local LAM2 = LibStub:GetLibrary("LibAddonMenu-2.0")
-----------------
---- Globals ----
-----------------
AsylumOlorime = {}
AsylumOlorime.name = "AsylumOlorime"
AsylumOlorime.version = "1.1.2"

AsylumOlorime.groupMembers = {}
timeLeft = {0,0,0,0,0,0,0,0}
---------------------------
---- Variables Default ----
---------------------------
AsylumOlorime.Default = {
	OffsetX = 510,
    OffsetY = 240,
	ColorRGB = {0, 1, 0, 1},
	DPS = {	[1] = "@Floliroy",
			[2] = "@everyone",
			[3] = "@everyone",
			[4] = "@everyone",
			[5] = "@everyone",
			[6] = "@everyone",
			[7] = "@everyone",
			[8] = "@everyone",
	},
}

-------------------------
---- Settings Window ----
-------------------------
function AsylumOlorime.CreateSettingsWindow()
	local panelData = {
		type = "panel",
		name = "AsylumOlorime",
		displayName = "Asylum Olorime",
		author = "Floliroy",
		version = AsylumOlorime.version,
		slashCommand = "/asolo",
		--registerForRefresh = true,
		registerForDefaults = true,
	}
	
	local cntrlOptionsPanel = LAM2:RegisterAddonPanel("AsylumOlorime_Settings", panelData)
	
	local optionsData = {
		[1] = {
			type = "header",
			name = "Asylum Olorime Settings",
		},
		[2] = {
			type = "description",
			text = "Just set the @name of your 8 DDs.\n\rPosition 1 is entrance, position 8 is exit.",
		},
		[3] = {
			type = "button",
			name = "Check Members",
			tooltip = "Check all the members of your group",
			func = function()
				AsylumOlorime.CheckMembers()
			end,
			width = "half",
		},
		[4] = {
			type = "button",
			name = "Debug Positions",
			tooltip = "If the dropdowns are empty click here to check actual position of each DDs.",
			func = function()
				d("|c00FF00Asylum Olorime|r\r\nPos1:" .. AsylumOlorime.DPS[1] .." |c00FF00//|r Pos2:".. AsylumOlorime.DPS[2] .." |c00FF00//|r Pos3:".. AsylumOlorime.DPS[3] .." |c00FF00//|r|r Pos4:".. AsylumOlorime.DPS[4] .." |c00FF00//|r Pos5:".. AsylumOlorime.DPS[5] .." |c00FF00//|r Pos6:".. AsylumOlorime.DPS[6] .." |c00FF00//|r Pos7:".. AsylumOlorime.DPS[7] .." |c00FF00//|r Pos8:".. AsylumOlorime.DPS[8])
			end,
			width = "half",
		},
		[5] = {
			type = "submenu",
			name = "Set DDs Positions",
			tooltip = "Here choose the @name of each of your DDs in the correct position.",
			controls = {
				[1] = {
					type = "dropdown",
					name = "DD Position 1",
					tooltip = "The @name of the DD in position 1.",
					choices = AsylumOlorime.groupMembers,
					default = AsylumOlorime.groupMembers[1],
					getFunc = function() return AsylumOlorime.savedVariables.DPS[1] end,
					setFunc = function(selected)
						for index, name in ipairs(AsylumOlorime.groupMembers) do
							if name == selected then
								AsylumOlorime.savedVariables.DPS[1] = selected
								AsylumOlorime.DPS[1] = selected
								break
							end
						end
					end,
					reference = "DD1_dropdown",
				},
				[2] = {
					type = "dropdown",
					name = "DD Position 2",
					tooltip = "The @name of the DD in position 2.",
					choices = AsylumOlorime.groupMembers,
					default = AsylumOlorime.groupMembers[2],
					getFunc = function() return AsylumOlorime.savedVariables.DPS[2] end,
					setFunc = function(selected)
						for index, name in ipairs(AsylumOlorime.groupMembers) do
							if name == selected then
								AsylumOlorime.savedVariables.DPS[2] = selected
								AsylumOlorime.DPS[2] = selected
								break
							end
						end
					end,
					reference = "DD2_dropdown",
				},
				[3] = {
					type = "dropdown",
					name = "DD Position 3",
					tooltip = "The @name of the DD in position 3.",
					choices = AsylumOlorime.groupMembers,
					default = AsylumOlorime.groupMembers[1],
					getFunc = function() return AsylumOlorime.savedVariables.DPS[3] end,
					setFunc = function(selected)
						for index, name in ipairs(AsylumOlorime.groupMembers) do
							if name == selected then
								AsylumOlorime.savedVariables.DPS[3] = selected
								AsylumOlorime.DPS[3] = selected
								break
							end
						end
					end,
					reference = "DD3_dropdown",
				},
				[4] = {
					type = "dropdown",
					name = "DD Position 4",
					tooltip = "The @name of the DD in position 4.",
					choices = AsylumOlorime.groupMembers,
					default = AsylumOlorime.groupMembers[4],
					getFunc = function() return AsylumOlorime.savedVariables.DPS[4] end,
					setFunc = function(selected)
						for index, name in ipairs(AsylumOlorime.groupMembers) do
							if name == selected then
								AsylumOlorime.savedVariables.DPS[4] = selected
								AsylumOlorime.DPS[4] = selected
								break
							end
						end
					end,
					reference = "DD4_dropdown",
				},
				[5] = {
					type = "dropdown",
					name = "DD Position 5",
					tooltip = "The @name of the DD in position 5.",
					choices = AsylumOlorime.groupMembers,
					default = AsylumOlorime.groupMembers[5],
					getFunc = function() return AsylumOlorime.savedVariables.DPS[5] end,
					setFunc = function(selected)
						for index, name in ipairs(AsylumOlorime.groupMembers) do
							if name == selected then
								AsylumOlorime.savedVariables.DPS[5] = selected
								AsylumOlorime.DPS[5] = selected
								break
							end
						end
					end,
					reference = "DD5_dropdown",
				},
				[6] = {
					type = "dropdown",
					name = "DD Position 6",
					tooltip = "The @name of the DD in position 6.",
					choices = AsylumOlorime.groupMembers,
					default = AsylumOlorime.groupMembers[6],
					getFunc = function() return AsylumOlorime.savedVariables.DPS[6] end,
					setFunc = function(selected)
						for index, name in ipairs(AsylumOlorime.groupMembers) do
							if name == selected then
								AsylumOlorime.savedVariables.DPS[6] = selected
								AsylumOlorime.DPS[6] = selected
								break
							end
						end
					end,
					reference = "DD6_dropdown",
				},
				[7] = {
					type = "dropdown",
					name = "DD Position 7",
					tooltip = "The @name of the DD in position 7.",
					choices = AsylumOlorime.groupMembers,
					default = AsylumOlorime.groupMembers[7],
					getFunc = function() return AsylumOlorime.savedVariables.DPS[7] end,
					setFunc = function(selected)
						for index, name in ipairs(AsylumOlorime.groupMembers) do
							if name == selected then
								AsylumOlorime.savedVariables.DPS[7] = selected
								AsylumOlorime.DPS[7] = selected
								break
							end
						end
					end,
					reference = "DD7_dropdown",
				},
				[8] = {
					type = "dropdown",
					name = "DD Position 8",
					tooltip = "The @name of the DD in position 8.",
					choices = AsylumOlorime.groupMembers,
					default = AsylumOlorime.groupMembers[1],
					getFunc = function() return AsylumOlorime.savedVariables.DPS[8] end,
					setFunc = function(selected)
						for index, name in ipairs(AsylumOlorime.groupMembers) do
							if name == selected then
								AsylumOlorime.savedVariables.DPS[8] = selected
								AsylumOlorime.DPS[8] = selected
								break
							end
						end
					end,
					reference = "DD8_dropdown",
				},
			},
		},
		[6] = {
			type = "header",
			width = "full",
		},
		[7] = {
			type = "checkbox",
			name = "Unlock",
			tooltip = "Use it to reposition the alert.",
			default = false,
			getFunc = function() return AsylumOlorime.savedVariables.AlwaysShowAlert end,
			setFunc = function(newValue) 
				AsylumOlorime.savedVariables.AlwaysShowAlert = newValue
				AsylumOlorimeAlert:SetHidden(not newValue)  
			end,
		},   
		[8] = {
			type = "colorpicker",
			name = "Alert Color",
			getFunc = function() return unpack(AsylumOlorime.savedVariables.ColorRGB) end,
			setFunc = function(r,g,b,a)
				AsylumOlorime.savedVariables.ColorRGB = {r,g,b,a}
				AsylumOlorimeFight:SetColor(unpack(AsylumOlorime.savedVariables.ColorRGB))
			end,
		},
	}
	
	LAM2:RegisterOptionControls("AsylumOlorime_Settings", optionsData)
