-- Teleport Module
-- Handles all teleportation functionality including zone cache and player tracking
-- Dependencies: EventManager, Message, Validator
-- Data Dependencies: NMGuildHallTeleportData

local Addon = NMGuildHall
local Constants = Addon and Addon.Constants

-- Teleport Module
local Teleport = {
    initialized = false,
    -- Cache system
    zonePlayerCache = {},
    lastCacheUpdateTimeMs = 0,
    cacheMetrics = {
        hits = 0,
        misses = 0,
        rebuilds = 0,
        lastReset = GetGameTimeMilliseconds()
    },
    -- Performance caches
    collectibleCache = {},
    guildMemberCache = {},
    friendCache = {},
    playerNameCache = nil,
    lastCacheUpdate = 0,
    lastInvalidateMs = 0,
    invalidatePending = false,
    cacheRefreshSuppressed = false,
    -- Rebuild control
    pendingRebuild = false,
    pendingRebuildHandle = nil,
    pendingRefreshHandle = nil,
    -- Constants (Defaults, overwritten in Initialize)
    CACHE_DURATION = 30,
    REFRESH_COOLDOWN_MS = 5000,
    MINIMUM_CACHE_REBUILD_INTERVAL = 5000,
    MAX_MEMBERS_TO_CHECK = 100
}

-- Initialize the teleport module
function Teleport:Initialize()
    if self.initialized then
        return
    end
    
    -- Load Constants
    local Constants = Addon.Constants
    if Constants and Constants.TELEPORT then
        self.CACHE_DURATION = Constants.TELEPORT.DEFAULT_CACHE_DURATION_SECONDS or 30
        self.REFRESH_COOLDOWN_MS = (Constants.TELEPORT.DEFAULT_REFRESH_COOLDOWN_SECONDS and Constants.TELEPORT.DEFAULT_REFRESH_COOLDOWN_SECONDS * 1000) or 5000
        self.MINIMUM_CACHE_REBUILD_INTERVAL = Constants.TELEPORT.MINIMUM_CACHE_REBUILD_INTERVAL_MS or 5000
        self.MAX_MEMBERS_TO_CHECK = Constants.TELEPORT.DEFAULT_MAX_MEMBERS_TO_CHECK or 100
    end
    
    -- Reset all caches
    self.zonePlayerCache = {}
    self.collectibleCache = {}
    self.guildMemberCache = {}
    self.friendCache = {}
    self.playerNameCache = nil
    self.lastCacheUpdateTimeMs = 0
    self.lastCacheUpdate = 0
    self.cacheRefreshSuppressed = false
    self.pendingRebuild = false
    self.invalidatePending = false
    self.pendingRebuildHandle = nil
    self.pendingRefreshHandle = nil
    
    self.initialized = true
    
    if Addon and Addon.Message then
        Addon.Message:For("Teleport"):Debug(GetString(NMGH_DEBUG_TELEPORT_INIT))
    end
end

-- Get configurable max members to check
function Teleport:GetMaxMembersToCheck()
    if Addon and Addon.db and Addon.db.maxGuildMembersToCheck then
        return tonumber(Addon.db.maxGuildMembersToCheck) or self.MAX_MEMBERS_TO_CHECK
    elseif Addon and Addon.defaults and Addon.defaults.maxGuildMembersToCheck then
        return tonumber(Addon.defaults.maxGuildMembersToCheck) or self.MAX_MEMBERS_TO_CHECK
    end
    return self.MAX_MEMBERS_TO_CHECK
end

-- Get cache metrics for performance monitoring
function Teleport:GetCacheMetrics()
    local total = self.cacheMetrics.hits + self.cacheMetrics.misses
    local hitRate = total > 0 and (self.cacheMetrics.hits / total * 100) or 0
    return {
        hits = self.cacheMetrics.hits,
        misses = self.cacheMetrics.misses,
        rebuilds = self.cacheMetrics.rebuilds,
        hitRate = hitRate,
        total = total,
        uptime = (GetGameTimeMilliseconds() - self.cacheMetrics.lastReset) / 1000
    }
end

