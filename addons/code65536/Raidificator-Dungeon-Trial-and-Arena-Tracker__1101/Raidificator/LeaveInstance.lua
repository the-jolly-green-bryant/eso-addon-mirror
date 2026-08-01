local LCCC = LibCodesCommonCode
local RCR = Raidificator

local CONFIRM_COUNT = 2
local CONFIRM_SENSITIVITY = 1500

local RequestTime = 0
local RequestCount = 0

function RCR.LeaveInstanceKeybind( )
	if (CanExitInstanceImmediately()) then
		local currentTime = GetGameTimeMilliseconds()
		if (currentTime - RequestTime < CONFIRM_SENSITIVITY) then
			RequestCount = RequestCount + 1
		else
			RequestCount = 1
		end
		RequestTime = currentTime

		if (RequestCount < CONFIRM_COUNT) then
			RCR.Msg(string.format(GetString(SI_RCR_KEYBIND_CONFIRM), GetString(SI_GROUP_MENU_LEAVE_INSTANCE_KEYBIND), CONFIRM_COUNT - RequestCount, CONFIRM_SENSITIVITY / 1000))
		else
			RequestCount = 0
			ExitInstanceImmediately()
		end
	end
end

function RCR.InitializeLeaveInstance( )
	LCCC.RegisterString("SI_BINDING_NAME_RCR_LEAVE_INSTANCE", string.format("%s: %s", GetString(SI_RCR_TITLE), GetString(SI_GROUP_MENU_LEAVE_INSTANCE_KEYBIND)))
end
