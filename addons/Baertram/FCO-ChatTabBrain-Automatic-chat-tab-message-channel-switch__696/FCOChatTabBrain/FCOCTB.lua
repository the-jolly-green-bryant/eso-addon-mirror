-----------------------------------------------------------------
--FCOChatTabBrain.lua
--Author: Baertram
------------------------------------------------------------------
--************************************************************************************************************************
--************************************************************************************************************************
--************************************************************************************************************************
------------------------------------------------------------------
-- [Error/bug & feature messages to check - CHANGELOG since last version] --
---------------------------------------------------------------------
--[ToDo list] --
--____________________________
-- Current max bugs: 2
--____________________________

--#1) Test chat mentions by keywords. Do not seem to work?

--#2) Test sound notifications of guild master vs. normal guilds members.

---------------------------------------------------------------------
-- Currently worked on [Added/Fixed/Changed]
---------------------------------------------------------------------
--Since last update 0.4.3 - New version: 0.4.4
---------------------------------------------------------------------
--[Fixed]
--

--[Changed]
--

--[Added]
--

--[Added on request]
--

--************************************************************************************************************************
--************************************************************************************************************************
--************************************************************************************************************************
------------------------------------------------------------------
FCOCTB = FCOCTB or {}
local FCOCTB = FCOCTB

local chatSystem = FCOCTB.ChatSystem

--===================== HELP & CHAT COMMANDS ==============================================

local function help()
	local locVars = FCOCTB.localizationVars.fco_ctb_loc
    d(locVars["chatcommands_info"])
	d(locVars["chatcommands_help"])
	d(locVars["chatcommands_status"])
	d(locVars["chatcommands_addonon"])
	d(locVars["chatcommands_addonoff"])
	d(locVars["chatcommands_addontoggle"])
end

local function status()
    local locVars = FCOCTB.localizationVars.fco_ctb_loc
	d(locVars["chatcommands_status_info"])
	if(FCOCTB.settingsVars.settings.chatBrainActive == true) then
		d(locVars["chatcommands_status_on"])
    else
		d(locVars["chatcommands_status_off"])
	end
end

--chat command handlers
local function command_handler(arg)
    arg = string.lower(arg)
    local locVars = FCOCTB.localizationVars.fco_ctb_loc
	if(arg == "help" or arg == "list") then
       	help()
	elseif(arg == "status" or arg == "") then
       	status()
	elseif(arg == "on" or arg == "an") then
        FCOCTB.setChatBrain(true)
        d(locVars["chatcommands_status_on"])
	elseif(arg == "off" or arg == "aus") then
        FCOCTB.setChatBrain(false)
        d(locVars["chatcommands_status_off"])
	elseif(arg == "toggle") then
        FCOCTB.toggleChatBrain()
        if FCOCTB.settingsVars.settings.chatBrainActive == true then
        	d(locVars["chatcommands_status_on"])
        else
	        d(locVars["chatcommands_status_off"])
        end
    end
end

function FCOCTB.RegisterSlashCommands()
    -- Register slash commands
	SLASH_COMMANDS["/fcochattabbrain"] = command_handler
	SLASH_COMMANDS["/fcoctb"] 		   = command_handler
end

-- Call the start function for this addon
FCOCTB.Initialized()
