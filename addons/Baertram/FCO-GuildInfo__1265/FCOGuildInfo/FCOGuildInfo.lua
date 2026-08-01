--[[
user:/AddOns/FCOGuildInfo/FCOGuildInfo.lua:385: function expected instead of nil
stack traceback:
user:/AddOns/FCOGuildInfo/FCOGuildInfo.lua:385: in function 'FCOGuildInfo:buildGuildMemberOnlineText'
|caaaaaa<Locals> self = [table:1]{}, buildType = "label", chatOutputText = "", numGuilds = 4, guildIndex = 1, guildId = 6477, guildIdRemoved = 6477, displayName = "@Baertram", pChatUseESOcolors = F </Locals>|r
user:/AddOns/FCOGuildInfo/FCOGuildInfo.lua:120: in function 'FCOGuildInfo:New'
|caaaaaa<Locals> self = [table:1], guild = [table:2]{}, numGuilds = 4, icon = ud, label = ud, anchorControl = ud </Locals>|r
user:/AddOns/FCOGuildInfo/FCOGuildInfo.lua:634: in function 'OnAddOnLoaded'
|caaaaaa<Locals> event = 65536, addonName = "FCOGuildInfo" </Locals>|r
]]

local ADDON = {}
ADDON.name = "FCOGuildInfo"
ADDON.version	= 2.44
ADDON.savedVarsVersion = 1.2
local FCOGuildInfo = ZO_Object:Subclass()
FCOGI = FCOGuildInfo
local addonName = ADDON.name

local EM = EVENT_MANAGER

--Load the settings from the SavedVAriables
local settings = {}
local locVars = {}

--Uncolored "FCOIS" pre chat text for the chat output
locVars.preChatText = "[FCOGI]"
--Green colored "FCOIS" pre text for the chat output
locVars.preChatTextGreen = "|c22DD22"..locVars.preChatText.."|r "
--Red colored "FCOIS" pre text for the chat output
locVars.preChatTextRed = "|cDD2222"..locVars.preChatText.."|r "
--Blue colored "FCOIS" pre text for the chat output
locVars.preChatTextBlue = "|c2222DD"..locVars.preChatText.."|r "

-- Convert a decimal number in [0,255] to a hexadecimal number.
local function dec2hex(n)
	local str = "0123456789abcdef"
	local l = string.sub(str, math.floor(n/16)+1, math.floor(n/16)+1)
	local r = string.sub(str, n%16 + 1, n%16 + 1)
	return l..r
end

-- Turn a ([0,1])^3 RGB colour to "|cABCDEF" form.
local function makeColour(r, g, b)
	r = math.floor(255*r)
	g = math.floor(255*g)
	b = math.floor(255*b)
	return "|c"..dec2hex(r)..dec2hex(g)..dec2hex(b)
end

local function GetAnchorControlInChatWindow(minimized)
	minimized = minimized or false
	local anchorControl = nil
    if MyStatus ~= nil then
		if minimized then
			anchorControl = ZO_ChatWindowMail
        else
			anchorControl = GetControl(MyStatus.control, "StatusOpenDropdown") or My_Status_TLCStatusOpenDropdown
        end
    else
		if minimized then
			anchorControl = ZO_ChatWindowNumNotifications
		else
			anchorControl = ZO_ChatWindowNumNotifications
        end
    end
    if anchorControl == nil then
    	anchorControl = ZO_ChatWindowNumNotifications
    end
    return anchorControl
end

--get the main menu variable from ZOs gamepad/keyboard stuff
local function FCOGuildInfo_GetMainMenu()
    if IsInGamepadPreferredMode() then
    	return MAIN_MENU_GAMEPAD
    else
    	return MAIN_MENU_KEYBOARD
    end
end

function FCOGuildInfo:New(control)
	local object = ZO_Object.New(self)
    object.control = control -->XML defined TLC control FCOGuildInfoContainer

	--Initialize the guild info array for each guild
	local guild = {}
	self.guild = guild

	self:Initialize(control)

	return object
