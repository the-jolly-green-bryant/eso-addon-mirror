-- ==================================================================================================== --
-- # Immersive Interactions
-- # 
-- # It's an addon for ESO. I'm not going to put a fancy license or disclaimer. Go crazy with it.
-- ==================================================================================================== --

do
	--============================================================--
	--InitializeData		()

	--StripText				(string)
	--Trim					(string)

	--Blank					()
	--ColorTab				(string)
	--ColorOpt				(string, integer)

	--SetHidden				(boolean)

	--SetupTitle			()
	--SetupAltTitle			()
	--SaveAltTitle			()
	--RefreshTitles			()

	--ResetChatter			()
	--RefreshTab			(string)

	--Colorize				(control, string)
	--ShowText				(float)
	--QueueText				()

	--CleanUpAll			()
	--============================================================--

	function ImmersiveFunctions.InitializeData()	ImmersiveData.bNotChattering = true		end
	
	function ImmersiveFunctions.StripText(str)		return str:gsub("|c%x%x%x%x%x%x", "")	end --[[ from zo_addonmanager.lua ]]--

	function ImmersiveFunctions.Trim(str)			return str:gsub("^%s*(.-)%s*$", "%1")	end

	function ImmersiveFunctions.Blank()
		local ctab		= ImmersiveData.handles["TargetAreaBodyText"]
		local numLines	= math.ceil(ctab:GetTextHeight() / ctab:GetFontHeight())

		if ImmersiveFunctions.Debug("body") then
			d("numLines = "..tostring(numLines))
		end

		local text = ""
		for i = 1, numLines do text = text.."\n" end

		return text
	end

	--[[
		parameters:
			ct = color variable to use, which are stored as ct.."R", ct.."G", ct.."B", ct.."A" in settings
			str = string to copy and return color version
	]]--
	function ImmersiveFunctions.Colorize(ct, str)
		local GetSetting = ImmersiveFunctions.GetSetting

		local color = ZO_ColorDef:New()
		color:SetRGBA(GetSetting(ct.."R"), GetSetting(ct.."G"), GetSetting(ct.."B"), GetSetting(ct.."A"))

		-- strip any previous color codes in the text
		return color:Colorize(ImmersiveFunctions.StripText(tostring(str)))
	end

	function ImmersiveFunctions.ColorTab(tabText)
		return ImmersiveFunctions.Colorize("tab", tabText)
	end

	function ImmersiveFunctions.ColorOpt(option, index)
		local enabled = false

		if option.enabled then
			enabled = true
		end

		local opText = option:GetText()

		return ImmersiveFunctions.ColorOpt_text(opText, index, enabled)
	end

	function ImmersiveFunctions.ColorOpt_text(opText, index, enabled)
		local GetSetting	= ImmersiveFunctions.GetSetting
		local fcolor		= ImmersiveFunctions.Colorize

		local prefix = fcolor("opn", index)..fcolor("opp", GetSetting("szDivider"))

		if #opText >= #prefix and opText:sub(1,#prefix) == prefix then
			return opText -- already colorized
			--opText = opText:sub(#prefix+2, #opText) -- remove prefix number and divider, also get rid of the space after the divider
		end

		if enabled and GetSetting("bHighlight") then
		-- highlight [Lie], [Persuade] etc.
			local texSpc = opText:match('(%[.-%])')
			if texSpc and opText:sub(1,1) == '[' then
				opText = tostring(fcolor("spc", texSpc))..tostring(fcolor("opt", opText:sub(#texSpc+1, #opText)))
			else
				opText = fcolor("opt", opText)
			end
		else
			opText = fcolor("opt", opText)
		end

		if GetSetting("bAddNums") then
			opText = prefix.." "..opText
		end

		return opText
	end

	function ImmersiveFunctions.SetHidden(bState)
		if ImmersiveFunctions.IsInvalid() then return end

		if bState then
			ImmersiveData.handles["TargetAreaBodyText"]:SetText(ImmersiveData.blankBodyText)
		else
			ImmersiveData.handles["TargetAreaBodyText"]:SetText(ImmersiveData.colorBodyText)
		end

		local GetSetting = ImmersiveFunctions.GetSetting
		if GetSetting("bHideUI") then
			if bState and ImmersiveData.uiHidden then
				-- ui is hidden already
			elseif bState or ImmersiveData.uiHidden then
				-- need to hide and ui is visible, or need to show and ui is hidden
				ImmersiveData.uiHidden = not ImmersiveData.uiHidden
				ToggleShowIngameGui()
			-- else would be both bState and uiHidden are false, which means the ui is visible and meant to be so
				-- unhide ui if bState is false and ui is hidden
			end
		end

		for k, v in pairs(ImmersiveData.states) do
			if GetSetting(k) then ImmersiveData.handles[v]:SetHidden(bState) end
		end

		if GetSetting("bHideReward") then do
			-- these must be handled separately from the other sections,
			-- or else invalid rewards during non-reward interactions when restoring visibility
			local RA		= ImmersiveData.handles["RewardArea"]
			local RH		= ImmersiveData.handles["RewardAreaHeader"]
			local showRA	= ImmersiveData.bShowRewardArea

			--d(showRA)
			--d(RA:IsHidden())
			if bState then
				-- hide is true, check if RA is hidden
				if not RA:IsHidden() then
					showRA = true
					RA:SetHidden(showRA)
					RH:SetHidden(showRA)
				end
			elseif showRA then
				-- hide is false, and showRA is true, so restore the reward area
				showRA = false
				RA:SetHidden(showRA)
				RH:SetHidden(showRA)
			end

			ImmersiveData.bShowRewardArea = showRA
		end end
	end

	function ImmersiveFunctions.SetupTitle()
		local titleFormat

		if ImmersiveFunctions.GetSetting("bTrimDashes") then
			titleFormat = ''
		else
			titleFormat = '-'
		end

		ImmersiveData.title = titleFormat..GetUnitName("interact")..titleFormat
	end

	function ImmersiveFunctions.SetupAltTitle()
		local GetSetting = ImmersiveFunctions.GetSetting

		local bState = GetSetting("bAltTitle")
		if not bState then return end

		local itb		= ImmInt_TitleBar
		local itbL		= ImmInt_TitleBarLabel

		local size = #GetUnitName("interact")

		local IMF = ImmersiveFunctions

		if IMF.Debug("alt") then
			d("size: "..tostring(size))
		end

		local font = IMF.GetFont("alt")
		if IMF.Debug("alt") then
			d(font)
		end

		local width = IMF.GetWidth("alt", size)
		if size > 24 then
			itb:SetWidth(width+12)
			itbL:SetWidth(width)
		else
			itb:SetWidth(524)
			itbL:SetWidth(512)
		end -- if the name is really long, then the nameplate needs to expand

		if IMF.Debug("alt") then
			d("itb:GetWidth(): "..tostring(itb:GetWidth()))
			d("itbL:GetWidth(): "..tostring(itbL:GetWidth()))
		end
		itbL:SetText(IMF.Colorize("alt", ImmersiveData.title))
		itbL:SetFont(IMF.GetFont("alt"))

		itb:ClearAnchors()
		itb:SetAnchor(GetSetting("AltTitle_point"), itb:GetParent(), GetSetting("AltTitle_relativePoint"), GetSetting("AltTitle_posx"), GetSetting("AltTitle_posy"))

		itb:SetHidden(not bState)
		itb:SetMouseEnabled(bState)

		-- todo add a clause to hide it during dialog but appear with everything else
	end

	function ImmersiveFunctions.SaveAltTitle()
		local GetSetting = ImmersiveFunctions.GetSetting
		local SetSetting = ImmersiveFunctions.SetSetting

		--if ImmersiveFunctions.Debug("alt") then
			--d("SaveAltTitle():: alta = "..tostring(GetSetting("alta"))..", alth = "..tostring(GetSetting("alth"))..", altx = "..tostring(GetSetting("altx"))..", alty = "..tostring(GetSetting("alty")))
		--end

		local bState = GetSetting("bAltTitle")
		if not bState then return end

		local itb = ImmInt_TitleBar
		local _, a, __, h, x, y = itb:GetAnchor(0)

		SetSetting("AltTitle_point", a)
		SetSetting("AltTitle_relativePoint", h)
		SetSetting("AltTitle_posx", x)
		SetSetting("AltTitle_posy", y)


		ImmInt_TitleBarLabel:SetText("")
		itb:SetHidden(true)
	end

	---[[
	function ImmersiveFunctions.SaveToggleButton()
		local GetSetting = ImmersiveFunctions.GetSetting
		local SetSetting = ImmersiveFunctions.SetSetting

		local bState = GetSetting("bToggleButton")
		if not bState then return end

		local itb = ImmInt_ToggleButtonBg
		local _, a, __, h, x, y = itb:GetAnchor(0)

		SetSetting("ToggleButton_point", a)
		SetSetting("ToggleButton_relativePoint", h)
		SetSetting("ToggleButton_posx", x)
		SetSetting("ToggleButton_posy", y)
	end

	function ImmersiveFunctions.SaveMsgWindow()
		local GetSetting = ImmersiveFunctions.GetSetting
		local SetSetting = ImmersiveFunctions.SetSetting

		local bState = GetSetting("bMsgWindow")
		if not bState then return end

		local itb = ImmersiveData.MsgWindow
		local _, a, __, h, x, y = itb:GetAnchor(0)

		SetSetting("MsgWindow_point", a)
		SetSetting("MsgWindow_relativePoint", h)
		SetSetting("MsgWindow_posx", x)
		SetSetting("MsgWindow_posy", y)
	end
	--]]

	function ImmersiveFunctions.RefreshTitles()
		ImmersiveFunctions.SetupTitle()
		ImmersiveFunctions.SetupAltTitle()
	end

	function ImmersiveFunctions.ResetChatter()
		ImmersiveFunctions.SetHidden(false)
	end

	function ImmersiveFunctions.RefreshTab(text)
		if ImmersiveData.bodyText ~= text then
			ImmersiveFunctions.ResetChatter()
			ImmersiveData.handles["TargetAreaBodyText"]:SetText(text)
			ImmersiveFunctions.ParseStage()
		end
	end

	-- compare time queued to time latest text saved in ImmersiveData.iTime, ignore mismatches as dirty calls
	-- incase the player is clicking ahead/replaying audio/etc and wait for updated text via zo_callLater
	function ImmersiveFunctions.ShowText(queueTime)
		if ImmersiveFunctions.IsInvalid() then return end

		if queueTime == ImmersiveData.iTime and queueTime >= 0 then
			ImmersiveData.handles["TargetAreaBodyText"]:SetText(ImmersiveData.colorBodyText)
			ImmersiveFunctions.ResetChatter()
		end
	end

	-- prepare the dialog text for the queue
	function ImmersiveFunctions.QueueText()
		local iDelay	= #ImmersiveData.bodyText * ImmersiveFunctions.GetSetting("iOffsetMS") -- note #string is the string length
		local qTime		= ImmersiveData.iTime

		zo_callLater(function() ImmersiveFunctions.ShowText(qTime) end, iDelay)
	end

	function ImmersiveFunctions.CleanUpAll()
		--ResetChatter()
		--ResetChat()

		local ctat = ImmersiveData.handles["TargetAreaTitle"]
		ctat:SetText('-'..GetUnitName("interact")..'-')
		ctat:SetMouseEnabled(false)

		do
			-- restore default fonts
			local LMP = LibMediaProvider

			ImmersiveData.handles["TargetAreaTitle"]:SetFont(("%s|%s|%s"):format(LMP:Fetch('font', "Univers 67"), 28, "soft-shadow-thick"))
			ImmersiveData.handles["TargetAreaBodyText"]:SetFont(("%s|%s|%s"):format(LMP:Fetch('font', "Univers 67"), 24, "soft-shadow-thick"))

			local hpao = ImmersiveData.handles["PlayerAreaOptions"]
			for i = 1, hpao:GetNumChildren() do
				local op = hpao:GetChild(i)
				--op:SetText(ImmersiveData.opt[i])
				op.optionType = nil
				op:SetText("")
				op:SetFont(("%s|%s|%s"):format(LMP:Fetch('font', "Univers 67"), 22, "soft-shadow-thick"))
			end
		end

		ImmersiveData.ctrls["audioReplay"]:SetHidden(true)

		if ImmersiveData.uiHidden then
			ImmersiveData.uiHidden = false
			ToggleShowIngameGui()
		end

		-- restore defaults
		--[[
		local csa = CENTER_SCREEN_ANNOUNCE
		if not csaStates then return end
		for i = 1, #csaTypes do
			if csaStates[i] then
				--csa:ResumeAnnouncementByType(csaTypes[i])
				--d("csaTypes["..i.."]: "..tostring(csaTypes[i]))
			end
		end
		csaStates = nil
		--]]

		ImmersiveFunctions.ResetChatter()
	end

	function ImmersiveFunctions.RestoreDefaultData()
		ImmersiveData.bService		= false
		ImmersiveData.iTime			= -1

		ImmersiveData.opt			= nil
		ImmersiveData.opt			= { }

		ImmersiveData.controls		= nil
		ImmersiveData.controls		= { }
	end

	-- find the array index for convo terminating option
	-- would prefer a more robust, universal way, but was having issue with invalid options lingering after the good-bye
	function ImmersiveFunctions.GetNumOptions(options)
		for i = 1, #options do
			if string.find(options[i], "Nevermind.") or string.find(options[i], "Never mind.")
			or string.find(options[i], "Farewell.") or string.find(options[i], "Fare well.")
			or string.find(options[i], "Goodbye.") then return i end
		end

		return #options
	end
end
