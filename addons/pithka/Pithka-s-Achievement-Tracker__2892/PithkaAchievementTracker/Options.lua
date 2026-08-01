-- Initialize file
PITHKA         = PITHKA or {}
PITHKA.Options = {}


PITHKA.Options.panelData = {
    type = "panel",
    name = "Pithka Achievement Tracker",
    displayName = "Pithka's Achievement Tracker",
    author = "Pithka",
    registerForRefresh = true,	--boolean (optional) (will refresh all options controls when a setting is changed and when the panel is shown)
}


PITHKA.Options.optionsTable = {
    {
        type = "header",
        name = "Usage",
        width = "full",	--or "half" (optional)
    },
    {
        type = "description",
        --title = "My Title",	--(optional)
        text = "Open addon with /pat or keybinding.\n\n",
        width = "full",	--or "half" (optional)
    },
    
    {
        type = "header",
        name = "Hidden Features",
        width = "full",	--or "half" (optional)
    },
    {
        type = "description",
        --title = "My Title",	--(optional)
        text = "- Click on achievement icon to open in journal \n" ..
               "- Click on dungeon or trial name to teleport or queue \n"..
               "- Click arrow next to summary footer to enable guild specific ranks \n" .. 
               "- /pledges to list today's pledges\n\n",
        width = "full",	--or "half" (optional)
    },

    ----------------------------

    {
        type = "header",
        name = "Message Me",
        width = "full",	--or "half" (optional)
    },
    {
        type = "description",
        --title = "My Title",	--(optional)
        text = "To report bugs, feedback, or to have your guild included in the addon, message me on discord Pithka#9797\n\n",
        width = "full",	--or "half" (optional)
    },

    ----------------------

    {
        type = "header",
        name = "Sweatiest PVE-Er Competition",
        width = "full",	--or "half" (optional)
    },
    {
        type = "description",
        --title = "My Title",	--(optional)
        text = [[
Congratulations to @Olibeau for having the most OP addon screenshot (before the account-wide achievements patch, March 2022).   Not only did he have every single trifecta in the game, but also 34 trial trifectas including 6 Godslayers, 3 Dawnbringer, along with 4 Unchaineds and 18 Spirit Slayers. 

Some honorable mentions in the competition
- @Steenee with the most Godslayers (12x)
- @VEx43 with the most Unchained (16x)
- @Rhzolen with the most trials trifectas (40x)
- @mlee with the most dungeon trifectas (152x)

Thank you to our judges @SkinnyCheeks and @Nefas, and a special thanks to @Raf for sponsoring the competition prize pool.
]],
        width = "full",	--or "half" (optional)
    },

        {
			type = "checkbox",
            name = "Enable teleport",
            tooltip = "Allows you to teleport directly to dungeons and trials with the following command in your chat window /tp xx.  XX is the abbreviation of the dungeon or trial.",
			getFunc = function() return PITHKA.SV.options.enableTeleport end,
			setFunc = function(value)
				 PITHKA.SV.options.enableTeleport = value
			end,
            warning = "Will need to reload the UI.",
		},
}