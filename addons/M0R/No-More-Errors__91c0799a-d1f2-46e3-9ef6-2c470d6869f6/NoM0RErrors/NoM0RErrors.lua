-- The majority of this code is adapated from Garkin, Ayantir, and SlippyCheeze's No, Thank you! addon, which has been discontinued.
-- https://www.esoui.com/downloads/info865-Nothankyou.html#info


EVENT_MANAGER:UnregisterForEvent("ErrorFrame", EVENT_LUA_ERROR)

local provider = LibNotifications:CreateProvider()

local function RemoveNotification(data)
	table.remove(provider.notifications, data.notificationId)
	provider:UpdateNotifications()
end

local function OpenErrorNotification(data)
	ZO_ERROR_FRAME:OnUIError(data.data.errorString, data.data.errorCode)
	RemoveNotification(data)
end


local notifHeading = "|cFFD700Some M0R UI Errors|r"

local function OnLuaError(_, errorString, errorCode)
	if not ZO_ERROR_FRAME.suppressedErrors[errorCode] and errorString then
		local errorHexCode = ""
		if errorCode then
	        errorHexCode = ZO_SELECTED_TEXT:Colorize(string.format("%X", errorCode))
	    end
		local notifTitle = zo_strformat(SI_WINDOW_TITLE_UI_ERROR, errorHexCode) -- zos uses colorizedErrorHexCode = ZO_SELECTED_TEXT:Colorize(self.errorHexCode)
		local msg = {
			dataType = NOTIFICATIONS_REQUEST_DATA,
			secsSinceRequest = ZO_NormalizeSecondsSince(0),
			message = notifTitle.."\nPress Accept to open in the error window!",
			note = errorString,
			heading = notifHeading,
			texture = "/esoui/art/miscellaneous/eso_icon_warning.dds",
			shortDisplayText = notifTitle,
			--controlsOwnSounds = true,
			keyboardAcceptCallback = OpenErrorNotification,
			keybaordDeclineCallback = RemoveNotification,
			gamepadAcceptCallback = OpenErrorNotification,
			gamepadDeclineCallback = RemoveNotification,
			data = {errorString = errorString, errorCode = errorCode},
		}
		table.insert(provider.notifications, msg)
		provider:UpdateNotifications()
		d("A UI error ("..errorHexCode..") has been temporarily suppressed to your notifications!")
	end
end

EVENT_MANAGER:RegisterForEvent("NoM0RErrors", EVENT_LUA_ERROR, OnLuaError)


-- ONLY SUPRESS ERRORS WHILE IN THE SAME ZONE - POP ALL ERRORS WHEN MOVING ZONES



local lastZone = 0
local function playerActivated()
	local currentZone = GetUnitWorldPosition('player')
	if currentZone ~= lastZone then
		--d("Loaded into a new zone: "..currentZone..", last zone was: "..lastZone)
		if not ZO_IsTableEmpty(provider.notifications) then
			d("A new zone has been loaded into! NoM0RErrors will display all the previously suppressed errors so that you can report them to the developers!")
			for i,v in pairs(provider.notifications) do
				ZO_ERROR_FRAME:OnUIError(v.data.errorString, v.data.errorCode)
			end
			provider.notifications = {}
			provider:UpdateNotifications()
		end
		lastZone = currentZone
	end
end

EVENT_MANAGER:RegisterForEvent("NoM0RErrors", EVENT_PLAYER_ACTIVATED, playerActivated)
