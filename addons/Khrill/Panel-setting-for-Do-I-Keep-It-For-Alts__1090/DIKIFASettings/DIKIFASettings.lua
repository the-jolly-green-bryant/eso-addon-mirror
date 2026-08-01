------------------------------------------
--                Settings              --
--               for DIKIFA             --
--                by Khrill             --
--                                      --
--                v 1.6.0               --
-- 	  review 1.6.0 Khrill&Wandamey   	--
------------------------------------------
-- v1.6.0 update to API Eso 2.3
-- v1.5.0 update to API Eso 2.2
local ADDON_NAME = "DIKIFASettings"
local ADDON_DISPLAYNAME = "Do I keep it for alts?"
local ADDON_VERSION = "1.6.0"
local ADDON_AUTHOR="|c0096ffWandamey|r & |cFF6A00Khrill|r"  
local DIKIFAisActive = false
local DIKIFASettingValues = nil
local DIKIFADefaults = {}
local DIKIFAStrings = {}
local DIKIFALang = "en"
-- faut encore faire ton truc magique avec les caractères spéciaux là dessous mais normalement mon notepad code comme il faut. 
-- et puis tester les options. c'est trop moche quand c'est pas mes settings, moi je peux pas.
-- j'ai sorti le vert pour pas qu'on pense que ça permettait d'éditer quoi que ce soit. (je me souviens bien de quand j'étais encore plus noob)

-- La table magique! et mon Notepad++ il prend son pied à faire des remplacer de folie *sifflote*
--[[
   à : \195\160    è : \195\168    ì : \195\172    ò : \195\178    ù : \195\185
   á : \195\161    é : \195\169    í : \195\173    ó : \195\179    ú : \195\186
   â : \195\162    ê : \195\170    î : \195\174    ô : \195\180    û : \195\187
   ã : \195\163    ë : \195\171    ï : \195\175    õ : \195\181    ü : \195\188
   ä : \195\164                    ñ : \195\177    ö : \195\182
   æ : \195\166                                    ø : \195\184
   ç : \195\167                                    œ : \197\147
   Ä : \195\132   Ö : \195\150   Ü : \195\156    ß : \195\159
]]

DIKIFAStrings.settings = 		{en = "|cFF6A00Settings|r", 		de = "|cFF6A00Einstellungen|r",				fr = "|cFF6A00R\195\169glages|r"}
DIKIFAStrings.trophies = 		{en = "Trophies", 					de = "Troph\195\164en", 					fr = "Troph\195\169es"}
DIKIFAStrings.motifs = 			{en = "Motif books", 				de = "Stile B\195\188cher", 				fr = "Livres de motifs"}
DIKIFAStrings.recipes = 		{en = "Recipes", 					de = "Rezepte",								fr = "Recettes"}
DIKIFAStrings.fishes = 			{en = "Rare fishes", 				de = "Seltene Fische", 						fr = "Poissons rares"}
DIKIFAStrings.foodanddrink = 	{en = "Food & Drink", 				de = "Essen & Trinken", 					fr = "Nourriture & Boisson"}
DIKIFAStrings.cookingfire = 	{en = "Cooking fire", 				de = "Feuerstelle", 						fr = "Feu de cuisine"}
DIKIFAStrings.titleknow = 		{en = "'Known By' header", 			de = "'Erlernt von' Titelkopf", 			fr = "En-t\195\170te 'Connu de'"}
DIKIFAStrings.showknown = 		{en = "Characters who know", 		de = "Charaktere die kennen", 				fr = "Persos qui connaissent"}
DIKIFAStrings.knowncolor = 		{en = "Color", 						de = "Farbe", 								fr = "Couleur"}
DIKIFAStrings.titledontknow = 	{en = "'Not Yet Known By' header", 	de = "'Noch nicht erlernt von' Titelkopf", 	fr = "En-t\195\170te 'Pas encore connu de'"}
DIKIFAStrings.showunknown = 	{en = "Characters who don't know", 	de = "Charaktere die nicht kennen", 		fr = "Persos qui ne connaissent pas"}
DIKIFAStrings.whattodisplay = 	{en = "|c0096FFWhat to display|r", 	de = "|c0096FFLinien zu anzeigenr", 		fr = "|c0096FFLignes à afficher|r"}


