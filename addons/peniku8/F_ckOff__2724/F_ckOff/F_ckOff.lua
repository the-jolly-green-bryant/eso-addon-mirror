if not FuckOff then FuckOff = {} end
local FO = FuckOff
local em = GetEventManager()

FO.name = "F_ckOff"
FO.version = "1.1.14"
	
	
	function FO.getAppIndexFromID(guildID, userID)
		for i=1, GetGuildFinderNumGuildApplications(guildID) do
			if userID == zo_strformat("<<5>>", GetGuildFinderGuildApplicationInfoAt(guildID, i))
			 then return i
			end
		end
	end
  
  
  function FO.appAccepted(eventCode, guildID, userID, result)
  	local index = FO.getAppIndexFromID(guildID, userID)
  	if result == 5 then
  		DeclineGuildApplication(guildID, index)
  	end
  end



function FO.Initialize(event, addon)
	
	if addon ~= FO.name then return end
	
	em:UnregisterForEvent("FuckOffInitialize", EVENT_ADD_ON_LOADED)
	
	em:RegisterForEvent("FOGuildAppAccepted", EVENT_GUILD_FINDER_PROCESS_APPLICATION_RESPONSE, FO.appAccepted)
	
end

em:RegisterForEvent("FuckOffInitialize", EVENT_ADD_ON_LOADED, function(...) FO.Initialize(...) end)