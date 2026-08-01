-- =============================================================================
-- === OptimalWeave Localization System (localization.lua)                   ===
-- =============================================================================
--[[
    AddOn Name:         OptimalWeave
    File:               localization.lua
    Description:        Core localization system providing string lookup
                        functionality via ZO_CreateStringId definitions.
                        MUST load after all language files in manifest.
    Dependencies:       lang/*.lua files
    Author:             Orollas & VollständigerName
    Version:            1.17.0
--]]
-- =============================================================================

-- =============================================================================
-- == INITIALIZATION & SAFETY CHECKS ===========================================
-- =============================================================================
local OW = OptimalWeave                         -- Alias for global AddOn table
local NAME = OW.name or "OptimalWeave"          -- Fallback for AddOn name

-- =============================================================================
-- == CORE LOCALIZATION FUNCTIONALITY ==========================================
-- =============================================================================
local _G = _G
local GetString = GetString
local select = select
local format = string.format

OW.L = function(key, ...)
    local stringId = _G[key]

    if not stringId then
        local errorMsg = format(
            "|cFFFF00[%s]|r Warning: Missing localization key |cFF0000'%s'|r",
            NAME,
            tostring(key)
        )

        DEFAULT_CHAT_FRAME:AddMessage(errorMsg, 1.0, 0.82, 0.0)
        return format("|cFF0000[!%s!]|r", key)
    end

    if select("#", ...) > 0 then
        return GetString(stringId, ...)
    end

    return GetString(stringId)
end
-- =============================================================================
-- == END OF LOCALIZATION SYSTEM ===============================================
-- =============================================================================