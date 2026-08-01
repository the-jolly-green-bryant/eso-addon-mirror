--[[

	Chat will no longer pass the right edge of the screen and come back for scenes such as Mail
	Chat should no longer reset position if scene 
	
	
	
	WHAT WAS I USING COLLECTION OBJECTS FOR????


    if COMPANION_KEYBOARD_FRAGMENT:IsShowing() then
	else
	end
	

oh
/script d(ZO_Companion_Gamepad_TopLevel:IsHidden())
/script d(ZO_Companion_KeyboardTopLevel:IsHidden())
/script d(COMPANION_KEYBOARD_FRAGMENT:IsShowing())


	added support for gamepad dialogues
	
	
	
]]
-- TODO - Is LAYOUT_POSITION_FOUR needed? Is it not the same as LAYOUT_POSITION_RIGHT?
-- However, it may be that if screen is wider there will be space to the right of it+



--[[
TOP = 1
LEFT = 2
TOPLEFT = 3
BOTTOM = 4
BOTTOMLEFT = 6

TOPRIGHT = 9
]]

--------------------------------------------------------------------------------
-- Chat window
--------------------------------------------------------------------------------

local g_minimizeFragment = MINIMIZE_CHAT_FRAGMENT
local g_minimizeFragment_Show = g_minimizeFragment.Show
local g_minimizeFragment_Hide = g_minimizeFragment.Hide

local STATE_DISABLED				= 0
local STATE_ENABLED					= 1
local STATE_EXTRA					= 2

local LAYOUT_POSITION_INVALID		= 0

-- Above keybind strip and Hud left
local LAYOUT_POSITION_LEFT			= 1 
-- Above keybind strip and Gamepad Nav Quadrants
local LAYOUT_POSITION_ONE			= 2
local LAYOUT_POSITION_TWO			= 3
local LAYOUT_POSITION_THREE 		= 4
local LAYOUT_POSITION_FOUR			= 5
-- Above keybind strip and Hud right
local LAYOUT_POSITION_RIGHT			= 6 -- used only as reference
-- Hud bottom rght
local LAYOUT_POSITION_BOTTOMRIGHT	= 7

local MODUAL_NAME = 'IsJustaGamepadUIVisibility_DynamicChat'

local defaults = {
	['openPositions']			= {},
	['repositioned']			= false,
	['lastLayoutPosition']		= LAYOUT_POSITION_INVALID,
	['currentLayoutPosition']	= LAYOUT_POSITION_INVALID,
}

--[ZO_SharedGamepadNavQuadrantSpace] = 

local supportedControls = {
	[LAYOUT_POSITION_LEFT] = {
		ZO_ChampionPerks,
		ZO_Companion_Gamepad_TopLevel,
		ZO_InteractWindow_Gamepad,
		ZO_GameMenu_InGameNavigationContainerScroll,
		ZO_KeybindStripGamepadBackground,
	},
	[LAYOUT_POSITION_ONE] = {
		ZO_SharedGamepadNavQuadrant_1_Background,
		ZO_SharedGamepadNavQuadrant_1_StaticBackground,
		ZO_SharedGamepadNavQuadrant_1_BackgroundNestedBg,

		ZO_GamepadDialogBase,
		ZO_GamepadDialogPara,
		ZO_GamepadDialogCool,
		ZO_GamepadDialogStaticList,
		ZO_GamepadDialogItemSlider,
		
	--	ZO_GamepadNotifications,
	},
	[LAYOUT_POSITION_TWO] = {
		ZO_SharedGamepadNavQuadrant_2_Background,
		ZO_SharedGamepadNavQuadrant_1_2_Background,
		ZO_GamepadTooltipTopLevelLeftTooltipBg,
		
	},
	[LAYOUT_POSITION_THREE] = {
		ZO_SharedGamepadNavQuadrant_1_2_3_Background,
		ZO_SharedGamepadNavQuadrant_2_3_Background,
		ZO_SharedGamepadNavQuadrant_3_Background,
		ZO_HelpTutorialsDisplay_Gamepad_TopLevel,
		ZO_GamepadTooltipTopLevelQuadrant_2_3_TooltipBg,
	},
	[LAYOUT_POSITION_FOUR] = {
		ZO_SharedGamepadNavQuadrant_1_2_3_4_Background,
		ZO_SharedGamepadNavQuadrant_2_3_4_Background
	},
	[LAYOUT_POSITION_RIGHT] = {
	},
	[LAYOUT_POSITION_BOTTOMRIGHT] = {
		ZO_GameMenu_InGame
	},
}

