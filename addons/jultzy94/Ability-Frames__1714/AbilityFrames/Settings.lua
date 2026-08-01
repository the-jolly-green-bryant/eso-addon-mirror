-------------------------------------------------------------------------------------------------
--  MENU OPTIONS COMPONENT --
-------------------------------------------------------------------------------------------------

local ab = ab
ab.Settings = {}
LAM2 = LibStub("LibAddonMenu-2.0")

local iconTexturesList1 = {
	-- Standard Frames
	[1] = "ESO Standard Borders",
	[2] = "Clean Borders",
	[3] = "Black Borders",
	[4] = "White Borders",
	
	-- Classic Frames
	[5] = "Orange Borders",
	[6] = "Orange2 Borders",
	[7] = "Brown Borders",
	
	-- Class Frames
	[8] = "Dragonknight Borders",
	[9] = "Sorcerer Borders",
	[10] = "Templar Borders",
	[11] = "Nightblade Borders",
	[12] = "Warden Borders",
	
	-- Flag Frames
	[13] = "Swedish Borders",
	
	-- New Frames
	[14] = "Yellow Borders",
	[15] = "Ice Borders",
	
	-- Guild Frames
	[16] = "Fiskarna Borders",
	
	-- Special Frames
}

local iconTexturesList2 = {
	-- Standard Frames
	[1] = "ESO Standard Borders",
	[2] = "Clean Borders",
	[3] = "Black Borders",
	[4] = "White Borders",
	
	-- Classic Frames
	[5] = "Orange Borders",
	[6] = "Orange2 Borders",
	[7] = "Brown Borders",
	
	-- Class Frames
	[8] = "Dragonknight Borders",
	[9] = "Sorcerer Borders",
	[10] = "Templar Borders",
	[11] = "Nightblade Borders",
	[12] = "Warden Borders",
	
	-- Flag Frames
	[13] = "Swedish Borders",
	
	-- New Frames
	[14] = "Yellow Borders",
	[15] = "Ice Borders",
	
	-- Guild Frames
	[16] = "Fiskarna Borders",
	
	-- Special Frames
}

local iconTexturesList3 = {
	[1] = "Round Borders",
	[2] = "Square Borders",
}

-------------------------------------------------------------------------------------------------
--  Initialize Menu Component ------------------------------------------
------------------------------------------------------------------------
--  Called by OnAddOnLoaded(eventCode, addOnName) (AbilityFrames.lua) --
-------------------------------------------------------------------------------------------------
function ab.Settings:Initialize()
	
	-- Configure the master panel
	ab.Settings.panel = {
		type = "panel",
		name = ab.tag,
		displayName = "|cffff00A|r|c009ad6bility |c009ad6Frames|r",
		author = "|cffff00J|r|c009ad6ultzy|r",
	    version = ab.version,
		registerForRefresh = true,
		registerForDefaults = true,
		slashCommand = "/ab",	
	}
	
	ab.Settings.options = {
	{
		type = "header",
		name = "General Options",
		width = "full",
	},
	
	{
        type = "checkbox",
        name = "Use Round Active/Usable Ability Shape",
        tooltip = "Standard UI use square shapes for this.",
		default = false,
		warning = "You must reload the UI twice!",
        getFunc = function() return ab.SV.IconAForm end,
        setFunc = function(val) ab.SV.IconAForm = val end,
	},
	{
        type = "checkbox",
        name = "Use Square Passive Ability Shape",
        tooltip = "Standard UI use round shapes for this.",
		default = false,
		warning = "You must reload the UI twice!",
        getFunc = function() return ab.SV.IconPForm end,
        setFunc = function(val) ab.SV.IconPForm = val end,
	},
	{
		type = "header",
		name = "Interface Options",
	},
	{
        type = "dropdown",
        name = "Active/Usable Ability Style",
        tooltip = "Choose your borders for your active/usable abilities. Standard UI is Vanilla borders.",
		choices = iconTexturesList1,
		default = "Vanilla Borders",
		warning = "You must reload the UI twice!",
        getFunc = function() return ab.SV.IconA end,
        setFunc = function(val) ab.SV.IconA = val end,
	},
	{
        type = "dropdown",
        name = "Passive Ability Style",
        tooltip = "Choose your borders for your passive abilities. Standard UI is Vanilla borders.",
		choices = iconTexturesList2,
		default = "Vanilla Borders",
		warning = "You must reload the UI twice!",
        getFunc = function() return ab.SV.IconP end,
        setFunc = function(val) ab.SV.IconP = val end,
	},
	{
		type = "button",
		name = "Reload UI",
		tooltip = "REMEMBER TO RELOAD THE UI TWICE",
		width = "full",
		func = function() 
	      ReloadUI("ingame")
		end,
	},
	{
		type = "divider",
		alpha = 1,
		width = full,
	},
}
	
	-- Setup the initial panel
	LAM2:RegisterAddonPanel("AbilityFrames", ab.Settings.panel)
	
	-- Setup the menus
	LAM2:RegisterOptionControls("AbilityFrames", ab.Settings.options)
end