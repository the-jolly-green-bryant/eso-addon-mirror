--[[
	Addon: Taos Group Tools
	Author: TProg Taonnor
	Created by @Taonnor
]]--

--[[
	Local variables
]]--
local _logger = nil
local _settingsHandler = TGT_SettingsHandler
local _ultimateGroupHandler = TGT_UltimateGroupHandler
local _inviteHandler = TGT_InviteHandler

local _name = "TGT-CommandsHandler"

--[[
	Table TGT_CommandsHandler
]]--
TGT_CommandsHandler = {}
TGT_CommandsHandler.__index = TGT_CommandsHandler

--[[
	===============
    PRIVATE METHODS
    ===============
]]--

--[[
	Called on /tgtlogs command
]]--
local function ShowLogsCommand()
    _logger:ShowLogs()
end

--[[
	Called on /tgt command
]]--
local function GetAllCommands()
    d("Commands active:")
    d("/tgt - Gets all available commands")
    d("/tgtlogs - Open or closes debug log window")
    d("/tgtsor <SOUND> - Sets SOUND on Ready value, see https://wiki.esoui.com/Sounds")
    d("/tgtsot <SOUND> - Sets SOUND on Thrown value, see https://wiki.esoui.com/Sounds")
    d("/gi <INVITESTRING> - Sets invite string.")
	d("/regroup - Starts regroup.")
end

--[[
	Called on /tgtsor command
]]--
local function SetSoundOnReadyCommand(sound)
    if (sound ~= "") then
        PlaySound(SOUNDS[sound])
        _settingsHandler.SetSoundOnReadySettings(99, sound)
    else
        d("Invalid sound: " .. tostring(sound))
    end
end

--[[
	Called on /tgtsot command
]]--
local function SetSoundOnThrownCommand(sound)
    if (sound ~= "") then
        PlaySound(SOUNDS[sound])
        _settingsHandler.SetSoundOnThrownSettings(99, sound)
    else
        d("Invalid sound: " .. tostring(sound))
    end
end

--[[
	Called on /gi command
]]--
local function SetGroupInviteString(inviteString)
    if (inviteString ~= nil and inviteString ~= "") then
        _settingsHandler.SetInviteString(inviteString)
    else
        d("Invalid invite string: " .. tostring(inviteString))
    end
end

--[[
	Called on /regroup command
]]--
local function ActivateRegroup()
    _inviteHandler.Regroup()
end

--[[
	==============
    PUBLIC METHODS
    ==============
]]--

--[[
	Initialize initializes TGT_CommandsHandler
]]--
function TGT_CommandsHandler.Initialize()
    _logger = TGT_LOGGER

    -- Define commands
    SLASH_COMMANDS["/tgt"] = GetAllCommands
    SLASH_COMMANDS["/tgtlogs"] = ShowLogsCommand
    SLASH_COMMANDS["/tgtsor"] = SetSoundOnReadyCommand
    SLASH_COMMANDS["/tgtsot"] = SetSoundOnThrownCommand
    SLASH_COMMANDS["/gi"] = SetGroupInviteString
	SLASH_COMMANDS["/regroup"] = ActivateRegroup
    
    _logger:logTrace("TGT_CommandsHandler -> Initialized")
end