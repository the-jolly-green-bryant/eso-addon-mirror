GuildPlannerPro_Command = {}

function GuildPlannerPro_Command.Handle(...)
    local option = select(1, ...)
    if type(option) == "nil" or option == "" or option == "help" then
        local msg = GetString(GPPRO_COMMAND_HELP_TITLE) .. "\n"
        msg = msg .. "|c009900/gppro reinit|r - " .. GetString(GPPRO_COMMAND_HELP_REINIT) .. "\n"
        msg = msg .. "|c009900/gppro export|r - " .. GetString(GPPRO_COMMAND_HELP_EXPORT) .. "\n"
        msg = msg .. "|c009900/gppro clear|r - " .. GetString(GPPRO_COMMAND_HELP_CLEAR) .. "\n"
        msg = msg .. "|c009900/gppro version|r - " .. GetString(GPPRO_COMMAND_HELP_VERSION)
        GuildPlannerPro_Utils:PrintMessage(msg)
    elseif option == "reinit" then
        GuildPlannerPro_Export:Init()
        GuildPlannerPro_Utils:PrintMessage(GetString(GPPRO_COMMAND_REINIT))
    elseif option == "export" then
        GuildPlannerPro_Export:ExportGameData()
        GuildPlannerPro_Utils:PrintMessage(GetString(GPPRO_COMMAND_EXPORT))
    elseif option == "clear" then
        GuildPlannerPro_Export:ClearGameData()
        GuildPlannerPro_Utils:PrintMessage(GetString(GPPRO_COMMAND_CLEAR))
    elseif option == "version" then
        GuildPlannerPro_Utils:PrintMessage(GetString(GPPRO_COMMAND_ADDON_VERSION) .. " |ceeeeee" .. GuildPlannerPro_Export.AddonVersion .. "|r")
    end
end
