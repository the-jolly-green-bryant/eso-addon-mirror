NTDial = {}
local NTakDialog = NTDial
local ADDON_NAME = "NTakDialog"
local texts	= NTDial_Texts


------------------------------------------
--		UTILITY FUNCTIONS

local function debug(str, force)
	if not(NTakDialog.settings.debug) and not(force) then return end
	if str == nil then str = "nil" end
	d("NTak Dialog: " .. str)
end
local function ReverseArray(array)
	local reversed = {}
	for k,v in pairs(values) do
   		reversed[v]=k
	end
	return reversed
end
local function NumbersClose(num1, num2)
	local diff = math.abs(num1 - num2)
	return (diff < 0.005)
end
local function TableToString(tbl, keyON, valON, sep)
    local result = ""
    for k, v in pairs(tbl) do
        -- Check the key type
        if keyON then
			if type(k) == "string" then
				result = result .. "[\"" .. k .. "\"]" .. "="
			end
		end

        -- Check the value type
		if valON then
			if type(v) == "table" then
				result = result .. TableToString(v, keyON, valON, sep)
			elseif type(v) == "boolean" then
				result = result .. tostring(v)
			else
				result = result .. v
			end
		end
        result = result .. sep
    end
    return result
end
local function BoolToNum(bool)
	return bool and 1 or 0
end
local function CopyTree(elm)
    local copy
    if type(elm) == 'table' then
		-- Copy object by iterating into it
        copy = {}
        for key, val in next, elm, nil do
            copy[CopyTree(key)] = CopyTree(val)
        end
        setmetatable(copy, CopyTree(getmetatable(elm)))
    else
		-- Not a table, simple copy
        copy = elm
    end
    return copy
end
local function GetCharAt(t, i)
	local by = string.byte(t, i)
	if by == nil then return "", 0, 0 end
	local l = 0
	if		by > 240 then l = 3
	elseif	by > 225 then l = 2
	elseif	by > 192 then l = 1
	end
	return string.sub(t, i, i + l), l + 1, by
end
local function TextPad(pad)
	return "|u" .. pad .. ":::|u"
end
local function TextIcon(path, size, pad)
	--	Prevent nil
	if size == nil then size = 32 end
	--	Format path
	path = "/esoui/" .. path
	--	Format icon with size
	local icon = "|t" .. size .. ":" .. size .. ":" .. path .. "|t"
	--	Add padding
	if pad	~= nil then
		icon = TextPad(pad) .. icon .. TextPad(pad)
    end
	--	Result
    return icon
end
local function TextSpacePredict(text, start, spacesToHit)
	--	Add some “space prediction” to prevent line jump during the fading animation
	local strSpaces	= ""
	local offset	= start - 2
	local nbSpaces	= 0
	local space		= ""
	for i = -2, 16 do
		local chr, off, code = GetCharAt(text, offset)
		offset	= offset + off
		if i > 0 and chr ~= "" then
			if chr == " " then
				nbSpaces = nbSpaces + 1
				if nbSpaces > spacesToHit then break end -- Don't break on first space
				space = " "
			elseif chr == " " then
				space = " "
			elseif chr == "I" or chr == "i" or chr == "j" or chr == "l" or chr == "t" or chr == "r" then
				space = " "
			elseif chr == "." or chr == "!" or chr == "?" or chr == "," or chr == ";" then
				space = "  "
			elseif chr == "-" then
				space = " "
			elseif chr == "m" then
				space = "   "
			elseif code >= 65 and code <= 90 then -- CAPS
				space = "   "
			else
				space = "  "
			end
			strSpaces = strSpaces .. space
		end
	end
	-- strSpaces = strSpaces .. " <" -- DEBUG
	return strSpaces
end
local function TextColorHEX(text, color) -- NOT USED
	return "|c" .. color .. text .. "|r"
end
local function TextColorRGBS(t, r, g, b, s)
	--	Calculate rgb with "saturation"
	r = zo_min(255 * (s * r))
	g = zo_min(255 * (s * g))
	b = zo_min(255 * (s * b))
	--	Format
	return string.format("|c%02x%02x%02x%s|r", r, g, b, t)
end
local function CustomFont(style, size, weight)
    return string.format("$(%s)|$(KB_%s)|%s", style, size, weight)
end
local function FadeIn(elm, a, t, steps) -- NOT USED
	--	Prevent nil
    if steps == nil then steps = 10 end
    if a 	 == nil then a = 1		end
    if t	 == nil then t = 1000	end
	--	Calculate steps
    local aStep = a / steps
    local tStep = t	/ steps
    --	Loop
    for i = 0, steps do
		zo_callLater(function()
			elm:SetAlpha(i * aStep)
        end, i * tStep)
    end
end
local function IsDescription(text)
	--	Check if description
	local first = GetCharAt(text, 1)
	-- local last = GetCharAt(text, -1)
	return (
		first == "<" or	-- Description markup
		first == '"' or	-- American quotes
		first == '“' or	-- English quotes
		first == '«' or	-- French quotes
		first == '„' or	-- German quotes 
		first == '»'	-- German quotes
	)
end

--	The below method is interesting, but not using it as I don't want to alter the game style.
-- local fontSize = 12
-- local fontStyle = "MEDIUM_FONT"         -- or "BOLD_FONT"
-- local fontWeight = "soft-shadow-thin"   -- or "soft-shadow-thick", or... see list below
-- local nameFont = string.format("$(BOLD_FONT)|$(KB_%s)|%s", fontStyle, fontSize, fontWeight)
-- local myFont = "$(BOLD_FONT)|$(KB_28)|soft-shadow-thick"

--	Fonts
-- local fontsStyles = {
	-- "MEDIUM_FONT", "BOLD_FONT", "CHAT_FONT",
    -- "GAMEPAD_LIGHT_FONT", "GAMEPAD_MEDIUM_FONT", "GAMEPAD_BOLD_FONT",
    -- "ANTIQUE_FONT", "HANDWRITTEN_FONT", "STONE_TABLET_FONT"
-- }
-- local fontsWeights = { "shadow", "soft-shadow-thin", "soft-shadow-thick", "thick-outline", }


------------------------------------------
--		INITIALISATIONS

--	Some things from localizations
local dontDisplay	= texts.dontDisplay

--	Some UI constants and initializations
local xWINDOWDIV	= ZO_InteractWindowDivider
local xSEPARATOR	= ZO_InteractWindowVerticalSeparator
local xTOPBG		= ZO_InteractWindowTopBG
local xBOTTOMBG		= ZO_InteractWindowBottomBG
local xTITLE		= ZO_InteractWindowTargetAreaTitle
local xBODY			= ZO_InteractWindowTargetAreaBodyText
local xOPTIONS		= ZO_InteractWindowPlayerAreaOptions
local xHIGHLIGHT	= ZO_InteractWindowPlayerAreaHighlight
local xHLTOP		= ZO_InteractWindowPlayerAreaHighlightTop
local xHLBOT		= ZO_InteractWindowPlayerAreaHighlightBottom
local xREWARD		= ZO_InteractWindowCollapseContainerRewardArea -- Old: ZO_InteractWindowRewardArea
-- local xREWARDHEADER	= ZO_InteractWindowRewardAreaHeader	-- NOT USED
local xTALIGNs 		= { TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, TEXT_ALIGN_RIGHT }
local fontZero		= CustomFont("CHAT_FONT", -99, "soft-shadow-thin")
local fontsSizes	= {
	"ZoFontHeader",						-- 18
	"ZoFontConversationQuestReward",	-- 20
	"ZoFontConversationOption",			-- 22, Regular Option
	"ZoFontConversationText",			-- 24, Regular Text
	"ZoFontConversationName",			-- 28, Regular Title
	-- "ZoFontWindowTitle",				-- 30
	"ZoFontCallout",					-- 36
	"ZoFontCallout2",					-- 48
}


