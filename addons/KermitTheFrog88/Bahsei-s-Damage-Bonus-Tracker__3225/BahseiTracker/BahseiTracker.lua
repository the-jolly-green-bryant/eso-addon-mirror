local LAM2 = LibAddonMenu2
local hudtrackerpostinit = false
BahseiTracker = {}
BahseiTracker.name = "BahseiTracker" 
BahseiTracker.variableVersion = 7
BahseiTracker.version = "0.21"
BahseiTracker.savedVariables = 0
BahseiTracker.Default = {
	  OffsetX = 20,
	  OffsetY = 75,
	  AlertOffsetX = 0,
	  AlertOffsetY = 0,
	  Show = false,
	  OnlyShowInCombat = false,
	  GlobalShow = true,
	  BonusBarColor = {0,0,1,1},
	  PercentBarColor1 = {1,0,0,1},
	  PercentBarColor2 = {0,1,0,1},
	  Width = 200,
	  Height = 75,
	  MagickaDump = false,
	  MagickaDumpThreshold = 50,
 }

function BahseiTracker.OnAddOnLoaded(event, addonName)
	if addonName ~= BahseiTracker.name then return end
	
	BahseiTracker:Initialize()
end

function BahseiTracker:Initialize()

BahseiTracker.CreateSettingsWindow()
BahseiTracker.savedVariables = ZO_SavedVars:NewAccountWide("BahseiTrackerVars", BahseiTracker.variableVersion, nil, BahseiTracker.Default, GetWorldName())
BahseiTracker1:ClearAnchors()
BahseiTracker1:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, BahseiTracker.savedVariables.OffsetX, BahseiTracker.savedVariables.OffsetY)
BahseiTracker1:SetDimensions( BahseiTracker.savedVariables.Width, BahseiTracker.savedVariables.Height)
BahseiTracker1BonusBar:SetDimensions( BahseiTracker.savedVariables.Width, (BahseiTracker.savedVariables.Height / 2 ) )
BahseiTracker1PercentBar:SetDimensions( BahseiTracker.savedVariables.Width, (BahseiTracker.savedVariables.Height / 2 ) )

BahseiTracker.fragment = ZO_SimpleSceneFragment:New(BahseiTracker1)

	if BahseiTracker.savedVariables.GlobalShow then
		if BahseiTracker.savedVariables.Show then
			local found = 0
			for i = 0, 20 do
				local itemName = GetItemName(BAG_WORN, i)
					if string.find(itemName, "Bahsei's") then
						found = found + 1
					end
			end
			if found >= 5 then 
					if BahseiTracker.savedVariables.OnlyShowInCombat then
						if BahseiTracker.inCombat then
						BahseiTracker1:SetHidden(false) 
						HUD_SCENE:AddFragment(BahseiTracker.fragment)
						HUD_UI_SCENE:AddFragment(BahseiTracker.fragment)
						else
						BahseiTracker1:SetHidden(true)
						HUD_SCENE:RemoveFragment(BahseiTracker.fragment)
						HUD_UI_SCENE:RemoveFragment(BahseiTracker.fragment)
						end
					else
						BahseiTracker1:SetHidden(false) 
						HUD_SCENE:AddFragment(BahseiTracker.fragment)
						HUD_UI_SCENE:AddFragment(BahseiTracker.fragment)
					end
			else 
				BahseiTracker1:SetHidden(true)
				HUD_SCENE:RemoveFragment(BahseiTracker.fragment)
				HUD_UI_SCENE:RemoveFragment(BahseiTracker.fragment)
				BahseiTrackerDumpAlert:SetHidden(true)
				HUD_SCENE:RemoveFragment(BahseiTracker.BahseiTrackerDumpAlertFragment)
				HUD_UI_SCENE:RemoveFragment(BahseiTracker.BahseiTrackerDumpAlertFragment)
			end
		else
				if BahseiTracker.savedVariables.OnlyShowInCombat then
					if BahseiTracker.inCombat then
					BahseiTracker1:SetHidden(false) 
					HUD_SCENE:AddFragment(BahseiTracker.fragment)
					HUD_UI_SCENE:AddFragment(BahseiTracker.fragment)
					else
					BahseiTracker1:SetHidden(true)
					HUD_SCENE:RemoveFragment(BahseiTracker.fragment)
					HUD_UI_SCENE:RemoveFragment(BahseiTracker.fragment)
					end
				else
					BahseiTracker1:SetHidden(false)
					HUD_SCENE:AddFragment(BahseiTracker.fragment)
					HUD_UI_SCENE:AddFragment(BahseiTracker.fragment)
				end
		end
	else
		BahseiTracker1:SetHidden(true)
		HUD_SCENE:RemoveFragment(BahseiTracker.fragment)
		HUD_UI_SCENE:RemoveFragment(BahseiTracker.fragment)
	end


