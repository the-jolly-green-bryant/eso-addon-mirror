ContentHelper = ContentHelper or {}
local ContentHelper = ContentHelper

ContentHelper.potential_sounds = {
    "CONSOLE_GAME_ENTER",
    "CC_RANDOMIZE",
    "CC_GAMEPAD_CHARACTER_CLICK",
    "STABLE_FEED_CARRY",
    "ABILITY_WEAPON_SWAP_FAIL",
    "DEFER_NOTIFICATION",
    "SCRIPTED_WORLD_EVENT_INVITED",
    "QUEST_STEP_FAILED",
    "INVENTORY_ITEM_APPLY_CHARGE",
    "INVENTORY_ITEM_APPLY_ENCHANT",
    "JUSTICE_PICKPOCKET_BONUS",
    "JUSTICE_PICKPOCKET_FAILED",
    "LFG_FIND_REPLACEMENT",
    "BATTLEGROUND_CAPTURE_FLAG_TAKEN_OWN_TEAM",
    "BATTLEGROUND_CAPTURE_FLAG_CAPTURED_BY_OTHER_TEAM",
    "BATTLEGROUND_CAPTURE_FLAG_CAPTURED_BY_OWN_TEAM",
    "BATTLEGROUND_MURDERBALL_TAKEN_OWN_TEAM",
    "SKILL_POINT_GAINED",
    "ENLIGHTENED_STATE_GAINED",
    "ENLIGHTENED_STATE_LOST",
    "ABILITY_COMPANION_ULTIMATE_READY",
    "SKILL_XP_DARK_ANCHOR_CLOSED",
    "GAMEPAD_STATS_SINGLE_PURCHASE",
    "BLACKSMITH_IMPROVE_TOOLTIP_GLOW_FAIL",
    "DAEDRIC_ARTIFACT_REVEALED",
    "DAEDRIC_ARTIFACT_DESPAWNED",
    "CODE_REDEMPTION_SUCCESS",
    "ARMORY_OPEN",
    "ARMORY_RESTORE_SUCCESS",
    "ARMORY_SAVE_SUCCESS",
    "TRIBUTE_SUMMARY_PLACEMENT_MATCH_SEGMENT_FILL_VICTORY",
    "TRIBUTE_SUMMARY_RANK_CHANGE",
    "TRIBUTE_AGENT_HEALED",
    "ENDLESS_DUNGEON_ATTEMPTS_REMAINING_DECREMENT",
    "ENDLESS_DUNGEON_BUFF_ACQUIRE_AVATAR_VISION",
    "ENDLESS_DUNGEON_BUFF_ACQUIRE_VERSE",
    "ENDLESS_DUNGEON_BUFF_ACQUIRE_VISION",
    "INSTANCE_SHUTDOWN",
}