--	Icons for all chatter option types
local icons = {
	["Chat"]		= TextIcon('art/chatwindow/chat_notification_up.dds',			32),
	["Quest"] 		= TextIcon('art/inventory/inventory_tabicon_quest_up.dds',		32),
	["Cross"] 		= TextIcon('art/buttons/decline_up.dds',						32 - 6, 3),
	["Tick"]		= TextIcon('art/buttons/accept_up.dds',							32 - 6, 3),
    --	Companion, bank, stores
	["Head"]		= TextIcon('art/contacts/social_status_highlight.dds',			32),
	["Money"] 		= TextIcon('art/bank/bank_tabicon_gold_up.dds',					32),
	["Store"]		= TextIcon('art/guild/guildhistory_indexicon_guildstore_up.dds',32),
	["Bank"]		= TextIcon('art/tooltips/icon_bank.dds',						32 - 8, 4),
	["Guild"]		= TextIcon('art/guild/guildhistory_indexicon_guildbank_up.dds',	32),
	["Mount"] 		= TextIcon('art/mounts/tabicon_mounts_up.dds',					32),
    --	Skills
	["Thieves"]		= TextIcon('art/vendor/vendor_tabicon_fence_up.dds',			32),
	["Fighters"]	= TextIcon('art/icons/progression_tabicon_fightersguild_up.dds',32),
	["Mages"]		= TextIcon('art/icons/progression_tabicon_magesguild_up.dds',	32),
	--	Repeat
	["Refresh"]		= TextIcon('art/help/help_tabicon_feedback_up.dds',				32),
    -- ["Audio"]		= TextIcon('art/charactercreate/charactercreate_audio_up.dds',	32),
	["Craft"]		= TextIcon('art/tutorial/inventory_tabicon_crafting_up.dds',	32),
}
NTakDialog.iconsTooltip = TableToString(icons, false, true, "")
--	Some more icons for use in settings UI
icons["Text"]		= TextIcon('art/guild/tabicon_roster_up.dds',					32)
icons["History"]	= TextIcon('art/tutorial/guild-tabicon_history_up.dds',			32)
icons["Title"]		= TextIcon('art/tutorial/menubar_character_up.dds',				32)
icons["Specific"]	= TextIcon('art/chatwindow/chat_friendsonline_up.dds',			32)
icons["Options"]	= TextIcon('art/worldmap/map_indexicon_locations_up.dds',		32)
icons["Hover"]		= TextIcon('art/worldmap/map_indexicon_locations_down.dds',		32)
NTakDialog.icons	= icons
--	Bind to option types
local chatIcons32 = {
	--	Generic
	[CHATTER_GENERIC_ACCEPT]										= icons["Tick"],		--    42
	[CHATTER_COMPLETE_QUEST]										= icons["Tick"],		--    43
	[CHATTER_START_TALK]											= icons["Chat"],		--   100
	[CHATTER_TALK_CHOICE]											= icons["Chat"], 		--   101 not working anymore ?
	[101]															= icons["Chat"], 		--   101
	["CHATTER_REPEAT"]												= icons["Refresh"],		--Custom
	[CHATTER_GOODBYE]												= icons["Cross"],		-- 10000
	--	Special choices
	[CHATTER_TALK_CHOICE_MONEY] 									= icons["Money"],		--   102
	[CHATTER_TALK_CHOICE_INTIMIDATE_DISABLED]						= icons["Cross"],		--   103
	[CHATTER_TALK_CHOICE_PERSUADE_DISABLED]							= icons["Cross"],		--   104
	[SI_CONVERSATION_OPTION_SPEECHCRAFT_INTIMIDATE]					= icons["Fighters"],	--  6356
	[SI_CONVERSATION_OPTION_SPEECHCRAFT_PERSUADE]					= icons["Mages"],		--  6357
	--	Under arrest
	[CHATTER_TALK_CHOICE_PAY_BOUNTY]								= icons["Money"],		--   105
	[CHATTER_TALK_CHOICE_USE_CLEMENCY]								= icons["Thieves"],		--   106
	[CHATTER_TALK_CHOICE_CLEMENCY_DISABLED]							= icons["Cross"],		--   107
	[CHATTER_TALK_CHOICE_CLEMENCY_COOLDOWN]							= icons["Cross"],		--   108
	[CHATTER_TALK_CHOICE_USE_SHADOWY_CONNECTIONS]					= icons["Thieves"],		--   109
	[CHATTER_TALK_CHOICE_SHADOWY_CONNECTIONS_UNAVAILABLE]			= icons["Cross"],		--   110
	[CHATTER_START_PAY_BOUNTY]										= icons["Money"],		--   500
	[SI_CONVERSATION_OPTION_SPEECHCRAFT_CLEMENCY]					= icons["Thieves"],		--  6358
	[CHATTER_START_USE_CLEMENCY]									= icons["Thieves"],		--  4400
	[CHATTER_START_USE_SHADOWY_CONNECTIONS]							= icons["Thieves"],		--  4500
	--	Quests
	[CHATTER_START_NEW_QUEST_BESTOWAL]								= icons["Quest"],		--   200
	[CHATTER_START_COMPLETE_QUEST]									= icons["Tick"],		--   300
	[CHATTER_START_GIVE_ITEM]										= icons["Quest"],		--   400
	[CHATTER_START_ADVANCE_COMPLETABLE_QUEST_CONDITIONS]			= icons["Quest"],		--  4000
	--	Cyrodill
	[CHATTER_START_KEEP]											= icons["Quest"],		--	2000
	[CHATTER_START_KEEP_GUILD_CLAIM]								= icons["Tick"],		--	2600
	--	Stores and banks
	[CHATTER_TALK_CHOICE_BEGIN_SKILL_RESPEC]						= icons["Store"],		--   111
	[CHATTER_TALK_CHOICE_ATTRIBUTE_RESPEC]							= icons["Store"],		--   112
	[CHATTER_START_SHOP]											= icons["Store"],		--   600
	[CHATTER_START_BANK]											= icons["Bank"],		--  1200
	[CHATTER_START_BUY_BAG_SPACE]									= icons["Store"],		--  1600
	[CHATTER_PROMPT_BUY_BAG_SPACE]									= icons["Store"],		--  1601
	[CHATTER_START_CRAFT]											= icons["Craft"],		--	2900
	[CHATTER_START_STABLE]											= icons["Mount"],		--  3100
	[CHATTER_START_GUILDBANK]										= icons["Guild"],		--  3300
	[CHATTER_START_TRADINGHOUSE]									= icons["Store"],		--  3400
	[CHATTER_START_GUILDKIOSK_BID]									= icons["Money"],		--	3800
	[CHATTER_START_GUILDKIOSK_PURCHASE]								= icons["Store"],		--	3900
	--	Companions
	[4770]															= icons["Head"],		--	4770
	[4780]															= icons["Head"],		--	4780
}