local function DIKIFAGetDefaultsSettings()
	-- Get defaults values from DIKIFA addon
	local defaults = {
		TrophiesOn 			= (DIKIFA.TrophiesOn>0),
		MotifsOn 			= (DIKIFA.MotifsOn>0),
		RecipesOn 			= (DIKIFA.RecipesOn>0),
		FishesOn 			= (DIKIFA.FishesOn>0),
		ShowAtCookingFire 	= (DIKIFA.ShowAtCookingFire>0),
		FoodDrinkOn			= (DIKIFA.FoodDrinkOn>0),
		ShowUnknown 		= (DIKIFA.ShowUnknown>0),
		ShowKnown 			= (DIKIFA.ShowKnown>0),				
		ShowTitleKnown		= (DIKIFA.ShowTitleKnown>0),			
		ShowTitleUnknown	= (DIKIFA.ShowTitleUnknown>0),							
		KnownColor 			= {r=DIKIFA.rkn, g=DIKIFA.gkn, b=DIKIFA.bkn},
		UnknownColor 		= {r=DIKIFA.rukn, g=DIKIFA.gukn, b=DIKIFA.bukn},
	}
	return defaults
end
local function DIKIFASetSettings()
	--Set saved settings to DIKIFA addon
	if DIKIFASettingValues.ShowAtCookingFire 	then DIKIFA.ShowAtCookingFire 	= 2 else DIKIFA.ShowAtCookingFire 	= 0 end		--
	if DIKIFASettingValues.TrophiesOn 			then DIKIFA.TrophiesOn 			= 2 else DIKIFA.TrophiesOn 			= 0 end
	if DIKIFASettingValues.MotifsOn 			then DIKIFA.MotifsOn 			= 2 else DIKIFA.MotifsOn 			= 0 end
	if DIKIFASettingValues.RecipesOn 			then DIKIFA.RecipesOn 			= 2 else DIKIFA.RecipesOn 			= 0 end
	if DIKIFASettingValues.FishesOn 			then DIKIFA.FishesOn 			= 2 else DIKIFA.FishesOn 			= 0 end
	if DIKIFASettingValues.FoodDrinkOn 			then DIKIFA.FoodDrinkOn 		= 2 else DIKIFA.FoodDrinkOn 		= 0 end
	if DIKIFASettingValues.ShowTitleUnknown 	then DIKIFA.ShowTitleUnknown 	= 2 else DIKIFA.ShowTitleUnknown 	= 0 end
	if DIKIFASettingValues.ShowTitleKnown 		then DIKIFA.ShowTitleKnown 		= 2 else DIKIFA.ShowTitleKnown 		= 0 end 	--
	if DIKIFASettingValues.ShowUnknown 			then DIKIFA.ShowUnknown 		= 2 else DIKIFA.ShowUnknown 		= 0 end
	if DIKIFASettingValues.ShowKnown 			then DIKIFA.ShowKnown 			= 2 else DIKIFA.ShowKnown 			= 0 end 	--
	if DIKIFASettingValues.ShowIntroKnownBy		then DIKIFA.ShowIntroKnownBy	= 2 else DIKIFA.ShowIntroKnownBy	= 0 end		--
	DIKIFA.rkn 		= DIKIFASettingValues.KnownColor.r
	DIKIFA.gkn 		= DIKIFASettingValues.KnownColor.g
	DIKIFA.bkn 		= DIKIFASettingValues.KnownColor.b
	DIKIFA.rukn 	= DIKIFASettingValues.UnknownColor.r
	DIKIFA.gukn 	= DIKIFASettingValues.UnknownColor.g
	DIKIFA.bukn 	= DIKIFASettingValues.UnknownColor.b
	DIKIFA:SubmitSettings()
