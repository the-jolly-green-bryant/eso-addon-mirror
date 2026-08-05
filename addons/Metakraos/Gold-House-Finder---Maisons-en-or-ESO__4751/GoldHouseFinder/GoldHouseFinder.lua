local GHF = {}
local ADDON_NAME = "GoldHouseFinder"
local MAX_HOUSE_ID = 500
local ROW_COUNT = 11
local ROW_HEIGHT = 32
local PRICE_UNKNOWN = -1

local BUDGET_FILTERS = {
    { label = "Tous", minGold = nil, maxGold = nil },
    { label = "< 100k", maxGold = 100000 },
    { label = "100k - 500k", minGold = 100001, maxGold = 500000 },
    { label = "500k - 1M", minGold = 500001, maxGold = 1000000 },
    { label = "> 1M", minGold = 1000001 },
}

local ENVIRONMENT_FILTERS = {
    { label = "Tous", value = nil },
    { label = "Ville", value = "Ville" },
    { label = "Bord de mer", value = "Bord de mer" },
    { label = "Riviere / lac", value = "Riviere / lac" },
    { label = "Campagne / isole", value = "Campagne / isole" },
}

local TERRAIN_FILTERS = {
    { label = "Tous", value = nil },
    { label = "Aucun / interieur", value = "Aucun / interieur" },
    { label = "Petit", value = "Petit" },
    { label = "Moyen", value = "Moyen" },
    { label = "Grand", value = "Grand" },
}

local DWELLING_FILTERS = {
    { label = "Tous", value = nil },
    { label = "Tres petite", value = "Tres petite" },
    { label = "Petite", value = "Petite" },
    { label = "Moyenne", value = "Moyenne" },
    { label = "Grande", value = "Grande" },
    { label = "Tres grande", value = "Tres grande" },
}

local ACHIEVEMENT_SEARCH_ALIASES = {
    ["Malabal Tor Adventurer"] = { "Aventurier de Malabal Tor", "Malabal Tor" },
    ["Aldmeri Dominion Adventurer"] = { "Aventurier du Domaine aldmeri", "Domaine aldmeri" },
    ["Daggerfall Covenant Adventurer"] = { "Aventurier de l'Alliance de Daguefilante", "Daguefilante" },
    ["Ebonheart Pact Adventurer"] = { "Aventurier du Pacte de Coeurebene", "Pacte de Coeurebene" },
    ["Grahtwood Adventurer"] = { "Aventurier de Grahtwood", "Grahtwood" },
    ["Reaper's March Adventurer"] = { "Aventurier de la Marche de la Camarde", "Marche de la Camarde" },
    ["Wrothgar Adventurer"] = { "Aventurier de Wrothgar", "Wrothgar" },
    ["Craglorn Adventurer"] = { "Aventurier de Raidelorn", "Raidelorn" },
    ["Bangkorai Adventurer"] = { "Aventurier de Bangkorai", "Bangkorai" },
    ["Deshaan Adventurer"] = { "Aventurier de Deshaan", "Deshaan" },
    ["The Rift Adventurer"] = { "Aventurier de la Breche", "Breche" },
    ["Shadowfen Adventurer"] = { "Aventurier de Fangeombre", "Fangeombre" },
    ["Blackwood Grand Adventurer"] = { "Grand aventurier du Bois noir", "Bois noir" },
    ["Summerset Grand Adventurer"] = { "Grand aventurier du Couchant", "Couchant" },
    ["An Unsparing Harvest"] = { "Impitoyable moisson" },
    ["Champion of Vivec"] = { "Champion de Vivec" },
    ["Coldharbour Master Explorer"] = { "Maitre explorateur de Havreglace", "Havreglace" },
}

local HOUSE_META_BY_ID = {
    [1] = { env = "Ville", terrain = "Aucun / interieur", dwelling = "Tres petite" },
    [2] = { env = "Ville", terrain = "Aucun / interieur", dwelling = "Tres petite" },
    [3] = { env = "Ville", terrain = "Aucun / interieur", dwelling = "Tres petite" },
    [4] = { env = "Ville", terrain = "Aucun / interieur", dwelling = "Tres petite" },
    [5] = { env = "Ville", terrain = "Aucun / interieur", dwelling = "Tres petite" },
    [6] = { env = "Ville", terrain = "Aucun / interieur", dwelling = "Tres petite" },
    [7] = { env = "Campagne / isole", terrain = "Petit", dwelling = "Petite" },
    [8] = { env = "Ville", terrain = "Petit", dwelling = "Moyenne" },
    [9] = { env = "Ville", terrain = "Moyen", dwelling = "Grande" },
    [10] = { env = "Ville", terrain = "Petit", dwelling = "Petite" },
    [11] = { env = "Ville", terrain = "Moyen", dwelling = "Moyenne" },
    [12] = { env = "Riviere / lac", terrain = "Grand", dwelling = "Grande" },
    [13] = { env = "Ville", terrain = "Petit", dwelling = "Petite" },
    [14] = { env = "Campagne / isole", terrain = "Moyen", dwelling = "Moyenne" },
    [15] = { env = "Campagne / isole", terrain = "Grand", dwelling = "Grande" },
    [16] = { env = "Ville", terrain = "Aucun / interieur", dwelling = "Petite" },
    [17] = { env = "Ville", terrain = "Petit", dwelling = "Moyenne" },
    [18] = { env = "Ville", terrain = "Petit", dwelling = "Grande" },
    [19] = { env = "Ville", terrain = "Petit", dwelling = "Petite" },
    [20] = { env = "Ville", terrain = "Petit", dwelling = "Moyenne" },
    [21] = { env = "Campagne / isole", terrain = "Moyen", dwelling = "Grande" },
    [22] = { env = "Campagne / isole", terrain = "Petit", dwelling = "Petite" },
    [23] = { env = "Riviere / lac", terrain = "Moyen", dwelling = "Moyenne" },
    [24] = { env = "Ville", terrain = "Grand", dwelling = "Grande" },
    [25] = { env = "Campagne / isole", terrain = "Petit", dwelling = "Petite" },
    [26] = { env = "Campagne / isole", terrain = "Moyen", dwelling = "Moyenne" },
    [27] = { env = "Riviere / lac", terrain = "Grand", dwelling = "Grande" },
    [28] = { env = "Riviere / lac", terrain = "Moyen", dwelling = "Petite" },
    [29] = { env = "Ville", terrain = "Aucun / interieur", dwelling = "Moyenne" },
    [30] = { env = "Ville", terrain = "Grand", dwelling = "Grande" },
    [31] = { env = "Campagne / isole", terrain = "Petit", dwelling = "Petite" },
    [32] = { env = "Campagne / isole", terrain = "Moyen", dwelling = "Moyenne" },
    [33] = { env = "Campagne / isole", terrain = "Grand", dwelling = "Grande" },
    [34] = { env = "Ville", terrain = "Petit", dwelling = "Petite" },
    [35] = { env = "Ville", terrain = "Moyen", dwelling = "Moyenne" },
    [36] = { env = "Bord de mer", terrain = "Grand", dwelling = "Grande" },
    [37] = { env = "Riviere / lac", terrain = "Grand", dwelling = "Tres grande" },
    [38] = { env = "Bord de mer", terrain = "Grand", dwelling = "Tres grande" },
    [39] = { env = "Bord de mer", terrain = "Grand", dwelling = "Tres grande" },
    [42] = { env = "Ville", terrain = "Aucun / interieur", dwelling = "Tres petite" },
    [43] = { env = "Riviere / lac", terrain = "Grand", dwelling = "Grande" },
    [44] = { env = "Bord de mer", terrain = "Moyen", dwelling = "Moyenne" },
    [47] = { env = "Campagne / isole", terrain = "Grand", dwelling = "Petite" },
    [48] = { env = "Campagne / isole", terrain = "Grand", dwelling = "Tres grande" },
    [49] = { env = "Campagne / isole", terrain = "Moyen", dwelling = "Petite" },
    [58] = { env = "Ville", terrain = "Aucun / interieur", dwelling = "Tres petite" },
    [59] = { env = "Ville", terrain = "Petit", dwelling = "Grande" },
    [68] = { env = "Ville", terrain = "Aucun / interieur", dwelling = "Tres petite" },
    [70] = { env = "Ville", terrain = "Moyen", dwelling = "Grande" },
}

