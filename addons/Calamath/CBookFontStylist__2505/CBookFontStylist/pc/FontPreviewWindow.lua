--
-- Calamath's BookFont Stylist [CBFS]
--
-- Copyright (c) 2020 Calamath
--
-- This software is released under the Artistic License 2.0
-- https://opensource.org/licenses/Artistic-2.0
--

if not CBookFontStylist then return end
local CBFS = CBookFontStylist:SetSharedEnvironment()
-- ---------------------------------------------------------------------------------------
local L = GetString

-- ---------------------------------------------------------------------------------------
-- Font Preview Window Class
-- ---------------------------------------------------------------------------------------
local CBFS_FontPreviewWindow = CT_AdjustableInitializingObject:Subclass()
function CBFS_FontPreviewWindow:Initialize(control, overriddenAttrib)
	self._attrib = {
		x = 0, 
		y = 0, 
		width = 400, 
		height = 600, 
	}
	CT_AdjustableInitializingObject.Initialize(self, overriddenAttrib)
	self.control = control
	self.mediumBg = self.control:GetNamedChild("MediumBg")
	self.title = self.control:GetNamedChild("Title")
	self.body = self.control:GetNamedChild("Body")

	control:SetHandler("OnMoveStop", function(control)
		self:RefreshWindowPosition()
	end)
	control:SetHandler("OnResizeStop", function(control)
		self:RefreshWindowPosition()
		self:RefreshWindowSize()
	end)

	self.title:SetText(L(SI_CBFS_UI_PREVIEW_TITLE_COMMON))
	self.body:SetText(L(SI_CBFS_UI_PREVIEW_BODY_COMMON) .. L(SI_CBFS_UI_PREVIEW_BODY_LOCALE))
	self.mediumBg:SetTexture(GetExtendedBookMediumTexture(BOOK_MEDIUM_NONE))

	self:SetAnchor(TOPLEFT, guiRoot, TOPLEFT, self:GetAttribute("x"), self:GetAttribute("y"))
	self:SetDimensions(self:GetAttribute("width"), self:GetAttribute("height"))
end

function CBFS_FontPreviewWindow:UpdateSizeAndPosition()
	self:SetAnchor(TOPLEFT, guiRoot, TOPLEFT, self:GetAttribute("x"), self:GetAttribute("y"))
	self.control:SetDimensions(self:GetAttribute("width"), self:GetAttribute("height"))
end

function CBFS_FontPreviewWindow:RefreshWindowPosition()
	local x, y = self.control:GetScreenRect()
	self:SetAttribute("x", x)
	self:SetAttribute("y", y)
end

function CBFS_FontPreviewWindow:RefreshWindowSize()
	local width, height = self.control:GetDimensions()
	self:SetAttribute("width", width)
	self:SetAttribute("height", height)
end

function CBFS_FontPreviewWindow:SetAnchor(point, relativeTo, relativePoint, offsetX, offsetY)
	self.control:ClearAnchors()
	self.control:SetAnchor(point, relativeTo, relativePoint, offsetX, offsetY)
	self:RefreshWindowPosition()
end

function CBFS_FontPreviewWindow:SetPosition(x, y)
	self:SetAnchor(TOPLEFT, guiRoot, TOPLEFT, x, y)
end

function CBFS_FontPreviewWindow:SetDimensions(width, height)
	self.control:SetDimensions(width, height)
	self:RefreshWindowSize()
end

function CBFS_FontPreviewWindow:SetTitleFont(titleFont)
	if self.title then
		self.title:SetFont(titleFont)
	end
end

function CBFS_FontPreviewWindow:SetBodyFont(bodyFont)
	if self.body then
		self.body:SetFont(bodyFont)
	end
end

function CBFS_FontPreviewWindow:SetMediumBgTexture(bookMediumTexture)
	if self.mediumBg then
		self.mediumBg:SetTexture(bookMediumTexture)
	end
end

function CBFS_FontPreviewWindow:Show()
	self.control:SetHidden(false)
end

function CBFS_FontPreviewWindow:Hide()
	self.control:SetHidden(true)
end

CBookFontStylist:RegisterClassObject("CBFS_FontPreviewWindow", CBFS_FontPreviewWindow)
