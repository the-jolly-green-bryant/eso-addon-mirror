Ultibomb = {}
Ultibomb.name = 'Ultibomb'
Ultibomb.isLoaded = false
Ultibomb._playerInfoString = ''
Ultibomb.Helpers = {}

Ultibomb._commandState = 'off'

Ultibomb.dev = true;

Ultibomb.manifest = {
	[1] = {
		ultiType = 1,
		key = 'Dawnbreakers',
		data = {},
		cost = 125,
		colors = {r=0.6784,g=0.6235,b=0.1137,zo='|cad9f1d'}
	},
	[2] = {
		ultiType = 2,
		key = 'Negates',
		data = {},
		cost = 192,
		colors = {r=1.0000,g=0.1098,b=0.9686,zo='|cff1cf7'}
	},
	[3] = {
		ultiType = 3,
		key = 'Sleets',
		data = {},
		cost = 200,
		colors = {r=0.1216,g=0.6196,b=0.7569,zo='|c1f9ec1'}
	},
	[4] = {
		ultiType = 4,
		key = 'Restos',
		data = {},
		cost = 125,
		colors = {r=0.6784,g=0.6235,b=0.1137,zo='|cad9f1d'}
	},
	[5] = {
		ultiType = 5,
		key = 'Destros',
		data = {},
		cost = 255,
		colors = {r=0.9098,g=0.1725,b=0.1725,zo='|ce82c2c'}
	},	
	[6] = {
		ultiType = 6,
		key = 'Shifting',
		data = {},
		cost = 225,
		colors = {r=0.7569,g=0.4627,b=0.2471,zo='|cc1763f'}
	},
	[7] = {
		ultiType = 7,
		key = 'Novas',
		data = {},
		cost = 250,
		colors = {r=0.6784,g=0.6235,b=0.1137,zo='|cad9f1d'}
	},
	[8] = {
		ultiType = 8,
		key = 'Colossus',
		data = {},
		cost = 225,
		colors = {r=0.1216,g=0.6196,b=0.7569,zo='|c1f9ec1'}
	}

}

local panelData = {
     type = "panel",
     name = "Ultibomb",
     author = 'ghostbane',
}

local db = {}

local defaults = {
	ultis = {
		['Dawnbreakers'] = true,
		['Negates'] = true,
		['Sleets'] = true,
		['Restos'] = true,
		['Destros'] = true,
		['Shifting'] = true,
		['Novas'] = true,
		['Colossus'] = true
	},
	layoutMode = {
		Horizontal = false,
		Vertical = true
	}
}

local optionsData = {}

optionsData[#optionsData+1] = {
    type = "header",
    name = "Ulti View Settings",
}

for i in pairs(Ultibomb.manifest) do
	
	local key = Ultibomb.manifest[i].key

	optionsData[#optionsData+1] = {
	    type = "checkbox",
	    name = key,
	    tooltip = "Yo "..key,
	    getFunc = function() return db.ultis[key] end,
	    setFunc = function(value) 
	    	db.ultis[key] = value
	    	Ultibomb.CreateGUIContainers()
	    end,
	    default = defaults.ultis[key]
	}

end

optionsData[#optionsData+1] = {
    type = "description",
    title = "",
    text = [[
    ]]
}
optionsData[#optionsData+1] = {
    type = "header",
    name = "Layout",
}

optionsData[#optionsData+1] = {
	type = "dropdown",
	name = "Layout Mode:",
	tooltip = "Choose your layout mode",
	choices = {'Vertical','Horizontal'},
	getFunc = function()
		if db.layoutMode.Vertical then
			return 'Vertical'
		else
			return 'Horizontal'
		end
	end,
	setFunc = function(choice)
		
		if choice == 'Vertical' then
			db.layoutMode.Vertical = true
			db.layoutMode.Horizontal = false

			if Ultibomb._commandState == 'on' or Ultibomb._commandState == 'watch' then		
				makeVertical()
			end
		else
			db.layoutMode.Horizontal = true
			db.layoutMode.Vertical = false

			if Ultibomb._commandState == 'on' or Ultibomb._commandState == 'watch' then		
				makeHorz()
			end
		end

	end
}

