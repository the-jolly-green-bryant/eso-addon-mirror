if FCOStarveStop == nil then FCOStarveStop = {} end
local FCOSS = FCOStarveStop

------------------------------------------------------------------------------------------------------------
-- Slash chat commands
------------------------------------------------------------------------------------------------------------
--Check the commands ppl type to the chat
local function command_handler(args)
    --Parse the arguments string
    local options = {}
    local searchResult = { string.match(args, "^(%S*)%s*(.-)$") }
    for i,v in pairs(searchResult) do
        if (v ~= nil and v ~= "") then
            options[i] = string.lower(v)
        end
    end
    --Debug mode
    if (options[1] ~= nil and (options[1] == "debug")) then
        FCOSS.debug = not FCOSS.debug
        d(FCOSS.locVars.preChatTextBlue .. FCOSS.localizationVars.fco_ss_loc["debugMode_"..tostring(FCOSS.debug)])
    end
end

--Register the slash commands
function FCOSS.RegisterSlashCommands()
    -- Register slash commands
    SLASH_COMMANDS["/fcostarevstop"]	= command_handler
    SLASH_COMMANDS["/fcoss"]			= command_handler
end
