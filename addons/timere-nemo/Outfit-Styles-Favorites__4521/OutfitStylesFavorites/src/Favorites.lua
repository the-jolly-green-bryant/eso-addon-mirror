local OSF = OutfitStylesFavorites

-- Favorites.lua
-- Persistent storage of favorited style IDs.
-- Provides IsFavorite, AddFavorite, RemoveFavorite.
-- styleKey = collectibleData:GetId()  (integer, account-wide stable)

local DEFAULTS = {
    favorites = {},
}

function OSF:InitializeSavedVars()
    self.savedVars = ZO_SavedVars:NewAccountWide("OutfitStylesFavorites_SavedVars", 1, nil, DEFAULTS, GetWorldName())
end

-- Returns true when the given style ID is marked as a favorite.
-- savedVars is nil until InitializeSavedVars runs; guard defensively so a future
-- change to initialization order does not produce a hard crash.
function OSF:IsFavorite(styleKey)
    if not self.savedVars then return false end
    return self.savedVars.favorites[styleKey] == true
end

function OSF:AddFavorite(styleKey)
    self.savedVars.favorites[styleKey] = true
    self:RefreshPanel()
end

function OSF:RemoveFavorite(styleKey)
    self.savedVars.favorites[styleKey] = nil
    self:RefreshPanel()
end

-- Trigger a grid rebuild when the favorites set changes.
-- retainScrollPosition=true so the user stays at the same place in the list.
function OSF:RefreshPanel()
    local panel = ZO_OUTFIT_STYLES_PANEL_KEYBOARD
    if panel and panel.fragment:IsShowing() then
        panel:RefreshVisible(true)
    end
end
