
local defaults = {
	displayName = "|cFF00FFIsJusta|r |cffffffChat Right|r",
	name = "IJA_ChatRight",
	version = "1",
}


---------------------------------------------------------------------------------------------------------------
-- Initialize
---------------------------------------------------------------------------------------------------------------
local addon = ZO_InitializingObject:Subclass()

function addon:Initialize(control)
	self.control = control

	zo_mixin(self, defaults)
	
	local function OnLoaded(_, name)
		if name ~= defaults.name then return end
	end
	local function onPlayerActivated()
		self.control:UnregisterForEvent(EVENT_PLAYER_ACTIVATED)
		ApplyTemplateToControl(KEYBOARD_CHAT_SYSTEM.control, 'IJA_ChatRight_Right_Template')
	--	ApplyTemplateToControl(ZO_ChatWindow, "IJA_ChatRight_Right_Template")
		d( self.displayName .. " version: " .. self.version)
	end
	self.control:RegisterForEvent(EVENT_PLAYER_ACTIVATED, onPlayerActivated)
    control:RegisterForEvent( EVENT_ADD_ON_LOADED, OnLoaded)
end

---------------------------------------------------------------------------------------------------------------
-- 
---------------------------------------------------------------------------------------------------------------
function KEYBOARD_CHAT_SYSTEM:ShowMinBar()
    --clear the anchors
    self.mailButton:ClearAnchors()
    self.mailLabel:ClearAnchors()
    self.friendsButton:ClearAnchors()
    self.friendsLabel:ClearAnchors()
    self.notificationsButton:ClearAnchors()
    self.notificationsLabel:ClearAnchors()
    self.minBar.maxButton:ClearAnchors()
    self.agentChatButton:ClearAnchors()

    --reset the parentage for fading purposes
    self.mailButton:SetParent(self.minBar)
    self.mailLabel:SetParent(self.minBar)
    self.friendsButton:SetParent(self.minBar)
    self.friendsLabel:SetParent(self.minBar)
    self.notificationsButton:SetParent(self.minBar)
    self.notificationsLabel:SetParent(self.minBar)
    self.agentChatButton:SetParent(self.minBar)

    --reanchor everything
    self.mailButton:SetAnchor(TOPRIGHT, nil, nil, -4, 265)
    self.mailLabel:SetAnchor(TOPLEFT, self.mailButton, BOTTOMLEFT, 0, -5)
    self.mailLabel:SetAnchor(TOPRIGHT, self.mailButton, BOTTOMRIGHT, 0, -5)
    self.friendsButton:SetAnchor(TOPLEFT, self.mailLabel, BOTTOMLEFT)
    self.friendsLabel:SetAnchor(TOPLEFT, self.friendsButton, BOTTOMLEFT, 0, -5)
    self.friendsLabel:SetAnchor(TOPRIGHT, self.friendsButton, BOTTOMRIGHT, 0, -5)
    self.notificationsButton:SetAnchor(TOPLEFT, self.friendsLabel, BOTTOMLEFT)
    self.notificationsLabel:SetAnchor(TOPLEFT, self.notificationsButton, BOTTOMLEFT, 0, -5)
    self.notificationsLabel:SetAnchor(TOPRIGHT, self.notificationsButton, BOTTOMRIGHT, 0, -5)
    self.agentChatButton:SetAnchor(TOPLEFT, self.notificationsLabel, BOTTOMLEFT)
    self.minBar.maxButton:SetAnchor(TOPLEFT, self.agentChatButton, BOTTOMLEFT)

    --center the labels
    self.mailLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.friendsLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.notificationsLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    self.minBar:SetHidden(false)
    self.isMinimized = true
end

local function OnPlay(animation, control)
	control.container:SetMinimizingOrMaximizing(true)
	control:SetClampedToScreen(false)
end

local function OnStop(animation, control)
	local progress = animation:GetTimeline():GetProgress()