local LAM2 = LibStub("LibAddonMenu-2.0")

function Ultibomb.Helpers.PercentOrder(a,b)
	return a.percent > b.percent
end

function Ultibomb.Helpers.CountGroup( data )

	local count = 0
  	for _ in pairs(data) do count = count + 1 end
  	return count

end

function Ultibomb:Initialize()

	local self = Ultibomb

	self.isLoaded = true

	self.GUI = {}
	self.ResetCollections()
	self.CreateGUIContainers()

	self.realNames = {}
	self.realNames['@Sezme'] = 'Sezme'
	self.realNames['@enzoisadog'] = 'Enzo'
	self.realNames['@Ghostbane'] = 'Ghost'
	self.realNames['@Syhae'] = 'Sy'
	self.realNames['@ScarrX'] = 'Scarr'
	self.realNames['@IkeESO'] = 'Ike'
	self.realNames['@Lyar09'] = 'Lyar'
	self.realNames['@HashtagReflex'] = 'Hashtag'
	self.realNames['@Gorrest'] = 'Gorrest'
	self.realNames['@angryjanitor2'] = 'Janitor'
	self.realNames['@NirnStorm'] = 'Rue'
	self.realNames['@Static.Wave'] = 'Static'
	self.realNames['@Roaldy'] = 'Roaldy'
	self.realNames['@yougotrekt994'] = 'SHOCK'
	self.realNames['@XoShooter'] = 'Shooter'
	self.realNames['@Theia_LeFay'] = 'Theia'
	self.realNames['@Kuro.Kitsune'] = 'Elia'
	self.realNames['@Trance90'] = 'Trance'

	self.realNames['@Belkin14'] = 'Belkin'
	self.realNames['@Sevah'] = 'Sev'
	self.realNames['@Zehebo'] = 'Z'
	self.realNames['@J18696'] = 'Pride'
	self.realNames['@Rossdresser'] = 'Ross'
	self.realNames['@UrenTelvanni'] = 'Uren'
	self.realNames['@VicMortal'] = 'Dark'
	self.realNames['@Yuki_Aurelius'] = 'Yuki'
	self.realNames['@Teutonicmadden'] = 'Teuty'
	self.realNames['@castlelel'] = 'SUPER CASTLE'
	self.realNames['@Nam0'] = 'Namo'
	self.realNames['@Shockz325'] = 'Shockz'
	self.realNames['@iMorbid'] = 'Morbid'
	self.realNames['@NellyESO'] = 'Nelly'
	self.realNames['@Drunkassbadger'] = 'Raime'
	self.realNames['@TrashGameBTW'] = 'Gundy'
	self.realNames['@big_Joel'] = 'Joel'
	self.realNames['@bmesi'] = 'Afro'
	self.realNames['@Karstyll'] = 'Bee'
	self.realNames['@ghostbane'] = 'Ghost'
	self.realNames['@Vjj'] = 'Vjj'
	self.realNames['@NobleGuardian'] = 'Noble'
	self.realNames['@nerfnightblade'] = 'Rem'
	self.realNames['@itsjeepers'] = 'Jeepers'
	self.realNames['@Datralis23'] = 'Dat'
	-- Assign Dummy data
	-- self.manifest[1].data['@enzo'] = { name='Enzo', percent=125 }
	-- self.manifest[1].data['@scarr'] = { name='Scarr', percent=89 }
	-- self.manifest[1].data['@shooter'] = { name='Shooter', percent=56 }
	-- self.manifest[1].data['@lyar'] = { name='Lyar', percent=22 }

	-- self.manifest[2].data['@sy'] = { name='Sy', percent=101 }
	-- self.manifest[2].data['@static'] = { name='Static', percent=81 }

	-- self.manifest[3].data['@hashtag'] = { name='Hashtag', percent=146 }

	-- self.manifest[4].data['@Ghostbane'] = { name='Ghost', percent=146 }
	-- self.manifest[4].data['@enzo'] = { name='Enzo', percent=146 }
	-- self.manifest[4].data['@scarr'] = { name='Scarr', percent=89 }
	-- self.manifest[4].data['@lyar'] = { name='Lyar', percent=22 }

	-- self.manifest[5].data['@sezme'] = { name='Sezme', percent=146 }

	-- self.manifest[6].data['@gorrest'] = { name='Gorrest', percent=300 }
	-- Ultibomb.memberData.banners['frozn']={name='Frozn',percent=5}
	-- Ultibomb.memberData.banners['@Ghostbane']={name='Wee Mad Arthur',percent=120}
	-- Ultibomb.memberData.banners['kilandros']={name='Kilandros',percent=15}
	-- Ultibomb.memberData.banners['@xvirus123']={name='Malady',percent=195}
	-- Ultibomb.memberData.banners['peggy']={name='Peggy Moe',percent=75}
	-- Ultibomb.memberData.negates['vjori']={name='Vjori',percent=75}
	-- Ultibomb.memberData.negates['paul']={name='Paul Daniels',percent=125}

	-- Fix UI
    UltibombGUIScreenHeader:SetEdgeColor(ZO_ColorDef:New(0,0,0,0):UnpackRGBA())
    UltibombGUIBlankHeader:SetEdgeColor(ZO_ColorDef:New(0,0,0,0):UnpackRGBA())

    -- local test = Squishy.Container:New(UltibombGUI,'Dawnbreakers',{r=0.6784,g=0.6235,b=0.1137,zo='|cad9f1d'})
    -- test:SnapTo(UltibombGUIBlankHeader)
    -- test:SetHeaderCount(0,0)


    -- Legoooo!
	self:Render()

	-- Unattach the listener
	EVENT_MANAGER:UnregisterForEvent(Ultibomb.name, EVENT_ADD_ON_LOADED)
	EVENT_MANAGER:RegisterForEvent(Ultibomb.name, EVENT_ACTION_LAYER_POPPED, self.OnActionLayerChange)
    EVENT_MANAGER:RegisterForEvent(Ultibomb.name, EVENT_ACTION_LAYER_PUSHED, self.OnActionLayerChange)

	
