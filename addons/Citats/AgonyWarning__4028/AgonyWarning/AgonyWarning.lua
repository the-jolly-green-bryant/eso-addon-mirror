AgonyWarning = {}
AgonyWarning.name = "AgonyWarning"

local LGPS = LibGPS2
local LMP = LibMapPing
local LAM = LibAddonMenu2

AgonyWarning.MapStepSize = 1.4285034012573e-005

function AgonyWarning.LoadSettings()
	local panelName = "AgonyWarningPanel"

	local panelData = {
		type = "panel",
		name = "AgonyWarning",
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
					AgonyWarning.Locked = true
					AgonyWarningBar:SetHidden(true)
					
					local coordX, coordY = AgonyWarningBar:GetCenter()
					AgonyWarning.SavedVariables.OffsetX = coordX-(GuiRoot:GetWidth()/2)
					AgonyWarning.SavedVariables.OffsetY = coordY-(GuiRoot:GetHeight()/2)
					
					AgonyWarningBar:SetMouseEnabled(false)
					AgonyWarningBar:SetMovable(false)
					
					d("AgonyWarning position saved.")
				else
					AgonyWarning.Locked = false
					AgonyWarningBar:SetHidden(false)
					
					AgonyWarningBar:SetMouseEnabled(true)
					AgonyWarningBar:SetMovable(true)
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
			name = "Donate",
			func = function()
				if GetWorldName() == "NA Megaserver" then
					SCENE_MANAGER:Show('mailSend')
					zo_callLater(
						function()
							ZO_MailSendToField:SetText("@Citats")
							ZO_MailSendSubjectField:SetText("Donation")
							QueueMoneyAttachment(0)
							ZO_MailSendBodyField:TakeFocus() 
						end, 
					200)
				else
					CHAT_SYSTEM:Maximize()
					d("We are on different servers.")
				end
			end,
			width = "full",
		},
	}
	LAM:RegisterOptionControls(panelName, optionsData)
end

function AgonyWarning.OnAddOnLoaded(event, addonName)
	if addonName == AgonyWarning.name then
		AgonyWarning.WarningIsActive = false
		AgonyWarning.Locked = true
		AgonyWarning.Initialize()
		AgonyWarning.LoadSettings()

		EVENT_MANAGER:UnregisterForEvent(AgonyWarning.name, EVENT_ADD_ON_LOADED)
	end
end

function AgonyWarning.OnPlayerActivated(eventCode, initial)
	if AgonyWarning.Locked then
		AgonyWarningBar:SetHidden(true)
	end
end

function AgonyWarning.Initialize()
	EVENT_MANAGER:RegisterForEvent(AgonyWarning.name, EVENT_COMBAT_EVENT, AgonyWarning.OnCombatEvent)
	local myDefaults = {}
	myDefaults.OffsetX = 0
	myDefaults.OffsetY = -275
	AgonyWarning.SavedVariables = ZO_SavedVars:NewCharacterIdSettings("AgonyWarningSavedVariables", 1.0, nil, myDefaults, GetWorldName())
	
	AgonyWarning.WarningDuration = 1200
	AgonyWarning.AbilityId = 160184

	AgonyWarning.CreateTimerBarControl()
	
	LMP:RegisterCallback("BeforePingAdded", AgonyWarning.OnBeforePingAdded)
	LMP:RegisterCallback("AfterPingRemoved", AgonyWarning.OnAfterPingRemoved)
	
	SLASH_COMMANDS["/testagonywarning"] = AgonyWarning.Test
end

function AgonyWarning.CreateTimerBarControl()
	local wm = WINDOW_MANAGER
	AgonyWarning.TLW = wm:CreateTopLevelWindow("AgonyWarningTLW")
	AgonyWarning.TimerBar = wm:CreateControl("AgonyWarningBar", AgonyWarning.TLW, CT_CONTROL)
	AgonyWarning.TimerBar:SetHidden(true)
	AgonyWarning.TimerBar:ClearAnchors()
	AgonyWarning.TimerBar:SetAnchor(BOTTOM, GuiRoot, CENTER, AgonyWarning.SavedVariables.OffsetX, AgonyWarning.SavedVariables.OffsetY)
	AgonyWarning.TimerBar:SetDimensions(400, 100)
	
	AgonyWarning.TimerBar.Container = wm:CreateControl("AgonyWarningBarContainer", AgonyWarning.TimerBar, CT_BACKDROP)
	AgonyWarning.TimerBar.Container:SetAnchor(CENTER, AgonyWarning.TimerBar, CENTER, 0, 0)
	AgonyWarning.TimerBar.Container:SetDimensions(400, 100)
	AgonyWarning.TimerBar.Container:SetCenterColor( 1, 0, 0, 1)
	AgonyWarning.TimerBar.Container:SetEdgeColor(0, 0, 0, 1.0)
	AgonyWarning.TimerBar.Container:SetEdgeTexture(nil, 1, 1, 0.1, 0.1)
	
	AgonyWarning.TimerBar.Container.Front = wm:CreateControl("AgonyWarningBarContainerFront", AgonyWarning.TimerBar.Container, CT_LABEL)
	AgonyWarning.TimerBar.Container.Front:SetAnchor(CENTER, AgonyWarning.TimerBar.Container, CENTER, 0, 0)
	AgonyWarning.TimerBar.Container.Front:SetFont("$(MEDIUM_FONT)|$(KB_48)|thick-outline")
	AgonyWarning.TimerBar.Container.Front:SetColor(1, 1, 1, 1)
	AgonyWarning.TimerBar.Container.Front:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	AgonyWarning.TimerBar.Container.Front:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	
	AgonyWarning.TimerBar.Container.Front:SetText("BLOCK")
