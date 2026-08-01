  ---------------------------------------
  -- Advanced Nameplates
  -- Tierney11290 (Stratejacket) - 2017
  ---------------------------------------
  
ANP = ANP or {}
ANP.appName = "AdvancedNameplates"
local LMP = LibStub:GetLibrary("LibMediaProvider-1.0")

function ANP.Fonts()

  -- If using Keyboard & Mouse mode then do the following
  if IsInGamepadPreferredMode() == false then
  
	-- Keyboard Font Calls for LAM --
	if ANP.SV.FontsKB == "Adventure" then
		ANP.FontAdventureKB()
	elseif ANP.SV.FontsKB == "Arialn" then
		ANP.FontArialnKB()
	elseif ANP.SV.FontsKB == "Consolas" then
		ANP.FontConsolasKB()
	elseif ANP.SV.FontsKB == "ESO Cartographer" then
		ANP.FontCartographerKB()
	elseif ANP.SV.FontsKB == "Fitzgerald" then
		ANP.FontFitzgeraldKB()
	elseif ANP.SV.FontsKB == "Futura Condensed" then
		ANP.FontFuturaCondensedKB()
	elseif ANP.SV.FontsKB == "Gentium" then
		ANP.FontGentiumKB()
	elseif ANP.SV.FontsKB == "Hooked Up" then
		ANP.FontHookedUpKB()
	elseif ANP.SV.FontsKB == "ProseAntique" then
		ANP.FontProseAntiqueKB()
	elseif ANP.SV.FontsKB == "Skurri" then
		ANP.FontSkurriKB()
	elseif ANP.SV.FontsKB == "Futura Condensed Medium" then
		ANP.FontSkyrimKB()
	elseif ANP.SV.FontsKB == "Skyrim Handwritten" then
		ANP.FontHandwrittenKB()
	elseif ANP.SV.FontsKB == "Trajan Pro" then
		ANP.FontTrajanProGP()
	elseif ANP.SV.FontsKB == "Univers 55" then
		ANP.FontUnivers55KB()		
	elseif ANP.SV.FontsKB == "Univers 57" then
		ANP.FontUnivers57KB()
	else ANP.SV.FontsKB = "Univers 67"
		ANP.FontUnivers67KB()
	end

  -- If using Gamepad mode then do the following
  elseif IsInGamepadPreferredMode() == true then	

    -- Gamepad Font Calls for LAM --
	if ANP.SV.FontsGP == "Adventure" then
		ANP.FontAdventureGP()
	elseif ANP.SV.FontsGP == "Arialn" then
		ANP.FontArialnGP()
	elseif ANP.SV.FontsGP == "Consolas" then
		ANP.FontConsolasGP()
	elseif ANP.SV.FontsGP == "ESO Cartographer" then
		ANP.FontCartographerGP()
	elseif ANP.SV.FontsGP == "Fitzgerald" then
		ANP.FontFitzgeraldGP()
	elseif ANP.SV.FontsGP == "Gentium" then
		ANP.FontGentiumGP()
	elseif ANP.SV.FontsGP == "Hooked Up" then
		ANP.FontHookedUpGP()
	elseif ANP.SV.FontsGP == "ProseAntique" then
		ANP.FontProseAntiqueGP()
	elseif ANP.SV.FontsGP == "Skurri" then
		ANP.FontSkurriGP()
	elseif ANP.SV.FontsGP == "Skyrim Handwritten" then
		ANP.FontHandwrittenGP()
	elseif ANP.SV.FontsGP == "Trajan Pro" then
		ANP.FontTrajanProGP()
	elseif ANP.SV.FontsGP == "Univers 55" then
		ANP.FontUnivers55GP()		
	elseif ANP.SV.FontsGP == "Univers 57" then
		ANP.FontUnivers57GP()
	elseif ANP.SV.FontsGP == "Univers 67" then
		ANP.FontUnivers67GP()
	else ANP.SV.FontsGP = "Futura Condensed"
		ANP.FontFuturaCondensedGP()
	end
  end
end

function ANP.SizeKB()
	-- No current function available for Nameplate sizes
end

function OnAddOnLoaded(eventCode, addOnName)
    if (ANP.appName ~= addOnName) then return end
	
	LMP:Register("font", "Adventure",               [[AdvancedNameplates/fonts/Adventure.ttf]]              	)
    LMP:Register("font", "Arialn",         			[[AdvancedNameplates/fonts/arialn.ttf]]           			)
    LMP:Register("font", "ESO Cartographer",  		[[AdvancedNameplates/fonts/esocartographer-bold.otf]]   	)
    LMP:Register("font", "Fitzgerald",      		[[AdvancedNameplates/fonts/Fitzgerald.ttf]]       	    	)
    LMP:Register("font", "Gentium",         		[[AdvancedNameplates/fonts/Gentium.ttf]]                	)
    LMP:Register("font", "HookedUp",             	[[AdvancedNameplates/fonts/HookedUp.ttf]]               	)
    LMP:Register("font", "Futura Condensed Medium", [[AdvancedNameplates/fonts/fcm.ttf]]    )

	
	local defaults = {
		FontsKB = "Univers 67",
		FontsGP = "Futura Condensed",
	}
	
	ANP.SV = ZO_SavedVars:NewAccountWide("AdvancedNameplates_SavedVariables", 1, nil, defaults)
	
 -- ANP.SizeKB()
	ANP.Fonts()
	
	ANP:initLAM()
	
end

EVENT_MANAGER:RegisterForEvent(ANP.appName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(ANP.appName, EVENT_PLAYER_ACTIVATED, ANP.Fonts)