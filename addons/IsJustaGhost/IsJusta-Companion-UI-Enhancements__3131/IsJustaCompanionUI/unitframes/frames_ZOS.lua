local savedVars = {}

local UnitFrames, LAST_SETTING

---------------------------------------------------------------------------------------------------------------
-- locals
---------------------------------------------------------------------------------------------------------------
local fontHeights = {
	["ZoFontGameBold"] = 18,
	["ZoFontGamepadBold34"] = 34,
}

local FRAME_LAYOUT_DATA = {}
local fontList = {
	[1] = "ZoFontGamepad18",
	[2] = "ZoFontGamepad20",
	[3] = "ZoFontGamepad22",
	[4] = "ZoFontGamepad25",
	[5] = "ZoFontGamepad27",
	[6] = "ZoFontGamepad34",
	[7] = "ZoFontGamepad36",
	[8] = "ZoFontGamepad42",
}

local fontSizes = {}
do
	for k, fontString in ipairs(fontList) do
		local fontSize = fontString:gsub('%D+', '')
		fontSizes[#fontSizes + 1] = GetString(SI_CHAT_OPTIONS_FONT_SIZE) .. fontSize
	end
end

---------------------------------------------------------------------------------------------------------------
-- local functions
---------------------------------------------------------------------------------------------------------------

local function getPlatformLayoutData()
	local platformKey = IsInGamepadPreferredMode() and "gamepad" or "keyboard"
	local layoutData = FRAME_LAYOUT_DATA[platformKey]
	
	if IJA_GamepadHUD then
		if IJA_GamepadHUD.savedVars.enablePlayerFrames then
			layoutData = FRAME_LAYOUT_DATA.keyboard
		end
	end
	
	return layoutData
end

local function getCotrolChild(control, child)
	if control then
		return control:GetNamedChild(child)
	end
	return nil
end

---------------------------------------------------------------------------------------------------------------
-- 
---------------------------------------------------------------------------------------------------------------
local Companion_Frame = {}

function Companion_Frame:PerformDeferredInitialization()
	self.showLevel = self.savedVars.showLevel
	
	FRAME_LAYOUT_DATA = {
		['keyboard'] = {
			isGamepad = false,
			height = 110,
			scaleModifier = 1,
			templateName = 'IJA_CompanionUnitFrameZOS_Keyboard_Template',
			['healthBarTemplateData'] = {
				['template'] = 'IJA_CompanionUnitFramesStatus_Keyboard_Template',
				['gradient'] = self.savedVars.healthGradient,

			},
			['shieldOverlayTemplateData'] = {
				['template'] = 'IJA_ArrowStatusBar',
				['gradient'] = self.savedVars.shieldGradient,
			},
		},
		['gamepad'] = {
			isGamepad = true,
			height = 135,
			scaleModifier = 0.7,
			templateName = 'IJA_CompanionUnitFrameZOS_Gamepad_Template',
			['healthBarTemplateData'] = {
				['template'] = 'IJA_CompanionUnitFramesStatus_Gamepad_Template',
				['gradient'] = self.savedVars.healthGradient,
			},
			['shieldOverlayTemplateData'] = {
				['template'] = 'IJA_ArrowStatusBar',
				['gradient'] = self.savedVars.shieldGradient,
			}
		}
	}
end

function Companion_Frame:GetDisabledState(disabled)
	if not disabled and IsUnitGrouped("player") then
		disabled = self.savedVars.useGroupFrame
	end
	
	return disabled
end

function Companion_Frame:ApplyVisualStyle()
	local hasPendingCompanion = HasPendingCompanion()
	local layoutData = getPlatformLayoutData()
	self.layoutData = layoutData
	
	ApplyTemplateToControl(self.frame, layoutData.templateName)
	
	local height = self.healthValue:IsHidden() and layoutData.height or self.healthValue:GetTextHeight() + layoutData.height
	self.frame:SetHeight(height)
		
	local alpha = self.savedVars.occupancy * 0.01
	self.background:SetAlpha(alpha)
	
	local healthBar = self.healthBar.barControl
	healthBar:GetNamedChild('Underlay'):SetHidden(not self.savedVars.hideBarBg)
	healthBar:GetNamedChild('Overlay'):SetHidden(self.savedVars.hideBarBg)
	healthBar:GetNamedChild('BG'):SetHidden(self.savedVars.hideBarBg)
	healthBar:GetNamedChild('BG'):SetAlpha(self.savedVars.hideBarBg and 0.8 or 1)
	
	self:SetScale()
	
	self.healthBar.barControl:GetNamedChild("Gloss"):SetHidden(false)
	self.shieldOverlay.barControl:GetNamedChild("Gloss"):SetHidden(false)
end

function Companion_Frame:GetLayoutData()
	return getPlatformLayoutData()
end

function Companion_Frame:SetScale()
	local layoutData = getPlatformLayoutData()
	local scale = (self.savedVars.frameScale * 0.01) * layoutData.scaleModifier
	self.frame:SetScale(scale)
end

function Companion_Frame:SetBarsHidden(hideBars)
	self.healthBar.barControl:SetHidden(hideBars)
	self.shieldOverlay.barControl:SetHidden(hideBars)
end

function Companion_Frame:SetFonts()
	self.nameLabel:SetFont(self.savedVars.fonts[1])
	self.statusLabel:SetFont(self.savedVars.fonts[2])
	self.healthValue:SetFont(self.savedVars.fonts[3])
end

function Companion_Frame:HideHealthValue(hidden)
	local layoutData = getPlatformLayoutData()
	self.healthValue:SetHidden(hidden)
	
	local height = hidden and layoutData.height or self.healthValue:GetTextHeight() + layoutData.height
	self.frame:SetHeight(height)
end

function Companion_Frame:ShowLevel()
	return self.savedVars.showLevel
end

function Companion_Frame:SetShieldOverlayDimmensions(width, height)
	local scale = self.frame:GetScale()

	self.shieldOverlay.barControl:SetDimensions(width / scale, height / scale)
end

function IJA_CompanionFrames_ZOS_Template(...)
	return Companion_Frame
end