------------------------------------------
--		MAIN FUNCTIONS


--	WINDOW

local uiWidth, uiHeight
local winWidth, winHeight
local windowFullWidth, winVposBase, winVpos
local windowMarginLeft		= 10 -- px
local windowBorderLeft		= 2  -- px
local windowPaddingLeft		= 10 -- px
local windowPaddingRight	= 30 -- px
local optionMarginLeft		= 30 -- px
local optionMarginRight		= 30 -- px
local backgroundHeight 		= 120 -- px -- default value
function ZO_Interaction:OnScreenResized()
	--	Escape if not initialized
	if NTakDialog == nil then return end
	if NTakDialog == {} then return end
	
	--	Get dimensions
	uiWidth, uiHeight	= GuiRoot:GetDimensions()
	if uiWidth == nil then return end
	
	winWidth, winHeight	= xWINDOWDIV:GetDimensions()
	windowFullWidth		= uiWidth * NTakDialog.settings.windowWidth
	
	--	Manage vertical offset	
	winVposBase = 1 - BoolToNum(NTakDialog.settings.windowCenterize) / 2
	winVpos		= uiHeight * (winVposBase + NTakDialog.settings.windowVerticalPosition) / 2
	
	--	Use custom or default padding values
	if NTakDialog.settings.windowPaddings then
		if NTakDialog.settings.windowResize and NTakDialog.settings.windowPaddingAuto then
			windowPaddingRight	= windowFullWidth * 0.1
			windowPaddingLeft	= windowPaddingRight / 3
		else
			windowPaddingRight	= NTakDialog.settings.windowPaddingRight
			windowPaddingLeft	= NTakDialog.settings.windowPaddingLeft
		end
	else
		windowPaddingRight	= 30
		windowPaddingLeft	= 10
	end
	
	--	Options margin is the same as the window padding right
	optionMarginRight	= windowPaddingRight

	--	Resize
	if NTakDialog.settings.windowResize then
		--	Calculate new width
		winWidth	= windowFullWidth - windowMarginLeft - windowBorderLeft + 10 - windowPaddingLeft - windowPaddingRight
		
		--	Here's the fun
		additionalHeight	= math.max(0, (NTakDialog.settings.windowHeight - 0.3) * (0.5 * uiHeight))
		regularHeightCoef	= math.min(1, (NTakDialog.settings.windowHeight / 0.3))
		backgroundHeight	= backgroundHeight * regularHeightCoef + additionalHeight
		if NTakDialog.settings.windowHeight == 1 then
			backgroundHeight = uiHeight
		end
	end

	--	Centerized layout backgrounds tweaks
	if NTakDialog.settings.windowCenterize then
		--	Separator
		xSEPARATOR:SetTexture('/esoui/art/battlegrounds/battlegrounds_scoreboardbg_left.dds')
		xSEPARATOR:SetWidth(winWidth * 1.2)		
		xTOPBG:SetHidden(true)
		xBOTTOMBG:SetHidden(true)
	else
	--	Regular layout backgrounds tweaks
		xTOPBG:ClearAnchors()
		xTOPBG:SetAnchor(TOPLEFT, xTITLE, nil, -windowPaddingLeft, -backgroundHeight)
		xTOPBG:SetAnchor(BOTTOMRIGHT, GuiRoot, RIGHT)
	end



	--	Function called on interaction, apply layout
	function INTERACTION:AnchorBottomBG(optionControl)		
		-- debug("function INTERACTION:AnchorBottomBG")
		
		if NTakDialog.settings.windowCenterize then
		--	Centerized layout
			--	Window
			SetFrameInteractionTarget(0.75, 0.5) -- 0.75, 0.5
			xWINDOWDIV:ClearAnchors()
			xWINDOWDIV:SetAnchor(BOTTOM, GuiRoot, CENTER, 0, winVpos)
			xWINDOWDIV:SetWidth(winWidth)
			xSEPARATOR:ClearAnchors()
			xSEPARATOR:SetAnchor(TOPLEFT, xTITLE, nil, -winWidth / 9, -80)
			xSEPARATOR:SetAnchor(BOTTOMLEFT, optionControl, BOTTOMLEFT, -winWidth / 9 - optionMarginLeft, 33 + backgroundHeight) -- old : 200 + backgroundHeight
		else
		-- Regular layout
			--	Window
			xWINDOWDIV:ClearAnchors()
			xWINDOWDIV:SetAnchor(RIGHT, GuiRoot, TOPRIGHT, -windowPaddingRight, winVpos)
			xWINDOWDIV:SetWidth(winWidth)
		
			--	Bottom
			xBOTTOMBG:ClearAnchors()
			xBOTTOMBG:SetAnchor(TOPRIGHT, GuiRoot, RIGHT)
			xBOTTOMBG:SetAnchor(BOTTOMLEFT, optionControl, BOTTOMLEFT, -windowPaddingLeft - optionMarginLeft, backgroundHeight)
		end			
	end
end
ZO_ItemPreview_Shared.IsInteractionCameraPreviewEnabled = GetPreviewModeEnabled


--	OPTION BACKGROUND

local xHLBG = CreateControl("ZO_InteractWindowPlayerAreaHighlightBackground", xHIGHLIGHT, CT_TEXTURE)
xHLBG:SetTexture("esoui/art/buttons/gamepad/inline_controllerbkg_darkgrey-center.dds")
xHLBG:SetTextureCoords(0.5, 1, 0, 1)
xHLBG:SetBlendMode(TEX_BLEND_MODE_ALPHA)


--	ONE-SHOT TWEAKS

local contentAlpha	= 1
local optionAlpha	= 1
local iconsSpaces	= ""
local styleSpaces	= ""
local optionStyle	= ""
local bodyR, bodyG, bodyB
local function TweakStatic() -- Called only once, on init.
	--	Gamepad Support -- BETA	
	if NTakDialog.settings.gamepad then
		xBODY = ZO_InteractWindow_GamepadContainerText
	end
	bodyR, bodyG, bodyB = xBODY:GetColor()

	--	Window background transparency
	local bkgAlpha = 1 - NTakDialog.settings.windowBkgTransparency
	xTOPBG:SetAlpha(bkgAlpha)
	xBOTTOMBG:SetAlpha(bkgAlpha)
	ZO_InteractWindow_GamepadBG:SetAlpha(bkgAlpha)
	if NTakDialog.settings.windowCenterize then
		xSEPARATOR:SetAlpha(bkgAlpha)
	end

	--	Window all texts transparency
	contentAlpha = 1 - NTakDialog.settings.windowContentTransparency
	optionAlpha = contentAlpha
	optionAlpha = 1 - NTakDialog.settings.optionTransparency
	
	--	Title
	xTITLE:SetHorizontalAlignment(xTALIGNs[NTakDialog.settings.titleAlign])
	xTITLE:SetFont(fontsSizes[NTakDialog.settings.titleSize + 5])

	--	Text body (only to prevent bad behavior on first chat)
	xBODY:SetFont(fontsSizes[NTakDialog.settings.textSize + 4])
	
	--	Option suffixes
	iconsSpaces	= string.sub("          ", 0, NTakDialog.settings.optionIconsSpace)
	styleSpaces	= string.sub("          ", 0, NTakDialog.settings.optionNumberSpace)
	optionStyle	= ""
	if NTakDialog.settings.optionNumbers then
		optionStyle = NTakDialog.settings.optionNumberStyling .. styleSpaces
	end

	--	Highlights
	local full			= NTakDialog.settings.HLFullWidth
	local bordersWidth	= NTakDialog.settings.HLBordersWidth
	local backAlpha		= NTakDialog.settings.HLBackAlpha
	local backOffset	= (0 - windowPaddingLeft - optionMarginLeft ) * BoolToNum(full)

	--	Change background effect
	xHLBG:ClearAnchors()
	xHLBG:SetAnchor(TOPLEFT, xHIGHLIGHT, TOPLEFT, backOffset, -1 - bordersWidth / 2)
	xHLBG:SetAnchor(BOTTOMRIGHT, xHIGHLIGHT, BOTTOMRIGHT, windowPaddingRight * 2, 1 + bordersWidth / 2)
	xHLBG:SetAlpha(backAlpha)
	
	--	Change borders width
	xHLTOP:SetHeight(bordersWidth)
	xHLBOT:SetHeight(bordersWidth)
