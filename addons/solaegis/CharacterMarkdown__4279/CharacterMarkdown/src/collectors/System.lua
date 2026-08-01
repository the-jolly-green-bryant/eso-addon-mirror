-- CharacterMarkdown - System Data Collector
-- Composition logic moved from API layer

local CM = CharacterMarkdown

local function CollectSystemData()
    -- Use API layer granular functions
    local apiVersion = CM.api.system.GetAPIVersion()
    local timestamp = CM.api.time.GetNow()
    local dateStr = CM.api.time.FormatDate(timestamp)

    -- Addon Metadata
    local addonName = "CharacterMarkdown"
    local addonVersion = CM.api.system.GetAddOnMetadata(addonName, "Version") or "Unknown"
    local addonAuthor = CM.api.system.GetAddOnMetadata(addonName, "Author") or "Unknown"

    local data = {
        addon = {
            name = addonName,
            version = addonVersion,
            author = addonAuthor,
            apiVersion = apiVersion,
        },
        time = {
            timestamp = timestamp,
            formatted = dateStr,
        },
    }

    CM.DebugPrint("COLLECTOR", "System data collected")
    return data
end

CM.collectors.CollectSystemData = CollectSystemData

CM.DebugPrint("COLLECTOR", "System collector module loaded")
