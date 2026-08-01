local LMP = RAEIH.LMP
local LAN = RAEIH.LAN
local uTag = "player"
local A_Sub

function RAEIH.NewSubPosition()
	if RAEIH.SavedVars.SubtitlesFirstTime == true then
		RAEIH_Subtitles:ClearAnchors()
		RAEIH_Subtitles:SetAnchor(BOTTOM, GuiRoot, BOTTOM, 0, -100)
		RAEIH.SavedVars.SubtitlesX = RAEIH_Subtitles:GetLeft()
		RAEIH.SavedVars.SubtitlesY = RAEIH_Subtitles:GetTop()
		RAEIH_Subtitles:ClearAnchors()
		RAEIH_Subtitles:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.SubtitlesX, RAEIH.SavedVars.SubtitlesY)
		RAEIH.SavedVars.SubtitlesFirstTime = false
	elseif RAEIH.SavedVars.SubtitlesFirstTime == false and RAEIH.SavedVars.SubtitlesAlignment == true then
		RAEIH_Subtitles:ClearAnchors()
		RAEIH_Subtitles:SetAnchor(TOP, GuiRoot, TOP, 0, RAEIH.SavedVars.SubtitlesY)
	end
end

function RAEIH.FadeSubtitles()
	if A_Sub == nil then
		--A_Sub = LAN:New() --P5ych3: LibAnimation has updated, outdated function call removed..
		A_Sub = LibAnimation:New() --P5ych3: Updated function call.
		A_Sub:AlphaToFrom(1, 0, RAEIH.SavedVars.SubtitlesFadeTime)
		A_Sub:Apply(RAEIH_Subtitles)
		A_Sub:Play()
	else
		A_Sub:Play()
	end
end

function RAEIH.CreateSubtitles()
	local WM = GetWindowManager()
	if RAEIH_Subtitles == nil then
		-- Shorten Variables
		local mX = RAEIH.SavedVars.SubtitlesX
		local mY = RAEIH.SavedVars.SubtitlesY
		local iW = RAEIH.SavedVars.SubtitlesIconW
		local iH = RAEIH.SavedVars.SubtitlesIconH
		if RAEIH.SavedVars.SubtitlesAlignment == false then
			-- Main Placeholder
			RAEIH_Subtitles = WM:CreateTopLevelWindow("RAEIH_Subtitles")
			RAEIH_Subtitles:SetDimensions(iW + 1000, RAEIH.SavedVars.SubtitlesFontSize * 5)
			RAEIH_Subtitles:SetClampedToScreen(true)
			RAEIH_Subtitles:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, mX, mY)
			RAEIH_Subtitles:SetMouseEnabled(true)
			RAEIH_Subtitles:SetMovable(not RAEIH.SavedVars.LockSubtitles)
			RAEIH_Subtitles:SetHandler("OnReceiveDrag", RAEIH.StartMovingSubtitles)
			RAEIH_Subtitles:SetHandler("OnMouseUp", RAEIH.StopMovingSubtitles)
			RAEIH_Subtitles:SetHidden(true)
			RAEIH.NewSubPosition()
		else
			-- Main Placeholder (Alignment Activated)
			RAEIH_Subtitles = WM:CreateTopLevelWindow("RAEIH_Subtitles")
			RAEIH_Subtitles:SetDimensions(iW + 1000, RAEIH.SavedVars.SubtitlesFontSize * 5)
			RAEIH_Subtitles:SetClampedToScreen(true)
			RAEIH_Subtitles:SetAnchor(TOP, GuiRoot, TOP, 0, mY)
			RAEIH_Subtitles:SetMouseEnabled(true)
			RAEIH_Subtitles:SetMovable(not RAEIH.SavedVars.LockSubtitles)
			RAEIH_Subtitles:SetHandler("OnReceiveDrag", RAEIH.StartMovingSubtitles)
			RAEIH_Subtitles:SetHandler("OnMouseUp", RAEIH.StopMovingSubtitles)
			RAEIH_Subtitles:SetHidden(true)
		end
		-- String
		RAEIH_Subtitles_String = WM:CreateControl("RAEIH_Subtitles_String", RAEIH_Subtitles, CT_LABEL)
		RAEIH_Subtitles_String:SetAnchorFill(RAEIH_Subtitles)
		RAEIH_Subtitles_String:SetHorizontalAlignment(1)
		RAEIH_Subtitles_String:SetVerticalAlignment(1)
	end