end


--	HISTORY

local chatHistoric	= ""
local chatOptions	= {}
local chatIndexes	= {}
local chatPlayer	= GetUnitName("player")
local chatTitle		= ""
local function ClearChatOptions()
	chatOptions = {}
end
local function ClearChatHistory()
	chatHistoric = ""
	ClearChatOptions()
end
local function AddInChatHistory(text, isOption, numOption)
	--	Output in chat
	if NTakDialog.settings.chatOutput then
		if isOption then	
			d("\n" .. ZO_HIGHLIGHT_TEXT:Colorize(text))
		else
			d("\n" .. text)
		end
	end
	
	--	Put in history	
	if NTakDialog.settings.chatHistory then
	
		if isOption then
			--	If it's an option
			local prefix = ""
			if NTakDialog.settings.chatNames then
				--	Formatting with chat name
				prefix = chatPlayer .. ": "
				text = "“" .. text .. "”"
			elseif not(IsDescription(text)) then
				--	Prefix only if not description
				prefix = NTakDialog.settings.chatOptionPrefix			
			end
			text = ZO_HIGHLIGHT_TEXT:Colorize("\n" .. prefix .. text)
			ClearChatOptions()
		elseif NTakDialog.settings.chatNames then
			--	If it's a text
			text = chatTitle .. ": “" .. text .. "”"
		end
		
		if NTakDialog.settings.chatLastReply then
			ClearChatHistory()
		end

		chatHistoric = chatHistoric .. text .. "\n"
	end
end


--	TITLE

local function TweakTitle()
	--	Get title text
	local title	= xTITLE:GetText()
	
	--	Remove “decoration”
	-- d(SI_INTERACT_TITLE_FORMAT) -- TO TEST
	-- ZO_CreateStringId("SI_INTERACT_TITLE_FORMAT", "<<1>>")	-- TO TEST, alter the title style
	chatTitle = string.sub(title, 2, -2)
	if NTakDialog.settings.titleClean then
		title = chatTitle
	end

	--	Add padding according to alignement
	local align	= NTakDialog.settings.titleAlign
	local pad	= NTakDialog.settings.titlePadding
    if pad > 0 then
		if (align == 1) then title = TextPad(pad) .. title end
		if (align == 3) then title = title .. TextPad(pad) end
	end

	--	Change color
	if NTakDialog.settings.titleColorAlt then
        title = ZO_HIGHLIGHT_TEXT:Colorize(title)
	end
	
	--	Final display
	xTITLE:SetText(title)
	-- xTITLE:SetAlpha(contentAlpha)
end


--	TEXT

local bodyText, bodyTextLength
local textFadeDelay, textFadeDelta, textFadeStep, textPreventJump
local textId = 0
local isTextHidden = false
local function TextHide()
	isTextHidden = true
	xBODY:SetFont(fontZero)
	xBODY:SetHeight(10)
end
local function TextShow()
	isTextHidden = false
	xBODY:SetFont(fontsSizes[NTakDialog.settings.textSize + 4])
	xBODY:SetHeight(nil)
end
local function TextSetHidden(value)
	if value then
    	TextHide()
    else
		TextShow()
    end
end
local function TextFull()
	--	Escape if text is already reseted (so, surely displayed!?)
	if not(bodyText)	then return end
	if bodyText == ""	then return end

	--	Display full text
    xBODY:SetText(chatHistoric .. bodyText)
	xTITLE:SetAlpha(contentAlpha)
	xBODY:SetAlpha(contentAlpha)
	AddInChatHistory(bodyText)
	bodyText = ""
	
	--	Call the display of options
	if NTakDialog.settings.optionShowAfterText then
		OptionsFadeInit()
	end
end
local fadeId = 0
local function TextFadeLoop(strFull, strPart, iPart)
	--	Escape if text has changed
	if fadeId ~= textId then return end
	
	--	Escape if already displayed
	if bodyText == "" then return end
	if NumbersClose(xBODY:GetAlpha(), contentAlpha) then return end
	
	--	Escape if init not called (text changed)
	if xBODY:GetAlpha() == 0 then
		bodyText = ""
		return
	end

	--	End this loop if fully displayed
	local displayedLength = zo_strlen(strFull)
	if displayedLength >= bodyTextLength then
		TextFull()
		return
	end

	--	Add some “space prediction” to prevent line jump during the fading animation
	local strSpaces	= ""
	if not(NTakDialog.settings.textFadeExpand) then
		strSpaces = TextSpacePredict(bodyText, displayedLength + NTakDialog.settings.textFadeExtent, 2)
	end
	
	--	Set new text
	xBODY:SetText(chatHistoric .. strFull .. strPart .. strSpaces)
	
	--	Inits for new iteration
	iPart 		= iPart + (GetFrameDeltaTimeMilliseconds() / textFadeDelta) * textFadeStep
	strPart		= ""
	offset		= displayedLength + 1
	local iMax	= iPart
	for i = iMax, 0, -textFadeStep do
		local chr, off = GetCharAt(bodyText, offset)
		offset = offset + off
		if i >= 1 then
			iPart	= iPart - textFadeStep
			strFull	= strFull .. chr
		else
			strPart	= strPart .. TextColorRGBS(chr, bodyR, bodyG, bodyB, i)
		end
    end
	
	--	Call next iteration
	zo_callLater(function()
		TextFadeLoop(strFull, strPart, iPart)
	end, 1)
end
local function TextFadeInit(speed)
	--	Instant display selected
	if not(NTakDialog.settings.textFadeIn or NTakDialog.settings.textHide) or (speed > 2) then
		TextFull()
		return
	end

    --	Get timers
	textFadeDelay	= math.min(1, NTakDialog.settings.textFadeDelay)
    textFadeDelta	= NTakDialog.settings.textFadeDelta
	textFadeStep	= 1 / NTakDialog.settings.textFadeExtent
	
	--	Use these specific settings if using the "text hidden"
	if NTakDialog.settings.textHide and not(NTakDialog.settings.textHideSameDelays) then
		textFadeDelay = 1
		textFadeDelta = 23
	end
	
    --	Speed up text display
    if speed > 1 then
		textFadeDelta = textFadeDelta / 4
    end
	
    --	Initialize the text fading
    xBODY:SetText(chatHistoric)
    zo_callLater(function()
		fadeId = textId
		xBODY:SetAlpha(0.01) -- Fake hidden
		TextFadeLoop("", "", 0)
		xTITLE:SetAlpha(contentAlpha)
		xBODY:SetAlpha(contentAlpha - 0.01) -- Fake displayed
    end, textFadeDelay)