end

--Read the settings and unhide/hide the label/icon
function FCOGuildInfo:ToggleViewModeControls()
    --Show the icon or the text label?
    if settings.displayMode == 1 then
		self.guildMembersLabel:SetHidden(true)
		self.guildMembersIcon:SetHidden(false)
    else
		self.guildMembersLabel:SetHidden(false)
		self.guildMembersIcon:SetHidden(true)
    end
end

function FCOGuildInfo:UpdateMemberCount(guildId)
  	local numGuildMembers, newGuildOnlineMemberCount = GetGuildInfo(guildId) 	--ZO_GuildSharedInfoCount
--d("[UpdateMemberCount] members: " .. numGuildMembers .. ", online: " .. newGuildOnlineMemberCount)
	--Workaround for guild removed
    if numGuildMembers ~= nil and newGuildOnlineMemberCount ~= nil then
		self.guild[guildId] = self.guild[guildId] or {}
		self.guild[guildId].onlineMemberCount = newGuildOnlineMemberCount
		self.guild[guildId].totalMemberCount = numGuildMembers
	end

    --Build the text for the label?
    if settings.displayMode == 2 then
		local guildMembersOnlineLabelText = self:buildGuildMemberOnlineText("label")
        if guildMembersOnlineLabelText ~= nil and guildMembersOnlineLabelText ~= "" then
        	self.guildMembersLabel:SetText(guildMembersOnlineLabelText)
        end
    end
end

--Update the parent of the guild member text label
function FCOGuildInfo:updateLabelParent(minimized)
	minimized = minimized or false
    local label = self.guildMembersLabel
    --Anchor and parent to the chat window, or not
	if settings.chatParent then
		if minimized then
			label:SetParent(ZO_ChatWindowMinBar)
            FCOGuildInfoContainer:SetHidden(true)
		else
			label:SetParent(ZO_ChatWindow)
            FCOGuildInfoContainer:SetHidden(true)
        end
	else
		if minimized then
			label:SetParent(FCOGuildInfoContainer)
            FCOGuildInfoContainer:SetHidden(false)
		else
			label:SetParent(FCOGuildInfoContainer)
            FCOGuildInfoContainer:SetHidden(false)
        end
	end
end

--ReAnchor the icon and text labels to the controls in the chat window (or outside if they were manually dragged out of the chat)
function FCOGuildInfo:ReAnchorControlsInChat(minimized, startup)
	minimized = minimized or false
    startup = startup or false
    if startup then
		--Read the settings and unhide/hide the label/icon
	    self:ToggleViewModeControls()
		--Load the label movement settings and apply it to the label
	    self.guildMembersLabel:SetMovable(settings.labelMove)
    end

	--Parent and anchor controls
    local anchorControl = GetAnchorControlInChatWindow(minimized)
	local parentControl

	--Icon control
	--Reanchor the icon in the chat window again as several addons may have added icons too
    local icon = self.guildMembersIcon
	if minimized then
    	parentControl = CHAT_SYSTEM.minBar
    else
		parentControl = CHAT_SYSTEM.control
    end
	icon:SetParent(parentControl)
	icon:ClearAnchors()
	if minimized then
		if anchorControl == ZO_ChatWindowMail then
			icon:SetAnchor(BOTTOMLEFT, anchorControl, TOPLEFT, 0, 0)
        else
			icon:SetAnchor(TOPLEFT, anchorControl, BOTTOMLEFT, 0, 0)
		end
    else
		icon:SetAnchor(LEFT, anchorControl, RIGHT, settings.IconOffsetX, 0)
    end

	--Label control
    local label = self.guildMembersLabel
	label:ClearAnchors()
	if minimized then
		if settings.OffsetChatMinimizedX ~= 0 or settings.OffsetChatMinimizedY ~= 0 then
			self:updateLabelParent(minimized)
			label:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, settings.OffsetChatMinimizedX, settings.OffsetChatMinimizedY)
		else
            FCOGuildInfoContainer:SetHidden(true)
			label:SetParent(parentControl)
			if anchorControl == ZO_ChatWindowMail then
				label:SetAnchor(BOTTOMLEFT, anchorControl, TOPLEFT, 0, 0)
	        else
				label:SetAnchor(TOPLEFT, anchorControl, BOTTOMLEFT, 0, 0)
			end
		end
    else
		if settings.OffsetX ~= 0 or settings.OffsetY ~= 0 then
			self:updateLabelParent()
        	label:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, settings.OffsetX, settings.OffsetY)
		else
            FCOGuildInfoContainer:SetHidden(true)
			label:SetParent(parentControl)
			label:SetAnchor(LEFT, anchorControl, RIGHT, 2, 0)
        end
    end