BahseiTracker.BahseiTrackerDumpAlertFragment = ZO_SimpleSceneFragment:New(BahseiTrackerDumpAlert)

BahseiTrackerDumpAlert:ClearAnchors()
if BahseiTracker.savedVariables.AlertOffsetX == 0 and BahseiTracker.savedVariables.AlertOffsetY == 0 then
	BahseiTrackerDumpAlert:SetAnchor(CENTER, GuiRoot, CENTER, BahseiTracker.savedVariables.AlertOffsetX, 40)	
else
	BahseiTrackerDumpAlert:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, BahseiTracker.savedVariables.AlertOffsetX, BahseiTracker.savedVariables.AlertOffsetY)	
end

BahseiTrackerDumpAlert:SetHidden(true)
BahseiTrackerDumpAlertBG:SetHidden(true)
HUD_SCENE:RemoveFragment(BahseiTracker.BahseiTrackerDumpAlertFragment)
HUD_UI_SCENE:RemoveFragment(BahseiTracker.BahseiTrackerDumpAlertFragment)

BahseiTracker1BonusBar:SetColor(unpack(BahseiTracker.savedVariables.BonusBarColor))
BahseiTracker1PercentBar:SetColor(unpack(BahseiTracker.savedVariables.PercentBarColor1))

BahseiTracker.inCombat = IsUnitInCombat("player")
EVENT_MANAGER:RegisterForEvent(BahseiTracker.name, EVENT_PLAYER_COMBAT_STATE, BahseiTracker.OnPlayerCombatState)


EVENT_MANAGER:UnregisterForEvent(BahseiTracker.name, EVENT_ADD_ON_LOADED)

end


function BahseiTracker.OnPlayerCombatState(event, inCombat)

	if inCombat ~= BahseiTracker.inCombat then
		BahseiTracker.inCombat = inCombat
	end

end

