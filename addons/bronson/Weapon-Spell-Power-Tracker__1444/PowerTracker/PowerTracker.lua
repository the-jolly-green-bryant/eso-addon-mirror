-- 
-- Simple addon to show current weapon and spell power
-- or weapon and spell critical rating
--
local firstTime = false;
local initialised = false;
local CRIT_COEFFICIENT = 219.1;
local MEDPOWERCHANGE = 200;
local LARGEPOWERCHANGE = 300;
local MEGAPOWERCHANGE = 450;
local MAX_MODE = 3;
local lastSP;
local lastWP;

local MAXFLOATERS = 10;
local FLOATHEIGHT = 200;
local nextFloater = 1;
local floaters = {};

PowerTracker = {};
PowerTracker.name = "PowerTracker";

-- Default variables structure to apply for new saved data
-- Show power now set to a mode structure
-- 0 = Crit chances
-- 1 = Weapon and spell power
-- 2 = Weapon & Weapon crit
-- 3 = Spell power & spell crit
PowerTracker.Default = {
	OffsetX = 480,
	OffsetY = 480,
	ShowPower = 2
}


function PowerTracker:Initialize()

	PowerTracker.savedVariables = ZO_SavedVars:NewCharacterIdSettings("PowerTrackerVars", 2, "namespace", PowerTracker.Default );
	PowerTrackerWindow:ClearAnchors();
	PowerTrackerWindow:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, PowerTracker.savedVariables.OffsetX, PowerTracker.savedVariables.OffsetY);

	--Add a fragment for the power tracker XML control to the GUI so it will be hidden inside menus
	local fragment = ZO_FadeSceneFragment:New(PowerTrackerWindow, nil, 0);
	HUD_SCENE:AddFragment(fragment);
	HUD_UI_SCENE:AddFragment(fragment);
	initialised = true;
	
	setupFloaters();
	firstTime = true;
	
end

function PowerTracker.OnAddOnLoaded(event, addonName)
  -- The event fires each time *any* addon loads - but we only care about when our own addon loads.
  if addonName == PowerTracker.name then
    PowerTracker:Initialize();
  end
end


-- On click we toggle between showing power and critical chance
function PowerTracker.OnClicked( self, button, upInside, bctrl, balt, bshift, command )
	
	if ( button == 2 ) then
		local x = PowerTracker.savedVariables.ShowPower + 1;
		if ( x > MAX_MODE ) then
			x = 0;
		end
		PowerTracker.savedVariables.ShowPower = x;
	end
end

function PowerTracker.OnUpdate()

	if ( firstTime ) then
		firstTime = false;
		d(" ");
		d("Weapon & Spell Power Tracker");
		d("To Contact Author With Ideas/Feedback:");
		d("EU Server  @bronson242");
		d(" ");
	end

	if ( initialised ) then

		local wp = GetPlayerStat(STAT_POWER,       STAT_BONUS_OPTION_APPLY_BONUS);
		local sp = GetPlayerStat(STAT_SPELL_POWER, STAT_BONUS_OPTION_APPLY_BONUS);
		local wc = GetPlayerStat(STAT_CRITICAL_STRIKE, STAT_BONUS_OPTION_APPLY_BONUS) / CRIT_COEFFICIENT;
		local sc = GetPlayerStat(STAT_SPELL_CRITICAL,  STAT_BONUS_OPTION_APPLY_BONUS)	/ CRIT_COEFFICIENT;
		
		-- Check for changes; floating value display
		addFloatingValue ( "%d", wp, lastWP, 0,  135.0/255,205.0/255,50.0/255,0.9, 160.0/255,0,0,0.7 );
		addFloatingValue ( "%d", sp, lastSP, 90, 135.0/255,206.0/255,250.0/255,0.9, 0,0,160.0/255,0.7 );
		lastWP = wp;
		lastSP = sp;
				
		-- Show values based on the mode selected
		if ( PowerTracker.savedVariables.ShowPower == 1 ) then
			updateTracker ( false, false, "%d", wp, "%d", sp, "", "%" );
		elseif (PowerTracker.savedVariables.ShowPower == 0 ) then 
			updateTracker ( false, false, "%0.2f", wc, "%0.2f", sc, "%", "%" );
		elseif (PowerTracker.savedVariables.ShowPower == 2 ) then 
			updateTracker ( false, true, "%d", wp, "%0.2f", wc, "", "%" );
		elseif (PowerTracker.savedVariables.ShowPower == 3 ) then 
			updateTracker ( true, false, "%d", sp, "%0.2f", sc, "", "%" );
		end
		
		moveFloaters()
		
	end
	
