--[[----------------------------------------------------------
    CurvyHud 
    ----------------------------------------------------------
	Localization 	: 	/Main/MoveMode.lua 
    Original Author	:	Niocwy
	Update Author 	:	Vvarderen
    Version			: 	6.12
    Updated			:  	2020-06-20 (YYYY-MM-DD)
----------------------------------------------------------]]--

local L = CurvyHud:GetLoc()

function CurvyHud:MoveMode()
	-- Initializing all movable frames to support movement
	for frameName, frame in pairs(CurvyHud.movableFrames) do
		CurvyHud:BuildMoveBackdrop(frameName, frame)
		-- when a frame start moving, we continuously update the related setter and configuration
		-- hopefully, frames are only movable in move mode
		frame:SetHandler("OnMoveStart",  
			function(self) 	
				EVENT_MANAGER:RegisterForUpdate('CurvyHud',  50, 
					function()
						if(CurvyHud.positionPanel ~= nil) then
							CurvyHud:UpdatePosition(frameName,  self)
						end
					end
				)
			end
		)
		frame:SetHandler("OnMoveStop", 
			function(self)
				EVENT_MANAGER:UnregisterForUpdate('CurvyHud')
			end
		)
	end
	-- CurvyHud.moveMode.lockContainers = false
	CurvyHud.moveMode.lockTextValues = false
end

local function round(num) 

	if (num >= 0) then 
		return math.floor(num+.5) 
	else 
		return math.ceil(num-.5) 
	end
end


function CurvyHud:BuildMoveBackdrop(frameName, frame)
	
	local c = frame

	c.bg = WINDOW_MANAGER:CreateControl(nil, c, CT_BACKDROP)
	c.bg:SetCenterColor(unpack(CurvyHud.colorTable["purpleLow"]))
	c.bg:SetEdgeColor(unpack(CurvyHud.colorTable["purpleHight"]))
	c.bg:SetEdgeTexture('', 8, 1, 2)
	c.bg:SetAnchorFill(c)
	c.bg:SetHidden(true)
end

function CurvyHud:BuildPositionPanel()
	-- Creating the positions panel
	local panel = WINDOW_MANAGER:CreateTopLevelWindow('Curvy_MoveModePanel')
	panel:SetAnchor(BOTTOMRIGHT)
	panel:SetDimensions(480, 320)
	panel:SetMovable(true)
	panel:SetClampedToScreen(true)
	panel:SetClampedToScreenInsets(10, 10, 10, 10)
	panel:SetMouseEnabled(true)
	panel.bg = WINDOW_MANAGER:CreateControlFromVirtual(nil,  panel,  "ZO_DefaultBackdrop")
	-- Logo
	local logo = WINDOW_MANAGER:CreateControl(nil,  panel, CT_TEXTURE)
	logo:SetDimensions(153, 77)
	logo:SetAnchor(TOP, title, TOP, 0, -100)
	logo:SetTexture(CurvyHud.name.."/textures/icons/logo.dds")
	-- header
	local title = WINDOW_MANAGER:CreateControl(nil,  panel, CT_LABEL)
	title:SetFont("ZoFontHeader3")
	title:SetDimensions(panel:GetWidth(), 40)
	title:SetAnchor(TOP)
	title:SetVerticalAlignment(TEXT_ALIGN_TOP)
	title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	title:SetText(L.Move_CoordsHeader)
	panel:SetHidden(false)
	panel.header = title
	-- creating setters for all movable frames
	-- could loop on it,  but we want some kind of order
	panel.setters = {}
	local setters = panel.setters
	
	local c = title
	local bar = CurvyHud.bars
	c = self:CreatePositionSetter(panel, L.Move_barContainerLeft, CurvyHud.barContainerLeft, c)
	setters['barContainerLeft'] = c 
	c = self:CreatePositionSetter(panel, L.Move_barContainerRight, CurvyHud.barContainerRight, c)
	setters['barContainerRight'] = c 
	c = self:CreatePositionSetter(panel, L.Move_targetNameplate, CurvyHud.targetNameplate, c)
	setters['targetNameplate'] = c 
	c = self:CreatePositionSetter(panel, L.Move_taunt, CurvyHud.taunt, c)
	setters['taunt'] = c 
	c = self:CreatePositionSetter(panel, L.Move_interactionPrompt, CurvyHud.interactionPrompt, c)
	setters['interactionPrompt'] = c 
	c = self:CreatePositionSetter(panel, L.Move_PlayerinteractionPrompt, CurvyHud.playerinteractionPrompt, c)
	setters['playerinteractionPrompt'] = c 
	c = self:CreatePositionSetter(panel, L.Move_healthBarText, bar.healthBar.textContainer, c)
	setters['healthBarText'] = c 
	c = self:CreatePositionSetter(panel, L.Move_magickaBarText, bar.magickaBar.textContainer, c)
	setters['magickaBarText'] = c 
	c = self:CreatePositionSetter(panel, L.Move_staminaBarText, bar.staminaBar.textContainer, c)
	setters['staminaBarText'] = c 
	c = self:CreatePositionSetter(panel, L.Move_targetBarText, bar.targetBar.textContainer, c)
	setters['targetBarText'] = c
	c = self:CreatePositionSetter(panel, L.Move_mountBarText, bar.mountBar.textContainer, c)
	setters['mountBarText'] = c
	c = self:CreatePositionSetter(panel, L.Move_werewolfBarText, bar.werewolfBar.textContainer, c)
	setters['werewolfBarText'] = c
	c = self:CreatePositionSetter(panel, L.Move_siegeBarText, bar.siegeBar.textContainer, c)
	setters['siegeBarText'] = c
	c = self:CreatePositionSetter(panel, L.Move_shieldText, bar.healthBar.shield.textContainer, c)
	setters['shieldText'] = c
	c = self:CreatePositionSetter(panel, L.Move_targetShieldText, bar.targetBar.shield.textContainer, c)
	setters['targetShieldText'] = c 
	c = self:CreatePositionSetter(panel, L.Move_LowAttributesAlert, CurvyHud.lowAttributes, c)
	setters['lowAttributes'] = c
	c = self:CreatePositionSetter(panel, L.Move_combatTips, CurvyHud.combatTips, c)
	setters['combatTips'] = c 
	c = self:CreatePositionSetter(panel, L.Move_clepsydre, CurvyHud.clepsydre, c)
	setters['clepsydre'] = c 	
	
	panel:SetHeight(math.abs(title:GetTop() - c:GetBottom()))
	CurvyHud.positionPanel = panel
