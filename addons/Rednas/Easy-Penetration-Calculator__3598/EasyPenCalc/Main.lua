EPC = EPC or {}

function EPC.ToggleGUI()
	SCENE_MANAGER:ToggleTopLevel(EPC.GUI.Main)
end

function EPC.Initialize()
	SCENE_MANAGER:RegisterTopLevel(EPC.GUI.Main, locksUIMode)
	
	EPC.UI.PEN.Initialize()
	EPC.PEN.UpdateSummaryValues()
	
	--Add to Bandits side panel, but wait 1 sec to make sure BUI is loaded
	zo_callLater(
		function()
			--Check if BUI and BUI.PanelAdd exist
			if BUI and BUI.PanelAdd then
				local BUISidePanel={
					{
					icon		= "/esoui/art/armory/buildicons/buildicon_12.dds",
					tooltip		= EPC.fullName,
					func		= EPC.ToggleGUI,
					enabled		= true
					}
				}
				BUI.PanelAdd(BUISidePanel)
			end
		end
	, 1000)

end

function EPC.OnAddOnLoaded(event, addonName)
  if addonName == EPC.name then
    EVENT_MANAGER:UnregisterForEvent(EPC.name, EVENT_ADD_ON_LOADED)
    EPC.Initialize()
  end
end
 
EVENT_MANAGER:RegisterForEvent(EPC.name, EVENT_ADD_ON_LOADED, EPC.OnAddOnLoaded)

SLASH_COMMANDS["/pen"] = EPC.ToggleGUI