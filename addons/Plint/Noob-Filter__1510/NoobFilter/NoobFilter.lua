--PLINT'S PIZZARONI PEPPERONI 
-- First, we create a namespace for our addon by declaring a top-level table that will hold everything else.
PooAddon = {}
 
-- This isn't strictly necessary, but we'll use this string later when registering events.
-- Better to define it in a single place rather than retyping the same string.
PooAddon.name = "NoobFilter"

scrublistlap={}
scrublistrace={}

local maxdeathlap
local mindeathlap
local maxdeathrace
local mindeathrace
 
--/script voor ingame print
--------------------------------
--begin own functions
--------------------------------
function PooAddon.Prefix(arg1)
	local options = {}
	--local searchResult = { string.match(arg1,"^(%S*)%s*(.-)$") }
	local searchResult = { string.match(arg1,"^([^,]*),*(.-)$") }
	for i,v in pairs(searchResult) do
		if (v ~= nil and v ~= "") then
			options[i] = v
		end
    end
	
	--we add to prefixlist
	if(options[2]~=nil) then
		prefixlist[tostring(options[1])]=tostring(options[2])
		PooAddon.savedVariables.prefixlist=prefixlist
	--or we remove
	else
		prefixlist[tostring(options[1])]=nil
	end

end

function PooAddon.ResetPrefix()
	--remove all prefixes from all players
	for k,v in pairs (prefixlist) do
		prefixlist[k] = nil
	end
	PooAddon.savedVariables.prefixlist=prefixlist
	d("All prefixes are reset.")
end

function PooAddon.deathUpdate(eventCode,unitTag,isDead)
	-- when a scrub dies

	if isDead and "group" == string.sub(unitTag, 0, 5) then 
		--UPDATE LAP
		--find out if scrub died before
		local scrubName=GetUnitName(unitTag)
		local tempnr=scrublistlap[scrubName]
		if tempnr==nil then 
			scrublistlap[scrubName]=1
		else 
			scrublistlap[scrubName]=tempnr+1
		end
		
		--UPDATE RACE
		--find out if scrub died before
		local scrubName=GetUnitName(unitTag)
		local tempnr=scrublistrace[scrubName]
		if tempnr==nil then 
			scrublistrace[scrubName]=1
		else 
			scrublistrace[scrubName]=tempnr+1
		end
		--update minmaxdeath
		PooAddon.MinMaxDeath()
	end
end

function PooAddon.ResetLap()
	--reset the scrublist
	for k,v in pairs (scrublistlap) do
		scrublistlap[k] = nil
	end
	--reset minmaxdeath
	PooAddon.MinMaxDeath()
	d("NoobFilter Reset Interim Death Counter")
end

function PooAddon.ResetRace()
	--reset the scrublist
	for k,v in pairs (scrublistrace) do
		scrublistrace[k] = nil
	end
	--reset the scrublist
	for k,v in pairs (scrublistlap) do
		scrublistlap[k] = nil
	end
	--reset minmaxdeath
	PooAddon.MinMaxDeath()
	d("NoobFilter Reset Total Death Counter")
end

function PooAddon.PrintLap()
	--if empty list then no scrubs
	if next(scrublistlap) == nil then
		d("No deaths to report!")
	--print scrubs with most deaths first
	else 
		PooAddon.PrintSortedLap()
	end
end

function PooAddon.PrintRace()
	--if empty list then no scrubs
	if next(scrublistrace) == nil then
		d("No deaths to report!")
	--print scrubs with most deaths first
	else 
		PooAddon.PrintSortedRace()
	end
end

function PooAddon.Test()
	--d("test")
end

function PooAddon.PrintSortedLap()
	local currentdeath=maxdeathlap
	local nextdeath=mindeathlap
	local outputString="Interim Death Count: "
	local firsty=0
	--we go over the list of scrubs really inefficiently
	--starting with the biggest scrub
	while(currentdeath~=mindeathlap) do
		for key,value in pairs(scrublistlap) do 
			--print scrub
			if(value==currentdeath) then
				if(firsty==1) then
					outputString=outputString .. "| "
				else 
					firsty=1
				end
				if(prefixlist[key]~=nill) then
					outputString=outputString .. tostring(prefixlist[key]) .. " "
				end
				outputString=outputString .. tostring(key) .. ": " .. tostring(value) .. " " 
			elseif value<currentdeath then
				if value>nextdeath then
					nextdeath=value
				end
			end
		end
		currentdeath=nextdeath
		nextdeath=mindeathlap
	end
	--and once more for last scrubDiedBeforeBoolean
	for key,value in pairs(scrublistlap) do 
		--print scrub
		if(value==currentdeath) then
			if(firsty==1) then
				outputString=outputString .. "| "
			else 
				firsty=1
			end
			if(prefixlist[key]~=nill) then
				outputString=outputString .. tostring(prefixlist[key]) .. " "
			end
			outputString=outputString .. tostring(key) .. ": " .. tostring(value) .. " " 
		elseif value<currentdeath then
			if value>nextdeath then
				nextdeath=value
			end
		end
	end
	
	--steal from solinur
	-- Determine appropriate channel
	--350chars max
	local channel = IsUnitGrouped('player') and "/p " or "/say "
	CHAT_SYSTEM.textEntry:SetText( channel .. outputString )
	CHAT_SYSTEM:Maximize()
	CHAT_SYSTEM.textEntry:Open()
	CHAT_SYSTEM.textEntry:FadeIn()
