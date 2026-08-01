ReloadButton = {}

ReloadButton.Default = { OffsetX = 300, OffsetY = 300, Show = true, version = 2}

ReloadButton.name = "ReloadButton" 

ReloadButton.version = 2
ReloadButton.show = true
local yellowColor = ZO_ColorDef:New("EFFF00")

local function Print(message, ...)

    df("[%s]: %s", yellowColor:Colorize(ReloadButton.name), message:format(...))

end

function ReloadButton.OnAddOnLoaded(event, addonName)
   if addonName == ReloadButton.name then  
	ReloadButton:Initialize()
  end
end

function ReloadButton:Initialize() 
  ReloadButton.savedVariables = ZO_SavedVars:NewCharacterIdSettings("ReloadButtonSavedVariables", ReloadButton.version, nil, ReloadButton.Default)  
  --Set show flag
  if ReloadButton.savedVariables.Show ~= nil then
  ReloadButton.show = ReloadButton.savedVariables.Show
  end
  ReloadButton.Check()
  ReloadButtonWindow:ClearAnchors()
  ReloadButtonWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ReloadButton.savedVariables.OffsetX, ReloadButton.savedVariables.OffsetY)
  ReloadButton.ControlSettings()  
  Print("Initialized...")
  EVENT_MANAGER:UnregisterForEvent(ReloadButton.name, EVENT_ADD_ON_LOADED)
end

function ReloadButton.SaveSettings()

  ReloadButton.version = ReloadButton.version + 1
  ReloadButton.savedVariables.Show = ReloadButton.show
  ReloadButton.savedVariables.version = ReloadButton.version
	ReloadButton.savedVariables.OffsetX = ReloadButtonWindow:GetLeft()
	ReloadButton.savedVariables.OffsetY = ReloadButtonWindow:GetTop()
end

function ReloadButton.Close()
  ReloadButtonWindow:SetHidden(true)
  ReloadButton.show = false
  ReloadButton.savedVariables.Show = false
end

function ReloadButton.Open()
  ReloadButtonWindow:SetHidden(false)
  ReloadButton.show = true
  ReloadButton.savedVariables.Show = true
  end

function ReloadButton.Reload()
  ReloadUI("ingame")
  end

function ReloadButton.Check()
  if ReloadButton.show == true then
      ReloadButton.Open()
    else 
      ReloadButton.Close()
    end
  end
  
  function ReloadButton.ControlSettings()
    
    local panelData = {
    type = "panel",
    name = "ReloadButton",
    displayName = "ReloadButton",
    author = "Tarlac",
    version = ReloadButton.version,
    slashCommand = "/reloadbuttonsettings",	--(optional) will register a keybind to open to this panel
    registerForRefresh = true,	--boolean (optional) (will refresh all options controls when a setting is changed and when the panel is shown)
    registerForDefaults = true,	--boolean (optional) (will set all options controls back to default values)
}
    
    local optionsTable = {

    [1] = {
                type = "checkbox",
                name = "Show/Hide ReloadButton",
                tooltip = "This setting will display or hide the ReloadButton",
                getFunc = function() return ReloadButton.show end,
                setFunc = function(value) ReloadButton.show = value ReloadButton.Check() end,
            },    
       
}
    ZO_CreateStringId("SI_BINDING_NAME_TARLAC_RELOADBUTTON", "Show/Hide ReloadButton") 
    ZO_CreateStringId("SI_BINDING_NAME_TARLAC_RELOADBUTTON2", "ReloadUI")
    local LAM2 = LibStub("LibAddonMenu-2.0")

    LAM2:RegisterAddonPanel("ReloadButtonSettings", panelData) 
    LAM2:RegisterOptionControls("ReloadButtonSettings", optionsTable)

    end

EVENT_MANAGER:RegisterForEvent(ReloadButton.name, EVENT_ADD_ON_LOADED, ReloadButton.OnAddOnLoaded)
SLASH_COMMANDS["/reloadbutton"] = function()  ReloadButton.Open() end