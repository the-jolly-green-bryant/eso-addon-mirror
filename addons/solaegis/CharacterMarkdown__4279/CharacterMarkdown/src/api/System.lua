-- CharacterMarkdown - API Layer - System
-- Abstraction for System, Events, and metadata

local CM = CharacterMarkdown
CM.api = CM.api or {}
CM.api.system = {}

local api = CM.api.system

-- =====================================================
-- SYSTEM / METADATA
-- =====================================================

function api.GetAPIVersion()
    return CM.SafeCall(GetAPIVersion) or 0
end

function api.GetAddOnMetadata(name, field)
    if GetAddOnMetadata then
        return GetAddOnMetadata(name, field)
    end
    return nil
end

function api.Print(msg)
    if d then
        d(msg)
    end
end

-- Composition functions moved to collector level

CM.DebugPrint("API", "System API module loaded")
