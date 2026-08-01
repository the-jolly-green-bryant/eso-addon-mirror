LogToggler = LogToggler or {}

function LogToggler.createButton()
    LogToggler.button = LibChatMenuButton.addChatButton("LogTogglerChatButton", LogToggler.buttonIcon(), LogToggler.buttonTooltip(), function() LogToggler.toggleLogs() end)
    LogToggler.updateVisibiliy()
    LogToggler.updateButtonIcon()
end

function LogToggler.toggleLogs()
    if IsEncounterLogEnabled() then
        SetEncounterLogEnabled(false)
        d("Encounter log disabled.")
    else
        SetEncounterLogEnabled(true)
        d("Encounter log enabled.")
    end

    LogToggler.button:edit({["tooltip"] = LogToggler.buttonTooltip()})
    LogToggler.updateButtonIcon()
end

function LogToggler.buttonTooltip()
    if IsEncounterLogEnabled() then
        return "Disable encounter log"
    else
        return "Enable encounter log"
    end
end

function LogToggler.updateButtonIcon()
    local logIcon = "LogToggler/imgs/log_disabled.dds"
    local logHoverIcon ="LogToggler/imgs/log_disabled_hover.dds"

    if IsEncounterLogEnabled() then
        logIcon = "LogToggler/imgs/log_enabled.dds"
        logHoverIcon ="LogToggler/imgs/log_enabled_hover.dds"
    end

    LogToggler.button:edit({["imagePath"] = logIcon})
    LogToggler.button:edit({["imagePathHover"] = logHoverIcon})
end

function LogToggler.buttonIcon()
    return {"LogToggler/imgs/log_disabled.dds","LogToggler/imgs/log_disabled_hover.dds"}
end

function LogToggler.updateVisibiliy()
    if LogToggler.showButton then
        LogToggler.button:show()
    else
        LogToggler.button:hide()
    end
end