local GOLD_HOUSES_BY_EN_NAME = {
    ["Alinor Crest Townhouse"] = { gold = 1025000, req = "Summerset Grand Adventurer" },
    ["Ample Domicile"] = { gold = 195000, req = "Egg and Root" },
    ["Autumn's-Gate"] = { gold = 60000, req = "Master Fisher" },
    ["Black Vine Villa"] = { gold = 54000, req = "Aldmeri Dominion Adventurer" },
    ["Bouldertree Refuge"] = { gold = 190000, req = "Malabal Tor Adventurer" },
    ["Captain Margaux's Place"] = { gold = 56000, req = "Daggerfall Covenant Adventurer" },
    ["Cliffshade"] = { gold = 255000, req = "Aldmeri Dominion Adventurer" },
    ["Coldharbour Surreal Estate"] = { gold = 1000000, req = "Coldharbour Master Explorer" },
    ["Cyrodilic Jungle House"] = { gold = 71000, req = "Aldmeri Dominion Adventurer" },
    ["Daggerfall Overlook"] = { gold = 3785000, req = "Hero of the Daggerfall Covenant" },
    ["Domus Phrasticus"] = { gold = 295000, req = "Craglorn Adventurer" },
    ["Ebonheart Chateau"] = { gold = 3785000, req = "Hero of the Ebonheart Pact" },
    ["Exorcised Coven Cottage"] = { gold = 250000, req = "An Unsparing Harvest" },
    ["Forsaken Stronghold"] = { gold = 1285000, req = "Wrothgar Adventurer" },
    ["Gardner House"] = { gold = 1015000, req = "Daggerfall Covenant Adventurer" },
    ["Gorinir Estate"] = { gold = 780000, req = "Grahtwood Adventurer" },
    ["Grymharth's Woe"] = { gold = 280000, req = "Ebonheart Pact Adventurer" },
    ["Hammerdeath Bungalow"] = { gold = 65000, req = "Daggerfall Covenant Adventurer" },
    ["Hakkvild's High Hall"] = { gold = 3800000, req = "Falkreath Hold Vanquisher" },
    ["Hall of the Lunar Champion"] = { gold = 0, req = "Quest reward; tablets unlock rooms" },
    ["Hunding's Palatial Hall"] = { gold = 1295000, req = "Stros M'Kai Master Explorer" },
    ["Humblemud"] = { gold = 40000, req = "Ebonheart Pact Adventurer" },
    ["Kragenhome"] = { gold = 69000, req = "Ebonheart Pact Adventurer" },
    ["Mathiisen Manor"] = { gold = 1025000, req = "Aldmeri Dominion Adventurer" },
    ["Mournoth Keep"] = { gold = 325000, req = "Bangkorai Adventurer" },
    ["Old Mistveil Manor"] = { gold = 1020000, req = "Ebonheart Pact Adventurer" },
    ["Quondam Indorilia"] = { gold = 1265000, req = "Deshaan Adventurer" },
    ["Ravenhurst"] = { gold = 260000, req = "Daggerfall Covenant Adventurer" },
    ["Serenity Falls Estate"] = { gold = 3775000, req = "Hero of the Aldmeri Dominion" },
    ["Sleek Creek House"] = { gold = 335000, req = "Reaper's March Adventurer" },
    ["Snugpod"] = { gold = 45000, req = "Reliquary Retriever" },
    ["Stay-Moist Mansion"] = { gold = 760000, req = "Shadowfen Adventurer" },
    ["Strident Springs Demesne"] = { gold = 1280000, req = "Reaper's March Adventurer" },
    ["The Ample Domicile"] = { gold = 195000, req = "Egg and Root" },
    ["The Ebony Flask Inn Room"] = { gold = 3000, req = "A Friend in Need" },
    ["The Gorinir Estate"] = { gold = 780000, req = "Grahtwood Adventurer" },
    ["The Rosy Lion"] = { gold = 3000, req = "A Friend in Need" },
    ["Twin Arches"] = { gold = 73000, req = "High King Emeric's Savior" },
    ["Velothi Reverie"] = { gold = 323000, req = "Plague Eater" },
    ["Water's Edge"] = { gold = 1050000, req = "Blackwood Grand Adventurer" },
}

local GOLD_HOUSE_IDS = {
    [1] = { gold = 3000, req = "A Friend in Need" },
    [2] = { gold = 3000, req = "A Friend in Need" },
    [3] = { gold = 3000, req = "A Friend in Need" },
    [4] = { gold = 11000, req = "No achievement required" },
    [5] = { gold = 12000, req = "No achievement required" },
    [6] = { gold = 13000, req = "No achievement required" },
    [7] = { gold = 54000, req = "Aldmeri Dominion Adventurer" },
    [8] = { gold = 255000, req = "Aldmeri Dominion Adventurer" },
    [9] = { gold = 1025000, req = "Aldmeri Dominion Adventurer" },
    [10] = { gold = 40000, req = "Ebonheart Pact Adventurer" },
    [11] = { gold = 195000, req = "Egg and Root" },
    [12] = { gold = 760000, req = "Shadowfen Adventurer" },
    [13] = { gold = 45000, req = "Reliquary Retriever" },
    [14] = { gold = 190000, req = "Malabal Tor Adventurer" },
    [15] = { gold = 780000, req = "Grahtwood Adventurer" },
    [16] = { gold = 56000, req = "Daggerfall Covenant Adventurer" },
    [17] = { gold = 260000, req = "Daggerfall Covenant Adventurer" },
    [18] = { gold = 1015000, req = "Daggerfall Covenant Adventurer" },
    [19] = { gold = 69000, req = "Ebonheart Pact Adventurer" },
    [20] = { gold = 323000, req = "Plague Eater" },
    [21] = { gold = 1265000, req = "Deshaan Adventurer" },
    [22] = { gold = 50000, req = "Maormer's Bane" },
    [23] = { gold = 335000, req = "Reaper's March Adventurer" },
    [24] = { gold = 1275000, req = "Reaper's March Adventurer" },
    [25] = { gold = 71000, req = "Aldmeri Dominion Adventurer" },
    [26] = { gold = 295000, req = "Craglorn Adventurer" },
    [27] = { gold = 1280000, req = "Reaper's March Adventurer" },
    [28] = { gold = 60000, req = "The Rift Adventurer" },
    [29] = { gold = 280000, req = "Ebonheart Pact Adventurer" },
    [30] = { gold = 1020000, req = "Ebonheart Pact Adventurer" },
    [31] = { gold = 65000, req = "Daggerfall Covenant Adventurer" },
    [32] = { gold = 325000, req = "Bangkorai Adventurer" },
    [33] = { gold = 1285000, req = "Wrothgar Adventurer" },
    [34] = { gold = 73000, req = "High King Emeric's Savior" },
    [35] = { gold = 320000, req = "Consecrated Ground" },
    [36] = { gold = 1295000, req = "Stros M'Kai Master Explorer" },
    [37] = { gold = 3775000, req = "Hero of the Aldmeri Dominion" },
    [38] = { gold = 3785000, req = "Hero of the Daggerfall Covenant" },
    [39] = { gold = 3785000, req = "Hero of the Ebonheart Pact" },
    [42] = { gold = 3000, req = "A Friend in Need" },
    [43] = { gold = 1300000, req = "Savior of Morrowind" },
    [44] = { gold = 322000, req = "Champion of Vivec" },
    [47] = { gold = 1000000, req = "Coldharbour Master Explorer" },
    [48] = { gold = 3800000, req = "Falkreath Hold Vanquisher" },
    [49] = { gold = 250000, req = "An Unsparing Harvest" },
    [58] = { gold = 3000, req = "A Friend in Need" },
    [59] = { gold = 1025000, req = "Summerset Grand Adventurer" },
    [68] = { gold = 3000, req = "A Friend in Need" },
    [70] = { gold = 0, req = "Quest reward; tablets unlock rooms" },
}

local DEFAULT_SAVED_VARS = {
    extraGoldHouseIds = {},
    lastHouseScan = {},
    prerequisiteByCharacterId = {},
    achievementIdByName = {},
    budgetFilterIndex = 1,
    environmentFilterIndex = 1,
    terrainFilterIndex = 1,
    dwellingFilterIndex = 1,
    showOnlyUnowned = true,
    settingsSearchText = "",
    selectedHouseId = nil,
}

local function Chat(message)
    d("|cC6A85B[GoldHouseFinder]|r " .. tostring(message))
end

local function FormatGold(value)
    if not value or value == PRICE_UNKNOWN then
        return "prix or inconnu"
    end
    if value == 0 then
        return "gratuit/recompense"
    end
    local text = tostring(value)
    local k
    while true do
        text, k = text:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
        if k == 0 then break end
    end
    return text .. " or"
end

local function Normalize(value)
    return zo_strlower(tostring(value or ""))
end

local function GetServerProfile()
    if GetWorldName then
        local worldName = GetWorldName()
        if worldName and worldName ~= "" then
            return worldName
        end
    end

    return "Default"
end

function GHF.GetCurrentCharacterKey()
    if GetCurrentCharacterId then
        return tostring(GetCurrentCharacterId())
    end
    return "unknown"
end

function GHF.GetCachedHousePrerequisite(houseId)
    if not GHF.savedVars or not GHF.savedVars.prerequisiteByCharacterId then return nil end

    local characterKey = GHF.GetCurrentCharacterKey()
    local characterCache = GHF.savedVars.prerequisiteByCharacterId[characterKey]
    return characterCache and characterCache[houseId] or nil
end

function GHF.GetCachedAchievementIdByName(name)
    if not name or name == "" or not GHF.savedVars or not GHF.savedVars.achievementIdByName then return nil end
    return GHF.savedVars.achievementIdByName[Normalize(name)]
end

function GHF.SetCachedAchievementIdByName(name, achievementId)
    if not name or name == "" or not achievementId or achievementId == 0 or not GHF.savedVars then return end
    GHF.savedVars.achievementIdByName = GHF.savedVars.achievementIdByName or {}
    GHF.savedVars.achievementIdByName[Normalize(name)] = achievementId
end