ContentHelper.textures = {
    { "ContentHelper/ic/square_green.dds", "static", nil },
    { "ContentHelper/ic/square_blue.dds", "static", nil },
    { "ContentHelper/ic/square_pink.dds", "static", nil },
    { "ContentHelper/ic/square_orange.dds", "static", nil },
    { "ContentHelper/ic/square_red.dds", "static", nil },
    { "ContentHelper/ic/square_yellow.dds", "static", nil },
    { "ContentHelper/ic/square_orange_OT.dds", "static", nil },
    { "ContentHelper/ic/square_red_MT.dds", "static", nil },
    { "ContentHelper/ic/arrow.dds", "static", nil },
    { "ContentHelper/ic/green_arrow.dds", "static", nil },
    { "ContentHelper/ic/squaretwo_green.dds", "static", nil },
    { "ContentHelper/ic/squaretwo_blue.dds", "static", nil },
    { "ContentHelper/ic/squaretwo_pink.dds", "static", nil },
    { "ContentHelper/ic/squaretwo_orange.dds", "static", nil },
    { "ContentHelper/ic/squaretwo_red.dds", "static", nil },
    { "ContentHelper/ic/squaretwo_yellow.dds", "static", nil },
    { "ContentHelper/ic/circle.dds", "static", nil },
    { "ContentHelper/ic/circle_icon.dds", "static", nil },
    { "ContentHelper/ic/marker_lightblue.dds", "static", nil },
    { "ContentHelper/ic/pic/slaughterfish.dds", "static", nil },
    { "ContentHelper/ic/num/squaretwo_red_one.dds", "static", nil },
    { "ContentHelper/ic/num/squaretwo_red_two.dds", "static", nil },
    { "ContentHelper/ic/num/squaretwo_red_three.dds", "static", nil },
    { "ContentHelper/ic/num/squaretwo_red_four.dds", "static", nil },
    { "ContentHelper/ic/num/squaretwo_red_five.dds", "static", nil },
    { "ContentHelper/ic/num/squaretwo_red_six.dds", "static", nil },
    { "ContentHelper/ic/num/squaretwo_red_seven.dds", "static", nil },
    { "ContentHelper/ic/num/squaretwo_red_eight.dds", "static", nil },
    { "ContentHelper/ic/num/squaretwo_blue_one.dds", "static", nil },
    { "ContentHelper/ic/num/squaretwo_blue_two.dds", "static", nil },
    { "ContentHelper/ic/num/squaretwo_blue_three.dds", "static", nil },
    { "ContentHelper/ic/num/squaretwo_blue_four.dds", "static", nil },
    { "ContentHelper/ic/num/squaretwo_orange_one.dds", "static", nil },
    { "ContentHelper/ic/num/squaretwo_orange_two.dds", "static", nil },
    { "ContentHelper/ic/num/squaretwo_orange_three.dds", "static", nil },
    { "ContentHelper/ic/num/squaretwo_orange_four.dds", "static", nil },
    { "ContentHelper/ic/num/squaretwo_green_one.dds", "static", nil },
    { "ContentHelper/ic/num/squaretwo_green_two.dds", "static", nil },
    { "ContentHelper/ic/num/squaretwo_green_three.dds", "static", nil },
    { "ContentHelper/ic/num/squaretwo_green_four.dds", "static", nil },
    { "ContentHelper/ic/num/squaretwo_green_five.dds", "static", nil },
    { "ContentHelper/ic/num/squaretwo_green_six.dds", "static", nil },
    { "ContentHelper/ic/pic/snowflake.dds", "static", nil },
    { "ContentHelper/ic/pic/tornado.dds", "static", nil },
    { "ContentHelper/ic/pic/stop.dds", "static", nil },
    { "/esoui/art/targetmarkers/gamepad/target_blue_square.dds", "static", nil },
    { "/esoui/art/targetmarkers/gamepad/target_gold_star.dds", "static", nil },
    { "/esoui/art/targetmarkers/gamepad/target_green_circle.dds", "static", nil },
    { "/esoui/art/targetmarkers/gamepad/target_orange_triangle.dds", "static", nil },
    { "/esoui/art/targetmarkers/gamepad/target_pink_moons.dds", "static", nil },
    { "/esoui/art/targetmarkers/gamepad/target_purple_oblivion.dds", "static", nil },
    { "/esoui/art/targetmarkers/gamepad/target_red_weapons.dds", "static", nil },
    { "/esoui/art/targetmarkers/gamepad/target_white_skull.dds", "static", nil },
    { "ContentHelper/ic/letter/A.dds", "static", nil },
    { "ContentHelper/ic/letter/B.dds", "static", nil },
    { "ContentHelper/ic/letter/C.dds", "static", nil },
    { "ContentHelper/ic/letter/D.dds", "static", nil },
    { "ContentHelper/ic/letter/E.dds", "static", nil },
    { "ContentHelper/ic/letter/F.dds", "static", nil },
    { "ContentHelper/ic/letter/G.dds", "static", nil },
    { "ContentHelper/ic/letter/H.dds", "static", nil },
    { "ContentHelper/ic/letter/I.dds", "static", nil },
    { "ContentHelper/ic/letter/J.dds", "static", nil },
    { "ContentHelper/ic/letter/K.dds", "static", nil },
    { "ContentHelper/ic/letter/L.dds", "static", nil },
    { "ContentHelper/ic/letter/M.dds", "static", nil },
    { "ContentHelper/ic/letter/N.dds", "static", nil },
    { "ContentHelper/ic/letter/O.dds", "static", nil },
    { "ContentHelper/ic/letter/P.dds", "static", nil },
    { "ContentHelper/ic/letter/Q.dds", "static", nil },
    { "ContentHelper/ic/letter/R.dds", "static", nil },
    { "ContentHelper/ic/letter/S.dds", "static", nil },
    { "ContentHelper/ic/letter/T.dds", "static", nil },
    { "ContentHelper/ic/letter/U.dds", "static", nil },
    { "ContentHelper/ic/letter/V.dds", "static", nil },
    { "ContentHelper/ic/letter/W.dds", "static", nil },
    { "ContentHelper/ic/letter/X.dds", "static", nil },
    { "ContentHelper/ic/letter/Y.dds", "static", nil },
    { "ContentHelper/ic/letter/Z.dds", "static", nil },
    { "ContentHelper/ic/meme/3170-pepestop.dds", "static", nil },
    { "ContentHelper/ic/meme/monkaS.dds", "static", nil },
    { "ContentHelper/ic/meme/swamp.dds", "static", nil },
    { "ContentHelper/ic/meme/walter.dds", "static", nil },
    { "ContentHelper/ic/meme/ricardo.dds", "static", nil },
    { "ContentHelper/ic/meme/okcat.dds", "static", nil },
    { "ContentHelper/ic/meme/pepeno.dds", "static", nil },
    { "ContentHelper/ic/meme/pepeyes.dds", "static", nil },
    { "ContentHelper/ic/meme/sadcat.dds", "static", nil },
    { "ContentHelper/ic/meme/budko.dds", "static", nil },
    { "ContentHelper/ic/meme/ovecka.dds", "animated", {30, 6, 5} },
    { "ContentHelper/ic/meme/FF.dds", "static", nil },
    { "ContentHelper/ic/beacon/Beam13.dds", "static", nil },
    { "ContentHelper/ic/red_arrow.dds", "hover", nil },
}

