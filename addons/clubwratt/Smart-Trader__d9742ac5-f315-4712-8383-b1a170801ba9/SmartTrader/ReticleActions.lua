-- ReticleActions.lua: Imperative actions for reticle handling
-- These functions have side effects (mutate reticleState, hook UI)

---@class ZO_ReticleContainerInteractContextClass
---@field SetText fun(self: ZO_ReticleContainerInteractContextClass, text: string)

---@type ZO_ReticleContainerInteractContextClass
ZO_ReticleContainerInteractContext = ZO_ReticleContainerInteractContext

local ReticleActions = {}

-- Statistics
local setTextCallCount = 0
local cacheHitCount = 0
local cacheMissCount = 0
local cacheFetchCount = 0
---Initialize reticle text hooking
local function InitializeReticleHook()
    local ReticleUtils = SmartTrader.ReticleUtils
    local GuildUtils = SmartTrader.GuildUtils
    local GuildActions = SmartTrader.GuildActions
    local originalSetText = ZO_ReticleContainerInteractContext.SetText

    ZO_ReticleContainerInteractContext.SetText = function(self, text)
        setTextCallCount = setTextCallCount + 1

        -- Keep the raw incoming text for dedupe; formatted text will differ
        local incomingText = text

        local reticleState = SmartTrader.state.reticleState

        -- Check if we just processed this exact text - prevents spam from rapid SetText calls
        if incomingText == reticleState.lastCheckedTraderName then
            -- Reapply the last formatted version to avoid dropping color/size on repeat calls
            if reticleState.lastFormattedText then
                text = reticleState.lastFormattedText
            end
            originalSetText(self, text)
            return
        end

        -- First, check if this text matches a cached trader name (handles side glances).
        -- This check happens regardless of unit tags - if we've seen this trader before, format it.
        local guildDataByTraderName = SmartTrader.state.savedVars.guildDataByTraderName
        local data = guildDataByTraderName[incomingText]
        if data then
            cacheHitCount = cacheHitCount + 1
            local formattedText = GuildUtils.FormatGuildDisplayText(data, nil)
            if formattedText then
                text = formattedText
            end
            reticleState.lastCheckedTraderName = incomingText
            reticleState.lastFormattedText = text
            originalSetText(self, text)
            return
        end

        -- Not a cached trader name. Now check if the text matches a kiosk unit's name.
        -- IMPORTANT: The interact prompt and reticleover can be *different* targets (esp. in 3rd person).
        -- We only format when the text being set actually belongs to a kiosk, otherwise a distant
        -- reticleover trader could overwrite a nearby interact NPC's name.
        local matchedTag = nil
        local candidateTags = { "interact", "reticleover" }
        for i = 1, #candidateTags do
            local candidateTag = candidateTags[i]
            if DoesUnitExist(candidateTag) and IsUnitGuildKiosk(candidateTag) then
                local unitName = GetUnitName(candidateTag)
                if unitName and unitName ~= "" and unitName == text then
                    matchedTag = candidateTag
                    break
                end
            end
        end

        if not matchedTag then
            -- Text doesn't match any kiosk unit name; leave it alone.
            reticleState.lastCheckedTraderName = nil
            reticleState.lastFormattedText = nil
            originalSetText(self, text)
            return
        end

        -- It's a kiosk and the prompt text matches its unit name - fetch/format guild data.
        local guildId = GetUnitGuildKioskOwner(matchedTag)
        if not guildId or guildId == 0 then
            reticleState.lastCheckedTraderName = incomingText
            reticleState.lastFormattedText = text
            originalSetText(self, text)
            return
        end
        local guildDataById = SmartTrader.state.savedVars.guildDataById

        -- Check cache
        local cachedData = GuildUtils.GetCachedData(guildDataById, guildId)

        if cachedData then
            -- Cache hit - use cached data
            cacheHitCount = cacheHitCount + 1

            -- If this entry survived a flip (sizes preserved but locations cleared), patch in the observed
            -- traderName/city and reseed the trader-name lookup.
            if (not cachedData.traderName or cachedData.traderName == "") or (not cachedData.city or cachedData.city == "") then
                local observedTraderName = GetUnitName(matchedTag)
                local observedCity = GetUnitZone(matchedTag)
                local caption = GetUnitCaption(matchedTag)
                local observedGuildName = ReticleUtils.ExtractGuildNameFromCaption(caption)
                GuildActions.CacheGuildData(guildId, observedGuildName, observedTraderName, observedCity)
            end

            local formattedText = GuildUtils.FormatGuildDisplayText(cachedData, nil)
            if formattedText then
                text = formattedText
            end
        else
            -- Cache miss - fetch data if we haven't just checked this guild
            cacheMissCount = cacheMissCount + 1

            if reticleState.lastCheckedGuildId ~= guildId then
                cacheFetchCount = cacheFetchCount + 1
                reticleState.lastCheckedGuildId = guildId

                -- Get all available data from the kiosk
                local traderName = GetUnitName(matchedTag)
                local city = GetUnitZone(matchedTag)
                local caption = GetUnitCaption(matchedTag)
                local guildName = ReticleUtils.ExtractGuildNameFromCaption(caption)

                -- Store it in cache
                GuildActions.CacheGuildData(guildId, guildName, traderName, city)

                -- Use the newly cached data (or caption if storage failed)
                cachedData = guildDataById[guildId]
                if cachedData then
                    local formattedText = GuildUtils.FormatGuildDisplayText(cachedData, guildName)
                    if formattedText then
                        text = formattedText
                    end
                else
                    -- Fallback to caption extraction if storage somehow failed
                    local formattedText = GuildUtils.FormatGuildDisplayText(nil, guildName)
                    if formattedText then
                        text = formattedText
                    end
                end
            else
                -- Already checked this guild recently, just use caption
                local caption = GetUnitCaption(matchedTag)
                local fallbackGuildName = ReticleUtils.ExtractGuildNameFromCaption(caption)
                local formattedText = GuildUtils.FormatGuildDisplayText(nil, fallbackGuildName)
                if formattedText then
                    text = formattedText
                end
            end
        end

        reticleState.lastCheckedTraderName = incomingText
        reticleState.lastFormattedText = text
        originalSetText(self, text)
    end
