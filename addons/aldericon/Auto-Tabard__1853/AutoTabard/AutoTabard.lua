--[[
This Add-on is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its affiliates. 
The Elder Scrolls® and related logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States and/or other countries. 
All rights reserved

You can read the full terms at https://account.elderscrollsonline.com/add-on-terms]]

--[[
Acknowledgments

I'd like to thank the following people for helping me, either with testing or giving me ideas:
- @Draconise

I'd like to thank the following addons; this was my first addon and by examining their code helped me learn a lot:
- pChat by Puddy
- Dressing Room by dividee
]]

-- Initialized the addon names
AutoTabard = {}
AutoTabard.name = "AutoTabard"
AutoTabard.version = 12.0

-- For the addon settings menu
AutoTabard.LAM2 = LibAddonMenu2

-- Initializes various things; variables aptly named
AutoTabard.allGuilds = {}
AutoTabard.guildNames = {}
AutoTabard.costumeId = 10
AutoTabard.debug = false
AutoTabard.inGroup = false
AutoTabard.playerInCombat = false

-- Saved beyond session variables
AutoTabard.defaults={
	unequipTabard=true,
	soloPlayPVP=6,
	soloPlayPVE=6,
	guildOption={},
	guildLeads={},
	guildTabards={},
	listGuildLeads={}
}

function AutoTabard:Initialize()
	AutoTabard.changeTabard()

	EVENT_MANAGER:RegisterForEvent(AutoTabard.Name, EVENT_LEADER_UPDATE, AutoTabard.onGroupChange)
	EVENT_MANAGER:RegisterForEvent(AutoTabard.name, EVENT_PLAYER_ACTIVATED, AutoTabard.onPlayerActivated)
	EVENT_MANAGER:RegisterForUpdate(AutoTabard.name, 1000, AutoTabard.CheckGroupStatus)
	EVENT_MANAGER:RegisterForEvent(AutoTabard.name, EVENT_PLAYER_COMBAT_STATE, AutoTabard.OnPlayerCombatState)
end

function AutoTabard.OnAddOnLoaded(event, addonName)
	if addonName ~= AutoTabard.name then
		return
	end

	AutoTabard.SV = ZO_SavedVars:New("AutoTabardTrackerSettings", 1.0, "Settings", AutoTabard.defaults)
	AutoTabard:SetupGuilds()
	AutoTabard:InitializeAddonMenu()

	EVENT_MANAGER:UnregisterForEvent(AutoTabard.name, EVENT_ADD_ON_LOADED)

	AutoTabard:Initialize()
end

-- only want to try to swap when not in combat
function AutoTabard.OnPlayerCombatState(event, inCombat)
	if inCombat ~= AutoTabard.playerInCombat then
		AutoTabard.playerInCombat = inCombat
	end
end

-- no event for yourself joining / leaving group
function AutoTabard.CheckGroupStatus()
	local playerInGroup = AutoTabard.isPlayerInGroup()

	if playerInGroup ~= AutoTabard.inGroup then
		AutoTabard.changeTabard()
	end

	AutoTabard.inGroup = playerInGroup
end

function AutoTabard:SetupGuilds()
	AutoTabard.allGuilds = {}
	AutoTabard.guildNames = {}

	for guild = 1, GetNumGuilds() do
		local guildId = GetGuildId(guild)
		local guildName = GetGuildName(guildId)

		if (not guildName or (guildName):len() < 1) then
			guildName = "Guild " .. guildId
		end

		AutoTabard.allGuilds[guildName] = guildName
		AutoTabard.guildNames[guildName] = guildName

		if AutoTabard.SV.guildOption[guildId] ~= nil then
			AutoTabard.SV.guildOption[guildName] = AutoTabard.SV.guildOption[guildId]
		end

		if AutoTabard.SV.guildLeads[guildId] ~= nil then
			AutoTabard.SV.guildLeads[guildName] = AutoTabard.SV.guildLeads[guildId]
		end

		if AutoTabard.SV.guildTabards[guildId] ~= nil then
			AutoTabard.SV.guildTabards[guildName] = AutoTabard.SV.guildTabards[guildId]
		end
	end
end

function AutoTabard.onGroupChange(eventCode, leaderTag)
	if AutoTabard.debug == true then
		d("Inside onGroupChange")
	end

	AutoTabard.changeTabard()
end

function AutoTabard.onPlayerActivated(eventCode, initial)
	AutoTabard.changeTabard()
end

-- get unique item id of the right tabard connected to the right guild
function AutoTabard.registerGuildTabard(guildId)
	local uniqueId = Id64ToString(GetItemUniqueId(BAG_WORN, AutoTabard.costumeId))

	if AutoTabard.debug == true then
		d("Unique ID: "..uniqueId)
	end

	if uniqueId == '0' then
		d("Auto-Tabard tried to register your Guild Tabard but failed (make sure you have a tabard equipped)!")
		return
	end

	if AutoTabard.SV.guildTabards == nil then
		AutoTabard.SV.guildTabards[guildId] = -1
	end

	AutoTabard.SV.guildTabards[guildId] = uniqueId

	d("Registered tabard for guild: "..AutoTabard.guildNames[guildId])

	if AutoTabard.debug == true then
		d("Guild Tabard ID: "..uniqueId)
	end
end

-- grabbed from pChat; writes out your group leaders for the right guild
function AutoTabard.BuildGroupLeaders(guildId)
	local function Explode(div, str)
		if (div=='') then return false end
		local pos,arr = 0,{}
		for st,sp in function() return string.find(str,div,pos,true) end do
			table.insert(arr,string.sub(str,pos,st-1))
			pos = sp + 1
		end
		table.insert(arr,string.sub(str,pos))
		return arr
	end

	if AutoTabard.SV.guildLeads[guildId] ~= "" then
		local lines = Explode("\n", AutoTabard.SV.guildLeads[guildId])

		for lineIndex=#lines, 1, -1 do
			local userId = lines[lineIndex]

			if not (userId) then
				table.remove(lines, lineIndex)
			else
				AutoTabard.SV.listGuildLeads[userId] = guildId
			end
		end

		AutoTabard.SV.guildLeads[guildId] = table.concat(lines, "\n")
	end
end

function AutoTabard.isPlayerInGroup()
	if GetGroupSize() > 0 then
		return true
	end

	return false
end

function AutoTabard.equipTabard(guildId)
	if next(AutoTabard.SV.guildTabards) == nil then
		d("No guild tabards found!")
		return
	end

	if AutoTabard.SV.guildTabards[guildId] == nil then
		d("Guild tabard not found for this guild: "..AutoTabard.guildNames[guildId])
		return
	end

	local uniqueId = AutoTabard.SV.guildTabards[guildId]

	if AutoTabard.debug == true then
		d("Found unique id: "..uniqueId)
	end

	for slotIndex = 0, GetBagSize(BAG_BACKPACK) do
		local id = Id64ToString(GetItemUniqueId(BAG_BACKPACK, slotIndex))

		if id == uniqueId then
			EquipItem(BAG_BACKPACK, slotIndex, EQUIP_SLOT_COSTUME)
			d("Equipped tabard for guild: "..AutoTabard.guildNames[guildId])
			return
		end
	end
end

function AutoTabard.unequipTabard()
	-- if we don't meet any criteria, see if we unequip any equiped tabard
	if AutoTabard.SV.unequipTabard == true then
		-- only unequip if something equiped
		if Id64ToString(GetItemUniqueId(BAG_WORN, AutoTabard.costumeId)) == '0' then
			return
		end

		UnequipItem(EQUIP_SLOT_COSTUME)
		d("Unequipped Guild Tabard")
	end
end

function AutoTabard.changeTabard()
	if next(AutoTabard.SV.guildTabards) == nil then
		d("No guild tabards found!")
		AutoTabard.unequipTabard()
		return
	end

	-- don't try in combat; reduce lag and can't change costume anyways
	if AutoTabard.playerInCombat == true then
		return
	end

	-- first check if player is solo
	local playerInGroup = AutoTabard.isPlayerInGroup()

	if AutoTabard.debug == true then
		d("In Group: "..tostring(playerInGroup))
	end

	if playerInGroup == false then
		if IsPlayerInAvAWorld() == true then
			if AutoTabard.debug == true then
				d("Solo PVP Option: "..AutoTabard.SV.soloPlayPVP)
			end

			if AutoTabard.SV.soloPlayPVP ~= 6 then
				AutoTabard.equipTabard(AutoTabard.SV.soloPlayPVP)
				return
			end
		else
			if AutoTabard.debug == true then
				d("Solo PVE Option: "..AutoTabard.SV.soloPlayPVE)
			end

			if AutoTabard.SV.soloPlayPVE ~= 6 then
				AutoTabard.equipTabard(AutoTabard.SV.soloPlayPVE)
				return
			end
		end

		AutoTabard.unequipTabard()
		return
	end

	-- only continue if player is in group
	if playerInGroup ~= true then
		AutoTabard.unequipTabard()
		return
	end

	-- see if we have settings for current group leader
	local groupLeaderUserID = GetUnitDisplayName(GetGroupLeaderUnitTag())

	if AutoTabard.debug == true then
		d("Looking for group leader of: "..groupLeaderUserID)
	end

	if AutoTabard.SV.listGuildLeads[groupLeaderUserID] == nil then
		AutoTabard.unequipTabard()
		return
	end

	-- see if we have option set for guild found
	local guildId = AutoTabard.SV.listGuildLeads[groupLeaderUserID]

	if AutoTabard.debug == true then
		d("Looking for group id of: "..guildId)
	end

	if AutoTabard.SV.guildOption[guildId] == 1 then
		AutoTabard.unequipTabard()
		return
	end

	if AutoTabard.debug == true then
		d("Looking for group option of: "..AutoTabard.SV.guildOption[guildId])
	end

	-- check conditions of guild option
	if AutoTabard.SV.guildOption[guildId] == 2 then
		-- already in group
		AutoTabard.equipTabard(guildId)
		return
	elseif AutoTabard.SV.guildOption[guildId] == 3 then
		-- check if we're in PVP
		if IsPlayerInAvAWorld() == true then
			AutoTabard.equipTabard(guildId)
			return
		end
	end

	AutoTabard.unequipTabard()
end

function AutoTabard:InitializeAddonMenu()
	local panelData = {
		type = "panel",
		name = "Auto-Tabard",
		displayName = "|c66ccffAuto-Tabard",
		author = "|c4779ce@aldericon|r",
		version = string.format("%.1f", AutoTabard.version),
		slashCommand = "/autotabard",
		registerForRefresh = true,
		registerForDefaults = true
	}

	local optionsPanel = self.LAM2:RegisterAddonPanel("Auto_Tabard", panelData)
	local optionsData = {}

	table.insert(optionsData, {
		type = "description",
		text = "Auto-Tabard is a way to automate when you want to have a specific Guild Tabard equipped.",
	})
	table.insert(optionsData, {
		type = "header",
		name = "Auto-Tabard Options",
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Unequip Guild Tabard:",
		tooltip = "ON - will unequip the tabard if your current situation doesn't meet any defined criteria, OFF - will never unequip the guild tabard",
		default = self.defaults.unequipTabard,
		getFunc = function() return self.SV.unequipTabard end,
		setFunc = function(newValue) self.SV.unequipTabard = newValue AutoTabard.changeTabard() end,
	})

	local justGuildNames = {}

	for k,v in pairs(self.guildNames) do
	  table.insert(justGuildNames, v)
	end

	table.insert(optionsData, {
		type = "dropdown",
		name = "Choose Tabard when PVP Soloing:",
		tooltip = "Which guild tabard do you want to equip when soloing in PVP?",
		choices = {"None", unpack(justGuildNames)},
		getFunc = function() 
			if self.SV.soloPlayPVP==6 then 
				return "None"
			else
				return self.allGuilds[self.SV.soloPlayPVP]
			end
		end,
		setFunc = function(newValue)
			if newValue=="None" then 
				self.SV.soloPlayPVP=6
			else
				for guildId, guildName in pairs(self.allGuilds) do
					if newValue == guildName then
						self.SV.soloPlayPVP = guildId
						break
					end
				end
			end
			self.changeTabard()
		end,
		default = 6,
	})
	table.insert(optionsData, {
		type = "dropdown",
		name = "Choose Tabard when PVE Soloing:",
		tooltip = "Which guild tabard do you want to equip when soloing in PVE?",
		choices = {"None", unpack(justGuildNames)},
		getFunc = function() 
			if self.SV.soloPlayPVE==6 then 
				return "None"
			else
				return self.allGuilds[self.SV.soloPlayPVE]
			end
		end,
		setFunc = function(newValue)
			if newValue=="None" then 
				self.SV.soloPlayPVE=6
			else
				for guildId, guildName in pairs(self.allGuilds) do
					if newValue == guildName then
						self.SV.soloPlayPVE = guildId
						break
					end
				end
			end
			self.changeTabard()
		end,
		default = 6,
	})

	for guildId, guildName in pairs(self.allGuilds) do
		table.insert(optionsData, {
			type = "header",
			name = guildName .. " Options",
		})
		table.insert(optionsData, {
			type = "button",
			name = "Register Tabard",
			tooltip = "Click this while wearing the appropriate Guild Tabard for this guild to register the tabard's id",
			func = function ()
				self.registerGuildTabard(guildId)
				self.changeTabard()
			end,
		})
		table.insert(optionsData, {
			type = "dropdown",
			name = "When to Auto-Equip:",
			tooltip = "What criteria must be true for you to equip this guild's tabard?",
			choices = {"Never", "In Group", "In PVP & Group"},
			getFunc = function()
				local guildOptionChosen = 1

				if self.SV.guildOption[guildId] ~= nil then
					guildOptionChosen = self.SV.guildOption[guildId]
				end

				if guildOptionChosen == 1 then
					return "Never"
				elseif guildOptionChosen == 2 then
					return "In Group"
				elseif guildOptionChosen == 3 then
					return "In PVP & Group"
				end
			end,
			setFunc = function(newValue)
				local guildOptionChosen = 1

				if newValue=="In Group" then
					guildOptionChosen=2
				elseif newValue=="In PVP & Group" then
					guildOptionChosen=3
				end

				if self.SV.guildOption[guildId] == nil then
					self.SV.guildOption[guildId] = 1
				end

				self.SV.guildOption[guildId] = guildOptionChosen
				
				AutoTabard.changeTabard()
			end,
			default = 1,
		})
		table.insert(optionsData, {
			type = "editbox",
			name = "Group Leaders:",
			tooltip = "If option selected for guild includes 'In Group', write here the UserIDs of the players that will be the Group Leader when you need to equip the tabard.",
			disabled = function()
				if self.SV.guildOption[guildId] == 1 then
					return true
				end
			end,
			isMultiline = true,
			isExtraWide = true,
			getFunc = function() 
				if self.SV.guildLeads == nil then
					self.SV.guildLeads[guildId] = ''
				end

				return self.SV.guildLeads[guildId]
			end,
			setFunc = function(newValue)
				if self.SV.guildLeads == nil then
					self.SV.guildLeads[guildId] = ''
				end

				self.SV.guildLeads[guildId] = newValue
				self.BuildGroupLeaders(guildId)
				AutoTabard.changeTabard()
			end,
			width = "full",
		})
	end

	self.LAM2:RegisterOptionControls("Auto_Tabard", optionsData)	
end

EVENT_MANAGER:RegisterForEvent(AutoTabard.name, EVENT_ADD_ON_LOADED, AutoTabard.OnAddOnLoaded)