end

local OrigShowMiniBar = CHAT_SYSTEM.ShowMinBar
function CHAT_SYSTEM:ShowMinBar()
	OrigShowMiniBar(self)

	FCOGuildInfo:ReAnchorControlsInChat(true, false)
end

local OrigHideMiniBar = CHAT_SYSTEM.HideMinBar
function CHAT_SYSTEM:HideMinBar()
	OrigHideMiniBar(self)

	FCOGuildInfo:ReAnchorControlsInChat(false, false)
end

function FCOGuildInfo:Initialize(control)
	local numGuilds = GetNumGuilds()
	--Initialize the guild arrays
    for guildIndex = 1, numGuilds do
		local locGuildId = GetGuildId(guildIndex)
		if locGuildId ~= nil and locGuildId > 0 then
	    	self.guild[locGuildId] = {}
			--Update the members online/total of each joined guild
			self:UpdateMemberCount(locGuildId)
		end
    end

	local icon = WINDOW_MANAGER:CreateControl("FCOChatWindowGuildInfoIcon", ZO_ChatWindow, CT_TEXTURE)
	self.guildMembersIcon 		 = icon
	local label = WINDOW_MANAGER:CreateControl("FCOChatWindowGuildInfoLabel", ZO_ChatWindow, CT_LABEL)
    self.guildMembersLabel		 = label
	CHAT_SYSTEM.guildMembersIcon = icon
	CHAT_SYSTEM.guildMembersLabel = label

	--Hide the icon and the label and unhide them later depending on the settings
	label:SetHidden(true)
	icon:SetHidden(true)

	icon:SetDimensions(32, 32)
	icon:ClearAnchors()
	--Check if other chat icon addons like MyStatus are active
    local anchorControl = GetAnchorControlInChatWindow(CHAT_SYSTEM:IsMinimized())
	icon:SetAnchor(LEFT, anchorControl, RIGHT, settings.IconOffsetX, 0)
	icon:SetDrawLayer(1)
	icon:SetMouseEnabled(true)

	label:SetDimensions(225, 32)
	label:ClearAnchors()
	label:SetAnchor(LEFT, anchorControl, RIGHT, 2, 0)
	label:SetDrawLayer(1)
	label:SetMouseEnabled(true)
    label:SetText(self:buildGuildMemberOnlineText("label"))
    label:SetFont("ZoFontGameSmall")
    --label:SetScale(0.95)
    label:SetVerticalAlignment(TOP)

	icon:SetHandler("OnMouseUp", function(self, mouseButton, upInside)
		if mouseButton == 1 and upInside then
			local mainMenuVar = FCOGuildInfo_GetMainMenu()
        	mainMenuVar:ShowScene("guildRoster")
		end
    end)
	icon:SetHandler("OnMouseEnter", function()
		--Build the tooltip text
		local guildMembersOnlineTooltipText = self:buildGuildMemberOnlineText("tooltip")
        if guildMembersOnlineTooltipText ~= nil and guildMembersOnlineTooltipText ~= '' then
	        ZO_Tooltips_ShowTextTooltip(icon, BOTTOM, guildMembersOnlineTooltipText)
        end
	end)
	icon:SetHandler("OnMouseExit", function()
		ZO_Tooltips_HideTextTooltip()
	end)
	label:SetHandler("OnMouseEnter", function()
		--Build the tooltip text
		local guildMembersOnlineTooltipText = self:buildGuildMemberOnlineText("tooltip")
        if guildMembersOnlineTooltipText ~= nil and guildMembersOnlineTooltipText ~= '' then
	        ZO_Tooltips_ShowTextTooltip(icon, BOTTOM, guildMembersOnlineTooltipText)
        end
	end)
	label:SetHandler("OnMouseExit", function()
		ZO_Tooltips_HideTextTooltip()
	end)
    label:SetHandler("OnMoveStop", function()
		if not settings.labelMove then return false end
		if not CHAT_SYSTEM:IsMinimized() then
			settings.OffsetX = label:GetLeft()
			settings.OffsetY = label:GetTop()
		else
			settings.OffsetChatMinimizedX = label:GetLeft()
			settings.OffsetChatMinimizedY = label:GetTop()
        end
    end)

	local guildMembersTextureName = 'EsoUI/Art/Guild/tabicon_roster_up.dds'
	if ZO_MainMenuSceneGroupBarButton2Image then
    	guildMembersTextureName = ZO_MainMenuSceneGroupBarButton2Image:GetTextureFileName()
    end
	self.guildMembersIcon:SetTexture(guildMembersTextureName)