function GHF.ExtractAchievementName(text)
    if not text or text == "" then return "" end

    local leftQuote = string.char(194, 171)
    local rightQuote = string.char(194, 187)
    local leftIndex = text:find(leftQuote, 1, true)
    if leftIndex then
        local rightIndex = text:find(rightQuote, leftIndex + #leftQuote, true)
        if rightIndex then
            return text:sub(leftIndex + #leftQuote, rightIndex - 1)
        end
    end

    return text:match("\"([^\"]+)\"") or text:match("'([^']+)'") or ""
end

function GHF.IsRealAchievementRequirement(name)
    if not name or name == "" then return false end

    local normalized = Normalize(name)
    if normalized == "no achievement required" then return false end
    if normalized:find("quest reward", 1, true) then return false end
    if normalized:find("gratuit", 1, true) then return false end
    if normalized:find("non renseigne", 1, true) then return false end
    return true
end

function GHF.GetHouseAchievementSearchName(house)
    if not house then return "" end
    if house.linkedAchievementName and house.linkedAchievementName ~= "" then
        return house.linkedAchievementName
    end

    local extracted = GHF.ExtractAchievementName(house.prerequisiteHint or house.prerequisiteState or "")
    if extracted ~= "" then return extracted end

    extracted = GHF.ExtractAchievementName(house.req or "")
    if extracted ~= "" then return extracted end

    if GHF.IsRealAchievementRequirement(house.req) then
        return house.req
    end

    return ""
end

function GHF.AddUniqueSearchCandidate(candidates, seen, value)
    if not value or value == "" then return end

    local key = Normalize(value)
    if key == "" or seen[key] then return end
    seen[key] = true
    table.insert(candidates, value)
end

function GHF.GetHouseAchievementSearchCandidates(house)
    local candidates = {}
    local seen = {}
    local primary = GHF.GetHouseAchievementSearchName(house)

    GHF.AddUniqueSearchCandidate(candidates, seen, primary)

    local aliases = ACHIEVEMENT_SEARCH_ALIASES[primary]
    if aliases then
        for _, alias in ipairs(aliases) do
            GHF.AddUniqueSearchCandidate(candidates, seen, alias)
        end
    end

    local zone = primary:match("^(.-) Grand Adventurer$") or primary:match("^(.-) Adventurer$")
    if zone and zone ~= "" then
        GHF.AddUniqueSearchCandidate(candidates, seen, zone)
    end

    return candidates, primary
end

function GHF.GetAchievementSearchScore(achievementName, searchName, requirementName)
    local normalizedAchievementName = Normalize(achievementName)
    local normalizedSearchName = Normalize(searchName)
    local normalizedRequirementName = Normalize(requirementName or searchName)
    local score = 0

    if normalizedAchievementName == normalizedSearchName then
        score = score + 100
    elseif normalizedAchievementName:find(normalizedSearchName, 1, true) then
        score = score + 60
    end

    if normalizedRequirementName:find("adventurer", 1, true) then
        if normalizedAchievementName:find("adventurer", 1, true) or normalizedAchievementName:find("aventurier", 1, true) then
            score = score + 50
        end
    end

    if normalizedRequirementName:find("grand adventurer", 1, true) then
        if normalizedAchievementName:find("grand", 1, true) then
            score = score + 30
        end
    end

    local zone = (requirementName or ""):match("^(.-) Grand Adventurer$") or (requirementName or ""):match("^(.-) Adventurer$")
    if zone and zone ~= "" and normalizedAchievementName:find(Normalize(zone), 1, true) then
        score = score + 40
    end

    return score
end

function GHF.IsLinkedAchievementCompleteForCurrentCharacter(achievementId)
    if not achievementId or achievementId == 0 or not IsAchievementComplete then
        return nil, ""
    end

    local achievementName = GetAchievementName and GetAchievementName(achievementId) or ""
    if not IsAchievementComplete(achievementId) then
        return false, achievementName
    end

    local persistenceLevel = GetAchievementPersistenceLevel and GetAchievementPersistenceLevel(achievementId) or ACHIEVEMENT_PERSISTENCE_UNDEFINED
    if persistenceLevel == ACHIEVEMENT_PERSISTENCE_CHARACTER then
        return true, achievementName
    end

    if GetCharIdForCompletedAchievement and GetCurrentCharacterId then
        local completedByCharId = GetCharIdForCompletedAchievement(achievementId)
        local currentCharacterId = GetCurrentCharacterId()
        local currentCharacterId64 = StringToId64 and StringToId64(currentCharacterId) or currentCharacterId

        if completedByCharId and tostring(completedByCharId) == tostring(currentCharacterId64) then
            return true, achievementName
        end

        local completedByName = completedByCharId and GetCharacterNameById and GetCharacterNameById(completedByCharId) or ""
        if completedByName ~= "" then
            return false, achievementName, completedByName
        end

        return false, achievementName
    end

    return nil, achievementName
end

function GHF.GetHouseLinkedAchievementId(collectibleId)
    if GetCollectibleLinkedAchievement then
        local achievementId = GetCollectibleLinkedAchievement(collectibleId)
        if achievementId and achievementId ~= 0 then
            return achievementId
        end
    end

    return nil
end

function GHF.GetAchievementLink(achievementId)
    if achievementId and achievementId ~= 0 and GetAchievementLink then
        return GetAchievementLink(achievementId, LINK_STYLE_BRACKETS or LINK_STYLE_DEFAULT)
    end

    return ""
end

function GHF.OpenAchievementById(achievementId)
    if not achievementId or achievementId == 0 then
        return false
    end

    local achievementsSystem = SYSTEMS and SYSTEMS:GetObject("achievements")
    if achievementsSystem and achievementsSystem.ShowAchievement then
        achievementsSystem:ShowAchievement(achievementId)
        return true
    end

    return false
end

function GHF.SetHouseLinkedAchievement(house, achievementId, name)
    if not house or not achievementId or achievementId == 0 then return end

    house.linkedAchievementId = achievementId
    house.linkedAchievementName = name or (GetAchievementName and GetAchievementName(achievementId)) or house.linkedAchievementName or ""
    house.linkedAchievementLink = GHF.GetAchievementLink(achievementId)
    GHF.SetCachedAchievementIdByName(house.linkedAchievementName, achievementId)
    GHF.SetCachedAchievementIdByName(house.req, achievementId)
end

function GHF.FindAchievementIdInSearchResults(searchName, requirementName)
    if not searchName or searchName == "" or not GetNumAchievementsSearchResults or not GetAchievementsSearchResult then
        return nil, ""
    end

    local normalizedSearchName = Normalize(searchName)
    local bestAchievementId = nil
    local bestName = ""
    local bestScore = 0

    for resultIndex = 1, GetNumAchievementsSearchResults() do
        local categoryIndex, subcategoryIndex, achievementIndex = GetAchievementsSearchResult(resultIndex)
        local achievementId = GetAchievementId(categoryIndex, subcategoryIndex, achievementIndex)
        if achievementId and achievementId ~= 0 then
            local achievementName = GetAchievementName and GetAchievementName(achievementId) or ""
            local normalizedAchievementName = Normalize(achievementName)
            if normalizedAchievementName == normalizedSearchName then
                return achievementId, achievementName
            end
            if normalizedAchievementName:find(normalizedSearchName, 1, true) then
                local score = GHF.GetAchievementSearchScore(achievementName, searchName, requirementName)
                if score > bestScore then
                    bestScore = score
                    bestAchievementId = achievementId
                    bestName = achievementName
                end
            end
        end
    end

    return bestAchievementId, bestName
end

function GHF.QueueAchievementSearch(house, openWhenFound, silent)
    if not house then return end

    local candidates, requirementName = GHF.GetHouseAchievementSearchCandidates(house)
    if #candidates == 0 then
        if not silent then
            Chat("Aucun succes requis connu pour cette maison.")
        end
        return
    end

    for _, candidate in ipairs(candidates) do
        local cachedAchievementId = GHF.GetCachedAchievementIdByName(candidate)
        if cachedAchievementId then
            GHF.SetHouseLinkedAchievement(house, cachedAchievementId, GetAchievementName and GetAchievementName(cachedAchievementId) or candidate)
            if openWhenFound and not GHF.OpenAchievementById(cachedAchievementId) and house.linkedAchievementLink ~= "" then
                Chat("Succes requis: " .. house.linkedAchievementLink)
            end
            GHF.RefreshSettingsPreview()
            return
        end
    end

    if not StartAchievementSearch or not EVENT_ACHIEVEMENTS_SEARCH_RESULTS_READY then
        if not silent then
            Chat("Recherche de succes indisponible dans cette API ESO.")
        end
        return
    end

    if GHF.pendingAchievementSearch then return end

    GHF.pendingAchievementSearch = {
        houseId = house.houseId,
        candidates = candidates,
        candidateIndex = 1,
        searchName = candidates[1],
        requirementName = requirementName,
        openWhenFound = openWhenFound == true,
        silent = silent == true,
    }

    StartAchievementSearch(candidates[1], true)
    if not silent then
        Chat("Recherche du succes requis: " .. candidates[1])
    end
end

function GHF.OnAchievementSearchResultsReady()
    local pending = GHF.pendingAchievementSearch
    if not pending then return end

    local achievementId, achievementName = GHF.FindAchievementIdInSearchResults(pending.searchName, pending.requirementName)
    local house = GHF.GetHouseById(pending.houseId)
    if not achievementId or not house then
        pending.candidateIndex = (pending.candidateIndex or 1) + 1
        local nextSearchName = pending.candidates and pending.candidates[pending.candidateIndex]
        if nextSearchName and StartAchievementSearch then
            pending.searchName = nextSearchName
            StartAchievementSearch(nextSearchName, true)
            if not pending.silent then
                Chat("Nouvelle recherche du succes requis: " .. nextSearchName)
            end
            return
        end

        GHF.pendingAchievementSearch = nil
        if not pending.silent then
            Chat("Succes introuvable: " .. tostring(pending.requirementName or pending.searchName))
        end
        return
    end

    GHF.pendingAchievementSearch = nil

    if pending.requirementName and pending.requirementName ~= "" then
        GHF.SetCachedAchievementIdByName(pending.requirementName, achievementId)
    end
    for _, candidate in ipairs(pending.candidates or {}) do
        GHF.SetCachedAchievementIdByName(candidate, achievementId)
    end

    GHF.SetHouseLinkedAchievement(house, achievementId, achievementName)
    local met, state, hint = GHF.GetPrerequisiteState(house.houseId, house.collectibleId, house.unlocked, house.purchasable, house.hint, achievementId, pending.requirementName)
    house.prerequisiteMet = met
    house.prerequisiteState = state
    house.prerequisiteHint = hint

    GHF.RefreshSettingsHouseChoices()
    GHF.RefreshSettingsPreview()
    GHF.Refresh()

    if pending.openWhenFound and not GHF.OpenAchievementById(achievementId) and house.linkedAchievementLink ~= "" then
        Chat("Succes requis: " .. house.linkedAchievementLink)
    elseif not pending.silent then
        Chat("Succes requis trouve: " .. (achievementName ~= "" and achievementName or tostring(pending.requirementName)))
    end
end

function GHF.OpenRequiredAchievement(house)
    if not house then return end

    if house.linkedAchievementId and GHF.OpenAchievementById(house.linkedAchievementId) then
        return
    end

    GHF.QueueAchievementSearch(house, true, false)
end

function GHF.InsertLinkedAchievementLink(house)
    if not house or not house.linkedAchievementLink or house.linkedAchievementLink == "" then
        Chat("Aucun lien de succes disponible pour cette maison.")
        return
    end

    if ZO_LinkHandler_InsertLink then
        ZO_LinkHandler_InsertLink(house.linkedAchievementLink)
    else
        Chat("Lien du succes: " .. house.linkedAchievementLink)
    end
end

function GHF.GetHouseImage(collectibleId, houseId, fallbackIcon)
    local image

    if GetCollectibleKeyboardBackgroundImage then
        image = GetCollectibleKeyboardBackgroundImage(collectibleId)
    end

    if (not image or image == "") and GetHousePreviewBackgroundImage and houseId then
        image = GetHousePreviewBackgroundImage(houseId)
    end

    if (not image or image == "") and GetCollectibleGamepadBackgroundImage then
        image = GetCollectibleGamepadBackgroundImage(collectibleId)
    end

    if not image or image == "" then
        image = fallbackIcon or "/esoui/art/icons/housing_gen_inc_unfurnished.dds"
    end

    return image
end

function GHF.GetGoldInfo(houseId, name)
    return (GHF.savedVars and GHF.savedVars.extraGoldHouseIds and GHF.savedVars.extraGoldHouseIds[houseId])
        or GOLD_HOUSE_IDS[houseId]
        or GOLD_HOUSES_BY_EN_NAME[name]
end

function GHF.GetHouseCategoryLabel(houseId)
    if GetHouseCategoryType then
        local categoryType = GetHouseCategoryType(houseId)
        if categoryType and categoryType ~= 0 then
            return GetString("SI_HOUSECATEGORYTYPE", categoryType)
        end
    end
    return ""
end

function GHF.GetTraditionalFurnitureLimit(houseId)
    if GetHouseFurnishingPlacementLimit and HOUSING_FURNISHING_LIMIT_TYPE_LOW_IMPACT_ITEM then
        local limit = GetHouseFurnishingPlacementLimit(houseId, HOUSING_FURNISHING_LIMIT_TYPE_LOW_IMPACT_ITEM)
        if limit and limit > 0 then
            return limit
        end
    end

    if GetDefaultHouseTemplateIdForHouse and GetHouseTemplateBaseFurnishingCountInfo and HOUSING_FURNISHING_LIMIT_TYPE_LOW_IMPACT_ITEM then
        local templateId = GetDefaultHouseTemplateIdForHouse(houseId)
        if templateId and templateId ~= 0 then
            local _, limit = GetHouseTemplateBaseFurnishingCountInfo(templateId, HOUSING_FURNISHING_LIMIT_TYPE_LOW_IMPACT_ITEM)
            if limit and limit > 0 then
                return limit
            end
        end
    end

    return nil
end

function GHF.GetPrerequisiteState(houseId, collectibleId, unlocked, purchasable, hint, linkedAchievementId, requirementName)
    if unlocked then
        return true, "Maison possedee", hint or ""
    end

    local cached = GHF.GetCachedHousePrerequisite(houseId)
    if cached and cached.checked then
        return cached.met == true, cached.text or (cached.met and "Prerequis OK" or "Prerequis manquant"), cached.errorText or hint or ""
    end

    if linkedAchievementId then
        local achievementId = linkedAchievementId
        if achievementId and achievementId ~= 0 then
            local characterHasAchievement, achievementName, completedByName = GHF.IsLinkedAchievementCompleteForCurrentCharacter(achievementId)
            if characterHasAchievement == true then
                if achievementName ~= "" then
                    return true, "Prerequis OK: " .. achievementName, hint or ""
                end
                return true, "Prerequis OK", hint or ""
            end

            if characterHasAchievement == false and achievementName ~= "" and completedByName and completedByName ~= "" then
                return false, "Prerequis manquant: " .. achievementName .. " (fait par " .. completedByName .. ")", hint or ""
            elseif characterHasAchievement == false and achievementName ~= "" then
                return false, "Prerequis manquant: " .. achievementName, hint or ""
            elseif characterHasAchievement == false then
                return false, "Prerequis manquant", hint or ""
            end
        end
    end

    if GHF.IsRealAchievementRequirement(requirementName) then
        return nil, "Succes requis: " .. requirementName, hint or ""
    end

    return nil, "Prerequis non resolu", hint or ""
end

function GHF.GetRequiredToBuyErrorText(buyStoreFailure, buyErrorStringId)
    if ZO_StoreManager_GetRequiredToBuyErrorText then
        local text = ZO_StoreManager_GetRequiredToBuyErrorText(buyStoreFailure, buyErrorStringId)
        if text and text ~= "" then
            return text
        end
    end

    if buyErrorStringId and buyErrorStringId ~= 0 and GetString then
        local text = GetString(buyErrorStringId)
        if text and text ~= "" then
            return text
        end
    end

    return "Prerequis manquant"
end

function GHF.SetHousePrerequisiteState(houseId, met, text, errorText)
    if not houseId or houseId == 0 or not GHF.savedVars then return end

    GHF.savedVars.prerequisiteByCharacterId = GHF.savedVars.prerequisiteByCharacterId or {}
    local characterKey = GHF.GetCurrentCharacterKey()
    GHF.savedVars.prerequisiteByCharacterId[characterKey] = GHF.savedVars.prerequisiteByCharacterId[characterKey] or {}
    GHF.savedVars.prerequisiteByCharacterId[characterKey][houseId] = {
        checked = true,
        met = met == true,
        text = text,
        errorText = errorText or "",
    }

    local house = GHF.GetHouseById(houseId)
    if house then
        house.prerequisiteMet = met == true
        house.prerequisiteState = text
        house.prerequisiteHint = errorText or house.prerequisiteHint or ""
        local achievementName = GHF.ExtractAchievementName(errorText)
        if achievementName ~= "" then
            house.linkedAchievementName = achievementName
            GHF.QueueAchievementSearch(house, false, true)
        end
    end
end

function GHF.RefreshCurrentHousePurchaseRequirement()
    if not GetCurrentZoneHouseId or not GetNumStoreItems or not GetStoreEntryInfo then return end

    local houseId = GetCurrentZoneHouseId()
    if not houseId or houseId == 0 then return end

    local sawGoldTemplate = false
    local meetsAnyTemplate = false
    local firstErrorText = nil

    for entryIndex = 1, GetNumStoreItems() do
        local _, _, _, _, _, meetsRequirementsToBuy, _, _, _, _, _, _, _, entryType, buyStoreFailure, buyErrorStringId = GetStoreEntryInfo(entryIndex)
        if entryType == STORE_ENTRY_TYPE_HOUSE_WITH_TEMPLATE then
            sawGoldTemplate = true
            if meetsRequirementsToBuy then
                meetsAnyTemplate = true
            elseif not firstErrorText then
                firstErrorText = GHF.GetRequiredToBuyErrorText(buyStoreFailure, buyErrorStringId)
            end
        end
    end

    if not sawGoldTemplate then return end

    if meetsAnyTemplate then
        GHF.SetHousePrerequisiteState(houseId, true, "Prerequis OK (verifie en boutique)", "")
    else
        GHF.SetHousePrerequisiteState(houseId, false, firstErrorText or "Prerequis manquant", firstErrorText or "")
    end

    GHF.RefreshSettingsHouseChoices()
    GHF.Refresh()
end

function GHF.Scan()
    GHF.houses = {}

    for houseId = 1, MAX_HOUSE_ID do
        local collectibleId = GetCollectibleIdForHouse(houseId)
        if collectibleId and collectibleId ~= 0 then
            local name, description, icon, lockedIcon, unlocked, purchasable, isActive, collectibleCategoryType, categoryType, hint, isPlaceholder = GetCollectibleInfo(collectibleId)
            local goldInfo = GHF.GetGoldInfo(houseId, name)

            if name and name ~= "" and goldInfo and not isPlaceholder then
                local meta = HOUSE_META_BY_ID[houseId] or {}
                local linkedAchievementId = GHF.GetHouseLinkedAchievementId(collectibleId)
                local linkedAchievementName = linkedAchievementId and GetAchievementName and GetAchievementName(linkedAchievementId) or ""
                local linkedAchievementLink = GHF.GetAchievementLink(linkedAchievementId)
                local prerequisiteMet, prerequisiteState, prerequisiteHint = GHF.GetPrerequisiteState(houseId, collectibleId, unlocked, purchasable, hint, linkedAchievementId, goldInfo.req)
                table.insert(GHF.houses, {
                    houseId = houseId,
                    collectibleId = collectibleId,
                    name = zo_strformat("<<1>>", name),
                    icon = icon or lockedIcon,
                    image = GHF.GetHouseImage(collectibleId, houseId, icon or lockedIcon),
                    environment = meta.env or "Non classe",
                    terrainSize = meta.terrain or "Non classe",
                    dwellingSize = meta.dwelling or "Non classe",
                    categoryLabel = GHF.GetHouseCategoryLabel(houseId),
                    traditionalLimit = GHF.GetTraditionalFurnitureLimit(houseId),
                    prerequisiteMet = prerequisiteMet,
                    prerequisiteState = prerequisiteState,
                    prerequisiteHint = prerequisiteHint,
                    linkedAchievementId = linkedAchievementId,
                    linkedAchievementName = linkedAchievementName,
                    linkedAchievementLink = linkedAchievementLink,
                    unlocked = unlocked,
                    purchasable = purchasable,
                    gold = goldInfo.gold,
                    req = goldInfo.req or "",
                    hint = hint or "",
                    description = description or "",
                })
            end
        end
    end

    table.sort(GHF.houses, function(a, b)
        if a.unlocked ~= b.unlocked then
            return not a.unlocked
        end
        local ag = a.gold == PRICE_UNKNOWN and 999999999 or a.gold
        local bg = b.gold == PRICE_UNKNOWN and 999999999 or b.gold
        if ag == bg then
            return a.name < b.name
        end
        return ag < bg
    end)

    GHF.ApplyFilter()
end

function GHF.DumpAllHouses()
    if not GHF.savedVars then return end

    GHF.savedVars.lastHouseScan = {
        api = GetAPIVersion and GetAPIVersion() or 0,
        language = GetCVar and GetCVar("language.2") or "",
        scannedAt = GetTimeString and GetTimeString() or "",
        houses = {},
    }

    local count = 0
    for houseId = 1, MAX_HOUSE_ID do
        local collectibleId = GetCollectibleIdForHouse(houseId)
        if collectibleId and collectibleId ~= 0 then
            local name, description, icon, lockedIcon, unlocked, purchasable, isActive, collectibleCategoryType, categoryType, hint, isPlaceholder = GetCollectibleInfo(collectibleId)
            if name and name ~= "" and not isPlaceholder then
                count = count + 1
                GHF.savedVars.lastHouseScan.houses[houseId] = {
                    collectibleId = collectibleId,
                    name = zo_strformat("<<1>>", name),
                    unlocked = unlocked == true,
                    purchasable = purchasable == true,
                    categoryType = categoryType,
                    hint = hint or "",
                }
            end
        end
    end

    Chat(string.format("%d maisons scannees. Regarde SavedVariables\\GoldHouseFinder.lua apres /reloadui ou deconnexion.", count))
end

function GHF.AddGoldHouseFromSlash(args)
    local houseIdText, goldText = zo_strsplit(" ", args or "")
    local houseId = tonumber(houseIdText)
    local gold = tonumber(goldText)

    if not houseId or not gold then
        Chat("Usage: /ghfadd houseId prixOr  exemple: /ghfadd 44 322000")
        return
    end

    GHF.savedVars.extraGoldHouseIds[houseId] = {
        gold = gold,
        req = "Ajoute manuellement",
    }
    GHF.Scan()
    Chat(string.format("Maison houseId %d ajoutee a la liste or avec prix %s.", houseId, FormatGold(gold)))
end

function GHF.ApplyFilter()
    GHF.filtered = {}
    local query = Normalize(GHF.searchText)
    local budget = BUDGET_FILTERS[GHF.budgetFilterIndex or 1] or BUDGET_FILTERS[1]
    local environment = ENVIRONMENT_FILTERS[GHF.environmentFilterIndex or 1] or ENVIRONMENT_FILTERS[1]
    local terrain = TERRAIN_FILTERS[GHF.terrainFilterIndex or 1] or TERRAIN_FILTERS[1]
    local dwelling = DWELLING_FILTERS[GHF.dwellingFilterIndex or 1] or DWELLING_FILTERS[1]

    for _, house in ipairs(GHF.houses or {}) do
        local haystack = Normalize(house.name .. " " .. FormatGold(house.gold) .. " " .. house.req .. " " .. house.environment .. " " .. house.terrainSize .. " " .. house.dwellingSize .. " " .. house.categoryLabel)
        local matchesSearch = query == "" or haystack:find(query, 1, true)
        local matchesOwnership = not GHF.showOnlyUnowned or not house.unlocked
        local matchesBudget = true
        local matchesEnvironment = not environment.value or house.environment == environment.value
        local matchesTerrain = not terrain.value or house.terrainSize == terrain.value
        local matchesDwelling = not dwelling.value or house.dwellingSize == dwelling.value

        if budget.minGold or budget.maxGold then
            matchesBudget = house.gold ~= PRICE_UNKNOWN
                and (not budget.minGold or house.gold >= budget.minGold)
                and (not budget.maxGold or house.gold <= budget.maxGold)
        end

        if matchesSearch and matchesOwnership and matchesBudget and matchesEnvironment and matchesTerrain and matchesDwelling then
            table.insert(GHF.filtered, house)
        end
    end

    GHF.page = math.max(1, math.min(GHF.page or 1, GHF.GetMaxPage()))
    GHF.RefreshFilterButtons()
    GHF.RefreshSettingsHouseChoices()
    GHF.Refresh()
end

function GHF.GetMaxPage()
    local count = #(GHF.filtered or {})
    return math.max(1, math.ceil(count / ROW_COUNT))
end

function GHF.RequestJump(house, outside)
    if not house then return end

    if IsUnitInCombat("player") then
        Chat("Impossible de se teleporter en combat.")
        return
    end

    if house.unlocked then
        RequestJumpToHouse(house.houseId, outside == true)
    else
        RequestJumpToHouse(house.houseId)
    end
end

function GHF.SelectHouse(house)
    GHF.selectedHouse = house
    GHF.ShowHousePreview(house)
    GHF.selectedLabel:SetText(house and house.name or "Selectionne une maison")
    GHF.priceLabel:SetText(house and FormatGold(house.gold) or "")
    GHF.requirementLabel:SetText(house and ("Prerequis: " .. (house.req ~= "" and house.req or "non renseigne")) or "Choisis une ligne pour voir les actions disponibles.")
    GHF.previewButton:SetHidden(house == nil)
    GHF.insideButton:SetHidden(not (house and house.unlocked))
    GHF.outsideButton:SetHidden(not (house and house.unlocked))
    GHF.buyHintLabel:SetHidden(not (house and not house.unlocked))
    GHF.Refresh()
end

function GHF.CreateRow(parent, index)
    local row = WINDOW_MANAGER:CreateControl(nil, parent, CT_BUTTON)
    row:SetDimensions(620, ROW_HEIGHT)
    row:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, (index - 1) * (ROW_HEIGHT + 4))
    row:SetNormalFontColor(0.94, 0.88, 0.74, 1)
    row:SetMouseOverFontColor(1, 1, 1, 1)
    row:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    row:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    row:SetHandler("OnClicked", function(control)
        GHF.SelectHouse(control.house)
    end)
    row:SetHandler("OnMouseEnter", function(control)
        GHF.ShowHousePreview(control.house)
    end)
    row:SetHandler("OnMouseExit", function()
        GHF.ShowHousePreview(GHF.selectedHouse)
    end)

    row.bg = WINDOW_MANAGER:CreateControlFromVirtual(nil, row, "ZO_DefaultBackdrop")
    row.bg:SetAnchorFill(row)
    row.bg:SetCenterColor(0.08, 0.075, 0.06, 0.82)
    row.bg:SetEdgeColor(0.45, 0.34, 0.18, 0.55)

    row.icon = WINDOW_MANAGER:CreateControl(nil, row, CT_TEXTURE)
    row.icon:SetDimensions(26, 26)
    row.icon:SetAnchor(LEFT, row, LEFT, 6, 0)

    row.text = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
    row.text:SetFont("ZoFontGame")
    row.text:SetAnchor(LEFT, row, LEFT, 40, 0)
    row.text:SetDimensions(405, ROW_HEIGHT)
    row.text:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    row.price = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
    row.price:SetFont("ZoFontGame")
    row.price:SetAnchor(RIGHT, row, RIGHT, -10, 0)
    row.price:SetDimensions(160, ROW_HEIGHT)
    row.price:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    row.price:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    return row
end

function GHF.CreateButton(parent, text, width, callback)
    local button = WINDOW_MANAGER:CreateControlFromVirtual(nil, parent, "ZO_DefaultButton")
    button:SetDimensions(width, 28)
    button:SetText(text)
    button:SetHandler("OnClicked", callback)
    return button
end

function GHF.CreateFilterButton(parent, text, width, callback)
    local button = GHF.CreateButton(parent, text, width, callback)
    button.defaultText = text
    return button
end

function GHF.RefreshFilterButtons()
    if not GHF.budgetButtons then return end

    for index, button in ipairs(GHF.budgetButtons) do
        local filter = BUDGET_FILTERS[index]
        if index == GHF.budgetFilterIndex then
            button:SetText("[" .. filter.label .. "]")
        else
            button:SetText(filter.label)
        end
    end

    if GHF.unownedButton then
        GHF.unownedButton:SetText(GHF.showOnlyUnowned and "[A acheter]" or "A acheter")
    end
end

function GHF.ShowHousePreview(house)
    if not GHF.previewPane then return end

    if not house then
        GHF.previewPane:SetHidden(false)
        GHF.previewTexture:SetTexture("/esoui/art/icons/housing_gen_inc_unfurnished.dds")
        GHF.previewName:SetText("Survole une maison")
        GHF.previewPrice:SetText("")
        GHF.previewReq:SetText("L'image depend de la texture fournie par le client ESO.")
        GHF.previewStatus:SetText("")
        return
    end

    GHF.previewPane:SetHidden(false)
    GHF.previewTexture:SetTexture(house.image or house.icon or "/esoui/art/icons/housing_gen_inc_unfurnished.dds")
    GHF.previewName:SetText(house.name)
    GHF.previewPrice:SetText(FormatGold(house.gold))
    GHF.previewReq:SetText(GHF.GetHouseDetailsText(house))
    if house.unlocked then
        GHF.previewStatus:SetText("Deja possedee")
        GHF.previewStatus:SetColor(0.44, 0.86, 0.45, 1)
    elseif house.prerequisiteMet == false then
        GHF.previewStatus:SetText("Prerequis manquant")
        GHF.previewStatus:SetColor(1, 0.33, 0.28, 1)
    elseif house.prerequisiteMet == true then
        GHF.previewStatus:SetText("Prerequis OK / a acheter")
        GHF.previewStatus:SetColor(0.78, 0.86, 0.68, 1)
    elseif GHF.GetHouseAchievementSearchName(house) ~= "" then
        GHF.previewStatus:SetText("Succes requis")
        GHF.previewStatus:SetColor(0.78, 0.86, 0.68, 1)
    else
        GHF.previewStatus:SetText("Prerequis non resolu")
        GHF.previewStatus:SetColor(0.78, 0.86, 0.68, 1)
    end
end

function GHF.GetHouseById(houseId)
    if not houseId then return nil end
    for _, house in ipairs(GHF.houses or {}) do
        if house.houseId == houseId then
            return house
        end
    end
    return nil
end

function GHF.GetSelectedSettingsHouse()
    return GHF.GetHouseById(GHF.settingsSelectedHouseId or GHF.savedVars.selectedHouseId)
end

function GHF.GetSettingsChoiceText(house)
    if not house then return "" end
    if house.unlocked then
        return string.format("%s - %s - %s - possede", house.name, FormatGold(house.gold), house.environment)
    end

    if house.prerequisiteMet == false then
        return string.format("|cFF5555%s - %s - %s - prerequis manquant|r", house.name, FormatGold(house.gold), house.environment)
    end

    if house.prerequisiteMet == true then
        return string.format("%s - %s - %s - prerequis OK", house.name, FormatGold(house.gold), house.environment)
    end

    if GHF.GetHouseAchievementSearchName(house) ~= "" then
        return string.format("%s - %s - %s - succes requis", house.name, FormatGold(house.gold), house.environment)
    end

    return string.format("%s - %s - %s - prerequis non resolu", house.name, FormatGold(house.gold), house.environment)
end

function GHF.GetHouseDetailsText(house)
    if not house then
        return "Change les filtres puis selectionne une maison."
    end

    local lines = {
        "Statut prerequis: " .. (house.prerequisiteState or "Inconnu"),
        "Prerequis: " .. (house.req ~= "" and house.req or "non renseigne"),
        "Emplacement: " .. (house.environment or "Non classe"),
        "Terrain: " .. (house.terrainSize or "Non classe"),
        "Habitation: " .. (house.dwellingSize or "Non classe"),
    }

    local achievementSearchName = GHF.GetHouseAchievementSearchName(house)
    if house.linkedAchievementLink and house.linkedAchievementLink ~= "" then
        table.insert(lines, "Succes requis: " .. house.linkedAchievementLink)
    elseif achievementSearchName ~= "" then
        table.insert(lines, "Succes requis: " .. achievementSearchName)
    end

    if house.prerequisiteHint and house.prerequisiteHint ~= "" and house.prerequisiteHint ~= house.req then
        table.insert(lines, "Info ESO: " .. house.prerequisiteHint)
    end

    if house.categoryLabel and house.categoryLabel ~= "" then
        table.insert(lines, "Categorie ESO: " .. house.categoryLabel)
    end

    if house.traditionalLimit then
        table.insert(lines, "Limite meubles traditionnels: " .. tostring(house.traditionalLimit))
    end

    return table.concat(lines, "\n")
end

function GHF.RefreshSettingsPreview()
    local house = GHF.GetSelectedSettingsHouse()

    if GHF.settingsPreviewTexture then
        GHF.settingsPreviewTexture:SetTexture((house and (house.image or house.icon)) or "/esoui/art/icons/housing_gen_inc_unfurnished.dds")
    end
    if GHF.settingsPreviewName then
        GHF.settingsPreviewName:SetText(house and house.name or "Aucune maison selectionnee")
        if house and house.prerequisiteMet == false and not house.unlocked then
            GHF.settingsPreviewName:SetColor(1, 0.33, 0.28, 1)
        else
            GHF.settingsPreviewName:SetColor(0.98, 0.86, 0.52, 1)
        end
    end
    if GHF.settingsPreviewPrice then
        GHF.settingsPreviewPrice:SetText(house and FormatGold(house.gold) or "")
    end
    if GHF.settingsPreviewStatus then
        if not house then
            GHF.settingsPreviewStatus:SetText("")
            GHF.settingsPreviewStatus:SetColor(0.78, 0.86, 0.68, 1)
        elseif house.unlocked then
            GHF.settingsPreviewStatus:SetText("Deja possedee")
            GHF.settingsPreviewStatus:SetColor(0.44, 0.86, 0.45, 1)
        elseif house.prerequisiteMet == false then
            GHF.settingsPreviewStatus:SetText("Prerequis manquant")
            GHF.settingsPreviewStatus:SetColor(1, 0.33, 0.28, 1)
        elseif house.prerequisiteMet == true then
            GHF.settingsPreviewStatus:SetText("Prerequis OK / a acheter")
            GHF.settingsPreviewStatus:SetColor(0.78, 0.86, 0.68, 1)
        elseif GHF.GetHouseAchievementSearchName(house) ~= "" then
            GHF.settingsPreviewStatus:SetText("Succes requis")
            GHF.settingsPreviewStatus:SetColor(0.78, 0.86, 0.68, 1)
        else
            GHF.settingsPreviewStatus:SetText("Prerequis non resolu")
            GHF.settingsPreviewStatus:SetColor(0.78, 0.86, 0.68, 1)
        end
    end
    if GHF.settingsPreviewReq then
        GHF.settingsPreviewReq:SetText(GHF.GetHouseDetailsText(house))
        if house and house.prerequisiteMet == false and not house.unlocked then
            GHF.settingsPreviewReq:SetColor(1, 0.38, 0.32, 1)
        else
            GHF.settingsPreviewReq:SetColor(0.82, 0.78, 0.68, 1)
        end
    end

    if house and not house.unlocked and not house.linkedAchievementId and GHF.GetHouseAchievementSearchName(house) ~= "" then
        GHF.QueueAchievementSearch(house, false, true)
    end
end

function GHF.RefreshSettingsHouseChoices()
    if not GHF.settingsPanelCreated then return end

    local choices = {}
    local values = {}
    for _, house in ipairs(GHF.filtered or {}) do
        table.insert(choices, GHF.GetSettingsChoiceText(house))
        table.insert(values, house.houseId)
    end

    if #choices == 0 then
        choices = { "Aucune maison avec ces filtres" }
        values = { 0 }
        GHF.settingsSelectedHouseId = nil
        GHF.savedVars.selectedHouseId = nil
    elseif not GHF.GetSelectedSettingsHouse() then
        GHF.settingsSelectedHouseId = values[1]
        GHF.savedVars.selectedHouseId = values[1]
    end

    local control = _G.GoldHouseFinderHouseDropdown
    if control and control.UpdateChoices then
        control:UpdateChoices(choices, values)
        control:UpdateValue()
    end

    GHF.RefreshSettingsPreview()
end

function GHF.CreateSettingsPanel()
    local LAM = LibAddonMenu2
    if not LAM then
        Chat("LibAddonMenu-2.0 non detecte: pas de panneau dans Reglages > Extensions, mais l'interface reste disponible.")
        return
    end

    local panelName = "GoldHouseFinderOptions"
    GHF.settingsPanel = LAM:RegisterAddonPanel(panelName, {
        type = "panel",
        name = "Gold House Finder",
        displayName = "Gold House Finder",
        author = "Metakraos",
        version = "1.7.5",
        registerForRefresh = true,
        registerForDefaults = true,
    })

    LAM:RegisterOptionControls(panelName, {
        {
            type = "description",
            text = "Interface pour trouver les maisons achetables avec de l'or et lancer l'apercu ou le TP.",
        },
        {
            type = "editbox",
            name = "Recherche",
            tooltip = "Filtre par nom, prix ou prerequis.",
            getFunc = function()
                return GHF.searchText or ""
            end,
            setFunc = function(value)
                GHF.searchText = value or ""
                GHF.savedVars.settingsSearchText = GHF.searchText
                GHF.page = 1
                GHF.ApplyFilter()
            end,
            width = "full",
            default = "",
        },
        {
            type = "checkbox",
            name = "Afficher seulement les maisons a acheter",
            tooltip = "Masque les maisons deja possedees.",
            getFunc = function()
                return GHF.showOnlyUnowned == true
            end,
            setFunc = function(value)
                GHF.showOnlyUnowned = value
                GHF.savedVars.showOnlyUnowned = value
                GHF.page = 1
                GHF.ApplyFilter()
            end,
            default = DEFAULT_SAVED_VARS.showOnlyUnowned,
        },
        {
            type = "dropdown",
            name = "Budget",
            choices = { "Tous", "< 100k", "100k - 500k", "500k - 1M", "> 1M" },
            getFunc = function()
                local filter = BUDGET_FILTERS[GHF.budgetFilterIndex or 1] or BUDGET_FILTERS[1]
                return filter.label
            end,
            setFunc = function(value)
                for index, filter in ipairs(BUDGET_FILTERS) do
                    if filter.label == value then
                        GHF.budgetFilterIndex = index
                        GHF.savedVars.budgetFilterIndex = index
                        break
                    end
                end
                GHF.page = 1
                GHF.ApplyFilter()
            end,
            default = BUDGET_FILTERS[DEFAULT_SAVED_VARS.budgetFilterIndex].label,
        },
        {
            type = "dropdown",
            name = "Emplacement",
            choices = { "Tous", "Ville", "Bord de mer", "Riviere / lac", "Campagne / isole" },
            getFunc = function()
                local filter = ENVIRONMENT_FILTERS[GHF.environmentFilterIndex or 1] or ENVIRONMENT_FILTERS[1]
                return filter.label
            end,
            setFunc = function(value)
                for index, filter in ipairs(ENVIRONMENT_FILTERS) do
                    if filter.label == value then
                        GHF.environmentFilterIndex = index
                        GHF.savedVars.environmentFilterIndex = index
                        break
                    end
                end
                GHF.page = 1
                GHF.ApplyFilter()
            end,
            default = ENVIRONMENT_FILTERS[DEFAULT_SAVED_VARS.environmentFilterIndex].label,
            width = "half",
        },
        {
            type = "dropdown",
            name = "Taille terrain",
            choices = { "Tous", "Aucun / interieur", "Petit", "Moyen", "Grand" },
            getFunc = function()
                local filter = TERRAIN_FILTERS[GHF.terrainFilterIndex or 1] or TERRAIN_FILTERS[1]
                return filter.label
            end,
            setFunc = function(value)
                for index, filter in ipairs(TERRAIN_FILTERS) do
                    if filter.label == value then
                        GHF.terrainFilterIndex = index
                        GHF.savedVars.terrainFilterIndex = index
                        break
                    end
                end
                GHF.page = 1
                GHF.ApplyFilter()
            end,
            default = TERRAIN_FILTERS[DEFAULT_SAVED_VARS.terrainFilterIndex].label,
            width = "half",
        },
        {
            type = "dropdown",
            name = "Taille habitation",
            choices = { "Tous", "Tres petite", "Petite", "Moyenne", "Grande", "Tres grande" },
            getFunc = function()
                local filter = DWELLING_FILTERS[GHF.dwellingFilterIndex or 1] or DWELLING_FILTERS[1]
                return filter.label
            end,
            setFunc = function(value)
                for index, filter in ipairs(DWELLING_FILTERS) do
                    if filter.label == value then
                        GHF.dwellingFilterIndex = index
                        GHF.savedVars.dwellingFilterIndex = index
                        break
                    end
                end
                GHF.page = 1
                GHF.ApplyFilter()
            end,
            default = DWELLING_FILTERS[DEFAULT_SAVED_VARS.dwellingFilterIndex].label,
            width = "half",
        },
        {
            type = "dropdown",
            name = "Maison",
            choices = { "Aucune maison chargee" },
            choicesValues = { 0 },
            scrollable = 12,
            getFunc = function()
                return GHF.settingsSelectedHouseId or GHF.savedVars.selectedHouseId or 0
            end,
            setFunc = function(value)
                if value and value ~= 0 then
                    GHF.settingsSelectedHouseId = value
                    GHF.savedVars.selectedHouseId = value
                    GHF.SelectHouse(GHF.GetHouseById(value))
                end
                GHF.RefreshSettingsPreview()
            end,
            width = "full",
            reference = "GoldHouseFinderHouseDropdown",
        },
        {
            type = "custom",
            reference = "GoldHouseFinderSettingsPreview",
            minHeight = 535,
            maxHeight = 535,
            width = "full",
            createFunc = function(control)
                local wm = WINDOW_MANAGER

                control.bg = wm:CreateControlFromVirtual(nil, control, "ZO_DefaultBackdrop")
                control.bg:SetAnchorFill(control)
                control.bg:SetCenterColor(0.055, 0.048, 0.038, 0.92)
                control.bg:SetEdgeColor(0.50, 0.37, 0.18, 0.8)

                GHF.settingsPreviewTexture = wm:CreateControl(nil, control, CT_TEXTURE)
                GHF.settingsPreviewTexture:SetDimensions(510, 255)
                GHF.settingsPreviewTexture:SetAnchor(TOP, control, TOP, 0, 18)
                GHF.settingsPreviewTexture:SetTextureCoords(0, 0.68359375, 0, 0.68359375)

                GHF.settingsPreviewName = wm:CreateControl(nil, control, CT_LABEL)
                GHF.settingsPreviewName:SetFont("ZoFontWinH4")
                GHF.settingsPreviewName:SetColor(0.98, 0.86, 0.52, 1)
                GHF.settingsPreviewName:SetAnchor(TOPLEFT, GHF.settingsPreviewTexture, BOTTOMLEFT, 0, 12)
                GHF.settingsPreviewName:SetDimensions(510, 34)
                GHF.settingsPreviewName:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)

                GHF.settingsPreviewPrice = wm:CreateControl(nil, control, CT_LABEL)
                GHF.settingsPreviewPrice:SetFont("ZoFontGameBold")
                GHF.settingsPreviewPrice:SetColor(0.92, 0.74, 0.32, 1)
                GHF.settingsPreviewPrice:SetAnchor(TOPLEFT, GHF.settingsPreviewName, BOTTOMLEFT, 0, 4)
                GHF.settingsPreviewPrice:SetDimensions(510, 24)

                GHF.settingsPreviewStatus = wm:CreateControl(nil, control, CT_LABEL)
                GHF.settingsPreviewStatus:SetFont("ZoFontGame")
                GHF.settingsPreviewStatus:SetColor(0.78, 0.86, 0.68, 1)
                GHF.settingsPreviewStatus:SetAnchor(TOPLEFT, GHF.settingsPreviewPrice, BOTTOMLEFT, 0, 4)
                GHF.settingsPreviewStatus:SetDimensions(510, 24)

                GHF.settingsPreviewReq = wm:CreateControl(nil, control, CT_LABEL)
                GHF.settingsPreviewReq:SetFont("ZoFontGameSmall")
                GHF.settingsPreviewReq:SetColor(0.82, 0.78, 0.68, 1)
                GHF.settingsPreviewReq:SetAnchor(TOPLEFT, GHF.settingsPreviewStatus, BOTTOMLEFT, 0, 6)
                GHF.settingsPreviewReq:SetDimensions(510, 136)
                GHF.settingsPreviewReq:SetMouseEnabled(true)

                GHF.RefreshSettingsPreview()
            end,
            refreshFunc = function()
                GHF.RefreshSettingsPreview()
            end,
        },
        {
            type = "button",
            name = "Apercu / visiter",
            tooltip = "Ouvre l'apercu si la maison n'est pas possedee, ou teleporte dedans si elle l'est.",
            func = function()
                GHF.RequestJump(GHF.GetSelectedSettingsHouse(), false)
            end,
            width = "half",
        },
        {
            type = "button",
            name = "TP exterieur",
            tooltip = "Disponible pour les maisons deja possedees.",
            func = function()
                GHF.RequestJump(GHF.GetSelectedSettingsHouse(), true)
            end,
            width = "half",
        },
        {
            type = "button",
            name = "Succes requis",
            tooltip = "Cherche puis ouvre le succes requis pour acheter cette maison avec de l'or.",
            func = function()
                GHF.OpenRequiredAchievement(GHF.GetSelectedSettingsHouse())
            end,
            disabled = function()
                local house = GHF.GetSelectedSettingsHouse()
                return not (house and GHF.GetHouseAchievementSearchName(house) ~= "")
            end,
            width = "full",
        },
        {
            type = "button",
            name = "Scanner les maisons du client",
            tooltip = "Sauvegarde les maisons vues par ton client dans SavedVariables\\GoldHouseFinder.lua.",
            func = function()
                GHF.DumpAllHouses()
            end,
        },
    })

    GHF.settingsPanelCreated = true
    GHF.Scan()
