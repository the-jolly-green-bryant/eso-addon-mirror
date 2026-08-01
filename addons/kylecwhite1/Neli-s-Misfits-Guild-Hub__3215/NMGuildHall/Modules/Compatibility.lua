-- Compatibility Module
-- Handles compatibility with other addons and ESO updates

local Addon = NMGuildHall

local Compatibility = {
    -- Version information
    currentVersion = GetAPIVersion(),
    requiredAPIVersion = (Addon and Addon.Constants and Addon.Constants.COMPATIBILITY and Addon.Constants.COMPATIBILITY.REQUIRED_API_VERSION) or 101044,
    
    -- Addon compatibility flags
    addonCompatibility = {
        LibAddonMenu2 = true
    },
    
    -- Feature detection
    features = {},
    
    -- Compatibility warnings
    warnings = {},
    
    initialized = false
}

-- Initialize the compatibility module
function Compatibility:Initialize()
    if self.initialized then
        return
    end
    
    self:CheckAPIVersion()
    self:CheckDependencies()
    self:DetectFeatures()
    self:CheckAddonConflicts()
    
    self.initialized = true
    if Addon and Addon.Debug then
        Addon:Debug(GetString(NMGH_DEBUG_COMPAT_INIT))
    end
end

-- Check API version compatibility
function Compatibility:CheckAPIVersion()
    if self.currentVersion < self.requiredAPIVersion then
        if Addon and Addon.Warn then
            Addon:Warn(GetString(NMGH_COMPAT_API_VERSION_LOW), {
                current = self.currentVersion,
                required = self.requiredAPIVersion
            })
        end
    end
    
    if self.currentVersion > self.requiredAPIVersion + 1000 then
        if Addon and Addon.Warn then
            Addon:Warn(GetString(NMGH_COMPAT_API_VERSION_HIGH), {
                current = self.currentVersion,
                required = self.requiredAPIVersion
            })
        end
    end
end

-- Check required dependencies
function Compatibility:CheckDependencies()
    local dependencies = (Addon and Addon.Constants and Addon.Constants.COMPATIBILITY and Addon.Constants.COMPATIBILITY.DEPENDENCIES) or {
        {name = "LibAddonMenu2", global = "LibAddonMenu2", required = true},
    }

    local function FormatWarning(stringId, params)
        local text = GetString(stringId)
        if Addon and Addon.Message and Addon.Message._FormatPlain then
            return Addon.Message:_FormatPlain(text, params)
        end
        if params then
            for k, v in pairs(params) do
                text = string.gsub(text, "{" .. tostring(k) .. "}", tostring(v))
            end
        end
        return text
    end
    
    for _, dep in ipairs(dependencies) do
        local loaded = _G[dep.global] ~= nil
        
        if not loaded and dep.required then
            if Addon and Addon.Err then
                Addon:Err(GetString(NMGH_COMPAT_DEPENDENCY_MISSING), {name = dep.name})
            end
            table.insert(self.warnings, FormatWarning(NMGH_COMPAT_DEPENDENCY_MISSING, {name = dep.name}))
            self.addonCompatibility[dep.name] = false
        elseif not loaded then
            self.addonCompatibility[dep.name] = false
        else
            self.addonCompatibility[dep.name] = true
        end
    end
end

-- Detect available features
function Compatibility:DetectFeatures()
    -- Check for new API functions
    self.features.chatRouter = CHAT_ROUTER ~= nil
    self.features.newHousingAPI = RequestJumpToHouse ~= nil
    self.features.newTeleportAPI = JumpToGroupMember ~= nil
    self.features.newGuildAPI = GetGuildMemberCharacterInfo ~= nil
    self.features.newFriendAPI = GetFriendCharacterInfo ~= nil
    
    -- Check for Campaign API features
    self.features.campaignPopulation = GetSelectionCampaignPopulationData ~= nil
    self.features.campaignList = GetNumSelectionCampaigns ~= nil

    -- Check for UI improvements
    self.features.backdropUpdates = CT_BACKDROP ~= nil
    self.features.textureUpdates = CT_TEXTURE ~= nil
    self.features.labelUpdates = CT_LABEL ~= nil
    
    -- Log detected features
    if Addon and Addon.Debug then
        Addon:Debug(GetString(NMGH_DEBUG_DETECTED_FEATURES))
        for feature, available in pairs(self.features) do
            Addon:Debug(GetString(NMGH_DEBUG_FEATURE_STATUS), {feature = feature, status = tostring(available)})
        end
    end
end

-- Check for potential addon conflicts
function Compatibility:CheckAddonConflicts()
    -- Reserved for future conflict detection; currently a no-op.
end

-- Check if a feature is available
function Compatibility:IsFeatureAvailable(feature)
    return self.features[feature] == true
end

-- Check if an addon is compatible
function Compatibility:IsAddonCompatible(addonName)
    return self.addonCompatibility[addonName] == true
end

-- Get compatibility warnings
function Compatibility:GetWarnings()
    return self.warnings
end

