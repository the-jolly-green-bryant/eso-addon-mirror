local ImmersiveGamePadDialogue = ZO_Object:Subclass()

-- TODO These are overwritten whenever the addon loads
ImmersiveGamePadDialogue_SavedVars = {}
local function InitializeMenu()
    ImmersiveGamePadDialogue_SavedVars = ZO_SavedVars:New("ImmersiveGamePadDialogue_SavedVars", 1, nil, { disableNameplate = true, disableBackground = true, disableKeybindStrip = true })

    local panelData = {
        type = "panel",
        name = "Immersive Dialogue for Gamepad",
        displayName = "Immersive Dialogue for Gamepad",
        author = "me",
        version = "1.0",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsData = {
        {
            type = "checkbox",
            name = "Disable Nameplate",
            tooltip = "Toggle this to disable showing the nameplate.",
            getFunc = function() return ImmersiveGamePadDialogue_SavedVars.disableNameplate end,
            setFunc = function(value)
                ImmersiveGamePadDialogue_SavedVars.disableNameplate = value 
            end,
			requiresReload = false,
            default = false,
        },
        {
            type = "checkbox",
            name = "Disable Background",
            tooltip = "Toggle this to disable showing the background.",
            getFunc = function() return ImmersiveGamePadDialogue_SavedVars.disableBackground end,
            setFunc = function(value)
                ImmersiveGamePadDialogue_SavedVars.disableBackground = value 
            end,
			requiresReload = false,
            default = false,
        },
        {
            type = "checkbox",
            name = "Disable Keybind strip",
            tooltip = "Toggle this to disable showing the keybind strip.",
            getFunc = function() return ImmersiveGamePadDialogue_SavedVars.disableKeybindStrip end,
            setFunc = function(value)
                ImmersiveGamePadDialogue_SavedVars.disableKeybindStrip = value 
            end,
			requiresReload = false,
            default = false,
        },
    }

    LibAddonMenu2:RegisterAddonPanel("ImmersiveGamePadDialogueOptions", panelData)
    LibAddonMenu2:RegisterOptionControls("ImmersiveGamePadDialogueOptions", optionsData)
end

local UI 	=
{
	TITLE 		        =	ZO_InteractWindow_GamepadTitle,
	BODY 		        =	ZO_InteractWindow_GamepadContainerText,
	DIVIDER 		    =	ZO_InteractWindow_GamepadContainerDivider,
	BG 	         		=	ZO_InteractWindow_GamepadBG,
	OPTIONS 			=	ZO_InteractWindow_GamepadContainerInteract,
	KB_BG 			    =	ZO_KeybindStripGamepadBackground,
}

local toggleBody = false
function ToggleBody()
	toggleBody = not toggleBody
	UI.BODY:SetHidden(toggleBody)
	UI.DIVIDER:SetHidden(toggleBody)
end

local toggleOptions = true
function ToggleOptions()
	toggleOptions = not toggleOptions
	UI.OPTIONS:SetHidden(toggleOptions)
end

function RepeatDialogue()
	GetChatterData()
end

function ImmersiveGamePadDialogue:Initialize()
	UI.TITLE:SetHidden(ImmersiveGamePadDialogue_SavedVars.disableNameplate)
	UI.BG:SetHidden(ImmersiveGamePadDialogue_SavedVars.disableBackground)
	UI.KB_BG:SetHidden(ImmersiveGamePadDialogue_SavedVars.disableKeybindStrip)
	UI.BODY:SetHidden(toggleBody)
	UI.DIVIDER:SetHidden(toggleBody)
	UI.OPTIONS:SetHidden(toggleOptions)
end


-- Register
function ImmersiveGamePadDialogue:OnLoaded( eventCode, addOnName )
	EVENT_MANAGER:UnregisterForEvent("ImmersiveGamePadDialogue", EVENT_ADD_ON_LOADED)
	ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_HIDE_BODY", "Toggle Hide Body")
	ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_HIDE_OPTIONS", "Toggle Hide Options")
	ZO_CreateStringId("SI_BINDING_NAME_REPEAT_DIALOGUE", "Repeat Dialogue")
	InitializeMenu()

	EVENT_MANAGER:RegisterForEvent( "ImmersiveGamePadDialogue_Init", 		EVENT_CHATTER_BEGIN, 			function(event) ImmersiveGamePadDialogue:Initialize() end )
end

EVENT_MANAGER:RegisterForEvent( "ImmersiveGamePadDialogue", EVENT_ADD_ON_LOADED, ImmersiveGamePadDialogue.OnLoaded )