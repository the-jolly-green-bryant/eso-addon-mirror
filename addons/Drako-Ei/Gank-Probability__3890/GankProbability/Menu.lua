local GP = GankProbability
local internal = GP.internal
local LAM = LibAddonMenu2

function internal.initializeMenu()
   

    LAM:RegisterAddonPanel(GP.menuName, {
        type = "panel",
        name = GP.menuName,
        author = GP.author,
    })

    -- Get the names of the prediction models
    local predictionModels = {}
    for k, v in pairs(GP.savedVars.predictionModels) do
        table.insert(predictionModels, k)
    end

    LAM:RegisterOptionControls(GP.menuName, {
        {
            type = "header",
            name = "Gank probability settings",
        },
        {
            type = "checkbox",
            name = "Addon active",
            getFunc = function() return GP.savedVars.active end,
            setFunc = function(value) GP.savedVars.active = value; internal.clearReticle(); if (internal.toggleEvents) then internal.toggleEvents(value) end end
        },
        {
            type = "slider",
            name = "Reticle X",
            tooltip = "Set the X position of the reticle display.",
            min = -500,
            max = 500,
            getFunc = function() return GP.savedVars.reticleX end,
            setFunc = function(value) GP.savedVars.reticleX = value; internal.configureReticleDisplay() end,
            width = "full",
        },
        {
            type = "slider",
            name = "Reticle Y",
            tooltip = "Set the Y position of the reticle display.",
            min = -500,
            max = 500,
            getFunc = function() return GP.savedVars.reticleY end,
            setFunc = function(value) GP.savedVars.reticleY = value; internal.configureReticleDisplay() end,
            width = "full",
        },
        {
            type = "slider",
            name = "Reticle size",
            tooltip = "Set the size of the reticle display.",
            min = 1,
            max = 5,
            getFunc = function() return GP.savedVars.reticleSize end,
            setFunc = function(value) GP.savedVars.reticleSize = value; internal.configureReticleDisplay() end,
            width = "full",
        },
        {
            type = "header",
            name = "Machine learning settings",
        },
        {
            type = "dropdown",
            name = "Model selection",
            tooltip = "Select a model to make predictions.",
            choices = predictionModels,
            getFunc = function() return GP.savedVars.activeModel end,
            setFunc = function(var) GP.savedVars.activeModel = var; internal.initializeModel() end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Data collection",
            tooltip = "Record every gank attempt for better predictions.",
            getFunc = function() return GP.savedVars.dataCollection end,
            setFunc = function(value) GP.savedVars.dataCollection = value end
        },
        {
            type = "description",
            title = nil,
            text = "Leave data collection on to be able to create models tuned to you in the future!",
            width = "full",
        }
    })
    
end