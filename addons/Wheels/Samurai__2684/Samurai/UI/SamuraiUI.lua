SAMURAI = SAMURAI or { }
local sam = SAMURAI
local WM = GetWindowManager()
local SM = SCENE_MANAGER

sam.UI = { }
sam.UI.activeAlerts = { }

function sam._onMoveStop()
	local _, aPoint, _, aRelPoint, aOffX, aOffY = sam.UI.activeAlerts[1]:GetAnchor(0)
	local _, tPoint, _, tRelPoint, tOffX, tOffY = sam.UI.timedAlert:GetAnchor(0)
	sam.savedVars.activeOffsetX = aOffX
	sam.savedVars.activeOffsetY = aOffY
	sam.savedVars.activePoint = aPoint
	sam.savedVars.activeRelPoint = aRelPoint

	sam.savedVars.timedOffsetX = tOffX
	sam.savedVars.timedOffsetY = tOffY
	sam.savedVars.timedPoint = tPoint
	sam.savedVars.timedRelPoint = tRelPoint
end

function sam.UI.spawnNotificationFrame()
	local newFrameNum = #sam.UI.activeAlerts + 1
	sam.UI.activeAlerts[newFrameNum] = WM:CreateControlFromVirtual("SAMURAI_NOTI_" .. newFrameNum, sam.UI.window, "NotificationTemplate")
	sam.UI.activeAlerts[newFrameNum]:SetAnchor(BOTTOM, sam.UI.activeAlerts[newFrameNum - 1], TOP, 0, 10)
	sam.UI.activeAlerts[newFrameNum]:SetText("Notification #" .. tostring(newFrameNum))
	return newFrameNum
end

function sam.UI.getAvailableNotificationFrame()
	for num,frame in ipairs(sam.UI.activeAlerts) do
		if frame:IsControlHidden() then
			--frame:SetHidden(false)
			return num
		end
	end
	return sam.UI.spawnNotificationFrame()
end

function sam.UI.displayAlert(frameNum, formattedMessage)
	sam.UI.activeAlerts[frameNum]:SetText(formattedMessage)
	sam.UI.activeAlerts[frameNum]:SetHidden(false)
end

function sam.UI.hideAlert(frameNum)
	if sam.UI.activeAlerts[frameNum] then
		sam.UI.activeAlerts[frameNum]:SetHidden(true)
	end
end

function sam.UI.setHudDisplay(value)
	if value then
		SM:GetScene("hud"):AddFragment(sam.UI.windowFragment)
		SM:GetScene("hudui"):AddFragment(sam.UI.windowFragment)
	else
		SM:GetScene("hud"):RemoveFragment(sam.UI.windowFragment)
		SM:GetScene("hudui"):RemoveFragment(sam.UI.windowFragment)
	end
	sam.UI.window:SetHidden(value)
	sam.UI.timedAlert:SetHidden(value)
	sam.UI.timedAlert:SetText("Timed Alert")
	sam.UI.timedAlert:SetMovable(not value)
	sam.UI.timedAlert:SetMouseEnabled(not value)
	for num,frame in ipairs(sam.UI.activeAlerts) do
		frame:SetHidden(value)
		frame:SetText("Notification #"..num)
	end
	sam.UI.activeAlerts[1]:SetMovable(not value)
	sam.UI.activeAlerts[1]:SetMouseEnabled(not value)
end

function sam.buildDisplay()
	local window = WM:CreateTopLevelWindow("SAMURAI_DISPLAY")
	--window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
	window:SetAnchorFill()
	window:SetMouseEnabled(false)
	window:SetMovable(false)
	window:SetHidden(false)
	window:SetResizeToFitDescendents(true)

	local noti1 = WM:CreateControlFromVirtual("SAMURAI_NOTI_1", window, "NotificationTemplate")
	noti1:SetAnchor(sam.savedVars.activePoint, window, sam.savedVars.activeRelPoint, sam.savedVars.activeOffsetX, sam.savedVars.activeOffsetY)
	noti1:SetHandler("OnMoveStop", function(...) sam._onMoveStop() end)
	noti1:SetText("Notification #1")

	local timedAlert = WM:CreateControlFromVirtual("SAMURAI_TIMED_ALERT", window, "NotificationTemplate")
	timedAlert:SetAnchor(sam.savedVars.timedPoint, window, sam.savedVars.timedRelPoint, sam.savedVars.timedOffsetX, sam.savedVars.timedOffsetY)
	timedAlert:SetFont("$(BOLD_FONT)|$(KB_40)|thick-outline")
	timedAlert:SetColor(1, 1, .25)
	timedAlert:SetText("Timer Notification")
	timedAlert:SetHandler("OnMoveStop", function(...) sam._onMoveStop() end)

	sam.UI.window = window
	sam.UI.windowFragment = ZO_HUDFadeSceneFragment:New(sam.UI.window)
	sam.UI.timedAlert = timedAlert
	sam.UI.activeAlerts[1] = noti1
	sam.UI.setHudDisplay(true)
end