end

function Ultibomb.ResetCollections()

	local self = Ultibomb

	self.memberData = {
		ultimates = {}
	}

	for i in pairs(self.manifest) do
		
		local ultiRecord = self.manifest[i]

		ultiRecord.data = {}

		if self.GUI[ultiRecord.key] then

			local container = self.GUI[ultiRecord.key]
			-- container:HideAllRows()
			container:AdjustBodyHeight(1)
			container:SetHeaderCount(0, 0)
		end
	end

end

function Ultibomb.GetUltiManifestByKey(key)
	
	local self = Ultibomb

	for i in pairs(self.manifest) do
		if self.manifest[i].key == key then
			return self.manifest[i]
		end
	end
end

function Ultibomb.CreateGUIContainers()

	local self = Ultibomb
	local inc = 1

	-- A new container for you sir

	-- self._guiIndex[#self._guiIndex+1] = key
	local lastKey

	for i in pairs(self.manifest) do

		local key = self.manifest[i].key
		local active = db.ultis[key]

		if not self.GUI[key] then
			self.GUI[key] = Squishy.Container:New(UltibombGUI,key,self.GetUltiManifestByKey(key).colors)
			-- d('Creating '..key)
		end

		self.GUI[key]:SetHidden(not active)

		-- d(key,i,active)

		-- We need to decide on where your ulti container should go sir
		-- d(i,key)
		if active then
			if inc == 1 then
				-- Nothing yet, assign to the top
				self.GUI[key]:SnapTo(UltibombGUIBlankHeader)
				lastKey = key
			else
				-- Assign to the last container
				
				local lastContainer = self.GUI[lastKey]
				self.GUI[key]:SnapTo(lastContainer:GetBody())
				lastKey = key
			end

			inc = inc + 1
			self:RenderType(key)
		end
	end
end

function Ultibomb.OnActionLayerChange(_, _, activeLayerIndex)
	if Ultibomb._commandState == 'on' then
		UltibombGUI:SetHidden(activeLayerIndex > 2)
	end
end

function Ultibomb.ParsePartyData(mani)

	local data = mani.data
	local playerInfoString, groupTotal, readyCount = '', 0, 0
	local orderedTable, deadPlayersTable = {}, {}

	for i=1, GetGroupSize() do
		local userName = GetUnitDisplayName("group"..i)
		if userName and userName ~= "" then
			if IsUnitDead("group"..i) then
				deadPlayersTable[userName] = true
			end
		end
	end

	for name in pairs(data) do
		if not deadPlayersTable[name] then
			table.insert(orderedTable, data[name])
		end
	end

	table.sort(orderedTable,Ultibomb.Helpers.PercentOrder)

	for i in ipairs(orderedTable) do

		local color = '|c666666'

		if(orderedTable[i].percent > 99) then
			color = '|c0fe233'
			color = mani.colors.zo
			readyCount = readyCount + 1
		elseif(orderedTable[i].percent > 70) then
			color = '|c999999'
		elseif(orderedTable[i].percent > 50) then
			color = '|c666666'
		elseif(orderedTable[i].percent > 30) then
			color = '|c555555'
		else
			color = '|c444444'
		end

		if(orderedTable[i].percent > 99) then
			playerInfoString = playerInfoString..color..orderedTable[i].name..'|\n'
		else
			playerInfoString = playerInfoString..color..orderedTable[i].name..' '..orderedTable[i].percent..'%|\n'
		end

		groupTotal = groupTotal + 1
	end

	return playerInfoString, groupTotal, readyCount

end

function Ultibomb:RenderType(key)

	local self = Ultibomb

	-- d('RenderType:: '..tostring(key))
	local ultiText, total, ready = self.ParsePartyData( self.GetUltiManifestByKey(key) )

	self.GUI[key].ultiLabel:SetText(ultiText)
	self.GUI[key]:SetHeaderCount(ready,total)

end

function Ultibomb:Render()
	
	local self = Ultibomb

	for i in pairs(self.manifest) do

		self:RenderType(self.manifest[i].key)

	end

	if db.layoutMode.Vertical then
		makeVertical()
	else
		makeHorz()
	end

end

function Ultibomb.OnAddOnLoaded(event, addOnName)
	if addOnName == Ultibomb.name then

		db = ZO_SavedVars:New("UltibombSettings", 1, nil, defaults)
		LAM2:RegisterAddonPanel("UltibombOptions", panelData)
		LAM2:RegisterOptionControls("UltibombOptions", optionsData)

		Ultibomb:Initialize()
	end
end

-- -----------------------
-- Raid Notifier Extension
-- -----------------------
local LGS = LibStub:GetLibrary("LibGroupSocket")
local ultimateHandler = LGS:GetHandler(LGS.MESSAGE_TYPE_ULTIMATE)

function Ultibomb.setLGSMode( enabled )
	ZO_GroupMenu_Keyboard_LibGroupSocketToggle:toggleFunction(enabled)
end

function Ultibomb.OnUltimateReceived(unitTag, ultimateCurrent, ultimateCost, isSelf, ultiType)

	-- local unitTag = 'player'

	-- d('Ulti recieved - '..unitTag..' '..ultiType..' - '..ultimateCurrent..' / '..ultimateCost )

	local self = Ultibomb
	local userName = GetUnitDisplayName(unitTag)
	local tagName = GetUnitName(unitTag)

	if ultiType > 0 and not db.ultis[self.manifest[ultiType].key] then return end

	self.memberData.ultimates[userName] = {
		name = tagName,
		userName = userName,
		current = ultimateCurrent,
		cost = ultimateCost, 
		percent = math.floor((ultimateCurrent / ultimateCost) * 100) --round it down?
	}

	for name in pairs(Ultibomb.realNames) do
		if self.memberData.ultimates[name] then
			self.memberData.ultimates[name].name = Ultibomb.realNames[name]
		end
	end

	for i in pairs(self.manifest) do
		if self.manifest[i].data[userName] then

			-- d('ub: '..i..' = '..ultiType..'   '..tostring(ultimateCost < self.manifest[i].data[userName].cost))
			if i == ultiType and ultimateCost < self.manifest[i].data[userName].cost then
				-- d('|c1f9ec1Adjusting cost of '..i..' to '..ultimateCost)
				self.manifest[i].data[userName].cost = ultimateCost
			end

			local cost = self.manifest[i].data[userName].cost or self.manifest[i]
			-- Log(userName..' Recieving current: '..tostring(ultimateCurrent))
			-- Log(userName..' Recieving cost: '..tostring(cost))
			self.manifest[i].data[userName].current = ultimateCurrent
			self.manifest[i].data[userName].percent = math.floor((ultimateCurrent / cost) * 100)
			
			self:RenderType(self.manifest[i].key)
		end
	end

	-- Are you over 0 sir?
	if ultiType > 0 then

		-- Do we not have your name sir?
		if not self.manifest[ultiType].data[userName] then

			local ultiRecord = self.manifest[ultiType]

			-- d('Creating a '..ultiType..' record for '..userName)
			-- Create a new entry of player info into the manifest of the ulti
			ultiRecord.data[userName] = self.memberData.ultimates[userName]

			-- d(ultiRecord.key)
			-- Re-draw this ulti type
			self:RenderType(ultiRecord.key)
		end
	end

end

function Ultibomb.OnGroupUpdate()

	local self = Ultibomb

	local newMembers = {}
	for i=1, GetGroupSize() do
	-- for i=1, 1 do --self-dev
		local userName = GetUnitDisplayName("group"..i)
		-- local userName = GetUnitDisplayName('player') -- self-dev
		if userName and userName ~= "" then 
			newMembers[userName] = IsUnitOnline("group"..i)
			-- newMembers[userName] = IsUnitOnline('player') -- self-dev
		end
	end

	for userName in pairs(self.memberData.ultimates) do

		if not newMembers[userName] then
			self.memberData.ultimates[userName] = nil

			for i in pairs(self.manifest) do
				if self.manifest[i].data[userName] then
					self.manifest[i].data[userName] = nil
				end
			end

		end
	end

	-- Ultibomb.Render()

end

function Ultibomb.RegisterUltiListeners()
	
	-- Log('RegisterUltiListeners()')
	local self = Ultibomb

	self.setLGSMode(true)
	ultimateHandler:RegisterForUltimateChanges(self.OnUltimateReceived)
	ultimateHandler:Refresh()
	UltibombGUI:SetHidden(false)

	-- OnGroupUpdate()

	EVENT_MANAGER:RegisterForEvent(self.Name, EVENT_GROUP_MEMBER_JOINED, self.OnGroupUpdate)
	EVENT_MANAGER:RegisterForEvent(self.Name, EVENT_GROUP_MEMBER_LEFT,   self.OnGroupUpdate)
	EVENT_MANAGER:RegisterForEvent(self.Name, EVENT_GROUP_UPDATE,        self.OnGroupUpdate)
	EVENT_MANAGER:RegisterForEvent(self.Name, EVENT_GROUP_MEMBER_CONNECTED_STATUS , self.OnGroupUpdate)

end

function Ultibomb.UnregisterUltiListeners()

	local self = Ultibomb

	UltibombGUI:SetHidden(true)

	ultimateHandler:UnregisterForUltimateChanges(self.OnUltimateReceived)
	EVENT_MANAGER:UnregisterForEvent(self.Name, EVENT_GROUP_MEMBER_JOINED)
	EVENT_MANAGER:UnregisterForEvent(self.Name, EVENT_GROUP_MEMBER_LEFT)
	EVENT_MANAGER:UnregisterForEvent(self.Name, EVENT_GROUP_UPDATE)
	EVENT_MANAGER:UnregisterForEvent(self.Name, EVENT_GROUP_MEMBER_CONNECTED_STATUS)

	Ultibomb.setLGSMode(false)

end



-- --------------------
-- Attach Listeners
-- --------------------
EVENT_MANAGER:RegisterForEvent(Ultibomb.name, EVENT_ADD_ON_LOADED, Ultibomb.OnAddOnLoaded)

-- --------------------
-- Setup Commands
-- --------------------

SLASH_COMMANDS['/ub'] = function(arg)
	
	if arg == 'on' or arg == 'enable' then

		if Ultibomb.isLoaded then

			if Ultibomb._commandState == 'off' then
				d('Ultibomb is now on')
				ultimateHandler:SetStatusType('user')
				Ultibomb.RegisterUltiListeners()
				Ultibomb._commandState = 'on'
				UltibombGUI:SetHidden(false)
			else
				d('Ultibomb is already running you prat')
			end

		end

	elseif arg == 'off' or arg == 'disable' then

		if Ultibomb._commandState == 'on' or Ultibomb._commandState == 'watch' then
			d('Ultibomb is now off')
			Ultibomb.UnregisterUltiListeners()
		    EVENT_MANAGER:UnregisterForEvent(Ultibomb.name, EVENT_ACTION_LAYER_POPPED)
		    EVENT_MANAGER:UnregisterForEvent(Ultibomb.name, EVENT_ACTION_LAYER_PUSHED)
			Ultibomb.ResetCollections()
			Ultibomb._commandState = 'off'
			UltibombGUI:SetHidden(true)
		else
			d('Ultibomb isn\'t running you pleb')
		end

	elseif arg == 'help' or arg == 'list' then

		d('Ultibomb commands')
		d('------------------')
		d('/ub on, off, enable, disable, read, refresh, r, help, list')

	elseif arg == 'watch' then

		if Ultibomb._commandState == 'on' then
			d('You need to turn off first, use /ub off')
		else
			d('Ultibomb is now read-only mode, your data will not be sent')
			Ultibomb.UnregisterUltiListeners()
			ultimateHandler:SetStatusType('reader')
			Ultibomb.RegisterUltiListeners()
			Ultibomb._commandState = 'watch'
		end

	-- elseif arg == 'vert' then

	-- 	if Ultibomb._commandState == 'on' or Ultibomb._commandState == 'watch' then		
	-- 		makeVertical()
	-- 	else
	-- 		d('Ultibomb isn\'t running you pleb')
	-- 	end

	-- elseif arg == 'horz' then

	-- 	if Ultibomb._commandState == 'on' or Ultibomb._commandState == 'watch' then
	-- 		makeHorz()
	-- 	else
	-- 		d('Ultibomb isn\'t running you pleb')
	-- 	end

	elseif arg == 'refresh' or arg == 'r' then

		d('Refreshing Ultibomb data')
		Ultibomb.ResetCollections()
		Ultibomb.UnregisterUltiListeners()
		Ultibomb.RegisterUltiListeners()

	else

		d('Ultibomb does not understand this nonsense, seek a priest')

	end
end

function makeVertical()
	local i = 0

	for record in pairs(Ultibomb.manifest) do

		local key = Ultibomb.manifest[record].key

		if i == 0 then
			Ultibomb.GUI[key]:RenderVertical(true)
			i = 1
		else
			Ultibomb.GUI[key]:RenderVertical(false)
		end
	end
end

function makeHorz()
	local i = 0

	for record in pairs(Ultibomb.manifest) do

		local key = Ultibomb.manifest[record].key

		if i == 0 then
			Ultibomb.GUI[key]:RenderHorz(true)
			i = 1
		else
			Ultibomb.GUI[key]:RenderHorz(false)
		end
	end
end
