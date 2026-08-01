UL_LootLog = UL_LootLog or {}
local ULLL = UL_LootLog

function ShowOrHideFromKeyBinding()
	--d(ULLL.IsShowing(nil))
	if not ULLL.IsShowing(nil) then
		ULLL.Show(nil)
	else
		ULLL.Hide(nil)
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