end

local function OnGuildSelfLeft(event, guildId, ...)
	if guildId == nil then return false end
	--Clear all guild infos
	for locGuildId = 1, MAX_GUILDS do
		FCOGuildInfo.guild[locGuildId] = {}
	end
	--Update the count of all guilds
	for guildIndex = 1, GetNumGuilds() do
		local locGuildId = GetGuildId(guildIndex)
		if locGuildId ~= nil and locGuildId > 0 then
			--Update the count of all guild's members
			FCOGuildInfo:UpdateMemberCount(locGuildId)
		end
	end
end

local function OnGuildSelfChange(event, guildId, ...)
	if guildId == nil then return false end
	--Clear all guild infos
	for locGuildId = 1, MAX_GUILDS do
		FCOGuildInfo.guild[locGuildId] = {}
	end
	--Update the count of all guilds
	for guildIndex = 1, GetNumGuilds() do
		local locGuildId = GetGuildId(guildIndex)
		if locGuildId ~= nil and locGuildId > 0 then
			--Update the count of all guild's members
			FCOGuildInfo:UpdateMemberCount(locGuildId)
		end
	end
end

local function OnGuildCountChange(event, guildId, ...)
	if guildId == nil then return false end
	FCOGuildInfo:UpdateMemberCount(guildId)
end

local function OnGuildPlayerStatusChanged(event, guildId, displayName, oldStatus, newStatus)
	if guildId == nil or displayName == nil or newStatus == nil then return false end
    --Only react if a player gets online or offline
    if newStatus 	 == PLAYER_STATUS_ONLINE then
		FCOGuildInfo:UpdateMemberCount(guildId)
    elseif newStatus == PLAYER_STATUS_OFFLINE then
		FCOGuildInfo:UpdateMemberCount(guildId)
--[[
    elseif newStatus == PLAYER_STATUS_DO_NOT_DISTURB then
    elseif newStatus == PLAYER_STATUS_AWAY then
]]
    end
end

--Prepare the text output for the chat or the tooltip
function FCOGuildInfo:buildGuildMemberOnlineText(buildType)
	buildType = buildType or "tooltip"
	--Build the chat output text
	local chatOutputText = ''
	local numGuilds = GetNumGuilds()
--d("[buildGuildMemberOnlineText] numGuilds: " .. numGuilds)
	--For each guild: Build the text label/tooltip text and append it to the existing text
	for guildIndex = 1, numGuilds do
		local guildId = GetGuildId(guildIndex)
