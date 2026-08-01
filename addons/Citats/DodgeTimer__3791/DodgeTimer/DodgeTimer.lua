DodgeTimer = {}
DodgeTimer.name = "DodgeTimer"

function DodgeTimer.LoadSettings()
	local LAM = LibAddonMenu2
	local panelName = "DodgeTimerPanel"

	local panelData = {
		type = "panel",
		name = "DodgeTimer",
		author = "@Citats",
	}
	local panel = LAM:RegisterAddonPanel(panelName, panelData)
	local optionsData = {
		[1] = {
			type = "checkbox",
			name = "Lock",
			tooltip = "Toggle off to move the timer position on screen. Toggle back on to save the new position.",
			getFunc = function() return true end,
			setFunc = function(value)
				if value then
					DodgeTimer.locked = true
					
					local coordX, coordY = DodgeTimerBar:GetCenter()
					DodgeTimer.offsetX = coordX-(GuiRoot:GetWidth()/2)
					DodgeTimer.offsetY = coordY-(GuiRoot:GetHeight()/2)
					
					DodgeTimer.savedVariables.OffsetX = DodgeTimer.offsetX
					DodgeTimer.savedVariables.OffsetY = DodgeTimer.offsetY
					
					DodgeTimerBar:SetMouseEnabled(false)
					DodgeTimerBar:SetMovable(false)
					
					DodgeTimer.HudScene:AddFragment(DodgeTimer.MyFragment)
					
					d("DodgeTimer position saved.")
				else
					DodgeTimer.locked = false
					
					DodgeTimerBar:SetMouseEnabled(true)
					DodgeTimerBar:SetMovable(true)
					
					DodgeTimer.HudScene:RemoveFragment(DodgeTimer.MyFragment)
					DodgeTimerBar:SetHidden(false)
				end
			end,
			width = "full"
		},
		[2] = {
			type = "divider",
			width = "full"
		},
		[3] = {
			type = "button",
			name = "Donate Gold",
			tooltip = "Because I ams poor PvPer.",
			func = function()
				if GetWorldName() == "NA Megaserver" then
					SCENE_MANAGER:Show('mailSend')
					zo_callLater(
						function()
							ZO_MailSendToField:SetText("@Citats")
							ZO_MailSendSubjectField:SetText("Donation")
							QueueMoneyAttachment(1)
							ZO_MailSendBodyField:TakeFocus() 
						end, 
					200)
				else
					CHAT_SYSTEM:Maximize()
					d("We are on different servers sadface.")
				end
			end,
			width = "full",
		},
	}
	LAM:RegisterOptionControls(panelName, optionsData)
end

function DodgeTimer.OnAddOnLoaded(event, addonName)
	if addonName == DodgeTimer.name then
		DodgeTimer.timerIsActive = false
		DodgeTimer.locked = true
		DodgeTimer.offsetX = 400
		DodgeTimer.offsetY = 150
		DodgeTimer.Initialize()
		DodgeTimer.LoadSettings()

		EVENT_MANAGER:UnregisterForEvent(DodgeTimer.name, EVENT_ADD_ON_LOADED)
	end
end

function DodgeTimer.Initialize()
	EVENT_MANAGER:RegisterForEvent(DodgeTimer.name, EVENT_EFFECT_CHANGED, DodgeTimer.OnEffectChanged)
	local myDefaults = {}
	myDefaults.OffsetX = 400
	myDefaults.OffsetY = 150
	DodgeTimer.savedVariables = ZO_SavedVars:NewCharacterIdSettings("DodgeTimerSavedVariables", 1.0, nil, myDefaults, GetWorldName())

	DodgeTimer.TimerDuration = 4000
	DodgeTimer.AbilityId = 69143

	DodgeTimer.MyFragment = ZO_SimpleSceneFragment:New(DodgeTimerBar)
	DodgeTimer.HudScene = SCENE_MANAGER:GetScene("hud")
	DodgeTimer.HudScene:AddFragment(DodgeTimer.MyFragment)

	DodgeTimerBar:ClearAnchors()
	DodgeTimerBar:SetAnchor(CENTER, GuiRoot, CENTER, DodgeTimer.savedVariables.OffsetX, DodgeTimer.savedVariables.OffsetY)
end

function DodgeTimer.OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)

	if sourceType == COMBAT_UNIT_TYPE_PLAYER and abilityId == DodgeTimer.AbilityId and changeType == 3 then
		DodgeTimer.RestartTimer(stackCount)
	end
end

function DodgeTimer.RestartTimer(stackCount)
	
	DodgeTimer.timerIsActive = true
	
	DodgeTimerBarContainerLabel:SetText(stackCount)
	
	DodgeTimerBarContainerMiddle:SetDimensions(0, 50)
	DodgeTimerBarContainer:SetCenterColor(0,0,0,1)
	DodgeTimerBarContainerMiddle:SetHidden(false)
	DodgeTimerBarContainerLabel:SetHidden(false)
	
	if DodgeTimer.timeline ~= null then
		DodgeTimer.timeline:PlayFromStart()
	else
		DodgeTimer.timeline = ANIMATION_MANAGER:CreateTimeline()
		
		local animationDown = DodgeTimer.timeline:InsertAnimation(ANIMATION_SIZE, DodgeTimerBarContainerMiddle, 0)
		animationDown:SetStartAndEndHeight(50, 0)
		animationDown:SetStartAndEndWidth(25, 25)
		animationDown:SetDuration(DodgeTimer.TimerDuration)
		
		DodgeTimer.timeline:SetHandler('OnStop', function()
			DodgeTimer.timerIsActive = false
		
			DodgeTimerBarContainerMiddle:SetDimensions(25, 0)
			DodgeTimerBarContainer:SetCenterColor(0,1,0,1)
			DodgeTimerBarContainerMiddle:SetHidden(true)
			DodgeTimerBarContainerLabel:SetHidden(true)	
		end)
		
		DodgeTimer.timeline:PlayFromStart()
	end
	
end

EVENT_MANAGER:RegisterForEvent(DodgeTimer.name, EVENT_ADD_ON_LOADED, DodgeTimer.OnAddOnLoaded)