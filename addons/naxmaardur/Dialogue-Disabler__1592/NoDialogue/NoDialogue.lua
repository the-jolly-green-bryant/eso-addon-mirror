local NoDialogue = ZO_Object:Subclass()
local STUFF 	=
{
	TITLE 		=	ZO_InteractWindowTargetAreaTitle,
	BODY 		=	ZO_InteractWindowTargetAreaBodyText,
	BGT 		=	ZO_InteractWindowTopBG,
	BGB    		=	ZO_InteractWindowBottomBG,
	
}

function NoDialogue:Initialize()

	local NAME = ZO_InteractWindowTargetAreaTitle:GetText()
	STUFF.BODY:SetHidden( true )
	STUFF.TITLE:ClearAnchors()
	STUFF.TITLE:SetText( string.sub(NAME, 2, -2) )
	STUFF.BGT:SetHidden (true)
	STUFF.BGB:SetHidden (true)
	
	
end


function NoDialogue:OnLoaded( eventCode, addOnName )
	if ( addOnName ~= "NaxDialogueDisabler" ) then
		EVENT_MANAGER:RegisterForEvent( "NoDialogue_Init", 		EVENT_CHATTER_BEGIN, 			function(event) NoDialogue:Initialize() end )
	end
end


EVENT_MANAGER:RegisterForEvent( "NaxDialogueDisabler", EVENT_ADD_ON_LOADED, NoDialogue.OnLoaded )