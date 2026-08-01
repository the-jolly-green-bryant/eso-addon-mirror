-- Crystal Fragment Proc
-- This addon alerts you when Crystal Fragments procs by displaying a texture at the center bottom of the screen when the effect is triggered.
-- Author: Supplier (Nicholas)

-------------------------------------------------------------------------------------------------
--  Libraries --
-------------------------------------------------------------------------------------------------
local LAM2 = LibAddonMenu2

CFP = {}

CFP.name = "CrystalFragmentsProc"
CFP.displayVersion = "1.5"

CFP.Default = {
	offsetX = 950,
	offsetY = 790,
	iconWidth = 85,
	iconHeight = 85,
	showCFP = true,
	textSize = 50
}

--FUNC - Initialize whenever addon is loaded
function CFP.OnAddOnLoaded(event, addonName)
  if addonName == CFP.name then
	CFP:Initialize()
  end
end

function CFP:Initialize()
	CFP.inCombat = IsUnitInCombat("player")
	CFP.ClassId = GetUnitClassId("player")
	
	--PROCESSING - Checks to see if player is a Sorcerer. If Sorc, register for the needed events and initialize variables and window for image (alert). 
	if CFP.ClassId == 2 then
		local crystalFragSlot					-- Variable: Value, slot of the Crystal Fragment Skill
		local crystalFragSlotFound = false		-- Variable: Boolean, Whether there is a slot with the Crystal Fragment Skill
		local crystalFragDuration				-- Variable: Value, duration of the Crystal Fragment skill

		EVENT_MANAGER:RegisterForEvent(CFP.name, EVENT_PLAYER_COMBAT_STATE, CFP.OnPlayerCombatState)
		EVENT_MANAGER:RegisterForEvent(CFP.name, EVENT_EFFECT_CHANGED, CFP.checkCrystalProc)
		EVENT_MANAGER:RegisterForEvent(CFP.name, EVENT_ACTIVE_WEAPON_PAIR_CHANGED, CFP.OnPlayerSwapWeap)
		
		createBuffImage()
		
		CFP.savedVariables = ZO_SavedVars:NewCharacterIdSettings("CFPSavedVariables", 1, nil, CFP.Default)
		CFP:RestoreSettings()
		
		SLASH_COMMANDS["/cfp"] = showIndicator
	end	
end

--FUNC - A function that sets the indicator to be shown or not
function showIndicator(toDo)
	if toDo == "show" then
		CFPWindow:SetHidden(false)
	else if toDo == "hide" then
		CFPWindow:SetHidden(true)
	else return end
	end
end

--FUNC - Creates the Crystal Fragment Buff image
function createBuffImage()
	local image = WINDOW_MANAGER:CreateControl("CFPWindowImage", CFPWindow, CT_TEXTURE)
	image:SetAnchorFill(CFPWindow)
	CFPWindowImage:SetTexture("/esoui/art/icons/ability_sorcerer_thunderstomp_proc.dds")
end

--FUNC - Event handler for EVENT_EFFECT_CHANGED. Checks for Crystal Fragment Passive Proc and display/remove alert accordingly.
function CFP.checkCrystalProc(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitID, abilityID)
	--PROCESSING - ignore anything not related to player (npc, other players)
	if unitTag ~= "player" then return end
	
	--PROCESSING - check whether the effect is a Crystal Fragment Proc. 
	if abilityID == 46327 then
		--PROCESSING - Find where the crystal fragment slot is on the action bar using a while loop if it hasn't been found yet. 
		if not crystalFragSlotFound then
			crystalFragSlot = 3
			while (crystalFragSlot < 8) do
				if GetSlotBoundId(crystalFragSlot) == 114716 then
					crystalFragSlotFound = true
					break
				end
				crystalFragSlot = crystalFragSlot + 1
			end
		end
		
		--PROCESSING - Display alert(texture) to alert user if the Crystal Fragment Proc slot is active. Otherwise, remove alert.
		if GetSlotBoundId(crystalFragSlot) == 114716 and CFP.inCombat then
			CFPWindow:SetHidden(false)

			crystalFragDuration = 8
			CFPWindowCounter:SetText(string.format("%d", crystalFragDuration))

			EVENT_MANAGER:RegisterForUpdate(CFP.name, 1000, function(gameTimeMs) CFP.UpdateTimer() end)
		else
			CFPWindow:SetHidden(true)
			EVENT_MANAGER:UnregisterForUpdate(CFP.name)
		end
	end
end

--FUNC - If combat is over, set boolean variable crystalFragSlotFound back to false. This is
--	done to make sure the addon still works if user move their skills in their hotbar during gameplay.
function CFP.OnPlayerCombatState(event, inCombat)
  if inCombat ~= CFP.inCombat then
    CFP.inCombat = inCombat
	if not inCombat then
		crystalFragSlotFound = false
    end
  end