--d(">guildId: " ..tostring(guildId))
		if guildId ~= nil and guildId > 0 then
			if self.guild[guildId] ~= nil and self.guild[guildId].onlineMemberCount ~= nil and self.guild[guildId].totalMemberCount ~= nil then
				--local guildIdRemoved = guildId + MAX_GUILDS
				local guildIdRemoved = guildId
--d("[buildGuildMemberOnlineText] guildId: " .. guildId .. ", guildIdRemoved: " .. guildIdRemoved)
				local serverName = GetWorldName()
				local displayName = GetDisplayName()
				local rGC
	            local gGC
	            local bGC
				local messageColor
	            local pChatUseESOcolors = false
	            if pChat then
	            	pChatUseESOcolors = ((PCHAT_OPTS[serverName] and PCHAT_OPTS[serverName][displayName] and PCHAT_OPTS[serverName][displayName]["$AccountWide"] and PCHAT_OPTS[serverName][displayName]["$AccountWide"].useESOcolors) or (PCHAT_OPTS["Default"] and PCHAT_OPTS["Default"][displayName] and PCHAT_OPTS["Default"][displayName]["$AccountWide"] and PCHAT_OPTS["Default"][displayName]["$AccountWide"].useESOcolors)) or false
	            end
				--Get the current guild's color
				--is the pChat addon active?
				if pChat and not pChatUseESOcolors then
	            	messageColor = (PCHAT_OPTS[serverName] and PCHAT_OPTS[serverName][displayName]["$AccountWide"].colours[(2* (CHAT_CHANNEL_GUILD_1 + guildIndex - 1)) + 1]) or (PCHAT_OPTS["Default"] and PCHAT_OPTS["Default"][displayName] and PCHAT_OPTS["Default"][displayName]["$AccountWide"] and PCHAT_OPTS["Default"][displayName]["$AccountWide"].colours and PCHAT_OPTS["Default"][displayName]["$AccountWide"].colours[(2* (CHAT_CHANNEL_GUILD_1 + guildIndex - 1)) + 1])
				else
					if CHAT_SYSTEM and CHAT_SYSTEM.GetCategoryColorFromChannel then
						rGC, gGC, bGC = CHAT_SYSTEM:GetCategoryColorFromChannel(_G["CHAT_CHANNEL_GUILD_" .. tostring(guildIndex)])
					elseif ZO_ChatSystem_GetCategoryColorFromChannel then
						rGC, gGC, bGC = ZO_ChatSystem_GetCategoryColorFromChannel(_G["CHAT_CHANNEL_GUILD_" .. tostring(guildIndex)])
					end
				end
				if buildType == "tooltip" then
					if chatOutputText ~= '' then
						chatOutputText = chatOutputText .. '\n'
					end
					local guildName = GetGuildName(guildId)
					--Workaround after guild has been removed
					if guildName == nil or guildName == "" then
	                	guildName = GetGuildName(guildIdRemoved)
	                end
					if guildName == nil or guildName == "" then return false end
					--Colorize the guild numbers
	                if messageColor == nil and (rGC ~= nil and gGC ~= nil and bGC ~= nil) then
	                	guildName = makeColour(rGC, gGC, bGC) .. guildName .. "|r"
					elseif messageColor ~= nil then
	                	guildName = messageColor .. guildName .. "|r"
	                end
					local guildAlliance = GetGuildAlliance(guildId)
					--Workaround after guild has been removed
					if guildAlliance == nil or guildAlliance == 0 then
						guildAlliance = GetGuildAlliance(guildIdRemoved)
	                end
					if guildAlliance == nil or guildAlliance == 0 then return false end
					local guildText = zo_iconTextFormat(GetAllianceBannerIcon(guildAlliance), 24, 24, guildName) .. ":   "
					chatOutputText = chatOutputText .. guildText .. zo_strformat(SI_GUILD_NUM_MEMBERS_ONLINE_FORMAT, "|cFFFFFF" .. self.guild[guildId].onlineMemberCount .. "|r", "|cFFFFFF" .. self.guild[guildId].totalMemberCount .. "|r")

	            elseif buildType == "label" then
					--Colorize the guild numbers
	                if ( (messageColor == nil and (rGC ~= nil and gGC ~= nil and bGC ~= nil))
	                    or messageColor ~= nil) then
	                	if ( messageColor == nil and (rGC ~= nil and gGC ~= nil and bGC ~= nil)) then
							if chatOutputText ~= '' then
								chatOutputText = chatOutputText .. " " .. makeColour(rGC, gGC, bGC) .. guildIndex .. ')|r'
			                else
			                	chatOutputText = makeColour(rGC, gGC, bGC) .. guildIndex .. ')|r'
							end
						elseif messageColor ~= nil then
							if chatOutputText ~= '' then
								chatOutputText = chatOutputText .. " " .. messageColor .. guildIndex .. ')|r'
			                else
			                	chatOutputText = messageColor .. guildIndex .. ')|r'
							end
	                    end
	                else
						if chatOutputText ~= '' then
							chatOutputText = chatOutputText .. ' ' .. guildIndex .. ')'
		                else
		                	chatOutputText = guildIndex .. ')'
						end
	                end
					chatOutputText = chatOutputText .. zo_strformat(SI_GUILD_NUM_MEMBERS_ONLINE_FORMAT, "|cFFFFFF" .. self.guild[guildId].onlineMemberCount .. "|r", "|cFFFFFF" .. self.guild[guildId].totalMemberCount .. "|r")
	            end
			end
		end
	end
	if chatOutputText ~= nil and chatOutputText ~= "" then
		if buildType == "tooltip" then
			chatOutputText = locVars.preChatTextGreen .. "|cFFFFFF" .. GetString("SI_GUILDHISTORYCATEGORY", 1) .. GetString(SI_GUILD_NUM_MEMBERS_ONLINE_LABEL) .. "|r\n" .. chatOutputText
		--elseif buildType == "label" then
		end
	else
    	chatOutputText = ""
	end
    return chatOutputText