--	local maximized = animation:GetDeltaOffsetX() >= 0
	local maximized = (not KEYBOARD_CHAT_SYSTEM.isMinimized)
	control:SetClampedToScreen(maximized)
	control.container:SetMinimizingOrMaximizing(false)
end

local function GetOrCreateMinimizeAnimationTimeline(container)
	if not container.minimizeAnimationTimeline then
		local animationTimeline = ANIMATION_MANAGER:CreateTimelineFromVirtual("ChatMinMaxAnim", container.control)
		container.minimizeAnimationTimeline = animationTimeline

		local animation = animationTimeline:GetAnimation(1)
		animation:SetHandler("OnPlay", OnPlay)
		animation:SetHandler("OnStop", OnStop)
	end

	return container.minimizeAnimationTimeline
end

function KEYBOARD_CHAT_SYSTEM:Minimize()
	if not self.isMinimized then
		-- Slide all chat windows off the left edge of the screen
		for _, container in pairs(self.containers) do
			local animationTimeline = GetOrCreateMinimizeAnimationTimeline(container)

			-- If the animation is still playing keep the same positions;
			-- otherwise save the current position and calculate the minimize distance
			local minimizeDistance
			if not animationTimeline:IsPlaying() then
				minimizeDistance = container.control:GetRight()
				container.originalPosition = minimizeDistance
			else
				minimizeDistance = container.originalPosition
			end

			local distanceToRight = GuiRoot:GetRight() - minimizeDistance
			-- Additional margin to ensure the container is completely hidden
			minimizeDistance = minimizeDistance + 40 + distanceToRight
	
			-- Set the animation distance
		--	animationTimeline:GetAnimation(1):SetTranslateDeltas(-minimizeDistance, 0)
			animationTimeline:GetAnimation(1):SetTranslateDeltas(minimizeDistance, 0)

			-- Fire the animation
			animationTimeline:PlayFromStart()

			-- Hide all the tabs at the top
			for _, tab in pairs(container.tabGroup.m_Buttons) do
				tab:SetHidden(true)
			end

			container.overflowTab:SetHidden(true)
			container.newWindowTab:SetHidden(true)
		end

		-- Move the buttons to and show the minimized bar
		PlaySound(SOUNDS.CHAT_MINIMIZED)
		self:ShowMinBar()
	end
end

function KEYBOARD_CHAT_SYSTEM:Maximize()
	if self.isMinimized then
		for _, container in pairs(self.containers) do
			-- Calculate the distance to the original position
			
			local distanceToRight = GuiRoot:GetRight() - container.originalPosition
			local maximizeDistance = container.control:GetRight() - container.originalPosition

			-- Setup the animation and fire it
			local animationTimeline = GetOrCreateMinimizeAnimationTimeline(container)
		--	animationTimeline:GetAnimation(1):SetTranslateDeltas(maximizeDistance, 0)
			animationTimeline:GetAnimation(1):SetTranslateDeltas(-maximizeDistance, 0)
			animationTimeline:PlayFromStart()

			-- Show the tabs that haven't overflowed
			for _, tab in pairs(container.tabGroup.m_Buttons) do
				if tab.index < container.hiddenTabStartIndex then
					tab:SetHidden(false)
				else
					container.overflowTab:SetHidden(false)
				end
			end
			container.newWindowTab:SetHidden(false)

			container:FadeIn()
		end

		-- Hide the minimized bar and fade in the windows
		PlaySound(SOUNDS.CHAT_MAXIMIZED)
		self:HideMinBar()

		if self.newChatFadeAnim and self.newChatFadeAnim:IsPlaying() then
			self.newChatFadeAnim:Stop()
			self.minBar.bgHighlight:SetAlpha(0)
		end
	end
end

---------------------------------------------------------------------------------------------------------------
-- XML Handlers
---------------------------------------------------------------------------------------------------------------
function IJA_ChatRight_Initialize(...)
	IJA_CHATRIGHT = addon:New(...)
end
