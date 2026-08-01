local FSL = FlowersSheLikes

function FSL.CreateSettingsMenu()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local L = FSL[GetCVar("Language.2")] or FSL["en"]
    
    local panelData = {
        type = "panel",
        name = FSL.name,
        displayName = "|c00FF00Flowers She Likes|r",
        author = "Ayantir & Gemini",
        version = "14.7",
    }

    local optionsData = {
        {
            type = "header",
            name = "Global Colors",
        },
        {
            type = "colorpicker",
            name = L.l1 or "Favorite",
            getFunc = function() return FSL.vars.colors[1].r, FSL.vars.colors[1].g, FSL.vars.colors[1].b, FSL.vars.colors[1].a or 1 end,
            setFunc = function(r, g, b, a) FSL.vars.colors[1] = {r=r, g=g, b=b, a=a} end,
        },
        {
            type = "colorpicker",
            name = L.l2 or "Why Not",
            getFunc = function() return FSL.vars.colors[2].r, FSL.vars.colors[2].g, FSL.vars.colors[2].b, FSL.vars.colors[2].a or 1 end,
            setFunc = function(r, g, b, a) FSL.vars.colors[2] = {r=r, g=g, b=b, a=a} end,
        },
        {
            type = "colorpicker",
            name = L.l3 or "Unimportant",
            getFunc = function() return FSL.vars.colors[3].r, FSL.vars.colors[3].g, FSL.vars.colors[3].b, FSL.vars.colors[3].a or 1 end,
            setFunc = function(r, g, b, a) FSL.vars.colors[3] = {r=r, g=g, b=b, a=a} end,
        },
        {
            type = "header",
            name = "Plant Selection",
        }
    }

    local choices = {L.l1 or "Favorite", L.l2 or "Why Not", L.l3 or "Unimportant"}
    local FlowerList = {
        "Blessed Thistle", "Blue Entoloma", "Bugloss", "Columbine", "Corn Flower",
        "Dragonthorn", "Emetic Russula", "Imp Stool", "Lady's Smock", "Luminous Russula",
        "Mountain Flower", "Namira's Rot", "Nightshade", "Nirnroot", "Stinkhorn",
        "Violet Coprinus", "Water Hyacinth", "White Cap", "Wormwood", "Crimson Nirnroot"
    }

    for i, flowerName in ipairs(FlowerList) do
        table.insert(optionsData, {
            type = "dropdown",
            name = flowerName,
            choices = choices,
            getFunc = function() return (FSL.vars.selections and FSL.vars.selections[i]) or choices[3] end,
            setFunc = function(value) FSL.vars.selections[i] = value end,
            width = "half",
        })
    end

    LAM:RegisterAddonPanel("FSL_Options", panelData)
    LAM:RegisterOptionControls("FSL_Options", optionsData)
end