end

--Show the guild info in the chat
function FCOGuildInfo:chatOutput()
	local chatOutputText = self:buildGuildMemberOnlineText("tooltip")
	if chatOutputText ~= '' then
	   	d(chatOutputText)
	end
end

--Show the online/total guild members in the chat as you start the game
function FCOGuildInfo:autoPostToChatOnStartup()
	if settings.startupPostToChat then
    	self:chatOutput()
    end
end

--Toggle between automatically posted guild member infos to the chat on startup, or not
function FCOGuildInfo:toggleAutoPostToChatMode(mode)
	mode = mode or 'startup'
	if mode == 'startup' then
	    settings.startupPostToChat = not settings.startupPostToChat
    end
	d(locVars.preChatTextBlue .. "Toggling auto post to chat on startup to: |c22DD22" .. tostring(settings.startupPostToChat) .. "|r")
end

--Toggle between chat container = parent of the text label, or GuiRoot (FCOGuildInfoContainer control)?
function FCOGuildInfo:toggleChatParent()
	settings.chatParent = not settings.chatParent
	--Update the label's parent control now
	FCOGuildInfo:updateLabelParent(CHAT_SYSTEM:IsMinimized())
	--Show output message to the chat?
	d(locVars.preChatTextBlue .. "Toggling chat parent to: |c22DD22" .. tostring(settings.chatParent) .. "|r")
end

--Toggle between label movable, or not
function FCOGuildInfo:toggleLabelMove()
	if self.guildMembersLabel:IsHidden() == false then
		settings.labelMove = not settings.labelMove
    	self.guildMembersLabel:SetMovable(settings.labelMove)
		d(locVars.preChatTextBlue .. "Toggling text label movement to: |c22DD22" .. tostring(settings.labelMove) .. "|r")
	else
		d(locVars.preChatTextRed .. "|cFFFFFFPlease change the display mode to the text label first!|r")
    end
end