if KelaPadUI then
	local controls_KelaPadUI = {
		[LAYOUT_POSITION_TWO] = {
			KPUI_GamepadTooltipTopLevel,
			KPUI_GamepadDialogTooltipTopLevel,
			MAIN_MENU_GAMEPAD.control
		},
		[LAYOUT_POSITION_THREE] = {
			Kela_Research,
			Kela_Undaunted
		},
	}
	
	for position, controls in pairs(controls_KelaPadUI) do
		for _, control in pairs(controls) do
			table.insert(supportedControls[position], control)
		end
	end
end


local unsuported_scenes = {
	['hud'] = true,
	['hudui'] = true,
--	['housingEditorHudUI'] = true,
	['marketAnnouncement'] = true,
}

local LAYOUT_POSITION_OFFSET = {
	[LAYOUT_POSITION_LEFT]			= LAYOUT_POSITION_LEFT,
	[LAYOUT_POSITION_ONE]			= ZO_GAMEPAD_QUADRANT_1_LEFT_OFFSET + ZO_GAMEPAD_PANEL_WIDTH, -- 526
	[LAYOUT_POSITION_TWO]			= ZO_GAMEPAD_QUADRANT_1_LEFT_OFFSET + ZO_GAMEPAD_QUADRANT_1_2_WIDTH, -- 1006
	[LAYOUT_POSITION_THREE]			= ZO_GAMEPAD_QUADRANT_1_LEFT_OFFSET + ZO_GAMEPAD_QUADRANT_1_2_3_WIDTH, -- 1384
	[LAYOUT_POSITION_FOUR]			= ZO_GAMEPAD_QUADRANT_1_LEFT_OFFSET + ZO_GAMEPAD_QUADRANT_1_2_3_4_WIDTH, -- 1864
}

local VAR_COLLECTION_SYSTEM_OBJECTS = {
	['collectionsBook'] = {
		['gamepad'] = GAMEPAD_COLLECTIONS_BOOK,
		['keyboard'] = COLLECTIONS_BOOK,
	},
	['collectionsBookComanion'] = {
		['gamepad'] = COMPANION_COLLECTION_BOOK_GAMEPAD,
		['keyboard'] = COMPANION_COLLECTION_BOOK_KEYBOARD,
	},
}

local isTop = {
	[TOP] = true,
	[TOPLEFT] = true,
	[TOPRIGHT] = true,
}

local chatAnchor = ZO_Anchor:New()
local function updateChatAnchor(control)
	chatAnchor:SetFromControlAnchor(control)
	chatAnchor:SetTarget(GuiRoot)
end

SecurePostHook('ZO_ChatSystem_OnMoveStop', function(control)
--	updateChatAnchor(control)
end)

local function getCurrentAnchor()
	local isValid, point, target, relPoint, offsetX, offsetY = KEYBOARD_CHAT_SYSTEM.control:GetAnchor(0)
	return point, target, relPoint, offsetX, offsetY
end

local function getSavedChatAnchor()
	local container = KEYBOARD_CHAT_SYSTEM.control.container
	local settings = KEYBOARD_CHAT_SYSTEM.sv.containers[container.id]
	
	return settings.point, GuiRoot, settings.relPoint, settings.x, settings.y
end

local function getOffsetY(point, currentLayoutPosition)
	if currentLayoutPosition < LAYOUT_POSITION_BOTTOMRIGHT then
		return isTop[point] and ZO_KeybindStripGamepadBackground:GetTop() - KEYBOARD_CHAT_SYSTEM.control:GetHeight() or -(ZO_KeybindStripGamepadBackground:GetHeight())
	else
		return isTop[point] and GuiRoot:GetBottom() - KEYBOARD_CHAT_SYSTEM.control:GetHeight() or 0
	end
end

local function isTextEntryOpen()
	return ZO_GetChatSystem():IsTextEntryOpen()
end

local function onShow(self, name, position)
	self:SetOpenPosition(name, position)
end

local function onHide(self, name)
	self:SetOpenPosition(name)
end

--	/script d(KEYBOARD_CHAT_SYSTEM.sv.containers[1])

--------------------------------------------------------------------------------
-- Initialize
--------------------------------------------------------------------------------

local ChatPosition = ZO_InitializingObject:Subclass()