end
local function TextCorrections(text)
	--	Typo corrections
	text = text:gsub("%.(%a)", ". %1")		-- Add space after “.” if there isn't
	text = text:gsub("  ", " ")				-- Replace double spaces by one
	text = text:gsub(" (%p)", " %1")		-- Just in case, should be already correct
	return text
end
local function TweakText(speed, repeated)
	--	Get text values, correct and add history
	bodyText = xBODY:GetText()
	bodyText = TextCorrections(bodyText)
	bodyTextLength = zo_strlen(bodyText)

	--
	if not(repeated) then xBODY:SetText(chatHistoric .. bodyText) end
	
	--	Get default dimensions
	TextShow()
	local w, h	= xBODY:GetDimensions()

	-- Fixed pre-allocated height
	if not(NTakDialog.settings.textFadeExpand) then
		xBODY:SetHeight(h)
	end
	
	--	Change alignments
	local align = NTakDialog.settings.textAlign
	xBODY:SetHorizontalAlignment(xTALIGNs[align])	
	-- xBODY:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	
	--	Override parameters if text must be hidden
    if NTakDialog.settings.textHide and not(IsDescription(bodyText)) then
		TextHide()
	end
	
	--	Launch the text fading
	TextFadeInit(speed)
  
  	--	Display options directly (text not displayed yet)
	if NTakDialog.settings.optionShowDirect then
		OptionsFadeInit()
	end
end


--	OPTIONS

local function NOTUSED_RepeatFunctions_NOTUSED()  
  
-- local function AddRepeatOption(i) -- NOTHING THERE FOR NOW
	--	Get data
	-- iRepeat	= i - 1
	-- local original	= xOPTIONS:GetChild(i - 1)
	-- local copy		= xOPTIONS:GetChild(i)
	-- d("Trigger add repeat option")
	-- d(copy)
	
	-- table.insert(xOPTIONS, original)
	
	--	Copy option
	-- copy = original						-- TO TEST
	--copy:SetHidden(false)
	-- copy:SetText("Copy text")
	-- xOPTIONS:SetChild(i, original)	-- TO TEST

	--	Alter the original (so goodbye stays in last position)

-- function ZO_Interaction:PopulateChatterOption(controlID, optionIndex, optionText, optionType, optionalArg, isImportant, chosenBefore, importantOptions)
  
	-- INTERACTION:PopulateChatterOption(xOPTIONS:GetChild(i - 1), i, original:GetText(), original.optionType, false, false, false)

	--	Alter original
	-- original:SetText("Could you repeat?")
-- end


--	EXAMPLE
-- local oldFunction = INTERACTION.PopulateChatterOption
-- function INTERACTION:PopulateChatterOption(controlID, ...)
	-- oldFunction(self, controlID, ...)
	-- sets the color of the answer option, the color changes if the answer has been selected before
	-- local optionControl = self.optionControls[controlID]
	-- if optionControl.enabled then
		-- if(optionControl.chosenBefore) then
			-- optionControl:SetColor(unpack(DialogColors.settings.seenColor))
		-- else
			-- optionControl:SetColor(unpack(DialogColors.settings.selectColor))
		-- end
		-- GetControl(optionControl, "IconImage"):SetDesaturation(0)
	-- end
	-- set the shadow color of the answer
	-- optionControl:SetStyleColor(unpack(DialogColors.settings.shadowColor))
end
local newOptionsCount = 0 -- TO TEST
local iOptions = 0
local iRepeat = 0
local function ClearRawOptions()
	chatOptions	= {}
	chatIndexes	= {}
end
local function SaveRawOption(i, text)
	chatOptions[i] = text
	chatIndexes[text] = i  
end


local repeatText = texts.optionRepeat
local restartText = texts.optionRestart
function CustomPopulateChatterOption()
	local OriginalPopulateChatterOption = INTERACTION.PopulateChatterOption
	function INTERACTION:PopulateChatterOption(controlID, optionIndex, optionText, optionType, optionalArg, isImportant, chosenBefore, importantOptions, ...)
		--	Reset if first option
		if iOptions == 0 then
			ClearRawOptions()
		end
  
		--	Count calls of this function
		iOptions = iOptions + 1
    
		--	Some debug output
		if optionType ~= nil then -- and optionIndex ~= nil then
			debug("option #" .. iOptions .. " : type: " .. optionType) -- .. ", index: " .. optionIndex)
		else
			debug("option #" .. iOptions .. " : type and/or index is incorrect")
		end

		--	Launch original function if not last option
		if optionType ~= CHATTER_GOODBYE and not(IsUnderArrest()) then
	    	OriginalPopulateChatterOption(self, controlID, optionIndex, optionText, optionType, optionalArg, isImportant, chosenBefore, importantOptions, ...)
			SaveRawOption(iOptions, optionText)
			return	--	Escape
	    end
	    
		--	Get control
	    local optionControl = self.optionControls[controlID]
	
		--	Goodbye option
	    chosenBefore = NTakDialog.settings.optionGreyBye
	   	OriginalPopulateChatterOption(self, controlID, optionIndex, optionText, optionType, optionalArg, isImportant, chosenBefore, importantOptions, ...)
		SaveRawOption(iOptions, optionText)

		--	Add repeat
		if NTakDialog.settings.optionAddRepeat then
			--	Increment for next option
			controlID = controlID + 1
			iOptions = iOptions + 1
		
			--	
			chosenBefore = NTakDialog.settings.optionGreyRepeat
			iRepeat = iOptions
			local text = ""
			if textId == 0 then
				text = restartText
			else
				text = repeatText
			end
			OriginalPopulateChatterOption(self, controlID, iRepeat, text, CHATTER_START_TALK, optionalArg, isImportant, chosenBefore, nil, ...)
			debug("Repeat option: " .. iRepeat)
		end
	
    	--	Final count	
		newOptionsCount = iOptions
		iOptions = 0 -- To trigger reset next time

		--	Debug
		debug("Options count: " .. newOptionsCount)
	end
end
CustomPopulateChatterOption()


local optionsCount
local function GetOptionsCount()
	optionsCount = xOPTIONS:GetNumChildren()
	-- optionsCount = 1 + GetChatterOptionCount()
end
local function HideOptions()
	xREWARD:SetAlpha(0)
	xOPTIONS:SetAlpha(0)
	xHIGHLIGHT:SetAlpha(0)
end
local function ShowOptions()
	xREWARD:SetAlpha(optionAlpha)
	xOPTIONS:SetAlpha(optionAlpha)
	xHIGHLIGHT:SetAlpha(optionAlpha)	
end
local function IsBadOption(option)
	-- return option:IsHidden()			-- In some cases, the options are hidden but correct, and displayed ?!
	-- return option.optionType == nil	-- Better below
	return not(option.optionType) or not(option.optionText)
