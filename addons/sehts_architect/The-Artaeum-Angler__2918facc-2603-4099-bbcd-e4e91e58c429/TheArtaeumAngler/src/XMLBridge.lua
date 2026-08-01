local Addon = TheArtaeumAngler

-- luacheck: push ignore 111
function TheArtaeumAngler_UI_OnInitialized(control)
    if Addon and Addon.UI and Addon.UI.Initialize then
        Addon.UI.Initialize(control)
    end
end
-- luacheck: pop