end

function AsylumOlorime.CheckMembers()
	for i = 1, 24 do
		AsylumOlorime.groupMembers[i] = ""
	end
	if GetGroupSize() == 0 then
		AsylumOlorime.groupMembers[1] = GetUnitDisplayName("player")
    else
		  for i = 1, GetGroupSize() do 
			AsylumOlorime.groupMembers[i] = GetUnitDisplayName("group" .. i)  
          end
	end
	if DD1_dropdown ~= nil then
		DD1_dropdown:UpdateChoices()
	end
	if DD2_dropdown ~= nil then
		DD2_dropdown:UpdateChoices()
	end
	if DD3_dropdown ~= nil then
		DD3_dropdown:UpdateChoices()
	end
	if DD4_dropdown ~= nil then
		DD4_dropdown:UpdateChoices()
	end
	if DD5_dropdown ~= nil then
		DD5_dropdown:UpdateChoices()
	end
	if DD6_dropdown ~= nil then
		DD6_dropdown:UpdateChoices()
	end
	if DD7_dropdown ~= nil then
		DD7_dropdown:UpdateChoices()
	end
	if DD8_dropdown ~= nil then
		DD8_dropdown:UpdateChoices()
	end
end

----------------
---- UPDATE ----
----------------

function AsylumOlorime.Update()
	local positionAlert = "Set Alert Position"
	if ((IsUnitInCombat("player")) and (GetZoneId(GetUnitZoneIndex("player")) == 1000)) then -- ((IsUnitInCombat("player")) and (GetZoneId(GetUnitZoneIndex("player")) == 1000)) then
		local currentTimeStamp = GetGameTimeMilliseconds() / 1000

		local left = 0;
		local right = 0;

		for playerID = 1, GetGroupSize() do
			for numDD = 1, 8 do 
				if (GetUnitDisplayName(GetGroupUnitTagByIndex(playerID)) == AsylumOlorime.DPS[numDD]) then
					for i = 1,GetNumBuffs(GetGroupUnitTagByIndex(playerID)) do
						local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer = GetUnitBuffInfo(GetGroupUnitTagByIndex(playerID),i)
						if ((abilityId == 109994) or (abilityId == 110020)) then

							timeLeft[numDD] = timeEnding - currentTimeStamp

						end
					end
				end
			end
		end

		right 	= timeLeft[1]*1.3 + timeLeft[2]*1.2 + timeLeft[3]*1.1 + timeLeft[4]
		left	= timeLeft[8]*1.3 + timeLeft[7]*1.2 + timeLeft[6]*1.1 + timeLeft[5]

		if right > left then
			AsylumOlorimeAlert:SetHidden(false)
			positionAlert = "Left"
		elseif right < left then
			AsylumOlorimeAlert:SetHidden(false)
			positionAlert = "Right"
		elseif right == left then 
			AsylumOlorimeAlert:SetHidden(false)
			positionAlert = "Middle"
		end		
	else 		
		AsylumOlorimeAlert:SetHidden(not AsylumOlorime.savedVariables.AlwaysShowAlert)
		positionAlert = "Set Alert Position"
	end
	AsylumOlorimeFight:SetText(string.format("%s", positionAlert))
