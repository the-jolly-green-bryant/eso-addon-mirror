GoldHouseFinder = {}

local GHF = GoldHouseFinder
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
    prerequisiteByHouseId = {},
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

function GHF:GetCurrentCharacterKey()
    if GetCurrentCharacterId then
        return tostring(GetCurrentCharacterId())
    end
    return "unknown"
end

function GHF:GetCachedHousePrerequisite(houseId)
    if not self.savedVars or not self.savedVars.prerequisiteByCharacterId then return nil end

    local characterKey = self:GetCurrentCharacterKey()
    local characterCache = self.savedVars.prerequisiteByCharacterId[characterKey]
    return characterCache and characterCache[houseId] or nil
end

function GHF:GetCachedAchievementIdByName(name)
    if not name or name == "" or not self.savedVars or not self.savedVars.achievementIdByName then return nil end
    return self.savedVars.achievementIdByName[Normalize(name)]
end

function GHF:SetCachedAchievementIdByName(name, achievementId)
    if not name or name == "" or not achievementId or achievementId == 0 or not self.savedVars then return end
    self.savedVars.achievementIdByName = self.savedVars.achievementIdByName or {}
    self.savedVars.achievementIdByName[Normalize(name)] = achievementId
end

function GHF:ExtractAchievementName(text)
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

function GHF:IsRealAchievementRequirement(name)
    if not name or name == "" then return false end

    local normalized = Normalize(name)
    if normalized == "no achievement required" then return false end
    if normalized:find("quest reward", 1, true) then return false end
    if normalized:find("gratuit", 1, true) then return false end
    if normalized:find("non renseigne", 1, true) then return false end
    return true
end

function GHF:GetHouseAchievementSearchName(house)
    if not house then return "" end
    if house.linkedAchievementName and house.linkedAchievementName ~= "" then
        return house.linkedAchievementName
    end

    local extracted = self:ExtractAchievementName(house.prerequisiteHint or house.prerequisiteState or "")
    if extracted ~= "" then return extracted end

    extracted = self:ExtractAchievementName(house.req or "")
    if extracted ~= "" then return extracted end

    if self:IsRealAchievementRequirement(house.req) then
        return house.req
    end

    return ""
end

function GHF:AddUniqueSearchCandidate(candidates, seen, value)
    if not value or value == "" then return end

    local key = Normalize(value)
    if key == "" or seen[key] then return end
    seen[key] = true
    table.insert(candidates, value)
end

function GHF:GetHouseAchievementSearchCandidates(house)
    local candidates = {}
    local seen = {}
    local primary = self:GetHouseAchievementSearchName(house)

    self:AddUniqueSearchCandidate(candidates, seen, primary)

    local aliases = ACHIEVEMENT_SEARCH_ALIASES[primary]
    if aliases then
        for _, alias in ipairs(aliases) do
            self:AddUniqueSearchCandidate(candidates, seen, alias)
        end
    end

    local zone = primary:match("^(.-) Grand Adventurer$") or primary:match("^(.-) Adventurer$")
    if zone and zone ~= "" then
        self:AddUniqueSearchCandidate(candidates, seen, zone)
    end

    return candidates, primary
end

function GHF:GetAchievementSearchScore(achievementName, searchName, requirementName)
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

function GHF:IsLinkedAchievementCompleteForCurrentCharacter(achievementId)
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

function GHF:GetHouseLinkedAchievementId(collectibleId)
    if GetCollectibleLinkedAchievement then
        local achievementId = GetCollectibleLinkedAchievement(collectibleId)
        if achievementId and achievementId ~= 0 then
            return achievementId
        end
    end

    return nil
end

function GHF:GetAchievementLink(achievementId)
    if achievementId and achievementId ~= 0 and GetAchievementLink then
        return GetAchievementLink(achievementId, LINK_STYLE_BRACKETS or LINK_STYLE_DEFAULT)
    end

    return ""
end

function GHF:OpenAchievementById(achievementId)
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

function GHF:SetHouseLinkedAchievement(house, achievementId, name)
    if not house or not achievementId or achievementId == 0 then return end

    house.linkedAchievementId = achievementId
    house.linkedAchievementName = name or (GetAchievementName and GetAchievementName(achievementId)) or house.linkedAchievementName or ""
    house.linkedAchievementLink = self:GetAchievementLink(achievementId)
    self:SetCachedAchievementIdByName(house.linkedAchievementName, achievementId)
    self:SetCachedAchievementIdByName(house.req, achievementId)
end

function GHF:FindAchievementIdInSearchResults(searchName, requirementName)
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
                local score = self:GetAchievementSearchScore(achievementName, searchName, requirementName)
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