function ChatPosition:Initialize()
	zo_mixin(self, defaults)

	self:InitializeHandlers()
end

function ChatPosition:SetState(state)
	if self.state ~= state then
		self.state = state
		self.isUpdating = false
		
		self.enabled = state > 0
		if state > 0 then
		--	self.dynamicAnchor = {point = BOTTOMLEFT, relTo = ZO_KeybindStripGamepadBackground, relPoint = BOTTOMRIGHT, x = 0, y  = 0}
			
			if not ZO_GameMenu_InGame:IsHidden() then
				self:OnShow('ZO_GameMenu_InGame', LAYOUT_POSITION_BOTTOMRIGHT)
			end
		else
			-- reset position
			if self.repositioned then
		--		self:OnHide('ZO_GameMenu_InGame', LAYOUT_POSITION_BOTTOMRIGHT)
				self:OnEffectivelyHidden('ZO_GameMenu_InGame')
			end
		end
	end
end

function ChatPosition:InitializeHandlers()
	local function setHandlers(position, control, ...)
		local function callback(ctr, onName, name, position, ...)
			self[onName](self, name, position)
		end
		
		for k, handlerName in pairs({'OnEffectivelyShown', 'OnEffectivelyHidden', 'OnShow', 'OnHide' }) do
			ZO_PostHookHandler(control, handlerName, function(ctr, ...)
				callback(ctr, handlerName, ctr:GetName(), position, ...)
			end)
		end
	end

	self.control = KEYBOARD_CHAT_SYSTEM.control
	self.id = self.control.container.id
	self.chatWindow = KEYBOARD_CHAT_SYSTEM.containers[self.id]
	
	self:Reset()
--	updateChatAnchor(self.control)
	
	for position, controls in pairs(supportedControls) do
		for _, control in pairs(controls) do
			setHandlers(position, control)
		end
	end

	HOUSING_EDITOR_HUD_UI_SCENE:RegisterCallback("StateChange",  function(oldState, newState)
		if newState == SCENE_SHOWN then
			-- lets just not move it
			self:OnShow('housingEditorHudUI', LAYOUT_POSITION_LEFT)
		elseif newState == SCENE_HIDDEN then
			self:OnHide('housingEditorHudUI')
		end
	end)

	local function setOnStop()
		local function onStop(animation, control)
			if self:IsActive() then
				if ZO_CHAT_BLOCKING_SCENE_NAMES[SCENE_MANAGER:GetCurrentSceneName()] then return end
				
				if KEYBOARD_CHAT_SYSTEM:IsMinimized() then
					if self.wasChatMaximized or self.updateLater then
						zo_callLater(ZO_ChatSystem_OnMinMaxClicked, 100)
					else
				--		ZO_ChatSystem_OnMinMaxClicked()
					end
				elseif not self.repositioned then
					-- if chat is opened on hud, reset it's position
					self:SetMaximizedAnchor()
				end
			end
		end
		
		local minimizeAnimationTimeline = self.minimizeAnimationTimeline:GetAnimation(1)
		-- Append GetName function to the timeline.
		minimizeAnimationTimeline.GetName = function() return 'KEYBOARD_CHAT_SYSTEM_minimizeAnimationTimeline' end
		ZO_PostHookHandler(minimizeAnimationTimeline, "OnStop", onStop)
	end
	
	local function onTimelineCreated()
		-- this update loop is used to capture the animation timeline after the first time the chat is minimized.
		-- It does not exist until then and is required.
		if self.chatWindow.minimizeAnimationTimeline then
			EVENT_MANAGER:UnregisterForUpdate("IJA_GamepadUIVisibility_GetAnimationTimeline")
			self.minimizeAnimationTimeline = self.chatWindow.minimizeAnimationTimeline
			setOnStop()
		end
	end
	EVENT_MANAGER:RegisterForUpdate("IJA_GamepadUIVisibility_GetAnimationTimeline", 100, onTimelineCreated)

	local function onMaximize()
		return self:OnMaximize()
	end

	ZO_PreHook(KEYBOARD_CHAT_SYSTEM, 'Maximize', function(self)
		return onMaximize()
	end)

	local function getShowDelay()
		if self:IsActive() then
			if not self.repositioned then
				return 200
			end
		end
		return 0
	end
	function g_minimizeFragment:Hide()
		zo_callLater(function()
			g_minimizeFragment_Hide(self)
		end, getShowDelay())
	end
	--[[
	function g_minimizeFragment:Show()
		g_minimizeFragment_Show(self)
	end
	]]

	self.initialized = true
