CustomIdleAnimation = {
	name = "CustomIdleAnimation",
	title = "Custom Idle Animation",
	author = "MBW91",
	version = "1.7.3",
	savedVariablesVersion = 2.1
}
local CIA = CustomIdleAnimation
local LAM = LibAddonMenu2
 
function CIA.Initialize()
	CIA.sortedEmoteSlashNames = {}
	CIA.sortedEmoteDisplayNames = {}
	emoteByEmoteIndeces = {}
	emoteBySlashNames = {}
	CIA.unlockedEmotes = {}
	for i=1, GetNumEmotes() do
		local slashName, category, emoteId, displayName = GetEmoteInfo(i)
		table.insert(CIA.sortedEmoteSlashNames, string.sub(slashName, 2))
		table.insert(CIA.sortedEmoteDisplayNames, displayName)
		
		local emote = {}
		emote.emoteIndex = i
		emote.displayName = displayName
		emote.slashName = slashName
		emote.category = category
		
		emoteByEmoteIndeces[i] = emote
		emoteBySlashNames[slashName] = emote
	
		if (GetEmoteCollectibleId(i) == nil or
			(GetEmoteCollectibleId(i) ~= nil and IsCollectibleUnlocked(GetEmoteCollectibleId(i)))) then
			table.insert(CIA.unlockedEmotes, emote)
		end
		
		SLASH_COMMANDS["/"..CIA.sortedEmoteSlashNames[i]] = function()
			CIA.StopActiveIdleSetTemporarily()
			PlayEmoteByIndex(i)
		end
	end

	CIA.sortedUnlockedEmotes = {}
	table.sort(CIA.sortedEmoteSlashNames)
	for _, sn in pairs(CIA.sortedEmoteSlashNames) do
		if (Length(CIA.sortedUnlockedEmotes) == 0 or
			CIA.sortedUnlockedEmotes[Length(CIA.sortedUnlockedEmotes)].slashName ~= "/"..sn) then
			for _, ue in pairs(CIA.unlockedEmotes) do
				if (ue.slashName == "/"..sn) then
					table.insert(CIA.sortedUnlockedEmotes, ue)
					break
				end
			end
		end
	end
	
	CIA.idleSetTitles = {}
	CIA.movedSinceLastUpdate = false
	CIA.emoteCategoryNames = {
		[EMOTE_CATEGORY_CEREMONIAL] = "Ceremonial",
		[EMOTE_CATEGORY_CHEERS_AND_JEERS] = "Cheers and Jeers",
		[EMOTE_CATEGORY_COLLECTED] = "Collected",
		[EMOTE_CATEGORY_DEPRECATED] = "Deprecated",
		[EMOTE_CATEGORY_EMOTION] = "Emotion",
		[EMOTE_CATEGORY_ENTERTAINMENT] = "Entertainment",
		[EMOTE_CATEGORY_FOOD_AND_DRINK] = "Food and Drink",
		[EMOTE_CATEGORY_GIVE_DIRECTIONS] = "Give Directions",
		[EMOTE_CATEGORY_INVALID] = "Invalid",
		[EMOTE_CATEGORY_PERPETUAL] = "Perpetual",
		[EMOTE_CATEGORY_PERSONALITY_OVERRIDE] = "Personality Override",
		[EMOTE_CATEGORY_PHYSICAL] = "Physical",
		[EMOTE_CATEGORY_POSES_AND_FIDGETS] = "Poses and Fidgets",
		[EMOTE_CATEGORY_PROP] = "Prop",
		[EMOTE_CATEGORY_SOCIAL ] = "Social"
	}
	
	CIA.LoadSavedVariables()
	
	if (CIA.enabled and Length(CIA.idleSets) > 0) then
		CIA.idleSets[CIA.activeIdleSetIndex]:Start()
	end
end

function CIA.OnAddOnLoaded(event, addonName)
	if addonName == CIA.name then
		CIA.Initialize()
		CIA.InitializeLAM()
		
		if (CIA.openMenuAfterReload == true) then
			CIA.openMenuAfterReload = nil
			CIA.SaveSavedVariables()
			EVENT_MANAGER:RegisterForEvent("Open"..CIA.name.."Menu", EVENT_PLAYER_ACTIVATED , function() DoCommand("/cia") end)
		end
	end
