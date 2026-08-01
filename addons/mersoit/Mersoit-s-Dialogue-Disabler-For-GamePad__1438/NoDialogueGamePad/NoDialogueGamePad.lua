local NoDialogueGamePad = ZO_Object:Subclass()
-- Stuff..
local STUFF 	=
{
	TITLE 		=	ZO_InteractWindow_GamepadTitle,
	BODY 		=	ZO_InteractWindow_GamepadContainerText,
	BG 			=	ZO_InteractWindow_GamepadBG,
}

function NoDialogueGamePad:Initialize()

	-- Set hidden text and background
	STUFF.BODY:SetHidden( true )
	STUFF.BG:SetHidden (true)
end

-- Register
function NoDialogueGamePad:OnLoaded( eventCode, addOnName )
	if ( addOnName ~= "MersDialogueDisablerForGamePad" ) then
		EVENT_MANAGER:RegisterForEvent( "NoDialogueGamePad_Init", 		EVENT_CHATTER_BEGIN, 			function(event) NoDialogueGamePad:Initialize() end )
	end
end

-- Register the addon.
EVENT_MANAGER:RegisterForEvent( "MersDialogueDisablerForGamePad", EVENT_ADD_ON_LOADED, NoDialogueGamePad.OnLoaded )