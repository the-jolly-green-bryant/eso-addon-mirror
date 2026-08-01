-- =============================================================================
-- === PerfectedWeave Localization System (localization.lua)                   ===
-- =============================================================================
--[[
    AddOn Name:         PerfectedWeave
    File:               localization.lua
    Description:        Core localization system providing string lookup
                        functionality via ZO_CreateStringId definitions.
                        MUST load after all language files in manifest.
    Dependencies:       lang/*.lua files
    Author:             Orollas, VollständigerName, mYoda01
    Version:            1.2.0
--]]
-- =============================================================================

-- =============================================================================
-- == INITIALIZATION & SAFETY CHECKS ===========================================
-- =============================================================================

-- Create fallback table if not exists -----------------------------------------
--if not PerfectedWeave then PerfectedWeave = {} end  -- Global namespace protection

-- Create local references -----------------------------------------------------
local PW = PerfectedWeave                         -- Alias for global AddOn table
local NAME = PW.name or "PerfectedWeave"          -- Fallback for AddOn name

-- =============================================================================
-- == CORE LOCALIZATION FUNCTIONALITY ==========================================
-- =============================================================================

--------------------------------------------------------------------------------
-- Localization master function with error handling and string formatting
-- @function PW.L
-- @description Primary localization access point handling:
--              - String ID validation
--              - Error reporting for missing keys
--              - Dynamic string formatting
-- @param key string - ZO_CreateStringId identifier (case-sensitive)
-- @param ... any - Optional format arguments (supports %s, %d, etc.)
-- @return string - Localized text or error placeholder
--------------------------------------------------------------------------------
PW.L = function(key, ...)
    -- Validate key existence --------------------------------------------------
    if _G[key] == nil then  -- Check global namespace for string ID registration
        -- Create error message with colored prefix
        local errorMsg = string.format(
            "|cFFFF00[%s]|r Warning: Missing localization key |cFF0000'%s'|r",
            NAME,
            tostring(key)
        )
        
        -- Print to chat console for debugging
        DEFAULT_CHAT_FRAME:AddMessage(errorMsg, 1.0, 0.82, 0.0)  -- Gold color
        
        -- Return visible placeholder for UI elements
        return string.format("|cFF0000[!%s!]|r", key)
    end

    -- Retrieve and format string ----------------------------------------------
    local stringId = _G[key]              -- Get registered string ID
    local formatArgs = { ... }            -- Capture variable arguments
    
    -- Format string only if arguments exist
    local formattedString
    if #formatArgs > 0 then
        formattedString = GetString(stringId, unpack(formatArgs))  -- ESO API call with args
    else
        formattedString = GetString(stringId)  -- Simple string without formatting
    end
    
    -- Return final processed string
    return formattedString
end

-- =============================================================================
-- == END OF LOCALIZATION SYSTEM ===============================================
-- =============================================================================