end

function ChatPosition:ShowPreview()
	-- No Preview
end

--------------------------------------------------------------------------------
-- 
--------------------------------------------------------------------------------

function ChatPosition:ResetChatSavedAnchor()
	local point, target, relPoint, offsetX = getCurrentAnchor()
	
	if point ~= TOPLEFT and point ~= BOTTOMLEFT then
		
		local offsetX = self.control:GetLeft()
		local offsetY = self.control:GetTop()
		local centerX, centerY = GuiRoot:GetCenter()
		
		point = offsetY > centerY and BOTTOMLEFT or TOPLEFT
		offsetY = point == BOTTOMLEFT and GuiRoot:GetBottom() - offsetY or offsetY
		
		local settings = KEYBOARD_CHAT_SYSTEM.sv.containers[self.id]
		settings.point = point
		settings.relPoint = point
		settings.x = offsetX
		settings.y = offsetY
		
		KEYBOARD_CHAT_SYSTEM.sv.containers[self.id] = settings
	end

	self.currentLayoutPosition = LAYOUT_POSITION_INVALID
end

function ChatPosition:Reset()
	if self.currentLayoutPosition == LAYOUT_POSITION_INVALID then
		if SCENE_MANAGER:GetCurrentSceneName() == 'hud' then
			if not KEYBOARD_CHAT_SYSTEM:IsMinimized() then
				self:ResetChatSavedAnchor()
			end
		end
	end
end

function ChatPosition:GetAnchor()
	local minimized = KEYBOARD_CHAT_SYSTEM:IsMinimized()
	local point, target, relPoint, offsetX, offsetY = getSavedChatAnchor()
	
	if minimized then
		point, target, relPoint, offsetX = getCurrentAnchor()
	end

	if self.repositioned then
		offsetX, offsetY = self:GetOffsets(point)
	end
	
--	d( debug.traceback())
	return point, target, relPoint, offsetX, offsetY
end

function ChatPosition:GetOffsets(point)
	local screenRight = GuiRoot:GetRight()
	local width = ZO_ChatWindow:GetDimensions()

	local offsetX = LAYOUT_POSITION_OFFSET[self.currentLayoutPosition] or screenRight
	local offsetY = getOffsetY(point, self.currentLayoutPosition)
	
	if point ~= BOTTOMLEFT and (offsetX + width) > screenRight then
		offsetX = screenRight - width
	end

	return offsetX, offsetY
end


--------------------------------------------------------------------------------
-- 
--------------------------------------------------------------------------------

-- Resetting update handler.
function ChatPosition:OnUpdate()
	local updateName = MODUAL_NAME .. '_OnUpdate'
	EVENT_MANAGER:UnregisterForUpdate(updateName)
	
	-- TODO: add check to see if chat is in proper position?
	if self:IsActive() then
		local function onUpdate()
			EVENT_MANAGER:UnregisterForUpdate(updateName)
			self:UpdatePositions()
		end
		
		EVENT_MANAGER:RegisterForUpdate(updateName, 100, onUpdate)
	end
end

function ChatPosition:UpdatePositions()
	if not self.isUpdating then
		self.isUpdating = true

		self:UpdateCurrentLayoutPosition()
		
		if not self.updateLater then
			if self.isNew then
				if not KEYBOARD_CHAT_SYSTEM:IsMinimized() then
					local reset = self:ShouldReset(SCENE_MANAGER:GetCurrentSceneName())
					if reset then
						if self.repositioned then
							self.repositioned = false
							self:Minimize()
						end
					else
						self.repositioned = true
						self:SetMaximizedAnchor()
					end
				
				elseif self.wasChatMaximized then
					KEYBOARD_CHAT_SYSTEM:Maximize()
				end
			end
		end
		
		self.isUpdating = false
	end
end

function ChatPosition:UpdateCurrentLayoutPosition()
	local newPosition = LAYOUT_POSITION_INVALID
	
	for controlName, position in pairs(self.openPositions)do
		if position > newPosition then
			newPosition = position
		end
	end
	
	if self.state == STATE_EXTRA and newPosition >= LAYOUT_POSITION_LEFT then
		newPosition = newPosition < LAYOUT_POSITION_BOTTOMRIGHT and LAYOUT_POSITION_RIGHT or newPosition
	end
	
	self.currentLayoutPosition = newPosition
	
	local isNew = self.lastLayoutPosition ~= self.currentLayoutPosition
	if isNew then
		self.lastLayoutPosition = self.currentLayoutPosition
	end

	self.isNew = isNew
