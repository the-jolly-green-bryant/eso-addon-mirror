TEC = {} 
TEC.name = "TEC"
TEC.settingsRev = 1
TEC.version = "1.2.1"

local LAM2 = LibStub:GetLibrary("LibAddonMenu-2.0")

local forceFirstPerson = false

local cameraCentered = false
local shoulderCameraDistance = 2
local animateCamera = true
local combatCenter = false
local interactionCrafting = false
local interactionDyeStation = false
local interactionLockpicking = false
local interactionFurniturePreview = false
local interactionSiegeWeapons = false
local interactionChatting = false
local werewolfThirdPerson = true
local combatFirstPerson = false

local cameraForcedCenter = false

local addonInitialized = false

------------------------------------------------------
-- OnAddOnLoaded
------------------------------------------------------
function TEC.OnAddOnLoaded(event, addOnName)
    if addOnName ~= TEC.name then return end
    if addOnName == TEC.name then
        ZO_CreateStringId("SI_BINDING_NAME_RUN_TEC", GetString(SI_CWA_KEY_BINDING))        
        TEC:Initialize()
    end
end

------------------------------------------------------
-- Initialize
------------------------------------------------------
function TEC:Initialize()

    ZO_ItemPreview_Shared.IsInteractionCameraPreviewEnabled = GetPreviewModeEnabled
    
    local defaults = {
        forceFirstPerson = false,
        animateCamera = true,
        combatCenter = false,
        interactionCrafting = true,
        interactionDyeStation = true,
        interactionLockpicking = true,
        interactionFurniturePreview = true,
        interactionSiegeWeapons = true,
        interactionChatting = true,
        werewolfThirdPerson = true,
        combatFirstPerson = false       
    }
    
    TEC.savedVariables = ZO_SavedVars:NewAccountWide("TECSavedVariables", TEC.settingsRev, nil, defaults)
    
    forceFirstPerson = TEC.savedVariables.forceFirstPerson
    animateCamera = TEC.savedVariables.animateCamera
    combatCenter = TEC.savedVariables.combatCenter
    interactionCrafting = TEC.savedVariables.interactionCrafting
    interactionDyeStation = TEC.savedVariables.interactionDyeStation
    interactionLockpicking = TEC.savedVariables.interactionLockpicking
    interactionFurniturePreview = TEC.savedVariables.interactionFurniturePreview
    interactionSiegeWeapons = TEC.savedVariables.interactionSiegeWeapons
    interactionChatting = TEC.savedVariables.interactionChatting
    werewolfThirdPerson = TEC.savedVariables.werewolfThirdPerson
    combatFirstPerson = TEC.savedVariables.combatFirstPerson     

	local startingCameraPosition = tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_HORIZONTAL_POSITION_MULTIPLIER))
	if startingCameraPosition == 0 then
		cameraCentered = true
	else
		cameraCentered = false
	end	
    cameraForcedCenter = cameraCentered

    TEC.CreateSettingsWindow()
    INTERACTION:OnScreenResized()
    
    addonInitialized = true
    
end

------------------------------------------------------
-- OVERRIDE: OnScreenResized
------------------------------------------------------
function ZO_Interaction:OnScreenResized()
    local width, height = GuiRoot:GetDimensions()

    local divider = self.control:GetNamedChild("Divider")
    divider:ClearAnchors()
    divider:SetAnchor(RIGHT, GuiRoot, TOPRIGHT, -width * 0.0534, height * .5)

    local chatterWidth = width * 0.3
    divider:SetWidth(chatterWidth)

    for i = 1, 10 do
        local chatterOption = GetControl(self.chatterOptionName, i)
        chatterOption:SetWidth(chatterWidth - 30)
    end
end
------------------------------------------------------
-- GameCameraDeactivated
------------------------------------------------------
function TEC.GameCameraDeactivated()
    iType = GetInteractionType()
	if iType == INTERACTION_CRAFT then
    	if interactionCrafting then
            SetInteractionUsingInteractCamera(not interactionCrafting)
        else
            return
        end
	end
	if iType == INTERACTION_DYE_STATION then
    	if interactionDyeStation then
            SetInteractionUsingInteractCamera(not interactionDyeStation)
        else
            return
        end
	end
	if iType == INTERACTION_LOCKPICK then
    	if interactionLockpicking then
            SetInteractionUsingInteractCamera(not interactionLockpicking)
        else
            return            
        end
	end
	if iType == INTERACTION_FURNITURE then
    	if interactionFurniturePreview then
            SetInteractionUsingInteractCamera(not interactionFurniturePreview)
        else
            return            
        end
	end
	if iType == INTERACTION_SIEGE then
    	if interactionSiegeWeapons then
            SetInteractionUsingInteractCamera(not interactionSiegeWeapons)
        else
            return            
        end
	end
	if iType == INTERACTION_STABLE or iType == INTERACTION_CONVERSATION or iType == INTERACTION_VENDOR or iType == INTERACTION_BANK or iType == INTERACTION_GUILDBANK then
    	if interactionChatting then
            SetInteractionUsingInteractCamera(not interactionChatting)
        else
            return
        end
	end