--Reset the coordinates of the moveable label and reanchor it tot he standard controls
function FCOGuildInfo:resetLabelMove()
	local reset = false
	if settings.OffsetX ~= 0 or settings.OffsetY ~= 0 then
	    settings.OffsetX = 0
	    settings.OffsetY = 0
		d(locVars.preChatTextBlue .. "Text label position reset to standard!")
        reset = true
    end
	if settings.OffsetChatMinimizedX ~= 0 or settings.OffsetChatMinimizedY ~= 0 then
	    settings.OffsetChatMinimizedX = 0
	    settings.OffsetChatMinimizedY = 0
		d(locVars.preChatTextBlue .. "Text label (chat minimized) position reset to standard!")
        reset = true
    end
	if reset then
		settings.labelMove = false
		--ReAnchor the controls again now
	    self:ReAnchorControlsInChat(CHAT_SYSTEM:IsMinimized(), true)
    end
end

--Toggle between the shown icon + tooltip & the text output
function FCOGuildInfo:toggleDisplayMode()
	local displayModeDescription = ""
    if settings.displayMode == 1 then
    	settings.displayMode = 2
       	displayModeDescription = "Show text"
    else
		settings.displayMode = 1
       	displayModeDescription = "Show icon"
    end
	--Update the controls and hide/unhide them
	self:ToggleViewModeControls()
	d(locVars.preChatTextBlue .. "Toggling display mode to: |c22DD22" .. displayModeDescription .. "|r")
end

--Change the offset of the icon
function FCOGuildInfo:changeIconOffset(x)
	if self.guildMembersLabel:IsHidden() then
	    local xOffset = tonumber(x)
	    if xOffset == nil or xOffset < -200 or xOffset > 500 then
			d(locVars.preChatTextRed .. "|cFFFFFFPlease enter a number between -200 and 500 as |cFF0000x|r offset!|r")
			return false
	    end
		settings.IconOffsetX = xOffset
		--ReAnchor the icon in the chat window
		FCOGuildInfo:ReAnchorControlsInChat(CHAT_SYSTEM:IsMinimized(), false)
		d(locVars.preChatTextBlue .. "Moving icon offset on x-axis to: |c22DD22" .. xOffset .. "|r")
	else
		d(locVars.preChatTextRed .. "|cFFFFFFPlease change the display mode to the icon first!|r")
    end
end


--Show the chat commands & info texts
function FCOGuildInfo:showHelp()
	d(locVars.preChatTextBlue .. "- |c22DD22FCO|r |cFFFFFFGuildInfo|r")
	d("> The following chat commands are possible:")
	d("|cFFFFFFAlways start with '|c22DD22/fcogi|r' or '|c22DD22/fcoguildinfo|r'|cFFFFFF!|r")
	d(": Don't enter any parameter to show the current online/total guild member of each of your guilds posted into your chat")
	d("|c22DD22h|r/|c22DD22help|r/|c22DD22aide|r: Show this help")
	d("|c22DD22dm|r/|c22DD22displayMode|r: Change the display mode between 'Icon' and 'Text' inside the chat window")
    d("|c22DD22lm|r/|c22DD22labelMove|r: Allow to move the label inside the chat window")
    d("|c22DD22lmr|r/|c22DD22labelMoveReset|r: Reset the position of the movable label inside the chat window (and in the minimized chat window)")
    d("|c22DD22cp|r/|c22DD22chatParent|r: Set the chat window as parent control of the text label, or not. Deactivate this option to show the text label even if the chat is faded out!")
	d("|c22DD22sc|r/|c22DD22startupChat|r: Automatically post the online/total guild members of each of your guilds into your chat as you start the game/do a reloadui")
	d("|c22DD22io|r/|c22DD22iconOffset|r <|cFF0000x|r>: Move the icon on the x-axis to the left (|cFF0000x|r<0) or to the right (|cFF0000x|r>0). Please enter a value for |cFF0000x|r between -200 and 500. The icon display mode must be active!")
end