function ContentHelper.AddonMenu()
	local menuOptions = {
		type				 = "panel",
		name				 = "Makos's ContentHelper",
		displayName	 = "|cFF00F7Makos's ContentHelper|r",
		author			 = ContentHelper.author,
		version			 = ContentHelper.version,
		slashCommand = "/msc",
		registerForRefresh	= true,
		registerForDefaults = true,
	}

	local dataTable = {
		{
			type = "header",
			name = "|cFFFACDSettings|r",
		},
		{
			type = "divider",
		},
		{
			type = "description",
			text = " Use: /mcd 10 to create countdown \n Use: /mrw yourtext to create raidwarning \n Use: /mplaceself to place marker on your position \n Use: /mplacetarget to place marker where you look \n \n You can also have a look in keybinds to bind these features to a button of your choice",
		},
		{
			type = "divider",
		},
		{
			type = "dropdown",
			name = "Marker SE",
			tooltip = "Choose sound effect for marker placement",
			choices = ContentHelper.potential_sounds,
			getFunc = function() return ContentHelper.savedVariables.soundEffect end,
			setFunc = function(var) ContentHelper.savedVariables.soundEffect = var end,
		},
		{
        type = "slider",
        name = "Marker SE volume",
        tooltip = "Change this to adjust volume of marker placement ping. Set to 0 to mute  (Default: 5)",
        min = 0,
        max = 20,
        getFunc = function() return ContentHelper.savedVariables.placeVolume end,
        setFunc = function(value) ContentHelper.savedVariables.placeVolume = value end,
		},
		{
        type = "slider",
        name = "Marker size",
        tooltip = "Change this to adjust marker size (Default: 170)",
        min = 30,
        max = 500,
        getFunc = function() return ContentHelper.savedVariables.iconSize end,
        setFunc = function(value) ContentHelper.savedVariables.iconSize = value end,
		},
		
		{
			type = "editbox",
                name = "RW 1 msg (max 15 char)",
                tooltip = "Enter here the Raid Warning 1 message",
                getFunc = function() return ContentHelper.savedVariables.RW1 or "" end,
                setFunc = function(text)
					ContentHelper.savedVariables.RW1 = text
				end,
                isMultiline = false,	--boolean
		},
		
		{
			type = "editbox",
                name = "RW 2 msg (max 15 char)",
                tooltip = "Enter here the Raid Warning 2 message",
                getFunc = function() return ContentHelper.savedVariables.RW2 or "" end,
                setFunc = function(text)
					ContentHelper.savedVariables.RW2 = text
				end,
                isMultiline = false,	--boolean
		},
		
		{
			type = "editbox",
                name = "RW 3 msg (max 15 char)",
                tooltip = "Enter here the Raid Warning 3 message",
                getFunc = function() return ContentHelper.savedVariables.RW3 or "" end,
                setFunc = function(text)
					ContentHelper.savedVariables.RW3 = text
				end,
                isMultiline = false,	--boolean
		},
		
		{
			type    = "checkbox",
			name    = "Enable chat notifications",
			tooltip = "You are going to see some notifications when you receive data from another player",
			default = true,
			getFunc = function() return ContentHelper.savedVariables.chatNot end,
			setFunc = function(value)
				ContentHelper.savedVariables.chatNot = value
			end,
		},


        {
            type = "divider",
        },


        {
            type    = "checkbox",
            name    = "Enable markers on aggroed enemies",
            tooltip = "when ON you are going to see markers above enemies which are engaging in combat",
            default = true,
            getFunc = function() return ContentHelper.savedVariables.isMarkerEnemy end,
            setFunc = function(value)
                ContentHelper.savedVariables.isMarkerEnemy = value
            end,
        },

        {
            type = "slider",
            name = "Enemy marker size",
            tooltip = "Change this to adjust marker size (Default: 100)",
            min = 30,
            max = 150,
            getFunc = function() return ContentHelper.savedVariables.enemyMarkerSize end,
            setFunc = function(value) ContentHelper.savedVariables.enemyMarkerSize = value end,
        },
	}

	local LAM = LibAddonMenu2
	LAM:RegisterAddonPanel(ContentHelper.name .. "Options2", menuOptions )
	LAM:RegisterOptionControls(ContentHelper.name .. "Options2", dataTable )
end
