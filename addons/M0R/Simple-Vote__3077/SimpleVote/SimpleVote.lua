SimpleVote = {}

-- Written by M0R_Gaming

SimpleVote.name = "SimpleVote"


function SimpleVote.sendVote(message)
	local sent = BeginGroupElection(0,message)
	SimpleVote.descriptor = message
	if sent then
		d("Vote Initiated: "..message)
		EVENT_MANAGER:RegisterForEvent("SimpleVote Callback", EVENT_GROUP_ELECTION_RESULT,SimpleVote.callback)
	else
		d("Vote Failed to send")
	end
end

function SimpleVote.sendSuperVote(message)
	local sent = BeginGroupElection(1,message)
	SimpleVote.descriptor = message
	if sent then
		d("Vote Initiated: "..message)
		EVENT_MANAGER:RegisterForEvent("SimpleVote Callback", EVENT_GROUP_ELECTION_RESULT,SimpleVote.callback)
	else
		d("Vote Failed to send")
	end
end

function SimpleVote.sendReady(message)
	local sent = BeginGroupElection(2,message)
	SimpleVote.descriptor = message
	if sent then
		d("Ready Check Initiated: "..message)
		EVENT_MANAGER:RegisterForEvent("SimpleVote Callback", EVENT_GROUP_ELECTION_RESULT,SimpleVote.callback)
	else
		d("Ready Check Failed to send")
	end
end

function SimpleVote.callback(eventCode,electionResult,descriptor) 
	if descriptor == SimpleVote.descriptor then
		if electionResult == 4 then
			d("Vote Passed")
		elseif electionResult == 5 then
			d("Vote Failed")
		elseif electionResult == 2 then
			d("Vote Tied")
		elseif electionResult == 1 then
			d("Vote Timed Out")
		elseif electionResult == 3 then
			d("Vote Abandoned")
		elseif electionResult == 6 then
			d("Vote In Progress")
		elseif electionResult == 0 then
			d("Vote Not In Progress")
		else
			d("It should be impossible to get here. Notify @M0R_Gaming of the following number: "..electionResult)
		end
		EVENT_MANAGER:UnregisterForEvent("SimpleVote Callback", EVENT_GROUP_ELECTION_RESULT)
	end
end

 

-- Setting up Keybinds and Commands --

SLASH_COMMANDS["/vote"] = SimpleVote.sendVote
SLASH_COMMANDS["/supervote"] = SimpleVote.sendSuperVote
SLASH_COMMANDS["/ready"] = SimpleVote.sendReady






-- The following was adapted from https://wiki.esoui.com/Circonians_Stamina_Bar_Tutorial#lua_Structure

-------------------------------------------------------------------------------------------------
--  OnAddOnLoaded  --
-------------------------------------------------------------------------------------------------
function SimpleVote.OnAddOnLoaded(event, addonName)
	if addonName ~= SimpleVote.name then return end

	SimpleVote:Initialize()
end
 
-------------------------------------------------------------------------------------------------
--  Initialize Function --
-------------------------------------------------------------------------------------------------
function SimpleVote:Initialize()
	EVENT_MANAGER:UnregisterForEvent(SimpleVote.name, EVENT_ADD_ON_LOADED)
end
 
-------------------------------------------------------------------------------------------------
--  Register Events --
-------------------------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(SimpleVote.name, EVENT_ADD_ON_LOADED, SimpleVote.OnAddOnLoaded)