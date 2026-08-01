-- ==================================================================================================== --
-- # Immersive Interactions
-- # 
-- # It's an addon for ESO. I'm not going to put a fancy license or disclaimer. Go crazy with it.
-- ==================================================================================================== --

--[[
--]]

do
	local IMF = ImmersiveFunctions

	function ImmersiveFunctions.ChatterEnd()
		if IMF.GetData("bNotChattering") then return end

		local cs = CHAT_SYSTEM
		if IMF.GetData("bRestoreMini") then cs:ShowMinBar();	IMF.SetData("bRestoreMini", false) end
		if IMF.GetData("bRestoreChat") then cs:Maximize();		IMF.SetData("bRestoreChat", false) end

		IMF.SaveAltTitle()

		IMF.CleanUpAll()
		IMF.RestoreDefaultData()

		IMF.SetData("do_once", true)
		IMF.SetData("bNotChattering", true)
	end

	function ImmersiveFunctions.GetKeyboard()
		return IMF.SetupChatter, IMF.ParseStage, IMF.HideChatter, IMF.HideChat
	end

	function ImmersiveFunctions.GetGamepad()
		return IMF.SetupChatterGP, IMF.ParseStageGP, IMF.HideChatterGP, IMF.HideChatGP
	end

	function ImmersiveFunctions.ChatterHandler()
		if IMF.IsInvalid() then return end

		if not IMF.GetSetting("bEnabled") then IMF.ChatterEnd(); IMF.AddonDisable() return end

		IMF.SetData("bNotChattering", false)

		-- allow console support with "function pointers" assigned appropriately
		local SetupChatter, ParseStage, HideChatter, HideChat

		if IsInGamepadPreferredMode() then
			SetupChatter, ParseStage, HideChatter, HideChat = IMF.GetGamepad()
			ImmersiveData.handles = ImmersiveData.handlesGP
			ImmersiveData.states = ImmersiveData.statesGP
		else
			SetupChatter, ParseStage, HideChatter, HideChat = IMF.GetKeyboard()
			ImmersiveData.handles = ImmersiveData.handlesKB
			ImmersiveData.states = ImmersiveData.statesKB
		end

		if IMF.GetData("do_once") then
			SetupChatter()
		end

		-- ParseStage() returns true if this convo qualifies for hiding, otherwise move on
		if ParseStage() then HideChatter() end

		if IMF.GetData("do_once") then
			HideChat()
			IMF.SetData("do_once", false)
		end
	end
end
