local DTT = {}

--[[ INIT
	init addon
--]]
function DTT.Initialize()
   deaglTT.Teleport.Initialize()
end

--[[ LOAD ADDOND
	run event after UI loaded  
--]]       
function DTT.LOADED (eventCode, addOnName)  
    if addOnName ~= deaglTT.Name then return end

    -- read settings from ZOS
    --ZO_SavedVars:NewAccountWide(savedVariableTable, version, namespace, defaults, profile, displayName)
    deaglTT.Settings = ZO_SavedVars:NewAccountWide("TeleportSavedVars", 1, nil, deaglTT.SettingsDefault, nil)
   
    -- wait n sec after UI load and run init()
	zo_callLater(function()
		DTT.Initialize()  
        deaglTT.Loaded = true   
        end, 3000); 
    -- remove loaded event for memory leak
    EVENT_MANAGER:UnregisterForEvent(deaglTT.Name, EVENT_ADD_ON_LOADED)
	
	-- Init slash commands
	SLASH_COMMANDS["/tt"] = DTT.SlashHandler
end

--[[ SLASH COMMANDS
]]--
function DTT.SlashHandler(arg)
	local data = { }
	data = deaglTT.Lib.Split(arg)
		-- no args, shown args in chat window
	if arg == nil or arg == "" or table.getn(data) == 0 or table.getn(data) >= 4 then
		deaglTT.ToChat(deaglTT.ChatLineHeader.. deaglTT.Color[5].. " Slash-Command information")
		
		--deaglTT.ToChat(deaglTT.Color[6].. "/tt "..deaglTT.Color[2].. "jth => ".. deaglTT.Color[5].. "Jump to primary house")
		deaglTT.ToChat(deaglTT.Color[6].. "/tt "..deaglTT.Color[2].. "reset session => ".. deaglTT.Color[5].. "Reset the session teleport counter")
		deaglTT.ToChat(deaglTT.Color[6].. "/tt "..deaglTT.Color[2].. "reset total   => ".. deaglTT.Color[5].. "Reset the total teleport counter")
		deaglTT.ToChat(deaglTT.Color[6].. "/tt "..deaglTT.Color[2].. "reset gold    => ".. deaglTT.Color[5].. "Reset the gold counter")
		deaglTT.ToChat(deaglTT.Color[6].. "/tt "..deaglTT.Color[2].. "donate [sum gold, default 5k] => ".. deaglTT.Color[5].. "send some gold to me")
		deaglTT.ToChat(deaglTT.Color[5].. "---")
	end
	
	--donate
	if data[1] == "donate" then
		deaglTT.Lib.SendNote(data[2])
	end
	
	-- two args => JumpToHouse
	--if data[1] == "jth" then
	--	if DTT.DEBUG then d("Teleport: Jump to house") end
	--	deaglTT.Teleport.TeleportToHouse(data[2])
	--end
	
	-- two args => reset
	if table.getn(data) == 2 and data[1] == "reset" then
		if data[2] == "gold" then
			if DTT.DEBUG then d("Teleport: Gold reset") end
			local c = deaglTT.Settings.Teleport.teleportCost
			if c == nil or c == "" then c = "0" end
			deaglTT.ToChat(deaglTT.ChatLineHeader.. deaglTT.Color[5] .. " Reset gold counter from ".. deaglTT.Color[2].. c .. deaglTT.Color[5].. " to ".. deaglTT.Color[2].. "0")
			deaglTT.Settings.Teleport.teleportCost = 0
		end
		if data[2] == "total" then
			if DTT.DEBUG then d("Teleport: Total session reset") end
			local c = deaglTT.Settings.Teleport.teleportCounter
			if c == nil or c == "" then c = "0" end
			deaglTT.ToChat(deaglTT.ChatLineHeader.. deaglTT.Color[5].. " Reset total teleport counter from ".. deaglTT.Color[2].. c .. deaglTT.Color[5].. " to ".. deaglTT.Color[2].. "0")
			deaglTT.Settings.Teleport.teleportCounter = 0
		end
		if data[2] == "session" then
			if DTT.DEBUG then d("Teleport: Session reset")  end
			local c = DTT.TeleportCounterSession
			if c == nil or c == "" then c = "0" end
			deaglTT.ToChat(deaglTT.ChatLineHeader.. deaglTT.Color[5] .. " Reset session teleport counter from ".. deaglTT.Color[2].. c .. deaglTT.Color[5].. " to ".. deaglTT.Color[2].. "0")
			DTT.TeleportCounterSession = 0
		end
	end
	
	-- three args => set
	if table.getn(data) == 3 and data[1] == "set" then
		if data[2] == "gold" then
			if DTT.DEBUG then d("Teleport: Gold set to ".. data[4]) end
			local c = deaglTT.Settings.Teleport.teleportCost
			if c == nil or c == "" then c = "0" end
			deaglTT.ToChat(deaglTT.ChatLineHeader.. deaglTT.Color[5] .. " Set gold counter from ".. deaglTT.Color[2].. c .. deaglTT.Color[5].. " to ".. deaglTT.Color[2].. data[3])
			deaglTT.Settings.Teleport.teleportCost = data[3]
		end
		if data[2] == "total" then
			local c = deaglTT.Settings.Teleport.teleportCounter
			if c == nil or c == "" then c = "0" end
			if DTT.DEBUG then d("Teleport: Total session set to ".. data[2]) end
			deaglTT.ToChat(deaglTT.ChatLineHeader.. deaglTT.Color[5] .. " Set total teleportcounter from ".. deaglTT.Color[2].. c .. deaglTT.Color[5].. " to ".. deaglTT.Color[2].. data[3])
			deaglTT.Settings.Teleport.teleportCounter = data[3]
		end
	end
	
end

--[[ RAISE on STARTUP
	raise event after UI loaded to load addon
--]]
EVENT_MANAGER:RegisterForEvent(deaglTT.Name, EVENT_ADD_ON_LOADED, DTT.LOADED)

