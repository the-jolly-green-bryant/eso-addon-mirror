
-- The MIT License (MIT)

-- Copyright (c) 2016 Shaen

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice notice shall be included in
-- all copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.
---------------------------------------------------------------------------------

local function d() end

local NWD = ZO_Object:Subclass()

local CONSTANT 	=
{
	AREA 		=	ZO_InteractWindowTargetArea,
	TITLE 		=	ZO_InteractWindowTargetAreaTitle,
	BODY 		=	ZO_InteractWindowTargetAreaBodyText,
	BG 			=	ZO_InteractWindowTopBG,
}

local CHATTER_OPTION_INDENT = 30
local BACKGROUND_OFFSETX = -40
local BACKGROUND_HEIGHT = 120


function NWD:Initialize()

	CONSTANT.BODY:SetHidden( true )
	CONSTANT.TITLE:ClearAnchors()
	CONSTANT.TITLE:SetAnchor( BOTTOMLEFT, CONSTANT.BODY, nil, 0, -1 )

	NWD:Style()

end


function NWD_Toggle()


	if 	CONSTANT.BODY:IsHidden() then
		CONSTANT.BODY:SetHidden( false )
		CONSTANT.TITLE:ClearAnchors()
		CONSTANT.TITLE:SetAnchor( TOPLEFT, CONSTANT.BODY, nil, 0, -45 )
	else
		CONSTANT.BODY:SetHidden( true )
		CONSTANT.TITLE:ClearAnchors()
		CONSTANT.TITLE:SetAnchor( BOTTOMLEFT, CONSTANT.BODY, nil, 0, -1 )
	end

end



function ZO_Interaction:AnchorBottomBG(optionControl)
    self.control:GetNamedChild("BottomBG"):ClearAnchors()
    self.control:GetNamedChild("BottomBG"):SetAnchor(TOPRIGHT, GuiRoot, RIGHT)
    self.control:GetNamedChild("BottomBG"):SetAnchor(BOTTOMLEFT, optionControl, BOTTOMLEFT, BACKGROUND_OFFSETX - CHATTER_OPTION_INDENT, BACKGROUND_HEIGHT)
end

local function ChangeBackgrounOffsetX()
    ZO_InteractWindowTopBG:ClearAnchors()
    ZO_InteractWindowTopBG:SetAnchor(BOTTOMRIGHT, GuiRoot, RIGHT)
    ZO_InteractWindowTopBG:SetAnchor(TOPLEFT, ZO_InteractWindowTargetAreaTitle, nil, BACKGROUND_OFFSETX, -BACKGROUND_HEIGHT)
end


local function OverrideOptionsSetText()
    for index, control in ipairs(INTERACTION.optionControls) do
        local setText = control.SetText
        function control:SetText(text)
            local previousOptionsWithText = 0
            d(index)
            for i = 1, index do
                d(INTERACTION.optionControls[i])
                if INTERACTION.optionControls[i].optionText ~= "" then
                    previousOptionsWithText = previousOptionsWithText + 1
                end
            end
            d("-")
            setText(self, previousOptionsWithText..". "..text)
        end
    end
end


function NWD:Style( event )


	local NAME = ZO_InteractWindowTargetAreaTitle:GetText()
	CONSTANT.TITLE:SetText( string.sub(NAME, 2, -2) )
	CONSTANT.TITLE:SetHorizontalAlignment( TEXT_ALIGN_LEFT )
	CONSTANT.TITLE:SetFont("ZoFontCallout")


end


function NWD:OnLoaded( eventCode, addOnName )
	if ( addOnName ~= "NoWrittenDialogue" ) then

		ZO_CreateStringId( "SI_BINDING_NAME_TOGGLE_NWD", "Toggle Text" )
		
		EVENT_MANAGER:UnregisterForEvent("NoWrittenDialogue", EVENT_ADD_ON_LOADED)
		ChangeBackgrounOffsetX()
        OverrideOptionsSetText()
		
		EVENT_MANAGER:RegisterForEvent( "NWD_Init", 	EVENT_CHATTER_BEGIN, 			function(event) NWD:Initialize() end )
		EVENT_MANAGER:RegisterForEvent( "NWD_Update", 	EVENT_CONVERSATION_UPDATED,		function(event) NWD:Style(event) end )
		EVENT_MANAGER:RegisterForEvent( "NWD_Complete", EVENT_QUEST_COMPLETE_DIALOG, 	function(event) NWD:Style(event) end )
		EVENT_MANAGER:RegisterForEvent( "NWD_Offered", 	EVENT_QUEST_OFFERED, 			function(event) NWD:Style(event) end )
	end
end


EVENT_MANAGER:RegisterForEvent( "NoWrittenDialogue", EVENT_ADD_ON_LOADED, NWD.OnLoaded )
