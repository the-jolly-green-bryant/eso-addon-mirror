-- Settings menu.
function RoleplayMarker.LoadSettings()
    local LAM = LibAddonMenu2

    local panelData = {
        type = "panel",
        name = RoleplayMarker.menuName,
        displayName = RoleplayMarker.Colorize(RoleplayMarker.menuName),
        author = RoleplayMarker.Colorize(RoleplayMarker.author, "AAF0BB"),
        registerForRefresh = true,
        registerForDefaults = true,
    }
    LAM:RegisterAddonPanel(RoleplayMarker.menuName, panelData)

    local optionsTable = {}

    table.insert(
        optionsTable,
        {
            type = "checkbox",
            name = "Account Wide",
            tooltip = "Use the same settings throughout the entire account - instead of per character.",
            getFunc = function()
                return RoleplayMarker.savedVars.accountWide
            end,
            setFunc = function(v)
                RoleplayMarker.characterSavedVars.accountWide = v
                RoleplayMarker.accountSavedVars.accountWide = v
            end,
            width = "full", --or "half",
            requiresReload = true,
        }
    )

    -- Category. --
    table.insert(optionsTable, {
        type = "header",
        name = ZO_HIGHLIGHT_TEXT:Colorize("Settings"),
        width = "full",	--or "half" (optional)
    })

    table.insert(optionsTable, {
        type = "checkbox",
        name = "Override character title.",
        tooltip = "Marks character and replaces the title "..RoleplayMarker.markerTitle.." with Roleplayer.",
        getFunc = function() return RoleplayMarker.savedVars.markedByTitle end,
        setFunc = function(v) RoleplayMarker.savedVars.markedByTitle = v end,
        width = "half",	--or "half" (optional)
    })

    table.insert(optionsTable, {
        type = "colorpicker",
        name = "Colorize target frame marker icon.",
        tooltip = "Multiply the icon's color with this color. Pick White for original color.",
        getFunc = function() return unpack(RoleplayMarker.savedVars.markerTextureColor) end,
        setFunc = function(r,g,b,a)
            RoleplayMarker.savedVars.markerTextureColor = {r,g,b,a}
            RoleplayMarkerSettingsIconTexture['texture']:SetColor(r,g,b,a)
        end,
        width = "half",	--or "half" (optional)
    })

    table.insert(optionsTable, {
        type = "texture",
        image = RoleplayMarker.markerTexture,
        imageWidth = 64,	--max of 250 for half width, 510 for full
        imageHeight = 64,	--max of 100
        tooltip = "Preview of icon identifying roleplayers.",	--(optional)
        width = "full",	--or "half" (optional)
        reference = "RoleplayMarkerSettingsIconTexture",
    })

    LAM:RegisterOptionControls(RoleplayMarker.menuName, optionsTable)
end