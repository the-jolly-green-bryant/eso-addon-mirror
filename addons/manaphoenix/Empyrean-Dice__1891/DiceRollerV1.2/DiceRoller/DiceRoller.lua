-- First, we create a namespace for our addon by declaring a top-level table that will hold everything else.
DiceRoller = {}

-- Variables
local ch = CHAT_SYSTEM
local option = 2 -- Determines push type [0 = client, 1 = text entry, 2 = map ping]
local enabled = true
math.randomseed(os.clock())
 
-- This isn't strictly necessary, but we'll use this string later when registering events.
-- Better to define it in a single place rather than retyping the same string.
DiceRoller.name = "DiceRoller"

-- Next we create a function that will initialize our addon
function DiceRoller:Initialize()
	EVENT_MANAGER:UnregisterForEvent('RollCall', EVENT_ADD_ON_LOADED)
	self.savedVariables = ZO_SavedVars:New("RollSavedVariables", 1, nil, {mode = 2, enabled = true})
	option = self.savedVariables.mode -- Determines push type [0 = client, 1 = text entry, 2 = map ping]
	enabled = self.savedVariables.enabled
  -- ...but we don't have anything to initialize yet. We'll come back to this.
end
 
-- Then we create an event handler function which will be called when the "addon loaded" event
-- occurs. We'll use this to initialize our addon after all of its resources are fully loaded.
function DiceRoller.OnAddOnLoaded(event, addonName)
  -- The event fires each time *any* addon loads - but we only care about when our own addon loads.
  if addonName == DiceRoller.name then
    DiceRoller:Initialize()
  end
end

-- Function for Map Ping Received
function OnPingReceived(eventCode, pingEventType, pingType, pingTag, offsetX, offsetY, isOwner)

	if IsUnitInCombat('player') then return end
	if not enabled then return end
	
	if not isOwner and offsetX > 0 and offsetY > 0 and pingType == 150 then
		local length = tostring(offsetY):sub(3,3)
		local rolled = tostring(offsetX):sub(3,length+2)
		d("Length: " .. length)
		d("Rolled: " .. rolled)
	elseif isOwner and offsetX > 0 and offsetY > 0 and pingType == 150 then
		local length = tostring(offsetY):sub(3,3)
		local rolled = tostring(offsetX):sub(3,length+2)
		d("Length: " .. length)
		d("Rolled: " .. rolled)
	end

end

-- Function for roll
local function RollTheDice(dicenum,dicemax,add)
	local total = 0
	for i = 1, dicenum, 1 do
		for s = 1, math.random(100) do
			math.random(dicemax)
		end
		total = total + math.random(dicemax)
	end
	total = total + add
	return total
end

-- Ping to Players
local function PingToGroup(total,dicenum,dicemax,add)
	if option == 0 then
	ch:AddMessage("Result: " .. total .. "")
	ch:AddMessage("Rolled: [" .. dicenum .. "d" .. dicemax .. "]+" .. add)
	elseif option == 1 then
	StartChatInput("Result: " .. total, 3)
	elseif option == 2 then
	PingMap(MAP_PIN_TYPE_PING, MAP_TYPE_LOCATION_CENTERED, tonumber("0." .. total .. "44"), tonumber("0." .. string.len(total) .. "44"))
	--MAP_TYPE_PLAYER_CENTERED
	end
end

-- Function for Slash Command
function roll(dice)

	if not enabled then return end
	dice = dice or "1d6+0"
	if dice == "" then
		dice = "1d6+0"
	end
	local dicenum = dice:match("%d*")
	local d = dice:sub(dicenum:len()+1,dicenum:len()+1)
	local dicemax = dice:sub(dicenum:len()+2):match("%d*")
	local length = dicenum:len() + d:len() + dicemax:len()
	local plus = dice:sub(length+1,length+1)
	local add = dice:sub(length+2):match("%d*")
	
	if add == "" then
		add = 0
	end
	if dicemax == "" then
		dicemax = 6
	end
	if dicenum == "" then
		dicenum = 1
	end
	
	local total = RollTheDice(dicenum,dicemax,add)
	PingToGroup(total,dicenum,dicemax,add)
end

-- Function enable
function tog()
	enabled = not enabled
	d("Dice Roll Enabled: " .. enabled)
	DiceRoller.savedVariables.enabled = enabled
end

-- Mode switch
function mode(extra)
	if extra ~= "" then
		if tonumber(extra) < 3 and tonumber(extra) > -1 then
			option = tonumber(extra)
			DiceRoller.savedVariables.mode = tonumber(extra)
		end
	end
	d("Mode: " .. option)
end

-- Finally, we'll register our event handler function to be called when the proper event occurs.
EVENT_MANAGER:RegisterForEvent(DiceRoller.name, EVENT_ADD_ON_LOADED, DiceRoller.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent('RollCall', EVENT_MAP_PING, OnPingReceived)
SLASH_COMMANDS["/roll"] = roll
SLASH_COMMANDS["/rolltog"] = tog
SLASH_COMMANDS["/rollmode"] = mode