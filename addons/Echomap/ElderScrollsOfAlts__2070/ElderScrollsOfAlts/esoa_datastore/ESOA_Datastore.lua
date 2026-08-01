----------------------------------------
--[[ ESOA Datastore ]]-- 
----------------------------------------
-- INTERNAL Implementation API
----------------------------------------


------------------------------
-- 
EchoESOADatastore = {
    name            = "ESOA_Datastore",           -- Matches folder and Manifest file names.
    version         = "0.0.1",                    -- A nuisance to match to the Manifest.
    author          = "Echomap",
    SV_VERSION_NAME = 1,
    -- In Memory Settings
    view            = {
      fError    = false,
      fErrorMsg = nil,
	  currentAccountName = GetDisplayName(),
    },
    --
    -- Saved settings.
    svESOADataAW  = {},
	svListDataAW  = {},
    svCharDataAW  = {},
    svEquipDataAW = {},	
    --
	BITE_WERE_ABILITY  = GetString(ESOA_BITE_WERE_ABILITY),
    BITE_WERE_COOLDOWN = GetString(ESOA_BITE_WERE_COOLDOWN),
    BITE_VAMP_ABILITY  = GetString(ESOA_BITE_VAMP_ABILITY),
    BITE_VAMP_COOLDOWN = GetString(ESOA_BITE_VAMP_COOLDOWN),
	--
    -- Default settings.    
    defaultSettings1 = {
    },
    defaultSettingsGlobal = {
      debug      = false,
      beta       = false,
      savePlayerData = true,
      saveEquipData  = true,
    },
}

-- M1 : Solvent Proficiency, Metalworking, Tailoring, (Aspect Improvement, Potency Improvement), Recipe Quality, Recipe Improvement, Woodworking
EchoESOADatastore.view.matchNameList1 = {GetString(ESOA_FULL_SUB_SOLV),  GetString(ESOA_FULL_SUB_METAL),  GetString(ESOA_FULL_SUB_TAIL),  GetString(ESOA_FULL_SUB_ASPIMP),  GetString(ESOA_FULL_SUB_RECQUA),  GetString(ESOA_FULL_SUB_WOOD),  GetString(ESOA_FULL_SUB_ENGRAV) }
-- M2 : Provisioning
EchoESOADatastore.view.matchNameList2 = {GetString(ESOA_FULL_SUB_POTIMPR), GetString(ESOA_FULL_SUB_RECIMPR) }


------------------------------
-- API
------------------------------
------------------------------

------------------------------
-- UTIL
function EchoESOADatastore.debugMsg(...)
  if not EchoESOADatastore.svESOADataAW.debug then
    return
  end
  local arg={...}
  if arg == nil then
    return
  end
  local printResult = ""
  if(arg~=nil)then
    for i,v in ipairs(arg) do
      if(v==nil) then 
        printResult = printResult .. "nil"
      else
        printResult = printResult .. tostring(v) --.. " "
      end
    end
  end
  if printResult == nil then
    return
  end
  local val = zo_strformat( "(<<1>>) <<2>>",EchoESOADatastore.name,printResult)
  d(val)
end

------------------------------
-- UTIL
function EchoESOADatastore.outputMsg(...)
  local arg={...}
  if arg == nil then
    return
  end
  local printResult = ""
  if(arg~=nil)then
    for i,v in ipairs(arg) do
      if(v==nil) then 
        printResult = printResult .. "nil"
      else
        printResult = printResult .. tostring(v) --.. " "
      end
    end
  end
  if printResult == nil then
    return
  end  
	d("(" .. EchoESOADatastore.name .. ") " .. printResult )
end

------------------------------
-- SETUP  setup event handling
function EchoESOADatastore.DelayedStart()
	--ESOADatastoreLogic.saveCurrentPlayerData() -- DATA
end

------------------------------
-- EVENT
function EchoESOADatastore.OnPlayerLoaded(e)
	EVENT_MANAGER:UnregisterForEvent(EchoESOADatastore.name, EVENT_PLAYER_ACTIVATED)
end

------------------------------
-- EVENT
-- Player can be unloaded on zone change, reload, etc, but not called on QUIT/Crash
function EchoESOADatastore.OnPlayerUnloaded(event)
	--ESOADatastoreLogic.saveCurrentPlayerData()
end