end

function CIA.LoadSavedVariables()
	CIA.savedVariables = ZO_SavedVars:New("CustomIdleAnimationVariables", CIA.savedVariablesVersion, nil, {})
	local needToSave = false;

	if (CIA.savedVariables.active ~= nil or
		CIA.savedVariables.activeEmoteSet ~= nil or
		CIA.savedVariables.idleEmotes ~= nil or
		CIA.savedVariables.idleEmotesWeightings ~= nil or
		CIA.savedVariables.minEmoteTime ~= nil or
		CIA.savedVariables.updateDelay ~= nil) then
		needToSave = true
		CIA.savedVariables.enabled = CIA.savedVariables.active
		CIA.savedVariables.activeIdleSetIndex = CIA.savedVariables.activeEmoteSet

		if (CIA.savedVariables.idleEmotes ~= nil) then
			CIA.savedVariables.idleSets = {}
			for k, v in pairs(CIA.savedVariables.idleEmotes) do
				CIA.savedVariables.idleSets[k] = IdleSet(k)
				CIA.savedVariables.idleSets[k].delay = CIA.savedVariables.updateDelay[k] * 0.001
				for k2, v2 in pairs(CIA.savedVariables.idleEmotes[k]) do
					local emoteSlashName = v2
					if (string.sub(emoteSlashName, 1, 1) ~= "/") then
						emoteSlashName = "/"..emoteSlashName
					end

					CIA.savedVariables.idleSets[k]:Add(Idle(emoteSlashName, CIA.savedVariables.minEmoteTime[k] * 0.001, CIA.savedVariables.idleEmotesWeightings[k][k2], false))
				end
			end
		end
		
		CIA.savedVariables.active = nil
		CIA.savedVariables.activeEmoteSet = nil
		CIA.savedVariables.idleEmotes = nil
		CIA.savedVariables.idleEmotesWeightings = nil
		CIA.savedVariables.minEmoteTime = nil
		CIA.savedVariables.updateDelay = nil

		EVENT_MANAGER:RegisterForEvent(CIA.name.."SavedVariablesUpdate", EVENT_PLAYER_ACTIVATED , function() d(CIA.title.." was updated to version "..CIA.version..". Please have a look at your Idle Sets and check if everything is set as you like.") end)
	end
	
	CIA.enabled = CIA.savedVariables.enabled
	if (CIA.enabled == nil) then
		CIA.enabled = true
		needToSave = true
	end
	
	CIA.activeIdleSetIndex = CIA.savedVariables.activeIdleSetIndex
	if (CIA.activeIdleSetIndex == nil) then
		CIA.activeIdleSetIndex = 1
		needToSave = true
	end
	
	CIA.idleSets = {}
	if (CIA.savedVariables.idleSets ~= nil) then
		for k,v in pairs(CIA.savedVariables.idleSets) do
			CIA.idleSets[k] = IdleSet.Copy(v)
			CIA.idleSetTitles[k] = v.title
		end
	else
		CIA.idleSets = {
			[1] = IdleSet("Default"),
			[2] = IdleSet("Bard"),
			[3] = IdleSet("Dancer")
		}
		
		CIA.idleSets[1]:Add(Idle("/juggleflame", 10, 100, false))

		CIA.idleSets[2]:Add(Idle("/lute", 10, 100, false))
		CIA.idleSets[2]:Add(Idle("/drink", 5, 5, false))
		CIA.idleSets[2]:Add(Idle("/eat2", 6.5, 5, false))
		
		CIA.idleSets[3]:Add(Idle("/dance", 10, 100, false))
		CIA.idleSets[3]:Add(Idle("/dancedrunk", 10, 100, false))
		CIA.idleSets[3]:Add(Idle("/dancealtmer", 10, 100, false))
		CIA.idleSets[3]:Add(Idle("/danceargonian", 10, 100, false))
		CIA.idleSets[3]:Add(Idle("/dancebosmer", 10, 100, false))
		CIA.idleSets[3]:Add(Idle("/dancedunmer", 10, 100, false))
		CIA.idleSets[3]:Add(Idle("/danceimperial", 10, 100, false))
		CIA.idleSets[3]:Add(Idle("/dancekhajiit", 10, 100, false))
		CIA.idleSets[3]:Add(Idle("/dancenord", 10, 100, false))
		CIA.idleSets[3]:Add(Idle("/danceorc", 10, 100, false))
		CIA.idleSets[3]:Add(Idle("/danceredguard", 10, 100, false))
		
		CIA.idleSetTitles = { CIA.idleSets[1].title, CIA.idleSets[2].title, CIA.idleSets[3].title }
		
		needToSave = true
	end
	
	CIA.openMenuAfterReload = CIA.savedVariables.openMenuAfterReload
	
	if needToSave then
		CIA.SaveSavedVariables()
	end