end
local function DIKIFASetSettingsPanel()
	--// Settings panel LAM2
	local LAM2 = LibStub("LibAddonMenu-2.0")
	if ( not LAM2 ) then return end
	
	local panelData = {
			type = "panel",
			name = ADDON_DISPLAYNAME,
			displayName = "|cFF6A00D|r|c0096FFO|r I KEEP IT For Alts ?",
			author = ADDON_AUTHOR,
			version = ADDON_VERSION,
			slashCommand = "/dikifa",
			registerForRefresh = true,
			registerForDefaults = true,
	}
	local settingsPanel = LAM2:RegisterAddonPanel(ADDON_NAME, panelData)

	local optionsTable = {
		------------SETTINGS--------------
		{
			type = "header",
			name = DIKIFAStrings.settings[DIKIFALang], --Settings,
--			name = "|cFF6A00"..DIKIFAStrings.settings[DIKIFALang].."|r", --Settings,
			width = "full",
		},
		{	-- Trophies
			type = "checkbox",
			name = DIKIFAStrings.trophies[DIKIFALang], --"Trophies",
--			tooltip = "Support for EN DE FR, may work with other languages based on what was translated already",
			getFunc = function() return DIKIFASettingValues.TrophiesOn end,
			setFunc = function(value) DIKIFASettingValues.TrophiesOn = value
									if value then DIKIFA.TrophiesOn = 2 else DIKIFA.TrophiesOn = 0 end
									DIKIFA.SubmitSettings()
			end,
			width = "full",
			default = DIKIFADefaults.TrophiesOn,
		},
		{	-- Motifs
			type = "checkbox",
			name = DIKIFAStrings.motifs[DIKIFALang], --"Motifs",
--			tooltip = "working for English, Français, Deutsch only",
			getFunc = function() return DIKIFASettingValues.MotifsOn end,
			setFunc = function(value) DIKIFASettingValues.MotifsOn = value
									if value then DIKIFA.MotifsOn = 2 else DIKIFA.MotifsOn = 0 end
									DIKIFA.SubmitSettings()
			end,
			width = "full",
			default = DIKIFADefaults.MotifsOn,
		},
		{	-- Recipes
			type = "checkbox",
			name = DIKIFAStrings.recipes[DIKIFALang], --"Recipes",
--			tooltip = "Should work in any language",
			getFunc = function() return DIKIFASettingValues.RecipesOn end,
			setFunc = function(value) DIKIFASettingValues.RecipesOn = value
									if value then DIKIFA.RecipesOn = 2 else DIKIFA.RecipesOn = 0 end
									DIKIFA.SubmitSettings()
			end,
			width = "full",
			default = DIKIFADefaults.RecipesOn,
		},
		{	-- Fishes
			type = "checkbox",
			name = DIKIFAStrings.fishes[DIKIFALang], --"Fishes",
--			tooltip = "Support for EN DE FR, may work with other languages based on what was translated already",
			getFunc = function() return DIKIFASettingValues.FishesOn end,
			setFunc = function(value) DIKIFASettingValues.FishesOn = value
									if value then DIKIFA.FishesOn = 2 else DIKIFA.FishesOn = 0 end
									DIKIFA.SubmitSettings()
			end,
			width = "full",
			default = DIKIFADefaults.FishesOn,
		},
		{	-- Food & Drink
			type = "checkbox",
			name = DIKIFAStrings.foodanddrink[DIKIFALang], --"Food&Drink",
--			tooltip = "Should work in any language",
			getFunc = function() return DIKIFASettingValues.FoodDrinkOn end,
			setFunc = function(value) DIKIFASettingValues.FoodDrinkOn = value
									if value then DIKIFA.FoodDrinkOn = 2 else DIKIFA.FoodDrinkOn = 0 end
									DIKIFA.SubmitSettings()
			end,
			width = "full",
			default = DIKIFADefaults.FoodDrinkOn,
		},
		{	-- Show At Cooking Fire
			type = "checkbox",
			name = DIKIFAStrings.cookingfire[DIKIFALang], --"Show at Cooking Fire",
			--tooltip = "",
			getFunc = function() return DIKIFASettingValues.ShowAtCookingFire end,
			setFunc = function(value) DIKIFASettingValues.ShowAtCookingFire = value
									if value then DIKIFA.ShowAtCookingFire = 2 else DIKIFA.ShowAtCookingFire = 0 end
									DIKIFA.SubmitSettings()
			end,
			width = "full",
			default = DIKIFADefaults.ShowAtCookingFire,
		},
		{
			type = "header",
			name = DIKIFAStrings.whattodisplay[DIKIFALang]
		},
		{	-- Show Known Title line
			type = "checkbox",
			name = DIKIFAStrings.titleknow[DIKIFALang], --"Show known",
			--tooltip = "",
			getFunc = function() return DIKIFASettingValues.ShowTitleKnown end,
			setFunc = function(value) DIKIFASettingValues.ShowTitleKnown = value
									if value then DIKIFA.ShowTitleKnown = 2 else DIKIFA.ShowTitleKnown = 0 end
									DIKIFA.SubmitSettings()
			end,
			width = "full",
			default = DIKIFADefaults.ShowTitleKnown,
		},
		{	-- Show Known
			type = "checkbox",
			name = DIKIFAStrings.showknown[DIKIFALang], --"Show known",
			--tooltip = "",
			getFunc = function() return DIKIFASettingValues.ShowKnown end,
			setFunc = function(value) DIKIFASettingValues.ShowKnown = value
									if value then DIKIFA.ShowKnown = 2 else DIKIFA.ShowKnown = 0 end
									DIKIFA.SubmitSettings()
			end,
			width = "full",
			default = DIKIFADefaults.ShowKnown,
		},
		{	-- Known color
			type = "colorpicker",
			name = DIKIFAStrings.knowncolor[DIKIFALang], --"Known color",
			--tooltip = "",
			getFunc = function() return DIKIFASettingValues.KnownColor.r, DIKIFASettingValues.KnownColor.g, DIKIFASettingValues.KnownColor.b end,
			setFunc = function(r, g, b) DIKIFASettingValues.KnownColor = {r=r, g=g, b=b}
									DIKIFA.rkn = r
									DIKIFA.gkn = g
									DIKIFA.bkn = b
									DIKIFA.SubmitSettings()
			end,
			default = DIKIFADefaults.KnownColor,
		},
		{	-- Show not Known Title line
			type = "checkbox",
			name = DIKIFAStrings.titledontknow[DIKIFALang], --"Show not known",
			--tooltip = "",
			getFunc = function() return DIKIFASettingValues.ShowTitleUnknown end,
			setFunc = function(value) DIKIFASettingValues.ShowTitleUnknown = value
									if value then DIKIFA.ShowTitleUnknown = 2 else DIKIFA.ShowTitleUnknown = 0 end
									DIKIFA.SubmitSettings()
			end,
			width = "full",
			default = DIKIFADefaults.ShowTitleUnknown,
		},
		{	-- Show Unknown
			type = "checkbox",
			name = DIKIFAStrings.showunknown[DIKIFALang], --"Show unknown",
			--tooltip = "",
			getFunc = function() return DIKIFASettingValues.ShowUnknown end,
			setFunc = function(value) DIKIFASettingValues.ShowUnknown = value
									if value then DIKIFA.ShowUnknown = 2 else DIKIFA.ShowUnknown = 0 end
									DIKIFA.SubmitSettings()
			end,
			width = "full",
			default = DIKIFADefaults.ShowUnknown,
		},
		{	-- Unknown color
			type = "colorpicker",
			name = DIKIFAStrings.knowncolor[DIKIFALang], --"Unknown color",
			--tooltip = "",
			getFunc = function() return DIKIFASettingValues.UnknownColor.r, DIKIFASettingValues.UnknownColor.g, DIKIFASettingValues.UnknownColor.b end,
			setFunc = function(r, g, b) DIKIFASettingValues.UnknownColor = {r=r, g=g, b=b}
									DIKIFA.rukn = r
									DIKIFA.gukn = g
									DIKIFA.bukn = b
									DIKIFA.SubmitSettings()
			end,
			default = DIKIFADefaults.UnknownColor,
		},
	}

	LAM2:RegisterOptionControls(ADDON_NAME, optionsTable)
