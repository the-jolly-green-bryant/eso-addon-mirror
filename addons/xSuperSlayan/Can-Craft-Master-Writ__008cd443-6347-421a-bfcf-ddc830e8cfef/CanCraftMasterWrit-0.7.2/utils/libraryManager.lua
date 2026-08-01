-- Library Integration Module
-- Handles loading and interfacing with LibCharacterKnowledge and LibLazyCrafting

local LibraryManager = {}

-- Library references
local LibCharacterKnowledge = nil
local LCK = nil
local LibLazyCrafting = nil
local LLC = nil

-- Library loading status
local librariesLoaded = false
local initializationAttempted = false
local callbackRegistered = false

-- Callback function for when LibCharacterKnowledge is ready
local function OnLibCharacterKnowledgeInitialized()
    LibCharacterKnowledge = _G.LibCharacterKnowledge
    LCK = LibCharacterKnowledge
    
    -- Also initialize LibLazyCrafting if available
    LibLazyCrafting = _G.LibLazyCrafting
    LLC = LibLazyCrafting
    
    if LibCharacterKnowledge then
        librariesLoaded = true
        if _G.DebugLog then
            _G.DebugLog("LibCharacterKnowledge initialization complete - ready for use")
            if LibLazyCrafting then
                _G.DebugLog("LibLazyCrafting also available for provisioning support")
            else
                _G.DebugLog("LibLazyCrafting not available - limited provisioning support")
            end
        end
        
        -- Setup tooltips now that library is ready
        if _G.SetupMasterWritTooltips then
            _G.SetupMasterWritTooltips()
        end
    end
end

-- Initialize libraries using proper LibCharacterKnowledge pattern
function LibraryManager.Initialize()
    if initializationAttempted then
        return librariesLoaded, librariesLoaded and "Already initialized" or "Previous initialization failed"
    end
    
    initializationAttempted = true
    
    -- Check if LibCharacterKnowledge is available
    LibCharacterKnowledge = _G.LibCharacterKnowledge
    
    if LibCharacterKnowledge then
        LCK = LibCharacterKnowledge
        
        -- Register for initialization callback (must be done before LCK finishes initializing)
        if not callbackRegistered and LibCharacterKnowledge.RegisterForCallback and LibCharacterKnowledge.EVENT_INITIALIZED then
            LibCharacterKnowledge.RegisterForCallback("CanCraftMasterWrit", LibCharacterKnowledge.EVENT_INITIALIZED, OnLibCharacterKnowledgeInitialized)
            callbackRegistered = true
            return false, "LibCharacterKnowledge found - waiting for EVENT_INITIALIZED callback"
        else
            -- Library already initialized or callback already registered
            OnLibCharacterKnowledgeInitialized()
            return librariesLoaded, "LibCharacterKnowledge ready immediately"
        end
    else
        return false, "LibCharacterKnowledge not available - library not loaded"
    end
end

-- Check if libraries are available
function LibraryManager.AreLibrariesLoaded()
    return librariesLoaded
end

function LibraryManager.IsLibCharacterKnowledgeLoaded()
    return LibCharacterKnowledge ~= nil
end

-- NEW: Check if LibLazyCrafting is available
function LibraryManager.IsLibLazyCraftingLoaded()
    return LibLazyCrafting ~= nil
end

-- Get player's motif knowledge for a specific style and chapter
function LibraryManager.GetPlayerMotifKnowledge(styleId, chapterId)
    if not LibCharacterKnowledge then
        return nil, "LibCharacterKnowledge not available"
    end
    
    local LCK = LibCharacterKnowledge
    
    local success, result = pcall(LCK.GetMotifKnowledgeForCharacter, styleId, chapterId)
    if success then
        return result, "Success"
    else
        return nil, "API Error: " .. tostring(result)
    end
end

