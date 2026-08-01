---------------------------------------------------------------------------------------------------------------
-- locals
---------------------------------------------------------------------------------------------------------------
--[[
local fontHeights = {
	["ZoFontGameBold"] = 18,
	["ZoFontGamepadBold34"] = 34,
}

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
]]
---------------------------------------------------------------------------------------------------------------
-- local functions
---------------------------------------------------------------------------------------------------------------
local function hasActiveCompanion()
	return HasActiveCompanion() or HasPendingCompanion()
end

local function unpackDimensions(dimensions)
	return dimensions.width, dimensions.height
end

local function getAbrreviatedNumber(current, useUppercaseSuffixes)
	if useUppercaseSuffixes ~= nil then
		return ZO_AbbreviateAndLocalizeNumber(current, NUMBER_ABBREVIATION_PRECISION_TENTHS, useUppercaseSuffixes)
	end
	local shortAmount, suffix = AbbreviateNumber(current, NUMBER_ABBREVIATION_PRECISION_TENTHS, USE_LOWERCASE_NUMBER_SUFFIXES)
	return shortAmount .. suffix
end

local function createBackDrop(name, parent, width, height, centerColor, edgeColor, hidden)
	local bg = WINDOW_MANAGER:CreateControl("$(parent)" .. name, parent, CT_BACKDROP)
	bg:SetCenterColor(unpack(centerColor))
	bg:SetEdgeColor(unpack(edgeColor))
	bg:SetEdgeTexture("",8,2,2)
	bg:SetDrawLayer(0)
	bg:SetHidden(hidden)
	bg:SetDimensions(width, height)
	return bg
end

local function getLayoutData(scale)
	local s = BUI.Group.members <= 4 and BUI.Vars.SmallGroupScale / 100 or BUI.Group.members > 12 and BUI.Vars.LargeRaidScale / 100 or 1
	scale = scale or s
	
	local theme_color = BUI.Vars.Theme == 6 and {1,204/255,248/255,1} or BUI.Vars.Theme == 7 and BUI.Vars.AdvancedThemeColor or BUI.Vars.CustomEdgeColor
	local w, h = BUI.Vars.RaidWidth * scale, BUI.Vars.RaidHeight * scale
	
	local hs = h - (BUI.Vars.StatShare and 8-1 or 0) * scale
	local fs = math.min(BUI.Vars.RaidFontSize, hs*.8) * scale
	
	local comp = BUI.Vars.RaidCompact

	return w, h, hs, fs, comp, theme_color
end

local function unpackAnchor(comp, anchor1, anchor2)
	if comp then
		return unpack(anchor1)
	end
	return unpack(anchor2)
end

---------------------------------------------------------------------------------------------------------------
-- 
---------------------------------------------------------------------------------------------------------------
local Companion_Frame = {}

function Companion_Frame:PerformDeferredInitialization()
	self:InitilizeForGrandparent()
	local frame = CreateControl("$(parent)BUI", IJA_CompanionUnitFrames, CT_CONTROL)
	if not frame then return end
	local layoutData  = {
		['healthBarTemplateData'] = {
			['template'] = 'ZO_DefaultStatusBar',
			['gradient'] = self.savedVars.healthGradient,

		},
		['shieldOverlayTemplateData'] = {
			['template'] = 'IJA_DefaultStatusBar',
			['gradient'] = self.savedVars.shieldGradient,
		},
	}
end