end

function CurvyHud:CreatePositionSetter(parent, labelText, frame, previousControl)
	
	local control = WINDOW_MANAGER:CreateControl(nil,  parent, CT_CONTROL)
	local anchorConfig = frame.anchorConfig
	control:SetAnchor(TOPLEFT, previousControl, BOTTOMLEFT)
	control:SetDimensions(parent:GetWidth(), 30)
	-- label
	local label = WINDOW_MANAGER:CreateControl(nil, control, CT_LABEL)
	label:SetDimensions(250, 28)
	label:SetAnchor(TOPLEFT)
	label:SetFont("ZoFontWinH4")
	label:SetText(labelText)
	-- X label
	local Xlabel = WINDOW_MANAGER:CreateControl(nil, control, CT_LABEL)
	Xlabel:SetDimensions(30, 28)
	Xlabel:SetAnchor(LEFT, label, RIGHT, 0, 0)
	Xlabel:SetFont("ZoFontWinH4")
	Xlabel:SetText("X = ")
	
	local XeditBoxBg = WINDOW_MANAGER:CreateControlFromVirtual(nil,  control,  "ZO_EditBackdrop")
	XeditBoxBg:SetDimensions(55, 26) -- box to x coords
	XeditBoxBg:SetAnchor(LEFT, Xlabel, RIGHT, 0, -3)
	XeditBox = WINDOW_MANAGER:CreateControlFromVirtual(nil,  XeditBoxBg,  "ZO_DefaultEditForBackdrop")
	XeditBox:SetText(anchorConfig[4])
	XeditBox:SetHandler("OnFocusLost",  
		function(self)
			local text = self:GetText()
			local goodNumber,  x = string.gsub(text, "[^0-9-]", "")
			if(x > 0 or tonumber(text) == nil) then
				frame.anchorConfig[4] = "0"
				self:GetText("0")
				frame:ClearAnchors()
				frame:SetAnchor(unpack(frame.anchorConfig))
			else
				frame.anchorConfig[4] = text
				frame:ClearAnchors()
				frame:SetAnchor(unpack(frame.anchorConfig))
			end
		end
	)
	XeditBox:SetHandler("OnEscape",  function(self) self:LoseFocus() end)
	XeditBox:SetMaxInputChars(5)
	-- Y label
	local Ylabel = WINDOW_MANAGER:CreateControl(nil, control, CT_LABEL)
	Ylabel:SetDimensions(30, 28)
	Ylabel:SetAnchor(LEFT, Xlabel, RIGHT, 90, 0)
	Ylabel:SetFont("ZoFontWinH4")
	Ylabel:SetText("Y = ")

	local YeditBoxBg = WINDOW_MANAGER:CreateControlFromVirtual(nil,  control,  "ZO_EditBackdrop")
	YeditBoxBg:SetDimensions(55, 26) -- box to y coords
	YeditBoxBg:SetAnchor(LEFT, Ylabel, RIGHT, 0, -3)
	YeditBox = WINDOW_MANAGER:CreateControlFromVirtual(nil,  YeditBoxBg,  "ZO_DefaultEditForBackdrop")
	YeditBox:SetText(anchorConfig[5])
	YeditBox:SetHandler("OnFocusLost",  
		function(self)
			local text = self:GetText()
			local goodNumber, x = string.gsub(text, "[^0-9]", "")
			if(x > 0 and tonumber(text) == nil) then
				frame.anchorConfig[5] = "0"
				frame:ClearAnchors()
				frame:SetAnchor(unpack(frame.anchorConfig))
			else
				frame.anchorConfig[5] = text
				frame:ClearAnchors()
				frame:SetAnchor(unpack(frame.anchorConfig))
			end
		end
	)
	YeditBox:SetHandler("OnEscape",  function(self) self:LoseFocus() end)
	YeditBox:SetMaxInputChars(5)
	control.Xedit = XeditBox
	control.Yedit = YeditBox
	return control