end

-- FUNC - Function that is called every second. Updates the timer.
function CFP.UpdateTimer()
	crystalFragDuration = crystalFragDuration - 1
	CFPWindowCounter:SetText(string.format("%d", crystalFragDuration))
	if crystalFragDuration <= 0 then 
		CFPWindow:SetHidden(true)
		EVENT_MANAGER:UnregisterForUpdate(CFP.name)
	end
end

--FUNC - Whenever user swaps its weapon, set boolean variable crystalFragSlotFound back to false
function CFP.OnPlayerSwapWeap(event)
	crystalFragSlotFound = false
end

--FUNC - Restores position and size of the indicator
function CFP:RestoreSettings()
  local offsetX = CFP.savedVariables.offsetX
  local offsetY = CFP.savedVariables.offsetY

  CFP.CreateSettingsWindow()
  CFPWindow:SetHidden(CFP.savedVariables.showCFP)
  CFP.SetIconSize(CFP.savedVariables.iconWidth, CFP.savedVariables.iconHeight)
  CFP.SetTextSize(CFP.savedVariables.textSize)

  CFPWindow:ClearAnchors()
  CFPWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, offsetX, offsetY)
end

--FUNC - Saves location of the indicator when moved
function CFP.OnIndicatorMoveStop()
	CFP.savedVariables.offsetX = CFPWindow:GetLeft()
	CFP.savedVariables.offsetY = CFPWindow:GetTop()
end

--FUNC - Sets the Dimensions of the Indicator Image
function CFP.SetIconSize(_width, _height)
	CFPWindow:SetDimensions(_width, _height)	
end

--FUNC - Sets the size of the Indicator Timer Text
function CFP.SetTextSize(size)
	CFPWindowCounter:SetFont("EsoUI/Common/Fonts/univers67.otf|" .. size .. "|thick-outline")
end

-- FUNC - Create the Settings Window for this Addon. (Requires LibAddonMenu2!)
function CFP.CreateSettingsWindow() 
	local panelData = {
		type = "panel",
		name = "Crystal Fragments Proc",
		displayName = "Crystal Fragments Proc",
		author = "Supplier",
		version = CFP.version,
		slashCommand = "/cfp menu",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	local cntrlOptionsPanel = LAM2:RegisterAddonPanel("Crystal_Fragments_Proc", panelData)

	local optionsData = {
		[1] = {
			type = "header",
			name = "Crystal Fragments Proc Indicator Settings",
		},
		[2] = {
			type = "description",
			text = "Here you can adjust how the indicator looks.",
		},
		[3] = {
			type = "checkbox",
			name = "Show Crystal Fragments Proc Indicator",
			tooltip = "When ON the indicator will be visible. When OFF the indicator will be hidden.",
			default = false,
			getFunc = function() return not CFP.savedVariables.showCFP end,
			setFunc = function(newValue) 
				CFP.savedVariables.showCFP = not newValue
				CFPWindow:SetHidden(not newValue)  end,
		},
		[4] = {
			type = "slider",
			name = "Select Width",
			tooltip = "Adjusts the width of the icon",
			min = 55,
			max = 100,
			step = 1,
			default = 85,
			getFunc = function() return CFP.savedVariables.iconWidth end,
			setFunc = function(newValue)
						CFP.savedVariables.iconWidth = newValue
						CFP.SetIconSize(newValue, CFP.savedVariables.iconHeight)
						end,
		},
		[5] = {
			type = "slider",
			name = "Select Height",
			tooltip = "Adjusts the height of the icon",
			min = 55,
			max = 100,
			step = 1,
			default = 85,
			getFunc = function() return CFP.savedVariables.iconHeight end,
			setFunc = function(newValue)
						CFP.savedVariables.iconHeight = newValue
						CFP.SetIconSize(CFP.savedVariables.iconWidth, newValue)
						end,
		},
		[6] = {
			type = "slider",
			name = "Select Timer Text Size",
			tooltip = "Adjusts the font size of the timer",
			min = 25,
			max = 85,
			step = 1,
			default = 50,
			getFunc = function() return CFP.savedVariables.textSize end,
			setFunc = function(newValue)
						CFP.savedVariables.textSize = newValue
						CFP.SetTextSize(newValue)
						end,
		},
	}
	LAM2:RegisterOptionControls("Crystal_Fragments_Proc", optionsData)
end


EVENT_MANAGER:RegisterForEvent(CFP.name, EVENT_ADD_ON_LOADED, CFP.OnAddOnLoaded)