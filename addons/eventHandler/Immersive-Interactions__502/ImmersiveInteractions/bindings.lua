-- ==================================================================================================== --
-- # Immersive Interactions
-- # 
-- # It's an addon for ESO. I'm not going to put a fancy license or disclaimer. Go crazy with it.
-- ==================================================================================================== --

--[[
	function ImmersiveFunctions.SelectChatterGoodbye()
	function ImmersiveFunctions.SelectChatterOpt()

	function ImmersiveFunctions.ForceShowText()
	function ImmersiveFunctions.ReplayAudio()
	function ImmersiveFunctions.Refresh(key)
	function ImmersiveFunctions.ToggleHide(key)

	function ImmersiveFunctions.HookAltTitle(control, button, upInside)
	function ImmersiveFunctions.HookToggleButton(control, button, upInside)
	function ImmersiveFunctions.HookMsgWindow(control, button, upInside)

	function ImmersiveFunctions.ReloadUI()
	function ImmersiveFunctions.ToggleLoot(key)
--]]

-- ## Keybind functions ## --
do
	function ImmersiveFunctions.SelectChatterGoodbye()
		local IMF = ImmersiveFunctions
		if IMF.IsInvalid() then return end

		IMF.ChatterEnd()

		-- dislike this use of a global handle, but buggy other ways I tried DEBUG
		INTERACTION:CloseChatter()
	end

	function ImmersiveFunctions.SelectChatterOpt(opt)
		local IMF = ImmersiveFunctions
		if IMF.IsInvalid() then return end

		local numOpt = IMF.GetNumOptions(IMF.GetData("opt"))
		--d("Immersive Interactions -- option: "..opt.." | total options: "..numOpt)

		if numOpt ~= nill and numOpt >= opt then
			local optionString, optionType = GetChatterOption(opt)
			if optionType == CHATTER_GOODBYE then
				IMF.SelectChatterGoodbye()
			else
				SelectChatterOption(opt)
			end
		else
			-- DEBUG ME
			d("Immersive Interactions -- Warning: FAILURE TO SELECT OPT")
		end
	end

	function ImmersiveFunctions.ForceShowText()
		local IMF = ImmersiveFunctions
		if IMF.IsInvalid() then return end

		IMF.ResetChatter()
	end

	function ImmersiveFunctions.ReplayAudio()
		local IMF = ImmersiveFunctions
		if IMF.IsInvalid() then return end

		--[[ calling GetChatterData() restarts the current dialog audio
		-- replay behaves as if starting a new conversation, so dialog may change if the NPC has variations
		-- replay essentially starts a new conversation when used on quest reward screens --]]
		local text, numOptions, atGreeting = GetChatterData()

		-- check for new text when replaying audio, handle it appropriately
		IMF.RefreshTab(text)

		--[[ This fixes the response options to match the repeated dialogue on quest interactions,
		-- because the audio goes back to the starting stage and the responses were still
		-- reflecting the (possibly later) stage of the conversation where the repeat was initiated.
		-- This is only an issue on quest interactions, because normally the current stage repeats
		-- without having to redo the entire conversation.  -- eventHandler --]]
		if GetInteractionType() == INTERACTION_QUEST then
			IMF.ResetChatter()
			ResetChatter()			-- not sure if this is strictly necessary, but call the built-in reset before starting over
			IMF.ChatterHandler()
		end
	end

	function ImmersiveFunctions.Refresh(key)
		local IMF = ImmersiveFunctions
		d("Immersive Interactions -- Warning: Refresh("..key..") --- not tested. use '/reloadui' if anything unexpected happens.")

		--[[
		if key == 'bHideAll' then
			
		elseif (key == 'bHideWindow')
			
		elseif key = 'bHideTitle' then
			
		elseif key = 'bHideBodyText' then
			
		elseif key = 'bHideOptions' then
			
		elseif key = 'bHideVS' then
			
		elseif key = 'bHideTopBG' then
			
		elseif key = 'bHideBottomBG' then
			
		elseif key = 'bHideReward' then
			
		end
		--]]

		--IMF.ChatterEnd()
		--IMF.ChatterHandler()

		return false
	end


	function ImmersiveFunctions.ToggleHide(key)
		local IMF = ImmersiveFunctions

		local handles = {
			["UI"]					= { key = "bHideAll", },
			["Window"]				= { key = "bHideWindow", },
			["TargetAreaTitle"]		= { key = "bHideTitle", },
			["TargetAreaBodyText"]	= { key = "bHideBodyText", },
			["PlayerAreaOptions"]	= { key = "bHideOptions", },
			["VerticalSeparator"]	= { key = "bHideVS", },
			["WindowTopBG"]			= { key = "bHideTopBG", },
			["WindowBottomBG"]		= { key = "bHideBottomBG", },
			["RewardArea"]			= { key = "bHideReward", },
		}

		value = handles[key].key

		IMF.SetSetting(key, value)

		return IMF.Refresh(key)
	end

	function ImmersiveFunctions.ToggleOutput()
		local IMF = ImmersiveFunctions
		local MsgWindow = IMF.GetData("MsgWindow")--ImmersiveData.MsgWindow
		local state = IMF.GetSetting("bMsgWindow")

		MsgWindow:SetHidden(state)

		if state then
			ImmInt_ToggleButton:SetNormalTexture("EsoUI/Art/Cadwell/cadwell_indexIcon_gold_up.dds")
		else
			ImmInt_ToggleButton:SetNormalTexture("EsoUI/Art/Cadwell/cadwell_indexIcon_gold_down.dds")
		end

		IMF.SetSetting("bMsgWindow", not state)
	end

	function ImmersiveFunctions.HookAltTitle(control, button, upInside)
		local IMF = ImmersiveFunctions
		if button == MOUSE_BUTTON_INDEX_RIGHT then IMF.ForceShowText() end

		local a, h, x, y
		_, a, __, h, x, y = ImmInt_TitleBar:GetAnchor(0)

		IMF.SetSetting("AltTitle_point", a)
		IMF.SetSetting("AltTitle_relativePoint", h)
		IMF.SetSetting("AltTitle_posx", x)
		IMF.SetSetting("AltTitle_posy", y)
	end

	function ImmersiveFunctions.HookToggleButton(control, button, upInside)
		local IMF = ImmersiveFunctions

		local a, h, x, y
		_, a, __, h, x, y = ImmInt_ToggleButtonBg:GetAnchor(0)

		IMF.SetSetting("ToggleButton_point", a)
		IMF.SetSetting("ToggleButton_relativePoint", h)
		IMF.SetSetting("ToggleButton_posx", x)
		IMF.SetSetting("ToggleButton_posy", y)
	end

	function ImmersiveFunctions.HookMsgWindow(control, button, upInside)
		local IMF = ImmersiveFunctions

		local MsgWindow = IMF.GetData("MsgWindow")

		local a, h, x, y
		_, a, __, h, x, y = MsgWindow:GetAnchor(0)

		IMF.SetSetting("MsgWindow_point", a)
		IMF.SetSetting("MsgWindow_relativePoint", h)
		IMF.SetSetting("MsgWindow_posx", x)
		IMF.SetSetting("MsgWindow_posy", y)

		local sx, sy = MsgWindow:GetDimensions()
		IMF.SetSetting("MsgWindow_sizex", sx)
		IMF.SetSetting("MsgWindow_sizey", sy)
	end

-- ==================================================================================================== --

	function ImmersiveFunctions.ReloadUI()
		--SLASH_COMMANDS["/reloadui"]()
		ReloadUI("ingame")
		--CHAT_SYSTEM:AddMessage(tostring(IsUnitUsingVeteranDifficulty("player")))
	end

	do
		local lootFields = {
			["auto"]		= LOOT_SETTING_AUTO_LOOT,
			["stolen"]		= LOOT_SETTING_AUTO_LOOT_STOLEN,
			["area"]		= LOOT_SETTING_AOE_LOOT,
			["craft"]		= LOOT_SETTING_AUTO_ADD_TO_CRAFT_BAG,
		}

		function ImmersiveFunctions.ToggleLoot(key)
			local bState = 1 - tonumber(GetSetting(SETTING_TYPE_LOOT, lootFields[key]))
			SetSetting(SETTING_TYPE_LOOT, lootFields[key], bState)
		end
	end
end
