--[[
Author: Kyoma
Filename: LibCSA.lua
Version: 1.1

Description: This library serves to provide a global  enhancement of the center screen announcement system to make it more flexible
             for wider purposes. 
             Additions: 
              - Handlers:
                  + Global hooking of handlers using the new message params system, means addons won't have to duplicate original code when they only
                    want to add or modify something. 
              - Countdown:
                  + Text can now be provided to display a text above the countdown while it happens.
                  + Icon is no longer mandatory and will be skipped if not provided. Instead the countdown is all the way to 0 instead of ending at 1.
                  + Easy termination of a countdown before it is completed.

]]--

local libLoaded
local LIB_NAME, VERSION = "LibCSA", 1.1
local lib, oldminor = LibStub:NewLibrary(LIB_NAME, VERSION)
if not lib then return end

local CSA = CENTER_SCREEN_ANNOUNCE
local CSA_LINE_TYPE_COUNTDOWN = ZO_CenterScreenAnnouncementCountdownLine.GetLineType({}) -- we grab the local variable with this 'hack'

--TODO: prettify these hooks
local ZO_CenterScreenAnnouncementCountdownLine_Initialize
local ZO_CenterScreenAnnouncementCountdownLine_Reset
local ZO_CenterScreenAnnouncementCountdownLine_SetMessageParams
local ZO_CenterScreenAnnouncementCountdownLine_SetEndImageTexture 
local ZO_CenterScreenAnnouncementCountdownLine_OnCountDownAnimationEnd

local function Unload()

	if ZO_CenterScreenAnnouncementCountdownLine_Initialize then
		ZO_CenterScreenAnnouncementCountdownLine.Initialize = ZO_CenterScreenAnnouncementCountdownLine_Initialize
	end
	if ZO_CenterScreenAnnouncementCountdownLine_Reset then
		ZO_CenterScreenAnnouncementCountdownLine.Reset = ZO_CenterScreenAnnouncementCountdownLine_Reset
	end
	if ZO_CenterScreenAnnouncementCountdownLine_SetMessageParams then
		ZO_CenterScreenAnnouncementCountdownLine.SetMessageParams = ZO_CenterScreenAnnouncementCountdownLine_SetMessageParams
	end
	if ZO_CenterScreenAnnouncementCountdownLine_SetEndImageTexture then
		ZO_CenterScreenAnnouncementCountdownLine.SetEndImageTexture = ZO_CenterScreenAnnouncementCountdownLine_SetEndImageTexture
	end
	if ZO_CenterScreenAnnouncementCountdownLine_OnCountDownAnimationEnd then
		ZO_CenterScreenAnnouncementCountdownLine.OnCountDownAnimationEnd = ZO_CenterScreenAnnouncementCountdownLine_OnCountDownAnimationEnd
	end

end

