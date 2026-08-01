
-- The MIT License (MIT)

-- Copyright (c) 2016 Ak0

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
--
-- DISCLAIMER:
--
-- This Add-on is not created by, affiliated with or sponsored by ZeniMax
-- Media Inc. or its affiliates. The Elder Scrolls® and related logos are
-- registered trademarks or trademarks of ZeniMax Media Inc. in the United
-- States and/or other countries. All rights reserved.
--
-- You can read the full terms at:
-- https://account.elderscrollsonline.com/add-on-terms
--
---------------------------------------------------------------------------------

-- Define some constants that will be used troughout the addon.
local CONSTANT 	=
{
	NAME 		=	"Ak0sNoWrittenDialogue",
	AREA 		=	ZO_InteractWindowTargetArea,
	TITLE 		=	ZO_InteractWindowTargetAreaTitle,
	BODY 		=	ZO_InteractWindowTargetAreaBodyText,
	REWARD 		=	ZO_InteractWindowRewardAreaHeader,
	REWARDGOLD 	=	ZO_InteractWindowRewardAreaCurrency1,
	BG 			=	ZO_InteractWindowTopBG,
}

-- Function that sets the initial styling (Fires when you speak to a NPC).
function AkONWD_Initialize( addonName )

	-- Hide the text
	CONSTANT.BODY:SetHidden( true )
	-- Clear any anchors already set on CONSTANT.TITLE
	CONSTANT.TITLE:ClearAnchors()
	-- Reposition the NPCs name to the bottom of CONSTANT.BODY and move it 1px up.
	CONSTANT.TITLE:SetAnchor( BOTTOMLEFT, CONSTANT.BODY, nil, 0, -1 )

	-- Style the dialogue
	AkONWD_Style()

end

-- Function to toggle the body text.
function AkONWD_Toggle( event )

	-- Disable the keybinding if we are not in the Interact Window.
	if ZO_InteractWindow:IsHidden() then return end

	-- If the body text is hidden, show it and position the NPCs name accordingly.
	-- Else hide the body text and reposition the NPCs name.
	if 	CONSTANT.BODY:IsHidden() then
		-- Show the body text.
		CONSTANT.BODY:SetHidden( false )
		-- Clear any anchors previously set on CONSTANT.TITLE
		CONSTANT.TITLE:ClearAnchors()
		-- Reposition the NPCs name to the top of CONSTANT.BODY and move it 45px up.
		CONSTANT.TITLE:SetAnchor( TOPLEFT, CONSTANT.BODY, nil, 0, -45 )
	else
		-- Hide the body text.
		CONSTANT.BODY:SetHidden( true )
		-- Clear any anchors previously set on CONSTANT.TITLE
		CONSTANT.TITLE:ClearAnchors()
		-- Reposition the NPCs name to the bottom of CONSTANT.BODY and move it 1px up.
		CONSTANT.TITLE:SetAnchor( BOTTOMLEFT, CONSTANT.BODY, nil, 0, -1 )
	end

end

-- Function that removes dashes in names.
function AkONWD_Style( event )

	-- Remove the "-"s from the NPCs name.
	local NAME = ZO_InteractWindowTargetAreaTitle:GetText()
	CONSTANT.TITLE:SetText( string.sub(NAME, 2, -2) )
	-- Set the alignment of the NPCs name to the left.
	CONSTANT.TITLE:SetHorizontalAlignment( TEXT_ALIGN_LEFT )

	-- Push the top BG that is anchored to the title back, after moving the title.
	CONSTANT.BG:SetAnchor( TOPLEFT, CONSTANT.TITLE, TOPLEFT, -40, -120 )
	-- "-40 == -70" if "SlightlyImprovedDialogues" is installed

	-- Clear any anchors already set on CONSTANT.BODY
	CONSTANT.BODY:ClearAnchors()
	-- Add 30px padding to the left of the body text.
	CONSTANT.BODY:SetAnchor( BOTTOMLEFT, CONSTANT.AREA, nil, 30, 0 )
	-- Push the body text 42px down.
	CONSTANT.BODY:SetAnchor( BOTTOMRIGHT, CONSTANT.AREA, nil, 0, 42 )

	-- Clear any anchors already set on CONSTANT.REWARD
	CONSTANT.REWARD:ClearAnchors()
	-- Add 40px padding to the left of the reward window.
	CONSTANT.REWARD:SetAnchor( BOTTOMLEFT, CONSTANT.BODY, BOTTOMLEFT, 10, 40 )

	-- Always show the body text if it ends with > or " (If we are examining a book, a piece of paper or a dead body etc)
	local TEXT = ZO_InteractWindowTargetAreaBodyText:GetText()
	if string.sub( TEXT, -1, -1 ) == ">" or string.sub( TEXT, -1, -1 ) == '"' then
		-- Show the body text.
		CONSTANT.BODY:SetHidden( false )
		-- Clear any anchors previously set on CONSTANT.TITLE
		CONSTANT.TITLE:ClearAnchors()
		-- Reposition the NPCs name to the top of CONSTANT.BODY and move it 45px up.
		CONSTANT.TITLE:SetAnchor( TOPLEFT, CONSTANT.BODY, nil, 0, -45 )
	end

	if event == EVENT_QUEST_COMPLETE_DIALOG then -- If we are completing a quest.
		-- Basic styling that covers most quest reward scenarios.
		if (ZO_InteractWindowRewardAreaCurrency1) then -- If the quest gives a currency.
			ZO_InteractWindowRewardAreaCurrency1:ClearAnchors()
			ZO_InteractWindowRewardAreaCurrency1:SetAnchor( BOTTOMLEFT, ZO_InteractWindowRewardArea, nil, 40, 0 )
		end
		if (ZO_InteractWindowRewardAreaCurrency2) then -- If the quest gives more than 1 currency.
			ZO_InteractWindowRewardAreaCurrency1:ClearAnchors()
			ZO_InteractWindowRewardAreaCurrency1:SetAnchor( BOTTOMLEFT, ZO_InteractWindowRewardArea, nil, 40, -25 )
		end
	end

end

-- Function that registers all events.
function AkONWD_OnLoaded( eventCode, addonName )

	-- If the addon fails to load, don't register events.
	if ( addonName ~= CONSTANT.NAME ) then return end
		
	EVENT_MANAGER:RegisterForEvent( CONSTANT.NAME, 	EVENT_CHATTER_BEGIN, 			function(event) AkONWD_Initialize() end )
	EVENT_MANAGER:RegisterForEvent( CONSTANT.NAME, 	EVENT_CONVERSATION_UPDATED,		function(event) AkONWD_Style(event) end )
	EVENT_MANAGER:RegisterForEvent( CONSTANT.NAME, 	EVENT_QUEST_COMPLETE_DIALOG, 	function(event) AkONWD_Style(event) end )
	EVENT_MANAGER:RegisterForEvent( CONSTANT.NAME, 	EVENT_QUEST_OFFERED, 			function(event) AkONWD_Style(event) end )

end

-- Register the addon.
EVENT_MANAGER:RegisterForEvent( CONSTANT.NAME, EVENT_ADD_ON_LOADED, AkONWD_OnLoaded )