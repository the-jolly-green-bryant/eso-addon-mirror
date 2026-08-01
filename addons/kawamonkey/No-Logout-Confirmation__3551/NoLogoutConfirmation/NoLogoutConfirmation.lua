ZO_PreHook(
	"ZO_Dialogs_ShowGamepadDialog",
	function(dialogName)
		if dialogName == "GAMEPAD_LOG_OUT" then
			Logout()
			return true
		end
	end
)
ZO_PreHook(
	"ZO_Dialogs_ShowDialog",
	function(dialogName)
		if dialogName == "LOG_OUT" then
			Logout()
			return true
		elseif dialogName == "QUIT" then
			Quit()
			return true
		end
	end
)