-- Reset cache metrics
function Teleport:ResetCacheMetrics()
    self.cacheMetrics.hits = 0
    self.cacheMetrics.misses = 0
    self.cacheMetrics.rebuilds = 0
    self.cacheMetrics.lastReset = GetGameTimeMilliseconds()
end

function Teleport:IsInZoneCacheBlockedPvpArea()
    local okAvA, inAvA = pcall(IsInAvAZone)
    if okAvA and inAvA then
        return true
    end

    if type(GetCurrentBattlegroundId) == "function" then
        local okBg, battlegroundId = pcall(GetCurrentBattlegroundId)
        if okBg and type(battlegroundId) == "number" and battlegroundId > 0 then
            return true
        end
    end

    local ava = Constants and Constants.AVA
    if ava and type(GetUnitZoneIndex) == "function" and type(GetZoneId) == "function" then
        local okZoneIndex, zoneIndex = pcall(GetUnitZoneIndex, "player")
        if okZoneIndex and type(zoneIndex) == "number" and zoneIndex > 0 then
            local okZoneId, zoneId = pcall(GetZoneId, zoneIndex)
            if okZoneId and type(zoneId) == "number" then
                if zoneId == ava.CYRODIIL_ZONE_ID or zoneId == ava.IMPERIAL_CITY_ZONE_ID then
                    return true
                end
            end
        end
    end

    return false
end

function Teleport:_CancelPendingZoneRefresh()
    if self.pendingRefreshHandle then
        zo_removeCallLater(self.pendingRefreshHandle)
        self.pendingRefreshHandle = nil
    end
    self.invalidatePending = false
end

-- Cache invalidation function
function Teleport:InvalidateCaches()
    self.zonePlayerCache = {}
    self.collectibleCache = {}
    self.guildMemberCache = {}
    self.friendCache = {}
    self.playerNameCache = nil
    self.lastCacheUpdateTimeMs = 0
    self.lastCacheUpdate = 0
end

-- Check if collectible is unlocked
function Teleport:IsCollectibleUnlocked(collectibleId)
    if collectibleId == nil then
        return true
    end
    
    -- Check cache first
    if self.collectibleCache[collectibleId] ~= nil then
        return self.collectibleCache[collectibleId]
    end
    
    local success, unlocked = pcall(function()
        local _, _, _, _, unlocked = GetCollectibleInfo(collectibleId)
        return unlocked
    end)
    
    if not success then
        if Addon and Addon.Message then
            Addon.Message:Error(GetString(NMGH_ERR_COLLECTIBLE_CHECK_FAILED), {
                id = tostring(collectibleId),
                error = tostring(unlocked)
            })
        end
        unlocked = false
    end
    
    -- Cache the result
    self.collectibleCache[collectibleId] = unlocked
    return unlocked
end

-- Get cached player name
function Teleport:GetPlayerName()
    if not self.playerNameCache then
        local success, name = pcall(GetUnitDisplayName, "player")
        if success then
            self.playerNameCache = name
        else
            self.playerNameCache = ""
            if Addon and Addon.Message then
                Addon.Message:Error(GetString(NMGH_ERR_PLAYER_NAME_FAILED), {error = tostring(name)})
            end
        end
    end
    return self.playerNameCache
end

