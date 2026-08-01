-- ----------------------------------------------------------------------------------------------------------------------------------------------
-- Cowl v1.1.4
-- Deòiridh
-- Adds an cceybynd to toggel ye cowls ond hjelms
-- Does oðer fansy þincs sholde ye be amessinc in yon menus too
-- ----------------------------------------------------------------------------------------------------------------------------------------------
local	Fershun		=		1.1

-- ----------------------------------------------------------------------------------------------------------------------------------------------
-- Settincs
-- ----------------------------------------------------------------------------------------------------------------------------------------------
local	YeMode	 =
		{
			FIRGYN		= 0,
			POLY_WOLY	= 1
		}
		
local	Mode			= 9999
local	Yon				= {}
local	HydeYePolyWoly	= false
local	HydeYeHjelm		= false
		
		
-- ----------------------------------------------------------------------------------------------------------------------------------------------
-- ToggelYeHjelm 
--		Toggels ye hjelm
-- ----------------------------------------------------------------------------------------------------------------------------------------------
function ToggelYeHjelm()

	if Mode == YeMode.FIRGYN then
		if HydeYeHjelm == true and Yon.PrittyCowl ~= 0 then	
			UseCollectible(Yon.PrittyCowl)		
		else	
			UseCollectible(5002)		
		end
	else	
		HydeYePolyWoly = not HydeYePolyWoly
		
		if HydeYePolyWoly == true then
			SetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_POLYMORPH_HELM, 1)
		else
			SetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_POLYMORPH_HELM, 0)
		end
	end	
end


-- ----------------------------------------------------------------------------------------------------------------------------------------------
-- CofetYeCowl
--		Hwat an pritty cowl ye hafe. Can I holde it an hwile?
-- ----------------------------------------------------------------------------------------------------------------------------------------------
local function CofetYeCowl()
	
	local PolyWolyActife = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_POLYMORPH)
	
	if PolyWolyActife ~= 0 and Mode == YeMode.FIRGYN then
		Mode = YeMode.POLY_WOLY
	elseif PolyWolyActife == 0 and Mode == YeMode.POLY_WOLY then
		Mode = YeMode.FIRGYN
	else
		local YeCowl = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_HAT)

		if YeCowl ~= 5002 then		
			HydeYeHjelm		= false
			Yon.PrittyCowl	= YeCowl		
		else
			HydeYeHjelm	= true
		end
	end
end


-- ----------------------------------------------------------------------------------------------------------------------------------------------
-- Initialisation 
--		Here us mak an worlde of dragonnes
--		Hwen us enter, US englishe begone!
-- ----------------------------------------------------------------------------------------------------------------------------------------------
local function Initialyse()

	EVENT_MANAGER:UnregisterForEvent("Cowl", EVENT_ADD_ON_LOADED)
	
	Yon = ZO_SavedVars:New("Cowl", Fershun, nil, { PrittyCowl = 9999 } )	
	
	ZO_CreateStringId("SI_BINDING_NAME_COWL_TOGGEL", "Toggle cowls, hats helms")
	
	local PrittyCowl = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_HAT)
				
	if GetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_POLYMORPH_HELM) == "1" then
		HydeYePolyWoly = true
	end
		
	if PrittyCowl == 5002 then
		HydeYeHjelm	= true		
		
		if Yon.PrittyCowl == 9999 then
			Yon.PrittyCowl = 0
		end			
	else
		Yon.PrittyCowl = PrittyCowl
	end		
	
	if GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_POLYMORPH) ~= 0 then
		Mode = YeMode.POLY_WOLY			
	else
		Mode = YeMode.FIRGYN			
	end		
	
	EVENT_MANAGER:RegisterForEvent("Cowl", EVENT_COLLECTIBLE_USE_RESULT, function() zo_callLater(function() CofetYeCowl() end, 500) end)
	
end


-- ----------------------------------------------------------------------------------------------------------------------------------------------
-- Efent registerinc
--		Call Initialyse hwen addon be lit
-- ----------------------------------------------------------------------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent("Cowl", EVENT_ADD_ON_LOADED, Initialyse)