-- Convert style name to style ID using ESO API
function LibraryManager.GetStyleIdFromName(styleName)
    if not LibCharacterKnowledge then
        return nil, "LibCharacterKnowledge not available"
    end
    
    local LCK = LibCharacterKnowledge
    
    -- Get all motif styles and search for matching name
    local success, styleIds = pcall(LCK.GetMotifStyles)
    if success and styleIds then
        for _, styleId in ipairs(styleIds) do
            local styleName_api = GetItemStyleName(styleId)
            if styleName_api and string.lower(styleName_api) == string.lower(styleName) then
                return styleId, styleName_api
            end
        end
        return nil, "Style not found"
    else
        return nil, "Failed to get motif styles"
    end
end

-- Enhanced motif page checking using LibCharacterKnowledge
function LibraryManager.IsMotifPageKnown(styleName, itemType, characterId)
    if not LibCharacterKnowledge then
        return nil -- Return nil to indicate library not available
    end
    
    local LCK = LibCharacterKnowledge
    
    -- Convert style name to style ID
    local styleId, actualStyleName = LibraryManager.GetStyleIdFromName(styleName)
    if not styleId then
        return nil -- Style not found
    end
    
    -- Convert item type to chapter ID
    local chapterId = LibraryManager.GetChapterIdFromItemType(itemType)
    
    -- Get motif knowledge
    local knowledge, message = LibraryManager.GetPlayerMotifKnowledge(styleId, chapterId)
    if knowledge then
        return knowledge == LCK.KNOWLEDGE_KNOWN, message
    else
        return nil, message
    end
end

-- Convert item type to chapter constant
function LibraryManager.GetChapterIdFromItemType(itemType)
    if not itemType then return nil end
    
    local itemTypeLower = string.lower(itemType)
    
    local chapterMap = {
        ["axes"] = ITEM_STYLE_CHAPTER_AXES,
        ["belts"] = ITEM_STYLE_CHAPTER_BELTS,
        ["boots"] = ITEM_STYLE_CHAPTER_BOOTS,
        ["bows"] = ITEM_STYLE_CHAPTER_BOWS,
        ["chests"] = ITEM_STYLE_CHAPTER_CHESTS,
        ["daggers"] = ITEM_STYLE_CHAPTER_DAGGERS,
        ["gloves"] = ITEM_STYLE_CHAPTER_GLOVES,
        ["helmets"] = ITEM_STYLE_CHAPTER_HELMETS,
        ["legs"] = ITEM_STYLE_CHAPTER_LEGS,
        ["maces"] = ITEM_STYLE_CHAPTER_MACES,
        ["shields"] = ITEM_STYLE_CHAPTER_SHIELDS,
        ["shoulders"] = ITEM_STYLE_CHAPTER_SHOULDERS,
        ["staves"] = ITEM_STYLE_CHAPTER_STAVES,
        ["swords"] = ITEM_STYLE_CHAPTER_SWORDS
    }
    
    return chapterMap[itemTypeLower]
end

-- Get library status information
function LibraryManager.GetLibraryStatus()
    local status = {
        libCharacterKnowledge = LibCharacterKnowledge ~= nil,
        libLazyCrafting = LibLazyCrafting ~= nil,
        initialized = librariesLoaded
    }
    
    return status
end

-- NEW: LibLazyCrafting integration functions
function LibraryManager.CanCraftProvisioningRecipe(recipeName)
    if not LibLazyCrafting then
        return nil, "LibLazyCrafting not available"
    end
    
    local LLC = LibLazyCrafting
    
    -- Try various LLC functions to determine recipe craftability
    local success, result = pcall(function()
        if LLC.CanCraftItemByName then
            return LLC.CanCraftItemByName(recipeName)
        elseif LLC.GetRecipeKnowledge then
            return LLC.GetRecipeKnowledge(recipeName)
        else
            return nil
        end
    end)
    
    if success then
        return result, "Success"
    else
        return nil, "LibLazyCrafting error: " .. tostring(result)
    end
end

-- Export globally
_G.LibraryManager = LibraryManager

return LibraryManager