end

function GHF.CreateWindow()
    local wm = WINDOW_MANAGER
    local root = wm:CreateTopLevelWindow("GoldHouseFinderWindow")
    root:SetDimensions(965, 590)
    root:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    root:SetMouseEnabled(true)
    root:SetMovable(true)
    root:SetClampedToScreen(true)
    root:SetHidden(true)

    root.bg = wm:CreateControlFromVirtual(nil, root, "ZO_DefaultBackdrop")
    root.bg:SetAnchorFill(root)
    root.bg:SetCenterColor(0.035, 0.03, 0.025, 0.96)
    root.bg:SetEdgeColor(0.72, 0.52, 0.24, 0.85)

    local title = wm:CreateControl(nil, root, CT_LABEL)
    title:SetFont("ZoFontWinH2")
    title:SetColor(0.98, 0.84, 0.48, 1)
    title:SetText("Gold House Finder")
    title:SetAnchor(TOPLEFT, root, TOPLEFT, 18, 14)
    title:SetDimensions(520, 34)

    local subtitle = wm:CreateControl(nil, root, CT_LABEL)
    subtitle:SetFont("ZoFontGameSmall")
    subtitle:SetColor(0.78, 0.72, 0.62, 1)
    subtitle:SetText("Maisons achetables avec de l'or - megaserveur EU compatible")
    subtitle:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, -4)
    subtitle:SetDimensions(520, 22)

    local close = GHF.CreateButton(root, "X", 34, function() root:SetHidden(true) end)
    close:SetAnchor(TOPRIGHT, root, TOPRIGHT, -12, 12)

    local search = wm:CreateControlFromVirtual("GoldHouseFinderSearch", root, "ZO_DefaultEdit")
    search:SetDimensions(360, 30)
    search:SetAnchor(TOPLEFT, root, TOPLEFT, 18, 72)
    search:SetText("")
    search:SetHandler("OnTextChanged", function(control)
        GHF.searchText = control:GetText()
        GHF.page = 1
        GHF.ApplyFilter()
    end)
    GHF.search = search

    local refresh = GHF.CreateButton(root, "Actualiser", 105, function() GHF.Scan() end)
    refresh:SetAnchor(LEFT, search, RIGHT, 12, 0)

    local reset = GHF.CreateButton(root, "Effacer", 80, function()
        GHF.search:SetText("")
        GHF.searchText = ""
        GHF.page = 1
        GHF.ApplyFilter()
    end)
    reset:SetAnchor(LEFT, refresh, RIGHT, 8, 0)

    GHF.budgetButtons = {}
    local previousBudgetButton = nil
    for index, filter in ipairs(BUDGET_FILTERS) do
        local button = GHF.CreateFilterButton(root, filter.label, index == 1 and 58 or 68, function()
            GHF.budgetFilterIndex = index
            GHF.savedVars.budgetFilterIndex = index
            GHF.page = 1
            GHF.ApplyFilter()
        end)
        if previousBudgetButton then
            button:SetAnchor(LEFT, previousBudgetButton, RIGHT, 6, 0)
        else
            button:SetAnchor(TOPLEFT, root, TOPLEFT, 18, 112)
        end
        GHF.budgetButtons[index] = button
        previousBudgetButton = button
    end

    GHF.unownedButton = GHF.CreateFilterButton(root, "A acheter", 96, function()
        GHF.showOnlyUnowned = not GHF.showOnlyUnowned
        GHF.savedVars.showOnlyUnowned = GHF.showOnlyUnowned
        GHF.page = 1
        GHF.ApplyFilter()
    end)
    GHF.unownedButton:SetAnchor(LEFT, previousBudgetButton, RIGHT, 14, 0)

    GHF.countLabel = wm:CreateControl(nil, root, CT_LABEL)
    GHF.countLabel:SetFont("ZoFontGameSmall")
    GHF.countLabel:SetColor(0.82, 0.78, 0.68, 1)
    GHF.countLabel:SetAnchor(TOPLEFT, root, TOPLEFT, 18, 148)
    GHF.countLabel:SetDimensions(620, 22)

    local list = wm:CreateControl(nil, root, CT_CONTROL)
    list:SetDimensions(620, 392)
    list:SetAnchor(TOPLEFT, root, TOPLEFT, 18, 174)
    GHF.rows = {}
    for i = 1, ROW_COUNT do
        GHF.rows[i] = GHF.CreateRow(list, i)
    end

    GHF.prevButton = GHF.CreateButton(root, "<", 40, function()
        GHF.page = math.max(1, (GHF.page or 1) - 1)
        GHF.Refresh()
    end)
    GHF.prevButton:SetAnchor(BOTTOMLEFT, root, BOTTOMLEFT, 18, -18)

    GHF.pageLabel = wm:CreateControl(nil, root, CT_LABEL)
    GHF.pageLabel:SetFont("ZoFontGame")
    GHF.pageLabel:SetAnchor(LEFT, GHF.prevButton, RIGHT, 8, 0)
    GHF.pageLabel:SetDimensions(115, 28)
    GHF.pageLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    GHF.nextButton = GHF.CreateButton(root, ">", 40, function()
        GHF.page = math.min(GHF.GetMaxPage(), (GHF.page or 1) + 1)
        GHF.Refresh()
    end)
    GHF.nextButton:SetAnchor(LEFT, GHF.pageLabel, RIGHT, 4, 0)

    GHF.previewPane = wm:CreateControl(nil, root, CT_CONTROL)
    GHF.previewPane:SetDimensions(285, 390)
    GHF.previewPane:SetAnchor(TOPLEFT, list, TOPRIGHT, 18, 0)

    GHF.previewPaneBg = wm:CreateControlFromVirtual(nil, GHF.previewPane, "ZO_DefaultBackdrop")
    GHF.previewPaneBg:SetAnchorFill(GHF.previewPane)
    GHF.previewPaneBg:SetCenterColor(0.055, 0.048, 0.038, 0.92)
    GHF.previewPaneBg:SetEdgeColor(0.50, 0.37, 0.18, 0.8)

    GHF.previewTexture = wm:CreateControl(nil, GHF.previewPane, CT_TEXTURE)
    GHF.previewTexture:SetDimensions(248, 124)
    GHF.previewTexture:SetAnchor(TOP, GHF.previewPane, TOP, 0, 18)
    GHF.previewTexture:SetTexture("/esoui/art/icons/housing_gen_inc_unfurnished.dds")
    GHF.previewTexture:SetTextureCoords(0, 0.68359375, 0, 0.68359375)

    GHF.previewName = wm:CreateControl(nil, GHF.previewPane, CT_LABEL)
    GHF.previewName:SetFont("ZoFontWinH4")
    GHF.previewName:SetColor(0.98, 0.86, 0.52, 1)
    GHF.previewName:SetAnchor(TOPLEFT, GHF.previewTexture, BOTTOMLEFT, 0, 14)
    GHF.previewName:SetDimensions(248, 48)
    GHF.previewName:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    GHF.previewName:SetText("Survole une maison")

    GHF.previewPrice = wm:CreateControl(nil, GHF.previewPane, CT_LABEL)
    GHF.previewPrice:SetFont("ZoFontGameBold")
    GHF.previewPrice:SetColor(0.92, 0.74, 0.32, 1)
    GHF.previewPrice:SetAnchor(TOPLEFT, GHF.previewName, BOTTOMLEFT, 0, 6)
    GHF.previewPrice:SetDimensions(248, 24)

    GHF.previewStatus = wm:CreateControl(nil, GHF.previewPane, CT_LABEL)
    GHF.previewStatus:SetFont("ZoFontGame")
    GHF.previewStatus:SetColor(0.78, 0.86, 0.68, 1)
    GHF.previewStatus:SetAnchor(TOPLEFT, GHF.previewPrice, BOTTOMLEFT, 0, 4)
    GHF.previewStatus:SetDimensions(248, 24)

    GHF.previewReq = wm:CreateControl(nil, GHF.previewPane, CT_LABEL)
    GHF.previewReq:SetFont("ZoFontGameSmall")
    GHF.previewReq:SetColor(0.82, 0.78, 0.68, 1)
    GHF.previewReq:SetAnchor(TOPLEFT, GHF.previewStatus, BOTTOMLEFT, 0, 8)
    GHF.previewReq:SetDimensions(248, 70)
    GHF.previewReq:SetText("L'image depend de la texture fournie par le client ESO.")

    GHF.selectedLabel = wm:CreateControl(nil, root, CT_LABEL)
    GHF.selectedLabel:SetFont("ZoFontGameBold")
    GHF.selectedLabel:SetColor(0.98, 0.88, 0.58, 1)
    GHF.selectedLabel:SetAnchor(BOTTOMLEFT, root, BOTTOMLEFT, 230, -70)
    GHF.selectedLabel:SetDimensions(330, 24)
    GHF.selectedLabel:SetText("Selectionne une maison")

    GHF.priceLabel = wm:CreateControl(nil, root, CT_LABEL)
    GHF.priceLabel:SetFont("ZoFontGameBold")
    GHF.priceLabel:SetColor(0.92, 0.74, 0.32, 1)
    GHF.priceLabel:SetAnchor(LEFT, GHF.selectedLabel, RIGHT, 10, 0)
    GHF.priceLabel:SetDimensions(150, 24)
    GHF.priceLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)

    GHF.requirementLabel = wm:CreateControl(nil, root, CT_LABEL)
    GHF.requirementLabel:SetFont("ZoFontGameSmall")
    GHF.requirementLabel:SetColor(0.84, 0.80, 0.70, 1)
    GHF.requirementLabel:SetAnchor(TOPLEFT, GHF.selectedLabel, BOTTOMLEFT, 0, 0)
    GHF.requirementLabel:SetDimensions(440, 20)
    GHF.requirementLabel:SetText("Choisis une ligne pour voir les actions disponibles.")

    GHF.previewButton = GHF.CreateButton(root, "Apercu / TP", 105, function()
        GHF.RequestJump(GHF.selectedHouse, false)
    end)
    GHF.previewButton:SetAnchor(BOTTOMRIGHT, root, BOTTOMRIGHT, -18, -68)

    GHF.insideButton = GHF.CreateButton(root, "Interieur", 92, function()
        GHF.RequestJump(GHF.selectedHouse, false)
    end)
    GHF.insideButton:SetAnchor(RIGHT, GHF.previewButton, LEFT, -8, 0)

    GHF.outsideButton = GHF.CreateButton(root, "Exterieur", 92, function()
        GHF.RequestJump(GHF.selectedHouse, true)
    end)
    GHF.outsideButton:SetAnchor(RIGHT, GHF.insideButton, LEFT, -8, 0)

    GHF.buyHintLabel = wm:CreateControl(nil, root, CT_LABEL)
    GHF.buyHintLabel:SetFont("ZoFontGameSmall")
    GHF.buyHintLabel:SetColor(0.95, 0.78, 0.45, 1)
    GHF.buyHintLabel:SetText("Maison non possedee: le bouton ouvre l'apercu, l'achat se fait dans l'interface du jeu.")
    GHF.buyHintLabel:SetAnchor(BOTTOMRIGHT, root, BOTTOMRIGHT, -18, -22)
    GHF.buyHintLabel:SetDimensions(460, 20)
    GHF.buyHintLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)

    GHF.window = root
    GHF.SelectHouse(nil)
    GHF.CreateSettingsPanel()
    GHF.ShowHousePreview(nil)
