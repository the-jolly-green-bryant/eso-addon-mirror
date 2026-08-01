ScribingUI = ScribingUI or {}
ScribingUI.name = "ScribingUI"
ScribingUI.version = "1.0"


function ScribingUI.OnLoaded(_, addonName)
    if addonName ~= ScribingUI.name then return end
    ScribingUI:Init()
end

function ScribingUI:Init()



    SLASH_COMMANDS["/scribingui"] = function (args)
		ScribingUI.Show()
    end
	
	SLASH_COMMANDS["/rl"] = function(a) ReloadUI() end

    EVENT_MANAGER:UnregisterForEvent(ScribingUI.name, EVENT_ADD_ON_LOADED)
end

function ScribingUI:Show()
	SCENE_MANAGER:ShowSceneOrQueueForLoadingScreenDrop("scribingKeyboard")
end

EVENT_MANAGER:RegisterForEvent(ScribingUI.name, EVENT_ADD_ON_LOADED, ScribingUI.OnLoaded)

ZO_CreateStringId("SI_KEYBINDINGS_CATEGORY_SCRIBINGUI", "ScribingUI")
ZO_CreateStringId("SI_BINDING_NAME_SCRIBINGUI", "Show Scribing UI")