end

------------------------------------------------------
-- ToggleForceFirstPerson
------------------------------------------------------
function TEC.ToggleForceFirstPerson()
	forceFirstPerson = not forceFirstPerson
	TEC.savedVariables.forceFirstPerson = forceFirstPerson
end

------------------------------------------------------
-- ToggleCenter
------------------------------------------------------
function TEC.ToggleCenter()
	cameraCentered = not cameraCentered
	TEC.UpdateCameraPosition()
end

------------------------------------------------------
-- ToggleCenterByKey
------------------------------------------------------
function TEC.ToggleCenterByKey()
    if not combatCenter then
        TEC.ToggleCenter()
    end
	cameraForcedCenter = cameraCentered
end

------------------------------------------------------
-- ToggleShoulder
------------------------------------------------------
function TEC.ToggleShoulder()
	cameraCentered = false
	shoulderCameraDistance = 0 - shoulderCameraDistance
	TEC.UpdateCameraPosition()
end

------------------------------------------------------
-- UpdateCameraPositionPosition
------------------------------------------------------
function TEC.UpdateCameraPosition()
    local newPosition
    
	if cameraCentered then
		newPosition = 0
	else
		newPosition = shoulderCameraDistance
	end
	
    SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_HORIZONTAL_POSITION_MULTIPLIER, newPosition)

	if not animateCamera then
		ToggleGameCameraFirstPerson()
		ToggleGameCameraFirstPerson()
	end	
end

