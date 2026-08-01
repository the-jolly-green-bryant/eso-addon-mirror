-- * _ANDY_VERSION: 1.0.0 ** Please do not modify this line.
--[[----------------------------------------------------------
	AddonAnalyzer (ANDY)
  ----------------------------------------------------------
  *
	* Authors:
	* - Lent (IGN @CallMeLent, Github @adefee)
  *
  * Contents (core scan functions used by Andy):
  * - isEmpty()
  *
]]--

Andy = Andy or {}
local AndyUtil = AndyUtil or {}

-- getInstalledAddons()
-- Get a list of installed addons
function Andy.getInstalledAddons()
  local addons = {}
  local AddOnManager = GetAddOnManager()
  local numAddons = AddOnManager:GetNumAddOns()
  
  Andy.debugLog('Scanning ' .. numAddons .. ' installed addons...')
  
  for i = 1, numAddons do
    local name, title, author, description, enabled, state, isOutOfDate = AddOnManager:GetAddOnInfo(i)
    
    if name and enabled then
      -- Get version from manifest
      local version = AddOnManager:GetAddOnVersion(i)
      
      table.insert(addons, {
        name = name,
        title = title,
        author = author,
        version = version,
        enabled = enabled,
        isOutOfDate = isOutOfDate
      })
    end
  end
  
  Andy.debugLog('Found ' .. #addons .. ' enabled addons')
  return addons
end

-- scanSingleAddon()
-- Given a single addon, see if it's in our AddonWatchlistDb or AuthorWatchlistDb
function Andy.scanSingleAddon(addonData)
  if not addonData or not addonData.name then
    return nil
  end
  
  -- Normalize the addon name for case-insensitive comparison
  local normalizedName = AndyUtil.normalizeAddonName(addonData.name)
  
  -- First, check against addon watchlist
  for watchlistAddonName, watchlistInfo in pairs(Andy.AddonWatchlistDb) do
    local normalizedWatchlistName = AndyUtil.normalizeAddonName(watchlistAddonName)
    
    if normalizedName == normalizedWatchlistName then
      -- Check if this entry is for the current platform
      if not AndyUtil.isPlatformMatch(watchlistInfo.platform) then
        Andy.debugLog('Skipping ' .. addonData.name .. ' - platform mismatch')
        return nil
      end
      
      -- Found a match! Now check version
      if watchlistInfo.allVersions then
        -- All versions are flagged
        return {
          found = true,
          flaggedBy = "addon",
          addonName = addonData.name,
          version = addonData.version,
          reason = watchlistInfo.reason,
          description = watchlistInfo.description,
          reportedDate = watchlistInfo.reportedDate,
          platform = watchlistInfo.platform
        }
      elseif watchlistInfo.versions and addonData.version then
        -- Check if this specific version is flagged
        for _, badVersion in ipairs(watchlistInfo.versions) do
          if addonData.version == badVersion then
            return {
              found = true,
              flaggedBy = "addon",
              addonName = addonData.name,
              version = addonData.version,
              reason = watchlistInfo.reason,
              description = watchlistInfo.description,
              reportedDate = watchlistInfo.reportedDate,
              platform = watchlistInfo.platform
            }
          end
        end
      end
    end
  end
  
  -- Second, check against author watchlist
  if addonData.author then
    local normalizedAuthor = AndyUtil.normalizeAuthorName(addonData.author)
    
    for watchlistAuthor, watchlistInfo in pairs(Andy.AuthorWatchlistDb) do
      local normalizedWatchlistAuthor = AndyUtil.normalizeAuthorName(watchlistAuthor)
      
      -- Check if the watchlist author appears anywhere in the addon author string
      -- This catches variations like "@UserName", "by UserName", "[UserName]", etc.
      if normalizedWatchlistAuthor ~= "" and string.find(normalizedAuthor, normalizedWatchlistAuthor, 1, true) then
        -- Check if this entry is for the current platform
        if not AndyUtil.isPlatformMatch(watchlistInfo.platform) then
          Andy.debugLog('Skipping author ' .. addonData.author .. ' - platform mismatch')
          return nil
        end
        
        Andy.debugLog('Author match found in addon "' .. addonData.name .. '": "' .. normalizedWatchlistAuthor .. '" in "' .. normalizedAuthor .. '"')
        
        -- Found a flagged author!
        return {
          found = true,
          flaggedBy = "author",
          addonName = addonData.name,
          author = addonData.author,
          version = addonData.version,
          reason = watchlistInfo.reason,
          description = watchlistInfo.description,
          reportedDate = watchlistInfo.reportedDate,
          platform = watchlistInfo.platform
        }
      end
    end
  end
  
  -- No match found
  return nil
end

-- quickScanAllAddons()
-- Called on UI load, gets list of addons and scans each against AddonWatchlistDb
-- @param isManualScan (boolean, optional) - If true, bypass suppress settings and show all results
function Andy.quickScanAllAddons(isManualScan)

  -- Get all installed addons
  local installedAddons = Andy.getInstalledAddons()
  local flaggedAddons = {}
  
  -- Scan each addon
  for _, addon in ipairs(installedAddons) do
    local scanResult = Andy.scanSingleAddon(addon)
    if scanResult then
      table.insert(flaggedAddons, scanResult)
    end
  end
  
  -- Check if we should suppress warnings based on suppress settings
  local shouldShowWarnings = true
  local newAddonsFound = {}
  local versionChanged = false
  
  -- Manual scans always show warnings, regardless of suppress settings
  if isManualScan then
    Andy.debugLog('Manual scan requested - bypassing suppress settings')
    shouldShowWarnings = true
  elseif Andy.saved and Andy.saved.ignore and Andy.saved.ignore.enabled then
    Andy.debugLog('Suppress mode is enabled, checking for new addons or version changes...')
    
    -- Check if version has changed
    if Andy.saved.ignore.versionWhenIgnored and Andy.versionESO ~= Andy.saved.ignore.versionWhenIgnored then
      versionChanged = true
      Andy.debugLog('Version changed from ' .. Andy.saved.ignore.versionWhenIgnored .. ' to ' .. Andy.versionESO)
    end
    
    -- Check for new flagged addons not in the ignored list
    for _, result in ipairs(flaggedAddons) do
      local wasIgnored = false
      for _, ignoredAddon in ipairs(Andy.saved.ignore.flaggedAddons) do
        if result.addonName == ignoredAddon then
          wasIgnored = true
          break
        end
      end
      
      if not wasIgnored then
        table.insert(newAddonsFound, result)
      end
    end
    
      -- Determine if we should show warnings
    if #newAddonsFound == 0 and not versionChanged then
      shouldShowWarnings = false
      Andy.debugLog('No new addons found and version unchanged. Warnings suppressed.')
    else
      -- Auto re-enable monitoring if version changed or new addons found
      Andy.saved.ignore.enabled = false
      Andy.debugLog('New conditions detected. Re-enabling monitoring.')
    end
  end
  
  -- Log results to chat
  if #flaggedAddons > 0 and shouldShowWarnings then
    -- Play warning sound if enabled
    if Andy.saved and Andy.saved.enable and Andy.saved.enable.playSound > 0 then
      AndyUtil.PlayAlertSound()
    end
    
    -- Show banner message if enabled
    if Andy.saved and Andy.saved.enable and Andy.saved.enable.showBanner > 0 then
      local bannerMessage = "Andy: " .. #flaggedAddons .. " Flagged Addon" .. (#flaggedAddons > 1 and "s" or "") .. " Detected!"
      
      AndyUtil.PlayAlertBanner(bannerMessage)
    end
    
    -- Show reason for alert if coming out of suppress mode
    if #newAddonsFound > 0 or versionChanged then
      local reasons = {}
      if #newAddonsFound > 0 then
        table.insert(reasons, #newAddonsFound .. ' new flagged addon(s) detected')
      end
      if versionChanged then
        table.insert(reasons, 'Andy was updated')
      end
      d('|cFF0000[Andy WARNING]|r Alert triggered: ' .. table.concat(reasons, ' and '))
    end

    d('|cFF0000-----------------')
    
    d('|cFF0000[WARNING]|r Andy Found ' .. #flaggedAddons .. ' flagged addon(s):')
    
    for _, result in ipairs(flaggedAddons) do
      local reasonLabel = Andy.ReasonLabels[result.reason] or result.reason
      local versionText = result.version and (' v' .. result.version) or ''
      
      -- Mark new addons with an indicator
      local newIndicator = ""
      for _, newAddon in ipairs(newAddonsFound) do
        if newAddon.addonName == result.addonName then
          newIndicator = " |cFF0000[NEW]|r"
          break
        end
      end
      
      if result.flaggedBy == "author" then
        -- Flagged by author
        d('  |cFF8800' .. result.addonName .. versionText .. '|r' .. newIndicator .. ' - Flagged author: |cFF4444' .. (result.author or "Unknown") .. '|r (' .. reasonLabel .. ')')
      else
        -- Flagged by addon name
        d('  |cFF8800' .. result.addonName .. versionText .. '|r' .. newIndicator .. ' - Flagged as: ' .. reasonLabel)
      end
      
      if result.description then
        d('    ' .. result.description)
      end
    end
    
    d('|cFFFF00Please review these addons and consider removing them.|r')
    if not isManualScan then
      d('|cAAAAAATip: Use |cFFFFFF/andy suppress|r to suppress warnings until a new flagged addon is detected.')
    end

    d('|cFF0000-----------------')
  elseif #flaggedAddons > 0 and not shouldShowWarnings then
    Andy.debugLog('Warnings suppressed due to suppress mode Run /andy monitor to re-enable warnings.')
  else
    -- Only show "all clear" message if quiet mode is off
    if not Andy.saved or not Andy.saved.enable or Andy.saved.enable.quietMode == 0 then
      d('|cFF8800[Andy]|r No flagged addons found - all clear!')
      if not isManualScan then
        d('|cAAAAAATip: Use |cFFFFFF/andy quiet|r to suppress this message when no flagged addons are found.')
      end
    end
  end
  
  return flaggedAddons
end

Andy = Andy or {}