end

---Hook unit frame name label
local function InitializeUnitFrameHook()
    local ReticleUtils = SmartTrader.ReticleUtils
    local GuildUtils = SmartTrader.GuildUtils
    local GuildActions = SmartTrader.GuildActions

    local targetFrame = ZO_UnitFrames_GetUnitFrame("reticleover")
    if targetFrame and targetFrame.nameLabel then
        local originalSetText = targetFrame.nameLabel.SetText
        local isInHook = false

        targetFrame.nameLabel.SetText = function(control, text)
            if isInHook then
                originalSetText(control, text)
                return
            end

            isInHook = true

            -- First, check if this text matches a cached trader name
            local guildDataByTraderName = SmartTrader.state.savedVars.guildDataByTraderName
            local guildDataById = SmartTrader.state.savedVars.guildDataById
            local data = guildDataByTraderName[text]

            if data then
                local caption = GetUnitCaption("reticleover")
                local fallbackGuildName = ReticleUtils.ExtractGuildNameFromCaption(caption)
                local formattedText = GuildUtils.FormatGuildDisplayText(data, fallbackGuildName)
                if formattedText then
                    originalSetText(control, formattedText)
                    isInHook = false
                    return
                end
            end

            -- Check if looking at a kiosk
            local isKiosk = DoesUnitExist("reticleover") and IsUnitGuildKiosk("reticleover")
            local guildId = isKiosk and GetUnitGuildKioskOwner("reticleover") or nil

            if isKiosk and guildId and guildId ~= 0 then
                -- Direct look at kiosk - we have guild ID
                local reticleState = SmartTrader.state.reticleState
                local cachedData = GuildUtils.GetCachedData(guildDataById, guildId)

                -- If this entry survived a flip (sizes preserved but locations cleared), patch in the observed
                -- traderName/city and reseed the trader-name lookup.
                if cachedData and ((not cachedData.traderName or cachedData.traderName == "") or (not cachedData.city or cachedData.city == "")) then
                    local traderName = GetUnitName("reticleover")
                    local city = GetUnitZone("reticleover")
                    local caption = GetUnitCaption("reticleover")
                    local guildName = ReticleUtils.ExtractGuildNameFromCaption(caption)
                    GuildActions.CacheGuildData(guildId, guildName, traderName, city)
                end

                if not cachedData and reticleState.lastCheckedGuildId ~= guildId then
                    reticleState.lastCheckedGuildId = guildId

                    local traderName = GetUnitName("reticleover")
                    local city = GetUnitZone("reticleover")
                    local caption = GetUnitCaption("reticleover")
                    local guildName = ReticleUtils.ExtractGuildNameFromCaption(caption)

                    GuildActions.CacheGuildData(guildId, guildName, traderName, city)
                    cachedData = guildDataById[guildId]
                end

                local caption = GetUnitCaption("reticleover")
                local fallbackGuildName = ReticleUtils.ExtractGuildNameFromCaption(caption)
                local formattedText = GuildUtils.FormatGuildDisplayText(cachedData, fallbackGuildName)
                if formattedText then
                    text = formattedText
                end
            end

            originalSetText(control, text)
            isInHook = false
        end
    end
end

---Initialize Reticle module
function ReticleActions.Initialize()
    InitializeReticleHook()
    zo_callLater(function()
        InitializeUnitFrameHook()
    end, 1000)
end

---Get statistics
function ReticleActions.GetStats()
    return {
        setTextCalls = setTextCallCount,
        cacheHits = cacheHitCount,
        cacheMisses = cacheMissCount,
        cacheFetches = cacheFetchCount
    }
end

SmartTrader.ReticleActions = ReticleActions