end

-- Move function for Menu.lua buttons Lock and unlock and slash command curvy_move (on/off)
function CurvyHud:ToggleMoveFramesMode(enable)

	if (enable) then
		-- changing state
		CurvyHud.moveMode.enabled = true
		-- building position panel if not built yet,  and showing it
		if(CurvyHud.positionPanel == nil) then
			CurvyHud:BuildPositionPanel()
		end
		CurvyHud.positionPanel:SetHidden(false)
		CurvyHud:UpdateTargetNameplate()
		-- enabling frame movement,  showing backdrops and setting handlers
		for frameName, frame in pairs(CurvyHud.movableFrames) do
			frame:SetMovable(true)
			frame:SetClampedToScreen(true)
			frame:SetMouseEnabled(true)
			frame.bg:SetHidden(false)
			frame:SetHandler("OnMouseEnter", 
				function(self)
					for setterName, setter in pairs (CurvyHud.positionPanel.setters) do
						if (setterName == frameName) then
							setter:SetAlpha(1)
						else
							setter:SetAlpha(0.2)
						end
					end
				end
			)
			frame:SetHandler("OnMouseExit", 
				function(self)
					for _, setter in pairs(CurvyHud.positionPanel.setters) do
						setter:SetAlpha(1)
					end
				end
			)
		end
		-- unregistering for events which hide the HUD (we want to always show it as we move things)
		EVENT_MANAGER:UnregisterForEvent('CurvyHud',	EVENT_RETICLE_HIDDEN_UPDATE)
		EVENT_MANAGER:UnregisterForEvent('CurvyHud',	EVENT_POWER_UPDATE)
		EVENT_MANAGER:UnregisterForEvent('CurvyHud',	EVENT_PLAYER_COMBAT_STATE)
		EVENT_MANAGER:UnregisterForEvent('CurvyHud',	EVENT_RETICLE_TARGET_CHANGED)
		EVENT_MANAGER:UnregisterForEvent('CurvyHud',	EVENT_BOSSES_CHANGED)
		EVENT_MANAGER:UnregisterForEvent('CurvyHud',	EVENT_TARGET_CHANGED)
		EVENT_MANAGER:UnregisterForEvent('CurvyHud',	EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED)
		EVENT_MANAGER:UnregisterForEvent('CurvyHud',	EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED)
		EVENT_MANAGER:UnregisterForEvent('CurvyHud',	EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED)
		EVENT_MANAGER:UnregisterForEvent('CurvyHud', 	EVENT_EFFECT_CHANGED)
	else
		-- Hiding all movable frame an position panel
		if (CurvyHud.positionPanel ~= nil) then
			CurvyHud.positionPanel:SetHidden(true)
		end
		-- changing state
		self.moveMode.enabled = false
		-- enabling frame movement, hiding background and nil-ing handlers
		for frameName, frame in pairs (CurvyHud.movableFrames) do
			frame:SetMovable(false)
			frame:SetClampedToScreen(false)
			frame:SetMouseEnabled(false)
			frame.bg:SetHidden(true)
			
			frame:SetHandler("OnMouseEnter",  nil)
			frame:SetHandler("OnMouseExit",  nil)
		end
		-- re-registering normal events
		EVENT_MANAGER:RegisterForEvent('CurvyHud', 	EVENT_RETICLE_TARGET_CHANGED		, CurvyHud.OnReticleTarget)
		EVENT_MANAGER:RegisterForEvent('CurvyHud', 	EVENT_BOSSES_CHANGED				, CurvyHud.OnReticleTarget)
		EVENT_MANAGER:RegisterForEvent('CurvyHud', 	EVENT_TARGET_CHANGED 				, CurvyHud.OnReticleTarget)
		EVENT_MANAGER:RegisterForEvent('CurvyHud', 	EVENT_RETICLE_HIDDEN_UPDATE			, CurvyHud.OnReticleHidden)
		EVENT_MANAGER:RegisterForEvent('CurvyHud', 	EVENT_POWER_UPDATE					, CurvyHud.OnPowerUpdated)
		EVENT_MANAGER:RegisterForEvent('CurvyHud', 	EVENT_PLAYER_COMBAT_STATE			, CurvyHud.OnCombatStateChanged)
		EVENT_MANAGER:RegisterForEvent('CurvyHud', 	EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED	, CurvyHud.OnVisualChanged)
		EVENT_MANAGER:RegisterForEvent('CurvyHud', 	EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED	, CurvyHud.OnVisualChanged)
		EVENT_MANAGER:RegisterForEvent('CurvyHud', 	EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED	, CurvyHud.OnVisualChanged)
		EVENT_MANAGER:RegisterForEvent('CurvyHud', 	EVENT_EFFECT_CHANGED 				, CurvyHud.OnEffectChanged)		
	end
	-- finally,  show HUD
	CurvyHud:ShowHud()
