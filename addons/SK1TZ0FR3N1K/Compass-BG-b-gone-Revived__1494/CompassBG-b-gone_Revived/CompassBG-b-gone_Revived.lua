-- This AddOn was originally AK0's, I'm just keeping it going.
   -- Since Compass BG-b-gone has ended up in the Discontinued & Outdated Catagory I decided not to link the updates to the original any longer.
   -- I will continue to keep it up to date under the new name.
   -- I do not have any plans to make this addon anything other than what it is.
      -- This addon simply makes the compass background transparent.

function OnLoaded( event, addon )
	if ( addon ~= "CompassBG-b-gone_Revived" ) then return end
	local compass_center = WINDOW_MANAGER:GetControlByName("ZO_CompassFrame", "Center")
	compass_center:SetHidden(true)
	local compass_left = WINDOW_MANAGER:GetControlByName("ZO_CompassFrame", "Left")
	compass_left:SetHidden(true)
	local compass_right = WINDOW_MANAGER:GetControlByName("ZO_CompassFrame", "Right")
	compass_right:SetHidden(true)
end

EVENT_MANAGER:RegisterForEvent( "CompassBG-b-gone_Revived", EVENT_ADD_ON_LOADED, OnLoaded )