end

function updateTracker ( showWPImage, showSPImage, format1, value1, format2, value2, suffix1, suffix2 )

		WPImage:SetHidden(showWPImage);
		SPImage:SetHidden(showSPImage);
		PowerTrackerWindowWeaponPower:SetText(string.format(format1, value1 ) .. suffix1 );
		PowerTrackerWindowSpellPower:SetText(string.format(format2, value2 ) .. suffix2);
	
end

function PowerTracker.OnIndicatorMoveStop()

	local left = PowerTrackerWindow:GetLeft();
	local top  = PowerTrackerWindow:GetTop();

	PowerTracker.savedVariables.OffsetX = left;
	PowerTracker.savedVariables.OffsetY = top;
		
end

function setupFloaters()

	for i=1, MAXFLOATERS do
		local dynamicControl = CreateControlFromVirtual("PTFloatingValue", PowerTrackerWindow, "PowerTrackerFloat", i );	
		dynamicControl:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, PowerTracker.savedVariables.OffsetX+15, PowerTracker.savedVariables.OffsetY-FLOATHEIGHT);
		floaters[i] = dynamicControl;
	end


end

function moveFloaters()

	for i=1,MAXFLOATERS do
		local dynamicControl = floaters[i];
		if ( dynamicControl ~= nil ) then
			if ( dynamicControl:GetTop() > PowerTracker.savedVariables.OffsetY-FLOATHEIGHT ) then
				dynamicControl:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, dynamicControl:GetLeft(), dynamicControl:GetTop()-1 );
			else
				dynamicControl:SetText("");
			end
		end
	end

end

function addFloatingValue ( format1, currentvalue, lastvalue, xoffset, r,g,b,a, mr,mg,mb,ma )

	if ( lastvalue == nill ) then
		return;
	end
	if ( currentvalue == lastvalue ) then
		return;
	end

	
	-- Get our floater
	local dynamicControl = floaters[nextFloater]
	dynamicControl:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, PowerTracker.savedVariables.OffsetX+15+xoffset, PowerTracker.savedVariables.OffsetY-25);
	dynamicControl:SetText(string.format(format1, currentvalue-lastvalue));

	-- font information
	local fontSize = 16;
 
	-- Use second set of colors for negative values
	local newvalue = currentvalue - lastvalue;
	if ( newvalue > 0 ) then
		dynamicControl:SetColor(r,g,b,a);
	else
		dynamicControl:SetColor(mr,mg,mb,ma);
	end

	-- Set our font size
	if ( newvalue > MEDPOWERCHANGE ) then
		fontSize = 17;
	end
	if ( newvalue > LARGEPOWERCHANGE ) then
		fontSize = 19;
	end
	if ( newvalue > MEGAPOWERCHANGE ) then
		fontSize = 22;
	end
	local face = ZoFontChat:GetFontInfo();
    local font = ("%s|%s"):format(face, fontSize);
    dynamicControl:SetFont(font);
	
	-- Prepare for next one
	nextFloater = nextFloater + 1;
	if ( nextFloater > MAXFLOATERS ) then
		nextFloater = 1;
	end

end
 
-- Register Event handlers for addon
EVENT_MANAGER:RegisterForEvent(PowerTracker.name, EVENT_ADD_ON_LOADED, PowerTracker.OnAddOnLoaded);
