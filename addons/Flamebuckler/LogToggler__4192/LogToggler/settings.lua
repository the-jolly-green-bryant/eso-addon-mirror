LogToggler = LogToggler or {}

LogToggler.showButtonDefault = true

function LogToggler.createSettings()
    local LAM = LibAddonMenu2
    local panelName =  LogToggler.name.." - Options"

    local panelData = {
        type = "panel",
        name = LogToggler.name,
        author = "@Flamebuckler",
    }
    
    LAM:RegisterAddonPanel(panelName, panelData)

    local optionsData = {
        {
            type = "checkbox",
            name = "Show button",
            tooltip = "Shows the chat windows button",
            getFunc = function() return LogToggler.getShowButton() end,
            setFunc = function(value) LogToggler.setShowButton(value) end
        }
    }

    LAM:RegisterOptionControls(panelName, optionsData)
end

function LogToggler.loadSavedData()
    if LogToggler.savedVars.showButton == nil then
        LogToggler.showButton = LogToggler.showButtonDefault
    else
        LogToggler.showButton = LogToggler.savedVars.showButton
    end
end

function LogToggler.setShowButton(value)
    LogToggler.showButton = value
	LogToggler.savedVars.showButton = value
    LogToggler.updateVisibiliy()
end

function LogToggler.getShowButton()
    return LogToggler.showButton
end