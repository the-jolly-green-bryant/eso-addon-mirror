--Skylike Dialog v1.5 by Capt Tatsu
--based on Shinni's Free Dialog Camera

--Variables
local addonName = "SkylikeDialog"

local chatterOptionIndent = 10
local skipUnlock = {
	[INTERACTION_CRAFT] = true,
	[INTERACTION_DYE_STATION] = true,
    [INTERACTION_LOCKPICK] = false,
	[INTERACTION_SIEGE] = true,
	[INTERACTION_FURNITURE] = true,
}


--Change character name's font and remove hyphens
local function changeTargetTitle()
    local title = ZO_InteractWindowTargetAreaTitle:GetText()
    ZO_InteractWindowTargetAreaTitle:SetText(string.sub(title, 2, -2))
    ZO_InteractWindowTargetAreaTitle:SetFont("ZoFontCallout")
end

--Adjust dialog positioning
local function adjustDialogPosition()
	local uiWidth, uiHeight = GuiRoot:GetDimensions()

	ZO_InteractWindowTopBG:SetHidden (true)

	ZO_InteractWindowBottomBG:ClearAnchors()
	ZO_InteractWindowBottomBG:SetAnchor(RIGHT,GuiRoot,RIGHT,0.0,uiHeight*0.1)
	ZO_InteractWindowBottomBG:SetWidth(uiWidth*0.35)
	ZO_InteractWindowBottomBG:SetHeight(uiHeight*0.25)
	ZO_InteractWindowBottomBG:SetTextureCoords(0,2.0,0.3,0.3)
	
	ZO_InteractWindowTargetAreaTitle:ClearAnchors()
	ZO_InteractWindowTargetAreaTitle:SetAnchor(CENTER,GuiRoot,CENTER,0.0,uiHeight*0.1)
	ZO_InteractWindowTargetAreaTitle:SetWidth(uiWidth*2.0)
	
	ZO_InteractWindowTargetAreaBodyText:ClearAnchors()
	ZO_InteractWindowTargetAreaBodyText:SetAnchor(CENTER,GuiRoot,CENTER,0.0,uiHeight*0.35)
	ZO_InteractWindowTargetAreaBodyText:SetWidth(uiWidth*0.5)
	ZO_InteractWindowTargetAreaBodyText:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
		
	ZO_InteractWindowPlayerAreaOptions:ClearAnchors()
	ZO_InteractWindowPlayerAreaOptions:SetAnchor(RIGHT,GuiRoot,RIGHT,-uiWidth*0.05 + chatterOptionIndent,uiHeight*0.1)
	
	ZO_InteractWindowVerticalSeparator:ClearAnchors()
	ZO_InteractWindowVerticalSeparator:SetAnchor(RIGHT,GuiRoot,RIGHT,-uiWidth*0.35,uiHeight*0.1)
	ZO_InteractWindowVerticalSeparator:SetHeight(uiHeight*0.26)

	ZO_InteractWindowCollapseContainerRewardArea:ClearAnchors()
	ZO_InteractWindowCollapseContainerRewardArea:SetAnchor(LEFT,GuiRoot,LEFT,uiWidth*0.025 + 1.5*chatterOptionIndent,uiHeight*0.05)
end

--Adjust chatter option positioning
function ZO_Interaction:OnScreenResized()
	local uiWidth, uiHeight = GuiRoot:GetDimensions()
	local divider = self.control:GetNamedChild("Divider")
    divider:ClearAnchors()
    divider:SetAnchor(RIGHT, GuiRoot, RIGHT, -uiWidth * 0.05, 0.0)

    divider:SetWidth(uiWidth * 0.3)
	
	for i = 1, 10 do
        local currentOption = GetControl(self.chatterOptionName, i)
        currentOption:SetWidth(uiWidth*0.3 - chatterOptionIndent)
    end
end

--Apply all dialog adjustment functions
local function dialogAdjustment()
    changeTargetTitle()
	adjustDialogPosition()
end

EVENT_MANAGER:RegisterForEvent(addonName, EVENT_GAME_CAMERA_DEACTIVATED, function()
	if skipUnlock[GetInteractionType()] then
		return
	end
	SetInteractionUsingInteractCamera(false)
	EVENT_MANAGER:RegisterForEvent(addonName, EVENT_CHATTER_BEGIN, dialogAdjustment)
	EVENT_MANAGER:RegisterForEvent(addonName, EVENT_QUEST_OFFERED, dialogAdjustment)
	EVENT_MANAGER:RegisterForEvent(addonName, EVENT_QUEST_COMPLETE_DIALOG, dialogAdjustment)
	EVENT_MANAGER:RegisterForEvent(addonName, EVENT_CONVERSATION_UPDATED, dialogAdjustment)
end)

