RFPO = {
	name = "RFPO",
};
local set = CAMERA_OPTIONS_PREVIEW_FORCE_THIRD_PERSON;
function RFPO.OnAddOnLoaded( eventCode, addonName )
	if (addonName == RFPO.name) then
	EVENT_MANAGER:UnregisterForEvent(RFPO.name, EVENT_ADD_ON_LOADED)	
	ZO_CreateStringId("SI_BINDING_NAME_ChangeRFPO", "Change Camera Mode")
	
	EVENT_MANAGER:RegisterForEvent(RFPO.name, EVENT_PLAYER_ACTIVATED, RFPO.toggle);
	EVENT_MANAGER:RegisterForEvent(RFPO.name, EVENT_ACTION_LAYER_POPPED, RFPO.toggle);
	EVENT_MANAGER:RegisterForEvent(RFPO.name, EVENT_GAME_CAMERA_UI_MODE_CHANGED, RFPO.toggle);
	end
end

function RFPO.toggle(eventCode)
	if eventCode == 589824 or eventCode == 65552 or eventCode == 131491 or eventCode == 65536 then
	SetCameraOptionsPreviewModeEnabled(true, set)
	if set==CAMERA_OPTIONS_PREVIEW_FORCE_THIRD_PERSON
	then
	ZO_ReticleContainerReticle:SetAlpha(0)
    ZO_ReticleContainerStealthIconStealthText:SetHidden( true )
	ZO_ReticleContainerNonInteract:SetAlpha(0)
	ZO_ReticleContainerNonInteractText:SetAlpha(0)
	else
	ZO_ReticleContainerReticle:SetAlpha(1)
    ZO_ReticleContainerStealthIconStealthText:SetHidden(false)
	ZO_ReticleContainerNonInteract:SetAlpha(1)
	ZO_ReticleContainerNonInteractText:SetAlpha(1)
	end
	else
	if set==CAMERA_OPTIONS_PREVIEW_FORCE_THIRD_PERSON then set=CAMERA_OPTIONS_PREVIEW_FORCE_FIRST_PERSON else set=CAMERA_OPTIONS_PREVIEW_FORCE_THIRD_PERSON end
	SetCameraOptionsPreviewModeEnabled(true, set)
	if set==CAMERA_OPTIONS_PREVIEW_FORCE_THIRD_PERSON
	then
	ZO_ReticleContainerReticle:SetAlpha(0)
    ZO_ReticleContainerStealthIconStealthText:SetHidden( true )
	ZO_ReticleContainerNonInteract:SetAlpha(0)
	ZO_ReticleContainerNonInteractText:SetAlpha(0)
	else
	ZO_ReticleContainerReticle:SetAlpha(1)
    ZO_ReticleContainerStealthIconStealthText:SetHidden(false)
	ZO_ReticleContainerNonInteract:SetAlpha(1)
	ZO_ReticleContainerNonInteractText:SetAlpha(1)
	end
	end
end
EVENT_MANAGER:RegisterForEvent(RFPO.name, EVENT_ADD_ON_LOADED, RFPO.OnAddOnLoaded);