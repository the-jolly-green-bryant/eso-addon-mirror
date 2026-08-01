--[[
Author: Ayantir
Filename: en.lua
Version: Pontiac Trans Am
]]--

local strings = {

	PMP_INCLUDE					= "Include <<1>>",

	PMP_INCLUDE_NO3							= "Include \"No Peaceful pet\"",
	PMP_INCLUDE_NO4							= "Include \"No Costume\"",
	PMP_INCLUDE_NO9							= "Include \"No Personality\"",
	PMP_INCLUDE_NO10							= "Include \"No Hat\"",
	PMP_INCLUDE_NO11							= "Include \"No Skin\"",
	PMP_INCLUDE_NO12							= "Include \"No Polymorph\"",
	PMP_INCLUDE_NO13							= "Include \"No custom Hairstyle\"",
	PMP_INCLUDE_NO14							= "Include \"No Hair horns\"",
	PMP_INCLUDE_NO15							= "Include \"No Facial Accessory\"",
	PMP_INCLUDE_NO16							= "Include \"No Piercings\"",
	PMP_INCLUDE_NO17							= "Include \"No Head Marking\"",
	PMP_INCLUDE_NO18							= "Include \"No Body Marking\"",
	PMP_INCLUDE_NO99							= "Include \"No title\"",
					
	PMP_RANDOMIZE								= "Randomize at",
	PMP_RANDOMIZE_DESC						= "Select when to random",
						
	PMP_RANDOMIZE_CHOICE1					= "When changing zone",
	PMP_RANDOMIZE_CHOICE2					= "When game starts",
	PMP_RANDOMIZE_CHOICE3					= "Never",
	
	PMP_OUTFITTER_CATNAME					= "Outfits",
	PMR_NEW_OUTFIT								= "New outfit",
	
	SI_BINDING_NAME_PMP_RANDOM_CHAR		= "Pimp my Char!",
	SI_BINDING_NAME_PMP_RANDOM_RIDE		= "Pimp my Ride!",
	SI_BINDING_NAME_PMP_RANDOM_ALL		= "Customize!",
	
	PMR_NOCOLLECTIBLE							= "Nothing",
	PMR_OUTFIT_PLACEHOLDER					= "Please type an outfit Name",
	PMR_OUTFIT_LABEL							= "Name of Outfit",
	PMR_ASSOCIATE_KEYBIND					= "Create a keybind for this outfit",
	PMR_ADD_KEYBIND							= "Create a keybind",
	PMR_REM_KEYBIND							= "Remove the keybind",

}

for stringId, stringValue in pairs(strings) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end