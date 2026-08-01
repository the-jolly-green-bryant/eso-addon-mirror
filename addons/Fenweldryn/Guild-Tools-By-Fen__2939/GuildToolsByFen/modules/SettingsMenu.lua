GuildToolsByFenInternals.SettingsMenu = {}
local SettingsMenu = GuildToolsByFenInternals.SettingsMenu
local langStrings = GuildToolsByFenInternals.langStrings
local lang = GuildToolsByFenInternals.lang

function SettingsMenu.InitAddonMenu()
    local panelData = {
        type = "panel",
        name = GuildToolsByFenInternals.title,
        author = GuildToolsByFenInternals.author,
        version = GuildToolsByFenInternals.version,
    }    
    local optionsData = {
        {
            type = "submenu",
            name = langStrings[lang].inviteMessage,
            controls = {
                {
                    type = "description",
                    text = [[To use type |cff0000/gtfinvite|r to paste it to the current chat. Requires pressing enter after message is pasted.]],    
                },
                {
                    type = "editbox",
                    name = 'message',
                    getFunc = function() return GuildToolsByFenSettings.inviteMessage or "" end,
                    setFunc = function(text) GuildToolsByFenSettings.inviteMessage = text end,
                    isMultiline = true,
                    width = "full",
                },      
            }
        }
        
    }
    
    LibAddonMenu2:RegisterAddonPanel(GuildToolsByFenInternals.title, panelData)
    LibAddonMenu2:RegisterOptionControls(GuildToolsByFenInternals.title, optionsData)
end