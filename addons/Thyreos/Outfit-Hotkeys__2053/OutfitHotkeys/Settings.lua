-- Settings menu.
function OutfitHotkeys.LoadSettings()
    local LAM = LibStub("LibAddonMenu-2.0")

    local panelData = {
        type = "panel",
        name = OutfitHotkeys.menuName,
        displayName = OutfitHotkeys.menuName,
        author = OutfitHotkeys.author,
        -- version = OutfitHotkeys.version,
        slashCommand = "/ofhk",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    LAM:RegisterAddonPanel(OutfitHotkeys.menuName, panelData)

    local optionsTable = {
        [1] = {
            type = "header",
            name = "Options",
            width = "full",	--or "half" (optional)
        },
        [2] = {
            type = "description",
            title = nil,	--(optional)
            text = "At the time of this writing, there is a bug effecting some players where a wrong outfit is displayed on the player after zoning. Enable the option below to automatically re-equip the outfit you had on before zoning.",
            --text = "text",
            width = "full",	--or "half" (optional)
        },
        [3] = {
            type = "checkbox",
            name = "Restore Outfit after Zoning",
            getFunc = function() return OutfitHotkeys.savedVariables.restoreOutfit end,
            setFunc = function(value) OutfitHotkeys.savedVariables.restoreOutfit = value end,
            width = "full", --or "half" (optional)
        },
        [4] = {
            type = "header",
            name = "Mementos",
            width = "full", --or "half" (optional)
        },
        [5] = {
            type = "description",
            title = nil,    --(optional)
            text = GetString(SI_OUTFITHOTKEYS_MENU_MEMENTO_SECTION_DESCRIPTION),
            --text = "text",
            width = "full", --or "half" (optional)
        },
        [6] = {
            type = "dropdown",
            name = GetString(SI_OUTFITHOTKEYS_MENU_MEMENTO_UNEQUIP_OUTFIT),
            choices = OutfitHotkeys.GetMementoNames(),
            choicesValues = OutfitHotkeys.GetMementoIds(),
            getFunc = function() return OutfitHotkeys.savedVariables.mementoMap[0] end,
            setFunc = function(var) OutfitHotkeys.savedVariables.mementoMap[0] = var end,
            width = "full", --or "half" (optional)
            scrollable = true,
        },        
        [7] = {
            type = "dropdown",
            name = GetString(SI_OUTFITHOTKEYS_MENU_MEMENTO_OUTFIT01),
            choices = OutfitHotkeys.GetMementoNames(),
            choicesValues = OutfitHotkeys.GetMementoIds(),
            getFunc = function() return OutfitHotkeys.savedVariables.mementoMap[1] end,
            setFunc = function(var) OutfitHotkeys.savedVariables.mementoMap[1] = var end,
            width = "full", --or "half" (optional)
            scrollable = true,
        },        
        [8] = {
            type = "dropdown",
            name = GetString(SI_OUTFITHOTKEYS_MENU_MEMENTO_OUTFIT02),
            choices = OutfitHotkeys.GetMementoNames(),
            choicesValues = OutfitHotkeys.GetMementoIds(),
            getFunc = function() return OutfitHotkeys.savedVariables.mementoMap[2] end,
            setFunc = function(var) OutfitHotkeys.savedVariables.mementoMap[2] = var end,
            width = "full", --or "half" (optional)
            scrollable = true,
        },        
        [9] = {
            type = "dropdown",
            name = GetString(SI_OUTFITHOTKEYS_MENU_MEMENTO_OUTFIT03),
            choices = OutfitHotkeys.GetMementoNames(),
            choicesValues = OutfitHotkeys.GetMementoIds(),
            getFunc = function() return OutfitHotkeys.savedVariables.mementoMap[3] end,
            setFunc = function(var) OutfitHotkeys.savedVariables.mementoMap[3] = var end,
            width = "full", --or "half" (optional)
            scrollable = true,
        },        
        [10] = {
            type = "dropdown",
            name = GetString(SI_OUTFITHOTKEYS_MENU_MEMENTO_OUTFIT04),
            choices = OutfitHotkeys.GetMementoNames(),
            choicesValues = OutfitHotkeys.GetMementoIds(),
            getFunc = function() return OutfitHotkeys.savedVariables.mementoMap[4] end,
            setFunc = function(var) OutfitHotkeys.savedVariables.mementoMap[4] = var end,
            width = "full", --or "half" (optional)
            scrollable = true,
        },        
        [11] = {
            type = "dropdown",
            name = GetString(SI_OUTFITHOTKEYS_MENU_MEMENTO_OUTFIT05),
            choices = OutfitHotkeys.GetMementoNames(),
            choicesValues = OutfitHotkeys.GetMementoIds(),
            getFunc = function() return OutfitHotkeys.savedVariables.mementoMap[5] end,
            setFunc = function(var) OutfitHotkeys.savedVariables.mementoMap[5] = var end,
            width = "full", --or "half" (optional)
            scrollable = true,
        },        
        [12] = {
            type = "dropdown",
            name = GetString(SI_OUTFITHOTKEYS_MENU_MEMENTO_OUTFIT06),
            choices = OutfitHotkeys.GetMementoNames(),
            choicesValues = OutfitHotkeys.GetMementoIds(),
            getFunc = function() return OutfitHotkeys.savedVariables.mementoMap[6] end,
            setFunc = function(var) OutfitHotkeys.savedVariables.mementoMap[6] = var end,
            width = "full", --or "half" (optional)
            scrollable = true,
        },        
    }
    LAM:RegisterOptionControls(OutfitHotkeys.menuName, optionsTable)
end