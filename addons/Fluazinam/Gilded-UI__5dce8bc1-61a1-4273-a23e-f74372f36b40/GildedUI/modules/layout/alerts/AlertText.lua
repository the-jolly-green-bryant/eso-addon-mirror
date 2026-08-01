if not GildedUI then return end

local Addon = GildedUI

local DEFAULT_OFFSET_X = -15
local DEFAULT_OFFSET_Y = 4
local DEFAULT_ALIGN = "right"

local ROOT_CONTROL_NAME = "ZO_AlertTextNotificationGamepad"
local ALERT_LINE_TEMPLATE = "ZO_AlertLineGamepad"

local GHOST_LABELS = {
	"That person is busy.",
	"Alert preview",
}
local GHOST_WIDTH = 400
local GHOST_ROW_HEIGHT = 36
local GHOST_GAP = 9

local ALIGN_TO_TEXT = {
	left = TEXT_ALIGN_LEFT,
	center = TEXT_ALIGN_CENTER,
	right = TEXT_ALIGN_RIGHT,
}

local VALID_ALIGN = {
	left = true,
	center = true,
	right = true,
}

Addon.limits = Addon.limits or {}
Addon.limits.alertTextOffsetX = { min = -600, max = 100 }
Addon.limits.alertTextOffsetY = { min = 0, max = 400 }

Addon:RegisterDefaults({
	alertTextOffsetX = DEFAULT_OFFSET_X,
	alertTextOffsetY = DEFAULT_OFFSET_Y,
	alertTextAlign = DEFAULT_ALIGN,
	alertTextShowPreview = false,
})

local function GetAlertTextAlignKey(sv)
	local align = sv and sv.alertTextAlign
	if VALID_ALIGN[align] then
		return align
	end
	return DEFAULT_ALIGN
end

local function GetAlertTextHorizontalAlign(sv)
	return ALIGN_TO_TEXT[GetAlertTextAlignKey(sv)] or TEXT_ALIGN_RIGHT
end

function Addon:SanitizeAlertText()
	local limits = self.limits
	self:ClampSavedNumber("alertTextOffsetX", limits.alertTextOffsetX)
	self:ClampSavedNumber("alertTextOffsetY", limits.alertTextOffsetY)
	self:SanitizeSavedBoolean("alertTextShowPreview")

	local sv = self.state.sv
	if not VALID_ALIGN[sv.alertTextAlign] then
		sv.alertTextAlign = self.defaults.alertTextAlign
	end
end

local function GetAlertBuffer()
	local mgr = ALERT_MESSAGES_GAMEPAD
	return mgr and mgr.alerts
end

function Addon:ApplyAlertTextRootPosition()
	local sv = self.state.sv
	local root = _G[ROOT_CONTROL_NAME]
	if not sv or not root then
		return
	end

	local offsetX = sv.alertTextOffsetX
	local offsetY = sv.alertTextOffsetY
	if type(offsetX) ~= "number" then
		offsetX = DEFAULT_OFFSET_X
	end
	if type(offsetY) ~= "number" then
		offsetY = DEFAULT_OFFSET_Y
	end

	root:ClearAnchors()
	root:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, offsetX, offsetY)
end

function Addon:ApplyAlertTextBufferAnchor()
	local sv = self.state.sv
	local buffer = GetAlertBuffer()
	if not sv or not buffer then
		return
	end

	local offsetX = sv.alertTextOffsetX
	local offsetY = sv.alertTextOffsetY
	if type(offsetX) ~= "number" then
		offsetX = DEFAULT_OFFSET_X
	end
	if type(offsetY) ~= "number" then
		offsetY = DEFAULT_OFFSET_Y
	end

	-- Fresh ZO_Anchor: SetOffsets treats 0 as falsy and would keep the old offset.
	buffer.anchor = ZO_Anchor:New(TOPRIGHT, GuiRoot, TOPRIGHT, offsetX, offsetY)

	local entries = buffer.activeEntries
	if not entries then
		return
	end
	for i = 1, #entries do
		buffer.anchor:Set(entries[i])
	end
	if buffer.MoveEntriesOrLines and #entries > 0 then
		buffer:MoveEntriesOrLines(entries)
	end
end

function Addon:ApplyAlertTextAlignmentToActive()
	local sv = self.state.sv
	local buffer = GetAlertBuffer()
	if not sv or not buffer or not buffer.activeEntries then
		return
	end

	local horizontal = GetAlertTextHorizontalAlign(sv)
	for i = 1, #buffer.activeEntries do
		local entryControl = buffer.activeEntries[i]
		local lines = entryControl and entryControl.activeLines
		if lines then
			for j = 1, #lines do
				local line = lines[j]
				if line and line.SetHorizontalAlignment then
					line:SetHorizontalAlignment(horizontal)
				end
			end
		end
	end
end

function Addon:EnsureAlertTextSetupWrapped()
	if self.state.alertTextSetupWrapped then
		return
	end

	local buffer = GetAlertBuffer()
	if not buffer or not buffer.templates then
		return
	end

	local templateData = buffer.templates[ALERT_LINE_TEMPLATE]
	if not templateData or type(templateData.setup) ~= "function" then
		return
	end

	local stockSetup = templateData.setup
	templateData.setup = function(control, data)
		stockSetup(control, data)
		local sv = Addon.state.sv
		if control and control.SetHorizontalAlignment then
			control:SetHorizontalAlignment(GetAlertTextHorizontalAlign(sv))
		end
	end

	self.state.alertTextSetupWrapped = true
end

function Addon:EnsureAlertTextGhosts()
	if self.state.alertTextGhostRoot then
		return
	end
	self.state.alertTextGhostRoot = self:CreateLayoutGhostStack(
		self.name .. "_AlertTextGhosts",
		GHOST_LABELS,
		GHOST_WIDTH,
		GHOST_ROW_HEIGHT,
		GHOST_GAP
	)
end

function Addon:UpdateAlertTextPreview()
	local sv = self.state.sv
	if not sv then
		return
	end

	self:EnsureAlertTextGhosts()
	self:ApplyLayoutGhostStack(
		self.state.alertTextGhostRoot,
		sv.alertTextOffsetX,
		sv.alertTextOffsetY,
		1,
		sv.alertTextShowPreview == true,
		true,
		GetAlertTextHorizontalAlign(sv)
	)
end

function Addon:ApplyAlertText()
	if self.state.alertTextApplying then
		return
	end
	self.state.alertTextApplying = true

	local sv = self.state.sv
	if sv then
		self:EnsureAlertTextSetupWrapped()
		self:ApplyAlertTextRootPosition()
		self:ApplyAlertTextBufferAnchor()
		self:ApplyAlertTextAlignmentToActive()
		self:UpdateAlertTextPreview()
	end

	self.state.alertTextApplying = false
end

function Addon:ApplyAlertTextDefaults()
	self:ApplyAlertText()
end

function Addon:InitAlertText()
	self:ApplyAlertText()
end