-- Build cache of which zones have players with optimizations
function Teleport:BuildZonePlayerCache()
    local currentTimeMs = GetGameTimeMilliseconds()
    local cacheDurationMs = (self.CACHE_DURATION * 1000) -- Convert to milliseconds
    if Addon and Addon.db and Addon.db.zoneCacheDurationSeconds ~= nil then
        cacheDurationMs = (tonumber(Addon.db.zoneCacheDurationSeconds) or self.CACHE_DURATION) * 1000
    elseif Addon and Addon.defaults and Addon.defaults.zoneCacheDurationSeconds ~= nil then
        cacheDurationMs = (tonumber(Addon.defaults.zoneCacheDurationSeconds) or self.CACHE_DURATION) * 1000
    end
    if cacheDurationMs < 0 then cacheDurationMs = 0 end

    if self:IsInZoneCacheBlockedPvpArea() then
        self:_CancelPendingZoneRefresh()
        self.pendingRebuild = false
        if self.pendingRebuildHandle then
            zo_removeCallLater(self.pendingRebuildHandle)
            self.pendingRebuildHandle = nil
        end
        if not self.cacheRefreshSuppressed then
            self.cacheRefreshSuppressed = true
            if Addon and Addon.Message then
                Addon.Message:For("Teleport"):Debug("Zone cache rebuild suppressed while in PvP zone")
            end
        end
        return self.zonePlayerCache
    end

    if self.cacheRefreshSuppressed then
        self.cacheRefreshSuppressed = false
        if Addon and Addon.Message then
            Addon.Message:For("Teleport"):Debug("Zone cache rebuild resumed after leaving PvP zone")
        end
    end

    -- Return cached data if still valid (using milliseconds consistently)
    if (currentTimeMs - self.lastCacheUpdateTimeMs) < cacheDurationMs then
        self.cacheMetrics.hits = self.cacheMetrics.hits + 1
        return self.zonePlayerCache
    end
    
    self.cacheMetrics.misses = self.cacheMetrics.misses + 1
    self.cacheMetrics.rebuilds = self.cacheMetrics.rebuilds + 1

    local rebuildMode = "stale_async"
    if Addon and Addon.db and Addon.db.zoneCacheRebuildMode ~= nil then
        rebuildMode = tostring(Addon.db.zoneCacheRebuildMode)
    elseif Addon and Addon.defaults and Addon.defaults.zoneCacheRebuildMode ~= nil then
        rebuildMode = tostring(Addon.defaults.zoneCacheRebuildMode)
    end

    -- CRITICAL: Enforce minimum rebuild interval regardless of cache expiry
    if rebuildMode ~= "force" and (currentTimeMs - self.lastCacheUpdateTimeMs) < self.MINIMUM_CACHE_REBUILD_INTERVAL then
        if not self.pendingRebuild then
            self.pendingRebuild = true
            
            -- Cancel any existing pending rebuild
            if self.pendingRebuildHandle then
                zo_removeCallLater(self.pendingRebuildHandle)
            end
            
            self.pendingRebuildHandle = zo_callLater(function()
                self.pendingRebuildHandle = nil
                self.pendingRebuild = false
                self:BuildZonePlayerCache()
            end, self.MINIMUM_CACHE_REBUILD_INTERVAL - (currentTimeMs - self.lastCacheUpdateTimeMs))
        end
        return self.zonePlayerCache -- Return stale cache rather than hammering API
    end

    self.lastCacheUpdateTimeMs = currentTimeMs

    local cache = {}
    local playerName = self:GetPlayerName()
    
    -- === Group Members ===
    if GetGroupSize and GetGroupUnitTagByIndex and GetUnitDisplayName and GetUnitZoneIndex and GetZoneId and GetUnitName then
        local groupSize = GetGroupSize() or 0
        if groupSize > 0 then
            for i = 1, groupSize do
                local unitTag = GetGroupUnitTagByIndex(i)
                if unitTag then
                    local displayName = GetUnitDisplayName(unitTag)
                    if displayName and displayName ~= "" and displayName ~= playerName then
                        local zoneIndex = GetUnitZoneIndex(unitTag)
                        if type(zoneIndex) == "number" and zoneIndex > 0 then
                            local zoneId = GetZoneId(zoneIndex)
                            if type(zoneId) == "number" and zoneId > 0 then
                                cache[zoneId] = cache[zoneId] or {}
                                local unitName = GetUnitName(unitTag)
                                if unitName and unitName ~= "" then
                                    table.insert(cache[zoneId], {
                                        type = "group",
                                        name = unitName,
                                        displayName = displayName,
                                        unitTag = unitTag,
                                    })
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- === Friends ===
    if GetNumFriends and GetFriendInfo and GetFriendCharacterInfo then
        local numFriends = GetNumFriends() or 0
        if numFriends > 0 then
            for f = 1, numFriends do
                local displayName, _, status = GetFriendInfo(f)
                if displayName and status ~= PLAYER_STATUS_OFFLINE then
                    local hasCharacter, characterName, _, _, _, _, _, zoneId = GetFriendCharacterInfo(f)
                    if hasCharacter and displayName ~= playerName and zoneId and zoneId > 0 then
                        cache[zoneId] = cache[zoneId] or {}
                        table.insert(cache[zoneId], {
                            type = "friend",
                            name = characterName or "Unknown",
                            displayName = displayName,
                        })
                    end
                end
            end
        end
    end

    -- === Guild Members ===
    if GetNumGuilds and GetGuildId and GetNumGuildMembers and GetGuildMemberInfo and GetGuildMemberCharacterInfo then
        local numGuilds = GetNumGuilds() or 0
        if numGuilds > 0 then
            for g = 1, numGuilds do
                local guildId = GetGuildId(g)
                if guildId then
                    local numMembers = GetNumGuildMembers(guildId) or 0
                    if numMembers > 0 then
                        local baseLimit = self:GetMaxMembersToCheck()
                        local useDynamic = true
                        if Addon then
                            if Addon.db and Addon.db.dynamicGuildScanScaling ~= nil then
                                useDynamic = Addon.db.dynamicGuildScanScaling
                            elseif Addon.defaults and Addon.defaults.dynamicGuildScanScaling ~= nil then
                                useDynamic = Addon.defaults.dynamicGuildScanScaling
                            end
                        end

                        local scaledLimit = baseLimit
                        if useDynamic and numMembers > baseLimit then
                            scaledLimit = math.min(numMembers, math.min(250, baseLimit + math.floor(numMembers * 0.25)))
                        end

                        -- Hard cap on roster API calls. Previously this effectively capped *online* members
                        -- (membersChecked only incremented for non-offline), which could still scan most of the roster.
                        local membersScanned = 0
                        for m = 1, numMembers do
                            membersScanned = membersScanned + 1
                            if membersScanned > scaledLimit then
                                break -- Stop after checking max roster entries
                            end

                            local displayName, _, _, status = GetGuildMemberInfo(guildId, m)
                            if displayName and status ~= PLAYER_STATUS_OFFLINE then
                                local hasCharacter, characterName, _, _, _, _, _, zoneId = GetGuildMemberCharacterInfo(guildId, m)
                                if hasCharacter and displayName ~= playerName and zoneId and zoneId > 0 then
                                    cache[zoneId] = cache[zoneId] or {}
                                    table.insert(cache[zoneId], {
                                        type = "guild",
                                        name = characterName or "Unknown",
                                        displayName = displayName,
                                    })
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- Save cache and timestamp
    self.zonePlayerCache = cache
    self.lastCacheUpdate = currentTimeMs

    return cache
