-- Local references
local Scrollkeeper = Scrollkeeper
local SF = Scrollkeeper.Framework
local SF_Set = Scrollkeeper.Settings
local libScroll = nil

if type(SF) ~= "table" or type(SF_Set) ~= "table" then
  d(SF.func._L("ScrollkeeperProvisionMember", "ERROR_FRAMEWORK_MISSING"))
  return
end

-- Initialize module
Scrollkeeper.ProvisionMember = Scrollkeeper.ProvisionMember or { Name = "ScrollkeeperProvisionMember", Version = "1" }
local _addon = Scrollkeeper.ProvisionMember

-- Backward compatibility (DEPRECATED)
_G.ScrollkeeperProvisionMember = Scrollkeeper.ProvisionMember

local DEBUG_FILTERS = false  -- Set to true for debugging

-- Get guilds in display order (respects Guild Reorder if available)
local function getGuildsInOrder()
  local guilds = {}
  
  -- Check if Dolgubon's Guild Reorder is active
  if DolgubonsGuildReorder and type(DolgubonsGuildReorder.keyOrder) == "table" then
    -- keyOrder maps: visual position -> original guild index
    for visualPos = 1, GetNumGuilds() do
      local originalIdx = DolgubonsGuildReorder.keyOrder[visualPos]
      if originalIdx then
        local guildId = GetGuildId(originalIdx)
        local guildName = GetGuildName(guildId)
        if guildName then
          table.insert(guilds, guildName)
        end
      end
    end
  else
    -- Use native client order
    for i = 1, GetNumGuilds() do
      local guildName = GetGuildName(GetGuildId(i))
      if guildName then
        table.insert(guilds, guildName)
      end
    end
  end
  
  return guilds
end

-- Ensure the API table exists
SF.ProvisionMember = SF.ProvisionMember or {}
local PM = SF.ProvisionMember

-- LibHistoire integration for accurate guild join times
local LibHistoire = LibHistoire
local histoireReady = false

-- 🧠 Settings defaults
local defaults = {
  enabled = false,
  trackingDays = 30,
  autoTag = true,
  notifyOnJoin = true,
  taggedMembers = {},
  guildSettings = {},
  processedMembers = {},
}

-- Get settings using unified system
local function getSettings()
  -- Safe guards: framework table and required method must exist
  if type(SF) ~= "table" or type(SF.getModuleSettings) ~= "function" then
    -- Return a shallow copy of defaults to avoid modifying the original defaults table
    local safe = {}
    for k, v in pairs(defaults) do safe[k] = v end
    return safe
  end

  -- Defensive account name retrieval
  local accountName = (type(GetDisplayName) == "function") and GetDisplayName() or "UnknownAccount"
  if accountName == "" then accountName = "UnknownAccount" end
  local accountKey = _addon.Name .. "_" .. accountName

  -- Call framework method but guard the result
  local ok, settings = pcall(SF.getModuleSettings, accountKey, defaults)
  if not ok or type(settings) ~= "table" then
    -- Ensure we return a table (copy of defaults) so callers can index safely
    local safe = {}
    for k, v in pairs(defaults) do safe[k] = v end
    return safe
  end

  -- Ensure required subtables exist
  settings.taggedMembers = settings.taggedMembers or {}
  settings.guildSettings = settings.guildSettings or {}
  settings.processedMembers = settings.processedMembers or {}

  return settings
end

-- Track scroll position separately
local scrollOffset = 0
local uniqueIdCounter = 0

-- Generate unique control names
local function getUniqueControlName(prefix)
  uniqueIdCounter = uniqueIdCounter + 1
  return prefix .. "_" .. tostring(uniqueIdCounter) .. "_" .. tostring(GetTimeStamp())
end

function PM.promoteMember(guildName, memberName, notes)
  local settings = getSettings()
  if not settings or not guildName or not memberName then return false end
  if settings.taggedMembers[guildName] and settings.taggedMembers[guildName][memberName] then
    settings.taggedMembers[guildName][memberName].status = SF.func._L("ScrollkeeperProvisionMember", "STATUS_PROMOTED")
    settings.taggedMembers[guildName][memberName].promotedDate = GetTimeStamp()
    settings.taggedMembers[guildName][memberName].promotedBy = GetUnitName("player")
    if notes then
      local currentNotes = settings.taggedMembers[guildName][memberName].notes or ""
      settings.taggedMembers[guildName][memberName].notes = currentNotes .. " | Promoted: " .. notes
    end
    return true
  end
  return false
end

function PM.removeMember(guildName, memberName, reason)
  local settings = getSettings()
  if not settings or not guildName or not memberName then return false end

  if settings.taggedMembers[guildName] and settings.taggedMembers[guildName][memberName] then
    -- Get the tracking reason before removing
    local trackingReason = settings.taggedMembers[guildName][memberName].reason or SF.func._L("ScrollkeeperProvisionMember", "REASON_RANK")

    -- Remove from active tracking
    settings.taggedMembers[guildName][memberName] = nil

    -- Mark as processed with the reason
    settings.processedMembers = settings.processedMembers or {}
    settings.processedMembers[guildName] = settings.processedMembers[guildName] or {}
    settings.processedMembers[guildName][memberName] = {
      reason = trackingReason,
      removedTime = GetTimeStamp(),
      removedBy = GetUnitName("player")
    }
    return true
  end
  return false
end

-- Get per-guild settings with enhanced filters
local function getGuildSettings(guildName)
  if not guildName or type(guildName) ~= "string" or guildName == "" then
    return {
      enabled = false,
      autoTag = false,
      notifyOnJoin = false,
      trackingDays = 30,
      goldDonationFilter = {
        enabled = false,
        requiredAmount = 5000,
        timePeriodDays = 30,
        timeUnit = "days" -- "days", "weeks", "months"
      },
      inactivityFilter = {
        enabled = false,
        inactiveDays = 30
      },
      donorFilter = {
        enabled = false,
        minimumAmount = 1000,
        timePeriodDays = 30
      }
    }
  end

  local settings = getSettings()
  settings.guildSettings = settings.guildSettings or {}

  if not settings.guildSettings[guildName] then
    settings.guildSettings[guildName] = {
      enabled = true,
      autoTag = true,
      notifyOnJoin = true,
      trackingDays = 30,
      goldDonationFilter = {
        enabled = false,
        requiredAmount = 5000,
        timePeriodDays = 30,
        timeUnit = "days"
      },
      inactivityFilter = {
        enabled = false,
        inactiveDays = 30
      },
      donorFilter = {
        enabled = false,
        minimumAmount = 1000,
        timePeriodDays = 30
      }
    }
  else
    -- Ensure new filters exist
    if not settings.guildSettings[guildName].inactivityFilter then
      settings.guildSettings[guildName].inactivityFilter = {
        enabled = false,
        inactiveDays = 30
      }
    end
    if not settings.guildSettings[guildName].donorFilter then
      settings.guildSettings[guildName].donorFilter = {
        enabled = false,
        minimumAmount = 1000,
        timePeriodDays = 30
      }
    end

    -- Legacy gold filter migration
    local gdf = settings.guildSettings[guildName].goldDonationFilter
    if not gdf then
      settings.guildSettings[guildName].goldDonationFilter = { enabled = false, requiredAmount = 5000, timePeriodDays = 30, timeUnit = "days" }
    else
      if not gdf.requiredAmount then gdf.requiredAmount = gdf.minAmount or 5000 end
      if not gdf.timePeriodDays then gdf.timePeriodDays = gdf.daysSinceLastDonation or 30 end
      if not gdf.timeUnit then gdf.timeUnit = "days" end
      gdf.minAmount = nil
      gdf.daysSinceLastDonation = nil
      gdf.checkFrequency = nil
    end
  end

  return settings.guildSettings[guildName]
end

-- Theme update function for provision window
local function applyProvisionTheme(window)
  if not window or not SF or not SF.theme then return end

  -- Update title bar
  if window.titleBar and window.titleText and SF.applyThemeToTitleBar then
    SF.applyThemeToTitleBar(window.titleBar, window.titleText)
  end

  -- Update header panel background
  if window.headerPanel and SF.theme.colors and SF.theme.colors.header then
    local h = SF.theme.colors.header
    window.headerPanel:SetCenterColor(h[1] * 0.3, h[2] * 0.3, h[3] * 0.3, 1)
  end

  -- Update column headers
  if SF.applyThemeColor then
    if window.nameHeader then SF.applyThemeColor(window.nameHeader, "header") end
    if window.daysHeader then SF.applyThemeColor(window.daysHeader, "header") end
    if window.statusHeader then SF.applyThemeColor(window.statusHeader, "header") end
    if window.notesHeader then SF.applyThemeColor(window.notesHeader, "header") end
    if window.actionsHeader then SF.applyThemeColor(window.actionsHeader, "header") end
    if window.nameSortArrow then SF.applyThemeColor(window.nameSortArrow, "header") end
    if window.daysSortArrow then SF.applyThemeColor(window.daysSortArrow, "header") end
  end

  -- Update stats panel
  if window.statsPanel and SF.theme.colors and SF.theme.colors.panel then
    local p = SF.theme.colors.panel
    window.statsPanel:SetCenterColor(p[1], p[2], p[3], p[4])
  end
  -- Update filter button states with theme
  if window.updateFilterStates then
    window.updateFilterStates()
  end
end

-- Check for Advanced Member Tooltip availability
local AMT_Available = false
local function checkAMTAvailability()
  if AMT and AMT.GetAmountDonated and type(AMT.GetAmountDonated) == "function" then
    AMT_Available = true
    d(SF.func._L("ScrollkeeperProvisionMember", "SUCCESS_AMT_DETECTED"))
    return true
  end
  return false
end

-- Enhanced getMemberJoinTime with Data module integration
local function getMemberJoinTime(guildId, displayName)
  local guildName = GetGuildName(guildId)

  -- Priority 1: Try Advanced Member Tooltip
  if AMT_Available and AMT.savedData and AMT.savedData[guildName] then
    local memberKey = string.lower(displayName)
    local amtMemberData = AMT.savedData[guildName][memberKey]

    if amtMemberData and amtMemberData.timeJoined and amtMemberData.timeJoined > 0 then
      return amtMemberData.timeJoined, SF.func._L("ScrollkeeperProvisionMember", "SOURCE_AMT")
    end
  end

  -- Priority 2: Try ScrollkeeperData event cache
  if SF.Data and SF.Data.getEvents then
    local events = SF.Data.getEvents(guildName, "roster", 10000)

    -- Find join event for this member
    for _, event in ipairs(events) do
      if event.eventType == GUILD_HISTORY_ROSTER_EVENT_JOIN then
        local eventDisplayName = event.info.displayName or event.info.targetDisplayName
        if eventDisplayName == displayName then
          return event.timestamp, SF.func._L("ScrollkeeperProvisionMember", "SOURCE_DATA")
        end
      end
    end
  end

  -- Priority 3: Try LibHistoire (if available)
  if LibHistoire and histoireReady then
    local guildData = LibHistoire:GetGuildHistoryProcessor(guildId)
    if guildData and guildData.GetMemberJoinTime then
      local success, joinTime = pcall(guildData.GetMemberJoinTime, guildData, displayName)
      if success and joinTime and joinTime > 0 then
        return joinTime, SF.func._L("ScrollkeeperProvisionMember", "SOURCE_HISTOIRE")
      end
    end
  end

  return nil, SF.func._L("ScrollkeeperProvisionMember", "SOURCE_UNKNOWN")
end

