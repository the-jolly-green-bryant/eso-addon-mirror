-- ***** Pawprint's PVP Tools - AMS *****
-- Addon Message System



--------------------------------------------------
-- Initialize our namespace
--------------------------------------------------
if not PVPTools then PVPTools = {} end
if not PVPTools.AMS then PVPTools.AMS = {} end
local PT = PVPTools
local AMS = PVPTools.AMS
local questShareTag = "|c00ffff[QS] |r"
local QOLTag 		= "|c62d27f[QOL] |r"
local mapPinsTag 	= "|DEB877[MP] |r"
local MBTag 		= "|c62d27f[M&B] |r"
local AITag			= "|cAF54D1[AI] |r"
-- error message color: |cff0000

--------------------------------------------------
-- MESSAGE WINDOW FUNCTIONS
-- Choose a more catchy name in the future when we create the message window system.  For now just have a quick dump to user's chat window
--------------------------------------------------

-- TODO message window


--------------------------------------------------
-- DisplayChatMessage - display a message in the chat window
--------------------------------------------------
function AMS.DisplayChatMessage(message, tag)
	if PT.debug then PT.DebugEntry("PVPTools.AMS.DisplayChatMessage") end
	if not message then message = "NO MESSAGE" end
	
	if tag == "qs" then message = questShareTag .. message end
	if tag == "qol" then message = QOLTag .. message end
	if tag == "mb" then message = MBTag .. message end
	if tag == "ai" then message = AITag .. message end
	
	CHAT_ROUTER:AddSystemMessage(message)
end


--------------------------------------------------
-- DisplayAlertMessage - display a message in the right side alert area with audible warning
--------------------------------------------------
function AMS.DisplayAlertMessage(message, sound)
	if PT.debug then PT.DebugEntry("PVPTools.AMS.DisplayAlertMessage") end
	-- ZO_Alert(category, soundId, message, ...) --... is zo_strformat arguments like <<1> <<2>> etc.
	ZO_Alert(nil, sound, message)
end


--------------------------------------------------
-- DisplayCenterAnnounce - display a message in the center screen announcement area with associated sound
--------------------------------------------------
function AMS.DisplayCenterAnnounce(message, sound)
	-- Return format is
	--  Category - The alert category to send the alert to
		-- https://wiki.esoui.com/Globals#CenterScreenAnnouncementCategory
	--  SoundId - An optional sound id to play along with the message
	--  Message - The message to alert (either a string or a function that returns a string that will be called every frame)
	--  (Optional) Message2 - For combined text, the secondary text to display (either a string or a function that returns a string that will be called every frame)
	--  (Optional) icon - An icon to be displayed with the announcement
	--  (Optional) expiringCallback - A callback to be called when the announcement has begun fading out
	--  (optional) bar params
	--  (optional) lifespan of the message to be on the screen in milliseconds
	--
	-- NOTE: If a later optional return is used, the previous optional returns must be used as well (even if they return nil)
	-- If Category or Message is nil, then nothing will be shown. Simply not returning anything tells the system to not do anything.
	-- https://github.com/esoui/esoui/blob/2f36d35381b8ce4f5ebdb828ff54b312458e1221/esoui/ingame/centerscreenannounce/centerscreenannounce.lua#L102
	-- sound = sound or PT.soundDefault  Maybe we want the otption to silently display the message??
	if PT.debug then PT.DebugEntry("PVPTools.AMS.DisplayCenterAnnounce") end
	local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, sound)
	messageParams:SetText(message)
	messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_CHAMPION_POINT_GAINED)
	messageParams:MarkSuppressIconFrame()
	messageParams:MarkShowImmediately()
	messageParams:SetLifespanMS(2000)
	-- CENTER_SCREEN_ANNOUNCE:QueueMessage(messageParams)
	CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
end


--------------------------------------------------
-- DisplayMessage - process a message to be displayed
--------------------------------------------------
function AMS.DisplayMessage(message, msgModule)
	if PT.debug then PT.DebugEntry("Message System is to display . . .\n" .. message) end
	-- msgModule is the abbreviation of the module making the request in lowercase letters
	msgModule = msgModule or nil
	
	if not msgModule then AMS.DisplayChatMessage(message) end
	
	if msgModule == "qs" then
		if PT.ASV.settingsQSCenterAnnounce then AMS.DisplayCenterAnnounce(questShareTag..message) end
		if PT.ASV.settingsQSAlert then AMS.DisplayAlertMessage(questShareTag..message) end
		AMS.DisplayChatMessage(questShareTag..message)
	end	
	
	if msgModule == "qol" then
		if PT.ASV.settingsQOLCenterAnnounce then AMS.DisplayCenterAnnounce(QOLTag..message) end
		if PT.ASV.settingsQOLAlert then AMS.DisplayAlertMessage(QOLTag..message) end
		AMS.DisplayChatMessage(QOLTag..message)
	end	
	
	if msgModule == "mb" then
		AMS.DisplayCenterAnnounce(MBTag..message)
		AMS.DisplayChatMessage(MBTag..message)
	end
	
	if msgModule == "ai" then
		AMS.DisplayCenterAnnounce(AITag..message)
		AMS.DisplayChatMessage(AITag..message)
	end
end


--------------------------------------------------
-- SoundError - trigger the error message sound
--------------------------------------------------
function AMS.SoundError()
	PlaySound(PT.soundError)
end


--------------------------------------------------
-- SoundWarning - trigger the warning sound
--------------------------------------------------
function AMS.SoundWarning()
	PlaySound(PT.soundWarning)
end

