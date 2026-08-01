
--[[
LibLootSummary - ESO Addon Library v4.x

Purpose: Provides a robust API for printing item and loot summaries to chat, 
         supporting integration with LibAddonMenu and LibChatMessage.

Features: 
- Dynamic chat output with configurable formatting
- Multi-language localization support (EN/DE/FR/JP/RU)
- LibAddonMenu integration for settings UI
- Fallback handling for missing translations
- Developer-friendly diagnostics and error handling

Usage: See README.md for integration instructions and example usage.

Technical Notes:
- All major functions are documented inline
- Manifest metadata (version, author, etc.) is auto-assigned by ESO at runtime
- Lint errors for missing ESO globals are expected in local dev, not in-game
- Uses ZO_CreateStringId for proper localization string registration
]]


LibLootSummary = LibLootSummary or {}
local lls = LibLootSummary

--[[
Creates a new LibLootSummary.List instance with optional configuration

@param ... (table|nil) Optional configuration parameters passed to List:Initialize()
@return LibLootSummary.List A new List instance ready for use

Usage:
  local summary = LibLootSummary:New()
  local summary = LibLootSummary:New({ chat = myChat, prefix = "[Loot] " })
]]
function lls:New(...)
    return lls.List:New(...)
end
setmetatable(lls, { __call = function(_, ...) return lls.List:New(...) end })