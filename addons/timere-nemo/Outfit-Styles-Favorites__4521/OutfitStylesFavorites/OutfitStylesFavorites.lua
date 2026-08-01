-- OutfitStylesFavorites
-- Extends the Outfit Styles panel with a favorites system:
--   - "Show Favorites" checkbox that filters the grid to favorited styles only
--   - Right-click context menu items to add / remove favorites
--   - Gold-star badge on favorited entries when the filter is off
--   - Account-wide persistent storage via ZO_SavedVars

OutfitStylesFavorites = OutfitStylesFavorites or {}
local OSF = OutfitStylesFavorites

-- Runtime filter state; not persisted (defaults to off each session so the
-- player never logs in to a silently filtered grid).
OSF.showFavorites = false

local function OnAddOnLoaded(_, addonName)
    if addonName ~= "OutfitStylesFavorites" then return end
    EVENT_MANAGER:UnregisterForEvent("OutfitStylesFavorites", EVENT_ADD_ON_LOADED)

    OSF:InitializeSavedVars()   -- src/Favorites.lua  – must come first
    OSF:InitializeFilter()      -- src/Filter.lua
    OSF:InitializeCheckbox()    -- src/Checkbox.lua
    OSF:InitializeContextMenu() -- src/ContextMenu.lua
    OSF:InitializeHighlight()   -- src/Highlight.lua
end

EVENT_MANAGER:RegisterForEvent("OutfitStylesFavorites", EVENT_ADD_ON_LOADED, OnAddOnLoaded)