end
local function OptionsFadeLoop(fadeTime)
	--	Escape if fully displayed
	if xHIGHLIGHT:GetAlpha() >= optionAlpha then
		ShowOptions()
		return
	end

	--	Increase alpha
	local addAlpha	= (GetFrameDeltaTimeMilliseconds() / fadeTime) * optionAlpha
	xREWARD:SetAlpha(xREWARD:GetAlpha() + addAlpha)
	xOPTIONS:SetAlpha(xOPTIONS:GetAlpha() + addAlpha)
	xHIGHLIGHT:SetAlpha(xHIGHLIGHT:GetAlpha() + addAlpha) -- Usefull ? Isn't that in options already ?
	
	--	Continue on next frame
	zo_callLater(function()
		OptionsFadeLoop(fadeTime)
	end, 1)
end
function OptionsFadeInit()
    --	Start fading on the next frame
	zo_callLater(function()
		OptionsFadeLoop(NTakDialog.settings.optionFadeTime)
	end, 1)
end
local colorChosenBefore = {0.4, 0.4, 0.4}
local function OptionsHeight()
	--	Loop
	for i = 1, optionsCount do
		--	Get option, escape if incorrect
		local option = xOPTIONS:GetChild(i)
		if IsBadOption(option) then break end
		
		--	Change dimensions
		local w, h = option:GetDimensions()
		option:SetHeight(math.floor(h + 0.5) + NTakDialog.settings.optionHeightInc)
	end
end
local function TweakOptions()
	--	Escape if already done
	if xOPTIONS:GetAlpha() > 0 then return end

	--	Loop to stylize options
	local option
	local optionType
	local style
	for i = 1, optionsCount do
		--	Get option
		option = xOPTIONS:GetChild(i)
		--	Break if option incorrect (must be finished)
		if IsBadOption(option) then break end
		--	Escape if already tweaked
		if option:GetText():sub(1, 2) == " " then break end

		--	Put in original options array
		chatOptions[#chatOptions + 1] = option:GetText()
		
		style = " "
		--	Add option icons
		optionType = option.optionType
		if NTakDialog.settings.optionIcons then
			if i == iRepeat then
				--	Special icon for repeat
				optionType = "CHATTER_REPEAT"
			elseif chatIcons32[optionType] == nil then
				--	No icon found for that option
				if optionType > 0 then	--	Display a message only if the optionType got a correct value
					debug(texts.optionError .. optionType .. ".", true)
				end
				optionType = CHATTER_TALK_CHOICE	-- Default icon
			end
			
			--	Prepend icon
			style = style .. chatIcons32[optionType] .. iconsSpaces
		end
		
		--	Add option numbers
		if optionStyle ~= "" then
			-- if i ~= iRepeat then
				-- style = style .. string.rep(" ", string.len(optionStyle))
			-- else			
				style = style .. optionStyle:gsub("x", i)
			-- end
		end

		--	Final styling
		style = style .. " " -- Minimal space
		-- style = style:gsub(" ", ".")
		option:SetText(style .. option:GetText())
		
		--	Change font
		option:SetFont(fontsSizes[NTakDialog.settings.optionSize + 3])	
		
		--	Change alignments
		local align = NTakDialog.settings.optionAlign
		option:SetHorizontalAlignment(xTALIGNs[align])	
		option:SetVerticalAlignment(TEXT_ALIGN_CENTER)

		--	Grey "goodbye"
		if optionType == CHATTER_GOODBYE then
			if NTakDialog.settings.optionGreyBye and not(IsUnderArrest()) then
				option.chosenBefore = not(IsUnderArrest()) -- WHY NOT WORKING ?!
				option:SetColor(unpack(colorChosenBefore))
			end
		end
		
		--	Change dimensions
		option:SetWidth(winWidth - optionMarginLeft - optionMarginRight)
		option:SetHeight(nil) -- To restore default dimensions
	end

	--	Call on the next frame
	zo_callLater(OptionsHeight, 1)
end


--	USER INTERACTION
--	Replaces the default function for important option confirmation when using keyboard
--	Emulates a "mouse over" on 1st key press if important, 2nd to confirm.
local function CustomSelectChatterOption()
	--	Helper
	local function ResetSelectedChatter()
		if (INTERACTION.currentMouseLabel ~= nil) then
			ZO_ChatterOption_MouseExit(INTERACTION.currentMouseLabel)
		end
	end
	--	Keyboard function
	local OriginalSelectChatterOptionByIndex = INTERACTION.SelectChatterOptionByIndex
	function INTERACTION:SelectChatterOptionByIndex(optionIndex, skip)
		debug("Keyboard option selected: " .. optionIndex)
		
		--	Call original function on next frame
		if skip then 
			zo_callLater(function()
				OriginalSelectChatterOptionByIndex(self, optionIndex)
			end, 1)
			return
		end
    
		--	Text not full or options not displayed yet
		if	(NTakDialog.settings.textFadeShowOnPress and bodyText ~= "") or
			(xHIGHLIGHT:GetAlpha() == 0)
		then
			if bodyText ~= "" and NTakDialog.settings.textFadeShowOnPress then
				TextFull()
			end
			if xHIGHLIGHT:GetAlpha() == 0 and NTakDialog.settings.optionShowOnPress then
				OptionsFadeInit() -- ShowOptions() 
			end
			return
		end
		
		--	Check for specific option
		local option = INTERACTION.optionControls[optionIndex]
		-- local num = label.optionIndex
		local oiType = type(optionIndex)
		-- d(optionIndex)
		-- d(option.optionText)
		-- d(oiType)
		if option.isImportant then
			if (INTERACTION.currentMouseLabel == option) then
				--	If already “hovered”, launch original function
				OriginalSelectChatterOptionByIndex(self, optionIndex)
				ResetSelectedChatter()
			else
				--	Emulates the “MouseEnter” on the option
				ResetSelectedChatter()
				ZO_ChatterOption_MouseEnter(option)
			end
		--	Repeat
		elseif optionIndex == iRepeat then
			NTakDialog.OnRepeat()
		else
			--	Launch original function if not important
			OriginalSelectChatterOptionByIndex(self, optionIndex)
		end
	end
	--	Mouse function (but Keyboard “SelectChatterOptionByIndex” triggers it)
	local OriginalHandleChatterOptionClicked = INTERACTION.HandleChatterOptionClicked
	function INTERACTION:HandleChatterOptionClicked(label)
		--	Escape
		if xHIGHLIGHT:GetAlpha() == 0 then return end
		-- if(not label.enabled) then return end
		
        --	Do something with the option clicked
		if(label.enabled and label.optionIndex) then
			local num = label.optionIndex
            local oiType = type(num)
			local text = ""
			
			--	Repeat
			if num == iRepeat and oiType == "number" then
			-- if label.optionText == repeatText then
				NTakDialog.OnRepeat()
				return
			end
			
			--	Correct index
            if(oiType ~= "number") then num = 1 end -- Héhé, peut-être que c'est pas 1 !
			
            -- if(oiType == "number") then
				text = label.optionText
				-- text = label:GetText() -- With all formatting, icon and number 
			-- elseif(oiType == "function") then
			-- if text == nil or not(text) or text == "" then
				-- text = label:GetText()
			-- end
			
			AddInChatHistory(text, true, num)
		end
		
		--	Run original
		OriginalHandleChatterOptionClicked(INTERACTION, label)
	end
end
CustomSelectChatterOption()

--	Auto select an option
local function AutoSelectOption(value)
	if value > 0 then
		zo_callLater(function()
			INTERACTION:SelectChatterOptionByIndex(value, true)
		end, 100)
	end
end

--	VOLUME
local volumeMuted
local volumeSaved
local muted = {}	-- TO TEST ADD THINGS INSIDE
local function VolumeChange()
	--	Escape if volume already changed
	if volumeMuted then return end
	--	Save current volume
	volumeSaved = GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_VOLUME)
	--	Change volume to 0
	SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_VOLUME, 0)
	volumeMuted = true
