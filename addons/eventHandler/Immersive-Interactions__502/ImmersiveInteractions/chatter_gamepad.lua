-- ==================================================================================================== --
-- # Immersive Interactions
-- # 
-- # It's an addon for ESO. I'm not going to put a fancy license or disclaimer. Go crazy with it.
-- ==================================================================================================== --
--[[
	function ImmersiveFunctions.HideChatGP()
	function ImmersiveFunctions.HideChatterGP()
	function ImmersiveFunctions.ParseTitleGP()
	function ImmersiveFunctions.ParseBodyGP()
	function ImmersiveFunctions.ParseOptionsGP()
	function ImmersiveFunctions.ParseStageGP()
	function ImmersiveFunctions.SetupChatterGP()
--]]

do
	local IMF = ImmersiveFunctions

	-- support potentially different code for consoles
	function ImmersiveFunctions.HideChatGP()
		--IMF.HideChat()
	end

	function ImmersiveFunctions.HideChatterGP()
		--IMF.HideChatter()
		--d("I'm not a miracle worker.")
	end

	function ImmersiveFunctions.ParseStageGP()
		--return IMF.ParseStage()
		return true
	end

	function ImmersiveFunctions.SetupChatterGP()
		--IMF.SetupChatter()
		--d("Only so much I can do with... this...")

		--ZO_InteractWindow_Gamepad:SetHidden(true)
		--IMF.HideChatGP()
	end
end
