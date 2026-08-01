--[[
  This file is part of Awesome Events.

  Author: Thyreos
  Filename: strings.lua
  Last Modified: June 19, 2018

  License : CreativeCommons CC BY-NC-SA 4.0 Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

  Please read the README file for further information.
  ]]

local strings = {
  -- bank space
	SI_AWEMOD_PACKRAT="Pack Rat",
	SI_AWEMOD_PACKRAT_HINT="Get additional notifications about your inventory.",	

  -- bank space
  SI_AWEMOD_PACKRAT_LOW="Show Bank Space Warnings",
  SI_AWEMOD_PACKRAT_LOW_HINT="Get a notification before you run out of bank space.",
  SI_AWEMOD_PACKRAT_LOW_INFO="Bank space low (|cFFFF60info|r)",
  SI_AWEMOD_PACKRAT_LOW_INFO_HINT="If remaining bank space is this much or less, you will see a notification",
  SI_AWEMOD_PACKRAT_LOW_WARNING="Bank space low (|cFF6060warning|r)",
  SI_AWEMOD_PACKRAT_LOW_WARNING_HINT="If remaining bank space is this much or less, you will see a warning.",
  SI_AWEMOD_PACKRAT_LOW_LABEL="Bank Space|r: <<1>>",
  
  -- junk
  SI_AWEMOD_PACKRAT_JUNK = "Show Junk",
  SI_AWEMOD_PACKRAT_JUNK_HINT = "See if you have junk in your backpack and how much space it's taking.",
  SI_AWEMOD_PACKRAT_JUNK_LABEL = "Stacks of Junk|r: <<1>>",

  -- stolen
  SI_AWEMOD_PACKRAT_STOLEN = "Show Stolen",
  SI_AWEMOD_PACKRAT_STOLEN_HINT = "See if you are carrying stolen items and how many.",
  SI_AWEMOD_PACKRAT_STOLEN_LABEL = "<<1>>Stolen Items|r: <<2>> <<1>>|| Stacks|r: <<3>>",

  -- fish
  SI_AWEMOD_PACKRAT_FISH = "Show Fish",
  SI_AWEMOD_PACKRAT_FISH_HINT = "See if you have fish to fillet in your backpack and how many.",
  SI_AWEMOD_PACKRAT_FISH_LABEL = "<<1>>Fish|r: <<2>> <<1>>|| Stacks|r: <<3>>",

  -- containers
  SI_AWEMOD_PACKRAT_CONTAINERS = "Show Containers",
  SI_AWEMOD_PACKRAT_CONTAINERS_HINT = "See if you have unopened containers in your backpack and how many.",
  SI_AWEMOD_PACKRAT_CONTAINERS_LABEL = "Containers|r: <<1>>",

  -- intricates
  SI_AWEMOD_PACKRAT_INTRICATES = "Show Intricates",
  SI_AWEMOD_PACKRAT_INTRICATES_HINT = "See if you have intricate items in your backpack and how many.",
  SI_AWEMOD_PACKRAT_INTRICATES_LABEL = "|c81D4FAIntricate|r: <<1>><<2>><<3>><<4>><<5>>",

  -- glyphs
  SI_AWEMOD_PACKRAT_GLYPHS = "Show Glyphs",
  SI_AWEMOD_PACKRAT_GLYPHS_HINT = "See if you have glyphs in your backpack and how much space they are taking.",
  SI_AWEMOD_PACKRAT_GLYPHS_LABEL = "Stacks of Glyphs|r: <<1>>",

  -- maps
  SI_AWEMOD_PACKRAT_MAPS = "Show Maps",
  SI_AWEMOD_PACKRAT_MAPS_HINT = "See if you have maps or surveys in your backpack and how many. If we find any, we'll suggest one.",
  SI_AWEMOD_PACKRAT_MAPS_LABEL = "Maps|r(<<1>>): <<2>>",

  -- recipes
  SI_AWEMOD_PACKRAT_RECIPES = "Show Recipes",
  SI_AWEMOD_PACKRAT_RECIPES_HINT = "See if you have recipes in your backpack and how many.",
  --SI_AWEMOD_PACKRAT_RECIPES_LABEL = "Recipes|r: <<1>>",
  SI_AWEMOD_PACKRAT_RECIPES_LABEL = "<<1>>Recipes|r: <<2>> <<1>>|| Unknown|r: <<3>>",

  -- furnishing
  SI_AWEMOD_PACKRAT_FURNISHINGS = "Show Home Furnishings",
  SI_AWEMOD_PACKRAT_FURNISHINGS_HINT = "See if you have home furnishings in your backpack and how many slots they are taking up.",
  SI_AWEMOD_PACKRAT_FURNISHINGS_LABEL = "Home Furnishings|r: <<1>>",  

  -- FCO ItemSaver Related 
  SI_AWEMOD_PACKRAT_FCO_MISSING = "FCO ItemSaver addon missing",

  -- FCO marked for decon
  SI_AWEMOD_PACKRAT_FCO_DECON = "Show FCOIS Marked for Deconstruction",
  SI_AWEMOD_PACKRAT_HINT_FCO_DECON = "[Requires FCO ItemSaver] See if you have items in your backpack that are marked for deconstruction.",
  SI_AWEMOD_PACKRAT_LABEL_FCO_DECON = "Deconstruct|r: <<1>><<2>><<3>><<4>><<5>>",  

  -- FCO sell at guild store
  SI_AWEMOD_PACKRAT_FCO_GUILDSTORE = "Show FCOIS Sell at Guild Store",
  SI_AWEMOD_PACKRAT_HINT_FCO_GUILDSTORE = "[Requires FCO ItemSaver] See if you have items in your backpack that are marked to sell at a guild store and how many slots they are taking up.",
  SI_AWEMOD_PACKRAT_LABEL_FCO_GUILDSTORE = "Sell at Guild Store|r: <<1>>",  
}

for stringId, stringValue in pairs(strings) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end
