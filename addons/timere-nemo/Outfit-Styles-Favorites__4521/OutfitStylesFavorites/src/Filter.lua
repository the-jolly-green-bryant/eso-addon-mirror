local OSF = OutfitStylesFavorites

-- Filter.lua
-- Installs a ZO_PreHook on gridListPanelList.AddEntry once at initialisation.
-- When OSF.showFavorites is true the hook drops non-favourite entries before
-- they reach the grid.  Returning true from a ZO_PreHook prevents the original
-- function from running.
--
-- Empty-cell entries added by FillRowWithEmptyCells bypass AddEntry entirely
-- (they go through ZO_ScrollList_AddOperation directly), so they are unaffected
-- by this hook and row-padding is always correct.

function OSF:InitializeFilter()
    local panel    = ZO_OUTFIT_STYLES_PANEL_KEYBOARD
    -- gridListPanelList is set in InitializeGridListPanel and never reassigned,
    -- so this reference stays valid for the lifetime of the session.
    local gridList = panel.gridListPanelList

    ZO_PreHook(gridList, "AddEntry", function(_, data)
        -- When the filter is inactive pass everything through.
        if not OSF.showFavorites then return end
        -- Always pass the clear-slot entry; it has no collectible ID.
        if data.clearAction then return end
        -- Block entries that are not in the favourites set.
        if not OSF:IsFavorite(data:GetId()) then
            return true -- returning true prevents the original AddEntry call
        end
    end)
end