end

function GHF.Refresh()
    if not GHF.window then return end

    local list = GHF.filtered or {}
    local maxPage = GHF.GetMaxPage()
    GHF.page = math.max(1, math.min(GHF.page or 1, maxPage))
    local offset = (GHF.page - 1) * ROW_COUNT

    GHF.countLabel:SetText(string.format("%d maison(s) trouvee(s). Recherche par nom, prix ou prerequis.", #list))
    GHF.pageLabel:SetText(string.format("Page %d / %d", GHF.page, maxPage))
    GHF.prevButton:SetEnabled(GHF.page > 1)
    GHF.nextButton:SetEnabled(GHF.page < maxPage)

    for i, row in ipairs(GHF.rows) do
        local house = list[offset + i]
        row.house = house
        row:SetHidden(house == nil)
        if house then
            local owned
            if house.unlocked then
                owned = "|c88E28Apossede|r"
            elseif house.prerequisiteMet == false then
                owned = "|cFF5555prerequis manquant|r"
            elseif house.prerequisiteMet == true then
                owned = "|cD8B35Aprerequis OK|r"
            elseif GHF.GetHouseAchievementSearchName(house) ~= "" then
                owned = "|cD8B35Asucces requis|r"
            else
                owned = "|cD8B35Aprerequis non resolu|r"
            end
            row.icon:SetTexture(house.icon or "/esoui/art/icons/icon_missing.dds")
            row.text:SetText(string.format("%s  (%s)", house.name, owned))
            row.price:SetText(FormatGold(house.gold))
            if GHF.selectedHouse and GHF.selectedHouse.houseId == house.houseId then
                row.bg:SetCenterColor(0.20, 0.14, 0.07, 0.95)
                row.bg:SetEdgeColor(0.95, 0.70, 0.30, 1)
            else
                row.bg:SetCenterColor(0.08, 0.075, 0.06, 0.82)
                row.bg:SetEdgeColor(0.45, 0.34, 0.18, 0.55)
            end
        end
    end
end

function GHF.Toggle()
    if GHF.settingsPanel and LibAddonMenu2 and LibAddonMenu2.OpenToPanel then
        GHF.Scan()
        LibAddonMenu2:OpenToPanel(GHF.settingsPanel)
        return
    end

    if not GHF.window then return end
    if GHF.window:IsHidden() then
        GHF.Scan()
        GHF.window:SetHidden(false)
    else
        GHF.window:SetHidden(true)
    end
end

function GHF.Initialize()
    GHF.savedVars = ZO_SavedVars:NewAccountWide("GoldHouseFinderVars", 1, nil, DEFAULT_SAVED_VARS, GetServerProfile())
    GHF.savedVars.prerequisiteByCharacterId = GHF.savedVars.prerequisiteByCharacterId or {}
    GHF.page = 1
    GHF.searchText = GHF.savedVars.settingsSearchText or ""
    GHF.budgetFilterIndex = GHF.savedVars.budgetFilterIndex or 1
    if not BUDGET_FILTERS[GHF.budgetFilterIndex] then
        GHF.budgetFilterIndex = 1
        GHF.savedVars.budgetFilterIndex = 1
    end
    GHF.environmentFilterIndex = GHF.savedVars.environmentFilterIndex or 1
    if not ENVIRONMENT_FILTERS[GHF.environmentFilterIndex] then
        GHF.environmentFilterIndex = 1
        GHF.savedVars.environmentFilterIndex = 1
    end
    GHF.terrainFilterIndex = GHF.savedVars.terrainFilterIndex or 1
    if not TERRAIN_FILTERS[GHF.terrainFilterIndex] then
        GHF.terrainFilterIndex = 1
        GHF.savedVars.terrainFilterIndex = 1
    end
    GHF.dwellingFilterIndex = GHF.savedVars.dwellingFilterIndex or 1
    if not DWELLING_FILTERS[GHF.dwellingFilterIndex] then
        GHF.dwellingFilterIndex = 1
        GHF.savedVars.dwellingFilterIndex = 1
    end
    GHF.showOnlyUnowned = GHF.savedVars.showOnlyUnowned ~= false
    GHF.settingsSelectedHouseId = GHF.savedVars.selectedHouseId
    GHF.houses = {}
    GHF.filtered = {}
    GHF.CreateWindow()

    SLASH_COMMANDS["/ghf"] = function() GHF.Toggle() end
    SLASH_COMMANDS["/goldhouses"] = function() GHF.Toggle() end
    SLASH_COMMANDS["/maisonsor"] = function() GHF.Toggle() end
    SLASH_COMMANDS["/ghfdump"] = function() GHF.DumpAllHouses() end
    SLASH_COMMANDS["/ghfadd"] = function(args) GHF.AddGoldHouseFromSlash(args) end

    if EVENT_OPEN_HOUSE_STORE then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_OPEN_HOUSE_STORE, function()
            GHF.RefreshCurrentHousePurchaseRequirement()
            if zo_callLater then
                zo_callLater(function() GHF.RefreshCurrentHousePurchaseRequirement() end, 250)
                zo_callLater(function() GHF.RefreshCurrentHousePurchaseRequirement() end, 750)
            end
        end)
    end

    if EVENT_ACHIEVEMENTS_SEARCH_RESULTS_READY then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "AchievementSearch", EVENT_ACHIEVEMENTS_SEARCH_RESULTS_READY, function()
            GHF.OnAchievementSearchResultsReady()
        end)
    end

    Chat("charge. Ouvre Reglages > Extensions > Gold House Finder, ou /ghf.")
end

local function OnAddonLoaded(eventCode, addonName)
    if addonName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    GHF.Initialize()
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)
