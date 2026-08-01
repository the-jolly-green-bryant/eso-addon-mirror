RaidBuffs = RaidBuffs or {}
local RaidBuffs = RaidBuffs

function RaidBuffs.buildMenu(svdefaults)
	local LAM = LibAddonMenu2
	local def = svdefaults
	local trackingPresets = {
		"Full",
		"Dps",
		"Tank",
		"Healer",
		"Custom"
	}
	
	local panelData = {
		type = "panel",
		name = RaidBuffs.name,
		displayName = RaidBuffs.name,
		author = "Wheels",
		version = ""..RaidBuffs.version,
		registerForRefresh = true
	}

	LAM:RegisterAddonPanel(RaidBuffs.name.."Options", panelData)

	local options = {
		{
			type = "header",
			name = "Positioning"
		},
		{
			type = "checkbox",
			name = "UI Locked",
			tooltip = "Allows for positioning of UI",
			warning = "Reloading is recommended to save position!",
			getFunc = function() return true end,
			setFunc = function(value)
				if not value then
					EVENT_MANAGER:UnregisterForEvent(RaidBuffs.name, EVENT_RETICLE_HIDDEN_UPDATE)
					RaidBuffs.frames[1]:SetHidden(false)
					RaidBuffs.frames[1]:SetMovable(true)
					RaidBuffs.frames[1]:SetMouseEnabled(true)
				else
					EVENT_MANAGER:RegisterForEvent(RaidBuffs.name, EVENT_RETICLE_HIDDEN_UPDATE, RaidBuffs.reticleChange)
					RaidBuffs.frames[1]:SetHidden(true)
					RaidBuffs.frames[1]:SetMovable(false)
					RaidBuffs.frames[1]:SetMouseEnabled(false)
				end
			end,
					
		},
		{
			type = "header",
			name = "General Options"
		},
		{
			type = "slider",
			name = "Frame Size",
			tooltip = "Finally, an option for size!",
			min = 0.5,
			max = 2,
			step = 0.1,
			getFunc = function() return RaidBuffs.savedVariables.scale end,
			setFunc = function(value)
				RaidBuffs.savedVariables.scale = value
				for i = 1, MAX_BOSSES do
					if RaidBuffs.frames[i] ~= nil then
						RaidBuffs.frames[i]:SetScale(RaidBuffs.savedVariables.scale)
					end
				end
			end,
		},
		{
			type = "dropdown",
			name = "Growth Direction",
			tooltip = "Determines which direction additional boss frames are placed in",
			default = def.growthDir,
			choices = RaidBuffs.GROWTH,
			sort = "name-up",
			getFunc = function() return RaidBuffs.savedVariables.growthDir end,
			setFunc = function(value)
				if value == RaidBuffs.savedVariables.growthDir then return end
				for i = 1, #RaidBuffs.GROWTH do
					if value == RaidBuffs.GROWTH[i] then
						RaidBuffs.savedVariables.growthDir = value
					end
				end
			end,
			requiresReload = true
		},
		{
			type = "dropdown",
			name = "Tracking Preset",
			tooltip = "Select debuff tracking preset",
			default = def.trackingName,
			choices = trackingPresets,
			getFunc = function() return RaidBuffs.savedVariables.trackingName end,
			setFunc = function(value)
				if value == RaidBuffs.savedVariables.trackingName then return end
				if value == "Custom" then RaidBuffs.setupCustom(value) else
					RaidBuffs.savedVariables.tracking = { }
					RaidBuffs.savedVariables.tracking = RaidBuffs[value]
					RaidBuffs.debuffsInvert = { }
					for k, v in pairs(RaidBuffs.savedVariables.tracking) do RaidBuffs.debuffsInvert[v] = k end
					RaidBuffs.savedVariables.trackingName = value
					RaidBuffs.savedVariables.numTracked = #RaidBuffs.savedVariables.tracking
					RaidBuffs.savedVariables.currRows = math.ceil(#RaidBuffs.savedVariables.tracking / 2)
					for i = 1, MAX_BOSSES do	-- Appears redundant, easier than making new function for the time being
						if RaidBuffs.frames[i] ~= nil then
							RaidBuffs.frames[i].bossName:SetText('')
							for j = 1, RaidBuffs.MAX_ROWS do
								RaidBuffs.frames[i].rows[j].buffName1:SetText('')
								RaidBuffs.frames[i].rows[j].buffTime1:SetText('')
								RaidBuffs.frames[i].rows[j].buffName2:SetText('')
								RaidBuffs.frames[i].rows[j].buffTime2:SetText('')
							end
						end
					end
					RaidBuffs.BossUpdate()
				end
			end,
		},
		{
			type = "checkbox",
			name = "Track Boss HP",
			tooltip = "Toggles boss frames displaying boss HP",
			default = def.trackHealth,
			getFunc = function() return RaidBuffs.savedVariables.trackHealth end,
			setFunc = function(value)
				RaidBuffs.savedVariables.trackHealth = value
				RaidBuffs.BossUpdate()
			end
		},
		{
			type = "checkbox",
			name = "Cooldown Bars",
			tooltip = "Display colored cooldown bars behind each buff",
			default = def.cooldownBars,
			getFunc = function() return RaidBuffs.savedVariables.cooldownBars end,
			setFunc = function(value)
				RaidBuffs.savedVariables.cooldownBars = value
				if not value then
					for i = 1, MAX_BOSSES do
						if RaidBuffs.frames[i] ~= nil then
							for j = 1, RaidBuffs.MAX_ROWS do
								RaidBuffs.frames[i].rows[j].BG1:SetHidden(true)
								RaidBuffs.frames[i].rows[j].BG1:SetHidden(true)
								RaidBuffs.frames[i].rows[j].BG2:SetHidden(true)
								RaidBuffs.frames[i].rows[j].BG2:SetHidden(true)
							end
						end
					end
				end
			end
		},
		{
			type = "slider",
			name = "Number of Custom Buffs",
			min = 1,
			max = 10,
			step = 1,
			getFunc = function() return RaidBuffs.savedVariables.numCustom end,
			setFunc = function(value)
				RaidBuffs.savedVariables.numCustom = value
				RaidBuffs.savedVariables.numTracked = value
				for i = value + 1, 10 do
					RaidBuffs.savedVariables.Custom[i] = nil
				end
				RaidBuffs.setupCustom("Custom")
				ReloadUI()
			end,
			warning = "Reloads UI!",
		},
	}

	local customControls = { }
	for k,v in pairs(RaidBuffs.debuffsMaster) do
		table.insert(RaidBuffs.names, k)
	end
	for i = 1, RaidBuffs.savedVariables.numCustom do
		local newBuff = {
			{
				type = "dropdown",
				name = "Buff " .. i,
				width = "half",
				scrollable = 10,
				choices = RaidBuffs.names,
				getFunc = function() return RaidBuffs.savedVariables.Custom[i] end,
				setFunc = function(value)
					RaidBuffs.savedVariables.Custom[i] = value
					RaidBuffs.setupCustom("Custom")
				end
			},
		}
		table.insert(customControls, newBuff[1])
	end

	table.insert(options, {
		type = "submenu",
		name = "Custom Buff Setup",
		tooltip = "Define which buffs you would like displayed",
		controls = customControls,
		}
	)

	local addCustomBuffByID = { }
	
	LAM:RegisterOptionControls(RaidBuffs.name.."Options", options)
end

