BSCMaarselok = BSCMaarselok or {}
local BSCML = BSCMaarselok

local sounds = {
	"NEW_NOTIFICATION",
	"GROUP_REQUEST_DECLINED",
	"DEFER_NOTIFICATION",
	"DUEL_START",
	"NEW_MAIL",
	"MAIL_SENT",
	"ACHIEVEMENT_AWARDED",

	"QUEST_ACCEPTED",
	"QUEST_ABANDONED",
	"QUEST_COMPLETED",
	"QUEST_STEP_FAILED",
	"QUEST_FOCUSED",
	"OBJECTIVE_ACCEPTED",
	"OBJECTIVE_COMPLETED",
	"OBJECTIVE_DISCOVERED",

	"INVENTORY_ITEM_JUNKED",
	"INVENTORY_ITEM_UNJUNKED",

	"COLLECTIBLE_UNLOCKED",

	"JUSTICE_STATE_CHANGED",
	"JUSTICE_NOW_KOS",
	"JUSTICE_NO_LONGER_KOS",
	"JUSTICE_GOLD_REMOVED",
	"JUSTICE_ITEM_REMOVED",
	"JUSTICE_PICKPOCKET_BONUS",
	"JUSTICE_PICKPOCKET_FAILED",

	"GROUP_JOIN",
	"GROUP_LEAVE",
	"GROUP_DISBAND",

	"TELVAR_GAINED",
	"TELVAR_LOST",

	"RAID_TRIAL_COMPLETED",
	"RAID_TRIAL_FAILED",
}
local choices = {
	"New",
	"Group Request Declined",
	"Defer",
	"Duell Start",
	"New Mail",
	"Mail Sent",
	"Achievement Awarded",

	"Quest Accepted",
	"Quest Abandoned",
	"Quest Completed",
	"Quest Step Failed",
	"Quest Focused",
	"Objective Accepted",
	"Objective Completed",
	"Objective Discovered",

	"Inventory Item Junked",
	"Inventory Item Unjunked",

	"Collectible Unlocked",

	"Justice State Changed",
	"Justice Now KOS",
	"Justice No Longer KOS",
	"Justice Gold Removed",
	"Justice Item Removed",
	"Justice Pickpocket Bonus",
	"Justice Pickpocket Failed",

	"Group Join",
	"Group Leave",
	"Group Disband",

	"Telvar Gained",
	"Telvar Lost",

	"Raid Trial Completed",
	"Raid Trial Failed",
}


local optionsTable = {}


local function AddBaseSetting()
	--
	table.insert(optionsTable, {
        type = "header",
        name = "Base Setting",
		controls = control,
	})	
	
	-- 
	table.insert( optionsTable, { 
		type = "button", 
		name = "Show UI", 
		func = function() BSCML.Fragment:Show(); 
		end, 
	})
	
	--table.insert(optionsTable, {
	--	type = "slider",
	--	name = "Delay decrease (ms)",
	--	min = 0,
	--	max = 250,
	--	step = 1,
	--	default = 0,	
	--	getFunc = function() return BSCML.SV.UI_UPDATE_DELAY end,
	--	setFunc = function(value)
	--		BSCML.SV.UI_UPDATE_DELAY = value
	--	end,
	--})
	-- Update Interval
	table.insert(optionsTable, {
		type = "slider",
		name = "Update Interval (ms)",
		min = 50,
		max = 1000,
		step = 50,
		default = 100,	
		getFunc = function() return BSCML.SV.UI_UPDATE_INTERVAL end,
		setFunc = function(value)
			BSCML.SV.UI_UPDATE_INTERVAL = value
		end,
	})	
	-- Combat Settings
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Show Only In Combat",
		getFunc = function() return BSCML.SV.ONLYINCOMBAT end,
		setFunc = function(value) 
			BSCML.SV.ONLYINCOMBAT = value
			BSCML.HideUI(BSCML.SV.ONLYINCOMBAT)
		end,
	})	
	-- Set Check
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Show Only if Set Is equipt",
		getFunc = function() return BSCML.SV.ONLYIFSETACTIVE end,
		setFunc = function(value) 
			BSCML.SV.ONLYIFSETACTIVE = value
			BSCML.CheckMaarselok() 
		end,
	})
end 