local function Load()

	--ZO_CenterScreenMessageParams.SetLineType = function(self, lineType)
	--	self.lineType = lineType
	--end
    --
	-- ZO_CenterScreenMessageParams.GetLineType = function(self)
	--	return self.lineType
	--end

	-- create a global, seperate line because we dont want it to be affected by the countdown animation
	if not CSA.countdownLineHeader then
		CSA.countdownLineHeader = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)Header", CSA.countdownLineContainer, "ZO_CenterScreenAnnounceSmallTextTemplate")
		CSA.countdownLineHeader:ClearAnchors()
		CSA.countdownLineHeader:SetAnchor(BOTTOM, CSA.countdownLineContainer, TOP, 0, -30)
		-- keep track of the number of countdowns so we can determine 'ownership'
		CSA.countdownLineIndex = 0
		-- we 'borrow' ZOS' code for platform-based font
		ZO_CenterScreenAnnouncementSmallLine.ApplyPlatformStyle({control = CSA.countdownLineHeader})
	end

	ZO_CenterScreenAnnouncementCountdownLine_Initialize = ZO_CenterScreenAnnouncementCountdownLine.Initialize
	ZO_CenterScreenAnnouncementCountdownLine.Initialize = function(self, control)
		ZO_CenterScreenAnnouncementCountdownLine_Initialize(self, control)
		self.textControl = CSA.countdownLineHeader
		self.textControl:SetHidden(true)
		self.skipEndImage = true
		CSA.countdownLineIndex = CSA.countdownLineIndex + 1
		self.index = CSA.countdownLineIndex
	end

	ZO_CenterScreenAnnouncementCountdownLine_Reset = ZO_CenterScreenAnnouncementCountdownLine.Reset
	ZO_CenterScreenAnnouncementCountdownLine.Reset = function(self)
		ZO_CenterScreenAnnouncementCountdownLine_Reset(self)
		self.textControl:SetText("")
		self.textControl:SetHidden(true)
		self.skipEndImage = true
		CSA.countdownLineIndex = CSA.countdownLineIndex + 1
		self.index = CSA.countdownLineIndex
	end

	ZO_CenterScreenAnnouncementCountdownLine_SetMessageParams = ZO_CenterScreenAnnouncementCountdownLine.SetMessageParams
	ZO_CenterScreenAnnouncementCountdownLine.SetMessageParams = function(self, messageParams)
		ZO_CenterScreenAnnouncementCountdownLine_SetMessageParams(self, messageParams)
		local text = messageParams:GetMainText()
		if text ~= nil and text ~= "" then 
			self.textControl:SetText(text)
			self.textControl:SetHidden(false)
		else
			self.textControl:SetText("")
			self.textControl:SetHidden(true)
		end
	end

	ZO_CenterScreenAnnouncementCountdownLine_SetEndImageTexture = ZO_CenterScreenAnnouncementCountdownLine.SetEndImageTexture 
	ZO_CenterScreenAnnouncementCountdownLine.SetEndImageTexture = function(self, texture)
		if texture ~= nil and texture ~= "" then
			self.endImageControl:SetTexture(texture)
			self.skipEndImage = false
		else
			self.skipEndImage = true
		end
	end

	ZO_CenterScreenAnnouncementCountdownLine_OnCountDownAnimationEnd = ZO_CenterScreenAnnouncementCountdownLine.OnCountDownAnimationEnd
	ZO_CenterScreenAnnouncementCountdownLine.OnCountDownAnimationEnd = function(self, completedPlayback)
		if not completedPlayback then return end

		self.currentCountdownTimeS = self.currentCountdownTimeS - 1
		
		if self.currentCountdownTimeS > 0 then
			self:PlayCountdownLoopAnimation()
		elseif self.endImageControl:IsHidden() then
			if self.skipEndImage then 
				if self.currentCountdownTimeS == 0 then
					self:PlayCountdownLoopAnimation()
				else
					self.countdownEndImageAnimationTimeline:PlayInstantlyToEnd()
				end
			else
				self.messageParams:PlaySound()
				self.endImageControl:SetHidden(false)
				self.countdownControl:SetText("")
				self.countdownEndImageAnimationTimeline:PlayFromStart()
			end
		end
	end
	
	--ZO_CenterScreenAnnouncementCountdownLine.SetText = function(self, text)
	--    self:TrySettingDynamicText(self.textControl, text)
	--end

	lib.Unload = Unload
end

local CSH = ZO_CenterScreenAnnounce_GetHandlers()
function lib:HookHandler(eventId, hook)
	local originalHandler = CSH[eventId]
	CSH[eventId] = function(...)
		local messageParams = originalHandler(...)
		return hook(messageParams, ...)
	end
end

function lib:CreateCountdown(displayTimeMs, soundId, endIcon, mainText, secondaryText)
	local messageParams = CSA:CreateMessageParams(CSA_CATEGORY_COUNTDOWN_TEXT, soundId)
	messageParams:SetLifespanMS(displayTimeMs)
	messageParams:SetText(mainText, secondaryText)
	messageParams:SetIconData(endIcon)
	messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_COUNTDOWN)
	CSA:AddMessageWithParams(messageParams)
	-- since CENTER_SCREEN_ANNOUNCE_TYPE_COUNTDOWN is displayed immediately we grab it
	local line = CSA:GetMostRecentLine(CSA_LINE_TYPE_COUNTDOWN)
	return line and line.index or 0
end

function lib:EndCountdown(index)
	local line = CSA:GetMostRecentLine(CSA_LINE_TYPE_COUNTDOWN)
	if line and (line.index == index or index == nil) then -- yes we check for nil and not zero
		CSA:RemoveActiveLine(line)
	end
end

function lib:HasActiveCountdown()
	return CSA:HasActiveLines(CSA_LINE_TYPE_COUNTDOWN) 
end

if(lib.Unload) then lib.Unload() end
Load()
