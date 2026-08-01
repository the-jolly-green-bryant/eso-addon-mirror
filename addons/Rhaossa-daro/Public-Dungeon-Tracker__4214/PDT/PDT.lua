local ADDON_NAME = "PDT"
local ADDON_FULL_NAME = "Public Dungeon Tracker"
local ADDON_AUTHOR = "Rhaossa-daro"
local ADDON_VERSION = "1.0.1"

if not LibMultiAccountAchievements then return end
if not LibAddonMenu2 then return end

local LMAA = LibMultiAccountAchievements
local LAM = LibAddonMenu2

local PUBLIC_DUNGEONS = {
    ["Aldmeri Dominion"] = {
        { name = "Toothmaul Gully", achievement = 468, zone = "Auridon" },
        { name = "Root Sunder Ruins", achievement = 470, zone = "Grahtwood" },
        { name = "Rulanyil's Fall", achievement = 445, zone = "Greenshade" },
        { name = "Tempest Island Public", achievement = 460, zone = "Malabal Tor" },
        { name = "Jode's Light", achievement = 469, zone = "Reaper's March" },
    },
    ["Daggerfall Covenant"] = {
        { name = "Bad Man's Hallows", achievement = 380, zone = "Glenumbra" },
        { name = "Bonesnap Ruins", achievement = 714, zone = "Stormhaven" },
        { name = "Obsidian Scar", achievement = 713, zone = "Rivenspire" },
        { name = "Lost City of the Na-Totambu", achievement = 707, zone = "Alik'r Desert" },
        { name = "Razak's Wheel", achievement = 708, zone = "Bangkorai" },
    },
    ["Ebonheart Pact"] = {
        { name = "Crow's Wood", achievement = 379, zone = "Stonefalls" },
        { name = "Forgotten Crypts", achievement = 388, zone = "Deshaan" },
        { name = "Sanguine's Demesne", achievement = 372, zone = "Shadowfen" },
        { name = "Hall of the Dead", achievement = 381, zone = "Eastmarch" },
        { name = "Nimalten", achievement = 371, zone = "The Rift" },
    },
    ["Coldharbour"] = {
        { name = "Village of the Lost", achievement = 874, zone = "Coldharbour" },
    },
    ["DLC Zones"] = {
        { name = "Forgotten Wastes", achievement = 1855, zone = "Vvardenfell" },
        { name = "Nchuleftingth", achievement = 1846, zone = "Vvardenfell" },
        { name = "Old Orsinium", achievement = 1238, zone = "Wrothgar" },
        { name = "Rkindaleft", achievement = 1235, zone = "Wrothgar" },
        { name = "Karnwasten", achievement = 2096, zone = "Summerset" },
        { name = "Sunhold", achievement = 2095, zone = "Summerset" },
        { name = "Rimmen Necropolis", achievement = 2444, zone = "Northern Elsweyr" },
        { name = "Orcrest", achievement = 2445, zone = "Northern Elsweyr" },
        { name = "Labyrinthian", achievement = 2714, zone = "Western Skyrim" },
        { name = "Nchuthnkarst", achievement = 2715, zone = "The Reach" },
        { name = "Silent Halls", achievement = 2994, zone = "Blackwood" },
        { name = "Zenithar's Abbey", achievement = 2995, zone = "Blackwood" },
        { name = "Ghost Haven Bay", achievement = 3281, zone = "High Isle" },
        { name = "Spire of the Crimson Coin", achievement = 3283, zone = "High Isle" },
        { name = "Gorne", achievement = 3658, zone = "Telvanni Peninsula" },
        { name = "Telvanni Underground", achievement = 3657, zone = "Apocrypha" },
        { name = "Leftwheal Trading Post", achievement = 4000, zone = "West Weald" },
        { name = "Silorn", achievement = 4002, zone = "West Weald" },
        { name = "Deetra Grotto", achievement = 4264, zone = "Western Solstice" },
    },
}

local CATEGORY_ORDER = {
    "Aldmeri Dominion",
    "Daggerfall Covenant", 
    "Ebonheart Pact",
    "Coldharbour",
    "DLC Zones"
}

local COLOR_COMPLETE = "|c00FF00"
local COLOR_INCOMPLETE = "|cFF0000" 
local COLOR_ZONE = "|c888888"
local COLOR_SUMMARY_COMPLETE = "|c00FF00"
local COLOR_SUMMARY_PARTIAL = "|cFFFF00"
local COLOR_RESET = "|r"

local RefreshDungeonList

local function GetCompletionStats()
    local completedCount = 0
    local totalCount = 0
    
    for _, dungeons in pairs(PUBLIC_DUNGEONS) do
        for _, dungeon in ipairs(dungeons) do
            totalCount = totalCount + 1
            local success, isComplete = pcall(LMAA.IsAchievementComplete, nil, dungeon.achievement)
            if success and isComplete then
                completedCount = completedCount + 1
            end
        end
    end
    
    return completedCount, totalCount
end

local function GetCompletionSummary()
    local completedCount, totalCount = GetCompletionStats()
    local summaryColor = (completedCount == totalCount) and COLOR_SUMMARY_COMPLETE or COLOR_SUMMARY_PARTIAL
    
    return string.format("%s%d/%d%s", 
                        summaryColor, completedCount, totalCount, COLOR_RESET)
end

local function IsDungeonComplete(achievementId)
    local success, isComplete = pcall(LMAA.IsAchievementComplete, nil, achievementId)
    return success and isComplete or false
end

local function GenerateOptionsTable()
    local options = {
        {
            type = "description",
            title = "Skillpoints Earned",
            text = "",
            width = "half",
        },
        {
            type = "description",
            title = "",
            text = function() return GetCompletionSummary() end,
            width = "half",
        },
    }
    
    for _, categoryName in ipairs(CATEGORY_ORDER) do
        local dungeons = PUBLIC_DUNGEONS[categoryName]
        if dungeons and #dungeons > 0 then
            table.insert(options, {
                type = "header",
                name = categoryName,
                width = "full",
            })
            
            for _, dungeon in ipairs(dungeons) do
                local isComplete = IsDungeonComplete(dungeon.achievement)
                local nameColor = isComplete and COLOR_COMPLETE or COLOR_INCOMPLETE
                
                table.insert(options, {
                    type = "description",
                    title = "",
                    text = nameColor .. dungeon.name .. COLOR_RESET,
                    width = "half",
                })
                
                table.insert(options, {
                    type = "description", 
                    title = "",
                    text = COLOR_ZONE .. dungeon.zone .. COLOR_RESET,
                    width = "half",
                })
            end
        end
    end
    
    table.insert(options, {
        type = "divider",
        width = "full",
    })
    
    table.insert(options, {
        type = "button",
        name = "Refresh",
        func = RefreshDungeonList,
        width = "full",
    })
    
    return options
end

RefreshDungeonList = function()
    LAM:RegisterOptionControls(ADDON_NAME, GenerateOptionsTable())
end

local function OnAddOnLoaded(eventCode, addonName)
    if addonName ~= ADDON_NAME then return end
    
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    
    local panelData = {
        type = "panel",
        name = ADDON_FULL_NAME,
        displayName = ADDON_FULL_NAME,
        author = ADDON_AUTHOR,
        version = ADDON_VERSION,
        registerForRefresh = true,
    }
    
    LAM:RegisterAddonPanel(ADDON_NAME, panelData)
    LAM:RegisterOptionControls(ADDON_NAME, GenerateOptionsTable())
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)