end
local function VolumeRestore()
	--	Escape if volume hasn't been changed
	if not(volumeMuted) then return end
    --	Restore saved volume
    SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_VOLUME, volumeSaved)
    volumeMuted = false
end

--	SPEED
local speed = 0
local function SpeedCalc(fast, instant)
	return 1 + 1 * BoolToNum(fast) + 2 * BoolToNum(instant)
end
local function SpeedOptions()
	--	Escape if check already done
	if speed > 0 then return end
	
	--	Check if description
	if IsDescription(xBODY:GetText()) then
    	speed = SpeedCalc(NTakDialog.settings.speedDescription, NTakDialog.settings.directDescription)
	end

	--	Init. and Loop
	local doAuto = 0
	local doMute = false
	local specialOptions = 0
	local bankerOptions = false
	for i = 1, optionsCount do
		--	Get option
		local option = xOPTIONS:GetChild(i)
		
		--	Apply and escape when loop is done (option is incorrect or hidden)
		if IsBadOption(option) or option:IsHidden() then
			if (specialOptions == 1) or bankerOptions then
			--	Do things only if 1 "special"
				if doAuto > 0 then AutoSelectOption(doAuto) end
				if doMute then VolumeChange() end
			end
			return
		elseif
		--	Escape if anything to do with a quest or special speechcraft
			(not (NTakDialog.settings.autoQuestOpen) 		and (option.optionType == CHATTER_START_NEW_QUEST_BESTOWAL)) or
			(not (NTakDialog.settings.autoQuestAccept) 		and (option.optionType == CHATTER_GENERIC_ACCEPT)) or
			(not (NTakDialog.settings.autoQuestComplete)	and (option.optionType == CHATTER_COMPLETE_QUEST)) or
			option.optionType == CHATTER_START_COMPLETE_QUEST or
			option.optionType == CHATTER_START_GIVE_ITEM or
			option.optionType == CHATTER_START_ADVANCE_COMPLETABLE_QUEST_CONDITIONS or
			option.optionType == SI_CONVERSATION_OPTION_SPEECHCRAFT_INTIMIDATE or
			option.optionType == SI_CONVERSATION_OPTION_SPEECHCRAFT_PERSUADE
		then
			return
		elseif option.optionType == CHATTER_START_BANK then
		--	Do stuff depending on the option type
		-- Banker
			specialOptions = specialOptions + 1
			bankerOptions = true
    		speed = SpeedCalc(NTakDialog.settings.speedBanker, NTakDialog.settings.directBanker or NTakDialog.settings.autoBanker)
			if NTakDialog.settings.autoBanker		then doAuto = i end
			if NTakDialog.settings.muteBanker		then doMute = true end
		elseif (option.optionType == CHATTER_START_SHOP) and not(bankerOptions) then
		-- Vendor
			specialOptions = specialOptions + 1
    		speed = SpeedCalc(NTakDialog.settings.speedVendor, NTakDialog.settings.directVendor or NTakDialog.settings.autoVendor)
			if NTakDialog.settings.autoVendor 		then doAuto = i end
			if NTakDialog.settings.muteVendor		then doMute = true end
		elseif (option.optionType == CHATTER_START_TRADINGHOUSE) and not(bankerOptions) then
		-- Trader
			specialOptions = specialOptions + 1
    		speed = SpeedCalc(NTakDialog.settings.speedTrader, NTakDialog.settings.directTrader or NTakDialog.settings.autoTrader)
			if NTakDialog.settings.autoTrader 		then doAuto = i end
			if NTakDialog.settings.muteTrader		then doMute = true end
		elseif option.optionType == CHATTER_START_STABLE then
		-- Stable
			specialOptions = specialOptions + 1
    		speed = SpeedCalc(NTakDialog.settings.speedStable, NTakDialog.settings.directStable or NTakDialog.settings.autoStable)
			if NTakDialog.settings.autoStable 		then doAuto = i end
			if NTakDialog.settings.muteStable		then doMute = true end
		elseif option.optionType == CHATTER_START_NEW_QUEST_BESTOWAL then
		-- Quest			
			if NTakDialog.settings.autoQuestOpen and (specialOptions == 0) then				
				specialOptions = 1
				speed = SpeedCalc(false, true)
				doAuto = i
			end
		elseif option.optionType == CHATTER_GENERIC_ACCEPT then
		-- Quest			
			if NTakDialog.settings.autoQuestAccept and (specialOptions == 0) then				
				specialOptions = 1
				speed = SpeedCalc(false, true)
				doAuto = i
			end
		elseif option.optionType == CHATTER_COMPLETE_QUEST then
		-- Quest			
			if NTakDialog.settings.autoQuestComplete and (specialOptions == 0) then				
				specialOptions = 1
				speed = SpeedCalc(false, true)
				doAuto = i
			end
		end
	end
end


------------------------------------------
--		EVENT HANDLERS

--	Apply only static tweaks
function NTDial.InitDialogs()
	INTERACTION:OnScreenResized()
	TweakStatic()
end

--	Apply all dialog adjustment functions
local function OnDialog()

	--	To ensure everything is right
	if winWidth == nil then
		NTDial.InitDialogs()
	end

	--	Manage History
	ClearChatOptions()
	if textId == 0 then -- First dialog
		ClearChatHistory()
	end
	
	--	Hide things
	xTITLE:SetAlpha(0)
	TweakTitle()
	xBODY:SetAlpha(0)
	HideOptions()
	
	--	Call on the next frame
	textId = textId + 1
	zo_callLater(function()
		GetOptionsCount()
		SpeedOptions()
		TweakOptions()
		TweakText(speed)
	end, 1)
end



-- Intercept the method that prepares conversation data for the UI.
local function CustomInteractionGetChatterOptionData()
    local OriginalGetChatterOptionData = INTERACTION.GetChatterOptionData
    function INTERACTION:GetChatterOptionData(...)

        -- -- Invoke the original method.
        local chatterData = OriginalGetChatterOptionData(self, ...)
		newOptionsCount = newOptionsCount + 1
        -- d(GetTimeStamp() .. " - Chatter option: " .. newOptionsCount)

        -- -- Escape if incorrect
        -- if not(chatterData.optionText) then return chatterData end
        -- if not(chatterData.optionType) then return chatterData end

		-- -- Add number prefix to static options.
        -- if (savedVars.addNumberPrefix) then
            -- chatterData.optionText = chatterOptionCount..". "..chatterData.optionText
        -- end

        -- -- Always flag Goodbye as "seen before" unless you're
        -- -- under arrest, because then its the Flee option.
        -- if (savedVars.goodbyeAlwaysSeen) then
            -- if (chatterData.optionType == CHATTER_GOODBYE and not IsUnderArrest()) then
                -- chatterData.chosenBefore = true
            -- end
        -- end

        -- Return the modified data.
		
		SaveRawOption(newOptionsCount, chatterData.optionText)
		
        return chatterData
    end
end
CustomInteractionGetChatterOptionData()