end

function RAEIH.SetSubtitles(eventCode, channel, npcName, message)

	local clrDft = "|c" .. RAEIH.SavedVars.SubtitlesDefaultColour
	local clrNN = "|c" .. RAEIH.SavedVars.SubtitlesNNameColour

	if RAEIH.SavedVars.ShowSubtitles == true and (channel == CHAT_CHANNEL_MONSTER_EMOTE or channel == CHAT_CHANNEL_MONSTER_SAY or channel == CHAT_CHANNEL_MONSTER_WHISPER or channel == CHAT_CHANNEL_MONSTER_YELL) then

		local newNN = zo_strformat(SI_UNIT_NAME, npcName)

		if RAEIH.SavedVars.ShowNPCName == true then
			if RAEIH.SavedVars.SubtitlesFormat == "Default" then
				RAEIH.SubtitlesText = zo_iconFormat(RAEIH.Icons.Subtitles, RAEIH.SavedVars.SubtitlesIconW, RAEIH.SavedVars.SubtitlesIconH) .. " " .. clrNN .. newNN .. clrDft .. " - " .. message
			elseif RAEIH.SavedVars.SubtitlesFormat == "Parentheses" then
				RAEIH.SubtitlesText = zo_iconFormat(RAEIH.Icons.Subtitles, RAEIH.SavedVars.SubtitlesIconW, RAEIH.SavedVars.SubtitlesIconH) .. " " .. clrDft .. "(" .. clrNN .. newNN .. clrDft .. ") " .. message
			elseif RAEIH.SavedVars.SubtitlesFormat == "Brackets" then
				RAEIH.SubtitlesText = zo_iconFormat(RAEIH.Icons.Subtitles, RAEIH.SavedVars.SubtitlesIconW, RAEIH.SavedVars.SubtitlesIconH) .. " " .. clrDft .. "[" .. clrNN .. newNN .. clrDft .. "] " .. message
			elseif RAEIH.SavedVars.SubtitlesFormat == "Slashes" then
				RAEIH.SubtitlesText = zo_iconFormat(RAEIH.Icons.Subtitles, RAEIH.SavedVars.SubtitlesIconW, RAEIH.SavedVars.SubtitlesIconH) .. " " .. clrDft .. "/" .. clrNN .. newNN .. clrDft .. "/ " .. message
			elseif RAEIH.SavedVars.SubtitlesFormat == "Hypens" then
				RAEIH.SubtitlesText = zo_iconFormat(RAEIH.Icons.Subtitles, RAEIH.SavedVars.SubtitlesIconW, RAEIH.SavedVars.SubtitlesIconH) .. " " .. clrDft .. "-" .. clrNN .. newNN .. clrDft .. "- " .. message
			elseif RAEIH.SavedVars.SubtitlesFormat == "Default Multiline" then
				RAEIH.SubtitlesText = zo_iconFormat(RAEIH.Icons.Subtitles, RAEIH.SavedVars.SubtitlesIconW, RAEIH.SavedVars.SubtitlesIconH) .. " " .. clrNN .. newNN .. clrDft .. "\n" .. message
			elseif RAEIH.SavedVars.SubtitlesFormat == "Parentheses Multiline" then
				RAEIH.SubtitlesText = zo_iconFormat(RAEIH.Icons.Subtitles, RAEIH.SavedVars.SubtitlesIconW, RAEIH.SavedVars.SubtitlesIconH) .. " " .. clrDft .. "(" .. clrNN .. newNN .. clrDft .. ")\n" .. message
			elseif RAEIH.SavedVars.SubtitlesFormat == "Brackets Multiline" then
				RAEIH.SubtitlesText = zo_iconFormat(RAEIH.Icons.Subtitles, RAEIH.SavedVars.SubtitlesIconW, RAEIH.SavedVars.SubtitlesIconH) .. " " .. clrDft .. "[" .. clrNN .. newNN .. clrDft .. "]\n" .. message
			elseif RAEIH.SavedVars.SubtitlesFormat == "Slashes Multiline" then
				RAEIH.SubtitlesText = zo_iconFormat(RAEIH.Icons.Subtitles, RAEIH.SavedVars.SubtitlesIconW, RAEIH.SavedVars.SubtitlesIconH) .. " " .. clrDft .. "/" .. clrNN .. newNN .. clrDft .. "/\n" .. message
			elseif RAEIH.SavedVars.SubtitlesFormat == "Hypens Multiline" then
				RAEIH.SubtitlesText = zo_iconFormat(RAEIH.Icons.Subtitles, RAEIH.SavedVars.SubtitlesIconW, RAEIH.SavedVars.SubtitlesIconH) .. " " .. clrDft .. "-" .. clrNN .. newNN .. clrDft .. "-\n" .. message
			end
		else
			RAEIH.SubtitlesText = zo_iconFormat(RAEIH.Icons.Subtitles, RAEIH.SavedVars.SubtitlesIconW, RAEIH.SavedVars.SubtitlesIconH) .. " " .. clrDft .. message
		end
		RAEIH_Subtitles:SetHidden(false)
		RAEIH_Subtitles_String:SetHidden(false)
		RAEIH_Subtitles_String:SetText(RAEIH.SubtitlesText)
		RAEIH_Subtitles:SetDimensions(RAEIH_Subtitles_String:GetWidth(), RAEIH.SavedVars.SubtitlesFontSize * 5)
		RAEIH_Subtitles_String:SetWrapMode(1000)

		RAEIH.NewSubPosition()
		RAEIH.FadeSubtitles()
	end