end

function CurvyHud:UpdatePosition(frameName, frame)
	
	local setter = CurvyHud.positionPanel.setters[frameName]
	-- getting the position relative to the center
	local centerX,  centerY = frame:GetCenter()
	local midX =  GuiRoot:GetWidth() / 2
	local midY = GuiRoot:GetHeight() / 2
	
	local newX = round(-(midX - centerX))
	local newY = round(-(midY - centerY))
	-- getting the old values
	local oldX = setter.Xedit:GetText()
	local oldY = setter.Yedit:GetText()
	-- updating setter in position panel
	setter.Xedit:SetText(newX)
	setter.Yedit:SetText(newY)
	-- saving the position in config and reset the anchor just to be sure
	frame.anchorConfig[1] = CENTER
	frame.anchorConfig[2] = GuiRoot
	frame.anchorConfig[3] = CENTER
	frame.anchorConfig[4] = newX
	frame.anchorConfig[5] = newY
	
	frame:ClearAnchors()
	frame:SetAnchor(unpack(frame.anchorConfig))
	
	local dX = newX - oldX
	local dY = newY - oldY
	
	if (CurvyHud.moveMode.lockTextValues == true) then
		local barContainer = nil
		if (frame == CurvyHud.barContainerLeft) then
			barContainer = CurvyHud.barContainerLeft
		elseif (frame == CurvyHud.barContainerRight) then
			barContainer = CurvyHud.barContainerRight
		end
		if(barContainer ~= nil) then
			for barName,  bar in pairs (barContainer.bars) do
				local text = bar.textContainer
				local X, Y = text.anchorConfig[4]+dX,  text.anchorConfig[5]+dY
				text.anchorConfig[1] = CENTER
				text.anchorConfig[2] = GuiRoot
				text.anchorConfig[3] = CENTER
				text.anchorConfig[4] = X
				text.anchorConfig[5] = Y
				text:ClearAnchors()
				text:SetAnchor(unpack(text.anchorConfig))
				CurvyHud.positionPanel.setters[barName..'Text'].Xedit:SetText(X)
				CurvyHud.positionPanel.setters[barName..'Text'].Yedit:SetText(Y)
			end
		end
	end
end