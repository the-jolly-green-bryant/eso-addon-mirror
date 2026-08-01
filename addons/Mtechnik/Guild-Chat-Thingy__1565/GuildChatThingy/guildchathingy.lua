-- Calling the Library with the Slashcommander Functions
local LSC = LibStub("LibSlashCommander")

-- Starting my own Functions to get the party jumping!
local function Send(stringID)
    local myText = GetString(stringID)
    StartChatInput(myText)
end

-- List of commands, in an Mtechnik Language!
-- local command = LSC:Register()
--     command:AddAlias("/vg")
--     command:SetCallback(function() end)
--     command:SetDescription("This is for DeadShits")
--    command:SetDescription("List of Guild Chat Commands")

local command1 = LSC:Register()
    command1:AddAlias("/vgwelcome")
    command1:SetCallback(function() Send(SI_GUILDCHATTHINGY_VGWELCOME) end)
    command1:SetDescription("Welcome Message")

local command2 = LSC:Register()
    command2:AddAlias("/vgcommunicate")
    command2:SetCallback(function() Send(SI_GUILDCHATTHINGY_VGCOMMUNICATE) end)
    command2:SetDescription("Voice Server Info")

local command3 = LSC:Register()
    command3:AddAlias("/vggpanel")
    command3:SetCallback(function() Send(SI_GUILDCHATTHINGY_VGPANEL) end)
    command3:SetDescription("Guild Panel Reminder")

local command4 = LSC:Register()
    command4:AddAlias("/rl")
    command4:SetCallback(function() Send(reloadui) end)
    command4:SetDescription("Reloads the UI")