function BahseiTracker.CheckDisplayUpdate()

	if BahseiTracker.savedVariables.GlobalShow then
		if BahseiTracker.savedVariables.Show then
			local found = 0
			for i = 0, 20 do
				local itemName = GetItemName(BAG_WORN, i)
					if string.find(itemName, "Bahsei's") then
						found = found + 1
					end
			end
			if found >= 5 then 
				if (SCENE_MANAGER:GetCurrentSceneName() == "hud" or SCENE_MANAGER:GetCurrentSceneName() == "hudui")  then
					if BahseiTracker.savedVariables.OnlyShowInCombat then
						if BahseiTracker.inCombat then
						BahseiTracker1:SetHidden(false) 
						HUD_SCENE:AddFragment(BahseiTracker.fragment)
						HUD_UI_SCENE:AddFragment(BahseiTracker.fragment)
						else
						BahseiTracker1:SetHidden(true)
						HUD_SCENE:RemoveFragment(BahseiTracker.fragment)
						HUD_UI_SCENE:RemoveFragment(BahseiTracker.fragment)
						end
					else
						BahseiTracker1:SetHidden(false) 
						HUD_SCENE:AddFragment(BahseiTracker.fragment)
						HUD_UI_SCENE:AddFragment(BahseiTracker.fragment)
					end
				end
			else 
				BahseiTracker1:SetHidden(true)
				HUD_SCENE:RemoveFragment(BahseiTracker.fragment)
				HUD_UI_SCENE:RemoveFragment(BahseiTracker.fragment)
				BahseiTrackerDumpAlert:SetHidden(true)
				HUD_SCENE:RemoveFragment(BahseiTracker.BahseiTrackerDumpAlertFragment)
				HUD_UI_SCENE:RemoveFragment(BahseiTracker.BahseiTrackerDumpAlertFragment)
			end
		else
			if (SCENE_MANAGER:GetCurrentSceneName() == "hud" or SCENE_MANAGER:GetCurrentSceneName() == "hudui")  then
				if BahseiTracker.savedVariables.OnlyShowInCombat then
					if BahseiTracker.inCombat then
					BahseiTracker1:SetHidden(false) 
					HUD_SCENE:AddFragment(BahseiTracker.fragment)
					HUD_UI_SCENE:AddFragment(BahseiTracker.fragment)
					else
					BahseiTracker1:SetHidden(true)
					HUD_SCENE:RemoveFragment(BahseiTracker.fragment)
					HUD_UI_SCENE:RemoveFragment(BahseiTracker.fragment)
					end
				else
					BahseiTracker1:SetHidden(false) 
					HUD_SCENE:AddFragment(BahseiTracker.fragment)
					HUD_UI_SCENE:AddFragment(BahseiTracker.fragment)
				end
			end
		end
	else
		BahseiTracker1:SetHidden(true)
		HUD_SCENE:RemoveFragment(BahseiTracker.fragment)
		HUD_UI_SCENE:RemoveFragment(BahseiTracker.fragment)
	end

	if BahseiTracker.savedVariables.GlobalShow then
		if BahseiTracker.savedVariables.Show then
			local found = 0
			for i = 0, 20 do
				local itemName = GetItemName(BAG_WORN, i)
					if string.find(itemName, "Bahsei's") then
						found = found + 1
					end
			end
			if found >= 5 then
				if BahseiTracker.inCombat ~= true and BahseiTracker.savedVariables.MagickaDump then
					BahseiTracker.MagickaDumpAlert()
				else
					BahseiTrackerDumpAlert:SetHidden(true)
					HUD_SCENE:RemoveFragment(BahseiTracker.BahseiTrackerDumpAlertFragment)
					HUD_UI_SCENE:RemoveFragment(BahseiTracker.BahseiTrackerDumpAlertFragment)
				end
			else
				BahseiTrackerDumpAlert:SetHidden(true)
				HUD_SCENE:RemoveFragment(BahseiTracker.BahseiTrackerDumpAlertFragment)
				HUD_UI_SCENE:RemoveFragment(BahseiTracker.BahseiTrackerDumpAlertFragment)
			end
		else
			if BahseiTracker.inCombat ~= true and BahseiTracker.savedVariables.MagickaDump then
				BahseiTracker.MagickaDumpAlert()
			else
				BahseiTrackerDumpAlert:SetHidden(true)
				HUD_SCENE:RemoveFragment(BahseiTracker.BahseiTrackerDumpAlertFragment)
				HUD_UI_SCENE:RemoveFragment(BahseiTracker.BahseiTrackerDumpAlertFragment)
			end
		end
	end
		
end


EVENT_MANAGER:RegisterForEvent(BahseiTracker.name, EVENT_ADD_ON_LOADED, BahseiTracker.OnAddOnLoaded)