end

--    INIT    --
----------------
local function GetLanguage()
	local lang = GetCVar("language.2")
	--supported languages
	if(lang == "fr") then return lang end
	if(lang == "de") then return lang end
	--return english if not supported
	return "en"
end

local function DIKIFASettings_OnActivate()
--d("--OnActivate:"..tostring(DIKIFAisActive))
	if DIKIFAisActive then 
	
	-- note for Khrill : -------------------------------------------------------------------------------------------------------	
		if not (DIKIFA.ShowTitleUnknown) then-- check if the minimum version is running : this variable didnt exist before 1.6.0
			d("You need v1.6.0+ DIKIFA core to run this version of the settings")
			return
		end 
	-----------------------------------------------------------------------------------------------------------/end check--------
		-- build default values from DIKIFA global var and load settings
		DIKIFADefaults = DIKIFAGetDefaultsSettings()
		DIKIFASettingValues = ZO_SavedVars:New("DIKIFASettingsVars", 1, nil, DIKIFADefaults)
		DIKIFASetSettings()
		DIKIFALang = GetLanguage()
		-- build Settings panel
		DIKIFASetSettingsPanel()
	end
	EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
	EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED)
end

local function DIKIFASettings_OnInit(eventCode, addonName)
	-- check DIKIFA addon is available?
	if (addonName == "DIKIFA") then DIKIFAisActive = true end

	if addonName ~= ADDON_NAME then return end
	
	if DIKIFA then 
		if DIKIFA.version and DIKIFA.version >= 200 then return end
	end
	
	
	
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, function(...) DIKIFASettings_OnActivate() end)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, function(_event, _name) DIKIFASettings_OnInit(_event, _name) end)