-- Check member's gold donations using ScrollkeeperData
local function checkMemberDonations(guildId, guildName, displayName, requiredAmount, timePeriodDays, debugMode)
  if not guildId or not guildName or not displayName then
    if debugMode then
      d(string.format("[PM Debug] checkMemberDonations: Missing params - guildId:%s, guildName:%s, displayName:%s",
        tostring(guildId), tostring(guildName), tostring(displayName)))
    end
    return false, 0
  end

  if not SF.Data or not SF.Data.getEvents then
    if debugMode then
      d("[PM Debug] checkMemberDonations: SF.Data.getEvents not available")
    end
    return false, 0
  end

  -- Get ALL bankedGold events
  local allEvents = SF.Data.getEvents(guildName, "bankedGold", 999999)

  if not allEvents or #allEvents == 0 then
    if debugMode then
      d(string.format("[PM Debug] checkMemberDonations: No events found for guild %s", guildName))
    end
    return false, 0
  end

  local now = GetTimeStamp()
  local cutoffTime = now - (timePeriodDays * 86400)
  local totalInPeriod = 0
  local depositsFound = 0
  local allDepositsForMember = 0
  local oldestEventTime = nil
  local newestEventTime = nil

  if debugMode then
    d(string.format("[PM Debug] Checking %s in %s: Required=%d gold in last %d days",
      displayName, guildName, requiredAmount, timePeriodDays))
    d(string.format("[PM Debug] Current timestamp: %d, Cutoff timestamp: %d", now, cutoffTime))
    d(string.format("[PM Debug] Cutoff date: %s", os.date("%Y-%m-%d %H:%M:%S", cutoffTime)))
    d(string.format("[PM Debug] Total bankedGold events to scan: %d", #allEvents))
  end

  -- Filter and sum deposits
  for _, event in ipairs(allEvents) do
    if event.eventType == GUILD_HISTORY_BANKED_CURRENCY_EVENT_DEPOSITED then
      local eventDisplayName = event.info.displayName or event.info.actingDisplayName

      -- Normalize both names for comparison (remove @ if present)
      local normalizedEventName = eventDisplayName
      local normalizedSearchName = displayName

      if normalizedEventName and string.sub(normalizedEventName, 1, 1) == "@" then
        normalizedEventName = string.sub(normalizedEventName, 2)
      end
      if normalizedSearchName and string.sub(normalizedSearchName, 1, 1) == "@" then
        normalizedSearchName = string.sub(normalizedSearchName, 2)
      end

      if normalizedEventName == normalizedSearchName then
        allDepositsForMember = allDepositsForMember + 1
        local eventAmount = event.info.amount or 0
        local eventDate = os.date("%Y-%m-%d %H:%M:%S", event.timestamp)

        if not oldestEventTime or event.timestamp < oldestEventTime then
          oldestEventTime = event.timestamp
        end
        if not newestEventTime or event.timestamp > newestEventTime then
          newestEventTime = event.timestamp
        end

        if event.timestamp >= cutoffTime then
          totalInPeriod = totalInPeriod + eventAmount
          depositsFound = depositsFound + 1
          if debugMode then
            d(string.format("[PM Debug]   IN PERIOD: %d gold on %s (timestamp: %d)",
              eventAmount, eventDate, event.timestamp))
          end
        else
          if debugMode then
            d(string.format("[PM Debug]   TOO OLD: %d gold on %s (timestamp: %d)",
              eventAmount, eventDate, event.timestamp))
          end
        end
      end
    end
  end

  if debugMode then
    if allDepositsForMember > 0 then
      d(string.format("[PM Debug] Found %d total deposits for %s (oldest: %s, newest: %s)",
        allDepositsForMember,
        displayName,
        oldestEventTime and os.date("%Y-%m-%d", oldestEventTime) or "none",
        newestEventTime and os.date("%Y-%m-%d", newestEventTime) or "none"))
      d(string.format("[PM Debug] In-period: %d deposits = %d gold | Required: %d gold",
        depositsFound, totalInPeriod, requiredAmount))
    else
      d(string.format("[PM Debug] No deposits found for %s in any time period", displayName))
    end

    local meetsRequirement = (totalInPeriod >= requiredAmount)
    d(string.format("[PM Debug] RESULT: %s %s requirement (%d >= %d = %s)",
      displayName,
      meetsRequirement and "MEETS" or "FAILS",
      totalInPeriod,
      requiredAmount,
      tostring(meetsRequirement)))
  end

  -- Returns TRUE if they meet/exceed requirement (don't track)
  -- Returns FALSE if they don't meet requirement (track them)
  local meetsRequirement = (totalInPeriod >= requiredAmount)

  return meetsRequirement, totalInPeriod
end

-- Check member inactivity using ESO's native last online data
local function checkMemberInactivity(guildId, displayName, inactiveDays, debugMode)
  if not guildId or not displayName or not inactiveDays then
    return false, 0
  end

  -- Search guild roster for this member
  for i = 1, GetNumGuildMembers(guildId) do
    local memberName, _, _, _, lastOnline = GetGuildMemberInfo(guildId, i)
    if memberName == displayName then
      -- CRITICAL FIX: ESO's GetGuildMemberInfo returns lastOnline in SECONDS since epoch
      -- but it's actually the time SINCE last online, not a timestamp
      -- We need to get the actual last online time
      local now = GetTimeStamp()
      local secondsSinceOnline = lastOnline
      local daysSinceOnline = math.floor(secondsSinceOnline / 86400)

      if debugMode then
        d(string.format("[PM Inactive] %s: Last online %d seconds ago (%.1f days)",
          displayName, secondsSinceOnline, secondsSinceOnline / 86400))
        d(string.format("[PM Inactive]   Threshold: %d days", inactiveDays))
        d(string.format("[PM Inactive]   Result: %s",
          daysSinceOnline >= inactiveDays and "INACTIVE - TRACK" or "ACTIVE - SKIP"))
      end

      -- Return true if they've been offline longer than threshold
      local isInactive = (daysSinceOnline >= inactiveDays)
      return isInactive, daysSinceOnline
    end
  end

  -- Member not found in roster
  if debugMode then
    d(string.format("[PM Inactive] %s: NOT FOUND in guild roster", displayName))
  end
  return false, 0
end

-- Simplified probationary rank detection - only check rank position
local function isMemberInProbationaryRank(guildId, displayName)
  if not guildId or not displayName then return false end

  -- Get the total number of ranks for this guild
  local numRanks = GetNumGuildRanks(guildId)
  if numRanks == 0 then return false end

  -- Find the member and check their rank
  for i = 1, GetNumGuildMembers(guildId) do
    local memberName, _, rankIndex = GetGuildMemberInfo(guildId, i)
    if memberName == displayName then
      -- ESO uses 1-based indexing where 1 = Guild Master (highest authority)
      -- Higher numbers = lower authority, so numRanks = lowest rank (entry level)
      local isProbationary = (rankIndex == numRanks)

      return isProbationary
    end
  end

  return false
end

function PM.tagMemberAsProvisional(guildName, memberName, notes, reason, actualJoinTime)
  local settings = getSettings()
  if not settings or not guildName or not memberName then return false end
  settings.taggedMembers[guildName] = settings.taggedMembers[guildName] or {}

    -- Determine status based on reason
  local status = SF.func._L("ScrollkeeperProvisionMember", "STATUS_PROVISIONAL")
  if reason == SF.func._L("ScrollkeeperProvisionMember", "REASON_GOLD") then
    status = SF.func._L("ScrollkeeperProvisionMember", "STATUS_PENDING_DONATION")
  elseif reason == SF.func._L("ScrollkeeperProvisionMember", "REASON_INACTIVE") then
    status = SF.func._L("ScrollkeeperProvisionMember", "STATUS_INACTIVE")
  elseif reason == SF.func._L("ScrollkeeperProvisionMember", "REASON_DONOR") then
    status = SF.func._L("ScrollkeeperProvisionMember", "STATUS_DONOR")
  end

  -- Generate useful notes based on reason
  local autoNotes = notes or ""

  if reason == SF.func._L("ScrollkeeperProvisionMember", "REASON_GOLD") then
    -- For gold filter, show their current donation total
    if SF.Data and SF.Data.getMemberDonationInfo then
      local donationInfo = SF.Data.getMemberDonationInfo(guildName, memberName)
      if donationInfo and donationInfo.totalDonated then
        autoNotes = string.format("Donated: %d gold", donationInfo.totalDonated)
      else
        autoNotes = "No donations found"
      end
    end

  elseif reason == SF.func._L("ScrollkeeperProvisionMember", "REASON_DONOR") then
  -- For donor filter, use the same calculation as the filter check
  autoNotes = "Active Donor" -- Default fallback
  
  if SF.Data and SF.Data.getEvents then
    local guildId = nil
    for i = 1, GetNumGuilds() do
      if GetGuildName(GetGuildId(i)) == guildName then
        guildId = GetGuildId(i)
        break
      end
    end
    
    if guildId then
      local guildSettings = getGuildSettings(guildName)
      if guildSettings and guildSettings.donorFilter then
        -- Safely call checkMemberDonations with error handling
        local success, meetsReq, totalDonated = pcall(function()
          return checkMemberDonations(
            guildId,
            guildName,
            memberName,
            guildSettings.donorFilter.minimumAmount or 1000,
            guildSettings.donorFilter.timePeriodDays or 30,
            false
          )
        end)
        
        if success and totalDonated and totalDonated > 0 then
          autoNotes = string.format("Total donated: %d gold", totalDonated)
        elseif success and guildSettings.donorFilter.minimumAmount then
          autoNotes = string.format("Donor (min: %d gold)", guildSettings.donorFilter.minimumAmount)
        end
      end
    end
  end

  elseif reason == SF.func._L("ScrollkeeperProvisionMember", "REASON_INACTIVE") then
    -- For inactive filter, leave notes blank (days column shows offline time)
    autoNotes = ""
  end

  -- Don't add generic "auto-tagged" message
  -- Only use the specific notes we generated above

  settings.taggedMembers[guildName][memberName] = {
    joinDate = GetTimeStamp(),
    actualJoinTime = actualJoinTime or GetTimeStamp(),
    notes = autoNotes,
    status = status,
    reason = reason or SF.func._L("ScrollkeeperProvisionMember", "REASON_RANK"),
    taggedBy = GetUnitName("player")
  }

  -- Remove from processed list so they can be tracked again
  settings.processedMembers = settings.processedMembers or {}
  settings.processedMembers[guildName] = settings.processedMembers[guildName] or {}
  settings.processedMembers[guildName][memberName] = nil

  return true
end

-- Enhanced member filtering
local function shouldTrackMember(guildId, guildName, displayName, force)
  if not guildName or guildName == "" or not displayName then
    return false, nil, nil
  end

  local guildSettings = getGuildSettings(guildName)
  if not guildSettings or not guildSettings.enabled then
    return false, nil, nil
  end

  local settings = getSettings()
  if not settings then return false, nil, nil end

  -- CRITICAL: Check processed members FIRST
  if settings.processedMembers and settings.processedMembers[guildName] and settings.processedMembers[guildName][displayName] then
    local processedData = settings.processedMembers[guildName][displayName]

    if type(processedData) == "table" and processedData.reason then
      -- Rank removals are PERMANENT
      if processedData.reason == SF.func._L("ScrollkeeperProvisionMember", "REASON_RANK") then
        return false, nil, nil
      end
      -- Gold, inactive, and donor removals can be re-evaluated after 7 days
      if processedData.reason == SF.func._L("ScrollkeeperProvisionMember", "REASON_GOLD") or
         processedData.reason == SF.func._L("ScrollkeeperProvisionMember", "REASON_INACTIVE") or
         processedData.reason == SF.func._L("ScrollkeeperProvisionMember", "REASON_DONOR") then
        local daysSinceRemoval = (GetTimeStamp() - (processedData.removedTime or 0)) / 86400
        if daysSinceRemoval < 7 then
          return false, nil, nil
        end
        -- Cooldown expired, clear and continue
        settings.processedMembers[guildName][displayName] = nil
      end
    else
      -- Legacy format - treat as permanent
      return false, nil, nil
    end
  end

  -- Check if already tracked - be smart about updates
  local memberData = settings.taggedMembers and settings.taggedMembers[guildName] and settings.taggedMembers[guildName][displayName]
  if memberData and memberData.status ~= SF.func._L("ScrollkeeperProvisionMember", "STATUS_PROMOTED") then
    -- If not forcing, skip already-tracked members
    if not force then
      return false, nil, nil
    end
    -- If forcing, we'll check below if the reason has changed
    -- and only update if necessary
  end

  -- COLLECT ALL MATCHING FILTERS
  -- We check ALL filters and use the highest priority match
  local matchedFilters = {}

  -- FILTER 1: Probationary rank (RANK-based tracking) - HIGHEST PRIORITY
  local isProbationary = isMemberInProbationaryRank(guildId, displayName)
  
  if isProbationary then
    local actualJoinTime, source = getMemberJoinTime(guildId, displayName)
    
    table.insert(matchedFilters, {
      priority = 1,
      reason = SF.func._L("ScrollkeeperProvisionMember", "REASON_RANK"),
      joinTime = actualJoinTime
    })
    
    if force and DEBUG_FILTERS then
      local daysSinceJoin = actualJoinTime and math.floor((GetTimeStamp() - actualJoinTime) / 86400) or "unknown"
      d(string.format("[PM Rank] %s is probationary (%s days since join)", displayName, tostring(daysSinceJoin)))
    end
  end

  -- FILTER 2: Gold donation filter (checks ALL members, not just probationary)
  if guildSettings.goldDonationFilter and guildSettings.goldDonationFilter.enabled then
    -- Check if data is ready
    if SF.Data and SF.Data.isReady and SF.Data.isReady() then
      local allEvents = SF.Data.getEvents(guildName, "bankedGold", 999999)
      if allEvents and #allEvents > 0 then
        -- Check history depth - be lenient, allow 90% of required days
        local oldestTimestamp = nil
        for _, event in ipairs(allEvents) do
          if not oldestTimestamp or event.timestamp < oldestTimestamp then
            oldestTimestamp = event.timestamp
          end
        end

        local leniency = 0.9
        local lenientHistoryTime = GetTimeStamp() - (guildSettings.goldDonationFilter.timePeriodDays * 86400 * leniency)

        if oldestTimestamp and oldestTimestamp <= lenientHistoryTime then
          local meetsRequirement, totalDonated = checkMemberDonations(
            guildId,
            guildName,
            displayName,
            guildSettings.goldDonationFilter.requiredAmount,
            guildSettings.goldDonationFilter.timePeriodDays,
            false
          )

          -- If they DON'T meet the requirement, track them for gold reasons
          if not meetsRequirement then
            table.insert(matchedFilters, {
              priority = 3,
              reason = SF.func._L("ScrollkeeperProvisionMember", "REASON_GOLD"),
              joinTime = nil
            })
          end
        end
      end
    end
  end

  -- FILTER 3: Inactivity filter (checks ALL members)
  if guildSettings.inactivityFilter and guildSettings.inactivityFilter.enabled then
    if force and DEBUG_FILTERS then
      d(string.format("[PM Inactive] === CHECKING %s ===", displayName))
    end

    local isInactive, daysSince = checkMemberInactivity(
      guildId,
      displayName,
      guildSettings.inactivityFilter.inactiveDays,
      false
    )

    if isInactive then
      if force and DEBUG_FILTERS then
        d(string.format("[PM Inactive] %s is INACTIVE (%d days) - TRACK", displayName, daysSince))
      end
      
      table.insert(matchedFilters, {
        priority = 4,
        reason = SF.func._L("ScrollkeeperProvisionMember", "REASON_INACTIVE"),
        joinTime = nil
      })
    else
      if force and DEBUG_FILTERS then
        d(string.format("[PM Inactive] %s is ACTIVE (%d days offline) - SKIP", displayName, daysSince))
      end
    end
  end

  -- FILTER 4: Donor filter (tracks members who MEET minimum to recognize them)
  if guildSettings.donorFilter and guildSettings.donorFilter.enabled then
    if force and DEBUG_FILTERS then
      d(string.format("[PM Donor] === CHECKING %s ===", displayName))
      d(string.format("[PM Donor] Filter enabled: minimum=%d gold, period=%d days",
        guildSettings.donorFilter.minimumAmount, guildSettings.donorFilter.timePeriodDays))
    end

    -- Check if data is ready
    if SF.Data and SF.Data.isReady and SF.Data.isReady() then
      local allEvents = SF.Data.getEvents(guildName, "bankedGold", 999999)
      if allEvents and #allEvents > 0 then
        -- Check history depth
        local oldestTimestamp = nil
        for _, event in ipairs(allEvents) do
          if not oldestTimestamp or event.timestamp < oldestTimestamp then
            oldestTimestamp = event.timestamp
          end
        end

        local leniency = 0.9
        local lenientHistoryTime = GetTimeStamp() - (guildSettings.donorFilter.timePeriodDays * 86400 * leniency)

        if oldestTimestamp and oldestTimestamp <= lenientHistoryTime then
          local meetsMinimum, totalDonated = checkMemberDonations(
            guildId,
            guildName,
            displayName,
            guildSettings.donorFilter.minimumAmount,
            guildSettings.donorFilter.timePeriodDays,
            false
          )

          if force and DEBUG_FILTERS then
            d(string.format("[PM Donor] Result: donated %d gold (minimum: %d) - %s",
              totalDonated, guildSettings.donorFilter.minimumAmount,
              meetsMinimum and "MEETS - TRACK" or "FAILS - SKIP"))
          end

          -- Track them if they DO meet the minimum
          if meetsMinimum then
            table.insert(matchedFilters, {
              priority = 2,
              reason = SF.func._L("ScrollkeeperProvisionMember", "REASON_DONOR"),
              joinTime = nil
            })
          end
        end
      end
    end
  end

  -- Now decide which filter to use based on priority
  -- Priority order: 1=Rank (highest), 2=Donor, 3=Gold, 4=Inactive (lowest)
  if #matchedFilters > 0 then
    -- Sort by priority (lower number = higher priority)
    table.sort(matchedFilters, function(a, b) return a.priority < b.priority end)
    
    local winner = matchedFilters[1]
    
    -- Check if already tracked with this reason (avoid unnecessary updates)
    if memberData and memberData.reason == winner.reason then
      return false, nil, nil
    end
    
    return true, winner.reason, winner.joinTime
  end

  -- No filters matched
  return false, nil, nil
end

-- Re-evaluate existing tracked members against current data
function PM.reEvaluateMembers(guildName)
  local settings = getSettings()
  if not settings or not settings.taggedMembers then return 0 end

  local guildMembers = settings.taggedMembers[guildName] or {}
  local toRemove = {}
  local reEvaluatedCount = 0

  -- Find the guild ID
  local guildId = nil
  for i = 1, GetNumGuilds() do
    if GetGuildName(GetGuildId(i)) == guildName then
      guildId = GetGuildId(i)
      break
    end
  end

  if not guildId then return 0 end

  for memberName, data in pairs(guildMembers) do
    if data and type(data) == "table" and data.status ~= SF.func._L("ScrollkeeperProvisionMember", "STATUS_PROMOTED") then
      -- If they're tracked for gold reasons, re-check their donation status
      if data.reason == SF.func._L("ScrollkeeperProvisionMember", "REASON_GOLD") then
        local guildSettings = getGuildSettings(guildName)
        if guildSettings and guildSettings.goldDonationFilter and guildSettings.goldDonationFilter.enabled then
          local meetsRequirement = checkMemberDonations(
            guildId,
            guildName,
            memberName,
            guildSettings.goldDonationFilter.requiredAmount,
            guildSettings.goldDonationFilter.timePeriodDays
            -- debugMode defaults to false (nil)
          )

          if meetsRequirement then
            -- They now meet the requirement - remove them
            table.insert(toRemove, memberName)
            reEvaluatedCount = reEvaluatedCount + 1
          end
        end
      end
    end
  end

  -- Remove members who now meet requirements
  for _, memberName in ipairs(toRemove) do
    PM.removeMember(guildName, memberName, "Met gold requirement")
  end

  return reEvaluatedCount
end

-- Create a dedicated function to calculate accurate days since join
local function getAccurateDaysSinceJoin(guildId, guildName, memberName, storedData)
  local now = GetTimeStamp()

  -- 1. Check Advanced Member Tooltip first (most reliable)
  if AMT_Available and AMT.savedData and AMT.savedData[guildName] then
    local memberKey = string.lower(memberName)
    local amtMemberData = AMT.savedData[guildName][memberKey]

    if amtMemberData and amtMemberData.timeJoined and amtMemberData.timeJoined > 0 then
      local daysSince = math.floor((now - amtMemberData.timeJoined) / 86400)
      if daysSince >= 0 and daysSince <= 3650 then -- 10 year sanity check
        -- Update our stored data with AMT's accurate time
        storedData.actualJoinTime = amtMemberData.timeJoined
        return daysSince, SF.func._L("ScrollkeeperProvisionMember", "SOURCE_AMT")
      end
    end
  end

  -- 2. Check if we have validated stored time
  if storedData.actualJoinTime and storedData.actualJoinTime > 0 then
    local daysSince = math.floor((now - storedData.actualJoinTime) / 86400)
    if daysSince >= 0 and daysSince <= 3650 then
      return daysSince, SF.func._L("ScrollkeeperProvisionMember", "SOURCE_STORED")
    end
  end

  -- 3. Try LibHistoire
  if LibHistoire and histoireReady then
    local guildData = LibHistoire:GetGuildHistoryProcessor(guildId)
    if guildData and guildData.GetMemberJoinTime then
      local success, joinTime = pcall(guildData.GetMemberJoinTime, guildData, memberName)
      if success and joinTime and joinTime > 0 then
        local daysSince = math.floor((now - joinTime) / 86400)
        if daysSince >= 0 and daysSince <= 3650 then
          storedData.actualJoinTime = joinTime
          return daysSince, SF.func._L("ScrollkeeperProvisionMember", "SOURCE_HISTOIRE")
        end
      end
    end
  end

  -- 4. Try ScrollkeeperData donation timing
  if SF.Data and SF.Data.getMemberDonationInfo then
    local donationData = SF.Data.getMemberDonationInfo(guildName, memberName)
    if donationData and donationData.firstDonationTime and donationData.firstDonationTime > 0 then
      local daysSince = math.floor((now - donationData.firstDonationTime) / 86400)
      if daysSince >= 0 and daysSince <= 3650 then
        storedData.actualJoinTime = donationData.firstDonationTime
        return daysSince, SF.func._L("ScrollkeeperProvisionMember", "SOURCE_DONATION")
      end
    end
  end

  -- 5. Use tagged time as last resort
  if storedData.joinDate then
    local daysSince = math.floor((now - storedData.joinDate) / 86400)
    if daysSince >= 0 and daysSince <= 3650 then
      return daysSince, SF.func._L("ScrollkeeperProvisionMember", "SOURCE_TAGGED")
    end
  end

  -- Complete unknown
  return nil, SF.func._L("ScrollkeeperProvisionMember", "SOURCE_UNKNOWN")
end

-- Clear existing bad data function
function PM.clearBadData()
  local settings = getSettings()
  if not settings or not settings.taggedMembers then return 0 end

  local clearedCount = 0
  for guildName, members in pairs(settings.taggedMembers) do
    if members and type(members) == "table" then
      local toRemove = {}
      for memberName, data in pairs(members) do
        if data and type(data) == "table" and data.status ~= SF.func._L("ScrollkeeperProvisionMember", "STATUS_PROMOTED") then
          -- Find the guild ID for this guild name
          local guildId = nil
          for i = 1, GetNumGuilds() do
            if GetGuildName(GetGuildId(i)) == guildName then
              guildId = GetGuildId(i)
              break
            end
          end

          if guildId then
            local shouldTrack, reason, actualJoinTime = shouldTrackMember(guildId, guildName, displayName, force)
            if not shouldTrack then
              table.insert(toRemove, memberName)
              clearedCount = clearedCount + 1
            end
          else
            table.insert(toRemove, memberName)
            clearedCount = clearedCount + 1
          end
        end
      end

      for _, memberName in ipairs(toRemove) do
        members[memberName] = nil
      end
    end
  end

  return clearedCount
end

-- Clear only gold-based processed members (allow re-evaluation)
function PM.clearGoldProcessed()
  local settings = getSettings()
  if not settings or not settings.processedMembers then return 0 end

  local clearedCount = 0
  for guildName, members in pairs(settings.processedMembers) do
    if members and type(members) == "table" then
      local toRemove = {}
      for memberName, data in pairs(members) do
        if type(data) == "table" and data.reason == SF.func._L("ScrollkeeperProvisionMember", "REASON_GOLD") then
          table.insert(toRemove, memberName)
          clearedCount = clearedCount + 1
        end
      end

      for _, memberName in ipairs(toRemove) do
        members[memberName] = nil
      end
    end
  end

  return clearedCount
end

-- Scan for new members
local function scanForNewMembers(guildId, force)
  if not guildId then return {} end

  local settings = getSettings()
  if not settings or not settings.enabled then return {} end

  local guildName = GetGuildName(guildId)
  if not guildName then return {} end

  local guildSettings = getGuildSettings(guildName)
  if not guildSettings or not guildSettings.enabled then
    return {}
  end

  local newMembers = {}

  -- Scan current roster
  for i = 1, GetNumGuildMembers(guildId) do
    local displayName = GetGuildMemberInfo(guildId, i)
    if displayName and displayName ~= "" then
      local shouldTrack, reason, actualJoinTime = shouldTrackMember(guildId, guildName, displayName, true)  -- Force re-evaluation
      if shouldTrack then
        table.insert(newMembers, displayName)
        
        if guildSettings.autoTag then
          PM.tagMemberAsProvisional(guildName, displayName, SF.func._L("ScrollkeeperProvisionMember", "AUTO_TAG_SCAN"), reason, actualJoinTime)
        end
      end
    end
  end

  return newMembers
end

-- Initialize LibHistoire integration
local function initializeLibHistoire()
  if LibHistoire then
    LibHistoire:RegisterCallback("OnHistoireReady", function()
      histoireReady = true
      d(SF.func._L("ScrollkeeperProvisionMember", "SUCCESS_HISTOIRE_READY"))
    end)
  end
end

-- Event handlers
function _addon.guildMemberAdded(_, guildId, accountName)
  local settings = getSettings()
  if not settings or not settings.enabled then return end

  local guildName = GetGuildName(guildId)
  if not guildName then return end

  local guildSettings = getGuildSettings(guildName)
  if not guildSettings or not guildSettings.enabled then return end

  -- Check if we should track this member
  local shouldTrack, reason, actualJoinTime = shouldTrackMember(guildId, guildName, accountName)
  if shouldTrack then
    local joinTime = GetTimeStamp() -- For new joins, use current time
    if guildSettings.autoTag then
      PM.tagMemberAsProvisional(guildName, accountName, SF.func._L("ScrollkeeperProvisionMember", "AUTO_TAG_ONLINE"), reason, joinTime)
    end
    
    -- NO notification here - users will see updates when they open the provision window or run manual scans
  end
end

-- Event management
function _addon:EnableEvents()
  EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_GUILD_MEMBER_ADDED, _addon.guildMemberAdded)
  initializeLibHistoire()
  -- NO automatic scanning - user must manually scan from the window
end

function _addon:DisableEvents()
  EVENT_MANAGER:UnregisterForEvent(_addon.Name, EVENT_GUILD_MEMBER_ADDED)
end

-- Manual scan function
function PM.manualScan()
  -- Check if data is ready
  if not SF.Data or not SF.Data.isReady or not SF.Data.isReady() then
    d("[ProvisionMember] ERROR: Guild history data not ready yet. Wait a moment and try again.")
    return
  end

  -- Re-evaluate existing gold-tracked members
  local reEvaluatedTotal = 0
  for i = 1, GetNumGuilds() do
    local guildName = GetGuildName(GetGuildId(i))
    if guildName then
      reEvaluatedTotal = reEvaluatedTotal + PM.reEvaluateMembers(guildName)
    end
  end

  -- Clear bad data
  local clearedCount = PM.clearBadData()

  -- Scan for new members (force=false to disable debug spam)
  local totalNewMembers = 0
  for i = 1, GetNumGuilds() do
    local guildId = GetGuildId(i)
    local newMembers = scanForNewMembers(guildId, false) -- Don't spam debug
    totalNewMembers = totalNewMembers + #newMembers
  end

  -- Single completion message
  d(string.format(SF.func._L("ScrollkeeperProvisionMember", "LOG_SCAN_COMPLETE"), clearedCount, totalNewMembers))

  if reEvaluatedTotal > 0 then
    d(string.format("[ProvisionMember] Re-evaluated: %d members now meet requirements", reEvaluatedTotal))
  end
end

-- Get provisional member report
function PM.getProvisionalReport(guildName)
  if not guildName then return { totalTracked = 0, withinProbation = 0, overdue = 0, recent = {}, promoted = 0 } end
  local settings = getSettings()
  if not settings or not settings.taggedMembers then return { totalTracked = 0, withinProbation = 0, overdue = 0, recent = {}, promoted = 0 } end
  local guildMembers = settings.taggedMembers[guildName] or {}
  local guildSettings = getGuildSettings(guildName)

  local report = {
    totalTracked = 0,
    withinProbation = 0,
    overdue = 0,
    recent = {},
    promoted = 0
  }

  local now = GetTimeStamp()
  local dayInSeconds = 86400
  local maxDays = guildSettings.trackingDays or 30

  for memberName, data in pairs(guildMembers) do
    if data and type(data) == "table" then
      report.totalTracked = report.totalTracked + 1

      if data.status == SF.func._L("ScrollkeeperProvisionMember", "STATUS_PROMOTED") then
        report.promoted = report.promoted + 1
      else
        -- Use actual join time if available, otherwise use tagged time
        local referenceTime = data.actualJoinTime or data.joinDate or now
        local daysSinceJoin = (now - referenceTime) / dayInSeconds

        if daysSinceJoin <= maxDays then
          report.withinProbation = report.withinProbation + 1

          if daysSinceJoin <= 7 then
            table.insert(report.recent, {
              name = memberName,
              daysSince = math.floor(daysSinceJoin),
              status = data.status or SF.func._L("ScrollkeeperProvisionMember", "STATUS_PROVISIONAL"),
              notes = data.notes or ""
            })
          end
        else
          report.overdue = report.overdue + 1
        end
      end
    end
  end

  return report
end

-- Get all tracked guilds
function PM.getTrackedGuilds()
  local trackedGuilds = {}

  for i = 1, GetNumGuilds() do
    local guildName = GetGuildName(GetGuildId(i))
    if guildName then
      local guildSettings = getGuildSettings(guildName)
      if guildSettings and guildSettings.enabled then
        table.insert(trackedGuilds, guildName)
      end
    end
  end

  return trackedGuilds
end

-- Export only filtered members based on current view
function PM.exportMembers(guildName, activeFilter, viewingHighlighted, highlightedMembers)
  local settings = getSettings()
  if not settings or not settings.taggedMembers then
    return SF.func._L("ScrollkeeperProvisionMember", "STATUS_NO_DATA")
  end
  local guildMembers = settings.taggedMembers[guildName] or {}

  local exportText = string.format(SF.func._L("ScrollkeeperProvisionMember", "EXPORT_REPORT_HEADER"), guildName or "All Guilds") .. "\n"
  exportText = exportText .. string.format(SF.func._L("ScrollkeeperProvisionMember", "EXPORT_GENERATED"), os.date("%Y-%m-%d %H:%M:%S", GetTimeStamp())) .. "\n"

  if activeFilter then
    local filterName = activeFilter == "all" and SF.func._L("ScrollkeeperProvisionMember", "EXPORT_FILTER_ALL") or
                      activeFilter == "rank" and SF.func._L("ScrollkeeperProvisionMember", "EXPORT_FILTER_RANK") or
                      activeFilter == "gold" and SF.func._L("ScrollkeeperProvisionMember", "EXPORT_FILTER_GOLD") or
                      activeFilter == "inactive" and SF.func._L("ScrollkeeperProvisionMember", "EXPORT_FILTER_INACTIVE") or
                      activeFilter == "donor" and SF.func._L("ScrollkeeperProvisionMember", "EXPORT_FILTER_DONOR") or
                      SF.func._L("ScrollkeeperProvisionMember", "EXPORT_FILTER_CUSTOM")
    exportText = exportText .. string.format(SF.func._L("ScrollkeeperProvisionMember", "EXPORT_FILTER"), filterName) .. "\n"
  end

  if viewingHighlighted then
    exportText = exportText .. SF.func._L("ScrollkeeperProvisionMember", "EXPORT_VIEW_SELECTED") .. "\n"
  end

  exportText = exportText .. "\n"

  if guildName then
    local exportCount = 0

    for memberName, data in pairs(guildMembers) do
      if data and type(data) == "table" then
        local shouldExport = false

        -- Apply same filtering logic as the display
        if viewingHighlighted then
          shouldExport = highlightedMembers and highlightedMembers[memberName] == true
        else
          if not activeFilter or activeFilter == "all" or
             (activeFilter == "rank" and (data.reason == SF.func._L("ScrollkeeperProvisionMember", "REASON_RANK") or not data.reason)) or
             (activeFilter == "gold" and data.reason == SF.func._L("ScrollkeeperProvisionMember", "REASON_GOLD")) or
             (activeFilter == "inactive" and data.reason == SF.func._L("ScrollkeeperProvisionMember", "REASON_INACTIVE")) or
             (activeFilter == "donor" and data.reason == SF.func._L("ScrollkeeperProvisionMember", "REASON_DONOR")) then
            shouldExport = true
          end
        end

        if shouldExport then
          local referenceTime = data.actualJoinTime or data.joinDate or GetTimeStamp()
          local daysSince = math.floor((GetTimeStamp() - referenceTime) / 86400)
          local reason = data.reason or SF.func._L("ScrollkeeperProvisionMember", "REASON_RANK")
          local joinType = data.actualJoinTime and SF.func._L("ScrollkeeperProvisionMember", "EXPORT_DAYS_ACTUAL") or SF.func._L("ScrollkeeperProvisionMember", "EXPORT_DAYS_ESTIMATED")

          -- Only show days for rank members
          local daysText = reason == SF.func._L("ScrollkeeperProvisionMember", "REASON_RANK") and
                          string.format(SF.func._L("ScrollkeeperProvisionMember", "EXPORT_DAYS_FORMAT"), daysSince, joinType) or
                          SF.func._L("ScrollkeeperProvisionMember", "EXPORT_DAYS_NA")

          exportText = exportText .. string.format(SF.func._L("ScrollkeeperProvisionMember", "EXPORT_FORMAT"),
            memberName, data.status or SF.func._L("ScrollkeeperProvisionMember", "STATUS_PROVISIONAL"), daysText, reason, data.notes or "") .. "\n"
          exportCount = exportCount + 1
        end
      end
    end

    if exportCount == 0 then
      exportText = exportText .. SF.func._L("ScrollkeeperProvisionMember", "STATUS_NO_FILTER_MATCH") .. "\n"
    end
  end

  return exportText
end

-- Create export text window
local function createExportWindow(exportText)
  local windowName = "ScrollkeeperProvision_ExportWindow"

  local existingWindow = GetControl(windowName)
  if existingWindow then
    existingWindow:SetHidden(false)
    -- Update text content
    local textControl = existingWindow.textArea
    if textControl then
      textControl:SetText(exportText)
      zo_callLater(function()
        textControl:SelectAll()
        textControl:TakeFocus()
      end, 100)
    end
    return existingWindow
  end

  local window = WINDOW_MANAGER:CreateTopLevelWindow(windowName)
  window:SetDimensions(800, 600)
  window:SetAnchor(CENTER, GuiRoot, CENTER, 100, 0) -- Offset from main window
  window:SetMovable(true)
  window:SetMouseEnabled(true)
  window:SetClampedToScreen(true)
  window:SetHidden(false)

  -- Background
  local bg = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
  bg:SetAnchorFill()
  bg:SetCenterColor(0.1, 0.1, 0.1, 0.95)
  bg:SetEdgeColor(0.4, 0.4, 0.4, 1)
  bg:SetEdgeTexture("", 2, 2, 1)

  -- Title bar
  local titleBar = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
  titleBar:SetDimensions(800, 35)
  titleBar:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 0)
  titleBar:SetCenterColor(0.2, 0.2, 0.3, 1)
  titleBar:SetEdgeColor(0.4, 0.4, 0.4, 1)
  titleBar:SetEdgeTexture("", 1, 1, 0)

  local title = WINDOW_MANAGER:CreateControl(nil, titleBar, CT_LABEL)
  title:SetFont("$(PROSE_ANTIQUE_FONT)|22|soft-shadow-thin")
  title:SetText(SF.func._L("ScrollkeeperProvisionMember", "EXPORT_TITLE"))
  title:SetAnchor(LEFT, titleBar, LEFT, 10, 0)
  title:SetColor(1, 1, 1, 1)

  local closeBtn = WINDOW_MANAGER:CreateControl(nil, titleBar, CT_BUTTON)
  closeBtn:SetDimensions(25, 25)
  closeBtn:SetAnchor(RIGHT, titleBar, RIGHT, -10, 0)
  closeBtn:SetNormalTexture("/esoui/art/buttons/decline_up.dds")
  closeBtn:SetHandler("OnClicked", function() window:SetHidden(true) end)

  -- Create proper editable text area
  local textArea = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
  textArea:SetDimensions(780, 480)
  textArea:SetAnchor(TOPLEFT, window, TOPLEFT, 10, 45)
  textArea:SetCenterColor(0.05, 0.05, 0.05, 1)
  textArea:SetEdgeColor(0.3, 0.3, 0.3, 1)
  textArea:SetEdgeTexture("", 1, 1, 0)

  -- Create basic EditBox
  local editBox = WINDOW_MANAGER:CreateControl(nil, textArea, CT_EDITBOX)
  editBox:SetAnchor(TOPLEFT, textArea, TOPLEFT, 5, 5)
  editBox:SetAnchor(BOTTOMRIGHT, textArea, BOTTOMRIGHT, -5, -5)
  editBox:SetEditEnabled(true)
  editBox:SetMouseEnabled(true)
  editBox:SetMaxInputChars(100000)
  editBox:SetFont("ZoFontGameSmall")
  editBox:SetMultiLine(true)
  editBox:SetNewLineEnabled(true)

  editBox:SetText(exportText)

  window.textArea = editBox

  -- Select All button
  local selectAllBtn = WINDOW_MANAGER:CreateControl(nil, window, CT_BUTTON)
  selectAllBtn:SetDimensions(100, 30)
  selectAllBtn:SetAnchor(BOTTOM, window, BOTTOM, 0, -40)
  selectAllBtn:SetNormalTexture("EsoUI/Art/Buttons/button_up.dds")
  selectAllBtn:SetPressedTexture("EsoUI/Art/Buttons/button_down.dds")
  selectAllBtn:SetMouseOverTexture("EsoUI/Art/Buttons/button_over.dds")

  local selectAllLabel = WINDOW_MANAGER:CreateControl(nil, selectAllBtn, CT_LABEL)
  selectAllLabel:SetFont("$(PROSE_ANTIQUE_FONT)|19")
  selectAllLabel:SetText(SF.func._L("ScrollkeeperProvisionMember", "BTN_SELECT_ALL"))
  selectAllLabel:SetAnchor(CENTER, selectAllBtn, CENTER, 0, 0)
  selectAllLabel:SetColor(1, 1, 1, 1)

  selectAllBtn:SetHandler("OnClicked", function()
    editBox:SelectAll()
    editBox:TakeFocus()
  end)

  -- Instructions
  local instruction = WINDOW_MANAGER:CreateControl(nil, window, CT_LABEL)
  instruction:SetFont("ZoFontGame")
  instruction:SetText(SF.func._L("ScrollkeeperProvisionMember", "EXPORT_INSTRUCTION"))
  instruction:SetAnchor(BOTTOMLEFT, window, BOTTOMLEFT, 10, -10)
  instruction:SetColor(0.8, 0.8, 0.8, 1)

  -- Auto-focus after creation
  zo_callLater(function()
    editBox:SelectAll()
    editBox:TakeFocus()
  end, 100)

  -- Theme the export window
  window.titleBar = titleBar
  window.titleText = title
  window.updateTheme = function()
    if SF and SF.applyThemeToTitleBar then
      SF.applyThemeToTitleBar(window.titleBar, window.titleText)
    end
  end

  if SF and SF.registerThemedWindow then
    SF.registerThemedWindow("ScrollkeeperProvision_ExportWindow", window.updateTheme)
  end

  zo_callLater(function()
    if window.updateTheme then window.updateTheme() end
  end, 100)

  return window
end

-- LibScroll integration for smooth scrolling
local function setupSmoothScroll(scrollControl, scrollBar, contentHeight, visibleHeight, updateFunc, window)
  if not scrollControl or not scrollBar or not updateFunc or not window then return end
  
  -- Check if LibScroll is available (uses module-level variable)
  if not libScroll or type(libScroll.SetScrollBar) ~= "function" then
    -- d() call removed - already logged during initialization
    -- Fallback to basic mousewheel if LibScroll unavailable
    scrollControl:SetHandler("OnMouseWheel", function(self, delta)
      if not scrollBar:IsHidden() then
        local min, max = scrollBar:GetMinMax()
        local current = scrollBar:GetValue()
        local newValue = zo_clamp(current - (delta * 3), min, max)
        if newValue ~= current then
          scrollBar:SetValue(newValue)
          window.scrollOffset = math.floor(newValue)
          updateFunc(window)
        end
      end
    end)
    return
  end
  
  -- Use LibScroll for smooth scrolling
  libScroll:SetScrollBar(scrollControl, scrollBar)
  
  -- Update content dimensions
  local function updateScrollable()
    local memberList = {}
    local settings = getSettings()
    if not settings or not settings.taggedMembers or not window.selectedGuild then 
      libScroll:SetScrollableSize(scrollControl, 0)
      return 
    end
    
    local guildMembers = settings.taggedMembers[window.selectedGuild] or {}
    for memberName, data in pairs(guildMembers) do
      if data and type(data) == "table" then
        local shouldInclude = false
        if window.viewingHighlighted then
          shouldInclude = window.highlightedMembers[memberName] == true
        else
          if window.activeFilter == "all" then
            shouldInclude = (data.status ~= SF.func._L("ScrollkeeperProvisionMember", "STATUS_PROMOTED"))
          elseif window.activeFilter == "rank" then
            shouldInclude = (data.reason == SF.func._L("ScrollkeeperProvisionMember", "REASON_RANK") or not data.reason)
          elseif window.activeFilter == "gold" then
            shouldInclude = (data.reason == SF.func._L("ScrollkeeperProvisionMember", "REASON_GOLD"))
          elseif window.activeFilter == "inactive" then
            shouldInclude = (data.reason == SF.func._L("ScrollkeeperProvisionMember", "REASON_INACTIVE"))
          elseif window.activeFilter == "donor" then
            shouldInclude = (data.reason == SF.func._L("ScrollkeeperProvisionMember", "REASON_DONOR"))
          end
        end
        if shouldInclude then
          table.insert(memberList, {name = memberName, data = data})
        end
      end
    end
    
    local totalRows = #memberList
    local rowHeight = 35
    local actualContentHeight = totalRows * rowHeight
    
    libScroll:SetScrollableSize(scrollControl, actualContentHeight)
  end
  
  -- Register scroll callback
  libScroll:SetScrollCallback(scrollControl, function(offset)
    local rowHeight = 35
    window.scrollOffset = math.floor(offset / rowHeight)
    updateFunc(window)
  end)
  
  -- Store update function on window for external use
  window.updateScrollable = updateScrollable
  
  -- Initial update
  updateScrollable()
end

-- Create provisional member management window
local function createProvisionWindow()
  local windowName = "ScrollkeeperProvision_Window"

  local existingWindow = GetControl(windowName)
  if existingWindow then
    return existingWindow
  end

  local window = WINDOW_MANAGER:CreateTopLevelWindow(windowName)
  window:SetDimensions(1000, 750)
  window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
  window:SetMovable(true)
  window:SetMouseEnabled(true)
  window:SetClampedToScreen(true)
  window:SetHidden(true)

-- Initialize window variables
  window.selectedGuild = nil
  window.activeFilter = "all"
  window.memberRows = {}
  window.highlightedMembers = {}
  window.viewingHighlighted = false
  window.sortColumn = "days"
  window.sortDirection = "asc"

  -- Background and title bar
  local bg = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
  bg:SetAnchorFill()
  bg:SetCenterColor(0.1, 0.1, 0.1, 0.95)
  bg:SetEdgeColor(0.4, 0.4, 0.4, 1)
  bg:SetEdgeTexture("", 2, 2, 1)

  -- Title bar
  local titleBar = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
  titleBar:SetDimensions(1000, 35)
  titleBar:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 0)
  titleBar:SetCenterColor(0.2, 0.2, 0.3, 1)
  titleBar:SetEdgeColor(0.4, 0.4, 0.4, 1)
  titleBar:SetEdgeTexture("", 1, 1, 0)

  local title = WINDOW_MANAGER:CreateControl(nil, titleBar, CT_LABEL)
  title:SetFont("$(PROSE_ANTIQUE_FONT)|22|soft-shadow-thin")
  title:SetText(SF.func._L("ScrollkeeperProvisionMember", "WINDOW_TITLE"))
  title:SetAnchor(LEFT, titleBar, LEFT, 10, 0)
  title:SetColor(1, 1, 1, 1)

  local closeBtn = WINDOW_MANAGER:CreateControl(nil, titleBar, CT_BUTTON)
  closeBtn:SetDimensions(25, 25)
  closeBtn:SetAnchor(RIGHT, titleBar, RIGHT, -10, 0)
  closeBtn:SetNormalTexture("/esoui/art/buttons/decline_up.dds")
  closeBtn:SetHandler("OnClicked", function() window:SetHidden(true) end)

  -- Guild selection dropdown
  local guildLabel = WINDOW_MANAGER:CreateControl(nil, window, CT_LABEL)
  guildLabel:SetFont("$(PROSE_ANTIQUE_FONT)|18")
  guildLabel:SetText(SF.func._L("ScrollkeeperProvisionMember", "SELECT_GUILD"))
  guildLabel:SetAnchor(TOPLEFT, window, TOPLEFT, 20, 50)
  guildLabel:SetColor(1, 1, 1, 1)

  local guildDropdown = WINDOW_MANAGER:CreateControlFromVirtual(nil, window, "ZO_ComboBox")
  guildDropdown:SetDimensions(300, 30)
  guildDropdown:SetAnchor(TOPLEFT, guildLabel, TOPRIGHT, 10, -5)

  local guildCombo = ZO_ComboBox_ObjectFromContainer(guildDropdown)
  guildCombo:SetSortsItems(false)
  guildCombo:SetFont("ZoFontGame")

  -- Filter buttons
  local filterLabel = WINDOW_MANAGER:CreateControl(nil, window, CT_LABEL)
  filterLabel:SetFont("$(PROSE_ANTIQUE_FONT)|18")
  filterLabel:SetText(SF.func._L("ScrollkeeperProvisionMember", "FILTER_LABEL"))
  filterLabel:SetAnchor(LEFT, guildDropdown, RIGHT, 20, 5)
  filterLabel:SetColor(1, 1, 1, 1)

  -- All members filter button
  local allBtn = WINDOW_MANAGER:CreateControl(nil, window, CT_BUTTON)
  allBtn:SetDimensions(40, 40)
  allBtn:SetAnchor(LEFT, filterLabel, RIGHT, 10, -2)

  -- Background for all button
  local allBg = WINDOW_MANAGER:CreateControl(nil, allBtn, CT_BACKDROP)
  allBg:SetAnchorFill()
  allBg:SetCenterColor(0.3, 0.3, 0.4, 1) -- Darker background for active state
  allBg:SetEdgeColor(0.3, 0.3, 0.4, 1)
  allBg:SetEdgeTexture("", 2, 2, 1)

  local allLabel = WINDOW_MANAGER:CreateControl(nil, allBtn, CT_LABEL)
  allLabel:SetAnchor(CENTER, allBtn, CENTER, 0, 0)
  allLabel:SetFont("ZoFontGameBold")
  allLabel:SetText(SF.func._L("ScrollkeeperProvisionMember", "FILTER_ALL"))
  allLabel:SetColor(1, 1, 1, 1)

  -- Probation filter button
  local probationBtn = WINDOW_MANAGER:CreateControl(nil, window, CT_BUTTON)
  probationBtn:SetDimensions(40, 40)
  probationBtn:SetAnchor(LEFT, allBtn, RIGHT, 10, 0)

  local probationBg = WINDOW_MANAGER:CreateControl(nil, probationBtn, CT_BACKDROP)
  probationBg:SetAnchorFill()
  probationBg:SetCenterColor(0.1, 0.1, 0.2, 1) -- Inactive state
  probationBg:SetEdgeColor(0.3, 0.3, 0.3, 1)
  probationBg:SetEdgeTexture("", 2, 2, 1)

  local probationIcon = WINDOW_MANAGER:CreateControl(nil, probationBtn, CT_TEXTURE)
  probationIcon:SetDimensions(24, 24)
  probationIcon:SetAnchor(CENTER, probationBtn, CENTER, 0, 0)
  probationIcon:SetTexture("/esoui/art/guild/tabicon_roster_up.dds")

  -- Add tooltip for probation button
  probationBtn:SetHandler("OnMouseEnter", function(self)
    InitializeTooltip(InformationTooltip, self, TOPLEFT, 0, 0)
    SetTooltipText(InformationTooltip, SF.func._L("ScrollkeeperProvisionMember", "FILTER_PROBATION_ICON_TIP"))
  end)
  probationBtn:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)

  -- Gold filter button
  local goldBtn = WINDOW_MANAGER:CreateControl(nil, window, CT_BUTTON)
  goldBtn:SetDimensions(40, 40)
  goldBtn:SetAnchor(LEFT, probationBtn, RIGHT, 10, 0)

  local goldBg = WINDOW_MANAGER:CreateControl(nil, goldBtn, CT_BACKDROP)
  goldBg:SetAnchorFill()
  goldBg:SetCenterColor(0.1, 0.1, 0.2, 1) -- Inactive state
  goldBg:SetEdgeColor(0.3, 0.3, 0.3, 1)
  goldBg:SetEdgeTexture("", 2, 2, 1)

  local goldIcon = WINDOW_MANAGER:CreateControl(nil, goldBtn, CT_TEXTURE)
  goldIcon:SetDimensions(24, 24)
  goldIcon:SetAnchor(CENTER, goldBtn, CENTER, 0, 0)
  goldIcon:SetTexture("/esoui/art/currency/currency_gold.dds")
  goldIcon:SetColor(1, 0.8, 0.2, 1)

  -- Add tooltip for gold button
  goldBtn:SetHandler("OnMouseEnter", function(self)
    InitializeTooltip(InformationTooltip, self, TOPLEFT, 0, 0)
    SetTooltipText(InformationTooltip, SF.func._L("ScrollkeeperProvisionMember", "FILTER_GOLD_ICON_TIP"))
  end)
  goldBtn:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)

  -- Inactive filter button
  local inactiveBtn = WINDOW_MANAGER:CreateControl(nil, window, CT_BUTTON)
  inactiveBtn:SetDimensions(40, 40)
  inactiveBtn:SetAnchor(LEFT, goldBtn, RIGHT, 10, 0)

  local inactiveBg = WINDOW_MANAGER:CreateControl(nil, inactiveBtn, CT_BACKDROP)
  inactiveBg:SetAnchorFill()
  inactiveBg:SetCenterColor(0.1, 0.1, 0.2, 1)
  inactiveBg:SetEdgeColor(0.3, 0.3, 0.3, 1)
  inactiveBg:SetEdgeTexture("", 2, 2, 1)

  local inactiveIcon = WINDOW_MANAGER:CreateControl(nil, inactiveBtn, CT_TEXTURE)
  inactiveIcon:SetDimensions(24, 24)
  inactiveIcon:SetAnchor(CENTER, inactiveBtn, CENTER, 0, 0)
  inactiveIcon:SetTexture("/esoui/art/tutorial/timer_icon.dds")
  inactiveIcon:SetColor(0.6, 0.6, 0.6, 1)

  inactiveBtn:SetHandler("OnMouseEnter", function(self)
    InitializeTooltip(InformationTooltip, self, TOPLEFT, 0, 0)
    SetTooltipText(InformationTooltip, SF.func._L("ScrollkeeperProvisionMember", "FILTER_INACTIVE_TIP"))
  end)
  inactiveBtn:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)

  -- Donor filter button
  local donorBtn = WINDOW_MANAGER:CreateControl(nil, window, CT_BUTTON)
  donorBtn:SetDimensions(40, 40)
  donorBtn:SetAnchor(LEFT, inactiveBtn, RIGHT, 10, 0)

  local donorBg = WINDOW_MANAGER:CreateControl(nil, donorBtn, CT_BACKDROP)
  donorBg:SetAnchorFill()
  donorBg:SetCenterColor(0.1, 0.1, 0.2, 1)
  donorBg:SetEdgeColor(0.3, 0.3, 0.3, 1)
  donorBg:SetEdgeTexture("", 2, 2, 1)

  local donorIcon = WINDOW_MANAGER:CreateControl(nil, donorBtn, CT_TEXTURE)
  donorIcon:SetDimensions(24, 24)
  donorIcon:SetAnchor(CENTER, donorBtn, CENTER, 0, 0)
  donorIcon:SetTexture("/esoui/art/icons/servicemappins/servicepin_bank.dds")

  donorBtn:SetHandler("OnMouseEnter", function(self)
    InitializeTooltip(InformationTooltip, self, TOPLEFT, 0, 0)
    SetTooltipText(InformationTooltip, SF.func._L("ScrollkeeperProvisionMember", "FILTER_DONOR_TIP"))
  end)
  donorBtn:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)
  window.allBg = allBg
  window.probationBg = probationBg
  window.goldBg = goldBg
  window.inactiveBg = inactiveBg
  window.donorBg = donorBg

  -- Function to update filter button states with theme colors
  local function updateFilterStates()
    if not window then return end

    -- Get theme colors or use defaults
    local accentColor = {0.3, 0.3, 0.4, 1}
    local inactiveColor = {0.15, 0.15, 0.2, 1}
    local borderColor = {0.4, 0.4, 0.4, 1}

    if SF and SF.theme and SF.theme.colors then
      if SF.theme.colors.accent then
        accentColor = {SF.theme.colors.accent[1], SF.theme.colors.accent[2], SF.theme.colors.accent[3], 1}
      end
      if SF.theme.colors.border then
        borderColor = {SF.theme.colors.border[1], SF.theme.colors.border[2], SF.theme.colors.border[3], 1}
        inactiveColor = {borderColor[1] * 0.3, borderColor[2] * 0.3, borderColor[3] * 0.3, 1}
      end
    end

    -- Update all button states based on active filter
    local filters = {
      {name = "all", bg = window.allBg},
      {name = "rank", bg = window.probationBg},
      {name = "gold", bg = window.goldBg},
      {name = "inactive", bg = window.inactiveBg},
      {name = "donor", bg = window.donorBg}
    }

    for _, filter in ipairs(filters) do
      if filter.bg then
        if window.activeFilter == filter.name then
          filter.bg:SetCenterColor(accentColor[1], accentColor[2], accentColor[3], accentColor[4])
          filter.bg:SetEdgeColor(accentColor[1], accentColor[2], accentColor[3], 1)
        else
          filter.bg:SetCenterColor(inactiveColor[1], inactiveColor[2], inactiveColor[3], inactiveColor[4])
          filter.bg:SetEdgeColor(borderColor[1], borderColor[2], borderColor[3], 1)
        end
      end
    end
  end

  -- Store the function on window so it can be called elsewhere
  window.updateFilterStates = updateFilterStates

  -- Stats panel
  local statsPanel = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
  statsPanel:SetDimensions(960, 60)
  statsPanel:SetAnchor(TOPLEFT, window, TOPLEFT, 20, 90)
  statsPanel:SetCenterColor(0.05, 0.05, 0.05, 0.8)
  statsPanel:SetEdgeColor(1, 1, 1, 1)
  statsPanel:SetEdgeTexture("", 1, 1, 0)

  window.statsPanel = statsPanel
  local statsLabel = WINDOW_MANAGER:CreateControl(nil, statsPanel, CT_LABEL)
  statsLabel:SetFont("ZoFontGame")
  statsLabel:SetText(SF.func._L("ScrollkeeperProvisionMember", "STATUS_SELECT_GUILD"))
  statsLabel:SetAnchor(TOPLEFT, statsPanel, TOPLEFT, 10, 10)
  statsLabel:SetColor(1, 1, 1, 1)

  -- Member list area
  local listPanel = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
  listPanel:SetDimensions(960, 470)
  listPanel:SetAnchor(TOPLEFT, statsPanel, BOTTOMLEFT, 0, 10)
  listPanel:SetCenterColor(0.05, 0.05, 0.05, 0.8)

  -- Column headers
  local headerPanel = WINDOW_MANAGER:CreateControl(nil, listPanel, CT_BACKDROP)
  headerPanel:SetDimensions(940, 30)
  headerPanel:SetAnchor(TOPLEFT, listPanel, TOPLEFT, 10, 10)
  headerPanel:SetCenterColor(0.1, 0.1, 0.2, 1)
  headerPanel:SetEdgeColor(1, 1, 1, 1)
  headerPanel:SetEdgeTexture("", 1, 1, 0)

  -- Non-sortable headers
  local statusHeader = WINDOW_MANAGER:CreateControl(nil, headerPanel, CT_LABEL)
  statusHeader:SetFont("ZoFontGameBold")
  statusHeader:SetText(SF.func._L("ScrollkeeperProvisionMember", "STATUS"))
  statusHeader:SetAnchor(TOPLEFT, headerPanel, TOPLEFT, 420, 4)
  statusHeader:SetColor(1, 1, 1, 1)

  local notesHeader = WINDOW_MANAGER:CreateControl(nil, headerPanel, CT_LABEL)
  notesHeader:SetFont("ZoFontGameBold")
  notesHeader:SetText(SF.func._L("ScrollkeeperProvisionMember", "NOTES"))
  notesHeader:SetAnchor(TOPLEFT, headerPanel, TOPLEFT, 600, 4)
  notesHeader:SetColor(1, 1, 1, 1)

  local actionsHeader = WINDOW_MANAGER:CreateControl(nil, headerPanel, CT_LABEL)
  actionsHeader:SetFont("ZoFontGameBold")
  actionsHeader:SetText(SF.func._L("ScrollkeeperProvisionMember", "ACTIONS"))
  actionsHeader:SetAnchor(TOPLEFT, headerPanel, TOPLEFT, 800, 4)
  actionsHeader:SetColor(1, 1, 1, 1)

  -- Sortable Name header - needs to be a button for clicking
  local nameHeaderBtn = WINDOW_MANAGER:CreateControl(nil, headerPanel, CT_BUTTON)
  nameHeaderBtn:SetDimensions(200, 25)
  nameHeaderBtn:SetAnchor(TOPLEFT, headerPanel, TOPLEFT, 25, 4)
  nameHeaderBtn:SetMouseEnabled(true)

  local nameHeaderLabel = WINDOW_MANAGER:CreateControl(nil, nameHeaderBtn, CT_LABEL)
  nameHeaderLabel:SetFont("ZoFontGameBold")
  nameHeaderLabel:SetText(SF.func._L("ScrollkeeperProvisionMember", "MEMBER_NAME"))
  nameHeaderLabel:SetAnchor(LEFT, nameHeaderBtn, LEFT, 0, 0)
  nameHeaderLabel:SetColor(1, 1, 1, 1)

  local nameSortArrow = WINDOW_MANAGER:CreateControl(nil, nameHeaderBtn, CT_LABEL)
  nameSortArrow:SetFont("ZoFontGameBold")
  nameSortArrow:SetText("")
  nameSortArrow:SetAnchor(LEFT, nameHeaderLabel, RIGHT, 5, 0)
  nameSortArrow:SetColor(1, 1, 1, 1)

  -- Sortable Days header - needs to be a button for clicking
  local daysHeaderBtn = WINDOW_MANAGER:CreateControl(nil, headerPanel, CT_BUTTON)
  daysHeaderBtn:SetDimensions(60, 25)
  daysHeaderBtn:SetAnchor(TOPLEFT, headerPanel, TOPLEFT, 340, 4)
  daysHeaderBtn:SetMouseEnabled(true)

  local daysHeaderLabel = WINDOW_MANAGER:CreateControl(nil, daysHeaderBtn, CT_LABEL)
  daysHeaderLabel:SetFont("ZoFontGameBold")
  daysHeaderLabel:SetText(SF.func._L("ScrollkeeperProvisionMember", "DAYS"))
  daysHeaderLabel:SetAnchor(LEFT, daysHeaderBtn, LEFT, 0, 0)
  daysHeaderLabel:SetColor(1, 1, 1, 1)

  local daysSortArrow = WINDOW_MANAGER:CreateControl(nil, daysHeaderBtn, CT_LABEL)
  daysSortArrow:SetFont("ZoFontGameBold")
  daysSortArrow:SetText(ZO_SORT_ORDER_UP_ICON)
  daysSortArrow:SetAnchor(LEFT, daysHeaderLabel, RIGHT, 5, 0)
  daysSortArrow:SetColor(1, 1, 1, 1)

  -- Scrollable content area
  local scrollContainer = WINDOW_MANAGER:CreateControl(nil, listPanel, CT_CONTROL)
  scrollContainer:SetDimensions(940, 415)
  scrollContainer:SetAnchor(TOPLEFT, headerPanel, BOTTOMLEFT, 0, 5)
  scrollContainer:SetMouseEnabled(true)

  -- Scroll bar
  local scrollBar = WINDOW_MANAGER:CreateControl(nil, listPanel, CT_SLIDER)
  scrollBar:SetDimensions(16, 415)
  scrollBar:SetAnchor(TOPRIGHT, listPanel, TOPRIGHT, -5, 40)
  scrollBar:SetOrientation(ORIENTATION_VERTICAL)
  scrollBar:SetMinMax(0, 100)
  scrollBar:SetValue(0)
  scrollBar:SetThumbTexture("/esoui/art/miscellaneous/scrollbox_elevator.dds", "/esoui/art/miscellaneous/scrollbox_elevator_disabled.dds", nil, 8, 16)
  scrollBar:SetMouseEnabled(true)
  scrollBar:SetHidden(true)

  -- Button panel
  local buttonPanel = WINDOW_MANAGER:CreateControl(nil, window, CT_CONTROL)
  buttonPanel:SetDimensions(960, 90)
  buttonPanel:SetAnchor(BOTTOM, window, BOTTOM, 0, -30)

  -- Calculate centered positions for 6 buttons
  local buttonWidth = 35
  local buttonSpacing = 100
  local totalWidth = 6 * buttonWidth + 5 * buttonSpacing
  local startX = (960 - totalWidth) / 2

  -- Row 1: Main action buttons
  local refreshBtn = WINDOW_MANAGER:CreateControl(nil, buttonPanel, CT_BUTTON)
  refreshBtn:SetDimensions(buttonWidth, buttonWidth)
  refreshBtn:SetAnchor(TOPLEFT, buttonPanel, TOPLEFT, startX, 10)
  refreshBtn:SetNormalTexture("Scrollkeeper/ScrollkeeperFramework/textures/help_tabicon_feedback_up.dds")
  refreshBtn:SetPressedTexture("Scrollkeeper/ScrollkeeperFramework/textures/help_tabicon_feedback_down.dds")
  refreshBtn:SetMouseOverTexture("Scrollkeeper/ScrollkeeperFramework/textures/help_tabicon_feedback_over.dds")

  local refreshLabel = WINDOW_MANAGER:CreateControl(nil, buttonPanel, CT_LABEL)
  refreshLabel:SetAnchor(TOP, refreshBtn, BOTTOM, 0, 2)
  refreshLabel:SetFont("$(PROSE_ANTIQUE_FONT)|17")
  refreshLabel:SetText(SF.func._L("ScrollkeeperProvisionMember", "BTN_REFRESH"))
  refreshLabel:SetColor(1, 1, 1, 1)

  local exportBtn = WINDOW_MANAGER:CreateControl(nil, buttonPanel, CT_BUTTON)
  exportBtn:SetDimensions(buttonWidth, buttonWidth)
  exportBtn:SetAnchor(LEFT, refreshBtn, RIGHT, buttonSpacing, 0)
  exportBtn:SetNormalTexture("Scrollkeeper/ScrollkeeperFramework/textures/clipboard_up.dds")
  exportBtn:SetPressedTexture("Scrollkeeper/ScrollkeeperFramework/textures/clipboard_down.dds")
  exportBtn:SetMouseOverTexture("Scrollkeeper/ScrollkeeperFramework/textures/clipboard_over.dds")

  local exportLabel = WINDOW_MANAGER:CreateControl(nil, buttonPanel, CT_LABEL)
  exportLabel:SetAnchor(TOP, exportBtn, BOTTOM, 0, 2)
  exportLabel:SetFont("$(PROSE_ANTIQUE_FONT)|17")
  exportLabel:SetText(SF.func._L("ScrollkeeperProvisionMember", "BTN_EXPORT"))
  exportLabel:SetColor(1, 1, 1, 1)

  local scanBtn = WINDOW_MANAGER:CreateControl(nil, buttonPanel, CT_BUTTON)
  scanBtn:SetDimensions(buttonWidth, buttonWidth)
  scanBtn:SetAnchor(LEFT, exportBtn, RIGHT, buttonSpacing, 0)
  scanBtn:SetNormalTexture("Scrollkeeper/ScrollkeeperFramework/textures/campaign_tabicon_history_up.dds")
  scanBtn:SetPressedTexture("Scrollkeeper/ScrollkeeperFramework/textures/campaign_tabicon_history_down.dds")
  scanBtn:SetMouseOverTexture("Scrollkeeper/ScrollkeeperFramework/textures/campaign_tabicon_history_over.dds")

  local scanLabel = WINDOW_MANAGER:CreateControl(nil, buttonPanel, CT_LABEL)
  scanLabel:SetAnchor(TOP, scanBtn, BOTTOM, 0, 2)
  scanLabel:SetFont("$(PROSE_ANTIQUE_FONT)|17")
  scanLabel:SetText(SF.func._L("ScrollkeeperProvisionMember", "BTN_SCAN"))
  scanLabel:SetColor(1, 1, 1, 1)

  -- Row 2: Bulk operation buttons
  local highlightedBtn = WINDOW_MANAGER:CreateControl(nil, buttonPanel, CT_BUTTON)
  highlightedBtn:SetDimensions(buttonWidth, buttonWidth)
  highlightedBtn:SetAnchor(LEFT, scanBtn, RIGHT, buttonSpacing, 0)
  highlightedBtn:SetNormalTexture("/esoui/art/mainmenu/menubar_journal_up.dds")
  highlightedBtn:SetPressedTexture("/esoui/art/mainmenu/menubar_journal_down.dds")
  highlightedBtn:SetMouseOverTexture("/esoui/art/mainmenu/menubar_journal_over.dds")

  local highlightedLabel = WINDOW_MANAGER:CreateControl(nil, buttonPanel, CT_LABEL)
  highlightedLabel:SetAnchor(TOP, highlightedBtn, BOTTOM, 0, 2)
  highlightedLabel:SetFont("$(PROSE_ANTIQUE_FONT)|17")
  highlightedLabel:SetText(SF.func._L("ScrollkeeperProvisionMember", "BTN_VIEW_SELECTED"))
  highlightedLabel:SetColor(1, 1, 1, 1)

  local promoteAllBtn = WINDOW_MANAGER:CreateControl(nil, buttonPanel, CT_BUTTON)
  promoteAllBtn:SetDimensions(buttonWidth, buttonWidth)
  promoteAllBtn:SetAnchor(LEFT, highlightedBtn, RIGHT, buttonSpacing, 0)
  promoteAllBtn:SetNormalTexture("/esoui/art/buttons/pointsplus_up.dds")
  promoteAllBtn:SetPressedTexture("/esoui/art/buttons/pointsplus_down.dds")
  promoteAllBtn:SetMouseOverTexture("/esoui/art/buttons/pointsplus_over.dds")

  local promoteAllLabel = WINDOW_MANAGER:CreateControl(nil, buttonPanel, CT_LABEL)
  promoteAllLabel:SetAnchor(TOP, promoteAllBtn, BOTTOM, 0, 2)
  promoteAllLabel:SetFont("$(PROSE_ANTIQUE_FONT)|17")
  promoteAllLabel:SetText(SF.func._L("ScrollkeeperProvisionMember", "BTN_PROMOTE_ALL"))
  promoteAllLabel:SetColor(1, 1, 1, 1)

  local removeAllBtn = WINDOW_MANAGER:CreateControl(nil, buttonPanel, CT_BUTTON)
  removeAllBtn:SetDimensions(buttonWidth, buttonWidth)
  removeAllBtn:SetAnchor(LEFT, promoteAllBtn, RIGHT, buttonSpacing, 0)
  removeAllBtn:SetNormalTexture("/esoui/art/buttons/pointsminus_up.dds")
  removeAllBtn:SetPressedTexture("/esoui/art/buttons/pointsminus_down.dds")
  removeAllBtn:SetMouseOverTexture("/esoui/art/buttons/pointsminus_over.dds")

  local removeAllLabel = WINDOW_MANAGER:CreateControl(nil, buttonPanel, CT_LABEL)
  removeAllLabel:SetAnchor(TOP, removeAllBtn, BOTTOM, 0, 2)
  removeAllLabel:SetFont("$(PROSE_ANTIQUE_FONT)|17")
  removeAllLabel:SetText(SF.func._L("ScrollkeeperProvisionMember", "BTN_REMOVE_ALL"))
  removeAllLabel:SetColor(1, 1, 1, 1)

  -- Mail integration button
  local mailBtn = WINDOW_MANAGER:CreateControl(nil, buttonPanel, CT_BUTTON)
  mailBtn:SetDimensions(buttonWidth, buttonWidth)
  mailBtn:SetAnchor(TOP, buttonPanel, TOP, 0, 55) -- Position in second row, center
  mailBtn:SetNormalTexture("Scrollkeeper/ScrollkeeperFramework/textures/mail_tabicon_compose_up.dds")
  mailBtn:SetPressedTexture("Scrollkeeper/ScrollkeeperFramework/textures/mail_tabicon_compose_down.dds")
  mailBtn:SetMouseOverTexture("Scrollkeeper/ScrollkeeperFramework/textures/mail_tabicon_compose_over.dds")

  local mailLabel = WINDOW_MANAGER:CreateControl(nil, buttonPanel, CT_LABEL)
  mailLabel:SetAnchor(TOP, mailBtn, BOTTOM, 0, 2)
  mailLabel:SetFont("$(PROSE_ANTIQUE_FONT)|17")
  mailLabel:SetText(SF.func._L("ScrollkeeperProvisionMember", "BTN_MAIL_SELECTED"))
  mailLabel:SetColor(1, 1, 1, 1)

  -- Mail button handler
  mailBtn:SetHandler("OnClicked", function()
    if not window.selectedGuild then
      d(SF.func._L("ScrollkeeperProvisionMember", "ERROR_NO_GUILD_SELECTED"))
      return
    end

    -- Check if ScrollkeeperNotebookMail is available
    if not SLASH_COMMANDS["/sgtmail"] then
      d(SF.func._L("ScrollkeeperProvisionMember", "ERROR_MAIL_UNAVAILABLE"))
      return
    end

    -- Get the members to mail based on current view
    local membersToMail = {}
    local settings = getSettings()

    if settings and settings.taggedMembers and settings.taggedMembers[window.selectedGuild] then
      local guildMembers = settings.taggedMembers[window.selectedGuild]

      for memberName, data in pairs(guildMembers) do
        if data and type(data) == "table" and data.status ~= SF.func._L("ScrollkeeperProvisionMember", "STATUS_PROMOTED") then
          local shouldInclude = false

          if window.viewingHighlighted then
          shouldInclude = window.highlightedMembers[memberName] == true
        else
          if window.activeFilter == "all" or
             (window.activeFilter == "rank" and (data.reason == SF.func._L("ScrollkeeperProvisionMember", "REASON_RANK") or not data.reason)) or
             (window.activeFilter == "gold" and data.reason == SF.func._L("ScrollkeeperProvisionMember", "REASON_GOLD")) or
             (window.activeFilter == "inactive" and data.reason == SF.func._L("ScrollkeeperProvisionMember", "REASON_INACTIVE")) or
             (window.activeFilter == "donor" and data.reason == SF.func._L("ScrollkeeperProvisionMember", "REASON_DONOR")) then
            shouldInclude = true
          end
        end

          if shouldInclude then
            table.insert(membersToMail, memberName)
          end
        end
      end
    end

    if #membersToMail == 0 then
      d(SF.func._L("ScrollkeeperProvisionMember", "ERROR_NO_MEMBERS_TO_MAIL"))
      return
    end

    -- Open the mail window
    SLASH_COMMANDS["/sgtmail"]()

    -- Wait for the mail window to be created and then set up the recipients
    zo_callLater(function()
      local mailWindow = GetControl("ScrollkeeperMail_Window")
      if mailWindow then
        -- Set the provisional recipients list
        mailWindow.provisionRecipients = membersToMail

        -- Update the guild selection to match
        local guildDropdown = GetControl("ScrollkeeperMail_Window_GuildDropdown")
        if guildDropdown and guildDropdown.m_comboBox then
          guildDropdown.m_comboBox:SetSelectedItem(window.selectedGuild)
          mailWindow.selectedGuildId = nil

        -- Find the guild ID for the selected guild name
          for i = 1, GetNumGuilds() do
            local guildId = GetGuildId(i)
            if GetGuildName(guildId) == window.selectedGuild then
              mailWindow.selectedGuildId = guildId
              break
            end
          end
        end

      -- Update the recipient count display
        local recipientCountLabel = GetControl("ScrollkeeperMail_Window_RecipientCount")
        if recipientCountLabel then
          recipientCountLabel:SetText(string.format(SF.func._L("ScrollkeeperProvisionMember", "MAIL_RECIPIENT_COUNT"), #membersToMail))
        end

      -- Set status
        local statusLabel = GetControl("ScrollkeeperMail_Window_StatusLabel")
        if statusLabel then
          statusLabel:SetText(string.format(SF.func._L("ScrollkeeperProvisionMember", "MAIL_STATUS"), #membersToMail))
          statusLabel:SetColor(0.4, 1, 0.4, 1)
        end

      -- Auto-fill subject if it's gold filter
        if window.activeFilter == "gold" then
          local subjectInput = GetControl("ScrollkeeperMail_Window_SubjectInput")
          if subjectInput then
            subjectInput:SetText(string.format(SF.func._L("ScrollkeeperProvisionMember", "MAIL_SUBJECT_GOLD"), window.selectedGuild))
          end
        end

        d(string.format(SF.func._L("ScrollkeeperProvisionMember", "SUCCESS_MAIL_OPENED"), #membersToMail, window.selectedGuild))
      else
        d(SF.func._L("ScrollkeeperProvisionMember", "ERROR_MAIL_WINDOW_FAILED"))
      end
    end, 500)
  end)

  -- Add tooltip
  mailBtn:SetHandler("OnMouseEnter", function(self)
    InitializeTooltip(InformationTooltip, self, TOPLEFT, 0, 0)
    local tooltipText
    if window.viewingHighlighted then
      local count = 0
      for _ in pairs(window.highlightedMembers) do count = count + 1 end
      tooltipText = string.format(SF.func._L("ScrollkeeperProvisionMember", "BTN_MAIL_SELECTED_TIP_HIGHLIGHTED"), count)
    else
      tooltipText = SF.func._L("ScrollkeeperProvisionMember", "BTN_MAIL_SELECTED_TIP_FILTERED")
    end
    SetTooltipText(InformationTooltip, tooltipText)
  end)
  mailBtn:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)

  -- Clear member rows function
  local function clearMemberRows()
    for _, row in ipairs(window.memberRows) do
      if row and row.SetParent then
        row:SetParent(nil)
      end
    end
    window.memberRows = {}
  end

  -- Enhanced member list with proper clicking and days calculation
  local function updateMemberList()
    if not window.selectedGuild then
      clearMemberRows()
      return
    end

    local settings = getSettings()
    if not settings or not settings.taggedMembers then
      clearMemberRows()
      return
    end

    local guildMembers = settings.taggedMembers[window.selectedGuild] or {}
    local rowHeight = 35
    local visibleRows = math.floor(415 / rowHeight)

-- Build member list
local memberList = {}
for memberName, data in pairs(guildMembers) do
  if data and type(data) == "table" then
    local shouldInclude = false

    if window.viewingHighlighted then
      shouldInclude = window.highlightedMembers[memberName] == true
    else
      -- Fix the filter logic
      if window.activeFilter == "all" then
        -- Show ALL tracked members regardless of reason
        shouldInclude = (data.status ~= SF.func._L("ScrollkeeperProvisionMember", "STATUS_PROMOTED"))
      elseif window.activeFilter == "rank" then
        shouldInclude = (data.reason == SF.func._L("ScrollkeeperProvisionMember", "REASON_RANK") or not data.reason)
      elseif window.activeFilter == "gold" then
        shouldInclude = (data.reason == SF.func._L("ScrollkeeperProvisionMember", "REASON_GOLD"))
      elseif window.activeFilter == "inactive" then
        shouldInclude = (data.reason == SF.func._L("ScrollkeeperProvisionMember", "REASON_INACTIVE"))
      elseif window.activeFilter == "donor" then
        shouldInclude = (data.reason == SF.func._L("ScrollkeeperProvisionMember", "REASON_DONOR"))
      end
    end

    if shouldInclude then
      table.insert(memberList, {name = memberName, data = data})
    end
  end
end

-- Sort the member list based on current settings
    if window.sortColumn == "days" then
      table.sort(memberList, function(a, b)
        local aValue = 0
        local bValue = 0

        -- Get sort value based on reason type
        if a.data.reason == SF.func._L("ScrollkeeperProvisionMember", "REASON_INACTIVE") then
          -- For inactive members, sort by days offline
          local guildId = nil
          for i = 1, GetNumGuilds() do
            if GetGuildName(GetGuildId(i)) == window.selectedGuild then
              guildId = GetGuildId(i)
              break
            end
          end

          if guildId then
            for i = 1, GetNumGuildMembers(guildId) do
              local memberDisplayName, _, _, _, secondsOffline = GetGuildMemberInfo(guildId, i)
              if memberDisplayName == a.name then
                aValue = math.floor(secondsOffline / 86400)
                break
              end
            end
          end
        else
          -- For other members (rank, gold, donor), sort by join time
          aValue = math.floor((GetTimeStamp() - (a.data.actualJoinTime or a.data.joinDate or 0)) / 86400)
        end

        if b.data.reason == SF.func._L("ScrollkeeperProvisionMember", "REASON_INACTIVE") then
          -- For inactive members, sort by days offline
          local guildId = nil
          for i = 1, GetNumGuilds() do
            if GetGuildName(GetGuildId(i)) == window.selectedGuild then
              guildId = GetGuildId(i)
              break
            end
          end

          if guildId then
            for i = 1, GetNumGuildMembers(guildId) do
              local memberDisplayName, _, _, _, secondsOffline = GetGuildMemberInfo(guildId, i)
              if memberDisplayName == b.name then
                bValue = math.floor(secondsOffline / 86400)
                break
              end
            end
          end
        else
          -- For other members (rank, gold, donor), sort by join time
          bValue = math.floor((GetTimeStamp() - (b.data.actualJoinTime or b.data.joinDate or 0)) / 86400)
        end

        if window.sortDirection == "asc" then
          return aValue < bValue
        else
          return aValue > bValue
        end
      end)
    elseif window.sortColumn == "name" then
      table.sort(memberList, function(a, b)
        local nameA = (a.name or ""):lower()
        local nameB = (b.name or ""):lower()
        if window.sortDirection == "asc" then
          return nameA < nameB
        else
          return nameA > nameB
        end
      end)
    end

    local totalRows = #memberList

    -- Show/hide scroll bar
    if totalRows > visibleRows then
      scrollBar:SetHidden(false)
      scrollBar:SetMinMax(0, math.max(0, totalRows - visibleRows))
    else
      scrollBar:SetHidden(true)
      scrollBar:SetValue(0)
      window.scrollOffset = 0
    end

  -- Clear existing rows
  clearMemberRows()

    -- Create visible rows
    local displayRow = 0
    local startIndex = math.max(1, math.min(scrollOffset + 1, totalRows))
    local endIndex = math.min(startIndex + visibleRows - 1, totalRows)

    for i = startIndex, endIndex do
      local member = memberList[i]
      if member then
        local memberName = member.name
        local data = member.data

        -- Create row with unique name
        local rowControl = WINDOW_MANAGER:CreateControl(getUniqueControlName("Row"), scrollContainer, CT_CONTROL)
        rowControl:SetDimensions(920, rowHeight)
        rowControl:SetAnchor(TOPLEFT, scrollContainer, TOPLEFT, 0, displayRow * rowHeight)

        table.insert(window.memberRows, rowControl)

        -- Row background with highlighting support and click handling
        local rowBg = WINDOW_MANAGER:CreateControl(nil, rowControl, CT_BACKDROP)
        rowBg:SetAnchorFill()

        local isHighlighted = window.highlightedMembers[memberName]
        if isHighlighted then
          -- Use theme accent color for highlights
          if SF and SF.theme and SF.theme.colors and SF.theme.colors.accent then
            local accent = SF.theme.colors.accent
            rowBg:SetCenterColor(accent[1] * 0.8, accent[2] * 0.8, accent[3] * 0.8, 1)
            rowBg:SetEdgeColor(accent[1], accent[2], accent[3], 1)
            rowBg:SetEdgeTexture("", 2, 2, 1)
          else
            rowBg:SetCenterColor(0.5, 0.3, 0.1, 1)
            rowBg:SetEdgeColor(0.7, 0.5, 0.2, 1)
            rowBg:SetEdgeTexture("", 2, 2, 1)
          end
        elseif displayRow % 2 == 0 then
          rowBg:SetCenterColor(0.05, 0.05, 0.08, 0.9)
        else
          rowBg:SetCenterColor(0.08, 0.08, 0.12, 0.9)
        end

        -- Make entire row clickable with proper event handling
        rowControl:SetMouseEnabled(true)
        rowControl:SetHandler("OnMouseUp", function(self, button, upInside)
          if upInside and button == MOUSE_BUTTON_INDEX_LEFT then
            -- Prevent event bubbling to child controls
            if window.highlightedMembers[memberName] then
              window.highlightedMembers[memberName] = nil
            else
              window.highlightedMembers[memberName] = true
            end
            updateMemberList() -- Refresh to show highlight changes
            return true -- Consume the event
          end
        end)

        -- Also make the background clickable as backup
        rowBg:SetMouseEnabled(true)
        rowBg:SetHandler("OnMouseUp", function(self, button, upInside)
          if upInside and button == MOUSE_BUTTON_INDEX_LEFT then
            if window.highlightedMembers[memberName] then
              window.highlightedMembers[memberName] = nil
            else
              window.highlightedMembers[memberName] = true
            end
            updateMemberList()
            return true
          end
        end)

        -- Reason icon
        local reasonIcon = WINDOW_MANAGER:CreateControl(nil, rowControl, CT_TEXTURE)
        reasonIcon:SetDimensions(20, 20)
        reasonIcon:SetAnchor(TOPLEFT, rowControl, TOPLEFT, 2, 7)

        if data.reason == SF.func._L("ScrollkeeperProvisionMember", "REASON_GOLD") then
          reasonIcon:SetTexture("/esoui/art/guild/guild_tradinghouseaccess.dds")
          reasonIcon:SetColor(1, 0.8, 0.2, 1)
        elseif data.reason == SF.func._L("ScrollkeeperProvisionMember", "REASON_INACTIVE") then
          reasonIcon:SetTexture("/esoui/art/tutorial/timer_icon.dds")
          reasonIcon:SetColor(0.6, 0.6, 0.6, 1)
        elseif data.reason == SF.func._L("ScrollkeeperProvisionMember", "REASON_DONOR") then
          reasonIcon:SetTexture("/esoui/art/icons/servicemappins/servicepin_bank.dds")
        else
          reasonIcon:SetTexture("/esoui/art/tutorial/tabicon_roster_up.dds")
        end

        -- Member name
        local nameLabel = WINDOW_MANAGER:CreateControl(nil, rowControl, CT_LABEL)
        nameLabel:SetFont("ZoFontGame")
        nameLabel:SetText(memberName)
        nameLabel:SetAnchor(TOPLEFT, rowControl, TOPLEFT, 25, 5)
        nameLabel:SetColor(1, 1, 1, 1)

        -- Days calculation - show different data based on reason
        local daysSince = ""
        local daysColor = {0.8, 0.8, 0.8, 1}  -- Default gray

        if data.reason == SF.func._L("ScrollkeeperProvisionMember", "REASON_RANK") or not data.reason then
          -- Probation members: show days since join
          local guildId = nil
          for i = 1, GetNumGuilds() do
            if GetGuildName(GetGuildId(i)) == window.selectedGuild then
              guildId = GetGuildId(i)
              break
            end
          end

          if guildId then
            local calculatedDays, source = getAccurateDaysSinceJoin(guildId, window.selectedGuild, memberName, data)

            if calculatedDays then
              daysSince = tostring(calculatedDays)

              -- Color code by days
              if calculatedDays <= 7 then
                daysColor = {0.4, 1, 0.4, 1} -- Green for new
              elseif calculatedDays <= 21 then
                daysColor = {1, 0.8, 0.4, 1} -- Orange for medium
              else
                daysColor = {1, 0.4, 0.4, 1} -- Red for old
              end

              -- Add source indicator to the display
              if source == SF.func._L("ScrollkeeperProvisionMember", "SOURCE_AMT") then
                daysSince = daysSince .. "*"
              elseif source == SF.func._L("ScrollkeeperProvisionMember", "SOURCE_HISTOIRE") then
                daysSince = daysSince .. "~"
              elseif source == SF.func._L("ScrollkeeperProvisionMember", "SOURCE_DONATION") then
                daysSince = daysSince .. "?"
              elseif source == SF.func._L("ScrollkeeperProvisionMember", "SOURCE_TAGGED") then
                daysSince = daysSince .. "!"
              end
            else
              daysSince = SF.func._L("ScrollkeeperProvisionMember", "DAYS_UNKNOWN")
              daysColor = {0.6, 0.6, 0.6, 1}
            end
          else
            daysSince = SF.func._L("ScrollkeeperProvisionMember", "DAYS_ERROR")
            daysColor = {1, 0.4, 0.4, 1}
          end

        elseif data.reason == SF.func._L("ScrollkeeperProvisionMember", "REASON_INACTIVE") then
          -- Inactive members: show days offline
          local guildId = nil
          for i = 1, GetNumGuilds() do
            if GetGuildName(GetGuildId(i)) == window.selectedGuild then
              guildId = GetGuildId(i)
              break
            end
          end

          if guildId then
            -- Get their actual offline time
            for i = 1, GetNumGuildMembers(guildId) do
              local memberDisplayName, _, _, _, secondsOffline = GetGuildMemberInfo(guildId, i)
              if memberDisplayName == memberName then
                local daysOffline = math.floor(secondsOffline / 86400)
                daysSince = tostring(daysOffline) .. "d"

                -- Color code: more days = more red
                if daysOffline >= 90 then
                  daysColor = {1, 0.2, 0.2, 1} -- Dark red for very inactive
                elseif daysOffline >= 60 then
                  daysColor = {1, 0.4, 0.4, 1} -- Red
                else
                  daysColor = {1, 0.6, 0.4, 1} -- Orange
                end
                break
              end
            end
          end

          if daysSince == "" then
            daysSince = SF.func._L("ScrollkeeperProvisionMember", "DAYS_UNKNOWN")
            daysColor = {0.6, 0.6, 0.6, 1}
          end

        elseif data.reason == SF.func._L("ScrollkeeperProvisionMember", "REASON_GOLD") then
          -- Gold filter members: leave blank or show "N/A"
          daysSince = "-"
          daysColor = {0.6, 0.6, 0.6, 1}

        elseif data.reason == SF.func._L("ScrollkeeperProvisionMember", "REASON_DONOR") then
          -- Donor members: leave blank or show "N/A"
          daysSince = "-"
          daysColor = {0.6, 0.6, 0.6, 1}

        else
          -- Unknown reason
          daysSince = "-"
          daysColor = {0.6, 0.6, 0.6, 1}
        end

        local daysLabel = WINDOW_MANAGER:CreateControl(nil, rowControl, CT_LABEL)
        daysLabel:SetFont("ZoFontGame")
        daysLabel:SetText(daysSince)
        daysLabel:SetAnchor(TOPLEFT, rowControl, TOPLEFT, 340, 5)
        daysLabel:SetColor(daysColor[1], daysColor[2], daysColor[3], daysColor[4])

        -- Add tooltip to explain the symbols
        daysLabel:SetMouseEnabled(true)
        daysLabel:SetHandler("OnMouseEnter", (function(reason, days)
          return function(self)
            InitializeTooltip(InformationTooltip, self, TOPLEFT, 0, 0)

            local tooltipText = ""

            -- Different tooltip based on reason
            if reason == SF.func._L("ScrollkeeperProvisionMember", "REASON_INACTIVE") then
              tooltipText = "Days Offline\n\n"
              tooltipText = tooltipText .. "Shows how many days this member has been offline.\n"
              tooltipText = tooltipText .. "Higher numbers indicate longer inactivity."

            elseif reason == SF.func._L("ScrollkeeperProvisionMember", "REASON_RANK") or not reason then
              tooltipText = SF.func._L("ScrollkeeperProvisionMember", "TIP_DAYS_HEADER")

              if string.find(days, "%*") then
                tooltipText = tooltipText .. "|c00FF00" .. SF.func._L("ScrollkeeperProvisionMember", "TIP_DAYS_AMT") .. "|r\n"
              elseif string.find(days, "~") then
                tooltipText = tooltipText .. "|c88FF88" .. SF.func._L("ScrollkeeperProvisionMember", "TIP_DAYS_HISTOIRE") .. "|r\n"
              elseif string.find(days, "%?") then
                tooltipText = tooltipText .. "|cFFFF88" .. SF.func._L("ScrollkeeperProvisionMember", "TIP_DAYS_DONATION") .. "|r\n"
              elseif string.find(days, "!") then
                tooltipText = tooltipText .. "|cFFAA88" .. SF.func._L("ScrollkeeperProvisionMember", "TIP_DAYS_TAGGED") .. "|r\n"
              else
                tooltipText = tooltipText .. SF.func._L("ScrollkeeperProvisionMember", "TIP_DAYS_VALIDATED") .. "\n"
              end

              if not AMT_Available and days ~= SF.func._L("ScrollkeeperProvisionMember", "DAYS_NA") then
                tooltipText = tooltipText .. "\n|cFFFF00" .. SF.func._L("ScrollkeeperProvisionMember", "TIP_INSTALL_AMT") .. "|r"
              end

            else
              tooltipText = "N/A - Not applicable for this filter type"
            end

            SetTooltipText(InformationTooltip, tooltipText)
          end
        end)(data.reason, daysSince))
        daysLabel:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)

        -- Status
        local statusLabel = WINDOW_MANAGER:CreateControl(nil, rowControl, CT_LABEL)
        statusLabel:SetFont("ZoFontGame")
        statusLabel:SetText(data.status or SF.func._L("ScrollkeeperProvisionMember", "STATUS_PROVISIONAL"))
        statusLabel:SetAnchor(TOPLEFT, rowControl, TOPLEFT, 420, 5)
        statusLabel:SetColor(0.8, 0.8, 0.8, 1)

        -- Notes with proper positioning, color coding, and truncation
        local notes = data.notes or ""
        local noteColor = {0.7, 0.7, 0.7, 1}  -- Default gray

        -- Color code notes based on content
        if string.find(notes:lower(), "donated:") or string.find(notes:lower(), "total donated:") then
          noteColor = {0.4, 1, 0.4, 1}  -- Green for donation info
        elseif string.find(notes:lower(), "offline:") then
          noteColor = {1, 0.6, 0.4, 1}  -- Orange for offline info
        elseif string.find(notes:lower(), "no donations") then
          noteColor = {1, 0.4, 0.4, 1}  -- Red for no donations
        end

        -- Truncate long notes
        local displayNotes = notes
        if string.len(notes) > 25 then
          displayNotes = string.sub(notes, 1, 22) .. "..."
        end

        local notesLabel = WINDOW_MANAGER:CreateControl(nil, rowControl, CT_LABEL)
        notesLabel:SetFont("ZoFontGame")
        notesLabel:SetText(displayNotes)
        notesLabel:SetAnchor(TOPLEFT, rowControl, TOPLEFT, 600, 5)
        notesLabel:SetColor(noteColor[1], noteColor[2], noteColor[3], noteColor[4])

        -- Add tooltip if notes were truncated
        if string.len(notes) > 25 then
          notesLabel:SetMouseEnabled(true)
          notesLabel:SetHandler("OnMouseEnter", (function(fullNotes)
            return function(self)
              InitializeTooltip(InformationTooltip, self, TOPLEFT, 0, 0)
              SetTooltipText(InformationTooltip, fullNotes)
            end
          end)(notes))
          notesLabel:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)
        end

        -- Action buttons with tooltips and selection functionality
        local promoteBtn = WINDOW_MANAGER:CreateControl(nil, rowControl, CT_BUTTON)
        promoteBtn:SetDimensions(24, 24)
        promoteBtn:SetAnchor(TOPLEFT, rowControl, TOPLEFT, 800, 5)
        promoteBtn:SetNormalTexture("/esoui/art/buttons/accept_up.dds")
        promoteBtn:SetPressedTexture("/esoui/art/buttons/accept_down.dds")
        promoteBtn:SetMouseOverTexture("/esoui/art/buttons/accept_over.dds")

        -- Add tooltip based on filter type
        promoteBtn:SetHandler("OnMouseEnter", function(self)
          InitializeTooltip(InformationTooltip, self, TOPLEFT, 0, 0)

          local tooltipText
          if data.reason == SF.func._L("ScrollkeeperProvisionMember", "REASON_INACTIVE") then
            tooltipText = string.format("Open roster to review/kick %s (inactive member)", memberName)
          elseif data.reason == SF.func._L("ScrollkeeperProvisionMember", "REASON_GOLD") then
            tooltipText = string.format("Open roster to review %s (pending donation)", memberName)
          elseif data.reason == SF.func._L("ScrollkeeperProvisionMember", "REASON_DONOR") then
            tooltipText = string.format("Open roster to promote %s (valued contributor)", memberName)
          else
            -- Default for probationary rank
            tooltipText = string.format(SF.func._L("ScrollkeeperProvisionMember", "TIP_REVIEW_PROMOTE"), memberName)
          end

          SetTooltipText(InformationTooltip, tooltipText)
        end)
        promoteBtn:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)

        -- Promote button highlights member and then promotes
        promoteBtn:SetHandler("OnClicked", (function(name, guildName)
          return function()
            -- Find the guild ID
            local guildId = nil
            for j = 1, GetNumGuilds() do
              if GetGuildName(GetGuildId(j)) == guildName then
                guildId = GetGuildId(j)
                break
              end
            end

            if guildId then
              -- Open guild roster to the correct guild
              SCENE_MANAGER:Show("guildRoster")
              zo_callLater(function()
                if GUILD_ROSTER_MANAGER then
                  GUILD_ROSTER_MANAGER:SetGuildId(guildId)
                end
              end, 200)

              d(string.format(SF.func._L("ScrollkeeperProvisionMember", "LOG_OPENING_ROSTER_PROMOTE"), name))
            else
              d(string.format(SF.func._L("ScrollkeeperProvisionMember", "LOG_NO_GUILD_ID"), guildName))
            end
          end
        end)(memberName, window.selectedGuild))

        local removeBtn = WINDOW_MANAGER:CreateControl(nil, rowControl, CT_BUTTON)
        removeBtn:SetDimensions(24, 24)
        removeBtn:SetAnchor(LEFT, promoteBtn, RIGHT, 15, 0)
        removeBtn:SetNormalTexture("/esoui/art/buttons/decline_up.dds")
        removeBtn:SetPressedTexture("/esoui/art/buttons/decline_down.dds")
        removeBtn:SetMouseOverTexture("/esoui/art/buttons/decline_over.dds")

        -- Add tooltip
        removeBtn:SetHandler("OnMouseEnter", function(self)
          InitializeTooltip(InformationTooltip, self, TOPLEFT, 0, 0)
          SetTooltipText(InformationTooltip, string.format(SF.func._L("ScrollkeeperProvisionMember", "TIP_REMOVE"), memberName))
        end)
        removeBtn:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)

        -- Capture memberName in closure
        removeBtn:SetHandler("OnClicked", (function(name)
          return function()
            if PM.removeMember(window.selectedGuild, name, "Removed via UI") then
              d(string.format(SF.func._L("ScrollkeeperProvisionMember", "SUCCESS_REMOVED"), name))
              -- Remove from highlighted list if present
              window.highlightedMembers[name] = nil
              zo_callLater(function()
                if window.updateStats then window.updateStats() end
                updateMemberList()
              end, 100)
            end
          end
        end)(memberName))

        displayRow = displayRow + 1
      end
    end
	
	-- Update scrollable size if using LibScroll
    if window.updateScrollable then
      window.updateScrollable()
    end
  end

  -- Scroll bar handler
  scrollBar:SetHandler("OnValueChanged", function(control, value)
    local newOffset = math.floor(value or 0)
    if newOffset ~= scrollOffset then
      scrollOffset = newOffset
      updateMemberList()
    end
  end)

  -- Update statistics display
  local updateStats
  updateStats = function()
    if not window.selectedGuild then
      statsLabel:SetText(SF.func._L("ScrollkeeperProvisionMember", "STATUS_SELECT_GUILD"))
      return
    end

    local settings = getSettings()
    if not settings or not settings.taggedMembers then
      statsLabel:SetText(SF.func._L("ScrollkeeperProvisionMember", "STATUS_NO_TRACKING"))
      return
    end

    local guildMembers = settings.taggedMembers[window.selectedGuild] or {}

  -- Count by reason
  local reasonCounts = {
    [SF.func._L("ScrollkeeperProvisionMember", "REASON_RANK")] = 0,
    [SF.func._L("ScrollkeeperProvisionMember", "REASON_GOLD")] = 0,
    [SF.func._L("ScrollkeeperProvisionMember", "REASON_INACTIVE")] = 0,
    [SF.func._L("ScrollkeeperProvisionMember", "REASON_DONOR")] = 0,
  }
  local totalActive = 0
  local promoted = 0

  for _, data in pairs(guildMembers) do
    if data and type(data) == "table" then
      if data.status == SF.func._L("ScrollkeeperProvisionMember", "STATUS_PROMOTED") then
        promoted = promoted + 1
      else
        totalActive = totalActive + 1
        local reason = data.reason or SF.func._L("ScrollkeeperProvisionMember", "REASON_RANK")
        reasonCounts[reason] = (reasonCounts[reason] or 0) + 1
      end
    end
  end

  local statsText = string.format(
    "%s | Total: %d | Rank: %d | Gold: %d | Inactive: %d | Donor: %d | Promoted: %d",
    window.selectedGuild,
    totalActive,
    reasonCounts[SF.func._L("ScrollkeeperProvisionMember", "REASON_RANK")],
    reasonCounts[SF.func._L("ScrollkeeperProvisionMember", "REASON_GOLD")],
    reasonCounts[SF.func._L("ScrollkeeperProvisionMember", "REASON_INACTIVE")],
    reasonCounts[SF.func._L("ScrollkeeperProvisionMember", "REASON_DONOR")],
    promoted
  )
  
  statsLabel:SetText(statsText)
end

  -- Update filter button visual states
  local function updateFilterButtonStates()
    local accent = SF and SF.theme and SF.theme.colors and SF.theme.colors.accent or {0.3, 0.3, 0.4, 1}
    local inactive = {0.1, 0.1, 0.2, 1}

    -- Reset all buttons to inactive or accent depending on activeFilter
    window.allBg:SetCenterColor(unpack(window.activeFilter == "all" and accent or inactive))
    window.probationBg:SetCenterColor(unpack(window.activeFilter == "rank" and accent or inactive))
    window.goldBg:SetCenterColor(unpack(window.activeFilter == "gold" and accent or inactive))

    -- Make active button visually stronger (explicit override)
    if window.activeFilter == "all" then
      window.allBg:SetCenterColor(0.3, 0.3, 0.4, 1)
    elseif window.activeFilter == "rank" then
      window.probationBg:SetCenterColor(0.3, 0.3, 0.4, 1)
    elseif window.activeFilter == "gold" then
      window.goldBg:SetCenterColor(0.3, 0.3, 0.4, 1)
    end
  end

  -- Filter button handlers
  allBtn:SetHandler("OnClicked", function()
    window.activeFilter = "all"
    scrollOffset = 0
    scrollBar:SetValue(0)
    if window.updateFilterStates then window.updateFilterStates() end
    if window.updateMemberList then window.updateMemberList() end
  end)

  probationBtn:SetHandler("OnClicked", function()
    window.activeFilter = "rank"
    scrollOffset = 0
    scrollBar:SetValue(0)
    if window.updateFilterStates then window.updateFilterStates() end
    if window.updateMemberList then window.updateMemberList() end
  end)

  goldBtn:SetHandler("OnClicked", function()
    window.activeFilter = "gold"
    scrollOffset = 0
    scrollBar:SetValue(0)
    if window.updateFilterStates then window.updateFilterStates() end
    if window.updateMemberList then window.updateMemberList() end
  end)

  inactiveBtn:SetHandler("OnClicked", function()
    window.activeFilter = "inactive"
    scrollOffset = 0
    scrollBar:SetValue(0)
    if window.updateFilterStates then window.updateFilterStates() end
    if window.updateMemberList then window.updateMemberList() end
  end)

  donorBtn:SetHandler("OnClicked", function()
    window.activeFilter = "donor"
    scrollOffset = 0
    scrollBar:SetValue(0)
    if window.updateFilterStates then window.updateFilterStates() end
    if window.updateMemberList then window.updateMemberList() end
  end)

  -- Populate guild dropdown
  local function populateGuildDropdown()
  guildCombo:ClearItems()

  -- Get guilds in proper display order
  local orderedGuilds = getGuildsInOrder()
  local trackedGuilds = {}
  
  for _, guildName in ipairs(orderedGuilds) do
    local guildSettings = getGuildSettings(guildName)
    if guildSettings and guildSettings.enabled then
      table.insert(trackedGuilds, guildName)
    end
  end

  if #trackedGuilds == 0 then
    local noGuildsEntry = guildCombo:CreateItemEntry(SF.func._L("ScrollkeeperProvisionMember", "DROPDOWN_NO_GUILDS"), function() end)
    guildCombo:AddItem(noGuildsEntry)
    guildCombo:SelectItem(noGuildsEntry)
    return
  end

  -- Store current selection
  local currentSelection = window.selectedGuild
  
  for _, guildName in ipairs(trackedGuilds) do
    local entry = guildCombo:CreateItemEntry(guildName, function()
      window.selectedGuild = guildName
      scrollOffset = 0
      scrollBar:SetValue(0)
      window.highlightedMembers = {} -- Clear selections when switching guilds
      updateStats()
      updateMemberList()
    end)
    guildCombo:AddItem(entry)
  end

  -- Restore previous selection if it still exists, otherwise select first guild
  if currentSelection then
    local stillExists = false
    for _, guildName in ipairs(trackedGuilds) do
      if guildName == currentSelection then
        stillExists = true
        break
      end
    end
    
    if stillExists then
      window.selectedGuild = currentSelection
      guildCombo:SetSelectedItem(currentSelection)
    else
      window.selectedGuild = trackedGuilds[1]
      guildCombo:SetSelectedItem(trackedGuilds[1])
    end
  else
    window.selectedGuild = trackedGuilds[1]
    guildCombo:SetSelectedItem(trackedGuilds[1])
  end
  
  updateStats()
  updateMemberList()
end

-- Name header click handler
  nameHeaderBtn:SetHandler("OnClicked", function()
    if window.sortColumn == "name" then
      window.sortDirection = window.sortDirection == "asc" and "desc" or "asc"
    else
      window.sortColumn = "name"
      window.sortDirection = "asc"
    end

    nameSortArrow:SetText(window.sortDirection == "asc" and ZO_SORT_ORDER_UP_ICON or ZO_SORT_ORDER_DOWN_ICON)
    daysSortArrow:SetText("")

    updateMemberList()
  end)

  -- Days header click handler
  daysHeaderBtn:SetHandler("OnClicked", function()
    if window.sortColumn == "days" then
      window.sortDirection = window.sortDirection == "asc" and "desc" or "asc"
    else
      window.sortColumn = "days"
      window.sortDirection = "asc"
    end

    daysSortArrow:SetText(window.sortDirection == "asc" and ZO_SORT_ORDER_UP_ICON or ZO_SORT_ORDER_DOWN_ICON)
    nameSortArrow:SetText("")

    updateMemberList()
  end)

  -- Store functions on window for external access
  window.updateStats = updateStats
  window.updateMemberList = updateMemberList
  window.populateGuildDropdown = populateGuildDropdown
  window.headerPanel = headerPanel
  
-- Setup smooth scrolling with LibScroll
  setupSmoothScroll(scrollContainer, scrollBar, 415, 415, updateMemberList, window)
  
  -- Button handlers
  refreshBtn:SetHandler("OnClicked", function()
    -- Re-evaluate existing members against current donation data
    if window.selectedGuild then
      local reEvaluated = PM.reEvaluateMembers(window.selectedGuild)
      if reEvaluated > 0 then
        d(string.format("Re-evaluated and removed %d members who now meet gold requirements", reEvaluated))
      end
    end

    scrollOffset = 0
    scrollBar:SetValue(0)
    window.viewingHighlighted = false
    window.highlightedMembers = {}
    populateGuildDropdown()
    zo_callLater(function()
      updateStats()
      updateMemberList()
    end, 100)
    d(SF.func._L("ScrollkeeperProvisionMember", "LOG_REFRESHED"))
  end)

  refreshBtn:SetHandler("OnMouseEnter", function(self)
    InitializeTooltip(InformationTooltip, self, TOPLEFT, 0, 0)
    SetTooltipText(InformationTooltip, SF.func._L("ScrollkeeperProvisionMember", "BTN_REFRESH_TIP"))
  end)
  refreshBtn:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)

  exportBtn:SetHandler("OnClicked", function()
    if window.selectedGuild then
      local exportText = PM.exportMembers(
        window.selectedGuild,
        window.activeFilter,
        window.viewingHighlighted,
        window.highlightedMembers
      )
      createExportWindow(exportText)
    else
      d(SF.func._L("ScrollkeeperProvisionMember", "ERROR_NO_GUILD_SELECTED"))
    end
  end)

  exportBtn:SetHandler("OnMouseEnter", function(self)
    InitializeTooltip(InformationTooltip, self, TOPLEFT, 0, 0)
    SetTooltipText(InformationTooltip, SF.func._L("ScrollkeeperProvisionMember", "BTN_EXPORT_TIP"))
  end)
  exportBtn:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)

  scanBtn:SetHandler("OnClicked", function()
    -- Check if data is ready first
    if not SF.Data or not SF.Data.isReady or not SF.Data.isReady() then
      d("|cFF0000[ProvisionMember]|r " .. SF.func._L("ScrollkeeperProvisionMember", "ERROR_DATA_NOT_READY"))
      return
    end

    d("|cFFD700[ProvisionMember]|r " .. SF.func._L("ScrollkeeperProvisionMember", "LOG_STARTING_SCAN"))
    PM.manualScan()

    zo_callLater(function()
      populateGuildDropdown()
      updateStats()
      updateMemberList()
      d("|c00FF00[ProvisionMember]|r " .. SF.func._L("ScrollkeeperProvisionMember", "LOG_SCAN_COMPLETE_SHORT"))
    end, 2000)
  end)


  scanBtn:SetHandler("OnMouseEnter", function(self)
    InitializeTooltip(InformationTooltip, self, TOPLEFT, 0, 0)
    SetTooltipText(InformationTooltip, SF.func._L("ScrollkeeperProvisionMember", "BTN_SCAN_TIP"))
  end)
  scanBtn:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)

  -- Bulk operation button handlers with proper highlighting logic
  highlightedBtn:SetHandler("OnClicked", function()
    window.viewingHighlighted = not window.viewingHighlighted
    scrollOffset = 0
    scrollBar:SetValue(0)

    if window.viewingHighlighted then
      highlightedLabel:SetText(SF.func._L("ScrollkeeperProvisionMember", "BTN_VIEW_ALL"))
      highlightedLabel:SetColor(1, 0.8, 0.2, 1) -- Orange when active
    else
      highlightedLabel:SetText(SF.func._L("ScrollkeeperProvisionMember", "BTN_VIEW_SELECTED"))
      highlightedLabel:SetColor(1, 1, 1, 1) -- White when inactive
    end

    updateMemberList()

    local highlightedCount = 0
    for _ in pairs(window.highlightedMembers) do highlightedCount = highlightedCount + 1 end
    d(string.format(SF.func._L("ScrollkeeperProvisionMember", "LOG_FILTER_MODE"),
      window.viewingHighlighted and "Selected" or "All", highlightedCount))
  end)

  highlightedBtn:SetHandler("OnMouseEnter", function(self)
    InitializeTooltip(InformationTooltip, self, TOPLEFT, 0, 0)
    SetTooltipText(InformationTooltip, SF.func._L("ScrollkeeperProvisionMember", "BTN_VIEW_SELECTED_TIP"))
  end)
  highlightedBtn:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)

  -- Bulk open roster to review / promote selected members
  promoteAllBtn:SetHandler("OnMouseEnter", function(self)
    InitializeTooltip(InformationTooltip, self, TOPLEFT, 0, 0)
    SetTooltipText(InformationTooltip, SF.func._L("ScrollkeeperProvisionMember", "BTN_PROMOTE_ALL_TIP"))
  end)

  promoteAllBtn:SetHandler("OnMouseExit", function(self)
    ClearTooltip(InformationTooltip)
  end)

  promoteAllBtn:SetHandler("OnClicked", function()
    ClearTooltip(InformationTooltip)
    local highlightedCount = 0
    for _ in pairs(window.highlightedMembers) do
      highlightedCount = highlightedCount + 1
    end

    if highlightedCount == 0 then
      d(SF.func._L("ScrollkeeperProvisionMember", "STATUS_NO_SELECTED"))
      return
    end

    -- Find the guild ID for the selected guild
    local guildId = nil
    for j = 1, GetNumGuilds() do
      if GetGuildName(GetGuildId(j)) == window.selectedGuild then
        guildId = GetGuildId(j)
        break
      end
    end

    if guildId then
      -- Open guild roster and set guild
      SCENE_MANAGER:Show("guildRoster")
      zo_callLater(function()
        if GUILD_ROSTER_MANAGER then
          GUILD_ROSTER_MANAGER:SetGuildId(guildId)
        end
      end, 200)

      -- Log the members we intend to act on
      local memberList = {}
      for memberName, _ in pairs(window.highlightedMembers) do
        table.insert(memberList, memberName)
      end
      d(string.format(SF.func._L("ScrollkeeperProvisionMember", "LOG_OPENING_ROSTER_BULK"),
        #memberList, table.concat(memberList, ", ")))
    else
      d(SF.func._L("ScrollkeeperProvisionMember", "LOG_NO_GUILD_ID_SIMPLE"))
    end

    local removedCount = 0
    for memberName, _ in pairs(window.highlightedMembers) do
      if PM.removeMember(window.selectedGuild, memberName, "Bulk removed via UI") then
        removedCount = removedCount + 1
      end
    end

    window.highlightedMembers = {}

    zo_callLater(function()
      if window.updateStats then window.updateStats() end
      updateMemberList()
    end, 100)

    d(string.format(SF.func._L("ScrollkeeperProvisionMember", "SUCCESS_BULK_REMOVED"), removedCount))
  end)

  removeAllBtn:SetHandler("OnMouseEnter", function(self)
    InitializeTooltip(InformationTooltip, self, TOPLEFT, 0, 0)
    SetTooltipText(InformationTooltip, SF.func._L("ScrollkeeperProvisionMember", "BTN_REMOVE_ALL_TIP"))
  end)
  removeAllBtn:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)

  removeAllBtn:SetHandler("OnClicked", function()
    local highlightedCount = 0
    for _ in pairs(window.highlightedMembers) do
      highlightedCount = highlightedCount + 1
    end

    if highlightedCount == 0 then
      d(SF.func._L("ScrollkeeperProvisionMember", "STATUS_NO_SELECTED_REMOVE"))
      return
    end

    local removedCount = 0
    for memberName, _ in pairs(window.highlightedMembers) do
      if PM.removeMember(window.selectedGuild, memberName, "Bulk removed via UI") then
        removedCount = removedCount + 1
      end
    end

    window.highlightedMembers = {}

    zo_callLater(function()
      if window.updateStats then window.updateStats() end
      updateMemberList()
    end, 100)

    d(string.format(SF.func._L("ScrollkeeperProvisionMember", "SUCCESS_BULK_REMOVED"), removedCount))
  end)

-- Store theme-related references
  window.titleBar = titleBar
  window.titleText = title
  window.headerPanel = headerPanel
  window.nameHeader = nameHeaderLabel
  window.daysHeader = daysHeaderLabel
  window.nameSortArrow = nameSortArrow
  window.daysSortArrow = daysSortArrow
  window.statusHeader = statusHeader
  window.notesHeader = notesHeader
  window.actionsHeader = actionsHeader

  -- Store filter state update function
  window.updateFilterStates = updateFilterStates

  -- Call it initially
  updateFilterStates()

  -- Register theme update callback
  window.updateTheme = function()
    applyProvisionTheme(window)
  end

  -- Register with framework
  if SF and SF.registerThemedWindow then
    SF.registerThemedWindow("ScrollkeeperProvision_Window", window.updateTheme)
  end

  -- Apply initial theme
  zo_callLater(function()
    applyProvisionTheme(window)
  end, 100)


  -- Add OnShow handler for the open message
  window:SetHandler("OnShow", function()
    -- Refresh guild list when opening
    if window.populateGuildDropdown then
      window.populateGuildDropdown()
    end
    
    -- Show message about scanning
    d(string.format("|cFFD700[ProvisionMember]|r %s", 
      SF.func._L("ScrollkeeperProvisionMember", "WINDOW_OPENED_MESSAGE") or 
      "Window opened. Use the Scan button to check for members needing tracking."))
  end)
  
   populateGuildDropdown()
   return window
end


-- Slash command and keybind registration
local function registerCommands()
  SLASH_COMMANDS["/sgtprovision"] = function()
  local settings = getSettings()
  if not settings or not settings.enabled then
    d(SF.func._L("ScrollkeeperProvisionMember", "STATUS_DISABLED"))
    return
  end

  local window = GetControl("ScrollkeeperProvision_Window")
  if not window then
    window = createProvisionWindow()
    if not window then
      d("[ScrollkeeperProvisionMember] ERROR: Failed to create provision window")
      return
    end
  end

  -- Simple toggle - OnShow handler will display the message
  window:SetHidden(not window:IsHidden())
end

  -- Debug command to check specific member's donations
  SLASH_COMMANDS["/sgtcheckpm"] = function(args)
    -- Expected format: GuildName|@DisplayName
    local parts = {}
    for part in string.gmatch(args, "[^|]+") do
      table.insert(parts, part)
    end

    if #parts < 2 then
      d("Usage: /sgtcheckpm GuildName|@DisplayName")
      d("Example: /sgtcheckpm Dragon's Nest Thievery Co|@YourName")
      return
    end

    local guildName = parts[1]
    local displayName = parts[2]

    -- Find guild ID
    local guildId = nil
    for i = 1, GetNumGuilds() do
      if GetGuildName(GetGuildId(i)) == guildName then
        guildId = GetGuildId(i)
        break
      end
    end

    if not guildId then
      d(string.format("Could not find guild: %s", guildName))
      return
    end

    local guildSettings = getGuildSettings(guildName)
    if not guildSettings or not guildSettings.goldDonationFilter or not guildSettings.goldDonationFilter.enabled then
      d(string.format("Gold donation filter not enabled for %s", guildName))
      return
    end

    d("=== Checking " .. displayName .. " in " .. guildName .. " ===")
    d(string.format("Settings: %d gold required in last %d days",
      guildSettings.goldDonationFilter.requiredAmount,
      guildSettings.goldDonationFilter.timePeriodDays))

    -- This will trigger the debug output we added
    local meetsRequirement, totalDonated = checkMemberDonations(
      guildId,
      guildName,
      displayName,
      guildSettings.goldDonationFilter.requiredAmount,
      guildSettings.goldDonationFilter.timePeriodDays,
      true  -- Enable debug output for manual command
    )

    d("=== End Check ===")
  end

  -- Test specific member inactivity
  SLASH_COMMANDS["/sgtcheckinactive"] = function(args)
    if not args or args == "" then
      d("[PM Debug] Usage: /sgtcheckinactive <guild index> <displayName>")
      d("[PM Debug] Example: /sgtcheckinactive 1 @YourName")
      d("[PM Debug] Your guilds:")
      for i = 1, GetNumGuilds() do
        local guildName = GetGuildName(GetGuildId(i))
        d(string.format("[PM Debug]   %d: %s", i, guildName))
      end
      return
    end

    -- Parse: "1 @DisplayName" or "2 @Name"
    local guildIndex, displayName = string.match(args, "^(%d+)%s+(@?.+)$")

    if not guildIndex or not displayName then
      d("[PM Debug] ERROR: Could not parse arguments")
      d("[PM Debug] Usage: /sgtcheckinactive <guild index> <displayName>")
      return
    end

    guildIndex = tonumber(guildIndex)
    if not guildIndex or guildIndex < 1 or guildIndex > GetNumGuilds() then
      d(string.format("[PM Debug] ERROR: Invalid guild index %s (you have %d guilds)",
        tostring(guildIndex), GetNumGuilds()))
      return
    end

    local guildId = GetGuildId(guildIndex)
    local guildName = GetGuildName(guildId)

    d("========================================")
    d(string.format("[PM Inactive Debug] Guild: %s", guildName))
    d(string.format("[PM Inactive Debug] Member: %s", displayName))
    d("========================================")

    local guildSettings = getGuildSettings(guildName)
    if guildSettings and guildSettings.inactivityFilter and guildSettings.inactivityFilter.enabled then
      d(string.format("[PM Inactive Debug] Filter: ENABLED (threshold: %d days)",
        guildSettings.inactivityFilter.inactiveDays))
    else
      d("[PM Inactive Debug] Filter: DISABLED")
      d("[PM Inactive Debug] Using default threshold: 30 days")
    end

    local threshold = (guildSettings and guildSettings.inactivityFilter and
                      guildSettings.inactivityFilter.inactiveDays) or 30

    -- Check with debug enabled
    local isInactive, daysSince = checkMemberInactivity(guildId, displayName, threshold, true)

    d("========================================")
    d(string.format("[PM Inactive Debug] Final Result: %s",
      isInactive and "INACTIVE (would be tracked)" or "ACTIVE (would be skipped)"))
    d("========================================")
  end

  -- Register keybind
  ZO_CreateStringId("SI_BINDING_NAME_SCROLLKEEPER_PROVISION", "Open Provisional Member Window")
end

-- 🎛️ Build enhanced controls with cascading per-guild settings and donation integration
local function buildControls()
  local settings = getSettings()
  if not settings then
    return {{ type = "description", text = SF.func._L("ScrollkeeperProvisionMember", "ERROR_SETTINGS_UNAVAILABLE") }}
  end
  if not settings.guildSettings then
    settings.guildSettings = {}
  end

  if GetNumGuilds() == 0 then
    return {{
      type = "description",
      text = SF.func._L("ScrollkeeperProvisionMember", "ERROR_NO_GUILDS")
    }}
  end

  local controls = {
    {
      type = "submenu",
      name = SF.func._L("ScrollkeeperProvisionMember", "SUBMENU_NAME"),
      controls = {
        {
          type = "description",
          text = SF.func._L("ScrollkeeperProvisionMember", "DESCRIPTION")
        },
        {
          type    = "checkbox",
          name    = SF.func._L("ScrollkeeperProvisionMember", "MASTER_ENABLE"),
          tooltip = SF.func._L("ScrollkeeperProvisionMember", "MASTER_ENABLE_TIP"),
          getFunc = function() return settings.enabled end,
          setFunc = function(v)
            settings.enabled = v
            if v then
              _addon:EnableEvents()
              registerCommands()
            else
              _addon:DisableEvents()
            end
          end,
          default = defaults.enabled,
        },
        {
          type = "button",
          name = SF.func._L("ScrollkeeperProvisionMember", "OPEN_ADMIN"),
          tooltip = SF.func._L("ScrollkeeperProvisionMember", "OPEN_ADMIN_TIP"),
          func = function()
            if SLASH_COMMANDS["/sgtprovision"] then
              SLASH_COMMANDS["/sgtprovision"]()
            end
          end,
          width = "half",
        },
        {
          type = "button",
          name = SF.func._L("ScrollkeeperProvisionMember", "CLEAR_SCAN"),
          tooltip = SF.func._L("ScrollkeeperProvisionMember", "CLEAR_SCAN_TIP"),
          func = function()
            PM.manualScan()
          end,
          width = "half",
        },
        {
          type = "button",
          name = SF.func._L("ScrollkeeperProvisionMember", "RESET_GOLD"),
          tooltip = SF.func._L("ScrollkeeperProvisionMember", "RESET_GOLD_TIP"),
          func = function()
            local count = PM.clearGoldProcessed()
            d(string.format(SF.func._L("ScrollkeeperProvisionMember", "SUCCESS_CLEARED_GOLD"), count))
          end,
          width = "half",
        },
        {
          type = "description",
          name = SF.func._L("ScrollkeeperProvisionMember", "MEMBER_COUNT_STATUS"),
          text = function()
            local count = 0
            if settings and settings.taggedMembers then
              for guildName, members in pairs(settings.taggedMembers) do
                if members and type(members) == "table" then
                  for memberName, data in pairs(members) do
                    if data and type(data) == "table" and data.status ~= SF.func._L("ScrollkeeperProvisionMember", "STATUS_PROMOTED") then
                      count = count + 1
                    end
                  end
                end
              end
            end

            -- Count permanently removed members
            local rankRemoved = 0
            local goldRemoved = 0
            if settings and settings.processedMembers then
              for guildName, members in pairs(settings.processedMembers) do
                if members and type(members) == "table" then
                  for memberName, data in pairs(members) do
                    if type(data) == "table" then
                      if data.reason == SF.func._L("ScrollkeeperProvisionMember", "REASON_RANK") then
                        rankRemoved = rankRemoved + 1
                      elseif data.reason == SF.func._L("ScrollkeeperProvisionMember", "REASON_GOLD") then
                        goldRemoved = goldRemoved + 1
                      end
                    else
                      rankRemoved = rankRemoved + 1 -- Legacy format
                    end
                  end
                end
              end
            end

            return string.format(SF.func._L("ScrollkeeperProvisionMember", "MEMBER_COUNT_FORMAT"),
              count, rankRemoved, goldRemoved)
          end,
        },
        {
          type = "header",
          name = SF.func._L("ScrollkeeperProvisionMember", "INTEGRATION_HEADER")
        },
        {
          type = "description",
          text = function()
            local statusText = SF.func._L("ScrollkeeperProvisionMember", "INTEGRATION_STATUS") .. "\n\n"

            -- AMT Status
            if AMT_Available then
              statusText = statusText .. "|c00FF00" .. SF.func._L("ScrollkeeperProvisionMember", "AMT_AVAILABLE") .. "|r\n"
            else
              statusText = statusText .. "|cFF0000" .. SF.func._L("ScrollkeeperProvisionMember", "AMT_UNAVAILABLE") .. "|r\n"
              statusText = statusText .. "   " .. SF.func._L("ScrollkeeperProvisionMember", "AMT_INSTALL") .. "\n"
              statusText = statusText .. "   " .. SF.func._L("ScrollkeeperProvisionMember", "AMT_DESC") .. "\n\n"
            end

            -- LibHistoire Status
            if LibHistoire then
              if histoireReady then
                statusText = statusText .. "|c00FF00" .. SF.func._L("ScrollkeeperProvisionMember", "LH_READY") .. "|r\n\n"
              end
            else
              statusText = statusText .. "|cFF0000" .. SF.func._L("ScrollkeeperProvisionMember", "LH_MISSING") .. "|r\n\n"
            end

            -- Data Module Status
            if SF.Data then
              statusText = statusText .. "|c00FF00" .. SF.func._L("ScrollkeeperProvisionMember", "DATA_AVAILABLE") .. "|r\n\n"
            else
              statusText = statusText .. "|cFF0000" .. SF.func._L("ScrollkeeperProvisionMember", "DATA_UNAVAILABLE") .. "|r\n\n"
            end

            -- Symbol Legend
            statusText = statusText .. SF.func._L("ScrollkeeperProvisionMember", "SYMBOL_LEGEND") .. "\n"
            statusText = statusText .. "|c00FF00" .. SF.func._L("ScrollkeeperProvisionMember", "SYMBOL_AMT") .. "|r\n"
            statusText = statusText .. "|c88FF88" .. SF.func._L("ScrollkeeperProvisionMember", "SYMBOL_HISTOIRE") .. "|r\n"
            statusText = statusText .. "|cFFFF88" .. SF.func._L("ScrollkeeperProvisionMember", "SYMBOL_DONATION") .. "|r\n"
            statusText = statusText .. "|cFFAA88" .. SF.func._L("ScrollkeeperProvisionMember", "SYMBOL_TAGGED") .. "|r\n"
            statusText = statusText .. SF.func._L("ScrollkeeperProvisionMember", "SYMBOL_VALIDATED") .. "\n"
            statusText = statusText .. SF.func._L("ScrollkeeperProvisionMember", "SYMBOL_UNKNOWN") .. "\n\n"

            statusText = statusText .. SF.func._L("ScrollkeeperProvisionMember", "SYMBOL_FOOTER")

            return statusText
          end,
        },
      }
    }
  }

  -- Add per-guild settings
  for i = 1, GetNumGuilds() do
    local guildId = GetGuildId(i)
    local guildName = GetGuildName(guildId)

    if guildName and guildName ~= "" then
      local guildSubmenu = {
        type = "submenu",
        name = guildName,
        controls = {
          {
            type    = "checkbox",
            name    = string.format(SF.func._L("ScrollkeeperProvisionMember", "ENABLE_FOR_GUILD"), guildName),
            tooltip = SF.func._L("ScrollkeeperProvisionMember", "ENABLE_FOR_GUILD_TIP"),
            getFunc = function() return getGuildSettings(guildName).enabled end,
            setFunc = function(v)
              local gs = getGuildSettings(guildName)
              if gs then
                gs.enabled = v
                if not v then
                  -- Clear existing tracking when disabled
                  if settings and settings.taggedMembers then
                    settings.taggedMembers[guildName] = {}
                  end
                  if settings and settings.processedMembers then
                    settings.processedMembers[guildName] = {}
                  end
                  gs.autoTag = false
                  gs.notifyOnJoin = false
                  if gs.goldDonationFilter then gs.goldDonationFilter.enabled = false end
                  d(string.format(SF.func._L("ScrollkeeperProvisionMember", "SUCCESS_CLEARED_DATA"), guildName))
                end
              end
            end,
            default = true,
          },
          {
            type = "checkbox",
            name = SF.func._L("ScrollkeeperProvisionMember", "AUTO_TAG"),
            tooltip = SF.func._L("ScrollkeeperProvisionMember", "AUTO_TAG_TIP"),
            getFunc = function() return getGuildSettings(guildName).autoTag end,
            setFunc = function(v)
              local gs = getGuildSettings(guildName)
              if gs then gs.autoTag = v end
            end,
            disabled = function() return not getGuildSettings(guildName).enabled end,
            default = true,
          },
          {
            type    = "checkbox",
            name    = SF.func._L("ScrollkeeperProvisionMember", "NOTIFY_JOIN"),
            tooltip = SF.func._L("ScrollkeeperProvisionMember", "NOTIFY_JOIN_TIP"),
            getFunc = function() return getGuildSettings(guildName).notifyOnJoin end,
            setFunc = function(v)
              local gs = getGuildSettings(guildName)
              if gs then gs.notifyOnJoin = v end
            end,
            disabled = function() return not getGuildSettings(guildName).enabled end,
            default = true,
          },
          {
            type    = "slider",
            name    = SF.func._L("ScrollkeeperProvisionMember", "PROBATION_DAYS"),
            tooltip = SF.func._L("ScrollkeeperProvisionMember", "PROBATION_DAYS_TIP"),
            min = 1, max = 90, step = 1,
            getFunc = function() return getGuildSettings(guildName).trackingDays end,
            setFunc = function(v)
              local gs = getGuildSettings(guildName)
              if gs then gs.trackingDays = v end
            end,
            disabled = function() return not getGuildSettings(guildName).enabled end,
            default = 30,
          },
          {
            type = "header",
            name = SF.func._L("ScrollkeeperProvisionMember", "GOLD_HEADER"),
          },
          {
            type    = "checkbox",
            name    = SF.func._L("ScrollkeeperProvisionMember", "GOLD_ENABLE"),
            tooltip = SF.func._L("ScrollkeeperProvisionMember", "GOLD_ENABLE_TIP"),
            getFunc = function() return getGuildSettings(guildName).goldDonationFilter.enabled end,
            setFunc = function(v)
              local gs = getGuildSettings(guildName)
              if gs and gs.goldDonationFilter then gs.goldDonationFilter.enabled = v end
            end,
            disabled = function() return not getGuildSettings(guildName).enabled end,
            default = false,
          },
          {
            type    = "editbox",
            name    = SF.func._L("ScrollkeeperProvisionMember", "GOLD_AMOUNT"),
            tooltip = SF.func._L("ScrollkeeperProvisionMember", "GOLD_AMOUNT_TIP"),
            getFunc = function() return tostring(getGuildSettings(guildName).goldDonationFilter.requiredAmount) end,
            setFunc = function(v)
              local gs = getGuildSettings(guildName)
              if gs and gs.goldDonationFilter then
                local amount = tonumber(v) or 5000
                gs.goldDonationFilter.requiredAmount = math.max(0, amount)
              end
            end,
            disabled = function() return not getGuildSettings(guildName).enabled or not getGuildSettings(guildName).goldDonationFilter.enabled end,
            default = "5000",
            width = "half",
          },
          {
            type    = "editbox",
            name    = SF.func._L("ScrollkeeperProvisionMember", "GOLD_PERIOD"),
            tooltip = SF.func._L("ScrollkeeperProvisionMember", "GOLD_PERIOD_TIP"),
            getFunc = function() return tostring(getGuildSettings(guildName).goldDonationFilter.timePeriodDays) end,
            setFunc = function(v)
              local gs = getGuildSettings(guildName)
              if gs and gs.goldDonationFilter then
                local days = tonumber(v) or 30
                gs.goldDonationFilter.timePeriodDays = math.max(1, math.min(365, days))
              end
            end,
            disabled = function() return not getGuildSettings(guildName).enabled or not getGuildSettings(guildName).goldDonationFilter.enabled end,
            default = "30",
            width = "half",
          },
          {
            type = "header",
            name = SF.func._L("ScrollkeeperProvisionMember", "INACTIVITY_HEADER"),
          },
          {
            type    = "checkbox",
            name    = SF.func._L("ScrollkeeperProvisionMember", "INACTIVITY_ENABLE"),
            tooltip = SF.func._L("ScrollkeeperProvisionMember", "INACTIVITY_ENABLE_TIP"),
            getFunc = function() return getGuildSettings(guildName).inactivityFilter.enabled end,
            setFunc = function(v)
              local gs = getGuildSettings(guildName)
              if gs and gs.inactivityFilter then gs.inactivityFilter.enabled = v end
            end,
            disabled = function() return not getGuildSettings(guildName).enabled end,
            default = false,
          },
          {
            type    = "slider",
            name    = SF.func._L("ScrollkeeperProvisionMember", "INACTIVITY_DAYS"),
            tooltip = SF.func._L("ScrollkeeperProvisionMember", "INACTIVITY_DAYS_TIP"),
            min = 7,
            max = 90,
            step = 1,
            getFunc = function() return getGuildSettings(guildName).inactivityFilter.inactiveDays end,
            setFunc = function(v)
              local gs = getGuildSettings(guildName)
              if gs and gs.inactivityFilter then gs.inactivityFilter.inactiveDays = v end
            end,
            disabled = function() return not getGuildSettings(guildName).enabled or not getGuildSettings(guildName).inactivityFilter.enabled end,
            default = 30,
          },
          {
            type = "header",
            name = SF.func._L("ScrollkeeperProvisionMember", "DONOR_HEADER"),
          },
          {
            type    = "checkbox",
            name    = SF.func._L("ScrollkeeperProvisionMember", "DONOR_ENABLE"),
            tooltip = SF.func._L("ScrollkeeperProvisionMember", "DONOR_ENABLE_TIP"),
            getFunc = function() return getGuildSettings(guildName).donorFilter.enabled end,
            setFunc = function(v)
              local gs = getGuildSettings(guildName)
              if gs and gs.donorFilter then gs.donorFilter.enabled = v end
            end,
            disabled = function() return not getGuildSettings(guildName).enabled end,
            default = false,
          },
          {
            type    = "editbox",
            name    = SF.func._L("ScrollkeeperProvisionMember", "DONOR_AMOUNT"),
            tooltip = SF.func._L("ScrollkeeperProvisionMember", "DONOR_AMOUNT_TIP"),
            getFunc = function() return tostring(getGuildSettings(guildName).donorFilter.minimumAmount) end,
            setFunc = function(v)
              local gs = getGuildSettings(guildName)
              if gs and gs.donorFilter then
                local amount = tonumber(v) or 1000
                gs.donorFilter.minimumAmount = math.max(0, amount)
              end
            end,
            disabled = function() return not getGuildSettings(guildName).enabled or not getGuildSettings(guildName).donorFilter.enabled end,
            default = "1000",
            width = "half",
          },
          {
            type    = "editbox",
            name    = SF.func._L("ScrollkeeperProvisionMember", "DONOR_PERIOD"),
            tooltip = SF.func._L("ScrollkeeperProvisionMember", "DONOR_PERIOD_TIP"),
            getFunc = function() return tostring(getGuildSettings(guildName).donorFilter.timePeriodDays) end,
            setFunc = function(v)
              local gs = getGuildSettings(guildName)
              if gs and gs.donorFilter then
                local days = tonumber(v) or 30
                gs.donorFilter.timePeriodDays = math.max(1, math.min(365, days))
              end
            end,
            disabled = function() return not getGuildSettings(guildName).enabled or not getGuildSettings(guildName).donorFilter.enabled end,
            default = "30",
            width = "half",
          },
          {
            type = "description",
            name = SF.func._L("ScrollkeeperProvisionMember", "GUILD_STATS"),
            text = function()
              local report = PM.getProvisionalReport(guildName)
              if report.totalTracked == 0 then
                return SF.func._L("ScrollkeeperProvisionMember", "NO_MEMBERS")
              end
              local statusText = string.format(SF.func._L("ScrollkeeperProvisionMember", "STATS_FORMAT"),
                report.totalTracked, report.withinProbation, report.overdue, report.promoted)

              if #report.recent > 0 then
                statusText = statusText .. "\n" .. string.format(SF.func._L("ScrollkeeperProvisionMember", "RECENT_ADDITIONS"), #report.recent)
              end

              return statusText
            end,
          },
        }
      }

      table.insert(controls[1].controls, guildSubmenu)
    end
  end

  return controls
end

-- 🚀 Initialize
local function initialize()
  if _addon._initialized then
    return
  end

  -- Initialize LibScroll reference
  libScroll = LibScroll
  if not libScroll then
    d("[ProvisionMember] LibScroll not available - will use basic scrolling")
  end
  
  -- Check framework availability
  if not SF_Set or not SF_Set.RegisterModuleOptions then
    d(SF.func._L("ScrollkeeperProvisionMember", "ERROR_FRAMEWORK_MISSING"))
    return
  end

  -- Single consolidated startup message with all integration info
  local integrations = {}

  -- Check AMT once at startup
  if AMT and AMT.savedData and AMT.GetAmountDonated then
    AMT_Available = true
    table.insert(integrations, "AMT: yes")
  else
    table.insert(integrations, "AMT: no")
  end

  -- Check LibHistoire
  if LibHistoire then
    if histoireReady then
      table.insert(integrations, "LH: yes")
    end
  else
    table.insert(integrations, "LH: no")
  end

  -- Check Data module
  if SF.Data then
    table.insert(integrations, "Data: yes")
  else
    table.insert(integrations, "Data: no")
  end

  d(string.format(SF.func._L("ScrollkeeperProvisionMember", "LOG_INITIALIZING"), table.concat(integrations, " ")))

  -- Register controls
  local controls = buildControls()
  if controls then
    SF_Set.RegisterModuleOptions(_addon.Name, controls)
  end

  -- Register commands
  registerCommands()

  -- Enable event handlers (for real-time join detection only)
  local settings = getSettings()
  if settings and settings.enabled then
    _addon:EnableEvents()
  end

  _addon._initialized = true
end

-- Register for proper initialization
EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_PLAYER_ACTIVATED, function(_, initial)
  if not initial then return end
  EVENT_MANAGER:UnregisterForEvent(_addon.Name, EVENT_PLAYER_ACTIVATED)

  zo_callLater(function()
    initialize()
  end, 1000)
end)

-- Register callback
CALLBACK_MANAGER:RegisterCallback("Scrollkeeper_Initialized", function()
  if not _addon._initialized then
    initialize()
  end
end)