INTERACTION:OnScreenResized()


--Adjust NPC / Player interaction positioning
local function interactAdjustment()
	local uiWidth, uiHeight = GuiRoot:GetDimensions()
	
	ZO_ReticleContainerInteractContext:ClearAnchors()
	ZO_ReticleContainerInteractContext:SetAnchor(BOTTOM,GuiRoot,CENTER,0.0,uiHeight*0.09)
	ZO_ReticleContainerInteractKeybindButtonNameLabel:ClearAnchors()
	ZO_ReticleContainerInteractKeybindButtonNameLabel:SetAnchor(TOP,GuiRoot,CENTER,0.0,uiHeight*0.0925)
	ZO_ReticleContainerInteractAdditionalInfo:ClearAnchors()
	ZO_ReticleContainerInteractAdditionalInfo:SetAnchor(TOP,GuiRoot,CENTER,0.0,uiHeight*0.1275)
	
	ZO_PlayerToPlayerAreaPromptContainerTarget:ClearAnchors()
	ZO_PlayerToPlayerAreaPromptContainerTarget:SetAnchor(BOTTOM,GuiRoot,CENTER,0.0,uiHeight*0.20)
	ZO_PlayerToPlayerAreaPromptContainerActionAreaActionKeybindButtonNameLabel:ClearAnchors()
	ZO_PlayerToPlayerAreaPromptContainerActionAreaActionKeybindButtonNameLabel:SetAnchor(TOP,GuiRoot,CENTER,0.0,uiHeight*0.2025)
	
	ZO_ReticleContainerNonInteract:ClearAnchors()
	ZO_ReticleContainerNonInteract:SetAnchor(CENTER,GuiRoot,TOP,0.0,uiHeight*0.2)
	ZO_ReticleContainerNonInteractText:ClearAnchors()
	ZO_ReticleContainerNonInteractText:SetAnchor(CENTER,GuiRoot,TOP,0.0,uiHeight*0.2)
	ZO_ReticleContainerNonInteractText:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	ZO_ReticleContainerNonInteractText:SetFont("ZoFontGameBold")
end

EVENT_MANAGER:RegisterForEvent(addonName, EVENT_ADD_ON_LOADED, function() interactAdjustment() end)


--Allow furniture to be previewed again (thanks to alchemist1654)
ZO_ItemPreview_Shared.IsInteractionCameraPreviewEnabled = GetPreviewModeEnabled


--Disable dialog in shop (thanks to ArtisanLRO)
local function disableAudio()
  SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_ENABLED, 0)
end

local function enableAudio()
  SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_ENABLED, 1)
end

EVENT_MANAGER:RegisterForEvent(addonName, EVENT_OPEN_STORE, disableAudio)
EVENT_MANAGER:RegisterForEvent(addonName, EVENT_OPEN_FENCE, disableAudio)
EVENT_MANAGER:RegisterForEvent(addonName, EVENT_OPEN_BANK, disableAudio)
EVENT_MANAGER:RegisterForEvent(addonName, EVENT_OPEN_TRADING_HOUSE, disableAudio)
EVENT_MANAGER:RegisterForEvent(addonName, EVENT_OPEN_GUILD_BANK, disableAudio)
EVENT_MANAGER:RegisterForEvent(addonName, EVENT_OPEN_HOUSE_STORE, disableAudio)

EVENT_MANAGER:RegisterForEvent(addonName, EVENT_CLOSE_STORE, enableAudio)
EVENT_MANAGER:RegisterForEvent(addonName, EVENT_CLOSE_FENCE, enableAudio)
EVENT_MANAGER:RegisterForEvent(addonName, EVENT_CLOSE_BANK, enableAudio)
EVENT_MANAGER:RegisterForEvent(addonName, EVENT_CLOSE_TRADING_HOUSE, enableAudio)
EVENT_MANAGER:RegisterForEvent(addonName, EVENT_CLOSE_GUILD_BANK, enableAudio)
EVENT_MANAGER:RegisterForEvent(addonName, EVENT_CLOSE_HOUSE_STORE, enableAudio)