end

function RAEIH.TestSubtitles()

	local npcName = "Michebert Montieu"
	local message = "You should really go bother someone else. I have much to do, and little time to devote to trivial conversation. After all, we only get one life. No time to waste!"

	RAEIH.SetSubtitles(0, CHAT_CHANNEL_MONSTER_SAY, npcName, message)
end

function RAEIH.TestSubtitles2()

	local npcName = GetUnitName(uTag)
	local message = "Oh look! I'm testing subtitles!"

	RAEIH.SetSubtitles(0, CHAT_CHANNEL_MONSTER_SAY, npcName, message)
end

function RAEIH.OrganizeSubtitles()
	-- Shorten Variables
	local iW = RAEIH.SavedVars.SubtitlesIconW
	local iH = RAEIH.SavedVars.SubtitlesIconH
	-- Update Dimensions
	RAEIH_Subtitles:SetDimensions(iW + 1000, RAEIH.SavedVars.SubtitlesFontSize * 5)
end

function RAEIH.FormatSubtitles()

	local font = LMP:Fetch('font', RAEIH.SavedVars.SubtitlesFont)
	local size = RAEIH.SavedVars.SubtitlesFontSize
	local style = RAEIH.FontStyles[RAEIH.SavedVars.SubtitlesFontStyle]

	local fontFormat = font .. "|" .. size .. "|" .. style

	RAEIH_Subtitles_String:SetFont(fontFormat)

	if A_Sub then
		local anim = A_Sub.timeline:GetFirstAnimation()
		anim:SetDuration(RAEIH.SavedVars.SubtitlesFadeTime or RAEIH.DefaultSavedVars.SubtitlesFadeTime)
	end
end

function RAEIH.StartMovingSubtitles()
	RAEIH_Subtitles:StartMoving()
end

function RAEIH.StopMovingSubtitles()
	if RAEIH.SavedVars.SubtitlesAlignment == false then
		RAEIH_Subtitles:StopMovingOrResizing()
		RAEIH.SavedVars.SubtitlesX = RAEIH_Subtitles:GetLeft()
		RAEIH.SavedVars.SubtitlesY = RAEIH_Subtitles:GetTop()
		RAEIH_Subtitles:ClearAnchors()
		RAEIH_Subtitles:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.SubtitlesX, RAEIH.SavedVars.SubtitlesY)
	else
		RAEIH_Subtitles:StopMovingOrResizing()
		RAEIH.SavedVars.SubtitlesX = RAEIH_Subtitles:GetLeft()
		RAEIH.SavedVars.SubtitlesY = RAEIH_Subtitles:GetTop()
		RAEIH_Subtitles:ClearAnchors()
		RAEIH_Subtitles:SetAnchor(TOP, GuiRoot, TOP, 0, RAEIH.SavedVars.SubtitlesY)
	end
end