function Companion_Frame:ApplyVisualStyle(scale)

	local w, h, hs, fs, comp, theme_color = getLayoutData(scale)
	
	ApplyTemplateToControl(self.frame, 'IJA_CompanionUnitFrameBUI')
	
	
	local frame = self.frame
	local healthBar = self.healthBar.barControl
	local shieldOverlay = self.shieldOverlay.barControl
	local nameLabel = self.nameLabel
	local healthValue = self.healthValue
	local statusLabel = self.statusLabel
	
	local backdrop = healthBar:GetNamedChild('Underlay2')
	backdrop:SetEdgeTexture(BUI.progress[BUI.Vars.Theme], 32, 4, 4)
	backdrop:SetEdgeColor(unpack(theme_color))
	
	self.UpdateStyle(healthBar, w, h - 5 --[[, TOPLEFT, health, TOPLEFT, 0, 2]])
	self.UpdateStyle(shieldOverlay, w, h - 5 --[[, TOPRIGHT, healthBar, TOPRIGHT, 0, 0]])
	self.UpdateStyle(nameLabel, (w - ( select(comp, (fs * 1.2 + w / 3.6), (fs * 1.2)))), (fs * 1.3), unpackAnchor(comp, {LEFT, healthBar, LEFT, 8, 0}, {BOTTOMLEFT, healthBar, TOPLEFT, 2, fs*.1}) )
	self.UpdateStyle(healthValue, (w * 2 / 3), (fs * 1.3), unpackAnchor(comp, {RIGHT, healthBar, RIGHT, (-fs * 1.3), 0}, {LEFT, healthBar, LEFT, 8, 0} ))
	self.UpdateStyle(statusLabel, (w * 2 / 3), (fs * 1.3), unpackAnchor(comp, {RIGHT, healthBar, RIGHT, (-fs * 1.3), 0}, {LEFT, healthBar, LEFT, 8, 0} ))
	healthValue:SetHorizontalAlignment(comp and 2 or 0)
	statusLabel:SetHorizontalAlignment(comp and 2 or 0)
	
	nameLabel:SetFont(BUI.UI.Font(BUI.Vars.FrameFont1, fs, true))
	healthValue:SetFont(BUI.UI.Font(BUI.Vars.FrameFont1, fs, true))
	statusLabel:SetFont(BUI.UI.Font(BUI.Vars.FrameFont1, fs, true))
	
	self.hideNameOnStatus = comp
	
	self.healthBar.barControl:GetNamedChild("Gloss"):SetHidden(not self.savedVars.useFancyBar)
	self.shieldOverlay.barControl:GetNamedChild("Gloss"):SetHidden(not self.savedVars.useFancyBar)
end

function Companion_Frame:SetLocked(locked)
	self.frame:SetMovable(not locked)
end

function Companion_Frame:HideHealthValue(hidden)
	self.healthValue:SetHidden(hidden)
end

function Companion_Frame:ShowLevel()
	return BUI.Vars.RaidLevels
end

function Companion_Frame:GetDisabledState(disabled)
	return disabled
end

function Companion_Frame:SetBarsHidden(hideBars)
end


function Companion_Frame:GetLayoutData()
	local layoutData  = {
		['healthBarTemplateData'] = {
			['template'] = 'ZO_DefaultStatusBar',
			['gradient'] = self.savedVars.healthGradient,

		},
		['shieldOverlayTemplateData'] = {
			['template'] = 'IJA_DefaultStatusBar',
			['gradient'] = self.savedVars.shieldGradient,
		},
	}
	
	return layoutData
end

function Companion_Frame:UpdateStyle(width, height, point, relativeTo, relativePoint, offsetX, offsetY)
	if width or height then
		width = width or self:GetWidth()
		height = height or self:GetHeight()
		
		self:SetDimensions(width, height)
	end
	
	if point or relativeTo  or relativePoint or offsetX or offsetY then
		local anchor = ZO_Anchor:New(point, relativeTo, relativePoint, offsetX, offsetY)
		anchor:Set(self)
	end
end

function Companion_Frame:SetScale()
end

function Companion_Frame:SetShieldOverlayDimmensions(width, height)
	self.shieldOverlay.barControl:SetDimensions(width, height)
end

function Companion_Frame:InitilizeForGrandparent()
	local function Raid_UI(scale)
		if self.savedVars.selectedFrameStyle == 2 then
			self:ApplyVisualStyle(scale)
		end
	end
	ZO_PostHook(BUI.Frames, "Raid_UI", Raid_UI)
--	JO_HOOK_MANAGER:RegisterForPostHook('IsJustaCompanionUI', BUI.Frames, "Raid_UI", Raid_UI)
	
	local original_Handler = BUI_MenuGroupFrames:GetHandler('OnEffectivelyShown')
	local function OnEffectivelyShown()
		original_Handler()
		IJA_CompanionUnit:SetHidden(false)
	end
	
	BUI_MenuGroupFrames:SetHandler('OnEffectivelyShown', OnEffectivelyShown)
end

function IJA_CompanionFrames_BUI_Template(...)
	return Companion_Frame
end


