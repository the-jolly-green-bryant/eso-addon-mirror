local OSF = OutfitStylesFavorites

-- ContextMenu.lua
-- Injects "Add to Favorites" / "Remove from Favorites" into the right-click menu
-- for outfit style cells.
--
-- Hook strategy: ZO_PostHook on OnOutfitStyleEntryRightClick
-- ----------------------------------------------------------
-- The base-game handler calls ClearMenu(), AddMenuItem() × N, then ShowMenu().
-- Our ZO_PostHook fires after all of that.  We append our item with AddMenuItem
-- and call ShowMenu again to redisplay the menu with the extra entry.
--
-- The hook guards against isEmptyCell and clearAction entries — identical to the
-- conditions the base function uses before adding its own items — so we never
-- inject into an irrelevant menu and never touch ShowMenu globally.

function OSF:InitializeContextMenu()
    ZO_PostHook(ZO_OUTFIT_STYLES_PANEL_KEYBOARD, "OnOutfitStyleEntryRightClick",
        function(panel, entryData)
            local collectibleData = entryData.data
            if not collectibleData or collectibleData.isEmptyCell or collectibleData.clearAction then
                return
            end

            local styleKey = collectibleData:GetId()

            if OSF:IsFavorite(styleKey) then
                AddMenuItem(GetString(SI_OSF_REMOVE_FAVORITE), function()
                    OSF:RemoveFavorite(styleKey)
                end)
            else
                AddMenuItem(GetString(SI_OSF_ADD_FAVORITE), function()
                    OSF:AddFavorite(styleKey)
                end)
            end

            ShowMenu(panel.control)
        end
    )
end