local function AddSoundSetting()
	--
	table.insert(optionsTable, {
        type = "header",
        name = "Sound Setting",
		controls = control,
	})	
	-- Sound
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Play Sound on Countdown end",
		getFunc = function() return BSCML.SV.PLAYSOUND end,
		setFunc = function(value) 
			BSCML.SV.PLAYSOUND = value
		end,
	})	
	table.insert( optionsTable, { 
		type = "dropdown", 
		name = "Sounds", 
		choices = choices,
		getFunc = function()
			local sound = BSCML.SV.SOUND
			for i = 1, #sounds do
				if sounds[i] == sound then return choices[i] end
			end
			return choices[1]
		end,
		setFunc = function(value)
			for i = 2, #choices do
				if choices[i] == value then
					BSCML.SV.SOUND = sounds[i]
					PlaySound(SOUNDS[BSCML.SV.SOUND])
					return
				end
			end
		end,
		width = "full", 
		default = choices[4],
	})		
end

local function AddIconSetting()

	table.insert(optionsTable, {
        type = "header",
        name = "Icon Setting",
		controls = control,
	})
	-- Icon
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Icon On = Helmet",
		getFunc = function() return BSCML.SV.USEICON end,
		setFunc = function(value) 
			BSCML.SV.USEICON = value
			BSCML.SetIcon()
		end,
	})
	-- background Ahlpha
	table.insert(optionsTable, {
		type = "slider",
		name = "Background Alpha",
		min = 1,
		max = 100,
		step = 1,
		default = 20,	
		getFunc = function() return (BSCML.SV.UI_ALPHA * 100) end,
		setFunc = function(value)
			BSCML.SV.UI_ALPHA = (value / 100)			
			BSCML.SetAlpha()
		end,
	})		
	-- Icon Scaling
	table.insert(optionsTable, {
		type = "slider",
		name = "Icon Scaling",
		min = 25,
		max = 500,
		step = 5,
		default = 40,	
		getFunc = function() return BSCML.SV.DIMENSION end,
		setFunc = function(value)
			BSCML.SV.DIMENSION = value
			BSCML.SetIconDimension()				
		end,
	})
end

local function AddTextSetting()
	table.insert(optionsTable, {
        type = "header",
        name = "Text Setting",
		controls = control,
	})
	
	-- Text Scaling 
	table.insert(optionsTable, {
		type = "slider",
		name = "Text Size",
		min = 1,
		max = 100,
		step = 1,
		default = 20,	
		getFunc = function() return BSCML.SV.TEXTSCALING end,
		setFunc = function(value)
			BSCML.SV.TEXTSCALING = value
			BSCML.SetFont()
		end,
	})
	--
	table.insert( optionsTable, { 
		type = "colorpicker", 
		name = "Text Color", 
		getFunc = function() return BSCML.SV.textcolor_r, BSCML.SV.textcolor_g, BSCML.SV.textcolor_b, BSCML.SV.textcolor_a end, 
		setFunc = function(r, g, b, a) BSCML.SV.textcolor_r = r; BSCML.SV.textcolor_g = g; BSCML.SV.textcolor_b = b; BSCML.SV.textcolor_a = a; end, 
	});	
	--
	table.insert(optionsTable, {
		type = "slider",
		name = "Text Anchors TOP / BOTTOM",
		min = -250,
		max = 250,
		step = 1,
		default = 0,	
		getFunc = function() return BSCML.SV.text_anchro_top_bottom end,
		setFunc = function(value)
			BSCML.SV.text_anchro_top_bottom = value
			BSCML.SetTextAnchors()
		end,
	})
	--
	table.insert(optionsTable, {
		type = "slider",
		name = "Text Anchors LEFT / RIGHT",
		min = -250,
		max = 250,
		step = 1,
		default = 0,	
		getFunc = function() return BSCML.SV.text_anchro_left_right end,
		setFunc = function(value)
			BSCML.SV.text_anchro_left_right = value
			BSCML.SetTextAnchors()
		end,
	})
end

--
function BSCML.BuildMenu()
	-- the panel for the addons menu
	local panelData = {
		type = "panel",
		name = ""..BSCML.Name,
		displayName = ""..BSCML.NameSpaced,
		author = ""..BSCML.Author,
		version = ""..BSCML.Version,
		registerForRefresh = true,
	}

	-- Char settings
	AddBaseSetting()
	AddSoundSetting()
	AddTextSetting()	
	AddIconSetting()

		
    LibAddonMenu2:RegisterAddonPanel(BSCML.NameSpaced.."Options", panelData)
    LibAddonMenu2:RegisterOptionControls(BSCML.NameSpaced.."Options", optionsTable)
end
