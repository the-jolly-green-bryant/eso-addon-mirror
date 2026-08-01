Xynode = Xynode or {}
local Xynode = Xynode

panel = {}


function Xynode.CreateMenu(svdefaults)

	menu = LibAddonMenu2

	local default = svdefaults

	panel = {
		type = "panel",
		name = "Xynode Settings",
		displayName = "|cffff00Xynode's|r All About Mechanics",
		author = "Kukee2018",
		version = "1.71",
		registerForRefresh = true,
		registerForDefaults = true,
		slashCommand = "/xynodesettings",
		website = "https://www.xynodegaming.com/allaboutmechanics",
	}



			local sounds = {	"",
			"NEW_NOTIFICATION",
			"NEW_MAIL",
			"ACHIEVEMENT_AWARDED",

			"QUEST_ABANDONED",
			"QUEST_COMPLETED",



			"COLLECTIBLE_UNLOCKED",

			"JUSTICE_NOW_KOS",
			"JUSTICE_NO_LONGER_KOS",

			"JUSTICE_PICKPOCKET_BONUS",
			"JUSTICE_PICKPOCKET_FAILED",


			"TELVAR_GAINED",
			"TELVAR_LOST",
			}



			local choices = {"None",
			"Notification",
			"New Mail",

			"Achievement Awarded",

			"Quest Abandoned",
			"Quest Completed",


			"Collectible Unlocked",


			"Kill On Site",
			"No Longer Kill On Site",

			"Pickpocket Bonus",
			"Pickpocket Failed",



			"Telvar Gained",
			"Telvar Lost",
			}


	local options = {

		{
			type = "header",
			name = "Visuals"
		},
		{
			type = "checkbox",
			name = "Hide controls when no content",
			getFunc = function() return Xynode.savedVars.hideControls end,
			setFunc = function(value)
				Xynode.savedVars.hideControls = value
				Xynode.setUp()
			end,
			default = false,

		},
		{
			type = "slider",
			name = "Background Opacity",
			min = 0,
			max = 100,
			step = 1,
			getFunc = function() return Xynode.savedVars.bgAlpha end,
			setFunc = function(value)
				Xynode.savedVars.bgAlpha = value
			end,
			default = 75,
		},
		{
			type = "slider",
			name = "Foreground Opacity",
			min = 0,
			max = 100,
			step = 1,
			getFunc = function() return Xynode.savedVars.fgAlpha end,
			setFunc = function(value)
				Xynode.savedVars.fgAlpha = value
			end,
			default = 100,
		},
		{
			type = "header",
			name = "Sounds"
		},
		{
			type="dropdown",
			name="Guide Available Sound",
			choices = choices,

			getFunc = function()
				local sound = Xynode.savedVars.guidesound
				for i = 1, #sounds do
					if sounds[i] == sound then return choices[i] end
				end
				return choices[1]
			end,

			setFunc = function(value)
				for i = 1, #choices do
					if choices[i] == value then
						Xynode.savedVars.guidesound = sounds[i]
						PlaySound(SOUNDS[Xynode.savedVars.guidesound])
						return
					end
				end
			end,
			default = choices[1],

		},

				{
			type="dropdown",
			name="Boss Available Sound",
			choices = choices,

			getFunc = function()
				local sound = Xynode.savedVars.bosssound
				for i = 1, #sounds do
					if sounds[i] == sound then return choices[i] end
				end
				return choices[1]
			end,

			setFunc = function(value)
				for i = 1, #choices do
					if choices[i] == value then
						Xynode.savedVars.bosssound = sounds[i]
						PlaySound(SOUNDS[Xynode.savedVars.bosssound])
						return
					end
				end
			end,
			default = choices[1],

		},
		{
			type = "header",
			name = "Group Notifications"
		},
		{
			type = "checkbox",
			name = "Hide Group Death Hints",
			getFunc = function() return Xynode.savedVars.deathingroup end,
			setFunc = function(value)
				Xynode.savedVars.deathingroup = value
				Xynode.setUp()
			end,
			default = false,

		},



	}


	addOnPanelXy = menu:RegisterAddonPanel("Xynode", panel)
	menu:RegisterOptionControls("Xynode", options)
end