end

function CIA.SaveSavedVariables()
	CIA.savedVariables.enabled = CIA.enabled
	CIA.savedVariables.activeIdleSetIndex = CIA.activeIdleSetIndex
	CIA.savedVariables.idleSets = CIA.idleSets
	CIA.savedVariables.openMenuAfterReload = CIA.openMenuAfterReload
end

function CIA.StartActiveIdleSet()
	if (CIA.enabled) then
		CIA.idleSets[CIA.activeIdleSetIndex]:Start()
	end
end

function CIA.StopActiveIdleSet()
	CIA.idleSets[CIA.activeIdleSetIndex]:Stop()
end

function CIA.StopActiveIdleSetTemporarily()
    CIA.StopActiveIdleSet()
    EVENT_MANAGER:RegisterForUpdate(CIA.name.."Update", 100, CIA.StartIdleSetAfterMove)
end

function CIA.StartIdleSetAfterMove()
	if (not CIA.enabled) then
		return
	end

	if (CIA.movedSinceLastUpdate) then
		CIA.StartActiveIdleSet()
		CIA.movedSinceLastUpdate = false
		EVENT_MANAGER:UnregisterForUpdate(CIA.name.."Update")
		return
	end
	
	if (IsPlayerMoving()) then
		CIA.movedSinceLastUpdate = true
	end
end

function CIA.ToggleEnabled()
	CIA.enabled = not CIA.enabled
	if (CIA.enabled) then
		CIA.idleSets[CIA.activeIdleSetIndex]:Start()
		d("Activated "..CIA.title.." with Idle Set "..CIA.idleSets[CIA.activeIdleSetIndex].title)
	else
		CIA.idleSets[CIA.activeIdleSetIndex]:Stop()
		d("Deactivated "..CIA.title)
	end
	CIA.SaveSavedVariables()
end

function CIA.NextIdleSet()
	if (CIA.enabled and CIA.activeIdleSetIndex + 1 <= Length(CIA.idleSets)) then
		CIA.idleSets[CIA.activeIdleSetIndex]:Stop()
		CIA.activeIdleSetIndex = CIA.activeIdleSetIndex + 1
		CIA.idleSets[CIA.activeIdleSetIndex]:Start()
		d("Switching to Idle Set "..CIA.idleSets[CIA.activeIdleSetIndex].title)
	end
end

function CIA.PreviousIdleSet()
	if (CIA.enabled and CIA.activeIdleSetIndex - 1 >= 1) then
		CIA.idleSets[CIA.activeIdleSetIndex]:Stop()
		CIA.activeIdleSetIndex = CIA.activeIdleSetIndex - 1
		CIA.idleSets[CIA.activeIdleSetIndex]:Start()
		d("Switching to Idle Set "..CIA.idleSets[CIA.activeIdleSetIndex].title)
	end
end

