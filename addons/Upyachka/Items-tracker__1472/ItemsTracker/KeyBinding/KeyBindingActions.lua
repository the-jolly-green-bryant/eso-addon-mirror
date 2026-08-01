-- Implements actions to be binded to any key.
--- Toggles visibility of Info window.
function Up_ItemsTracker.toggleWindow()
    Up_ItemsTracker.UiController:toggleWindow()
end

--- Removes all existing providers.
function Up_ItemsTracker.clean()
    Up_ItemsTracker.ProvidersController:clean()
    Up_ItemsTracker.cleanHistory()
end
