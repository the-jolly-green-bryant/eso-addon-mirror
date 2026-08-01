--[[
	Addon: Taos Group Tools
	Author: TProg Taonnor
	Created by @Taonnor

    Copyright (c) 2018 Torsten Philipp (Taonnor) All rights reserved.

    Permission is hereby granted, free of charge, to any person obtaining
    a copy of this software and associated documentation (the "Software"),
    to operate the Software for personal use only. Permission is NOT granted
    to modify, merge, publish, distribute, sublicense, re-upload, and/or sell
    copies of the Software. Additionally, licensed use of the Software
    will be subject to the following:

    The above copyright notice and this permission notice shall be
    included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
    OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
    NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
    HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
    WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
    FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
    OTHER DEALINGS IN THE SOFTWARE.

    -------------------------------------------------------------------------------

    DISCLAIMER:

    This Add-on is not created by, affiliated with or sponsored by ZeniMax
    Media Inc. or its affiliates. The Elder Scrolls® and related logos are
    registered trademarks or trademarks of ZeniMax Media Inc. in the United
    States and/or other countries. All rights reserved.

    You can read the full terms at:
    https://account.elderscrollsonline.com/add-on-terms
]]--

--[[
	Local variables
]]--
local MAJOR = "1"
local MINOR = "1"
local PATCH = "6"

local LOG_NAME = "TGT-DebugLogger"
local LOG_FILE = "TaosGroupToolLogs"
local TRACE_ACTIVE = false
local DEBUG_ACTIVE = false
local ERROR_ACTIVE = true
local DIRECT_PRINT = false
local CATCH_LUA_ERRORS = false

local _addonName = "TaosGroupTools"

--[[
	Global variables
]]--
TGT_MOCKED = false
TGT_LOGGER = TaosDebugLogger(LOG_NAME, nil, TRACE_ACTIVE, DEBUG_ACTIVE, ERROR_ACTIVE, DIRECT_PRINT, CATCH_LUA_ERRORS, LOG_FILE)

--[[
	InitializeAddon Initializes Addon
]]--
local function InitializeAddon()
    TGT_LOGGER:InitLogFile()

    -- Initialize logging
    TGT_LOGGER:logTrace("TaosGroupTools -> Initialize")

    -- If mocking active, mock ZOS methods with mock methods
    if (TGT_MOCKED) then
        MockZOSMethods()
    end

    -- Initialize settings
    TGT_SettingsHandler.Initialize()

    -- Initialize communication
    TGT_Messages.Initialize()
    TGT_Communicator.Initialize()

    -- Initialize logic
	TGT_UltimateGroupHandler.Initialize()
    TGT_PlayerHandler.Initialize()
    TGT_InviteHandler.Initialize()
    TGT_CommandsHandler.Initialize()

    -- Initialize UI
    TGT_SettingsWindow.Initialize(MAJOR, MINOR, PATCH)

    -- Group Ultimate UI
    TGT_UltimateGroupMenu.Initialize()
    TGT_GroupUltimateSelector.Initialize()
    TGT_SimpleList.Initialize()
    TGT_SwimlaneList.Initialize()
    TGT_CompactSwimlaneList.Initialize()

    -- Group Leader UI
    TGT_FloatingLeaderMarker.Initialize()
    TGT_CenteredLeaderMarker.Initialize()
    TGT_CustomizedCompass.Initialize()

    -- Group Invite UI
    TGT_GroupMenuIntegration.Initialize()

    -- Group DPS/HPS UI
    TGT_SimpleDpsHpsList.Initialize()
    TGT_DpsHpsBarList.Initialize()

    -- Group Frames UI
    TGT_SubGroupMenu.Initialize()
    TGT_GroupFrames.Initialize()

    -- Detonation Tracker UI
    TGT_DetonationTracker.Initialize()

    -- Purge Tracker UI
    TGT_PurgeTracker.Initialize()
    
    -- Speed Tracker UI
    TGT_SpeedTracker.Initialize()
    
    -- Earthgore Tracker UI
    TGT_EarthgoreTracker.Initialize()

    TGT_LOGGER:logTrace("TaosGroupTools -> Initialize finished")
end

--[[
	OnAddOnLoaded if TaosGroupTools is loaded, initialize
]]--
local function OnAddOnLoaded(eventCode, addOnName)
	if (addOnName == _addonName) then

        -- Unregister Loaded Callback
        EVENT_MANAGER:UnregisterForEvent(_addonName, EVENT_ADD_ON_LOADED)

        -- Initialize
		InitializeAddon()
	end
end

-- Register Loaded Callback
EVENT_MANAGER:RegisterForEvent(_addonName, EVENT_ADD_ON_LOADED, OnAddOnLoaded);