------------------------------------------------------
-- CreateSettingsWindow
------------------------------------------------------
function TEC.CreateSettingsWindow()
  panelData = {
    type = "panel",
    name = "The Elder Cam",
    displayName = "The Elder Cam",
    author = "Eldrni",
    version = TEC.version,
    slashCommand = "/tec",
    registerForRefresh = true,
    registerForDefaults = true,
  }

  cntrlOptionsPanel = LAM2:RegisterAddonPanel("TEC_ASUGB", panelData)
  
  LAM2:RegisterOptionControls("TEC_ASUGB", {
      {
              type = "header",
              name = "General Settings",
      },
      {
              type = "checkbox",
              name = "Animate Camera",
              tooltip = "Animate the camera as it moves from shoulder to shoulder, moves to the center, or zooms in/out of first person.",
              default = false,
              getFunc = function() return TEC.savedVariables.animateCamera end,
              setFunc = function(newValue) 
                TEC.savedVariables.animateCamera = newValue
                animateCamera = newValue
              end,
      },
      {
              type = "header",
              name = "Interaction Settings",
      },
      {
			type = "description",
			text = "Don't use the interaction camera when...",
			width = "full"
      },            
      {
              type = "checkbox",
              name = "Crafting",
              tooltip = "Don't move the camera when you begin crafting.",
              default = false,
              getFunc = function() return TEC.savedVariables.interactionCrafting end,
              setFunc = function(newValue) 
                TEC.savedVariables.interactionCrafting = newValue
                interactionCrafting = newValue
              end,
      },
      {
              type = "checkbox",
              name = "Using a Dye Station",
              tooltip = "Don't move the camera when you use a dye station.",
              default = false,
              getFunc = function() return TEC.savedVariables.interactionDyeStation end,
              setFunc = function(newValue) 
                TEC.savedVariables.interactionDyeStation = newValue
                interactionDyeStation = newValue
              end,
      },                 
      {
              type = "checkbox",
              name = "Lockpicking",
              tooltip = "Don't move the camera when you are lockpicking.",
              default = false,
              getFunc = function() return TEC.savedVariables.interactionLockpicking end,
              setFunc = function(newValue) 
                TEC.savedVariables.interactionLockpicking = newValue
                interactionLockpicking = newValue
              end,
      },        
      {
              type = "checkbox",
              name = "Previewing Furniture",
              tooltip = "Don't move the camera when you are previewing furniture.",
              default = false,
              getFunc = function() return TEC.savedVariables.interactionFurniturePreview end,
              setFunc = function(newValue) 
                TEC.savedVariables.interactionFurniturePreview = newValue
                interactionFurniturePreview = newValue
              end,
      }, 
      {
              type = "checkbox",
              name = "Using Siege Weapons",
              tooltip = "Don't move the camera when you are using siege weapons.",
              default = false,
              getFunc = function() return TEC.savedVariables.interactionSiegeWeapons end,
              setFunc = function(newValue) 
                TEC.savedVariables.interactionSiegeWeapons = newValue
                interactionSiegeWeapons = newValue
              end,
      },
      {
              type = "checkbox",
              name = "Talking to NPCs",
              tooltip = "Don't move the camera when you are talking to NPCs.",
              default = false,
              getFunc = function() return TEC.savedVariables.interactionChatting end,
              setFunc = function(newValue) 
                TEC.savedVariables.interactionChatting = newValue
                interactionChatting = newValue
              end,
      },                       
      {
              type = "header",
              name = "First Person Settings",
      },      
      {
              type = "checkbox",
              name = "Force First Person Camera*",
              tooltip = "Force first person camera even while doing tasks such as riding a mount, assassinating* someone, sitting in a chair, etc.",
              default = false,
              getFunc = function() return TEC.savedVariables.forceFirstPerson end,
              setFunc = function(newValue) 
                TEC.savedVariables.forceFirstPerson = newValue
                forceFirstPerson = newValue
              end,
      },
      {
			type = "description",
			text = "* In order to stay in first person while assassinating someone, you must disable the 'assassination camera' under the main game options > camera.",
			width = "full"
      },
      {
              type = "checkbox",
              name = "Switch When Entering Combat",
              tooltip = "Switch to first person automatically when entering combat.",
              default = false,
              getFunc = function() return TEC.savedVariables.combatFirstPerson end,
              setFunc = function(newValue) 
                TEC.savedVariables.combatFirstPerson = newValue
                combatFirstPerson = newValue
              end,
      },            
      {
              type = "header",
              name = "Third Person Settings",
      },
      {
              type = "checkbox",
              name = "Center During Combat",
              tooltip = "When entering combat, center the camera automatically, and when combat ends, move the camera back to shoulder.",
              default = false,
              getFunc = function() return TEC.savedVariables.combatCenter end,
              setFunc = function(newValue) 
                TEC.savedVariables.combatCenter = newValue
                combatCenter = newValue
                cameraCentered = false
                TEC.UpdateCameraPosition()
              end,
      },
      {
			type = "description",
			text = "Enabling this option will disable the ability to manually center the camera.",
			width = "full"
      },
      {
              type = "checkbox",
              name = "Force Third Person When Werewolf",
              tooltip = "Force tird person camera, even if Force First person Camera is enabled, when the player becomes a werewolf.",
              default = false,
              getFunc = function() return TEC.savedVariables.werewolfThirdPerson end,
              setFunc = function(newValue) 
                TEC.savedVariables.werewolfThirdPerson = newValue
                werewolfThirdPerson = newValue
              end,
      },
                       
      
    })
end  

------------------------------------------------------
-- RegisterForUpdate
------------------------------------------------------
EVENT_MANAGER:RegisterForUpdate(TEC.name, 50, function()
    if (forceFirstPerson and not (werewolfThirdPerson and IsWerewolf())) or (combatFirstPerson and IsUnitInCombat("player")) then
        local currentCameraDistance = tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE))
        if currentCameraDistance > 0 then
            SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE, 0)
        end
    else
        local currentCameraDistance = tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE))
        if currentCameraDistance == 0 then
            SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE, 1)
        end
    end
    
    if combatCenter then
        if IsUnitInCombat("player") then
            if not cameraCentered then
                TEC.ToggleCenter()
            end
        else
            if cameraCentered then
                TEC.ToggleCenter()
            end            
        end
    end        
end)

------------------------------------------------------
-- RegisterForEvent
------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(TEC.name, EVENT_ADD_ON_LOADED, TEC.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(TEC.name, EVENT_GAME_CAMERA_DEACTIVATED, TEC.GameCameraDeactivated)

------------------------------------------------------
-- Bindings
------------------------------------------------------
ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_SHOULDER", "Toggle Left/Right Shoulder")
ZO_CreateStringId("SI_BINDING_NAME_CENTER_CAMERA", "Center Camera")
ZO_CreateStringId("SI_BINDING_NAME_FORCE_FIRST", "Toggle Force First Person")