local function CustomInteractionInitializeInteractWindow()
    local OriginalInitializeInteractWindow = INTERACTION.InitializeInteractWindow
    function INTERACTION:InitializeInteractWindow(...)
        -- d(GetTimeStamp() .. " - InitializeInteractWindow called")
        newOptionsCount = 0
		ClearRawOptions()
        OriginalInitializeInteractWindow(self, ...)
    end
end
CustomInteractionInitializeInteractWindow()


-- local function CustomResetInteraction()
	-- local OriginalResetInteraction = INTERACTION.ResetInteraction
	-- function INTERACTION:ResetInteraction(bodyText, ...)
		-- -- d(bodyText)
		-- OriginalResetInteraction(self, bodyText, ...)
	-- end
-- end
-- CustomResetInteraction()


local function OffDialog()
	speed = 0
	iRepeat = 0
	textId = 0
	
	TextFull()	-- I know that's strange, but yep
	xBODY:SetText("")
	
	--	Call later to restore volume
	zo_callLater(VolumeRestore, 500)
end

--	Repeat dialog
function NTakDialog.OnRepeat()
	--	Escape if not fully displayed
	if not(NumbersClose(xBODY:GetAlpha(), contentAlpha)) then return end
	-- if NTakDialog.settings.chatHistory then return end
	
	--	Repeat dialog
	debug("Repeat triggered.")
	local text, numOptions, atGreeting = GetChatterData()
end


------------------------------------------
--		COMMANDS & ASSOCIATED

function KeyUp_DialogRepeat()
	NTakDialog.OnRepeat()
end

function KeyUp_ToggleBodyHidden()
	TextSetHidden(not(isTextHidden))
end

--	Beta
local function ToggleBeta()
	NTakDialog.settings.beta = not(NTakDialog.settings.beta)
	local beta = NTakDialog.settings.beta
	debug("Beta: " .. BoolToNum(beta), true)
	-- debug("Nothing in beta right now!", true)

	-- debug("- Names in chat history", true)
	-- NTakDialog.settings.chatNames 			= beta

	debug("- Auto open/accept/complete quests", true)
	NTakDialog.settings.autoQuestOpen		= beta
	NTakDialog.settings.autoQuestAccept		= beta
	NTakDialog.settings.autoQuestComplete	= beta
	-- debug("- Gamepad support (needs reload UI)", true)
	-- NTakDialog.settings.gamepad				= beta
	
	--	Re-init everything with the new functionalities
	NTDial.InitDialogs()
end
SLASH_COMMANDS["/ntdial_beta"] = ToggleBeta

local function ToggleDebug()
	NTakDialog.settings.debug = not(NTakDialog.settings.debug)
end
SLASH_COMMANDS["/ntdial_debug"] = ToggleDebug



local function OnStyling()
	debug("Entering Outfit station… Removing centering mode.")
	SetFrameInteractionTarget(0.5, 0.5)
end



------------------------------------------
--		ADDON LOAD

local function OnAddOnLoaded(eventCode, addonName)
	--	Escape if incorrect
	if addonName ~= ADDON_NAME then return end

	--	Unregister
	EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
	
	--	Default settings
	local defaults = {
		--	Account wide
		accountWide					= true,
		--	Gamepad
		gamepad						= false,
		--	Chat history
		chatHistory					= false,
		chatLastReply				= false,
		chatOptionPrefix			= "> ",
		chatNames					= false,
		chatOutput					= false,
		--	Window
		windowCenterize				= false,
		windowResize				= false,
		windowWidth					= 0.45,
		windowHeight				= 0.5,
		windowVerticalPosition		= 0,
		windowPaddings				= false,
		windowPaddingAuto			= false,
		windowPaddingLeft			= 10,
		windowPaddingRight			= 30,
		windowBkgTransparency		= 0,
		windowContentTransparency	= 0,
		--	Title
		titleSize					= 1,
		titleAlign					= TEXT_ALIGN_LEFT,
		titleClean					= true,
		titleColorAlt				= true,
		titlePadding				= 0,
		--	Text body
		textSize					= 0,
		textAlign					= TEXT_ALIGN_LEFT, -- NOT USED
		textHide					= false,
		textHideSameDelays			= false,
		textFadeIn					= false,
		textFadeDelta				= 20,
		textFadeDelay				= 200,
		textFadeExtent				= 10,
		textFadeShowOnPress			= true,
		textFadeExpand				= true,
		--	Options
		optionShowDirect			= false,
		optionShowAfterText			= true,
		optionShowOnPress			= true,
		optionFadeTime				= 200,
		optionSize					= 0,
		optionHeightInc				= 4,
		optionAlign					= TEXT_ALIGN_LEFT, -- NOT USED ?
        optionGreyBye				= true,
		optionAddRepeat				= false,
		optionGreyRepeat			= true,
		optionNumbers				= true,
		optionNumberStyling			= "x)",
		optionNumberSpace			= 2,
		optionIcons					= false,
		optionIconsSpace			= 2,
		optionTransparency			= 0,
		--	Highlight effect
		HLFullWidth					= false,
		HLBordersWidth				= 2,
		HLBackAlpha					= 0.66,
        --	Mute sound
		muteBanker					= false,
        muteVendor					= false,
        muteTrader					= false,
        muteStable					= false,
		--	Auto open
		autoBanker					= false,
		autoVendor					= false,
        autoTrader					= false,
        autoStable					= false,
		autoQuestOpen				= false,
		autoQuestAccept				= false,
		autoQuestComplete			= false,
		--	Speed-up fading
		speedDescription			= false,
		speedBanker					= false,
        speedVendor					= false,
        speedTrader					= false,
        speedStable					= false,
		--	Display instantly
		directDescription			= false,
		directBanker				= false,
        directVendor				= false,
        directTrader				= false,
        directStable				= false,
		--	Debug
		debug						= false,
		beta						= false,
	}
	
	-- Get character settings
	NTakDialog.settings = ZO_SavedVars:NewCharacterIdSettings("NTakDialog_SavedVariables", 1, "Settings", defaults)
	-- Get (or create) account wide if selected
	if NTakDialog.settings.accountWide then
		if NTakDialog_SavedVariables.Default[GetDisplayName()]["$AccountWide"] == nil then
			local currents = CopyTree(NTakDialog_SavedVariables.Default[GetDisplayName()][GetCurrentCharacterId()]["Settings"])
			NTakDialog.settings = ZO_SavedVars:NewAccountWide("NTakDialog_SavedVariables", 1, "Settings", currents)
			zo_callLater(function()
				d("NTakDialog: Account-wide settings have been created from current character settings.")
			end, 5000)
		else
			NTakDialog.settings = ZO_SavedVars:NewAccountWide("NTakDialog_SavedVariables", 1, "Settings", defaults)
		end
	end
	
	--	Initialize all
	NTDial.InitSettings()
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED,		NTDial.InitDialogs)

	--	Register to various events
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_CHATTER_BEGIN,			OnDialog)
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_QUEST_OFFERED,			OnDialog)
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_QUEST_COMPLETE_DIALOG,	OnDialog)
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_CONVERSATION_UPDATED,	OnDialog)
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_CHATTER_END,			OffDialog)
	
	-- --	
	if NTakDialog.settings.windowCenterize then
		EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_DYEING_STATION_INTERACT_START, OnStyling)
	end
end
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)