------------------------------
-- EVENT
function EchoESOADatastore.OnAddOnLoaded(event, addonName)
	--d("addonName="..addonName)
	if addonName ~= EchoESOADatastore.name then return end
	EVENT_MANAGER:UnregisterForEvent(EchoESOADatastore.name, EVENT_ADD_ON_LOADED)
	-- Try a New Multi Account Wide Format!
	local profile = nil
	local displayName = "ESOA"
	local svVer = EchoESOADatastore.SV_VERSION_NAME
	--(savedVariableTable, version, namespace, defaults, profile, displayName, characterName)
	EchoESOADatastore.svESOADataAW  = ZO_SavedVars:NewAccountWide("ESOA_Datastore", svVer, "AccountData", EchoESOADatastore.defaultSettingsGlobal, profile,displayName)
	--(savedVariableTable, version, namespace, defaults, profile, displayName, characterName)
	EchoESOADatastore.svListDataAW  = ZO_SavedVars:NewAccountWide("ESOA_Datastore", svVer, "ListData", EchoESOADatastore.defaultSettings, profile,displayName)
	--(savedVariableTable, version, namespace, defaults, profile, displayName, characterName)
	EchoESOADatastore.svCharDataAW  = ZO_SavedVars:NewAccountWide("ESOA_Datastore", svVer, "CharData", EchoESOADatastore.defaultSettings, profile,displayName)
	--(savedVariableTable, version, namespace, defaults, profile, displayName, characterName)
	EchoESOADatastore.svEquipDataAW = ZO_SavedVars:NewAccountWide("ESOA_Datastore", svVer, "EquipData", EchoESOADatastore.defaultSettings, profile,displayName)
	--check/setup a bit earlier
	--EchoESOADatastore.CheckData()
	--EchoESOADatastore.SetupDefaultColors()
	zo_callLater(EchoESOADatastore.DelayedStart, 3000)

	-- Slash commands must be lowercase. Set to nil to disable.
	SLASH_COMMANDS["/esoadata"]      = EchoESOADatastore.SlashCommandHandler
	SLASH_COMMANDS["/esoadatastore"] = EchoESOADatastore.SlashCommandHandler
	--d("ESOA Datastore loaded")
end

------------------------------
-- Commands, help/debug/beta/testdata/deltestdata
function EchoESOADatastore.SlashCommandHandler(text)
	EchoESOADatastore.debugMsg("SlashCommandHandler: " , text)
	local options = {}
	local searchResult = { string.match(text,"^(%S*)%s*(.-)$") }
	for i,v in pairs(searchResult) do
		if (v ~= nil and v ~= "") then
		    options[i] = string.lower(v)
		end
	end
	--
	if #options == 0 then
		EchoESOADatastore.ShowHelp()
	elseif options[1] == "debug" then	
		local dg = EchoESOADatastore.svESOADataAW.debug
		EchoESOADatastore.svESOADataAW.debug = not dg
		EchoESOADatastore.outputMsg("EchoESOADatastore: Debug = " .. tostring(EchoESOADatastore.svESOADataAW.debug) )
	elseif (options[1] == "note" and #options == 2) then
		local playerName = options[2]
		EchoESOADatastore.GetPlayerNote(playerName)
	elseif options[1] == "list" then
		local param2 = options[2]
		EchoESOADatastore.PrintPlayerNote(param2)
	elseif options[1] == "help" then
		EchoESOADatastore.ShowHelp()
	else
		EchoESOADatastore.ShowHelp()
	end
end

------------------------------
-- User command
function EchoESOADatastore.ShowHelp()
    EchoESOADatastore.outputMsg("/esoadata <commands> where command can be; note or list")
end

------------------------------
-- Register for starting/startup events

-- When any addon is loaded, but before UI (Chat) is loaded.
EVENT_MANAGER:RegisterForEvent(EchoESOADatastore.name, EVENT_ADD_ON_LOADED, EchoESOADatastore.OnAddOnLoaded)
-- Add on player loaded
EVENT_MANAGER:RegisterForEvent(EchoESOADatastore.name, EVENT_PLAYER_DEACTIVATED, EchoESOADatastore.OnPlayerUnloaded)
-- When player is ready, after everything has been loaded. (after addon loaded)
EVENT_MANAGER:RegisterForEvent(EchoESOADatastore.name, EVENT_PLAYER_ACTIVATED, EchoESOADatastore.OnPlayerLoaded)
------------------------------
--[[ ESOA Datastore ]]-- 
------------------------------