end

-- Get players in a specific zone from cache
function Teleport:GetPlayersInZone(zoneId)
    if not zoneId then return {} end
    
    -- Ensure cache is built
    local cache = self:BuildZonePlayerCache()
    
    if cache and cache[zoneId] then
        return cache[zoneId]
    end
    
    return {}
end

-- Check if a zone has available players
function Teleport:IsZoneAvailable(zoneId)
    if not zoneId then return false end
    local cache = self:BuildZonePlayerCache()
    return cache[zoneId] ~= nil and #cache[zoneId] > 0
end

-- Create teleport entry list with search filter
function Teleport:CreateTeleportEntryList(searchText)
    -- Safety check for data table
    if not NMGuildHallTeleportData or not NMGuildHallTeleportData.TeleportList then
        if Addon and Addon.Message then
            Addon.Message:Error(GetString(NMGH_ERR_TELEPORT_DATA_MISSING))
        end
        return {}
    end

    local function normalizeZoneField(value)
        if type(value) == "function" then
            local ok, result = pcall(value)
            if ok then
                return result
            end
            return nil
        end
        return value
    end
    
    -- Validate search text
    if Addon.Validator then
        searchText = Addon.Validator:SanitizeSearchText(searchText)
    end

    local searchLower = nil
    if searchText and searchText ~= "" then
        searchLower = (zo_strlower and zo_strlower(searchText)) or string.lower(searchText)
    end
    
    local entryList = {}
    local data = NMGuildHallTeleportData

    local doValidate = false
    if Addon and Addon.IsDebugEnabled and Addon:IsDebugEnabled() then
        doValidate = true
    end
    
    for _, zone in ipairs(data.TeleportList) do
        -- Validate zone data
        if doValidate and Addon.Validator then
            local validatedZone, err = Addon.Validator:ValidateZoneData(zone)
            if err then
                if Addon and Addon.Message then
                    Addon.Message:Warn(GetString(NMGH_WARN_INVALID_ZONE_DATA), {error = tostring(err)})
                end
                -- Skip invalid zone but continue processing others
            else
                zone = validatedZone
            end
        end

        local zoneName = normalizeZoneField(zone.name)
        
        if self:IsCollectibleUnlocked(zone.collectibleId) then
            local matchesSearch = true
            if searchLower then
                local searchName = zoneName or ""
                local zoneLower = (zo_strlower and zo_strlower(searchName)) or string.lower(searchName)
                matchesSearch = string.find(zoneLower, searchLower, 1, true) ~= nil
            end
            
            if matchesSearch then
                local hasPlayers = zone.redirect and true or self:IsZoneAvailable(zone.id)
                
                -- Validate callback function
                local callback
                if zone.redirect then
                    -- Zone is redirected to a UI page instead of teleporting
                    local redirectTab = string.lower(zone.redirect)
                    callback = function()
                        if Addon and Addon.UI then
                            Addon.UI:SwitchTab(redirectTab)
                        end
                    end
                else
                    callback = function()
                        if hasPlayers then
                            self:TeleportToZone(zone)
                        else
                            -- Show "no players" message with zone name
                            if Addon and Addon.Warn then
                                Addon:Warn(GetString(NMGH_WARN_NO_PLAYERS_AVAILABLE), {zone = zoneName})
                            end
                        end
                    end
                end
                
                 -- Validate the teleport entry
                local label = zone.label or zoneName or "[No Name]"
                if zone.label == nil and type(zone.textColor) == "string" and string.sub(zone.textColor, 1, 2) == "|c" then
                    label = zone.textColor .. tostring(label) .. "|r"
                end
                local entry = {
                    label = label,
                    icon = zone.icon,
                    textColor = zone.textColor,
                    zone = zone,
                    available = hasPlayers,
                    callback = callback
                }
                
                if doValidate and Addon.Validator then
                    local validatedEntry, err = Addon.Validator:ValidateTeleportEntry(entry)
                    if err then
                        if Addon and Addon.Message then
                            Addon.Message:For("Teleport"):Warn(GetString(NMGH_WARN_INVALID_TELEPORT_ENTRY), {error = tostring(err)})
                        end
                    else
                        entry = validatedEntry
                        entryList[#entryList + 1] = entry
                    end
                else
                    entryList[#entryList + 1] = entry
                end
            end
        end
    end
    
    return entryList
end

-- Teleport to a specific zone
function Teleport:TeleportToZone(zone)
    if not zone then return end

    local function HideUIAfterTeleportRequest()
        if Addon and Addon.UI and Addon.UI.Hide then
            pcall(Addon.UI.Hide, Addon.UI)
        end
    end
    
    local okInAvAZone, inAvAZone = pcall(IsInAvAZone)
    if okInAvAZone and inAvAZone then
        if Addon then
            Addon:Warn(GetString(NMGH_CHAT_TELEPORT_PORT_AVA_BLOCKED))
        end
        return
    end

    -- USE THE CACHE instead of re-querying everything
    local playersInZone = self:GetPlayersInZone(zone.id)
    
    if not playersInZone or #playersInZone == 0 then
        if Addon then
            Addon:Warn(GetString(NMGH_CHAT_TELEPORT_PORT_NO_PLAYERS), {zone = zone.name or "[Unknown]"})
        end
        return
    end
    
    -- Try to jump to the first available player based on type priority
    local typeOrder = {"group", "friend", "guild"}
    local playerName = self:GetPlayerName()
    local jumpResultSuccess = rawget(_G, "JUMP_TO_PLAYER_RESULT_SUCCESS")

    local function ResolveJumpOutcome(jumpResult)
        if type(jumpResult) == "boolean" then
            return jumpResult and "confirmed" or "failed"
        end
        if type(jumpResult) == "number" and jumpResultSuccess ~= nil then
            return (jumpResult == jumpResultSuccess) and "confirmed" or "failed"
        end
        if jumpResult ~= nil then
            return "failed"
        end
        return "requested"
    end

    local function TryJumpToPlayer(playerType, player)
        if not player then
            return "failed"
        end

        if playerType == "group" then
            local target = player.unitTag or player.name
            if not target then
                return "failed"
            end

            if CanJumpToGroupMember then
                local okCan, canJump = pcall(CanJumpToGroupMember, target)
                if not okCan or not canJump then
                    return "failed"
                end
            end

            local okJump, jumpResult = pcall(JumpToGroupMember, target)
            if not okJump then
                return "failed"
            end
            return ResolveJumpOutcome(jumpResult)
        elseif playerType == "friend" then
            local target = player.displayName
            if not target then
                return "failed"
            end

            if CanJumpToFriend then
                local okCan, canJump = pcall(CanJumpToFriend, target)
                if not okCan or not canJump then
                    return "failed"
                end
            end

            local okJump, jumpResult = pcall(JumpToFriend, target)
            if not okJump then
                return "failed"
            end
            return ResolveJumpOutcome(jumpResult)
        elseif playerType == "guild" then
            local target = player.displayName
            if not target then
                return "failed"
            end

            if CanJumpToGuildMember then
                local okCan, canJump = pcall(CanJumpToGuildMember, target)
                if not okCan or not canJump then
                    return "failed"
                end
            end

            local okJump, jumpResult = pcall(JumpToGuildMember, target)
            if not okJump then
                return "failed"
            end
            return ResolveJumpOutcome(jumpResult)
        end
        return "failed"
    end
    
    for _, playerType in ipairs(typeOrder) do
        for _, player in ipairs(playersInZone) do
            if player.type == playerType and player.displayName ~= playerName then
                local jumpOutcome = TryJumpToPlayer(playerType, player)
                if jumpOutcome == "confirmed" then
                    if Addon then
                        Addon:Msg(GetString(NMGH_CHAT_TELEPORTING_TO), {destination = zone.name or "[Unknown]"})
                    end
                    HideUIAfterTeleportRequest()
                    return
                elseif jumpOutcome == "requested" then
                    -- "requested" means the jump was initiated but we don't have confirmation yet.
                    -- Keep player-facing messaging consistent, and reserve the extra detail for debug mode.
                    if Addon then
                        Addon:Msg(GetString(NMGH_CHAT_TELEPORTING_TO), {destination = zone.name or "[Unknown]"})
                    end
                    if Addon and Addon.Message then
                        Addon.Message:For("Teleport"):Debug("Teleport jump outcome: requested ({destination})", {
                            destination = zone.name or "[Unknown]"
                        })
                    end
                    HideUIAfterTeleportRequest()
                    return
                end
            end
        end
    end
    
    -- No one found (shouldn't happen if cache is correct)
    if Addon then
        Addon:Warn(GetString(NMGH_CHAT_TELEPORT_PORT_NO_PLAYERS), {zone = zone.name or "[Unknown]"})
    end
end

-- Teleport to a player's house
function Teleport:TeleportToHouse(name, houseId, message)
    local function HideUIAfterTeleportRequest()
        if Addon and Addon.UI and Addon.UI.Hide then
            pcall(Addon.UI.Hide, Addon.UI)
        end
    end

    local okAvA, inAvA = pcall(IsInAvAZone)
    if okAvA and inAvA then
        if Addon then
            Addon:Warn(GetString(NMGH_CHAT_TELEPORT_PORT_AVA_BLOCKED))
        end
        return
    end

    local success, displayName = pcall(GetDisplayName)
    if not success then
        if Addon and Addon.Message then
            Addon.Message:Error(GetString(NMGH_ERR_HOUSE_TELEPORT_NAME_FAILED), { error = tostring(displayName) })
        end
        return
    
    end

    local playerName = self:GetPlayerName()
    if name == playerName then
        local errSelf = RequestJumpToHouse(houseId)
        if errSelf ~= HOUSE_TELEPORT_RESULT_SUCCESS then
            if Addon and Addon.Message then
                Addon.Message:Error(GetString(NMGH_ERR_JUMP_SELF_FAILED), { error = tostring(errSelf) })
            end
        else
            HideUIAfterTeleportRequest()
        end
    else
        local errOther = JumpToSpecificHouse(name, houseId)
        if errOther ~= HOUSE_TELEPORT_RESULT_SUCCESS then
            if Addon and Addon.Message then
                Addon.Message:Error(GetString(NMGH_ERR_JUMP_OWNER_FAILED), { name = name, error = tostring(errOther) })
            end
        else
            HideUIAfterTeleportRequest()
        end
    end
    
    if message and CHAT_ROUTER and CHAT_ROUTER.AddSystemMessage then
        CHAT_ROUTER:AddSystemMessage(message)
    end
end

-- Force refresh of zone cache
function Teleport:RefreshZoneCache()
    if self:IsInZoneCacheBlockedPvpArea() then
        self:_CancelPendingZoneRefresh()
        if not self.cacheRefreshSuppressed then
            self.cacheRefreshSuppressed = true
            if Addon and Addon.Message then
                Addon.Message:For("Teleport"):Debug("Zone cache invalidation suppressed while in PvP zone")
            end
        end
        return false
    end

    if self.cacheRefreshSuppressed then
        self.cacheRefreshSuppressed = false
        if Addon and Addon.Message then
            Addon.Message:For("Teleport"):Debug("Zone cache invalidation resumed after leaving PvP zone")
        end
    end

    if self.invalidatePending then
        return
    end
    -- Cancel any pending refresh
    self:_CancelPendingZoneRefresh()
    
    local refreshCooldownMs = self.REFRESH_COOLDOWN_MS
    if Addon and Addon.db and Addon.db.zoneCacheRefreshCooldownSeconds ~= nil then
        refreshCooldownMs = (tonumber(Addon.db.zoneCacheRefreshCooldownSeconds) or 0) * 1000
    elseif Addon and Addon.defaults and Addon.defaults.zoneCacheRefreshCooldownSeconds ~= nil then
        refreshCooldownMs = (tonumber(Addon.defaults.zoneCacheRefreshCooldownSeconds) or 0) * 1000
    end
    if refreshCooldownMs < 0 then refreshCooldownMs = 0 end

    local nowMs = GetGameTimeMilliseconds()
    if self.lastInvalidateMs > 0 and (nowMs - self.lastInvalidateMs) < refreshCooldownMs then
        if not self.invalidatePending then
            self.invalidatePending = true
            local delayMs = refreshCooldownMs - (nowMs - self.lastInvalidateMs)
            self.pendingRefreshHandle = zo_callLater(function()
                self.pendingRefreshHandle = nil
                self.invalidatePending = false
                if self:IsInZoneCacheBlockedPvpArea() then
                    self.cacheRefreshSuppressed = true
                    if Addon and Addon.Message then
                        Addon.Message:For("Teleport"):Debug("Delayed zone cache invalidation skipped while in PvP zone")
                    end
                    return
                end
                self.lastInvalidateMs = GetGameTimeMilliseconds()
                self:InvalidateCaches()
                if Addon and Addon.Message then
                    Addon.Message:For("Teleport"):Debug("Zone cache invalidated")
                end
            end, delayMs)
        end
        return
    end

    self.lastInvalidateMs = nowMs
    self:InvalidateCaches()
    if Addon and Addon.Message then
        Addon.Message:For("Teleport"):Debug(GetString(NMGH_DEBUG_ZONE_CACHE_INVALID))
    end
end

-- Cleanup function for addon unload
function Teleport:Cleanup()
    -- Cancel pending rebuild
    if self.pendingRebuildHandle then
        zo_removeCallLater(self.pendingRebuildHandle)
        self.pendingRebuildHandle = nil
    end
    self.pendingRebuild = false
    
    -- Cancel any pending refresh
    self:_CancelPendingZoneRefresh()
    self.cacheRefreshSuppressed = false
    
    -- Clear caches
    self:InvalidateCaches()
    
    if Addon and Addon.Message then
        Addon.Message:For("Teleport"):Debug(GetString(NMGH_DEBUG_CLEANUP_DONE))
    end
end

-- Export teleport module
NMGuildHall = NMGuildHall or {}
NMGuildHall.Teleport = Teleport

return Teleport
