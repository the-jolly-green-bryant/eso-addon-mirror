-----------------
---- Globals ----
-----------------
ShowBlast = ShowBlast or {}
local ShowBlast = ShowBlast

ShowBlast.name = "ShowBlast"
ShowBlast.version = "1.2"
local LAM2 = LibAddonMenu2

---------------------------
---- Variables Default ----
---------------------------
ShowBlast.Default = {
	OffsetX = 800,
	OffsetY = 300,
	AlwaysShowAlert = false,
}

function ShowBlast.CreateSettingsWindow()
	local panelData = {
		type = "panel",
		name = "ShowBlastbones",
		displayName = "Show|c556b2fBlastbones|r",
		author = "Floliroy",
		version = ShowBlast.version,
		slashCommand = "/showblast",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	
	local cntrlOptionsPanel = LAM2:RegisterAddonPanel("ShowBlast_Settings", panelData)
	
	local optionsData = {
		{	type = "description",
			text = " ",
		},
		{	type = "checkbox",
			name = "Unlock",
			tooltip = "Use it to set the position of the Blastbones icon.",
			default = false,
			getFunc = function() return ShowBlast.savedVariables.AlwaysShowAlert end,
			setFunc = function(newValue) 
				ShowBlast.savedVariables.AlwaysShowAlert = newValue
				ShowBlastUI:SetHidden(not newValue)  
			end,
		},
	}

	LAM2:RegisterOptionControls("ShowBlast_Settings", optionsData)
end

-------------------
---- Functions ----
-------------------

local blastTimer = 0
function ShowBlast.UpdateTimer()
	if blastTimer >= 0 then
		ShowBlastUI_Timer:SetText(tostring(string.format("%.1f", blastTimer/1000)))
		blastTimer = blastTimer - 100
	end
end

local blinkBoolean = true
function ShowBlast.BlinkTimer()
	ShowBlastUI_Timer:SetHidden(blinkBoolean)
	blinkBoolean = not blinkBoolean
end

function ShowBlast.UnregisterCallLater()
	EVENT_MANAGER:UnregisterForUpdate(ShowBlast.name .. "TimerEnded")

	ShowBlastUI_Timer:SetHidden(true)
end

local isActive = true
local activeAbilityID, inactiveAbilityID
function ShowBlast.Run(_, _, _, _, unitTag, _, _, _, _, _, _, _, _, _, _, abilityId, _)	
	--Set here the fact that player can take Grave Robber
	isActive = not isActive
	if isActive then
		ShowBlastUI_Border:SetColor(0, 1, 0)
		ShowBlastUI_Icon:SetTexture(GetAbilityIcon(activeAbilityID))

		EVENT_MANAGER:UnregisterForUpdate(ShowBlast.name .. "TimerActive")

		ShowBlastUI_Timer:SetText("0.0")
		EVENT_MANAGER:RegisterForUpdate(ShowBlast.name .. "TimerEnded", 200, ShowBlast.BlinkTimer)
		EVENT_MANAGER:RegisterForUpdate(ShowBlast.name .. "CallLater", 2600, ShowBlast.UnregisterCallLater)
	else
		ShowBlastUI_Border:SetColor(1, 0, 0)
		ShowBlastUI_Icon:SetTexture(GetAbilityIcon(inactiveAbilityID))
		
		EVENT_MANAGER:UnregisterForUpdate(ShowBlast.name .. "TimerEnded")
		EVENT_MANAGER:UnregisterForUpdate(ShowBlast.name .. "CallLater")

		ShowBlastUI_Timer:SetHidden(false)
		blastTimer = GetAbilityDuration(activeAbilityID)
		EVENT_MANAGER:RegisterForUpdate(ShowBlast.name .. "TimerActive", 100, ShowBlast.UpdateTimer)	
	end
end
 
function ShowBlast:Initialize()	
	ShowBlast.CreateSettingsWindow()

	--Saved Variables
	ShowBlast.savedVariables = ZO_SavedVars:New("ShowBlastVariables", 1, nil, ShowBlast.Default)

	--Detect if magicka or stamina
	_, maxMagicka, _ = GetUnitPower("player", POWERTYPE_MAGICKA)
	_, maxStamina, _ = GetUnitPower("player", POWERTYPE_STAMINA)
	if maxMagicka > maxStamina then
		activeAbilityID = 117750
		inactiveAbilityID = 117773
	else
		activeAbilityID = 117691
		inactiveAbilityID = 117693
	end

	--UI
	ShowBlastUI:ClearAnchors()
	ShowBlastUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ShowBlast.savedVariables.OffsetX, ShowBlast.savedVariables.OffsetY)
	ShowBlastUI_Border:SetColor(0, 1, 0)
	ShowBlastUI_Icon:SetTexture(GetAbilityIcon(activeAbilityID))
	ShowBlastUI_Timer:SetHidden(true)
	
	--Run
	if GetUnitClassId("player") == 5 then
		ShowBlastUI:SetHidden(false)

		EVENT_MANAGER:RegisterForEvent(ShowBlast.name .. "Active", EVENT_EFFECT_CHANGED, ShowBlast.Run)
		EVENT_MANAGER:AddFilterForEvent(ShowBlast.name .. "Active", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, activeAbilityID, REGISTER_FILTER_UNIT_TAG, "player")

		EVENT_MANAGER:RegisterForEvent(ShowBlast.name .. "Reticle", EVENT_RETICLE_HIDDEN_UPDATE, ShowBlast.ReticleChange)
	else
		ShowBlastUI:SetHidden(true)
	end

	EVENT_MANAGER:UnregisterForEvent(ShowBlast.name, EVENT_ADD_ON_LOADED)
	
end

function ShowBlast.ReticleChange(_, hidden)
	local h = hidden or true
	if ShowBlast.savedVariables.AlwaysShowAlert then
		ShowBlastUI:SetHidden(false)
	else
		ShowBlastUI:SetHidden(hidden)
	end
end

function ShowBlast.SaveLoc()
	ShowBlast.savedVariables.OffsetX = ShowBlastUI:GetLeft()
	ShowBlast.savedVariables.OffsetY = ShowBlastUI:GetTop()
end	
 
function ShowBlast.OnAddOnLoaded(event, addonName)
	if addonName ~= ShowBlast.name then return end
		ShowBlast:Initialize()
end

EVENT_MANAGER:RegisterForEvent(ShowBlast.name, EVENT_ADD_ON_LOADED, ShowBlast.OnAddOnLoaded)