
local MAX_CHATTER_OPTIONS = 10
local CHATTER_OPTION_INDENT = 30

local INTERACTION_AREA_PERC_WIDTH = 0.3
local INTERACTION_AREA_RIGHT_OFFSET_PERC = 0.0534

function ZO_Interaction:OnScreenResized()
    local uiWidth, uiHeight = GuiRoot:GetDimensions()

    local divider = self.control:GetNamedChild("Divider")
    divider:ClearAnchors()
    divider:SetAnchor(RIGHT, GuiRoot, TOPRIGHT, -uiWidth * INTERACTION_AREA_RIGHT_OFFSET_PERC, uiHeight * .5)

    local interactionElementWidth = uiWidth * INTERACTION_AREA_PERC_WIDTH

    divider:SetWidth(interactionElementWidth)

    for i = 1, MAX_CHATTER_OPTIONS do
        local currentOption = GetControl(self.chatterOptionName, i)
        currentOption:SetWidth(interactionElementWidth - CHATTER_OPTION_INDENT)
    end
end

INTERACTION:OnScreenResized()

ZO_ItemPreview_Shared.IsInteractionCameraPreviewEnabled = IsInPreviewMode

local SKIP_INTERACTION = {
	[INTERACTION_CRAFT] = true,
	[INTERACTION_DYE_STATION] = true,
	[INTERACTION_LOCKPICK] = true,
	[INTERACTION_SIEGE] = true,
	[INTERACTION_FURNITURE] = true,
}
EVENT_MANAGER:RegisterForEvent("FreeDialogCamera", EVENT_GAME_CAMERA_DEACTIVATED, function()
	if SKIP_INTERACTION[GetInteractionType()] then
		return
	end
	SetInteractionUsingInteractCamera(false)
end)