function BahseiTracker.CreateSettingsWindow()
	local panelData = {
		type = "panel",
		name = "Bahsei's Damage Bonus Tracker",
		displayName = "Bahsei's Damage Bonus Tracker",
		author = "KermitTheFrog88",
		version = BahseiTracker.version,
		slashCommand = "/bdbt",
		registerForRefresh = true,
		registerForDefaults = true,
		website = "https://www.esoui.com/downloads/info3225-BahseisDamageBonusTracker.html",  --update url
		feedback = "https://www.esoui.com/downloads/info3225-BahseisDamageBonusTracker.html#comments", --update url
		donation = "https://www.esoui.com/downloads/info3225-BahseisDamageBonusTracker.html",  --Add in game mail function
	}
	
	local cntrlOptionsPanel = LAM2:RegisterAddonPanel("Bahsei_Tracker", panelData)
	
	local optionsData={
		[1] = {
			type = "header",
			name = "Settings",
		},
		[2] = {
			type = "description",
			text = "Settings to control the damage bonus bars",
		},
		[3] = {
			type = "checkbox",
			name = "Show data bars.",
			tooltip = "Turn bars on or off. Note: Disabling this overrides all other settings.",
			default = false,
			getFunc = function() return BahseiTracker.savedVariables.GlobalShow end,
			setFunc = function(newValue)
				BahseiTracker.savedVariables.GlobalShow = newValue
				if newValue then
					HUD_SCENE:RemoveFragment(BahseiTracker.fragment)
					HUD_UI_SCENE:RemoveFragment(BahseiTracker.fragment)
				else
				BahseiTracker.savedVariables.GlobalShow = false
					HUD_SCENE:AddFragment(BahseiTracker.fragment)
					HUD_UI_SCENE:AddFragment(BahseiTracker.fragment)
				end 
			end,
		},
		[4] = {
			type = "checkbox",
			name = "Only show bars if Bahsei's set equipped.",
			tooltip = "When ON bars will only be visible if your wearing the set.  When OFF the bars will always be visible.",
			default = false,
			getFunc = function() return BahseiTracker.savedVariables.Show end,
			setFunc = function(newValue)
				BahseiTracker.savedVariables.Show = newValue
				BahseiTracker.CheckDisplayUpdate()
				end,
		},
		[5] = {
		type = "submenu",
		name = "Bonus Damage Bar Color",
		tooltip = "Allows you to change the bonus damage bar color.",
		controls = {
			[1] = {
				type = "colorpicker",
				name = "Bar Color",
				tooltip = "Changes the color of the bar background.",
				getFunc = function() return unpack( BahseiTracker.savedVariables.BonusBarColor ) end,
				setFunc = function(r,g,b,a) 
					local alpha = BahseiTracker1BonusBar:GetAlpha()
					BahseiTracker.savedVariables.BonusBarColor = { r, g, b, a}
					BahseiTracker1BonusBar:SetColor( r,  g,  b,  a)  
					end,
				},
		}
		},
		[6] = {
		type = "submenu",
		name = "Magicka Percent Bar Color >50%",
		tooltip = "Allows you to change the magicka percent primary bar color.",
		controls = {
			[1] = {
				type = "colorpicker",
				name = "Primary Bar Color",
				tooltip = "Changes the color of the bar background.",
				getFunc = function() return unpack( BahseiTracker.savedVariables.PercentBarColor1 ) end,
				setFunc = function(r,g,b,a) 
					local alpha = BahseiTracker1PercentBar:GetAlpha()
					BahseiTracker.savedVariables.PercentBarColor1 = { r, g, b, a}
					BahseiTracker1PercentBar:SetColor( r,  g,  b,  a)  
					end,
				},
		}
		},
		[7] = {
		type = "submenu",
		name = "Magicka Percent Bar Color <50%",
		tooltip = "Allows you to change the magicka percent secondary bar color.",
		controls = {
			[1] = {
				type = "colorpicker",
				name = "Secondary Bar Color",
				tooltip = "Changes the color of the bar background.",
				getFunc = function() return unpack( BahseiTracker.savedVariables.PercentBarColor2 ) end,
				setFunc = function(r,g,b,a) 
					local alpha = BahseiTracker1PercentBar:GetAlpha()
					BahseiTracker.savedVariables.PercentBarColor2 = { r, g, b, a}
					end,
				},
		}
		},
		[8] = {
			type = "checkbox",
			name = "Only display in combat.",
			tooltip = "When ON bars will only be visible when you are in combat.",
			default = false,
			getFunc = function() return BahseiTracker.savedVariables.OnlyShowInCombat end,
			setFunc = function(newValue)
				BahseiTracker.savedVariables.OnlyShowInCombat = newValue
				end,
		},
		[9] = {
			type = "checkbox",
			name = "Display magicka dump alert when out of combat.",
			tooltip = "Based on magicka % threshold will display an alert reminder to dump magicka when out of combat and above the value set below.",
			default = false,
			getFunc = function() return BahseiTracker.savedVariables.MagickaDump end,
			setFunc = function(newValue)
				BahseiTracker.savedVariables.MagickaDump = newValue
				end,
		},
		[10] = {
		type = "submenu",
		name = "Magicka Dump Alert Percent Threshold",
		tooltip = "Sets the % threshold for displaying the out of combat magicka dump alert.",
		controls = {
			[1] = {
				type = "slider",
				name = "Magicka dump %",
				tooltip = "Alert threshold",
				getFunc = function() return BahseiTracker.savedVariables.MagickaDumpThreshold end,
				setFunc = function(newValue)
					BahseiTracker.savedVariables.MagickaDumpThreshold = newValue
					end,
				min = 0,
				max = 100,
				step = 1,
				decimals = 2,
				width = "half",
				},
			},
		},
	}
	
	LAM2:RegisterOptionControls("Bahsei_Tracker", optionsData)
	
end

function BahseiTracker.SaveLoc()
	BahseiTracker.savedVariables.OffsetX = BahseiTracker1:GetLeft()
	BahseiTracker.savedVariables.OffsetY = BahseiTracker1:GetTop()
end

function BahseiTracker.SaveAlertLoc()
	BahseiTracker.savedVariables.AlertOffsetX = BahseiTrackerDumpAlert:GetLeft()
	BahseiTracker.savedVariables.AlertOffsetY = BahseiTrackerDumpAlert:GetTop()
end
 
