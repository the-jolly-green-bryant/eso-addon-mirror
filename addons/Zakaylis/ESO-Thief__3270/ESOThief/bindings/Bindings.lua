ESOThief = ESOThief or {}
local ULLL = ESOThief

function ShowOrHideFromKeyBinding()
	if not ULLL.IsShowing(nil) then
		ULLL.Show(nil)
	else
		ULLL.Hide(nil)
	end 
end

function SHORT_INFO_ShowOrHideFromKeyBinding()
--d(ULLL.IsShortInfoWindowShowing.IsShowing)

	if ULLL.ShortInfoWindow:IsHidden() then
	--d('here')
		ULLL.ShortInfoWindow:SetHidden(false)
		ULLL.IsShortInfoWindowShowing.IsShowing = true
	else
		ULLL.ShortInfoWindow:SetHidden(true)
		ULLL.IsShortInfoWindowShowing.IsShowing = false
	end 
end

function Start()
	ULLL.Start(nil)
end

function Stop()
	ULLL.Stop(nil)
end

function CleanStop()
	ULLL.Stop(true)
end

function CleanStart()
	ULLL.Start(true)
end