--Check the commands ppl type to the chat
local function command_handler(args)
    --Parse the arguments string
	local options = {}
    local searchResult = { string.match(args, "^(%S*)%s*(.-)$") }
    for i,v in pairs(searchResult) do
        if (v ~= nil and v ~= "") then
            options[i] = string.lower(v)
        end
    end
	--Check the first parameter that was entered
	if (#options == 0 or options[1] == "") then
    	FCOGuildInfo:chatOutput()
	elseif(options[1] == "h" or options[1] == "help" or options[1] == "hilfe" or options[1] == "aide") then
    	FCOGuildInfo:showHelp()
	elseif(options[1] == "dm" or options[1] == "displayMode") then
    	FCOGuildInfo:toggleDisplayMode()
	elseif(options[1] == "lm" or options[1] == "labelMove") then
    	FCOGuildInfo:toggleLabelMove()
	elseif(options[1] == "lmr" or options[1] == "labelMoveReset") then
    	FCOGuildInfo:resetLabelMove()
	elseif(options[1] == "cp" or options[1] == "chatParent") then
		FCOGuildInfo:toggleChatParent()
	elseif(options[1] == "sc" or options[1] == "startupChat") then
    	FCOGuildInfo:toggleAutoPostToChatMode('startup')
    elseif((options[1] == "io" or options[1] == "iconOffset") and options[2] ~= nil) then
		FCOGuildInfo:changeIconOffset(options[2])
    end
end

--Register the slash commands
local function RegisterSlashCommands()
    -- Register slash commands
	SLASH_COMMANDS["/fcoguildinfo"] = command_handler
	SLASH_COMMANDS["/fcogi"] 		= command_handler
end

-------------------------------------------------------------------
--  OnPlayerActivated  --
-------------------------------------------------------------------
local function FCOGuildInfo_Player_Activated(...)
	--Initilaize the default setting values
	local defaultSettings = {
    	displayMode = 1,
        labelMove = false,
        OffsetX	= 0,
        OffsetY = 0,
        OffsetChatMinimizedX = 0,
        OffsetChatMinimizedY = 0,
        startupPostToChat = false,
		chatParent = true,
        IconOffsetX = 2,
    }
	--Load the user's settings from SavedVariables file -> Account wide of current addon version
	settings = ZO_SavedVars:NewAccountWide(addonName .. "_Settings", ADDON.savedVarsVersion, "Settings", defaultSettings)
	--ReAnchor the icon in the chat window
	FCOGuildInfo:ReAnchorControlsInChat(CHAT_SYSTEM:IsMinimized(), true)
    -- Check the settings and react on them
    FCOGuildInfo:autoPostToChatOnStartup()
end

-------------------------------------------------------------------
--  OnAddOnLoaded  --
-------------------------------------------------------------------
local function OnAddOnLoaded(event, addonNameOfEachAddon)
	if addonNameOfEachAddon ~= addonName then return end

	--Create the controls
  	FCOGuildInfo:New(FCOGuildInfoContainer)

    -- Register slash commands
    RegisterSlashCommands()

	--Register for the zone change/player ready event
	EM:RegisterForEvent(addonName, EVENT_PLAYER_ACTIVATED, FCOGuildInfo_Player_Activated)
	--Register for the guild member events
	EM:RegisterForEvent(addonName, EVENT_GUILD_MEMBER_PLAYER_STATUS_CHANGED, OnGuildPlayerStatusChanged)
    EM:RegisterForEvent(addonName, EVENT_GUILD_MEMBER_ADDED, OnGuildCountChange)
    EM:RegisterForEvent(addonName, EVENT_GUILD_MEMBER_REMOVED, OnGuildCountChange)
    EM:RegisterForEvent(addonName, EVENT_GUILD_SELF_JOINED_GUILD, OnGuildSelfChange)
    EM:RegisterForEvent(addonName, EVENT_GUILD_SELF_LEFT_GUILD, OnGuildSelfLeft)
	EM:UnregisterForEvent(addonName, EVENT_ADD_ON_LOADED)
end

---------------------------------------------------------------------
--  Register Events --
---------------------------------------------------------------------
EM:RegisterForEvent(addonName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
