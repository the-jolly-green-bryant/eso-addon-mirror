ESAddon = {}
ESAddon.name = "EyeStrain"
ESAddon.variableVersion = 3
ESAddon.Default = {
	hiddenUI = true,
	OverlayColour = {0, 0, 0, 0.3524590135},
}

function ESAddon:SetupSettings()
  local LAM2 = LibAddonMenu2
  if not LAM2 and LibStub then LAM2 = LibStub("LibAddonMenu-2.0") end
  if not LAM2 then d("Library LibAddonMenu is missing!") return end
  local panelData = {
      type = "panel",
      name = "Eye Strain",
      displayName = "Eye Strain",
      author = "Splat",
      version = "1.1.1",
      slashCommand = "/ess";
      registerForRefresh = true,
      website = "https://www.esoui.com/downloads/info2467-EyeStrain.html",
      feedback = "https://www.esoui.com/portal.php?&id=300",
  }
  LAM2:RegisterAddonPanel("ESAddonOptions", panelData)
  local optionsData = {
     [1] = {
	  type = "divider",
     },
     [2] = {
	  type = "description",
	  text = GetString(EYES_DESC),
     },
     [3] = {
	  type = "divider",
     },
     [4] = {
          type = "colorpicker",
	  name = GetString(EYES_NAME),
	  tooltip = GetString(EYES_TOOLTIP),
	  getFunc = function() return unpack( ESAddon.savedVariables.OverlayColour ) end,
	  setFunc = function(r,g,b,a) 
		    local alpha = ESAddonIndicatorBg:GetAlpha()
		    ESAddon.savedVariables.OverlayColour = {r, g, b, a}
		    ESAddonIndicatorBg:SetColor(r,g,b,a)  
		    end,
     },
}
  LAM2:RegisterOptionControls("ESAddonOptions", optionsData)
end

------------ UI ELEMENTS -------------

function ESAddon.ToggleWindow()
    if not ESAddon.savedVariables.hiddenUI == false then
        ESAddon.savedVariables.hiddenUI = false
        ESAddonIndicator:SetHidden(false)
        ESAddonIndicator:SetTopmost(true)
        ESAddonIndicator:BringWindowToTop(true)
    else
        ESAddon.savedVariables.hiddenUI = true
        ESAddonIndicator:SetHidden(true)
    end
end

--------------------------------------

function ESAddon:Initialize()
  SLASH_COMMANDS["/esui"] = ESAddon.ToggleWindow
  ESAddon.savedVariables = ZO_SavedVars:NewAccountWide("ESSavedVariables", ESAddon.variableVersion, nil, ESAddon.Default)
  ESAddon:SetupSettings()
    if ESAddon.savedVariables.hiddenUI == false then
         ESAddonIndicator:SetHidden(false)
         ESAddonIndicator:SetTopmost(true)
         ESAddonIndicator:BringWindowToTop(true)
    else
         ESAddonIndicator:SetHidden(true)
    end
  EVENT_MANAGER:UnregisterForEvent(ESAddon.name, EVENT_ADD_ON_LOADED)
end

function ESAddon.OnAddOnLoaded(event, addonName)
  if addonName == ESAddon.name then
    ESAddon:Initialize()
  end
end

EVENT_MANAGER:RegisterForEvent(ESAddon.name, EVENT_ADD_ON_LOADED, ESAddon.OnAddOnLoaded)

ZO_CreateStringId("SI_BINDING_NAME_EYE_STRAIN_TOGGLE_WINDOW", "Toggle Window")
ZO_CreateStringId("SI_BINDING_NAME_EYE_STRAIN_SETTINGS_MENU", "Settings Menu")