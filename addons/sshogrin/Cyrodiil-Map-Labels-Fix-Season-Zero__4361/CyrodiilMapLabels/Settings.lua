function CyrodiilMapLabelsAddon.CreateSettingsMenu()
    local lam = LibAddonMenu2
    if not lam then return end
    local db = CyrodiilMapLabelsAddon.db

    local prefix = "SI_CYRODIILMAPLABELS_"

    local panelData = {
        type = "panel",
        name = "Cyrodiil Map Labels", -- Kept as unlocalized string ID identifier to handle LAM caching safety cleanly
        displayName = GetString(_G[prefix .. "title"]), -- Native lookup maps your localized addon title text automatically
        author = "Neurowise & |c2046e5sshogrin|r",
        version = CyrodiilMapLabelsDefaults.version,
        registerForRefresh = true,
    }

    local optionsData = {
       [1] = {
            type = "dropdown",
            name = GetString(_G[prefix .. "nameDropdown"]),
            tooltip = GetString(_G[prefix .. "descDropdown"]),
            choices = {GetString(_G[prefix .. "choiceLong"]), GetString(_G[prefix .. "choiceShort"])},
            getFunc = function() 
                if db.datasetChoice == "Short Names" then return GetString(_G[prefix .. "choiceShort"]) end
                return GetString(_G[prefix .. "choiceLong"])
            end,
            setFunc = function(value) 
                if value == GetString(_G[prefix .. "choiceShort"]) then db.datasetChoice = "Short Names" else db.datasetChoice = "Long Names" end
                CyrodiilMapLabelsAddon.UpdateLabels() 
            end,
            default = CyrodiilMapLabelsDefaults.datasetChoice == "Short Names" and GetString(_G[prefix .. "choiceShort"]) or GetString(_G[prefix .. "choiceLong"]),
        },
       [2] = {
            type = "checkbox",
            name = GetString(_G[prefix .. "nameCheckbox"]),
            tooltip = GetString(_G[prefix .. "descCheckbox"]),
            getFunc = function() if db.useAllianceColors == nil then return true end return db.useAllianceColors end,
            setFunc = function(value) db.useAllianceColors = value CyrodiilMapLabelsAddon.UpdateLabels() end,
            default = CyrodiilMapLabelsDefaults.useAllianceColors,
        },
       [3] = {
            type = "colorpicker",
            name = GetString(_G[prefix .. "nameColor"]),
            tooltip = GetString(_G[prefix .. "descColor"]),
            getFunc = function() return db.fallbackR, db.fallbackG, db.fallbackB end,
            setFunc = function(r, g, b) db.fallbackR, db.fallbackG, db.fallbackB = r, g, b CyrodiilMapLabelsAddon.UpdateLabels() end,
            default = { r = CyrodiilMapLabelsDefaults.fallbackR, g = CyrodiilMapLabelsDefaults.fallbackG, b = CyrodiilMapLabelsDefaults.fallbackB },
        },
       [4] = {
            type = "slider",
            name = GetString(_G[prefix .. "nameSlider"]),
            tooltip = GetString(_G[prefix .. "descSlider"]),
            min = 0.5, max = 2.0, step = 0.1, decimals = 1,
            getFunc = function() return db.fontScale or CyrodiilMapLabelsDefaults.fontScale end,
            setFunc = function(value) db.fontScale = value CyrodiilMapLabelsAddon.UpdateLabels() end,
            default = CyrodiilMapLabelsDefaults.fontScale,
        },
    }

    lam:RegisterAddonPanel("CyrodiilMapLabelsOptions", panelData)
    lam:RegisterOptionControls("CyrodiilMapLabelsOptions", optionsData)
end
