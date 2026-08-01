-- ==================================================================================================== --
-- # Immersive Interactions
-- # 
-- # It's an addon for ESO. I'm not going to put a fancy license or disclaimer. Go crazy with it.
-- ==================================================================================================== --
--[[
	function ImmersiveFunctions.HideChat()
	function ImmersiveFunctions.HideChatter()
	function ImmersiveFunctions.ParseTitle()
	function ImmersiveFunctions.ParseBody()
	function ImmersiveFunctions.ParseOptions()
	function ImmersiveFunctions.ParseStage()
	function ImmersiveFunctions.SetupChatter()
--]]

do
	local IMF = ImmersiveFunctions

	function ImmersiveFunctions.HideChat()
		if IMF.GetSetting("bHideChat") then
			if IMF.GetData("bService") and not IMF.GetSetting("bHideChatShop") then return end

			local cs = CHAT_SYSTEM

			if not cs:IsMinimized() then
				IMF.SetData("bRestoreChat", true)
				cs:Minimize()
			end

			if IMF.GetSetting("bHideMini") then
				-- NOTE: unsure how to check if the minibar is hidden by external actions
				if IMF.GetData("bService") and not IMF.GetSetting("bHideMiniShop") then return end
				IMF.SetData("bRestoreMini", true)
				cs:HideMinBar()
			end
		end
	end

	-- hide the text until "number of letters" * iOffsetMS (miliseconds) after starting audio
	function ImmersiveFunctions.HideChatter()
		if IMF.GetSetting("iOffsetMS") <= 0 then
			--IMF.SetHidden(false)
			return
		end

		IMF.SetHidden(true)

		if IMF.GetSetting("bAlwaysHide") or IMF.GetSetting("iOffsetMS") > IMF.GetData("MAX_TIMER") then return end

		IMF.SetData("iTime", GetFrameTimeMilliseconds())  -- prevent overwrite by dirty delay calls
		IMF.QueueText()
	end

	function ImmersiveFunctions.ParseTitle()
		local ctat = IMF.GetData("handles")["TargetAreaTitle"]

		ctat:SetMouseEnabled(true)
		ctat:SetText(IMF.Colorize("tat", IMF.GetData("title")))
		ctat:SetFont(IMF.GetFont("tat"))
		IMF.SetupAltTitle()
	end

	function ImmersiveFunctions.ParseBody()
		local htab = IMF.GetData("handles")["TargetAreaBodyText"]

		IMF.SetData("bodyText", htab:GetText())
		IMF.SetData("colorBodyText", IMF.ColorTab(IMF.GetData("bodyText")))
		IMF.SetData("blankBodyText", IMF.Blank())

		htab:SetText(IMF.GetData("colorBodyText"))
		htab:SetFont(IMF.GetFont("tab"))
	end

	function ImmersiveFunctions.ParseOptions()
		local hpao = IMF.GetData("handles")["PlayerAreaOptions"]

		if not IMF.GetData("opt") then IMF.InitArray("opt") end

		if string.find(GetUnitName("interact"), "Writs") then IMF.SetData("bService", true) end

		for i = 1, hpao:GetNumChildren() do
			local op = hpao:GetChild(i)
			IMF.SetDataArray("opt", i, op:GetText()) -- save the original
			op:SetText(IMF.ColorOpt(op, i))
			op:SetFont(IMF.GetFont("opt"))

			if IMF.Debug("options") then
				d(tostring(op.optionType))
			end
			IMF.SetupIcon(op)
			if op.optionType then
				for k, v in pairs(IMF.GetData("skipTypes")) do
					if op.optionType == v then IMF.SetData("bService", true); break end
				end
			end
		end
	end

	function ImmersiveFunctions.ParseStage()
		IMF.ParseTitle()
		IMF.ParseBody()
		IMF.ParseOptions()

		if IMF.GetSetting("bPrintDialog") and not IMF.GetData("bService") then
			local MsgWindow = ImmersiveData.MsgWindow
			MsgWindow:AddText(tostring(GetUnitName("interact").." says, \""..string.gsub(IMF.GetData("colorBodyText"), "%c", "_").."\""))

			local options = IMF.GetData("opt")
			for i = 1, IMF.GetNumOptions(options) do
				if options[i] == "" then break end
				-- DEBUG_START check for hidden characters
				local str = string.gsub(options[i], "%c", "_")
				if not str == options[i] then MsgWindow:AddText(tostring("DEBUG_ERROR::HCHAR::"..str)) end
				-- DEBUG_END
				MsgWindow:AddText(tostring(IMF.ColorOpt_text(options[i],i, false)))
			end
		end

		-- for some reason, talking to a shop keeper after another NPC, when closing the prior dialog before hidden timer ends, causes shop keeper to be hidden
		-- reset chatter now as a work around
		IMF.ResetChatter()

		-- return true if there is no audio for this dialog or if we've determined this is a skip npc
		return not IMF.CheckHiding()
	end

	function ImmersiveFunctions.SetupChatter()
		IMF.SetData("iTime", -1)
		IMF.InitArray("opt")

		IMF.RefreshTitles()
		IMF.SetupReplay()
	end
end
