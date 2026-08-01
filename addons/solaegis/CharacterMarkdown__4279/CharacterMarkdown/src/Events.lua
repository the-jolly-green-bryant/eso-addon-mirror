-- CharacterMarkdown - Event System

local CM = CharacterMarkdown

local function OnAddOnLoaded(event, addonName)
    if addonName ~= CM.name then
        return
    end

    -- Update version from manifest now that addon is loaded
    CM.UpdateVersion()

    CM.Info("v" .. CM.version .. " Loading...")
    EVENT_MANAGER:UnregisterForEvent(CM.name, EVENT_ADD_ON_LOADED)

    if not CM.ValidateModules() then
        CM.Error("Module validation failed! Addon may not work correctly.")
        return
    end

    -- Initialize SavedVariables in ADD_ON_LOADED
    -- Per ESO best practices, SavedVariables MUST be initialized during ADD_ON_LOADED
    if CM.Settings and CM.Settings.Initializer then
        -- Use full Initialize() method which handles all initialization including format sync
        local success = CM.Settings.Initializer:Initialize()
        if not success then
            CM.Error("Settings initialization failed!")
        end
    else
        CM.Error("Settings.Initializer not available!")
    end
end

local function OnPlayerActivated(event, initial)
    if not CM.isInitialized then
        local panelReady = false
        if CM.Settings and CM.Settings.Panel then
            CM.Settings.Panel:Initialize()
            panelReady = true
        end

        if panelReady then
            CM.isInitialized = true
            CM.Success("Ready! Use /markdown to generate character profile")
        else
            CM.Error("Settings panel failed to initialize!")
        end

        EVENT_MANAGER:UnregisterForEvent(CM.name, EVENT_PLAYER_ACTIVATED)
    end
end

-- =====================================================
-- CACHE INVALIDATION HANDLERS
-- =====================================================

-- Throttling mechanism to prevent rapid successive cache clears
local pendingCacheClear = {}
local CACHE_CLEAR_DELAY_MS = 500

local function ThrottledCacheClear(cacheKey, clearFunc, debugMessage)
    if pendingCacheClear[cacheKey] then
        return
    end
    pendingCacheClear[cacheKey] = true

    zo_callLater(function()
        if clearFunc then
            clearFunc()
            CM.DebugPrint("CACHE", debugMessage)
        end
        pendingCacheClear[cacheKey] = nil
    end, CACHE_CLEAR_DELAY_MS)
end

local function OnCollectibleUpdated(event, collectibleId)
    if CM.api and CM.api.collectibles and CM.api.collectibles.ClearCache then
        ThrottledCacheClear(
            "collectibles",
            CM.api.collectibles.ClearCache,
            "Collectibles cache cleared (collectible updated: " .. tostring(collectibleId) .. ")"
        )
    end
end

local function OnSkillRankUpdate(event, skillType, skillLineIndex, rank)
    -- Clear skills cache when a skill rank changes (throttled)
    if CM.api and CM.api.skills and CM.api.skills.ClearCache then
        ThrottledCacheClear("skills", CM.api.skills.ClearCache, "Skills cache cleared (skill rank updated)")
    end
end

local function OnSkillPointsChanged(event)
    -- Clear skills cache when skill points change (throttled)
    if CM.api and CM.api.skills and CM.api.skills.ClearCache then
        ThrottledCacheClear("skills", CM.api.skills.ClearCache, "Skills cache cleared (skill points changed)")
    end
end

local function OnPlayerTitlesUpdate(event)
    if CM.api and CM.api.titles and CM.api.titles.ClearCache then
        ThrottledCacheClear("titles", CM.api.titles.ClearCache, "Titles cache cleared (player titles updated)")
    end
end

local function OnAntiquityUpdated(event, antiquityId)
    -- Clear antiquities cache when an antiquity is unlocked (throttled)
    if CM.api and CM.api.antiquities and CM.api.antiquities.ClearCache then
        ThrottledCacheClear(
            "antiquities",
            CM.api.antiquities.ClearCache,
            "Antiquities cache cleared (antiquity updated: " .. tostring(antiquityId) .. ")"
        )
    end
end

local function RegisterEventIfExists(eventId, handler)
    if eventId then
        EVENT_MANAGER:RegisterForEvent(CM.name, eventId, handler)
    end
end

local function RegisterEvents()
    EVENT_MANAGER:RegisterForEvent(CM.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
    EVENT_MANAGER:RegisterForEvent(CM.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

    RegisterEventIfExists(EVENT_COLLECTIBLE_UPDATED, OnCollectibleUpdated)
    RegisterEventIfExists(EVENT_SKILL_RANK_UPDATE, OnSkillRankUpdate)
    RegisterEventIfExists(EVENT_SKILL_POINTS_CHANGED, OnSkillPointsChanged)
    RegisterEventIfExists(EVENT_PLAYER_TITLES_UPDATE, OnPlayerTitlesUpdate)
    RegisterEventIfExists(EVENT_ANTIQUITY_UPDATED, OnAntiquityUpdated)
end

CM.events.OnAddOnLoaded = OnAddOnLoaded
CM.events.OnPlayerActivated = OnPlayerActivated
CM.events.RegisterEvents = RegisterEvents

-- Export cache invalidation handlers for manual clearing if needed
CM.events.OnCollectibleUpdated = OnCollectibleUpdated
CM.events.OnSkillRankUpdate = OnSkillRankUpdate
CM.events.OnSkillPointsChanged = OnSkillPointsChanged
CM.events.OnPlayerTitlesUpdate = OnPlayerTitlesUpdate
CM.events.OnAntiquityUpdated = OnAntiquityUpdated

-- Register event handlers
RegisterEvents()
