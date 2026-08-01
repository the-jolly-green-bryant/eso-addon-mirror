-- ==================================================================================================== --
-- # Immersive Interactions
-- # 
-- # It's an addon for ESO. I'm not going to put a fancy license or disclaimer. Go crazy with it.
-- ==================================================================================================== --

do
	function ImmersiveFunctions.RegisterHandlers()
		local IMF	= ImmersiveFunctions
		local em	= EVENT_MANAGER
		local ns	= "ImmersiveInteractions"

		em:RegisterForEvent(ns, EVENT_CHATTER_BEGIN, IMF.ChatterHandler)
		em:RegisterForEvent(ns, EVENT_CONVERSATION_UPDATED, IMF.ChatterHandler)
		em:RegisterForEvent(ns, EVENT_QUEST_OFFERED, IMF.ChatterHandler)
		em:RegisterForEvent(ns, EVENT_QUEST_COMPLETE_DIALOG, IMF.ChatterHandler)
		em:RegisterForEvent(ns, EVENT_CHATTER_END, IMF.ChatterEnd)
	end

	function ImmersiveFunctions.InitGameMode()
		local IMF	= ImmersiveFunctions
		--local IMD = ImmersiveData

		if IsInGamepadPreferredMode() then
			--ImmersiveData.handles = ImmersiveData.handlesGP
			--ImmersiveData.states = ImmersiveData.statesGP
			IMF.SetDataArray("handles", nil, IMF.GetData("handlesGP"))
		else
			--ImmersiveData.handles = ImmersiveData.handlesKB
			--ImmersiveData.states = ImmersiveData.statesKB
			IMF.SetDataArray("handles", nil, IMF.GetData("handlesKB"))
		end

		local wm = WINDOW_MANAGER
		ImmersiveData.ctrls["audioReplay"] = wm:CreateControl(nil, ImmersiveData.handles["TargetAreaTitle"], CT_TEXTURE)
	end

	function ImmersiveFunctions.InitXML()
		local IMF = ImmersiveFunctions
		local LIBMW	= LibMsgWin

		ImmersiveData.MsgWindow = LIBMW:CreateMsgWindow(IMF.GetSetting("szMsgWindowHandle"), IMF.GetSetting("szMsgWindowLabel"), IMF.GetSetting("iFadeDelay"), IMF.GetSetting("iFadeDuration"))
		local MsgWindow = ImmersiveData.MsgWindow

		MsgWindow:SetHidden(true)
		ImmInt_ToggleButtonBg:SetHidden(true)
		ImmInt_ToggleButton:SetHidden(true)

		MsgWindow:ClearAnchors()
		MsgWindow:SetDimensions(IMF.GetSetting("MsgWindow_sizex"), IMF.GetSetting("MsgWindow_sizey"))
		MsgWindow:SetAnchor(IMF.GetSetting("MsgWindow_point"), GuiRoot, IMF.GetSetting("MsgWindow_relativePoint"), IMF.GetSetting("MsgWindow_posx"), IMF.GetSetting("MsgWindow_posy"))

		ImmInt_ToggleButtonBg:ClearAnchors()
		ImmInt_ToggleButton:ClearAnchors()

		ImmInt_ToggleButtonBg:SetAnchor(IMF.GetSetting("ToggleButton_point"), GuiRoot, IMF.GetSetting("ToggleButton_relativePoint"), IMF.GetSetting("ToggleButton_posx"), IMF.GetSetting("ToggleButton_posy"))
		ImmInt_ToggleButton:SetAnchor(CENTER, ImmInt_ToggleButtonBg, CENTER)

		
		if not IsInGamepadPreferredMode() then
			MsgWindow:SetHidden(not IMF.GetSetting("bMsgWindow"))
			ImmInt_ToggleButtonBg:SetHidden(not IMF.GetSetting("bToggleButton"))
			ImmInt_ToggleButton:SetHidden(not IMF.GetSetting("bToggleButton"))
		end

		if MsgWindow:IsHidden() then
			ImmInt_ToggleButton:SetNormalTexture("EsoUI/Art/Cadwell/cadwell_indexIcon_gold_up.dds")
		else
			ImmInt_ToggleButton:SetNormalTexture("EsoUI/Art/Cadwell/cadwell_indexIcon_gold_down.dds")
		end

		ZO_PreHookHandler(ImmInt_TitleBar, "OnMouseUp", IMF.HookAltTitle)
		ZO_PreHookHandler(ImmInt_ToggleButtonBg, "OnMouseUp", IMF.HookToggleButton)
		MsgWindow:SetHandler("OnMouseUp", IMF.HookMsgWindow)
	end

	function ImmersiveFunctions.InitBindings()
		ZO_CreateStringId("SI_BINDING_NAME_MDR_FORCE_SHOW",				"Immediately Show Dialog")
		ZO_CreateStringId("SI_BINDING_NAME_MDR_REPLAY_AUDIO",			"Replay Audio Now")
		ZO_CreateStringId("SI_BINDING_NAME_MDR_TOGGLE_HIDE",			"Show/Hide All UI in Dialog")
		ZO_CreateStringId("SI_BINDING_NAME_MDR_TOGGLE_WINDOW",			"Show/Hide Addons in Dialog")
		ZO_CreateStringId("SI_BINDING_NAME_MDR_TOGGLE_MSGWINDOW",		"Show/Hide Dialog Output")

		ZO_CreateStringId("SI_BINDING_NAME_MDR_TOGGLE_TA_TITLE",		"Toggle Title")
		ZO_CreateStringId("SI_BINDING_NAME_MDR_TOGGLE_TA_BODY_TEXT",	"Toggle Body")
		ZO_CreateStringId("SI_BINDING_NAME_MDR_TOGGLE_PA_OPTIONS",		"Toggle Options")
		ZO_CreateStringId("SI_BINDING_NAME_MDR_TOGGLE_PA_ICONS",		"Toggle Icons")
		ZO_CreateStringId("SI_BINDING_NAME_MDR_TOGGLE_VS_SEPARATOR",	"Toggle Vertical")
		ZO_CreateStringId("SI_BINDING_NAME_MDR_TOGGLE_TOP_BG",			"Toggle TopBG")
		ZO_CreateStringId("SI_BINDING_NAME_MDR_TOGGLE_BOTTOM_BG",		"Toggle BottomBG")
		ZO_CreateStringId("SI_BINDING_NAME_MDR_TOGGLE_REWARD_AREA",		"Toggle Reward")

		ZO_CreateStringId("SI_BINDING_NAME_MDR_REFRESH_ALL",			"Refresh All")
		ZO_CreateStringId("SI_BINDING_NAME_MDR_REFRESH_TA_TITLE",		"Refresh Title")
		ZO_CreateStringId("SI_BINDING_NAME_MDR_REFRESH_TA_BODY_TEXT",	"Refresh Body")
		ZO_CreateStringId("SI_BINDING_NAME_MDR_REFRESH_PA_OPTIONS",		"Refresh Options")
		ZO_CreateStringId("SI_BINDING_NAME_MDR_REFRESH_PA_ICONS",		"Refresh Icons ")

		-- by request, rebind all response bindings
		ZO_CreateStringId("SI_BINDING_NAME_MDR_SELECT_OPT_DEFAULT",		"Response - Default")
		ZO_CreateStringId("SI_BINDING_NAME_MDR_SELECT_OPT_GOODBYE",		"Response - Goodbye")
		ZO_CreateStringId("SI_BINDING_NAME_MDR_SELECT_OPT_1",			"Response - Option 1")
		ZO_CreateStringId("SI_BINDING_NAME_MDR_SELECT_OPT_2",			"Response - Option 2")
		ZO_CreateStringId("SI_BINDING_NAME_MDR_SELECT_OPT_3",			"Response - Option 3")
		ZO_CreateStringId("SI_BINDING_NAME_MDR_SELECT_OPT_4",			"Response - Option 4")
		ZO_CreateStringId("SI_BINDING_NAME_MDR_SELECT_OPT_5",			"Response - Option 5")
		ZO_CreateStringId("SI_BINDING_NAME_MDR_SELECT_OPT_6",			"Response - Option 6")
		ZO_CreateStringId("SI_BINDING_NAME_MDR_SELECT_OPT_7",			"Response - Option 7")
		ZO_CreateStringId("SI_BINDING_NAME_MDR_SELECT_OPT_8",			"Response - Option 8")
		ZO_CreateStringId("SI_BINDING_NAME_MDR_SELECT_OPT_9",			"Response - Option 9")
		ZO_CreateStringId("SI_BINDING_NAME_MDR_SELECT_OPT_10",			"Response - Option 10")

		-- misc keybinds I like to use

		--ZO_CreateStringId("SI_BINDING_NAME_MDR_TOGGLE_HELM",			"Toggle Hide Helm) -- broken due to this now being an option in collections appearance
		ZO_CreateStringId("SI_BINDING_NAME_MDR_TOGGLE_AUTO_LOOT",		"Toggle Auto Loot")
		ZO_CreateStringId("SI_BINDING_NAME_MDR_TOGGLE_AREA_LOOT",		"Toggle Consolidate Area Loot")
		ZO_CreateStringId("SI_BINDING_NAME_MDR_RELOAD_UI",				"Reload UI")
	end
end