-- Get the current megaserver (PC-NA or PC-EU)
function Compatibility:GetMegaserver()
    local worldName = GetWorldName()
    
    -- Normalize server names
    if worldName == "NA Megaserver" then
        return "PC-NA"
    elseif worldName == "EU Megaserver" then
        return "PC-EU"
    elseif worldName == "PTS" then
        return "PTS"
    end
    
    -- Fallback detection
    if string.find(worldName, "NA") then
        return "PC-NA"
    elseif string.find(worldName, "EU") then
        return "PC-EU"
    end
    
    return "UNKNOWN"
end

-- Safe wrapper for API calls
function Compatibility:SafeAPICall(apiFunction, ...)
    if not apiFunction or type(apiFunction) ~= "function" then
        if Addon and Addon.Err then
            Addon:Err(GetString(NMGH_ERR_API_NOT_AVAILABLE))
        end
        return nil
    end
    
    local success, result = pcall(apiFunction, ...)
    if not success then
        if Addon and Addon.Err then
            Addon:Err(GetString(NMGH_ERR_API_CALL_FAILED), {error = tostring(result)})
        end
        return nil
    end
    
    return result
end

-- Safe wrapper for optional features/functions.
-- Primary use: gate behavior by a feature key from `self.features`, and call a function if available.
--
-- Supported forms:
-- 1) `SafeFeatureCall("chatRouter", "SomeGlobalFn", fallbackFn, ...)`
-- 2) `SafeFeatureCall("chatRouter", SomeFunction, fallbackFn, ...)`
-- 3) Back-compat: `SafeFeatureCall("SomeGlobalFn", fallbackFn, ...)` (treats feature as "function exists")
function Compatibility:SafeFeatureCall(featureKey, apiFunctionOrName, fallbackFunction, ...)
    -- Back-compat: (globalFnName, fallbackFn, ...)
    if type(apiFunctionOrName) == "function" and fallbackFunction == nil then
        fallbackFunction = apiFunctionOrName
        apiFunctionOrName = nil
    end

    local apiFunction = apiFunctionOrName
    if apiFunction == nil then
        apiFunction = _G[featureKey]
    elseif type(apiFunction) == "string" then
        apiFunction = _G[apiFunction]
    end

    local isFeatureFlagKnown = self.features ~= nil and self.features[featureKey] ~= nil
    local isAvailable = (isFeatureFlagKnown and self.features[featureKey] == true) or (type(apiFunction) == "function")

    if not isAvailable then
        if fallbackFunction and type(fallbackFunction) == "function" then
            return fallbackFunction(...)
        end
        return nil
    end

    if type(apiFunction) == "function" then
        return self:SafeAPICall(apiFunction, ...)
    end

    if fallbackFunction and type(fallbackFunction) == "function" then
        return fallbackFunction(...)
    end
    return nil
end

-- Get compatibility report
function Compatibility:GetCompatibilityReport()
    local report = {
        apiVersion = self.currentVersion,
        requiredVersion = self.requiredAPIVersion,
        addonCompatibility = self.addonCompatibility,
        features = self.features,
        warnings = self.warnings,
        status = "OK"
    }
    
    -- Determine overall status
    if #self.warnings > 0 then
        report.status = "WARNINGS"
    end
    
    -- Check for critical issues
    for addon, compatible in pairs(self.addonCompatibility) do
        if not compatible then
            local dep = nil
            for _, entry in ipairs((Addon and Addon.Constants and Addon.Constants.COMPATIBILITY and Addon.Constants.COMPATIBILITY.DEPENDENCIES) or {
                {name = "LibAddonMenu2", global = "LibAddonMenu2", required = true},
            }) do
                if entry.name == addon then
                    dep = entry
                    break
                end
            end
            
            if dep and dep.required then
                report.status = "ERROR"
                break
            end
        end
    end
    
    return report
end

-- Display compatibility report to user
function Compatibility:DisplayCompatibilityReport()
    local report = self:GetCompatibilityReport()
    
    if report.status == "OK" then
        if Addon and Addon.Msg and Addon.db and Addon.db.debug then
            Addon:Msg(GetString(NMGH_MSG_COMPAT_OK))
        end
        return
    end
    
    if Addon and Addon.Msg then
        Addon:Msg(GetString(NMGH_MSG_COMPAT_STATUS), {status = report.status})
    end
    
        if #report.warnings > 0 then
            if Addon and Addon.Warn then
                Addon:Warn(GetString(NMGH_MSG_COMPAT_WARN_HEADER))
                for _, warning in ipairs(report.warnings) do
                    Addon:Warn(GetString(NMGH_COMPAT_WARNING_BULLET), {warning = warning})
                end
            end
        end
    
    -- Add critical error info
    local missingDeps = {}
    for addon, compatible in pairs(report.addonCompatibility) do
        if not compatible then
            for _, entry in ipairs((Addon and Addon.Constants and Addon.Constants.COMPATIBILITY and Addon.Constants.COMPATIBILITY.DEPENDENCIES) or {}) do
                if entry.name == addon and entry.required then
                    table.insert(missingDeps, addon)
                    break
                end
            end
        end
    end
    
    if #missingDeps > 0 then
        if Addon and Addon.Err then
            Addon:Err(GetString(NMGH_ERR_DEPENDENCIES_MISSING), {deps = table.concat(missingDeps, ", ")})
        end
    end
end

-- Export compatibility module
NMGuildHall = NMGuildHall or {}
NMGuildHall.Compatibility = Compatibility

return Compatibility