end

function ChatPosition:TryUpdating()
	if self:IsActive() then
		self:OnUpdate()
	end
end

function ChatPosition:OnEffectivelyShown(...)
	onShow(self, ...)
end

function ChatPosition:OnShow(...)
	onShow(self, ...)
end

function ChatPosition:OnHide(...)
	onHide(self, ...)
end

function ChatPosition:OnEffectivelyHidden(...)
	onHide(self, ...)
end

function ChatPosition:SetOpenPosition(name, position)
	self.openPositions[name] = position
	self:TryUpdating()
end

function ChatPosition:ShouldUpdateLater()
	if self.minimizeAnimationTimeline then
		return self.minimizeAnimationTimeline:IsPlaying() and self.isNew
	end
	
	return false
end

function ChatPosition:ShouldReset(sceneName)
	if unsuported_scenes[sceneName] then
		return self.currentLayoutPosition == LAYOUT_POSITION_INVALID
	end
	
	return ZO_CHAT_BLOCKING_SCENE_NAMES[sceneName] ~= nil
end

--------------------------------------------------------------------------------
-- 
--------------------------------------------------------------------------------

function ChatPosition:OnMaximize()
	if self:IsActive() then
		self.wasChatMaximized = false
		
		self.updateLater = self:ShouldUpdateLater()
		if not self.updateLater then
			self:UpdateCurrentLayoutPosition()
			self:SetMinimizedAnchor()
			self.chatWindow.originalPosition = self:GetMaximizeDistance()
			self.repositioned = self.currentLayoutPosition ~= LAYOUT_POSITION_INVALID
		else
			
			-- Let the chat window stop moving before updating.
			return true
		end
	end
end

function ChatPosition:Minimize()
	self.wasChatMaximized = not KEYBOARD_CHAT_SYSTEM:IsMinimized()
	if self.wasChatMaximized then
		KEYBOARD_CHAT_SYSTEM:Minimize()
	end
end

function ChatPosition:GetMaximizeDistance()
	local offsetX = self:GetOffsets(self.point)
	
	if self.currentLayoutPosition == LAYOUT_POSITION_INVALID then
		offsetX = select(4, getSavedChatAnchor())
	end

	local width = self.currentLayoutPosition < LAYOUT_POSITION_RIGHT and KEYBOARD_CHAT_SYSTEM.control:GetWidth() or 0
	return offsetX + width
end

function ChatPosition:SetMinimizedAnchor()
	local point, target, relPoint, offsetX = getCurrentAnchor()
	local offsetY = getOffsetY(point, self.currentLayoutPosition)

	if self.currentLayoutPosition == LAYOUT_POSITION_INVALID then
		offsetY = select(5, getSavedChatAnchor())
	end
	self.point = point
	self:SetAnchor(point, target, relPoint, offsetX, offsetY)
end

function ChatPosition:SetMaximizedAnchor()
	local point, target, relPoint, offsetX, offsetY = self:GetAnchor()
	self:SetAnchor(point, target, relPoint, offsetX, offsetY)
end

function ChatPosition:SetAnchor(point, target, relPoint, offsetX, offsetY)
--	self.repositioned = self.currentLayoutPosition ~= LAYOUT_POSITION_INVALID

	local anchor = ZO_Anchor:New(point, target, relPoint, offsetX, offsetY)
	anchor:Set(KEYBOARD_CHAT_SYSTEM.control)
end

--------------------------------------------------------------------------------
-- 
--------------------------------------------------------------------------------

function ChatPosition:IsActive()
	return self.repositioned or self.enabled
end

do -- safeRegisterSystemObject
	local function safeRegisterSystemObject(systemName, object, platform)
		local system = SYSTEMS:GetSystem(systemName)

		if system[platform] == nil then
			system[platform] = object
		end
	end

	for systemName, object in pairs(VAR_COLLECTION_SYSTEM_OBJECTS) do
		safeRegisterSystemObject(systemName, object.gamepad, 'gamepadObject')
		safeRegisterSystemObject(systemName, object.keyboard, 'keyboardObject')
	end
end

--------------------------------------------------------------------------------
-- 
--------------------------------------------------------------------------------

function IJA_GamepadUIVisibility_ChatPosition_Initialize(state)
	return ChatPosition:New(state)
end