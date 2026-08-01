--[[
Audio Control Doctor
by @DrGerm on the North American Megaserver
Main LUA File
--]]

ACD = {}
ACD.name = "AudioControlDoctor"

function ACD.Update()
end

function ACD.OnInitialized(eventCode, addOnName)
    if (ACD.name ~= addOnName) then return end
    ACD.vars = ZO_SavedVars:NewAccountWide("AudioControlDoctor_SavedVariables", 1, nil, ACD.defaults)
end

-- Create Keybinds
ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_MASTER_ENABLED", "Toggle Master Audio")
ZO_CreateStringId("SI_BINDING_NAME_INCREASE_MASTER_VOLUME", "Increase Master Volume")
ZO_CreateStringId("SI_BINDING_NAME_DECREASE_MASTER_VOLUME", "Decrease Master Volume")

ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_MUSIC_ENABLED", "Toggle Music")
ZO_CreateStringId("SI_BINDING_NAME_INCREASE_MUSIC_VOLUME", "Increase Music Volume")
ZO_CreateStringId("SI_BINDING_NAME_DECREASE_MUSIC_VOLUME", "Decrease Music Volume")

ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_AMBIENT_ENABLED", "Toggle Ambient")
ZO_CreateStringId("SI_BINDING_NAME_INCREASE_AMBIENT_VOLUME", "Increase Ambient Volume")
ZO_CreateStringId("SI_BINDING_NAME_DECREASE_AMBIENT_VOLUME", "Decrease Ambient Volume")

ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_SFX_ENABLED", "Toggle Effects")
ZO_CreateStringId("SI_BINDING_NAME_INCREASE_SFX_VOLUME", "Increase Effects Volume")
ZO_CreateStringId("SI_BINDING_NAME_DECREASE_SFX_VOLUME", "Decrease Effects Volume")

ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_FOOTSTEPS_ENABLED", "Toggle Footsteps")
ZO_CreateStringId("SI_BINDING_NAME_INCREASE_FOOTSTEPS_VOLUME", "Increase Footsteps Volume")
ZO_CreateStringId("SI_BINDING_NAME_DECREASE_FOOTSTEPS_VOLUME", "Decrease Footsteps Volume")

ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_UI_ENABLED", "Toggle Interface")
ZO_CreateStringId("SI_BINDING_NAME_INCREASE_UI_VOLUME", "Increase Interface Volume")
ZO_CreateStringId("SI_BINDING_NAME_DECREASE_UI_VOLUME", "Decrease Interface Volume")

ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_VO_ENABLED", "Toggle Dialogue")
ZO_CreateStringId("SI_BINDING_NAME_INCREASE_VO_VOLUME", "Increase Dialogue Volume")
ZO_CreateStringId("SI_BINDING_NAME_DECREASE_VO_VOLUME", "Decrease Dialogue Volume")

ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_BACKGROUND_AUDIO", "Toggle Plays in Background")
--For Future Features
--ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_FIVE_POINT_ONE", "Toggle 5.1")
--ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_STEREO", "Toggle Stereo")

EVENT_MANAGER:RegisterForEvent(ACD.name, EVENT_ADD_ON_LOADED, ACD.OnInitialized)