function GHF:QueueAchievementSearch(house, openWhenFound, silent)
    if not house then return end

    local candidates, requirementName = self:GetHouseAchievementSearchCandidates(house)
    if #candidates == 0 then
        if not silent then
            Chat("Aucun succes requis connu pour cette maison.")
        end
        return
    end

    for _, candidate in ipairs(candidates) do
        local cachedAchievementId = self:GetCachedAchievementIdByName(candidate)
        if cachedAchievementId then
            self:SetHouseLinkedAchievement(house, cachedAchievementId, GetAchievementName and GetAchievementName(cachedAchievementId) or candidate)
            if openWhenFound and not self:OpenAchievementById(cachedAchievementId) and house.linkedAchievementLink ~= "" then
                Chat("Succes requis: " .. house.linkedAchievementLink)
            end
            self:RefreshSettingsPreview()
            return
        end
    end

    if not StartAchievementSearch or not EVENT_ACHIEVEMENTS_SEARCH_RESULTS_READY then
        if not silent then
            Chat("Recherche de succes indisponible dans cette API ESO.")
        end
        return
    end

    if self.pendingAchievementSearch then return end

    self.pendingAchievementSearch = {
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

function GHF:OnAchievementSearchResultsReady()
    local pending = self.pendingAchievementSearch
    if not pending then return end

    local achievementId, achievementName = self:FindAchievementIdInSearchResults(pending.searchName, pending.requirementName)
    local house = self:GetHouseById(pending.houseId)
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

        self.pendingAchievementSearch = nil
        if not pending.silent then
            Chat("Succes introuvable: " .. tostring(pending.requirementName or pending.searchName))
        end
        return
    end

    self.pendingAchievementSearch = nil

    if pending.requirementName and pending.requirementName ~= "" then
        self:SetCachedAchievementIdByName(pending.requirementName, achievementId)
    end
    for _, candidate in ipairs(pending.candidates or {}) do
        self:SetCachedAchievementIdByName(candidate, achievementId)
    end

    self:SetHouseLinkedAchievement(house, achievementId, achievementName)
    local met, state, hint = self:GetPrerequisiteState(house.houseId, house.collectibleId, house.unlocked, house.purchasable, house.hint, achievementId, pending.requirementName)
    house.prerequisiteMet = met
    house.prerequisiteState = state
    house.prerequisiteHint = hint

    self:RefreshSettingsHouseChoices()
    self:RefreshSettingsPreview()
    self:Refresh()

    if pending.openWhenFound and not self:OpenAchievementById(achievementId) and house.linkedAchievementLink ~= "" then
        Chat("Succes requis: " .. house.linkedAchievementLink)
    elseif not pending.silent then
        Chat("Succes requis trouve: " .. (achievementName ~= "" and achievementName or tostring(pending.requirementName)))
    end
end

function GHF:OpenRequiredAchievement(house)
    if not house then return end

    if house.linkedAchievementId and self:OpenAchievementById(house.linkedAchievementId) then
        return
    end

    self:QueueAchievementSearch(house, true, false)
end

function GHF:InsertLinkedAchievementLink(house)
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

function GHF:GetHouseImage(collectibleId, houseId, fallbackIcon)
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

function GHF:GetGoldInfo(houseId, name)
    return (self.savedVars and self.savedVars.extraGoldHouseIds and self.savedVars.extraGoldHouseIds[houseId])
        or GOLD_HOUSE_IDS[houseId]
        or GOLD_HOUSES_BY_EN_NAME[name]
end

function GHF:GetHouseCategoryLabel(houseId)
    if GetHouseCategoryType then
        local categoryType = GetHouseCategoryType(houseId)
        if categoryType and categoryType ~= 0 then
            return GetString("SI_HOUSECATEGORYTYPE", categoryType)
        end
    end
    return ""
end

function GHF:GetTraditionalFurnitureLimit(houseId)
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

function GHF:GetPrerequisiteState(houseId, collectibleId, unlocked, purchasable, hint, linkedAchievementId, requirementName)
    if unlocked then
        return true, "Maison possedee", hint or ""
    end

    local cached = self:GetCachedHousePrerequisite(houseId)
    if cached and cached.checked then
        return cached.met == true, cached.text or (cached.met and "Prerequis OK" or "Prerequis manquant"), cached.errorText or hint or ""
    end

    if linkedAchievementId then
        local achievementId = linkedAchievementId
        if achievementId and achievementId ~= 0 then
            local characterHasAchievement, achievementName, completedByName = self:IsLinkedAchievementCompleteForCurrentCharacter(achievementId)
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

    if self:IsRealAchievementRequirement(requirementName) then
        return nil, "Succes requis: " .. requirementName, hint or ""
    end

    return nil, "Prerequis non resolu", hint or ""
end

function GHF:GetRequiredToBuyErrorText(buyStoreFailure, buyErrorStringId)
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

function GHF:SetHousePrerequisiteState(houseId, met, text, errorText)
    if not houseId or houseId == 0 or not self.savedVars then return end

    self.savedVars.prerequisiteByCharacterId = self.savedVars.prerequisiteByCharacterId or {}
    local characterKey = self:GetCurrentCharacterKey()
    self.savedVars.prerequisiteByCharacterId[characterKey] = self.savedVars.prerequisiteByCharacterId[characterKey] or {}
    self.savedVars.prerequisiteByCharacterId[characterKey][houseId] = {
        checked = true,
        met = met == true,
        text = text,
        errorText = errorText or "",
    }

    local house = self:GetHouseById(houseId)
    if house then
        house.prerequisiteMet = met == true
        house.prerequisiteState = text
        house.prerequisiteHint = errorText or house.prerequisiteHint or ""
        local achievementName = self:ExtractAchievementName(errorText)
        if achievementName ~= "" then
            house.linkedAchievementName = achievementName
            self:QueueAchievementSearch(house, false, true)
        end
    end
end

function GHF:RefreshCurrentHousePurchaseRequirement()
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
                firstErrorText = self:GetRequiredToBuyErrorText(buyStoreFailure, buyErrorStringId)
            end
        end
    end

    if not sawGoldTemplate then return end

    if meetsAnyTemplate then
        self:SetHousePrerequisiteState(houseId, true, "Prerequis OK (verifie en boutique)", "")
    else
        self:SetHousePrerequisiteState(houseId, false, firstErrorText or "Prerequis manquant", firstErrorText or "")
    end

    self:RefreshSettingsHouseChoices()
    self:Refresh()
end

function GHF:Scan()
    self.houses = {}

    for houseId = 1, MAX_HOUSE_ID do
        local collectibleId = GetCollectibleIdForHouse(houseId)
        if collectibleId and collectibleId ~= 0 then
            local name, description, icon, lockedIcon, unlocked, purchasable, isActive, collectibleCategoryType, categoryType, hint, isPlaceholder = GetCollectibleInfo(collectibleId)
            local goldInfo = self:GetGoldInfo(houseId, name)

            if name and name ~= "" and goldInfo and not isPlaceholder then
                local meta = HOUSE_META_BY_ID[houseId] or {}
                local linkedAchievementId = self:GetHouseLinkedAchievementId(collectibleId)
                local linkedAchievementName = linkedAchievementId and GetAchievementName and GetAchievementName(linkedAchievementId) or ""
                local linkedAchievementLink = self:GetAchievementLink(linkedAchievementId)
                local prerequisiteMet, prerequisiteState, prerequisiteHint = self:GetPrerequisiteState(houseId, collectibleId, unlocked, purchasable, hint, linkedAchievementId, goldInfo.req)
                table.insert(self.houses, {
                    houseId = houseId,
                    collectibleId = collectibleId,
                    name = zo_strformat("<<1>>", name),
                    icon = icon or lockedIcon,
                    image = self:GetHouseImage(collectibleId, houseId, icon or lockedIcon),
                    environment = meta.env or "Non classe",
                    terrainSize = meta.terrain or "Non classe",
                    dwellingSize = meta.dwelling or "Non classe",
                    categoryLabel = self:GetHouseCategoryLabel(houseId),
                    traditionalLimit = self:GetTraditionalFurnitureLimit(houseId),
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

    table.sort(self.houses, function(a, b)
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

    self:ApplyFilter()
end

function GHF:DumpAllHouses()
    if not self.savedVars then return end

    self.savedVars.lastHouseScan = {
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
                self.savedVars.lastHouseScan.houses[houseId] = {
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

function GHF:AddGoldHouseFromSlash(args)
    local houseIdText, goldText = zo_strsplit(" ", args or "")
    local houseId = tonumber(houseIdText)
    local gold = tonumber(goldText)

    if not houseId or not gold then
        Chat("Usage: /ghfadd houseId prixOr  exemple: /ghfadd 44 322000")
        return
    end

    self.savedVars.extraGoldHouseIds[houseId] = {
        gold = gold,
        req = "Ajoute manuellement",
    }
    self:Scan()
    Chat(string.format("Maison houseId %d ajoutee a la liste or avec prix %s.", houseId, FormatGold(gold)))
end

function GHF:ApplyFilter()
    self.filtered = {}
    local query = Normalize(self.searchText)
    local budget = BUDGET_FILTERS[self.budgetFilterIndex or 1] or BUDGET_FILTERS[1]
    local environment = ENVIRONMENT_FILTERS[self.environmentFilterIndex or 1] or ENVIRONMENT_FILTERS[1]
    local terrain = TERRAIN_FILTERS[self.terrainFilterIndex or 1] or TERRAIN_FILTERS[1]
    local dwelling = DWELLING_FILTERS[self.dwellingFilterIndex or 1] or DWELLING_FILTERS[1]

    for _, house in ipairs(self.houses or {}) do
        local haystack = Normalize(house.name .. " " .. FormatGold(house.gold) .. " " .. house.req .. " " .. house.environment .. " " .. house.terrainSize .. " " .. house.dwellingSize .. " " .. house.categoryLabel)
        local matchesSearch = query == "" or haystack:find(query, 1, true)
        local matchesOwnership = not self.showOnlyUnowned or not house.unlocked
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
            table.insert(self.filtered, house)
        end
    end

    self.page = math.max(1, math.min(self.page or 1, self:GetMaxPage()))
    self:RefreshFilterButtons()
    self:RefreshSettingsHouseChoices()
    self:Refresh()
end

function GHF:GetMaxPage()
    local count = #(self.filtered or {})
    return math.max(1, math.ceil(count / ROW_COUNT))
end

function GHF:RequestJump(house, outside)
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

function GHF:SelectHouse(house)
    self.selectedHouse = house
    self:ShowHousePreview(house)
    self.selectedLabel:SetText(house and house.name or "Selectionne une maison")
    self.priceLabel:SetText(house and FormatGold(house.gold) or "")
    self.requirementLabel:SetText(house and ("Prerequis: " .. (house.req ~= "" and house.req or "non renseigne")) or "Choisis une ligne pour voir les actions disponibles.")
    self.previewButton:SetHidden(house == nil)
    self.insideButton:SetHidden(not (house and house.unlocked))
    self.outsideButton:SetHidden(not (house and house.unlocked))
    self.buyHintLabel:SetHidden(not (house and not house.unlocked))
    self:Refresh()
end

function GHF:CreateRow(parent, index)
    local row = WINDOW_MANAGER:CreateControl(nil, parent, CT_BUTTON)
    row:SetDimensions(620, ROW_HEIGHT)
    row:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, (index - 1) * (ROW_HEIGHT + 4))
    row:SetNormalFontColor(0.94, 0.88, 0.74, 1)
    row:SetMouseOverFontColor(1, 1, 1, 1)
    row:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    row:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    row:SetHandler("OnClicked", function(control)
        self:SelectHouse(control.house)
    end)
    row:SetHandler("OnMouseEnter", function(control)
        self:ShowHousePreview(control.house)
    end)
    row:SetHandler("OnMouseExit", function()
        self:ShowHousePreview(self.selectedHouse)
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

function GHF:CreateButton(parent, text, width, callback)
    local button = WINDOW_MANAGER:CreateControlFromVirtual(nil, parent, "ZO_DefaultButton")
    button:SetDimensions(width, 28)
    button:SetText(text)
    button:SetHandler("OnClicked", callback)
    return button
end

function GHF:CreateFilterButton(parent, text, width, callback)
    local button = self:CreateButton(parent, text, width, callback)
    button.defaultText = text
    return button
end

function GHF:RefreshFilterButtons()
    if not self.budgetButtons then return end

    for index, button in ipairs(self.budgetButtons) do
        local filter = BUDGET_FILTERS[index]
        if index == self.budgetFilterIndex then
            button:SetText("[" .. filter.label .. "]")
        else
            button:SetText(filter.label)
        end
    end

    if self.unownedButton then
        self.unownedButton:SetText(self.showOnlyUnowned and "[A acheter]" or "A acheter")
    end
end

function GHF:ShowHousePreview(house)
    if not self.previewPane then return end

    if not house then
        self.previewPane:SetHidden(false)
        self.previewTexture:SetTexture("/esoui/art/icons/housing_gen_inc_unfurnished.dds")
        self.previewName:SetText("Survole une maison")
        self.previewPrice:SetText("")
        self.previewReq:SetText("L'image depend de la texture fournie par le client ESO.")
        self.previewStatus:SetText("")
        return
    end

    self.previewPane:SetHidden(false)
    self.previewTexture:SetTexture(house.image or house.icon or "/esoui/art/icons/housing_gen_inc_unfurnished.dds")
    self.previewName:SetText(house.name)
    self.previewPrice:SetText(FormatGold(house.gold))
    self.previewReq:SetText(self:GetHouseDetailsText(house))
    if house.unlocked then
        self.previewStatus:SetText("Deja possedee")
        self.previewStatus:SetColor(0.44, 0.86, 0.45, 1)
    elseif house.prerequisiteMet == false then
        self.previewStatus:SetText("Prerequis manquant")
        self.previewStatus:SetColor(1, 0.33, 0.28, 1)
    elseif house.prerequisiteMet == true then
        self.previewStatus:SetText("Prerequis OK / a acheter")
        self.previewStatus:SetColor(0.78, 0.86, 0.68, 1)
    elseif self:GetHouseAchievementSearchName(house) ~= "" then
        self.previewStatus:SetText("Succes requis")
        self.previewStatus:SetColor(0.78, 0.86, 0.68, 1)
    else
        self.previewStatus:SetText("Prerequis non resolu")
        self.previewStatus:SetColor(0.78, 0.86, 0.68, 1)
    end
end

function GHF:GetHouseById(houseId)
    if not houseId then return nil end
    for _, house in ipairs(self.houses or {}) do
        if house.houseId == houseId then
            return house
        end
    end
    return nil
end

function GHF:GetSelectedSettingsHouse()
    return self:GetHouseById(self.settingsSelectedHouseId or self.savedVars.selectedHouseId)
end

function GHF:GetSettingsChoiceText(house)
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

    if self:GetHouseAchievementSearchName(house) ~= "" then
        return string.format("%s - %s - %s - succes requis", house.name, FormatGold(house.gold), house.environment)
    end

    return string.format("%s - %s - %s - prerequis non resolu", house.name, FormatGold(house.gold), house.environment)
end

function GHF:GetHouseDetailsText(house)
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

    local achievementSearchName = self:GetHouseAchievementSearchName(house)
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

function GHF:RefreshSettingsPreview()
    local house = self:GetSelectedSettingsHouse()

    if self.settingsPreviewTexture then
        self.settingsPreviewTexture:SetTexture((house and (house.image or house.icon)) or "/esoui/art/icons/housing_gen_inc_unfurnished.dds")
    end
    if self.settingsPreviewName then
        self.settingsPreviewName:SetText(house and house.name or "Aucune maison selectionnee")
        if house and house.prerequisiteMet == false and not house.unlocked then
            self.settingsPreviewName:SetColor(1, 0.33, 0.28, 1)
        else
            self.settingsPreviewName:SetColor(0.98, 0.86, 0.52, 1)
        end
    end
    if self.settingsPreviewPrice then
        self.settingsPreviewPrice:SetText(house and FormatGold(house.gold) or "")
    end
    if self.settingsPreviewStatus then
        if not house then
            self.settingsPreviewStatus:SetText("")
            self.settingsPreviewStatus:SetColor(0.78, 0.86, 0.68, 1)
        elseif house.unlocked then
            self.settingsPreviewStatus:SetText("Deja possedee")
            self.settingsPreviewStatus:SetColor(0.44, 0.86, 0.45, 1)
        elseif house.prerequisiteMet == false then
            self.settingsPreviewStatus:SetText("Prerequis manquant")
            self.settingsPreviewStatus:SetColor(1, 0.33, 0.28, 1)
        elseif house.prerequisiteMet == true then
            self.settingsPreviewStatus:SetText("Prerequis OK / a acheter")
            self.settingsPreviewStatus:SetColor(0.78, 0.86, 0.68, 1)
        elseif self:GetHouseAchievementSearchName(house) ~= "" then
            self.settingsPreviewStatus:SetText("Succes requis")
            self.settingsPreviewStatus:SetColor(0.78, 0.86, 0.68, 1)
        else
            self.settingsPreviewStatus:SetText("Prerequis non resolu")
            self.settingsPreviewStatus:SetColor(0.78, 0.86, 0.68, 1)
        end
    end
    if self.settingsPreviewReq then
        self.settingsPreviewReq:SetText(self:GetHouseDetailsText(house))
        if house and house.prerequisiteMet == false and not house.unlocked then
            self.settingsPreviewReq:SetColor(1, 0.38, 0.32, 1)
        else
            self.settingsPreviewReq:SetColor(0.82, 0.78, 0.68, 1)
        end
    end

    if house and not house.unlocked and not house.linkedAchievementId and self:GetHouseAchievementSearchName(house) ~= "" then
        self:QueueAchievementSearch(house, false, true)
    end
end

function GHF:RefreshSettingsHouseChoices()
    if not self.settingsPanelCreated then return end

    local choices = {}
    local values = {}
    for _, house in ipairs(self.filtered or {}) do
        table.insert(choices, self:GetSettingsChoiceText(house))
        table.insert(values, house.houseId)
    end

    if #choices == 0 then
        choices = { "Aucune maison avec ces filtres" }
        values = { 0 }
        self.settingsSelectedHouseId = nil
        self.savedVars.selectedHouseId = nil
    elseif not self:GetSelectedSettingsHouse() then
        self.settingsSelectedHouseId = values[1]
        self.savedVars.selectedHouseId = values[1]
    end

    local control = _G.GoldHouseFinderHouseDropdown
    if control and control.UpdateChoices then
        control:UpdateChoices(choices, values)
        control:UpdateValue()
    end

    self:RefreshSettingsPreview()
end

function GHF:CreateSettingsPanel()
    local LAM = LibAddonMenu2
    if not LAM then
        Chat("LibAddonMenu-2.0 non detecte: pas de panneau dans Reglages > Extensions, mais l'interface reste disponible.")
        return
    end

    local panelName = "GoldHouseFinderOptions"
    self.settingsPanel = LAM:RegisterAddonPanel(panelName, {
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
                return self.searchText or ""
            end,
            setFunc = function(value)
                self.searchText = value or ""
                self.savedVars.settingsSearchText = self.searchText
                self.page = 1
                self:ApplyFilter()
            end,
            width = "full",
            default = "",
        },
        {
            type = "checkbox",
            name = "Afficher seulement les maisons a acheter",
            tooltip = "Masque les maisons deja possedees.",
            getFunc = function()
                return self.showOnlyUnowned == true
            end,
            setFunc = function(value)
                self.showOnlyUnowned = value
                self.savedVars.showOnlyUnowned = value
                self.page = 1
                self:ApplyFilter()
            end,
            default = DEFAULT_SAVED_VARS.showOnlyUnowned,
        },
        {
            type = "dropdown",
            name = "Budget",
            choices = { "Tous", "< 100k", "100k - 500k", "500k - 1M", "> 1M" },
            getFunc = function()
                local filter = BUDGET_FILTERS[self.budgetFilterIndex or 1] or BUDGET_FILTERS[1]
                return filter.label
            end,
            setFunc = function(value)
                for index, filter in ipairs(BUDGET_FILTERS) do
                    if filter.label == value then
                        self.budgetFilterIndex = index
                        self.savedVars.budgetFilterIndex = index
                        break
                    end
                end
                self.page = 1
                self:ApplyFilter()
            end,
            default = BUDGET_FILTERS[DEFAULT_SAVED_VARS.budgetFilterIndex].label,
        },
        {
            type = "dropdown",
            name = "Emplacement",
            choices = { "Tous", "Ville", "Bord de mer", "Riviere / lac", "Campagne / isole" },
            getFunc = function()
                local filter = ENVIRONMENT_FILTERS[self.environmentFilterIndex or 1] or ENVIRONMENT_FILTERS[1]
                return filter.label
            end,
            setFunc = function(value)
                for index, filter in ipairs(ENVIRONMENT_FILTERS) do
                    if filter.label == value then
                        self.environmentFilterIndex = index
                        self.savedVars.environmentFilterIndex = index
                        break
                    end
                end
                self.page = 1
                self:ApplyFilter()
            end,
            default = ENVIRONMENT_FILTERS[DEFAULT_SAVED_VARS.environmentFilterIndex].label,
            width = "half",
        },
        {
            type = "dropdown",
            name = "Taille terrain",
            choices = { "Tous", "Aucun / interieur", "Petit", "Moyen", "Grand" },
            getFunc = function()
                local filter = TERRAIN_FILTERS[self.terrainFilterIndex or 1] or TERRAIN_FILTERS[1]
                return filter.label
            end,
            setFunc = function(value)
                for index, filter in ipairs(TERRAIN_FILTERS) do
                    if filter.label == value then
                        self.terrainFilterIndex = index
                        self.savedVars.terrainFilterIndex = index
                        break
                    end
                end
                self.page = 1
                self:ApplyFilter()
            end,
            default = TERRAIN_FILTERS[DEFAULT_SAVED_VARS.terrainFilterIndex].label,
            width = "half",
        },
        {
            type = "dropdown",
            name = "Taille habitation",
            choices = { "Tous", "Tres petite", "Petite", "Moyenne", "Grande", "Tres grande" },
            getFunc = function()
                local filter = DWELLING_FILTERS[self.dwellingFilterIndex or 1] or DWELLING_FILTERS[1]
                return filter.label
            end,
            setFunc = function(value)
                for index, filter in ipairs(DWELLING_FILTERS) do
                    if filter.label == value then
                        self.dwellingFilterIndex = index
                        self.savedVars.dwellingFilterIndex = index
                        break
                    end
                end
                self.page = 1
                self:ApplyFilter()
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
                return self.settingsSelectedHouseId or self.savedVars.selectedHouseId or 0
            end,
            setFunc = function(value)
                if value and value ~= 0 then
                    self.settingsSelectedHouseId = value
                    self.savedVars.selectedHouseId = value
                    self:SelectHouse(self:GetHouseById(value))
                end
                self:RefreshSettingsPreview()
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

                self.settingsPreviewTexture = wm:CreateControl(nil, control, CT_TEXTURE)
                self.settingsPreviewTexture:SetDimensions(510, 255)
                self.settingsPreviewTexture:SetAnchor(TOP, control, TOP, 0, 18)
                self.settingsPreviewTexture:SetTextureCoords(0, 0.68359375, 0, 0.68359375)

                self.settingsPreviewName = wm:CreateControl(nil, control, CT_LABEL)
                self.settingsPreviewName:SetFont("ZoFontWinH4")
                self.settingsPreviewName:SetColor(0.98, 0.86, 0.52, 1)
                self.settingsPreviewName:SetAnchor(TOPLEFT, self.settingsPreviewTexture, BOTTOMLEFT, 0, 12)
                self.settingsPreviewName:SetDimensions(510, 34)
                self.settingsPreviewName:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)

                self.settingsPreviewPrice = wm:CreateControl(nil, control, CT_LABEL)
                self.settingsPreviewPrice:SetFont("ZoFontGameBold")
                self.settingsPreviewPrice:SetColor(0.92, 0.74, 0.32, 1)
                self.settingsPreviewPrice:SetAnchor(TOPLEFT, self.settingsPreviewName, BOTTOMLEFT, 0, 4)
                self.settingsPreviewPrice:SetDimensions(510, 24)

                self.settingsPreviewStatus = wm:CreateControl(nil, control, CT_LABEL)
                self.settingsPreviewStatus:SetFont("ZoFontGame")
                self.settingsPreviewStatus:SetColor(0.78, 0.86, 0.68, 1)
                self.settingsPreviewStatus:SetAnchor(TOPLEFT, self.settingsPreviewPrice, BOTTOMLEFT, 0, 4)
                self.settingsPreviewStatus:SetDimensions(510, 24)

                self.settingsPreviewReq = wm:CreateControl(nil, control, CT_LABEL)
                self.settingsPreviewReq:SetFont("ZoFontGameSmall")
                self.settingsPreviewReq:SetColor(0.82, 0.78, 0.68, 1)
                self.settingsPreviewReq:SetAnchor(TOPLEFT, self.settingsPreviewStatus, BOTTOMLEFT, 0, 6)
                self.settingsPreviewReq:SetDimensions(510, 136)
                self.settingsPreviewReq:SetMouseEnabled(true)

                self:RefreshSettingsPreview()
            end,
            refreshFunc = function()
                self:RefreshSettingsPreview()
            end,
        },
        {
            type = "button",
            name = "Apercu / visiter",
            tooltip = "Ouvre l'apercu si la maison n'est pas possedee, ou teleporte dedans si elle l'est.",
            func = function()
                self:RequestJump(self:GetSelectedSettingsHouse(), false)
            end,
            width = "half",
        },
        {
            type = "button",
            name = "TP exterieur",
            tooltip = "Disponible pour les maisons deja possedees.",
            func = function()
                self:RequestJump(self:GetSelectedSettingsHouse(), true)
            end,
            width = "half",
        },
        {
            type = "button",
            name = "Succes requis",
            tooltip = "Cherche puis ouvre le succes requis pour acheter cette maison avec de l'or.",
            func = function()
                self:OpenRequiredAchievement(self:GetSelectedSettingsHouse())
            end,
            disabled = function()
                local house = self:GetSelectedSettingsHouse()
                return not (house and self:GetHouseAchievementSearchName(house) ~= "")
            end,
            width = "full",
        },
        {
            type = "button",
            name = "Scanner les maisons du client",
            tooltip = "Sauvegarde les maisons vues par ton client dans SavedVariables\\GoldHouseFinder.lua.",
            func = function()
                self:DumpAllHouses()
            end,
        },
    })

    self.settingsPanelCreated = true
    self:Scan()
end

function GHF:CreateWindow()
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

    local close = self:CreateButton(root, "X", 34, function() root:SetHidden(true) end)
    close:SetAnchor(TOPRIGHT, root, TOPRIGHT, -12, 12)

    local search = wm:CreateControlFromVirtual("GoldHouseFinderSearch", root, "ZO_DefaultEdit")
    search:SetDimensions(360, 30)
    search:SetAnchor(TOPLEFT, root, TOPLEFT, 18, 72)
    search:SetText("")
    search:SetHandler("OnTextChanged", function(control)
        self.searchText = control:GetText()
        self.page = 1
        self:ApplyFilter()
    end)
    self.search = search

    local refresh = self:CreateButton(root, "Actualiser", 105, function() self:Scan() end)
    refresh:SetAnchor(LEFT, search, RIGHT, 12, 0)

    local reset = self:CreateButton(root, "Effacer", 80, function()
        self.search:SetText("")
        self.searchText = ""
        self.page = 1
        self:ApplyFilter()
    end)
    reset:SetAnchor(LEFT, refresh, RIGHT, 8, 0)

    self.budgetButtons = {}
    local previousBudgetButton = nil
    for index, filter in ipairs(BUDGET_FILTERS) do
        local button = self:CreateFilterButton(root, filter.label, index == 1 and 58 or 68, function()
            self.budgetFilterIndex = index
            self.savedVars.budgetFilterIndex = index
            self.page = 1
            self:ApplyFilter()
        end)
        if previousBudgetButton then
            button:SetAnchor(LEFT, previousBudgetButton, RIGHT, 6, 0)
        else
            button:SetAnchor(TOPLEFT, root, TOPLEFT, 18, 112)
        end
        self.budgetButtons[index] = button
        previousBudgetButton = button
    end

    self.unownedButton = self:CreateFilterButton(root, "A acheter", 96, function()
        self.showOnlyUnowned = not self.showOnlyUnowned
        self.savedVars.showOnlyUnowned = self.showOnlyUnowned
        self.page = 1
        self:ApplyFilter()
    end)
    self.unownedButton:SetAnchor(LEFT, previousBudgetButton, RIGHT, 14, 0)

    self.countLabel = wm:CreateControl(nil, root, CT_LABEL)
    self.countLabel:SetFont("ZoFontGameSmall")
    self.countLabel:SetColor(0.82, 0.78, 0.68, 1)
    self.countLabel:SetAnchor(TOPLEFT, root, TOPLEFT, 18, 148)
    self.countLabel:SetDimensions(620, 22)

    local list = wm:CreateControl(nil, root, CT_CONTROL)
    list:SetDimensions(620, 392)
    list:SetAnchor(TOPLEFT, root, TOPLEFT, 18, 174)
    self.rows = {}
    for i = 1, ROW_COUNT do
        self.rows[i] = self:CreateRow(list, i)
    end

    self.prevButton = self:CreateButton(root, "<", 40, function()
        self.page = math.max(1, (self.page or 1) - 1)
        self:Refresh()
    end)
    self.prevButton:SetAnchor(BOTTOMLEFT, root, BOTTOMLEFT, 18, -18)

    self.pageLabel = wm:CreateControl(nil, root, CT_LABEL)
    self.pageLabel:SetFont("ZoFontGame")
    self.pageLabel:SetAnchor(LEFT, self.prevButton, RIGHT, 8, 0)
    self.pageLabel:SetDimensions(115, 28)
    self.pageLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    self.nextButton = self:CreateButton(root, ">", 40, function()
        self.page = math.min(self:GetMaxPage(), (self.page or 1) + 1)
        self:Refresh()
    end)
    self.nextButton:SetAnchor(LEFT, self.pageLabel, RIGHT, 4, 0)

    self.previewPane = wm:CreateControl(nil, root, CT_CONTROL)
    self.previewPane:SetDimensions(285, 390)
    self.previewPane:SetAnchor(TOPLEFT, list, TOPRIGHT, 18, 0)

    self.previewPaneBg = wm:CreateControlFromVirtual(nil, self.previewPane, "ZO_DefaultBackdrop")
    self.previewPaneBg:SetAnchorFill(self.previewPane)
    self.previewPaneBg:SetCenterColor(0.055, 0.048, 0.038, 0.92)
    self.previewPaneBg:SetEdgeColor(0.50, 0.37, 0.18, 0.8)

    self.previewTexture = wm:CreateControl(nil, self.previewPane, CT_TEXTURE)
    self.previewTexture:SetDimensions(248, 124)
    self.previewTexture:SetAnchor(TOP, self.previewPane, TOP, 0, 18)
    self.previewTexture:SetTexture("/esoui/art/icons/housing_gen_inc_unfurnished.dds")
    self.previewTexture:SetTextureCoords(0, 0.68359375, 0, 0.68359375)

    self.previewName = wm:CreateControl(nil, self.previewPane, CT_LABEL)
    self.previewName:SetFont("ZoFontWinH4")
    self.previewName:SetColor(0.98, 0.86, 0.52, 1)
    self.previewName:SetAnchor(TOPLEFT, self.previewTexture, BOTTOMLEFT, 0, 14)
    self.previewName:SetDimensions(248, 48)
    self.previewName:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    self.previewName:SetText("Survole une maison")

    self.previewPrice = wm:CreateControl(nil, self.previewPane, CT_LABEL)
    self.previewPrice:SetFont("ZoFontGameBold")
    self.previewPrice:SetColor(0.92, 0.74, 0.32, 1)
    self.previewPrice:SetAnchor(TOPLEFT, self.previewName, BOTTOMLEFT, 0, 6)
    self.previewPrice:SetDimensions(248, 24)

    self.previewStatus = wm:CreateControl(nil, self.previewPane, CT_LABEL)
    self.previewStatus:SetFont("ZoFontGame")
    self.previewStatus:SetColor(0.78, 0.86, 0.68, 1)
    self.previewStatus:SetAnchor(TOPLEFT, self.previewPrice, BOTTOMLEFT, 0, 4)
    self.previewStatus:SetDimensions(248, 24)

    self.previewReq = wm:CreateControl(nil, self.previewPane, CT_LABEL)
    self.previewReq:SetFont("ZoFontGameSmall")
    self.previewReq:SetColor(0.82, 0.78, 0.68, 1)
    self.previewReq:SetAnchor(TOPLEFT, self.previewStatus, BOTTOMLEFT, 0, 8)
    self.previewReq:SetDimensions(248, 70)
    self.previewReq:SetText("L'image depend de la texture fournie par le client ESO.")

    self.selectedLabel = wm:CreateControl(nil, root, CT_LABEL)
    self.selectedLabel:SetFont("ZoFontGameBold")
    self.selectedLabel:SetColor(0.98, 0.88, 0.58, 1)
    self.selectedLabel:SetAnchor(BOTTOMLEFT, root, BOTTOMLEFT, 230, -70)
    self.selectedLabel:SetDimensions(330, 24)
    self.selectedLabel:SetText("Selectionne une maison")

    self.priceLabel = wm:CreateControl(nil, root, CT_LABEL)
    self.priceLabel:SetFont("ZoFontGameBold")
    self.priceLabel:SetColor(0.92, 0.74, 0.32, 1)
    self.priceLabel:SetAnchor(LEFT, self.selectedLabel, RIGHT, 10, 0)
    self.priceLabel:SetDimensions(150, 24)
    self.priceLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)

    self.requirementLabel = wm:CreateControl(nil, root, CT_LABEL)
    self.requirementLabel:SetFont("ZoFontGameSmall")
    self.requirementLabel:SetColor(0.84, 0.80, 0.70, 1)
    self.requirementLabel:SetAnchor(TOPLEFT, self.selectedLabel, BOTTOMLEFT, 0, 0)
    self.requirementLabel:SetDimensions(440, 20)
    self.requirementLabel:SetText("Choisis une ligne pour voir les actions disponibles.")

    self.previewButton = self:CreateButton(root, "Apercu / TP", 105, function()
        self:RequestJump(self.selectedHouse, false)
    end)
    self.previewButton:SetAnchor(BOTTOMRIGHT, root, BOTTOMRIGHT, -18, -68)

    self.insideButton = self:CreateButton(root, "Interieur", 92, function()
        self:RequestJump(self.selectedHouse, false)
    end)
    self.insideButton:SetAnchor(RIGHT, self.previewButton, LEFT, -8, 0)

    self.outsideButton = self:CreateButton(root, "Exterieur", 92, function()
        self:RequestJump(self.selectedHouse, true)
    end)
    self.outsideButton:SetAnchor(RIGHT, self.insideButton, LEFT, -8, 0)

    self.buyHintLabel = wm:CreateControl(nil, root, CT_LABEL)
    self.buyHintLabel:SetFont("ZoFontGameSmall")
    self.buyHintLabel:SetColor(0.95, 0.78, 0.45, 1)
    self.buyHintLabel:SetText("Maison non possedee: le bouton ouvre l'apercu, l'achat se fait dans l'interface du jeu.")
    self.buyHintLabel:SetAnchor(BOTTOMRIGHT, root, BOTTOMRIGHT, -18, -22)
    self.buyHintLabel:SetDimensions(460, 20)
    self.buyHintLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)

    self.window = root
    self:SelectHouse(nil)
    self:CreateSettingsPanel()
    self:ShowHousePreview(nil)
end

function GHF:Refresh()
    if not self.window then return end

    local list = self.filtered or {}
    local maxPage = self:GetMaxPage()
    self.page = math.max(1, math.min(self.page or 1, maxPage))
    local offset = (self.page - 1) * ROW_COUNT

    self.countLabel:SetText(string.format("%d maison(s) trouvee(s). Recherche par nom, prix ou prerequis.", #list))
    self.pageLabel:SetText(string.format("Page %d / %d", self.page, maxPage))
    self.prevButton:SetEnabled(self.page > 1)
    self.nextButton:SetEnabled(self.page < maxPage)

    for i, row in ipairs(self.rows) do
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
            elseif self:GetHouseAchievementSearchName(house) ~= "" then
                owned = "|cD8B35Asucces requis|r"
            else
                owned = "|cD8B35Aprerequis non resolu|r"
            end
            row.icon:SetTexture(house.icon or "/esoui/art/icons/icon_missing.dds")
            row.text:SetText(string.format("%s  (%s)", house.name, owned))
            row.price:SetText(FormatGold(house.gold))
            if self.selectedHouse and self.selectedHouse.houseId == house.houseId then
                row.bg:SetCenterColor(0.20, 0.14, 0.07, 0.95)
                row.bg:SetEdgeColor(0.95, 0.70, 0.30, 1)
            else
                row.bg:SetCenterColor(0.08, 0.075, 0.06, 0.82)
                row.bg:SetEdgeColor(0.45, 0.34, 0.18, 0.55)
            end
        end
    end
end

function GHF:Toggle()
    if self.settingsPanel and LibAddonMenu2 and LibAddonMenu2.OpenToPanel then
        self:Scan()
        LibAddonMenu2:OpenToPanel(self.settingsPanel)
        return
    end

    if not self.window then return end
    if self.window:IsHidden() then
        self:Scan()
        self.window:SetHidden(false)
    else
        self.window:SetHidden(true)
    end
end

function GHF:Initialize()
    self.savedVars = ZO_SavedVars:NewAccountWide("GoldHouseFinderVars", 1, nil, DEFAULT_SAVED_VARS)
    self.savedVars.prerequisiteByHouseId = self.savedVars.prerequisiteByHouseId or {}
    self.savedVars.prerequisiteByCharacterId = self.savedVars.prerequisiteByCharacterId or {}
    self.page = 1
    self.searchText = self.savedVars.settingsSearchText or ""
    self.budgetFilterIndex = self.savedVars.budgetFilterIndex or 1
    if not BUDGET_FILTERS[self.budgetFilterIndex] then
        self.budgetFilterIndex = 1
        self.savedVars.budgetFilterIndex = 1
    end
    self.environmentFilterIndex = self.savedVars.environmentFilterIndex or 1
    if not ENVIRONMENT_FILTERS[self.environmentFilterIndex] then
        self.environmentFilterIndex = 1
        self.savedVars.environmentFilterIndex = 1
    end
    self.terrainFilterIndex = self.savedVars.terrainFilterIndex or 1
    if not TERRAIN_FILTERS[self.terrainFilterIndex] then
        self.terrainFilterIndex = 1
        self.savedVars.terrainFilterIndex = 1
    end
    self.dwellingFilterIndex = self.savedVars.dwellingFilterIndex or 1
    if not DWELLING_FILTERS[self.dwellingFilterIndex] then
        self.dwellingFilterIndex = 1
        self.savedVars.dwellingFilterIndex = 1
    end
    self.showOnlyUnowned = self.savedVars.showOnlyUnowned ~= false
    self.settingsSelectedHouseId = self.savedVars.selectedHouseId
    self.houses = {}
    self.filtered = {}
    self:CreateWindow()

    ZO_CreateStringId("SI_BINDING_NAME_GOLD_HOUSE_FINDER_TOGGLE", "Open Gold House Finder")

    SLASH_COMMANDS["/ghf"] = function() self:Toggle() end
    SLASH_COMMANDS["/goldhouses"] = function() self:Toggle() end
    SLASH_COMMANDS["/maisonsor"] = function() self:Toggle() end
    SLASH_COMMANDS["/ghfdump"] = function() self:DumpAllHouses() end
    SLASH_COMMANDS["/ghfadd"] = function(args) self:AddGoldHouseFromSlash(args) end

    if EVENT_OPEN_HOUSE_STORE then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_OPEN_HOUSE_STORE, function()
            self:RefreshCurrentHousePurchaseRequirement()
            if zo_callLater then
                zo_callLater(function() self:RefreshCurrentHousePurchaseRequirement() end, 250)
                zo_callLater(function() self:RefreshCurrentHousePurchaseRequirement() end, 750)
            end
        end)
    end

    if EVENT_ACHIEVEMENTS_SEARCH_RESULTS_READY then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "AchievementSearch", EVENT_ACHIEVEMENTS_SEARCH_RESULTS_READY, function()
            self:OnAchievementSearchResultsReady()
        end)
    end

    Chat("charge. Ouvre Reglages > Extensions > Gold House Finder, ou /ghf.")
end

local function OnAddonLoaded(eventCode, addonName)
    if addonName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    GHF:Initialize()
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)