function BahseiTracker.Update()
	local bonus = 0
	local current, max, effectiveMax = GetUnitPower("player", POWERTYPE_MAGICKA)
	local percent = (current / effectiveMax) * 100
		
	--Calculate our set damage bonus value.  
	--Ideally we would just grab this from the player info in game but I cant find any way to get current set bonus values from the API.
	if percent < 100  then
		bonus = (100 - percent) * 0.12
	else
	
		bonus = 0
	end
	
	--Visual indicator that your heading in the right direction, turn the % bar green below 50% magicka.  
	--Most players I've talked to try to keep their magicka below 50% as a rule of thumb with Bahsei.  
	--That said 50% is somewhat arbitrary and by no means optimal but its seems to be a good starting point.  
	if percent <= 50 then
		--BahseiTracker1PercentBar:SetColor(unpack( BahseiTracker.savedVariables.PercentBarColor2 ))
		BahseiTracker1PercentBar:SetColor(0,1,0,1)
	elseif BahseiTracker.savedVariables ~= 0 then
		--BahseiTracker1PercentBar:SetColor(unpack( BahseiTracker.savedVariables.PercentBarColor1 ))
		BahseiTracker1PercentBar:SetColor(1,0,0,1)
	else
		BahseiTracker1PercentBar:SetColor(1,0,0,1)
	end
	
	BahseiTracker1PercentBar:SetMinMax(0, effectiveMax)
	BahseiTracker1PercentBar:SetValue(current)
	BahseiTracker1BonusBar:SetValue(bonus)
	
	BahseiTracker1Percent:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	BahseiTracker1Bonus:SetText(string.format("Damage Bonus %d%% ", bonus))
	BahseiTracker1Percent:SetText(string.format("Magicka %d%% ", percent))

	
end

function BahseiTracker.ResizeStart()

	local width, height = BahseiTracker1:GetDimensions()
	if width >= 145 then width = width else width = 145 end
	if height >= 50 then height = height else height = 50 end
	BahseiTracker1:SetDimensions(width, height)
	BahseiTracker1BonusBar:SetDimensions( width, (height / 2) )
	BahseiTracker1PercentBar:SetDimensions( width, (height / 2) )

end

function BahseiTracker.ResizeStop()

	local width, height = BahseiTracker1:GetDimensions()
	if width >= 145 then width = width else width = 145 end
	if height >= 50 then height = height else height = 50 end
	BahseiTracker1:SetDimensions(width, height)
	BahseiTracker1BonusBar:SetDimensions( width, (height / 2) )
	BahseiTracker1PercentBar:SetDimensions( width, (height / 2) )
	BahseiTracker.savedVariables.Width = width
	BahseiTracker.savedVariables.Height = height

end

function BahseiTracker.MagickaDumpAlert()

	local AlertCurrent, AlertMax, AlertEffectiveMax = GetUnitPower("player", POWERTYPE_MAGICKA)
	local AlertPercent = (AlertCurrent / AlertEffectiveMax) * 100
	

	if (SCENE_MANAGER:GetCurrentSceneName() == "hud" or SCENE_MANAGER:GetCurrentSceneName() == "hudui")  then
		if BahseiTracker.savedVariables.MagickaDumpThreshold <= AlertPercent then
			BahseiTrackerDumpAlert:SetHidden(false)
			HUD_SCENE:AddFragment(BahseiTracker.BahseiTrackerDumpAlertFragment)
			HUD_UI_SCENE:AddFragment(BahseiTracker.BahseiTrackerDumpAlertFragment)
		else
			BahseiTrackerDumpAlert:SetHidden(true)
			HUD_SCENE:RemoveFragment(BahseiTracker.BahseiTrackerDumpAlertFragment)
			HUD_UI_SCENE:RemoveFragment(BahseiTracker.BahseiTrackerDumpAlertFragment)
		end
	end


end
 
 function BahseiTracker.ShowAlertBG()
	BahseiTrackerDumpAlertBG:SetHidden(false)
end

function BahseiTracker.HideAlertBG()
	BahseiTrackerDumpAlertBG:SetHidden(true)
end


function BahseiTrackerReset()
		for i = 0, 20 do
		local itemName = GetItemName(BAG_WORN, i)
		CHAT_SYSTEM:AddMessage(itemName)
		end
end

--Checks for display updates due to combat status and/or equiping/unequping Bahsei's gear.
EVENT_MANAGER:RegisterForUpdate("BahseiTrackerCheckDisplayUpdate", 500, BahseiTracker.CheckDisplayUpdate) --500 milliseconds = .5 seconds