end

function AsylumOlorime.Reset(event, inCombat)
	if inCombat ~= AsylumOlorime.inCombat then
		AsylumOlorime.inCombat = inCombat
		
		timeLeft = {0,0,0,0,0,0,0,0}
	end
end

----------
-- MAIN --
----------
function AsylumOlorime:Initialize()
	--Settings
	AsylumOlorime.CheckMembers()
	AsylumOlorime.CreateSettingsWindow()
	
	--Saved Variables
	AsylumOlorime.savedVariables = ZO_SavedVars:New("AsylumOlorimeVariables", 1, nil, AsylumOlorime.Default)
	EVENT_MANAGER:UnregisterForEvent(AsylumOlorime.name, EVENT_ADD_ON_LOADED)
	
	--UI
	AsylumOlorimeAlert:SetHidden(true)
	AsylumOlorimeAlert:ClearAnchors()
	AsylumOlorimeAlert:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, AsylumOlorime.savedVariables.OffsetX, AsylumOlorime.savedVariables.OffsetY)
	
	AsylumOlorimeFight:SetColor(unpack(AsylumOlorime.savedVariables.ColorRGB))
	AsylumOlorime.AlwaysShowAlert = AsylumOlorime.savedVariables.AlwaysShowAlert
	EVENT_MANAGER:UnregisterForEvent(AsylumOlorime.name, EVENT_ADD_ON_LOADED)
	
	--Update
	AsylumOlorime.DPS = AsylumOlorime.savedVariables.DPS

	EVENT_MANAGER:RegisterForEvent(AsylumOlorime.name, EVENT_PLAYER_COMBAT_STATE, AsylumOlorime.Reset)
	EVENT_MANAGER:RegisterForUpdate(AsylumOlorime.name, 250, AsylumOlorime.Update)
	EVENT_MANAGER:UnregisterForEvent(AsylumOlorime.name, EVENT_ADD_ON_LOADED)
	
end

function AsylumOlorime.SaveLoc()
	AsylumOlorime.savedVariables.OffsetX = AsylumOlorimeAlert:GetLeft()
	AsylumOlorime.savedVariables.OffsetY = AsylumOlorimeAlert:GetTop()
end	
 
function AsylumOlorime.OnAddOnLoaded(event, addonName)
	if addonName ~= AsylumOlorime.name then return end
		AsylumOlorime:Initialize()
end

EVENT_MANAGER:RegisterForEvent(AsylumOlorime.name, EVENT_ADD_ON_LOADED, AsylumOlorime.OnAddOnLoaded)