end

function AgonyWarning.OnCombatEvent(eventCode,result,isError,abilityName,abilityGraphic,abilityActionSlotType,sourceName,sourceType,targetName,targetType,hitValue,powerType,damageType,combatEventLog,sourceUnitId,targetUnitId,abilityId)
	if abilityId == AgonyWarning.AbilityId and sourceType == 5 and not AgonyWarning.WarningIsActive then
		AgonyWarning.ShowWarning()
		
		if GetGroupSize() ~= 0 then
			AgonyWarning.SendWarning()
		end
	end
end

function AgonyWarning.Test()
	AgonyWarning.ShowWarning()
		
	if GetGroupSize() ~= 0 then
		AgonyWarning.SendWarning()
	end
end

--Original code comes from rdkgrouptool
function AgonyWarning.SendWarning()
	LGPS:PushCurrentMap()
	SetMapToMapListIndex(23)
	LMP:SetMapPing(MAP_PIN_TYPE_PING, MAP_TYPE_LOCATION_CENTERED, AgonyWarning.EncodeMessage(10, 10, 10, 10))
	LGPS:PopCurrentMap()
end

function AgonyWarning.OnBeforePingAdded(pingType, pingTag, x, y, isPingOwner)
	if (pingType == MAP_PIN_TYPE_PING) then
		LGPS:PushCurrentMap()
		SetMapToMapListIndex(23)
		x, y = LMP:GetMapPing(pingType, pingTag)
		local b0, b1, b2, b3 = AgonyWarning.DecodeMessage(x,y)
		LGPS:PopCurrentMap()
		LMP:SuppressPing(pingType, pingTag)

		if b0 == 10 and b1 == 10 and b2 == 10 and b3 == 10 and not AgonyWarning.WarningIsActive then
			AgonyWarning.ShowWarning()
		end
	end
end

function AgonyWarning.OnAfterPingRemoved(pingType, pingTag, x, y, isPingOwner)
	if (pingType == MAP_PIN_TYPE_PING) then
		LMP:UnsuppressPing(pingType, pingTag)
	end
end

--Original code comes from libgroupsocket
function AgonyWarning.DecodeMessage(x, y)
	x = math.floor(x / AgonyWarning.MapStepSize + 0.5)
	y = math.floor(y / AgonyWarning.MapStepSize + 0.5)

	local b0 = math.floor(x / 0x100)
	local b1 = x % 0x100
	local b2 = math.floor(y / 0x100)
	local b3 = y % 0x100

	return b0, b1, b2, b3
end

function AgonyWarning.EncodeMessage(b0, b1, b2, b3)
	b0 = b0 or 0
	b1 = b1 or 0
	b2 = b2 or 0
	b3 = b3 or 0
	return (b0 * 0x100 + b1) * AgonyWarning.MapStepSize, (b2 * 0x100 + b3) * AgonyWarning.MapStepSize
end

function AgonyWarning.ShowWarning()
	AgonyWarning.WarningIsActive = true
	AgonyWarningBar:SetHidden(false)
	zo_callLater(function() AgonyWarning.HideWarning() end, AgonyWarning.WarningDuration)
end

function AgonyWarning.HideWarning()
	AgonyWarning.WarningIsActive = false
	if AgonyWarning.Locked then
		AgonyWarningBar:SetHidden(true)
	end
end

EVENT_MANAGER:RegisterForEvent(AgonyWarning.name, EVENT_ADD_ON_LOADED, AgonyWarning.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(AgonyWarning.name, EVENT_PLAYER_ACTIVATED, AgonyWarning.OnPlayerActivated)