function CIA.InitializeLAM()
	local panelData =
	{
		type = "panel",
		name = CIA.title,
		displayName = CIA.title.." Settings",
		author = CIA.author,
		version = CIA.version,
		slashCommand = "/cia",
		registerForRefresh = true,
		registerForDefaults = false
	}
	LAM.panel = LAM:RegisterAddonPanel("Custom Idle Animation Settings", panelData)
	
	local defaultDelay = 0
	local defaultMinTime = 5
	local defaultPriority = 1
	local defaultLoop = false
	
	local optionsData = {
		[1] =  {
			type = "checkbox",
			name = "Custom Idle Animation",
			tooltip = "Activates/Deactivates this addon.",
			width = "full",
			getFunc = function() return CIA.enabled end,
            setFunc = CIA.ToggleEnabled
		},
		[2] = { type = "divider" },
		[3] = {
			type = "dropdown",
			name = "Active Idle Set",
			tooltip = "Change the active Idle Set.",
			choices = CIA.idleSetTitles,
			getFunc = function() return CIA.idleSets[CIA.activeIdleSetIndex].title end,
			setFunc = function(value)
				local index = FindIndex(CIA.idleSetTitles, value)
				if (index ~= nil) then
					CIA.idleSets[CIA.activeIdleSetIndex]:Stop()
					CIA.activeIdleSetIndex = index
					CIA.SaveSavedVariables()
					CIA.idleSets[CIA.activeIdleSetIndex]:Start()
				end
			end,
			disabled = function() return not CIA.enabled end,
			width = "half"
		},
		[4] = {
			type = "editbox",
			name = "",
			tooltip = "Change the name of the active Idle Set.",
			getFunc = function() return CIA.idleSets[CIA.activeIdleSetIndex].title end,
			setFunc = function(value)
				local existingTitleIndex = FindIndex(CIA.idleSetTitles, value)
				if (existingTitleIndex == nil) then
					existingTitleIndex = FindIndex(CIA.idleSetTitles, CIA.idleSets[CIA.activeIdleSetIndex].title)
					CIA.idleSetTitles[existingTitleIndex] = value
					CIA.idleSets[CIA.activeIdleSetIndex].title = value
				CIA.openMenuAfterReload = true
					CIA.SaveSavedVariables()
					ReloadUI("ingame")
				end
			end,
			isMultiline = false,
			warning = "This will reload the UI!",
			disabled = function() return not CIA.enabled end,
			width = "half",
			default = ""
		},
		[5] = {
			type = "button",
			name = "+",
			tooltip = "Add a new Idle Set",
			func = function()
				local title = "New Idle Set"
				local counter = 0
				while (FindIndex(CIA.idleSetTitles, title) ~= nil) do
					counter = counter + 1
					title = title.." "..counter
				end
				table.insert(CIA.idleSets, IdleSet(title))
				CIA.activeIdleSetIndex = Length(CIA.idleSets)
				CIA.openMenuAfterReload = true
				CIA.SaveSavedVariables()
				ReloadUI("ingame")
			end,
			warning = "This will reload the UI!",
			disabled = function() return not CIA.enabled end,
			width = "half"
		},
		[6] = {
			type = "button",
			name = "-",
			tooltip = "Remove the current active Idle Set",
			func = function()
				CIA.idleSets[CIA.activeIdleSetIndex]:Stop()
				table.remove(CIA.idleSets, CIA.activeIdleSetIndex)
				CIA.activeIdleSetIndex = 1
				CIA.openMenuAfterReload = true
				CIA.SaveSavedVariables()
				ReloadUI("ingame")
			end,
			warning = "This will reload the UI!",
			disabled = function() return not CIA.enabled or Length(CIA.idleSets) <= 1 end,
			width = "half"
		},
		[7] = {
			type = "slider",
			name = "Delay",
			tooltip = "Set the delay, before any emote is played, in seconds.",
			default = defaultDelay,
			min = 0,
			max = 600,
			step = 0.1,
			decimals = 1,
			getFunc = function() return CIA.idleSets[CIA.activeIdleSetIndex].delay end,
			setFunc = function(var)
				CIA.idleSets[CIA.activeIdleSetIndex].delay = var
				CIA.SaveSavedVariables()
			end,
			disabled = function() return not CIA.enabled or Length(CIA.idleSets) < 1 end,
			width = "full"
		}
	}
	
	local counter = Length(optionsData) + 1
	for i=1, Length(CIA.sortedUnlockedEmotes) do
		local optionData = nil
		for k, v in pairs(optionsData) do
			if (v.category == CIA.sortedUnlockedEmotes[i].category) then
				optionData = optionsData[k]
			end
		end
		
		if (optionData == nil) then
			optionsData[counter] = {
				type = "submenu",
				name = CIA.emoteCategoryNames[CIA.sortedUnlockedEmotes[i].category],
				tooltip = "",
				disabled = function() return not CIA.enabled end,
				controls = {},
				category = CIA.sortedUnlockedEmotes[i].category,
				reference = "submenu"..CIA.sortedUnlockedEmotes[i].category
			}
			optionData = optionsData[counter]
		else
			counter = counter - 1
			table.insert(optionData.controls, { type = "divider" })
		end

		local disabled = function()
			return not CIA.enabled or
				   CIA.idleSets[CIA.activeIdleSetIndex]:Get(CIA.sortedUnlockedEmotes[i].slashName) == nil
		end
		table.insert(optionData.controls, {
			type = "checkbox",
			name = CIA.sortedUnlockedEmotes[i].displayName,
			tooltip = CIA.sortedUnlockedEmotes[i].slashName,
			getFunc = function() return CIA.idleSets[CIA.activeIdleSetIndex]:Get(CIA.sortedUnlockedEmotes[i].slashName) ~= nil end,
			setFunc = function(value)
				if (value) then
					CIA.idleSets[CIA.activeIdleSetIndex]:Add(Idle(CIA.sortedUnlockedEmotes[i].slashName, defaultMinTime, defaultPriority, defaultLoop))
				else
					CIA.idleSets[CIA.activeIdleSetIndex]:Remove(CIA.idleSets[CIA.activeIdleSetIndex]:Get(CIA.sortedUnlockedEmotes[i].slashName))
				end
				CIA.SaveSavedVariables()
			end,
			width = "half"
		})
		table.insert(optionData.controls, {
			type = "checkbox",
			name = "Loop",
			tooltip = "Should this emote repeatedly play during its minimum time?",
			default = defaultLoopEmotes,
			getFunc = function()
				if (not disabled()) then
					return CIA.idleSets[CIA.activeIdleSetIndex]:Get(CIA.sortedUnlockedEmotes[i].slashName).loop
				end	
			end,
			setFunc = function(var)
				CIA.idleSets[CIA.activeIdleSetIndex]:Get(CIA.sortedUnlockedEmotes[i].slashName).loop = var
				CIA.SaveSavedVariables()
			end,
			width = "half",
			disabled = disabled
		})
		table.insert(optionData.controls, {
			type = "slider",
			name = "Priority",
			tooltip = "Set the priority of this emote. If it is higher than the other priorities, then this emote will be played more often.",
			default = defaultPriority,
			min = 1,
			max = 100,
			step = 1,
			getFunc = function()
				if (not disabled()) then
					return CIA.idleSets[CIA.activeIdleSetIndex]:Get(CIA.sortedUnlockedEmotes[i].slashName).priority
				end	
			end,
			setFunc = function(var)
				CIA.idleSets[CIA.activeIdleSetIndex]:Get(CIA.sortedUnlockedEmotes[i].slashName).priority = var
				CIA.SaveSavedVariables()
			end,
			width = "half",
			disabled = disabled
		})
		table.insert(optionData.controls, {
			type = "slider",
			name = "Minimum Time",
			tooltip = "Set the minimum time in seconds this emote should be played.",
			default = defaultMinTime,
			min = 0.1,
			max = 600,
			step = 0.1,
			decimals = 1,
			getFunc = function()
				if (not disabled()) then
					return CIA.idleSets[CIA.activeIdleSetIndex]:Get(CIA.sortedUnlockedEmotes[i].slashName).minimumTime
				end
			end,
			setFunc = function(var)
				CIA.idleSets[CIA.activeIdleSetIndex]:Get(CIA.sortedUnlockedEmotes[i].slashName).minimumTime = var
				CIA.SaveSavedVariables()
			end,
			width = "half",
			disabled = disabled
		})
		
		counter = counter + 1
	end
	table.remove(optionsData[counter - 1].controls, Length(optionsData[counter - 1].controls))

	LAM:RegisterOptionControls(CIA.title.." Settings", optionsData)
end

EVENT_MANAGER:RegisterForEvent(CIA.name, EVENT_ADD_ON_LOADED, CIA.OnAddOnLoaded)
ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_CUSTOM_IDLE_ANIMATION", "Toggle Custom Idle Animation")
ZO_CreateStringId("SI_BINDING_NAME_SWITCH_TO_NEXT_IDLE_SET", "Switch to next Idle Set")
ZO_CreateStringId("SI_BINDING_NAME_SWITCH_TO_PREVIOUS_IDLE_SET", "Switch to previous Idle Set")