end

function PooAddon.PrintSortedRace()
	local currentdeath=maxdeathrace
	local nextdeath=mindeathrace
	local outputString="Total Death Count: "
	--we go over the list of scrubs really inefficiently
	--starting with the biggest scrub
	while(currentdeath~=mindeathrace) do
		for key,value in pairs(scrublistrace) do 
			--print scrub
			if(value==currentdeath) then
				if(firsty==1) then
					outputString=outputString .. "| "
				else 
					firsty=1
				end
				if(prefixlist[key]~=nill) then
					outputString=outputString .. tostring(prefixlist[key]) .. " "
				end
				outputString=outputString .. tostring(key) .. ": " .. tostring(value) .. " " 
			elseif value<currentdeath then
				if value>nextdeath then
					nextdeath=value
				end
			end
		end
		currentdeath=nextdeath
		nextdeath=mindeathrace
	end
	--and once more for last scrubDiedBeforeBoolean
	for key,value in pairs(scrublistrace) do 
		--print scrub
		if(value==currentdeath) then
			if(firsty==1) then
				outputString=outputString .. "| "
			else 
				firsty=1
			end
			if(prefixlist[key]~=nill) then
				outputString=outputString .. tostring(prefixlist[key]) .. " "
			end
			outputString=outputString .. tostring(key) .. ": " .. tostring(value) .. " " 
		elseif value<currentdeath then
			if value>nextdeath then
				nextdeath=value
			end
		end
	end
	
	--steal from solinur
	-- Determine appropriate channel
	--350chars max
	local channel = IsUnitGrouped('player') and "/p " or "/say "
	CHAT_SYSTEM.textEntry:SetText( channel .. outputString )
	CHAT_SYSTEM:Maximize()
	CHAT_SYSTEM.textEntry:Open()
	CHAT_SYSTEM.textEntry:FadeIn()
end

function PooAddon.MinMaxDeath()
	--find minimum and maximum number of deaths LAP
	maxdeathlap=0
	mindeathlap=99999
	--if list is empty
	if next(scrublistlap) == nil then
		maxdeathlap=0
		mindeathlap=0
	--we find minmaxdeath
	else
		for key,value in pairs(scrublistlap) do 
			if value<mindeathlap then mindeathlap=value end
			if value>maxdeathlap then maxdeathlap=value end			
		end
	end
	--find minimum and maximum number of deaths RACE
	maxdeathrace=0
	mindeathrace=99999
	--if list is empty
	if next(scrublistrace) == nil then
		maxdeathrace=0
		mindeathrace=0
	--we find minmaxdeath
	else
		for key,value in pairs(scrublistrace) do 
			if value<mindeathrace then mindeathrace=value end
			if value>maxdeathrace then maxdeathrace=value end			
		end
	end
end

--------------------------------
--end own functions
--------------------------------
--begin slash commands
--------------------------------
SLASH_COMMANDS["/resetint"] = PooAddon.ResetLap
SLASH_COMMANDS["/resettot"] = PooAddon.ResetRace
SLASH_COMMANDS["/printint"] = PooAddon.PrintLap
SLASH_COMMANDS["/printtot"] = PooAddon.PrintRace
--prefix with 1 argument removes prefix of player arg1 
--prefix with 2 arguments adds/overwrites prefix arg2 to player arg1
SLASH_COMMANDS["/prefix"] = PooAddon.Prefix
SLASH_COMMANDS["/resetprefix"] = PooAddon.ResetPrefix
--SLASH_COMMANDS["/sftest"] = PooAddon.Test
--------------------------------
--end slash commands
--------------------------------
--initialization
--------------------------------
 
-- Next we create a function that will initialize our addon
function PooAddon:Initialize()
  -- ...but we don't have anything to initialize yet. We'll come back to this.
  PooAddon:MinMaxDeath()
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_UNIT_DEATH_STATE_CHANGED, self.deathUpdate)
  
  --load saved variables 
  --namely prefixes for counter
  self.savedVariables = ZO_SavedVars:NewAccountWide("NoobFilterSavedVariables", 1, nil, {})
  savedprefixlist=PooAddon.savedVariables.prefixlist
	if(savedprefixlist~=nil) then
		prefixlist=PooAddon.savedVariables.prefixlist
	else 
		prefixlist={}
	end

end
-- Then we create an event handler function which will be called when the "addon loaded" event
-- occurs. We'll use this to initialize our addon after all of its resources are fully loaded.
function PooAddon.OnAddOnLoaded(event, addonName)
  -- The event fires each time *any* addon loads - but we only care about when our own addon loads.
  if addonName == PooAddon.name then
    PooAddon:Initialize()
  end
end
 
-- Finally, we'll register our event handler function to be called when the proper event occurs.
EVENT_MANAGER:RegisterForEvent(PooAddon.name, EVENT_ADD_ON_LOADED, PooAddon.OnAddOnLoaded)