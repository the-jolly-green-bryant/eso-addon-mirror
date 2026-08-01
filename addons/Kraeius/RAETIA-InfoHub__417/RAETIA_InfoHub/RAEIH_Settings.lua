local LAM2	= LibAddonMenu2
local LMP 	= LibMediaProvider

-- Getting Characters and Settings (Kith's Code in Srendarr, using with blessing of Garkin)

RAEIH.CharsOfAccount = {}
local copyCharSettingsFrom

local function CopyTable(baseChar, trgChar)
    if type(trgChar) ~= 'table' then trgChar = {} end
    if type(baseChar) == 'table' then
        for k, v in pairs(baseChar) do
            if type(v) == 'table' then
                CopyTable(v, trgChar[k])
            end
            trgChar[k] = v
        end
    end
end

local function CopySettingsFrom(baseChar)
    local baseData, trgData
    local trgChar = GetUnitName("player")

    for account, accountData in pairs(RAEIH_SavedVariables.Default) do
        for character, data in pairs(accountData) do   	
            if character == baseChar and data.version == 1.4 then
                baseData = data
            end
            if character == trgChar then
                trgData = data
            end
        end
    end

    if (not baseData or not trgData) then
        d("There is no character to copy settings!")
        return
    end
    CopyTable(baseData, trgData)
    if RAEIH_Chamberlain ~= nil then RAEIH.SavedVars.ChamberlainLedger = {} end    
    ReloadUI()
end

function RAEIH.GetChars()
	for account, accountData in pairs(RAEIH_SavedVariables.Default) do
		for player, data in pairs(accountData) do
			if player ~= GetUnitName("player") and data.version == 1.4 then
				table.insert(RAEIH.CharsOfAccount, player)
			end
		end
	end
	table.sort(RAEIH.CharsOfAccount)
end

-- Panel
local panelData =
{
	type = "panel",
	name = "RAETIA InfoHub",
	displayName = "|c3A5FCDRAETIA|r InfoHub",
	author = "@Kraeius (PC - EU), @|c66ccffP5YCH3|r (PC - NA)",
	version = RAEIH.Version,
	slashCommand = "/raeih",
	registerForRefresh = true,
	registerForDefaults = true,
	resetFunc = function() RAEIH.SetResetAdjs() end,
}


local optionsData =
{	
	-- Description
	{
		type = "description",
		title = "|c3A5FCDRAETIA|r InfoHub |c3A5FCD" .. RAEIH.Version .. "|r - Knowledge is Power!",
		width = "full"
	},

	-- Logo
	{
		type = "texture",
		image = "/esoui/art/login/credits_eso_bw_logotype.dds",
		imageWidth = 512,
		imageHeight = 128,
		width = "full"
	},

	-- Legatus Description
	{
		type = "description",
		title = "\n»   INFOHUB LEGATUS SETTINGS",
		text = "Legatus is primary InfoHub Bar. You can set order of the modules, change icon sizes, icon positions, font types, styles and sizes",
		width = "full"
	},

	-- New Development Test 1

	{
		type = "button",
		name = "Send Char. Info",
		func = function(value) RAEIH.SendCharacterInfo() end,
		width = "half",
		tooltip = "That's intended for Non-English client users only. It will open your mail panel with some character information like name, race, class etc. You'll see what you are about to send before sending it. This will help me to catch which strings have carets so I'll get rid of them on your clients. There is no risk to send them around"
	},

	-- Bug Report & Feedback

	{
		type = "button",
		name = "Bug Report / Feedback",
		func = function() RAEIH.BugReportFeedback() end,
		width = "half"
	},

	-- Enable Legatus
	{
		type = "checkbox",
		name = "Enable Legatus",
		getFunc = function() return RAEIH.SavedVars.EnableLegatus end,
		setFunc = function(value)
			RAEIH.SavedVars.EnableLegatus = value
			RAEIH.CreateLegatus()
			RAEIH.DisableLegatus()
			RAEIH.OrganizeLegatus()
		end,
		tooltip = "Disabling this will break it's bound with modules, so all of the modules will be free to move",
		width = "half",
		default = RAEIH.DefaultSavedVars.EnableLegatus
	},

	-- Adjust Compass Frame for Legatus
	{
		type = "checkbox",
		name = "Adjust Compass Position",
		getFunc = function() return RAEIH.SavedVars.LegatusCF end,
		setFunc = function(value)
			RAEIH.SavedVars.LegatusCF = value
			RAEIH.LegatusCFAdj(true)
		end,
		width = "half",
		tooltip = "Moves the Compass Frame below to open space for Legatus bar line.",
		warning = "Disabling this will reload UI",
		disabled = function() return not RAEIH.SavedVars.EnableLegatus end,
		default = RAEIH.DefaultSavedVars.LegatusCF
	},

	-- Legatus Alignment Settings
	{
		type = "dropdown",
		name = "Legatus Alignment",
		choices = {"Screen-Wide Left", "Screen-Wide Center", "Screen-Wide Right", "Bar-Wide Movable"},
		getFunc = function() return RAEIH.SavedVars.LegatusAlignment end,
		setFunc = function(value)
			RAEIH.SavedVars.LegatusAlignment = value
			RAEIH.OrganizeLegatus()
		end,
		width = "half",
		disabled = function() return not RAEIH.SavedVars.EnableLegatus end,
		default = RAEIH.DefaultSavedVars.LegatusAlignment
	},

	-- Legatus Padding
	{
		type = "slider",
		name = "Padding Between Modules",
		min = -20,
		max = 20,
		step = 1,
		getFunc = function() return RAEIH.SavedVars.LegatusPadding end,
		setFunc = function(value)
			RAEIH.SavedVars.LegatusPadding = value
			RAEIH.OrganizeLegatus()
		end,
		width = "half",
		default = RAEIH.DefaultSavedVars.LegatusPadding,
		disabled = function() return not RAEIH.SavedVars.EnableLegatus end
	},

	-- Background Type
	{
		type = "dropdown",
		name = "Background Type",
		choices = {"Solid Colour", "Texture"},
		getFunc = function() return RAEIH.SavedVars.LegatusBGType end,
		setFunc = function(value)
			RAEIH.SavedVars.LegatusBGType = value
			RAEIH.OrganizeLegatus()
		end,
		width = "full",
		disabled = function() return not RAEIH.SavedVars.EnableLegatus end,
		default = RAEIH.DefaultSavedVars.LegatusBGType
	},

	-- Background Texture
	{
		type = "dropdown",
		name = "Background Texture",
		choices = {"Aluminium", "Banto Bar", "Complete Dark", "Dark", "Dark Bottom", "Elder Scrolls Grad", "Glass", "Glaze", "Horizontal Grad", "Horizontal GradV2", "Inner Glow", "Inner Shadow", "Inner Shadow Glass", "Lite Step", "Melli", "Minimalist", "Normal", "Otravi", "Round", "SandPaper", "SandPaperV2", "Shadow", "Smooth", "WGlass"},
		getFunc = function() return RAEIH.SavedVars.LegatusBGTX end,
		setFunc = function(value)
			RAEIH.SavedVars.LegatusBGTX = value
			RAEIH.OrganizeLegatus()
		end,
		width = "half",
		disabled = function() return RAEIH.SavedVars.EnableLegatus == false end,
		default = RAEIH.DefaultSavedVars.LegatusBGTX
	},

	-- Legatus Background Colour
	{
		type = "colorpicker",
		name = "Background Colour & Alpha",
		getFunc = function() return RAEIH.HexToRGBforLGT(RAEIH.SavedVars.LegatusBRGB) end,
		setFunc = function(r, g, b, a)
			RAEIH.SavedVars.LegatusBRGB = RAEIH.RGBToHex(r, g, b)
			RAEIH.SavedVars.LegatusBA = a
			RAEIH.OrganizeLegatus()
		end,
		width = "half",
		tooltip = "Change the colour and alpha value of solid background or texture",
		disabled = function() return RAEIH.SavedVars.EnableLegatus == false end,
		default =
		{
			r = RAEIH.HexToR(RAEIH.DefaultSavedVars.LegatusBRGB),
			g = RAEIH.HexToG(RAEIH.DefaultSavedVars.LegatusBRGB),
			b = RAEIH.HexToB(RAEIH.DefaultSavedVars.LegatusBRGB),
			a = RAEIH.DefaultSavedVars.LegatusBA
		}
	},

	-- Legatus Horizontal Position
	{
		type = "editbox",
		name = "Horizontal Position",
		getFunc = function() return RAEIH.SavedVars.LegatusX end,
		setFunc = function(value)
			RAEIH.SavedVars.LegatusX = value
			if RAEIH_Legatus ~= nil then
				RAEIH_Legatus:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.LegatusX, RAEIH.SavedVars.LegatusY)
			end
			RAEIH.OrganizeLegatus()
		end,
		width = "half",
		default = RAEIH.DefaultSavedVars.LegatusX,
		disabled = function() return not RAEIH.SavedVars.EnableLegatus end
	},

	-- Legatus Vertical Position
	{
		type = "editbox",
		name = "Vertical Position",
		getFunc = function() return RAEIH.SavedVars.LegatusY end,
		setFunc = function(value)
			RAEIH.SavedVars.LegatusY = value
			if RAEIH_Legatus ~= nil then
				RAEIH_Legatus:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.LegatusX, RAEIH.SavedVars.LegatusY)
			end
			RAEIH.OrganizeLegatus()
		end,
		width = "half",
		default = RAEIH.DefaultSavedVars.LegatusY,
		disabled = function() return not RAEIH.SavedVars.EnableLegatus end,
	},

	{
		type = "description",
		title = "\n»   COPY SETTINGS",
		text = "You can copy InfoHub settings from a character to " .. GetUnitName("player") .. ". Select base character and click \"Copy\"",
		width = "full"
	},

	{
		type = "dropdown",
		name = "Characters",
		choices = RAEIH.CharsOfAccount,
		getFunc = function()
                    if (#RAEIH.CharsOfAccount >= 1) then
                        copyCharSettingsFrom = RAEIH.CharsOfAccount[1]
                        return RAEIH.CharsOfAccount[1]
                    end
                end,
        setFunc = function(value) copyCharSettingsFrom = value end,
		width = "full",
		default = RAEIH.CharsOfAccount[1]
	},

	{
		type = "button",
		name = "Copy",
		func = function() CopySettingsFrom(copyCharSettingsFrom) end,
		warning = "UI will be reloaded!",
		width = "full"
	},	

	-- Legatus Module Selection
	{
		type = "submenu",
		name = "Legatus Hub",

			controls = {

			{
				type = "description",
				text = "Make sure that you DON'T have same module on different slots and use \"Remove\" button if you fill your screen and need some space",
				width = "full"
			},

			{
				type = "button",
				name = "Use Predef. Modules",
				func = function() RAEIH.LGTPredModules() end,
				disabled = function() return not RAEIH.SavedVars.EnableLegatus end,
				tooltip = "FPS, Time, Coordinates, LVR, XVP, Gold, Banked Gold, Bag Slots, Bank Slots, Soul Gems, Weapon Charge, Durability, Repair Cost, Skill Points, Riding, Blacksmithing, Woodworking, Clothing, Friends",
				warning = "It's possible that space won't be enough for you if your UI scale value is high, so remove some of them",
				width = "half"
			},

			{
				type = "button",
				name = "Clear List",
				func = function() RAEIH.LGTClearModuleList() end,
				disabled = function() return not RAEIH.SavedVars.EnableLegatus end,
				tooltip = "Legatus will be completely empty",
				width = "half"
			},

			-- Legatus I
			{
				type = "dropdown",
				name = "Legatus I",
				choices = {"FPS", "Latency", "LUA Memory", "Time", "Zone", "Coordinates", "LVR", "XVP", "XVP per Hour", "Gold", "Gold per Hour", "Banked Gold", "Durability", "Repair Cost", "Bag Slots", "Bank Slots", "Thievery", "Bounty", "Riding", "Blacksmithing", "Woodworking", "Clothing", "Soul Gems", "Weapon Charge", "Attribute Points", "SkyShards", "Skill Points", "Champion XP", "Alliance Points", "AvA Rank", "Achievement Points", "Friends", "Player Info", "Combat State", "Vampirism", "Lycanthropy", "Crafting XP", "Notification"},
				getFunc = function() return RAEIH.SavedVars.L1CName end,
				setFunc = function(value)
					RAEIH.SavedVars.XL1CName = RAEIH.SavedVars.L1CName
					RAEIH.SavedVars.L1CName = value
					RAEIH.OrganizeLegatus()
				end,
				width = "half",
				disabled = function() return not RAEIH.SavedVars.EnableLegatus end,
				default = RAEIH.DefaultSavedVars.L1CName
			},

			-- Legatus I / Empty
			{
				type = "button",
				name = "Remove",
				func = function()
				RAEIH.SavedVars.XL1CName = RAEIH.SavedVars.L1CName
				RAEIH.SavedVars.L1CName = "Empty" end,
				width = "half"
			},

			-- Legatus II
			{
				type = "dropdown",
				name = "Legatus II",
				choices = {"FPS", "Latency", "LUA Memory", "Time", "Zone", "Coordinates", "LVR", "XVP", "XVP per Hour", "Gold", "Gold per Hour", "Banked Gold", "Durability", "Repair Cost", "Bag Slots", "Bank Slots", "Thievery", "Bounty", "Riding", "Blacksmithing", "Woodworking", "Clothing", "Soul Gems", "Weapon Charge", "Attribute Points", "SkyShards", "Skill Points", "Champion XP", "Alliance Points", "AvA Rank", "Achievement Points", "Friends", "Player Info", "Combat State", "Vampirism", "Lycanthropy", "Crafting XP", "Notification"},
				getFunc = function() return RAEIH.SavedVars.L2CName end,
				setFunc = function(value)
					RAEIH.SavedVars.XL2CName = RAEIH.SavedVars.L2CName
					RAEIH.SavedVars.L2CName = value
					RAEIH.OrganizeLegatus()
				end,
				width = "half",
				disabled = function() return RAEIH.SavedVars.L1CName == "Empty" end,
				default = RAEIH.DefaultSavedVars.L2CName
			},

			-- Legatus II / Empty
			{
				type = "button",
				name = "Remove",
				func = function()
					RAEIH.SavedVars.XL2CName = RAEIH.SavedVars.L2CName
					RAEIH.SavedVars.L2CName = "Empty"
				end,
				width = "half"
			},

			-- Legatus III
			{
				type = "dropdown",
				name = "Legatus III",
				choices = {"FPS", "Latency", "LUA Memory", "Time", "Zone", "Coordinates", "LVR", "XVP", "XVP per Hour", "Gold", "Gold per Hour", "Banked Gold", "Durability", "Repair Cost", "Bag Slots", "Bank Slots", "Thievery", "Bounty", "Riding", "Blacksmithing", "Woodworking", "Clothing", "Soul Gems", "Weapon Charge", "Attribute Points", "SkyShards", "Skill Points", "Champion XP", "Alliance Points", "AvA Rank", "Achievement Points", "Friends", "Player Info", "Combat State", "Vampirism", "Lycanthropy", "Crafting XP", "Notification"},
				getFunc = function() return RAEIH.SavedVars.L3CName end,
				setFunc = function(value)
					RAEIH.SavedVars.XL3CName = RAEIH.SavedVars.L3CName
					RAEIH.SavedVars.L3CName = value
					RAEIH.OrganizeLegatus()
				end,
				width = "half",
				disabled = function() return RAEIH.SavedVars.L2CName == "Empty" end,
				default = RAEIH.DefaultSavedVars.L3CName
			},

			-- Legatus III / Empty
			{
				type = "button",
				name = "Remove",
				func = function()
					RAEIH.SavedVars.XL3CName = RAEIH.SavedVars.L3CName
					RAEIH.SavedVars.L3CName = "Empty"
				end,
				width = "half"
			},

			-- Legatus IV
			{
				type = "dropdown",
				name = "Legatus IV",
				choices = {"FPS", "Latency", "LUA Memory", "Time", "Zone", "Coordinates", "LVR", "XVP", "XVP per Hour", "Gold", "Gold per Hour", "Banked Gold", "Durability", "Repair Cost", "Bag Slots", "Bank Slots", "Thievery", "Bounty", "Riding", "Blacksmithing", "Woodworking", "Clothing", "Soul Gems", "Weapon Charge", "Attribute Points", "SkyShards", "Skill Points", "Champion XP", "Alliance Points", "AvA Rank", "Achievement Points", "Friends", "Player Info", "Combat State", "Vampirism", "Lycanthropy", "Crafting XP", "Notification"},
				getFunc = function() return RAEIH.SavedVars.L4CName end,
				setFunc = function(value)
					RAEIH.SavedVars.XL4CName = RAEIH.SavedVars.L4CName
					RAEIH.SavedVars.L4CName = value
					RAEIH.OrganizeLegatus()
				end,
				width = "half",
				disabled = function() return RAEIH.SavedVars.L3CName == "Empty" end,
				default = RAEIH.DefaultSavedVars.L4CName
			},

			-- Legatus IV / Empty
			{
				type = "button",
				name = "Remove",
				func = function()
					RAEIH.SavedVars.XL4CName = RAEIH.SavedVars.L4CName
					RAEIH.SavedVars.L4CName = "Empty"
				end,
				width = "half"
			},

			-- Legatus V
			{
				type = "dropdown",
				name = "Legatus V",
				choices = {"FPS", "Latency", "LUA Memory", "Time", "Zone", "Coordinates", "LVR", "XVP", "XVP per Hour", "Gold", "Gold per Hour", "Banked Gold", "Durability", "Repair Cost", "Bag Slots", "Bank Slots", "Thievery", "Bounty", "Riding", "Blacksmithing", "Woodworking", "Clothing", "Soul Gems", "Weapon Charge", "Attribute Points", "SkyShards", "Skill Points", "Champion XP", "Alliance Points", "AvA Rank", "Achievement Points", "Friends", "Player Info", "Combat State", "Vampirism", "Lycanthropy", "Crafting XP", "Notification"},
				getFunc = function() return RAEIH.SavedVars.L5CName end,
				setFunc = function(value)
					RAEIH.SavedVars.XL5CName = RAEIH.SavedVars.L5CName
					RAEIH.SavedVars.L5CName = value
					RAEIH.OrganizeLegatus()
				end,
				width = "half",
				disabled = function() return RAEIH.SavedVars.L4CName == "Empty" end,
				default = RAEIH.DefaultSavedVars.L5CName
			},

			-- Legatus V / Empty
			{
				type = "button",
				name = "Remove",
				func = function()
					RAEIH.SavedVars.XL5CName = RAEIH.SavedVars.L5CName
					RAEIH.SavedVars.L5CName = "Empty"
				end,
				width = "half"
			},

			-- Legatus VI
			{
				type = "dropdown",
				name = "Legatus VI",
				choices = {"FPS", "Latency", "LUA Memory", "Time", "Zone", "Coordinates", "LVR", "XVP", "XVP per Hour", "Gold", "Gold per Hour", "Banked Gold", "Durability", "Repair Cost", "Bag Slots", "Bank Slots", "Thievery", "Bounty", "Riding", "Blacksmithing", "Woodworking", "Clothing", "Soul Gems", "Weapon Charge", "Attribute Points", "SkyShards", "Skill Points", "Champion XP", "Alliance Points", "AvA Rank", "Achievement Points", "Friends", "Player Info", "Combat State", "Vampirism", "Lycanthropy", "Crafting XP", "Notification"},
				getFunc = function() return RAEIH.SavedVars.L6CName end,
				setFunc = function(value)
					RAEIH.SavedVars.XL6CName = RAEIH.SavedVars.L6CName
					RAEIH.SavedVars.L6CName = value
					RAEIH.OrganizeLegatus()
				end,
				width = "half",
				disabled = function() return RAEIH.SavedVars.L5CName == "Empty" end,
				default = RAEIH.DefaultSavedVars.L6CName
			},

			-- Legatus VI / Empty
			{
				type = "button",
				name = "Remove",
				func = function()
					RAEIH.SavedVars.XL6CName = RAEIH.SavedVars.L6CName
					RAEIH.SavedVars.L6CName = "Empty"
				end,
				width = "half"
			},

			-- Legatus VII
			{
				type = "dropdown",
				name = "Legatus VII",
				choices = {"FPS", "Latency", "LUA Memory", "Time", "Zone", "Coordinates", "LVR", "XVP", "XVP per Hour", "Gold", "Gold per Hour", "Banked Gold", "Durability", "Repair Cost", "Bag Slots", "Bank Slots", "Thievery", "Bounty", "Riding", "Blacksmithing", "Woodworking", "Clothing", "Soul Gems", "Weapon Charge", "Attribute Points", "SkyShards", "Skill Points", "Champion XP", "Alliance Points", "AvA Rank", "Achievement Points", "Friends", "Player Info", "Combat State", "Vampirism", "Lycanthropy", "Crafting XP", "Notification"},
				getFunc = function() return RAEIH.SavedVars.L7CName end,
				setFunc = function(value)
					RAEIH.SavedVars.XL7CName = RAEIH.SavedVars.L7CName
					RAEIH.SavedVars.L7CName = value
					RAEIH.OrganizeLegatus()
				end,
				width = "half",
				disabled = function() return RAEIH.SavedVars.L6CName == "Empty" end,
				default = RAEIH.DefaultSavedVars.L7CName
			},

			-- Legatus VII / Empty
			{
				type = "button",
				name = "Remove",
				func = function()
					RAEIH.SavedVars.XL7CName = RAEIH.SavedVars.L7CName
					RAEIH.SavedVars.L7CName = "Empty"
				end,
				width = "half"
			},

			-- Legatus VIII
			{
				type = "dropdown",
				name = "Legatus VIII",
				choices = {"FPS", "Latency", "LUA Memory", "Time", "Zone", "Coordinates", "LVR", "XVP", "XVP per Hour", "Gold", "Gold per Hour", "Banked Gold", "Durability", "Repair Cost", "Bag Slots", "Bank Slots", "Thievery", "Bounty", "Riding", "Blacksmithing", "Woodworking", "Clothing", "Soul Gems", "Weapon Charge", "Attribute Points", "SkyShards", "Skill Points", "Champion XP", "Alliance Points", "AvA Rank", "Achievement Points", "Friends", "Player Info", "Combat State", "Vampirism", "Lycanthropy", "Crafting XP", "Notification"},
				getFunc = function() return RAEIH.SavedVars.L8CName end,
				setFunc = function(value)
					RAEIH.SavedVars.XL8CName = RAEIH.SavedVars.L8CName
					RAEIH.SavedVars.L8CName = value
					RAEIH.OrganizeLegatus()
				end,
				width = "half",
				disabled = function() return RAEIH.SavedVars.L7CName == "Empty" end,
				default = RAEIH.DefaultSavedVars.L8CName
			},

			-- Legatus VIII / Empty
			{
				type = "button",
				name = "Remove",
				func = function()
					RAEIH.SavedVars.XL8CName = RAEIH.SavedVars.L8CName
					RAEIH.SavedVars.L8CName = "Empty"
				end,
				width = "half"
			},

			-- Legatus IX
			{
				type = "dropdown",
				name = "Legatus IX",
				choices = {"FPS", "Latency", "LUA Memory", "Time", "Zone", "Coordinates", "LVR", "XVP", "XVP per Hour", "Gold", "Gold per Hour", "Banked Gold", "Durability", "Repair Cost", "Bag Slots", "Bank Slots", "Thievery", "Bounty", "Riding", "Blacksmithing", "Woodworking", "Clothing", "Soul Gems", "Weapon Charge", "Attribute Points", "SkyShards", "Skill Points", "Champion XP", "Alliance Points", "AvA Rank", "Achievement Points", "Friends", "Player Info", "Combat State", "Vampirism", "Lycanthropy", "Crafting XP", "Notification"},
				getFunc = function() return RAEIH.SavedVars.L9CName end,
				setFunc = function(value)
					RAEIH.SavedVars.XL9CName = RAEIH.SavedVars.L9CName
					RAEIH.SavedVars.L9CName = value
					RAEIH.OrganizeLegatus()
				end,
				width = "half",
				disabled = function() return RAEIH.SavedVars.L8CName == "Empty" end,
				default = RAEIH.DefaultSavedVars.L9CName
			},

			-- Legatus IX / Empty
			{
				type = "button",
				name = "Remove",
				func = function()
					RAEIH.SavedVars.XL9CName = RAEIH.SavedVars.L9CName
					RAEIH.SavedVars.L9CName = "Empty"
				end,
				width = "half"
			},

			-- Legatus X
			{
				type = "dropdown",
				name = "Legatus X",
				choices = {"FPS", "Latency", "LUA Memory", "Time", "Zone", "Coordinates", "LVR", "XVP", "XVP per Hour", "Gold", "Gold per Hour", "Banked Gold", "Durability", "Repair Cost", "Bag Slots", "Bank Slots", "Thievery", "Bounty", "Riding", "Blacksmithing", "Woodworking", "Clothing", "Soul Gems", "Weapon Charge", "Attribute Points", "SkyShards", "Skill Points", "Champion XP", "Alliance Points", "AvA Rank", "Achievement Points", "Friends", "Player Info", "Combat State", "Vampirism", "Lycanthropy", "Crafting XP", "Notification"},
				getFunc = function() return RAEIH.SavedVars.L10CName end,
				setFunc = function(value)
					RAEIH.SavedVars.XL10CName = RAEIH.SavedVars.L10CName
					RAEIH.SavedVars.L10CName = value
					RAEIH.OrganizeLegatus()
				end,
				width = "half",
				disabled = function() return RAEIH.SavedVars.L9CName == "Empty" end,
				default = RAEIH.DefaultSavedVars.L10CName
			},

			-- Legatus X / Empty
			{
				type = "button",
				name = "Remove",
				func = function()
					RAEIH.SavedVars.XL10CName = RAEIH.SavedVars.L10CName
					RAEIH.SavedVars.L10CName = "Empty"
				end,
				width = "half"
			},

			-- Legatus XI
			{
				type = "dropdown",
				name = "Legatus XI",
				choices = {"FPS", "Latency", "LUA Memory", "Time", "Zone", "Coordinates", "LVR", "XVP", "XVP per Hour", "Gold", "Gold per Hour", "Banked Gold", "Durability", "Repair Cost", "Bag Slots", "Bank Slots", "Thievery", "Bounty", "Riding", "Blacksmithing", "Woodworking", "Clothing", "Soul Gems", "Weapon Charge", "Attribute Points", "SkyShards", "Skill Points", "Champion XP", "Alliance Points", "AvA Rank", "Achievement Points", "Friends", "Player Info", "Combat State", "Vampirism", "Lycanthropy", "Crafting XP", "Notification"},
				getFunc = function() return RAEIH.SavedVars.L11CName end,
				setFunc = function(value)
					RAEIH.SavedVars.XL11CName = RAEIH.SavedVars.L11CName
					RAEIH.SavedVars.L11CName = value
					RAEIH.OrganizeLegatus()
				end,
				width = "half",
				disabled = function() return RAEIH.SavedVars.L10CName == "Empty" end,
				default = RAEIH.DefaultSavedVars.L11CName
			},

			-- Legatus XI / Empty
			{
				type = "button",
				name = "Remove",
				func = function()
					RAEIH.SavedVars.XL11CName = RAEIH.SavedVars.L11CName
					RAEIH.SavedVars.L11CName = "Empty"
				end,
				width = "half"
			},

			-- Legatus XII
			{
				type = "dropdown",
				name = "Legatus XII",
				choices = {"FPS", "Latency", "LUA Memory", "Time", "Zone", "Coordinates", "LVR", "XVP", "XVP per Hour", "Gold", "Gold per Hour", "Banked Gold", "Durability", "Repair Cost", "Bag Slots", "Bank Slots", "Thievery", "Bounty", "Riding", "Blacksmithing", "Woodworking", "Clothing", "Soul Gems", "Weapon Charge", "Attribute Points", "SkyShards", "Skill Points", "Champion XP", "Alliance Points", "AvA Rank", "Achievement Points", "Friends", "Player Info", "Combat State", "Vampirism", "Lycanthropy", "Crafting XP", "Notification"},
				getFunc = function() return RAEIH.SavedVars.L12CName end,
				setFunc = function(value)
					RAEIH.SavedVars.XL12CName = RAEIH.SavedVars.L12CName
					RAEIH.SavedVars.L12CName = value
					RAEIH.OrganizeLegatus()
				end,
				width = "half",
				disabled = function() return RAEIH.SavedVars.L11CName == "Empty" end,
				default = RAEIH.DefaultSavedVars.L12CName
			},

			-- Legatus XII / Empty
			{
				type = "button",
				name = "Remove",
				func = function()
					RAEIH.SavedVars.XL12CName = RAEIH.SavedVars.L12CName
					RAEIH.SavedVars.L12CName = "Empty"
				end,
				width = "half"
			},

			-- Legeatus XIII
			{
				type = "dropdown",
				name = "Legatus XIII",
				choices = {"FPS", "Latency", "LUA Memory", "Time", "Zone", "Coordinates", "LVR", "XVP", "XVP per Hour", "Gold", "Gold per Hour", "Banked Gold", "Durability", "Repair Cost", "Bag Slots", "Bank Slots", "Thievery", "Bounty", "Riding", "Blacksmithing", "Woodworking", "Clothing", "Soul Gems", "Weapon Charge", "Attribute Points", "SkyShards", "Skill Points", "Champion XP", "Alliance Points", "AvA Rank", "Achievement Points", "Friends", "Player Info", "Combat State", "Vampirism", "Lycanthropy", "Crafting XP", "Notification"},
				getFunc = function() return RAEIH.SavedVars.L13CName end,
				setFunc = function(value)
					RAEIH.SavedVars.XL13CName = RAEIH.SavedVars.L13CName
					RAEIH.SavedVars.L13CName = value
					RAEIH.OrganizeLegatus()
				end,
				width = "half",
				disabled = function() return RAEIH.SavedVars.L12CName == "Empty" end,
				default = RAEIH.DefaultSavedVars.L13CName
			},

			-- Legatus XIII / Empty
			{
				type = "button",
				name = "Remove",
				func = function()
					RAEIH.SavedVars.XL13CName = RAEIH.SavedVars.L13CName
					RAEIH.SavedVars.L13CName = "Empty"
				end,
				width = "half"
			},

			-- Legatus XIV
			{
				type = "dropdown",
				name = "Legatus XIV",
				choices = {"FPS", "Latency", "LUA Memory", "Time", "Zone", "Coordinates", "LVR", "XVP", "XVP per Hour", "Gold", "Gold per Hour", "Banked Gold", "Durability", "Repair Cost", "Bag Slots", "Bank Slots", "Thievery", "Bounty", "Riding", "Blacksmithing", "Woodworking", "Clothing", "Soul Gems", "Weapon Charge", "Attribute Points", "SkyShards", "Skill Points", "Champion XP", "Alliance Points", "AvA Rank", "Achievement Points", "Friends", "Player Info", "Combat State", "Vampirism", "Lycanthropy", "Crafting XP", "Notification"},
				getFunc = function() return RAEIH.SavedVars.L14CName end,
				setFunc = function(value)
					RAEIH.SavedVars.XL14CName = RAEIH.SavedVars.L14CName
					RAEIH.SavedVars.L14CName = value
					RAEIH.OrganizeLegatus()
				end,
				width = "half",
				disabled = function() return RAEIH.SavedVars.L13CName == "Empty" end,
				default = RAEIH.DefaultSavedVars.L14CName
			},

			-- Legatus XIV / Empty
			{
				type = "button",
				name = "Remove",
				func = function()
					RAEIH.SavedVars.XL14CName = RAEIH.SavedVars.L14CName
					RAEIH.SavedVars.L14CName = "Empty"
				end,
				width = "half"
			},

			-- Legatus XV
			{
				type = "dropdown",
				name = "Legatus XV",
				choices = {"FPS", "Latency", "LUA Memory", "Time", "Zone", "Coordinates", "LVR", "XVP", "XVP per Hour", "Gold", "Gold per Hour", "Banked Gold", "Durability", "Repair Cost", "Bag Slots", "Bank Slots", "Thievery", "Bounty", "Riding", "Blacksmithing", "Woodworking", "Clothing", "Soul Gems", "Weapon Charge", "Attribute Points", "SkyShards", "Skill Points", "Champion XP", "Alliance Points", "AvA Rank", "Achievement Points", "Friends", "Player Info", "Combat State", "Vampirism", "Lycanthropy", "Crafting XP", "Notification"},
				getFunc = function() return RAEIH.SavedVars.L15CName end,
				setFunc = function(value)
					RAEIH.SavedVars.XL15CName = RAEIH.SavedVars.L15CName
					RAEIH.SavedVars.L15CName = value
					RAEIH.OrganizeLegatus()
				end,
				width = "half",
				disabled = function() return RAEIH.SavedVars.L14CName == "Empty" end,
				default = RAEIH.DefaultSavedVars.L15CName
			},

			-- Legatus XV / Empty
			{
				type = "button",
				name = "Remove",
				func = function()
					RAEIH.SavedVars.XL15CName = RAEIH.SavedVars.L15CName
					RAEIH.SavedVars.L15CName = "Empty"
				end,
				width = "half"
			},

			-- Legatus XVI
			{
				type = "dropdown",
				name = "Legatus XVI",
				choices = {"FPS", "Latency", "LUA Memory", "Time", "Zone", "Coordinates", "LVR", "XVP", "XVP per Hour", "Gold", "Gold per Hour", "Banked Gold", "Durability", "Repair Cost", "Bag Slots", "Bank Slots", "Thievery", "Bounty", "Riding", "Blacksmithing", "Woodworking", "Clothing", "Soul Gems", "Weapon Charge", "Attribute Points", "SkyShards", "Skill Points", "Champion XP", "Alliance Points", "AvA Rank", "Achievement Points", "Friends", "Player Info", "Combat State", "Vampirism", "Lycanthropy", "Crafting XP", "Notification"},
				getFunc = function() return RAEIH.SavedVars.L16CName end,
				setFunc = function(value)
					RAEIH.SavedVars.XL16CName = RAEIH.SavedVars.L16CName
					RAEIH.SavedVars.L16CName = value
					RAEIH.OrganizeLegatus()
				end,
				width = "half",
				disabled = function() return RAEIH.SavedVars.L15CName == "Empty" end,
				default = RAEIH.DefaultSavedVars.L16CName
			},

			-- Legatus XVI / Empty
			{
				type = "button",
				name = "Remove",
				func = function()
					RAEIH.SavedVars.XL16CName = RAEIH.SavedVars.L16CName
					RAEIH.SavedVars.L16CName = "Empty"
				end,
				width = "half"
			},

			-- Legatus XVII
			{
				type = "dropdown",
				name = "Legatus XVII",
				choices = {"FPS", "Latency", "LUA Memory", "Time", "Zone", "Coordinates", "LVR", "XVP", "XVP per Hour", "Gold", "Gold per Hour", "Banked Gold", "Durability", "Repair Cost", "Bag Slots", "Bank Slots", "Thievery", "Bounty", "Riding", "Blacksmithing", "Woodworking", "Clothing", "Soul Gems", "Weapon Charge", "Attribute Points", "SkyShards", "Skill Points", "Champion XP", "Alliance Points", "AvA Rank", "Achievement Points", "Friends", "Player Info", "Combat State", "Vampirism", "Lycanthropy", "Crafting XP", "Notification"},
				getFunc = function() return RAEIH.SavedVars.L17CName end,
				setFunc = function(value)
					RAEIH.SavedVars.XL17CName = RAEIH.SavedVars.L17CName
					RAEIH.SavedVars.L17CName = value
					RAEIH.OrganizeLegatus()
				end,
				width = "half",
				disabled = function() return RAEIH.SavedVars.L16CName == "Empty" end,
				default = RAEIH.DefaultSavedVars.L17CName
			},

			-- Legatus XVII / Empty
			{
				type = "button",
				name = "Remove",
				func = function()
				RAEIH.SavedVars.XL17CName = RAEIH.SavedVars.L17CName
				RAEIH.SavedVars.L17CName = "Empty" end,
				width = "half"
			},

			-- Legatus XVIII
			{
				type = "dropdown",
				name = "Legatus XVIII",
				choices = {"FPS", "Latency", "LUA Memory", "Time", "Zone", "Coordinates", "LVR", "XVP", "XVP per Hour", "Gold", "Gold per Hour", "Banked Gold", "Durability", "Repair Cost", "Bag Slots", "Bank Slots", "Thievery", "Bounty", "Riding", "Blacksmithing", "Woodworking", "Clothing", "Soul Gems", "Weapon Charge", "Attribute Points", "SkyShards", "Skill Points", "Champion XP", "Alliance Points", "AvA Rank", "Achievement Points", "Friends", "Player Info", "Combat State", "Vampirism", "Lycanthropy", "Crafting XP", "Notification"},
				getFunc = function() return RAEIH.SavedVars.L18CName end,
				setFunc = function(value)
				RAEIH.SavedVars.XL18CName = RAEIH.SavedVars.L18CName
				RAEIH.SavedVars.L18CName = value
				RAEIH.OrganizeLegatus() end,
				width = "half",
				disabled = function() return RAEIH.SavedVars.L17CName == "Empty" end,
				default = RAEIH.DefaultSavedVars.L18CName
			},

			-- Legatus XVIII / Empty
			{
				type = "button",
				name = "Remove",
				func = function()
				RAEIH.SavedVars.XL18CName = RAEIH.SavedVars.L18CName
				RAEIH.SavedVars.L18CName = "Empty" end,
				width = "half"
			},

			-- Legatus XIX
			{
				type = "dropdown",
				name = "Legatus XIX",
				choices = {"FPS", "Latency", "LUA Memory", "Time", "Zone", "Coordinates", "LVR", "XVP", "XVP per Hour", "Gold", "Gold per Hour", "Banked Gold", "Durability", "Repair Cost", "Bag Slots", "Bank Slots", "Thievery", "Bounty", "Riding", "Blacksmithing", "Woodworking", "Clothing", "Soul Gems", "Weapon Charge", "Attribute Points", "SkyShards", "Skill Points", "Champion XP", "Alliance Points", "AvA Rank", "Achievement Points", "Friends", "Player Info", "Combat State", "Vampirism", "Lycanthropy", "Crafting XP", "Notification"},
				getFunc = function() return RAEIH.SavedVars.L19CName end,
				setFunc = function(value)
				RAEIH.SavedVars.XL19CName = RAEIH.SavedVars.L19CName
				RAEIH.SavedVars.L19CName = value
				RAEIH.OrganizeLegatus() end,
				width = "half",
				disabled = function() return RAEIH.SavedVars.L18CName == "Empty" end,
				default = RAEIH.DefaultSavedVars.L19CName
			},

			-- Legatus XIX / Empty
			{
				type = "button",
				name = "Remove",
				func = function()
				RAEIH.SavedVars.XL19CName = RAEIH.SavedVars.L19CName
				RAEIH.SavedVars.L19CName = "Empty" end,
				width = "half"
			},

			-- Legatus XX
			{
				type = "dropdown",
				name = "Legatus XX",
				choices = {"FPS", "Latency", "LUA Memory", "Time", "Zone", "Coordinates", "LVR", "XVP", "XVP per Hour", "Gold", "Gold per Hour", "Banked Gold", "Durability", "Repair Cost", "Bag Slots", "Bank Slots", "Thievery", "Bounty", "Riding", "Blacksmithing", "Woodworking", "Clothing", "Soul Gems", "Weapon Charge", "Attribute Points", "SkyShards", "Skill Points", "Champion XP", "Alliance Points", "AvA Rank", "Achievement Points", "Friends", "Player Info", "Combat State", "Vampirism", "Lycanthropy", "Crafting XP", "Notification"},
				getFunc = function() return RAEIH.SavedVars.L20CName end,
				setFunc = function(value)
				RAEIH.SavedVars.XL20CName = RAEIH.SavedVars.L20CName
				RAEIH.SavedVars.L20CName = value
				RAEIH.OrganizeLegatus() end,
				width = "half",
				disabled = function() return RAEIH.SavedVars.L19CName == "Empty" end,
				default = RAEIH.DefaultSavedVars.L20CName
			},

			-- Legatus XX / Empty
			{
				type = "button",
				name = "Remove",
				func = function()
				RAEIH.SavedVars.XL20CName = RAEIH.SavedVars.L20CName
				RAEIH.SavedVars.L20CName = "Empty" end,
				width = "half"
			}
		}
	},

	-- InfoHub Font Description
	{
		type = "description",
		title = "\n»   GENERAL FONT SETTINGS",
		text = "Change InfoHub font types, styles and sizes, including Legatus and free modules",
		width = "full"
	},

	-- InfoHub Font Type
	{
		type = "dropdown",
		name = "InfoHub Font Type",
		choices = LMP:List(LMP.MediaType.FONT),
		getFunc = function() return RAEIH.SavedVars.InfoHubFont end,
		setFunc = function(value)
		RAEIH.SavedVars.InfoHubFont = value
		RAEIH.SavedVars.FPSFont = value
		RAEIH.SavedVars.LatencyFont = value
		RAEIH.SavedVars.LUAMemoryFont = value
		RAEIH.SavedVars.TimeFont = value
		RAEIH.SavedVars.ZoneFont = value
		RAEIH.SavedVars.CoordinatesFont = value
		RAEIH.SavedVars.LVRFont = value
		RAEIH.SavedVars.XVPFont = value
		RAEIH.SavedVars.XVPperHourFont = value
		RAEIH.SavedVars.GoldFont = value
		RAEIH.SavedVars.GoldperHourFont = value
		RAEIH.SavedVars.BankedGoldFont = value
		RAEIH.SavedVars.DurabilityFont = value
		RAEIH.SavedVars.RepairCostFont = value
		RAEIH.SavedVars.BagSlotsFont = value
		RAEIH.SavedVars.BankSlotsFont = value
		RAEIH.SavedVars.ThieveryFont = value
		RAEIH.SavedVars.BountyFont = value
		RAEIH.SavedVars.RidingFont = value
		RAEIH.SavedVars.BlacksmithingFont = value
		RAEIH.SavedVars.WoodworkingFont = value
		RAEIH.SavedVars.ClothingFont = value
		RAEIH.SavedVars.SoulGemsFont = value
		RAEIH.SavedVars.WeaponChargeFont = value
		RAEIH.SavedVars.AttributePointsFont = value
		RAEIH.SavedVars.SkyShardsFont = value
		RAEIH.SavedVars.SkillPointsFont = value
		RAEIH.SavedVars.ChampionXPFont = value
		RAEIH.SavedVars.AlliancePointsFont = value
		RAEIH.SavedVars.AvARank = value
		RAEIH.SavedVars.AchievementPointsFont = value
		RAEIH.SavedVars.FriendsFont = value
		RAEIH.SavedVars.TimePlayedFont = value
		RAEIH.SavedVars.CombatStateFont = value
		RAEIH.SavedVars.VampirismFont = value
		RAEIH.SavedVars.LycanthropyFont = value
		RAEIH.SavedVars.CraftingXPFont = value
		RAEIH.SavedVars.SubtitlesFont = value
		RAEIH.SavedVars.ReticleFont = value
		RAEIH.SavedVars.NotificationFont = value		
		
		RAEIH.SetModules()
		RAEIH.FormatModules()
		RAEIH.OrganizeModules()
		RAEIH.OrganizeLegatus() end,
		width = "full",
		default = RAEIH.DefaultSavedVars.InfoHubFont,
		disabled = function() return not RAEIH.SavedVars.EnableLegatus end
	},

	-- InfoHub Font Style
	{
		type = "dropdown",
		name = "InfoHub Font Style",
		choices = {"Normal", "Outline", "Shadow", "Soft Shadow - Thick", "Soft Shadow - Thin", "Thick Outline"},
		getFunc = function() return RAEIH.SavedVars.InfoHubFontStyle end,
		setFunc = function(value)
		RAEIH.SavedVars.InfoHubFontStyle = value
		RAEIH.SavedVars.FPSFontStyle = value
		RAEIH.SavedVars.LatencyFontStyle = value
		RAEIH.SavedVars.LUAMemoryFontStyle = value
		RAEIH.SavedVars.TimeFontStyle = value
		RAEIH.SavedVars.ZoneFontStyle = value
		RAEIH.SavedVars.CoordinatesFontStyle = value
		RAEIH.SavedVars.LVRFontStyle = value
		RAEIH.SavedVars.XVPFontStyle = value
		RAEIH.SavedVars.XVPperHourFontStyle = value
		RAEIH.SavedVars.GoldFontStyle = value
		RAEIH.SavedVars.GoldperHourFontStyle = value
		RAEIH.SavedVars.BankedGoldFontStyle = value
		RAEIH.SavedVars.DurabilityFontStyle = value
		RAEIH.SavedVars.RepairCostFontStyle = value
		RAEIH.SavedVars.BagSlotsFontStyle = value
		RAEIH.SavedVars.BankSlotsFontStyle = value
		RAEIH.SavedVars.ThieveryFontStyle = value
		RAEIH.SavedVars.BountyFontStyle = value
		RAEIH.SavedVars.RidingFontStyle = value
		RAEIH.SavedVars.BlacksmithingFontStyle = value
		RAEIH.SavedVars.WoodworkingFontStyle = value
		RAEIH.SavedVars.ClothingFontStyle = value
		RAEIH.SavedVars.SoulGemsFontStyle = value
		RAEIH.SavedVars.WeaponChargeFontStyle = value
		RAEIH.SavedVars.AttributePointsFontStyle = value
		RAEIH.SavedVars.SkyShardsFontStyle = value
		RAEIH.SavedVars.SkillPointsFontStyle = value
		RAEIH.SavedVars.ChampionXPFontStyle = value
		RAEIH.SavedVars.AlliancePointsFontStyle = value
		RAEIH.SavedVars.AvARank = value
		RAEIH.SavedVars.AchievementPointsFontStyle = value
		RAEIH.SavedVars.FriendsFontStyle = value
		RAEIH.SavedVars.TimePlayedFontStyle = value
		RAEIH.SavedVars.CombatStateFontStyle = value
		RAEIH.SavedVars.VampirismFontStyle = value
		RAEIH.SavedVars.LycanthropyFontStyle = value
		RAEIH.SavedVars.CraftingXPFontStyle = value
		RAEIH.SavedVars.SubtitlesFontStyle = value
		RAEIH.SavedVars.ReticleFontStyle = value
		RAEIH.SavedVars.NotificationFontStyle = value		
		
		RAEIH.SetModules()
		RAEIH.FormatModules()
		RAEIH.OrganizeModules()
		RAEIH.OrganizeLegatus() end,
		width = "full",
		default = RAEIH.DefaultSavedVars.InfoHubFontStyle,
		disabled = function() return not RAEIH.SavedVars.EnableLegatus end
	},

	-- InfoHub Font Size
	{
		type = "slider",
		name = "InfoHub Font Size",
		min = 8,
		max = 72,
		step = 1,
		getFunc = function() return RAEIH.SavedVars.InfoHubFontSize end,
		setFunc = function(value)
		RAEIH.SavedVars.InfoHubFontSize = value
		RAEIH.SavedVars.FPSFontSize = value
		RAEIH.SavedVars.LatencyFontSize = value
		RAEIH.SavedVars.LUAMemoryFontSize = value
		RAEIH.SavedVars.TimeFontSize = value
		RAEIH.SavedVars.ZoneFontSize = value
		RAEIH.SavedVars.CoordinatesFontSize = value
		RAEIH.SavedVars.LVRFontSize = value
		RAEIH.SavedVars.XVPFontSize = value
		RAEIH.SavedVars.XVPperHourFontSize = value
		RAEIH.SavedVars.GoldFontSize = value
		RAEIH.SavedVars.GoldperHourFontSize = value
		RAEIH.SavedVars.BankedGoldFontSize = value
		RAEIH.SavedVars.DurabilityFontSize = value
		RAEIH.SavedVars.RepairCostFontSize = value
		RAEIH.SavedVars.BagSlotsFontSize = value
		RAEIH.SavedVars.BankSlotsFontSize = value
		RAEIH.SavedVars.ThieveryFontSize = value
		RAEIH.SavedVars.BountyFontSize = value
		RAEIH.SavedVars.RidingFontSize = value
		RAEIH.SavedVars.BlacksmithingFontSize = value
		RAEIH.SavedVars.WoodworkingFontSize = value
		RAEIH.SavedVars.ClothingFontSize = value
		RAEIH.SavedVars.SoulGemsFontSize = value
		RAEIH.SavedVars.WeaponChargeFontSize = value
		RAEIH.SavedVars.AttributePointsFontSize = value
		RAEIH.SavedVars.SkyShardsFontSize = value
		RAEIH.SavedVars.SkillPointsFontSize = value
		RAEIH.SavedVars.ChampionXPFontSize = value
		RAEIH.SavedVars.AlliancePointsFontSize = value
		RAEIH.SavedVars.AvARank = value
		RAEIH.SavedVars.AchievementPointsFontSize = value
		RAEIH.SavedVars.FriendsFontSize = value
		RAEIH.SavedVars.TimePlayedFontSize = value
		RAEIH.SavedVars.CombatStateFontSize = value
		RAEIH.SavedVars.VampirismFontSize = value
		RAEIH.SavedVars.LycanthropyFontSize = value
		RAEIH.SavedVars.CraftingXPFontSize = value
		RAEIH.SavedVars.SubtitlesFontSize = value
		RAEIH.SavedVars.ReticleFontSize= value
		RAEIH.SavedVars.NotificationFontSize = value		
		
		RAEIH.SetModules()
		RAEIH.FormatModules()
		RAEIH.OrganizeModules()
		RAEIH.OrganizeLegatus() end,
		width = "full",
		default = RAEIH.DefaultSavedVars.InfoHubFontSize,
		disabled = function() return not RAEIH.SavedVars.EnableLegatus end
	},

	-- Icon Settings Description
	{
		type = "description",
		title = "\n»   GENERAL ICON SETTINGS",
		text = "Change the icon sizes and positions of all modules",
		width = "full"
	},

	-- InfoHub Icon Size
	{
		type = "dropdown",
		name = "InfoHub Icon Size",
		choices = {"16", "24", "32", "40", "48", "56", "64"},
		getFunc = function() return RAEIH.SavedVars.InfoHubIconW end,
		setFunc = function(value)
		RAEIH.SavedVars.InfoHubIconW = value
		RAEIH.SavedVars.InfoHubIconH = value
		RAEIH.ChangeIHIconSize()
		RAEIH.OrganizeLegatus()
		RAEIH.LegatusCFAdj(fromSettings) end,
		width = "full",
		default = RAEIH.DefaultSavedVars.InfoHubIconW,
		disabled = function() return not RAEIH.SavedVars.EnableLegatus end
	},

	-- Icon Hor. Position
	{
		type = "slider",
		name = "Icons' Horizontal Position",
		min = -80,
		max = 80,
		step = 1,
		getFunc = function() return RAEIH.SavedVars.InfoHubIconX end,
		setFunc = function(value)
		RAEIH.SavedVars.InfoHubIconX = value
		RAEIH.ChangeIconPosIHX()
		RAEIH.OrganizeLegatus() end,
		width = "half",
		default = RAEIH.DefaultSavedVars.InfoHubIconX,
		warning = "Use with care if you have modules attached to Legatus",
		disabled = function() return not RAEIH.SavedVars.EnableLegatus end
	},

	-- Icon Ver. Position
	{
		type = "slider",
		name = "Icons' Vertical Position",
		min = -80,
		max = 80,
		step = 1,
		getFunc = function() return RAEIH.SavedVars.InfoHubIconY end,
		setFunc = function(value)
		RAEIH.SavedVars.InfoHubIconY = value
		RAEIH.ChangeIconPosIHY()
		RAEIH.OrganizeLegatus() end,
		width = "half",
		tooltip = "May be used for both Legatus and free modules",
		default = RAEIH.DefaultSavedVars.InfoHubIconY,
		disabled = function() return not RAEIH.SavedVars.EnableLegatus end
	},

	-- UI Positioning Description
	{
		type = "description",
		title = "\n»   UI SETTINGS",
		text = "Show grid on screen to satisfy your OCD while organizing module positions",
		width = "full"
	},

	-- Show Grid
	{
		type = "checkbox",
		name = "Show Grid",
		getFunc = function() return RAEIH.SavedVars.ShowGrid end,
		setFunc = function(value)
		RAEIH.SavedVars.ShowGrid = value
		RAEIH.CreateGrid(value) end,
		width = "half",
		warning = "A grid will be drawn to let you position modules more accurately",
		default = RAEIH.DefaultSavedVars.ShowGrid
	},

	-- Grid Size
	{
		type = "slider",
		name = "Grid Size",
		min = 30,
		max = 100,
		step = 1,
		getFunc = function() return RAEIH.SavedVars.GridSize end,
		setFunc = function(value)
		RAEIH.SavedVars.GridSize = value
		ReloadUI() end,
		width = "half",
		warning = "UI will be reloaded to update new grid tiles!",
		disabled = function() return not RAEIH.SavedVars.ShowGrid end
	},

	-- Auto-Hide Options Description
	{
		type = "description",
		title = "\n»   GENERAL AUTO-HIDE SETTINGS",
		text = "Auto-Hide Legatus and other free modules when these menus are open;",
		width = "full"
	},

	-- AH Game Panels
	{
		type = "checkbox",
		name = "Game Panels",
		getFunc = function() return RAEIH.SavedVars.InfoHubAHGamePanels end,
		setFunc = function(value)
		RAEIH.SavedVars.InfoHubAHGamePanels = value
		RAEIH.HideCheck() end,
		width = "full",
		tooltip = "Like Inventory, Character, Skills, Group and Guild panels",
		default = RAEIH.DefaultSavedVars.InfoHubAHGamePanels
	},

	-- AH Settings Menu
	{
		type = "checkbox",
		name = "Settings Menu",
		getFunc = function() return RAEIH.SavedVars.InfoHubAHSettingsMenu end,
		setFunc = function(value)
		RAEIH.SavedVars.InfoHubAHSettingsMenu = value
		RAEIH.HideCheck() end,
		width = "full",
		tooltip = "The panel that appear when you hit ESC",
		default = RAEIH.DefaultSavedVars.InfoHubAHSettingsMenu
	},

	-- AH Interact Window
	{
		type = "checkbox",
		name = "Interact Window",
		getFunc = function() return RAEIH.SavedVars.InfoHubAHInteract end,
		setFunc = function(value)
		RAEIH.SavedVars.InfoHubAHInteract = value
		RAEIH.HideCheck() end,
		width = "full",
		tooltip = "Like NPC dialog screen",
		default = RAEIH.DefaultSavedVars.InfoHubAHInteract
	},

	-- AH World Map
	{
		type = "checkbox",
		name = "World Map",
		getFunc = function() return RAEIH.SavedVars.InfoHubAHWorldMap end,
		setFunc = function(value)
		RAEIH.SavedVars.InfoHubAHWorldMap = value
		RAEIH.HideCheck() end,
		width = "full",
		default = RAEIH.DefaultSavedVars.InfoHubAHWorldMap
	},

	-- AH Quest Journal
	{
		type = "checkbox",
		name = "Quest Journals/Books",
		getFunc = function() return RAEIH.SavedVars.InfoHubAHJournal end,
		setFunc = function(value)
		RAEIH.SavedVars.InfoHubAHJournal = value
		RAEIH.HideCheck() end,
		tooltip = "Screen that you read books, letters, parchments etc",
		width = "full",
		default = RAEIH.DefaultSavedVars.InfoHubAHJournal
	},

	-- AH Crafting Screen
	{
		type = "checkbox",
		name = "Crafting Screen",
		getFunc = function() return RAEIH.SavedVars.InfoHubAHCrafting end,
		setFunc = function(value)
		RAEIH.SavedVars.InfoHubAHCrafting = value
		RAEIH.HideCheck() end,
		width = "full",
		tooltip = "Crafting Station screens",
		default = RAEIH.DefaultSavedVars.InfoHubAHCrafting
	},

	-- AH Mailbox
	-- NOTE: For this to work, Game Panels must be turned off
	{
		type = "checkbox",
		name = "Mailbox",
		getFunc = function() return RAEIH.SavedVars.InfoHubAHMailbox end,
		setFunc = function(value)
		RAEIH.SavedVars.InfoHubAHMailbox = value
		RAEIH.HideCheck() end,
		width = "full",
		tooltip = "Mailbox screens",
		default = RAEIH.DefaultSavedVars.InfoHubAHMailbox
	},

	-- InfoHub Extra Settings Description
	{
		type = "description",
		title = "\n»   EXTRA SETTINGS",
		text = "Change some InfoHub-Wide settings like Thousands Separator Format",
		width = "full"
	},

	-- TS Format
	{
		type = "dropdown",
		name = "Thousands Separator Format",
		choices = {"Point (.)", "Comma (,)"},
		getFunc = function() return RAEIH.SavedVars.TSFormat end,
		setFunc = function(value)
		RAEIH.SavedVars.TSFormat = value
		RAEIH.SetModules()
		RAEIH.FormatModules()
		RAEIH.OrganizeModules()
		RAEIH.OrganizeLegatus() end,
		width = "full",
		tooltip = "Will be set for all InfoHub modules",
		default = RAEIH.DefaultSavedVars.TSFormat
	},

	-- FPS
	{
		type = "submenu",
		name = "FPS",

			controls = {
			{
				type = "checkbox",
				name = "Enable FPS",
				getFunc = function() return RAEIH.SavedVars.ShowFPS end,
				setFunc = function(value)
				RAEIH.SavedVars.ShowFPS = value
				RAEIH_FPS:SetHidden(not RAEIH.SavedVars.ShowFPS)
				RAEIH.SetFPS()
				RAEIH.FormatFPS()
				RAEIH.OrganizeFPS() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.ShowFPS
			},

			{
				type = "dropdown",
				name = "Font Type",
				choices = LMP:List(LMP.MediaType.FONT),
				getFunc = function() return RAEIH.SavedVars.FPSFont end,
				setFunc = function(value)
				RAEIH.SavedVars.FPSFont = value
				RAEIH.SetFPS()
				RAEIH.FormatFPS()
				RAEIH.OrganizeFPS() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.FPSFont
			},

			{
				type = "dropdown",
				name = "Font Style",
				choices = {"Normal", "Outline", "Shadow", "Soft Shadow - Thick", "Soft Shadow - Thin", "Thick Outline"},
				getFunc = function() return RAEIH.SavedVars.FPSFontStyle end,
				setFunc = function(value)
				RAEIH.SavedVars.FPSFontStyle = value
				RAEIH.SetFPS()
				RAEIH.FormatFPS()
				RAEIH.OrganizeFPS() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.FPSFontStyle
			},

			{
				type = "slider",
				name = "Font Size",
				min = 8,
				max = 72,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.FPSFontSize end,
				setFunc = function(value)
				RAEIH.SavedVars.FPSFontSize = value
				RAEIH.SetFPS()
				RAEIH.FormatFPS()
				RAEIH.OrganizeFPS() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.FPSFontSize
			},

			{
				type = "dropdown",
				name = "Icon Size",
				choices = {"16", "24", "32", "40", "48", "56", "64"},
				getFunc = function() return RAEIH.SavedVars.FPSIconW end,
				setFunc = function(value)
				RAEIH.SavedVars.FPSIconW = value
				RAEIH.SavedVars.FPSIconH = value
				RAEIH_FPS_Icon:SetDimensions(RAEIH.SavedVars.FPSIconW, RAEIH.SavedVars.FPSIconH)
				RAEIH.SetFPS()
				RAEIH.FormatFPS()
				RAEIH.OrganizeFPS() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.FPSIconW
			},

			{
				type = "colorpicker",
				name = "Low FPS Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.FPSAlertColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.FPSAlertColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetFPS()
				RAEIH.FormatFPS()
				RAEIH.OrganizeFPS() end,
				width = "full",
				tooltip = "FPS is less than 30",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.FPSAlertColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.FPSAlertColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.FPSAlertColour)
				}
			},

			{
				type = "colorpicker",
				name = "Normal FPS Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.FPSWarningColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.FPSWarningColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetFPS()
				RAEIH.FormatFPS()
				RAEIH.OrganizeFPS() end,
				width = "full",
				tooltip = "FPS is between 30 and 40",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.FPSWarningColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.FPSWarningColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.FPSWarningColour)
				}
			},

			{
				type = "colorpicker",
				name = "High FPS Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.FPSNormalColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.FPSNormalColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetFPS()
				RAEIH.FormatFPS()
				RAEIH.OrganizeFPS() end,
				width = "full",
				tooltip = "FPS is more than 40",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.FPSNormalColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.FPSNormalColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.FPSNormalColour)
				}
			},

			{
				type = "slider",
				name = "Background Alpha",
				min = 0,
				max = 100,
				step = 10,
				getFunc = function() return RAEIH.SavedVars.FPSBA * 100 end,
				setFunc = function(value)
				RAEIH.SavedVars.FPSBA = value / 100
				RAEIH.SetFPS()
				RAEIH.FormatFPS()
				RAEIH.OrganizeFPS() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.FPSBA * 100,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Horizontal Position",
				getFunc = function() return RAEIH.SavedVars.FPSX end,
				setFunc = function(value)
				RAEIH.SavedVars.FPSX = value
				RAEIH_FPS:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.FPSX, RAEIH.SavedVars.FPSY)
				RAEIH.SetFPS()
				RAEIH.FormatFPS()
				RAEIH.OrganizeFPS() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.FPSX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Vertical Position",
				getFunc = function() return RAEIH.SavedVars.FPSY end,
				setFunc = function(value)
				RAEIH.SavedVars.FPSY = value
				RAEIH_FPS:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.FPSX, RAEIH.SavedVars.FPSY)
				RAEIH.SetFPS()
				RAEIH.FormatFPS()
				RAEIH.OrganizeFPS() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.FPSY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Horizantal Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.FPSIconX end,
				setFunc = function(value)
				RAEIH.SavedVars.FPSIconX = value
				RAEIH.SetFPS()
				RAEIH.FormatFPS()
				RAEIH.OrganizeFPS() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.FPSIconX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Vertical Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.FPSIconY end,
				setFunc = function(value)
				RAEIH.SavedVars.FPSIconY = value
				RAEIH.SetFPS()
				RAEIH.FormatFPS()
				RAEIH.OrganizeFPS() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.FPSIconY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			}
		}
	},
	
	-- LATENCY
	{
		type = "submenu",
		name = "Latency",

			controls = {
			{
				type = "checkbox",
				name = "Enable Latency",
				getFunc = function() return RAEIH.SavedVars.ShowLatency end,
				setFunc = function(value)
				RAEIH.SavedVars.ShowLatency = value
				RAEIH_Latency:SetHidden(not RAEIH.SavedVars.ShowLatency)
				RAEIH.SetLatency()
				RAEIH.FormatLatency()
				RAEIH.OrganizeLatency() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.ShowLatency
			},

			{
				type = "dropdown",
				name = "Font Type",
				choices = LMP:List(LMP.MediaType.FONT),
				getFunc = function() return RAEIH.SavedVars.LatencyFont end,
				setFunc = function(value)
				RAEIH.SavedVars.LatencyFont = value
				RAEIH.SetLatency()
				RAEIH.FormatLatency()
				RAEIH.OrganizeLatency() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.LatencyFont
			},

			{
				type = "dropdown",
				name = "Font Style",
				choices = {"Normal", "Outline", "Shadow", "Soft Shadow - Thick", "Soft Shadow - Thin", "Thick Outline"},
				getFunc = function() return RAEIH.SavedVars.LatencyFontStyle end,
				setFunc = function(value)
				RAEIH.SavedVars.LatencyFontStyle = value
				RAEIH.SetLatency()
				RAEIH.FormatLatency()
				RAEIH.OrganizeLatency() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.LatencyFontStyle
			},

			{
				type = "slider",
				name = "Font Size",
				min = 8,
				max = 72,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.LatencyFontSize end,
				setFunc = function(value)
				RAEIH.SavedVars.LatencyFontSize = value
				RAEIH.SetLatency()
				RAEIH.FormatLatency()
				RAEIH.OrganizeLatency() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.LatencyFontSize
			},

			{
				type = "dropdown",
				name = "Icon Size",
				choices = {"16", "24", "32", "40", "48", "56", "64"},
				getFunc = function() return RAEIH.SavedVars.LatencyIconW end,
				setFunc = function(value)
				RAEIH.SavedVars.LatencyIconW = value
				RAEIH.SavedVars.LatencyIconH = value
				RAEIH_Latency_Icon:SetDimensions(RAEIH.SavedVars.LatencyIconW, RAEIH.SavedVars.LatencyIconH)
				RAEIH.SetLatency()
				RAEIH.FormatLatency()
				RAEIH.OrganizeLatency() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.LatencyIconW
			},

			{
				type = "colorpicker",
				name = "High Latency Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.LatencyAlertColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.LatencyAlertColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetLatency()
				RAEIH.FormatLatency()
				RAEIH.OrganizeLatency() end,
				width = "full",
				tooltip = "Latency is more than 300ms",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.LatencyAlertColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.LatencyAlertColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.LatencyAlertColour)
				}
			},

			{
				type = "colorpicker",
				name = "Normal Latency Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.LatencyWarningColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.LatencyWarningColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetLatency()
				RAEIH.FormatLatency()
				RAEIH.OrganizeLatency() end,
				width = "full",
				tooltip = "Latency is between 300ms and 150ms",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.LatencyWarningColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.LatencyWarningColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.LatencyWarningColour)
				}
			},

			{
				type = "colorpicker",
				name = "Low Latency Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.LatencyNormalColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.LatencyNormalColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetLatency()
				RAEIH.FormatLatency()
				RAEIH.OrganizeLatency() end,
				width = "full",
				tooltip = "Latency is less than 150ms",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.LatencyNormalColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.LatencyNormalColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.LatencyNormalColour)
				}
			},

			{
				type = "slider",
				name = "Background Alpha",
				min = 0,
				max = 100,
				step = 10,
				getFunc = function() return RAEIH.SavedVars.LatencyBA * 100 end,
				setFunc = function(value)
				RAEIH.SavedVars.LatencyBA = value / 100
				RAEIH.SetLatency()
				RAEIH.FormatLatency()
				RAEIH.OrganizeLatency() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.LatencyBA * 100,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Horizontal Position",
				getFunc = function() return RAEIH.SavedVars.LatencyX end,
				setFunc = function(value)
				RAEIH.SavedVars.LatencyX = value
				RAEIH_Latency:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.LatencyX, RAEIH.SavedVars.LatencyY)
				RAEIH.SetLatency()
				RAEIH.FormatLatency()
				RAEIH.OrganizeLatency() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.LatencyX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Vertical Position",
				getFunc = function() return RAEIH.SavedVars.LatencyY end,
				setFunc = function(value)
				RAEIH.SavedVars.LatencyY = value
				RAEIH_Latency:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.LatencyX, RAEIH.SavedVars.LatencyY)
				RAEIH.SetLatency()
				RAEIH.FormatLatency()
				RAEIH.OrganizeLatency() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.LatencyY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Horizantal Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.LatencyIconX end,
				setFunc = function(value)
				RAEIH.SavedVars.LatencyIconX = value
				RAEIH.SetLatency()
				RAEIH.FormatLatency()
				RAEIH.OrganizeLatency() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.LatencyIconX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Vertical Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.LatencyIconY end,
				setFunc = function(value)
				RAEIH.SavedVars.LatencyIconY = value
				RAEIH.SetLatency()
				RAEIH.FormatLatency()
				RAEIH.OrganizeLatency() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.LatencyIconY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			}
		}
	},	

	-- LUA MEMORY
	{
		type = "submenu",
		name = "LUA Memory",

			controls = {
			{
				type = "checkbox",
				name = "Enable LUA Memory",
				getFunc = function() return RAEIH.SavedVars.ShowLUAMemory end,
				setFunc = function(value)
				RAEIH.SavedVars.ShowLUAMemory = value
				RAEIH_LUAMemory:SetHidden(not RAEIH.SavedVars.ShowLUAMemory)
				RAEIH.SetLUAMemory()
				RAEIH.FormatLUAMemory()
				RAEIH.OrganizeLUAMemory() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.ShowLUAMemory
			},

			{
				type = "slider",
				name = "Set LUA Memory Limit",
				min = 64,
				max = 2048,
				step = 64,
				getFunc = function() return tonumber(RAEIH.SavedVars.LUAMemoryLimit) end,
				setFunc = function(value)
				SetCVar("LuaMemoryLimitMB", tostring(value))
				RAEIH.SavedVars.LUAMemoryLimit = tostring(value)
				RAEIH.SetLUAMemory()
				RAEIH.FormatLUAMemory()
				RAEIH.OrganizeLUAMemory() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.LUAMemoryIconX,
				warning = "It uses your physical RAM so set it a little more than your in-use LUA Memory just to surpass in-game warning message"
			},

			{
				type = "dropdown",
				name = "Font Type",
				choices = LMP:List(LMP.MediaType.FONT),
				getFunc = function() return RAEIH.SavedVars.LUAMemoryFont end,
				setFunc = function(value)
				RAEIH.SavedVars.LUAMemoryFont = value
				RAEIH.SetLUAMemory()
				RAEIH.FormatLUAMemory()
				RAEIH.OrganizeLUAMemory() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.LUAMemoryFont
			},

			{
				type = "dropdown",
				name = "Font Style",
				choices = {"Normal", "Outline", "Shadow", "Soft Shadow - Thick", "Soft Shadow - Thin", "Thick Outline"},
				getFunc = function() return RAEIH.SavedVars.LUAMemoryFontStyle end,
				setFunc = function(value)
				RAEIH.SavedVars.LUAMemoryFontStyle = value
				RAEIH.SetLUAMemory()
				RAEIH.FormatLUAMemory()
				RAEIH.OrganizeLUAMemory() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.LUAMemoryFontStyle
			},

			{
				type = "slider",
				name = "Font Size",
				min = 8,
				max = 72,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.LUAMemoryFontSize end,
				setFunc = function(value)
				RAEIH.SavedVars.LUAMemoryFontSize = value
				RAEIH.SetLUAMemory()
				RAEIH.FormatLUAMemory()
				RAEIH.OrganizeLUAMemory() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.LUAMemoryFontSize
			},

			{
				type = "dropdown",
				name = "Icon Size",
				choices = {"16", "24", "32", "40", "48", "56", "64"},
				getFunc = function() return RAEIH.SavedVars.LUAMemoryIconW end,
				setFunc = function(value)
				RAEIH.SavedVars.LUAMemoryIconW = value
				RAEIH.SavedVars.LUAMemoryIconH = value
				RAEIH_LUAMemory_Icon:SetDimensions(RAEIH.SavedVars.LUAMemoryIconW, RAEIH.SavedVars.LUAMemoryIconH)
				RAEIH.SetLUAMemory()
				RAEIH.FormatLUAMemory()
				RAEIH.OrganizeLUAMemory() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.LUAMemoryIconW
			},

			{
				type = "colorpicker",
				name = "High Memory Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.LUAMemoryAlertColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.LUAMemoryAlertColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetLUAMemory()
				RAEIH.FormatLUAMemory()
				RAEIH.OrganizeLUAMemory() end,
				width = "full",
				tooltip = "Memory is more than limit",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.LUAMemoryAlertColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.LUAMemoryAlertColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.LUAMemoryAlertColour)
				}
			},

			{
				type = "colorpicker",
				name = "Normal Memory Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.LUAMemoryWarningColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.LUAMemoryWarningColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetLUAMemory()
				RAEIH.FormatLUAMemory()
				RAEIH.OrganizeLUAMemory() end,
				width = "full",
				tooltip = "Memory is more than half of limit",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.LUAMemoryWarningColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.LUAMemoryWarningColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.LUAMemoryWarningColour)
				}
			},

			{
				type = "colorpicker",
				name = "Low Memory Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.LUAMemoryNormalColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.LUAMemoryNormalColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetLUAMemory()
				RAEIH.FormatLUAMemory()
				RAEIH.OrganizeLUAMemory() end,
				width = "full",
				tooltip = "Memory is less than half of limit",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.LUAMemoryNormalColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.LUAMemoryNormalColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.LUAMemoryNormalColour)
				}
			},

			{
				type = "slider",
				name = "Background Alpha",
				min = 0,
				max = 100,
				step = 10,
				getFunc = function() return RAEIH.SavedVars.LUAMemoryBA * 100 end,
				setFunc = function(value)
				RAEIH.SavedVars.LUAMemoryBA = value / 100
				RAEIH.SetLUAMemory()
				RAEIH.FormatLUAMemory()
				RAEIH.OrganizeLUAMemory() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.LUAMemoryBA * 100,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Horizontal Position",
				getFunc = function() return RAEIH.SavedVars.LUAMemoryX end,
				setFunc = function(value)
				RAEIH.SavedVars.LUAMemoryX = value
				RAEIH_LUAMemory:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.LUAMemoryX, RAEIH.SavedVars.LUAMemoryY)
				RAEIH.SetLUAMemory()
				RAEIH.FormatLUAMemory()
				RAEIH.OrganizeLUAMemory() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.LUAMemoryX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Vertical Position",
				getFunc = function() return RAEIH.SavedVars.LUAMemoryY end,
				setFunc = function(value)
				RAEIH.SavedVars.LUAMemoryY = value
				RAEIH_LUAMemory:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.LUAMemoryX, RAEIH.SavedVars.LUAMemoryY)
				RAEIH.SetLUAMemory()
				RAEIH.FormatLUAMemory()
				RAEIH.OrganizeLUAMemory() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.LUAMemoryY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Horizantal Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.LUAMemoryIconX end,
				setFunc = function(value)
				RAEIH.SavedVars.LUAMemoryIconX = value
				RAEIH.SetLUAMemory()
				RAEIH.FormatLUAMemory()
				RAEIH.OrganizeLUAMemory() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.LUAMemoryIconX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Vertical Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.LUAMemoryIconY end,
				setFunc = function(value)
				RAEIH.SavedVars.LUAMemoryIconY = value
				RAEIH.SetLUAMemory()
				RAEIH.FormatLUAMemory()
				RAEIH.OrganizeLUAMemory() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.LUAMemoryIconY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			}
		}
	},	

	-- TIME
	{
		type = "submenu",
		name = "Time & Date",

			controls = {
			{
				type = "checkbox",
				name = "Enable Time & Date",
				getFunc = function() return RAEIH.SavedVars.ShowTime end,
				setFunc = function(value)
				RAEIH.SavedVars.ShowTime = value
				RAEIH_Time:SetHidden(not RAEIH.SavedVars.ShowTime)
				RAEIH.SetTime()
				RAEIH.FormatTime()
				RAEIH.OrganizeTime() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.ShowTime
			},

			{
				type = "dropdown",
				name = "Time & Date Format",
				choices = {"Time & Date", "Time", "Date"},
				getFunc = function() return RAEIH.SavedVars.TimeFormat end,
				setFunc = function(value)
					RAEIH.SavedVars.TimeFormat = value
					RAEIH.SetTime()
					RAEIH.FormatTime()
					RAEIH.OrganizeTime()
				end,
				width = "half",
				disabled = function() return not RAEIH.SavedVars.ShowTime end,
				default = RAEIH.DefaultSavedVars.TimeFormat
			},

			{
				type = "dropdown",
				name = "Date Format",
				choices = {"MM/DD/YY", "DD/MM/YY"},
				getFunc = function() return RAEIH.SavedVars.DateFormat end,
				setFunc = function(value)
					RAEIH.SavedVars.DateFormat = value
					RAEIH.SetTime()
					RAEIH.FormatTime()
					RAEIH.OrganizeTime()
				end,
				width = "half",
				disabled = function() return not RAEIH.SavedVars.ShowTime end,
				default = RAEIH.DefaultSavedVars.DateFormat
			},
			
			{
				type = "checkbox",
				name = "12 Hours Clock Format",
				getFunc = function() return RAEIH.SavedVars.Enable12HCF end,
				setFunc = function(value)
					RAEIH.SavedVars.Enable12HCF = value
					RAEIH.SetTime()
					RAEIH.FormatTime()
					RAEIH.OrganizeTime()
				end,
				width = "half",
				disabled = function() return not RAEIH.SavedVars.ShowTime end,
				default = RAEIH.DefaultSavedVars.Enable12HCF
			},

			{
				type = "dropdown",
				name = "Font Type",
				choices = LMP:List(LMP.MediaType.FONT),
				getFunc = function() return RAEIH.SavedVars.TimeFont end,
				setFunc = function(value)
					RAEIH.SavedVars.TimeFont = value
					RAEIH.SetTime()
					RAEIH.FormatTime()
					RAEIH.OrganizeTime()
				end,
				width = "half",
				default = RAEIH.DefaultSavedVars.TimeFont
			},

			{
				type = "dropdown",
				name = "Font Style",
				choices = {"Normal", "Outline", "Shadow", "Soft Shadow - Thick", "Soft Shadow - Thin", "Thick Outline"},
				getFunc = function() return RAEIH.SavedVars.TimeFontStyle end,
				setFunc = function(value)
					RAEIH.SavedVars.TimeFontStyle = value
					RAEIH.SetTime()
					RAEIH.FormatTime()
					RAEIH.OrganizeTime()
				end,
				width = "half",
				default = RAEIH.DefaultSavedVars.TimeFontStyle
			},

			{
				type = "slider",
				name = "Font Size",
				min = 8,
				max = 72,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.TimeFontSize end,
				setFunc = function(value)
				RAEIH.SavedVars.TimeFontSize = value
				RAEIH.SetTime()
				RAEIH.FormatTime()
				RAEIH.OrganizeTime() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.TimeFontSize
			},

			{
				type = "dropdown",
				name = "Icon Size",
				choices = {"16", "24", "32", "40", "48", "56", "64"},
				getFunc = function() return RAEIH.SavedVars.TimeIconW end,
				setFunc = function(value)
				RAEIH.SavedVars.TimeIconW = value
				RAEIH.SavedVars.TimeIconH = value
				RAEIH_Time_Icon:SetDimensions(RAEIH.SavedVars.TimeIconW, RAEIH.SavedVars.TimeIconH)
				RAEIH.SetTime()
				RAEIH.FormatTime()
				RAEIH.OrganizeTime() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.TimeIconW
			},

			{
				type = "colorpicker",
				name = "Time & Date Color",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.TimeDefaultColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.TimeDefaultColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetTime()
				RAEIH.FormatTime()
				RAEIH.OrganizeTime() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.TimeDefaultColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.TimeDefaultColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.TimeDefaultColour)
				}
			},

			{
				type = "slider",
				name = "Background Alpha",
				min = 0,
				max = 100,
				step = 10,
				getFunc = function() return RAEIH.SavedVars.TimeBA * 100 end,
				setFunc = function(value)
				RAEIH.SavedVars.TimeBA = value / 100
				RAEIH.SetTime()
				RAEIH.FormatTime()
				RAEIH.OrganizeTime() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.TimeBA * 100,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Horizontal Position",
				getFunc = function() return RAEIH.SavedVars.TimeX end,
				setFunc = function(value)
				RAEIH.SavedVars.TimeX = value
				RAEIH_Time:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.TimeX, RAEIH.SavedVars.TimeY)
				RAEIH.SetTime()
				RAEIH.FormatTime()
				RAEIH.OrganizeTime() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.TimeX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Vertical Position",
				getFunc = function() return RAEIH.SavedVars.TimeY end,
				setFunc = function(value)
				RAEIH.SavedVars.TimeY = value
				RAEIH_Time:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.TimeX, RAEIH.SavedVars.TimeY)
				RAEIH.SetTime()
				RAEIH.FormatTime()
				RAEIH.OrganizeTime() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.TimeY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Horizantal Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.TimeIconX end,
				setFunc = function(value)
				RAEIH.SavedVars.TimeIconX = value
				RAEIH.SetTime()
				RAEIH.FormatTime()
				RAEIH.OrganizeTime() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.TimeIconX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Vertical Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.TimeIconY end,
				setFunc = function(value)
				RAEIH.SavedVars.TimeIconY = value
				RAEIH.SetTime()
				RAEIH.FormatTime()
				RAEIH.OrganizeTime() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.TimeIconY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			}
		}
	},

	-- ZONE
	{
		type = "submenu",
		name = "Zone",

			controls = {

			{
				type = "checkbox",
				name = "Enable Zone",
				getFunc = function() return RAEIH.SavedVars.ShowZone end,
				setFunc = function(value)
				RAEIH.SavedVars.ShowZone = value
				RAEIH_Zone:SetHidden(not RAEIH.SavedVars.ShowZone)
				RAEIH.SetZone()
				RAEIH.FormatZone()
				RAEIH.OrganizeZone() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ShowZone
			},

			{
				type = "dropdown",
				name = "Zone Format",
				choices = {"Subzone (Zone)", "Subzone", "Zone"},
				getFunc = function() return RAEIH.SavedVars.ZoneFormat end,
				setFunc = function(value)
				RAEIH.SavedVars.ZoneFormat = value
				RAEIH.SetZone()
				RAEIH.FormatZone()
				RAEIH.OrganizeZone() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ZoneFormat
			},

			{
				type = "checkbox",
				name = "Enable Auto WM Zoom",
				getFunc = function() return RAEIH.SavedVars.AWMZ end,
				setFunc = function(value)
				RAEIH.SavedVars.AWMZ = value end,
				width = "half",
				tooltip = "World Map and Fast Travel Map will auto zoom out to the selected level",
				default = RAEIH.DefaultSavedVars.AWMZ
			},

			{
				type = "slider",
				name = "WM Zoom Level",
				min = 1,
				max = 9,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.WMZLvl end,
				setFunc = function(value)
				RAEIH.SavedVars.WMZLvl = value end,
				width = "half",
				tooltip = "9 = Max Zoom Out, 1 = Max Zoom In",
				default = RAEIH.DefaultSavedVars.WMZLvl
			},

			{
				type = "dropdown",
				name = "Font Type",
				choices = LMP:List(LMP.MediaType.FONT),
				getFunc = function() return RAEIH.SavedVars.ZoneFont end,
				setFunc = function(value)
				RAEIH.SavedVars.ZoneFont = value
				RAEIH.SetZone()
				RAEIH.FormatZone()
				RAEIH.OrganizeZone() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ZoneFont
			},

			{
				type = "dropdown",
				name = "Font Style",
				choices = {"Normal", "Outline", "Shadow", "Soft Shadow - Thick", "Soft Shadow - Thin", "Thick Outline"},
				getFunc = function() return RAEIH.SavedVars.ZoneFontStyle end,
				setFunc = function(value)
				RAEIH.SavedVars.ZoneFontStyle = value
				RAEIH.SetZone()
				RAEIH.FormatZone()
				RAEIH.OrganizeZone() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ZoneFontStyle
			},

			{
				type = "slider",
				name = "Font Size",
				min = 8,
				max = 72,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.ZoneFontSize end,
				setFunc = function(value)
				RAEIH.SavedVars.ZoneFontSize = value
				RAEIH.SetZone()
				RAEIH.FormatZone()
				RAEIH.OrganizeZone() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ZoneFontSize
			},

			{
				type = "dropdown",
				name = "Icon Size",
				choices = {"16", "24", "32", "40", "48", "56", "64"},
				getFunc = function() return RAEIH.SavedVars.ZoneIconW end,
				setFunc = function(value)
				RAEIH.SavedVars.ZoneIconW = value
				RAEIH.SavedVars.ZoneIconH = value
				RAEIH_Zone_Icon:SetDimensions(RAEIH.SavedVars.ZoneIconW, RAEIH.SavedVars.ZoneIconH)
				RAEIH.SetZone()
				RAEIH.FormatZone()
				RAEIH.OrganizeZone() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ZoneIconW
			},

			{
				type = "colorpicker",
				name = "Default Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.ZoneDefaultColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.ZoneDefaultColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetZone()
				RAEIH.FormatZone()
				RAEIH.OrganizeZone() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.ZoneDefaultColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.ZoneDefaultColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.ZoneDefaultColour)
				}
			},

			{
				type = "colorpicker",
				name = "Subzone Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.SubzoneColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.SubzoneColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetZone()
				RAEIH.FormatZone()
				RAEIH.OrganizeZone() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.SubzoneColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.SubzoneColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.SubzoneColour)
				}
			},

			{
				type = "colorpicker",
				name = "Zone Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.ZoneColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.ZoneColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetZone()
				RAEIH.FormatZone()
				RAEIH.OrganizeZone() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.ZoneColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.ZoneColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.ZoneColour)
				}
			},

			{
				type = "slider",
				name = "Background Alpha",
				min = 0,
				max = 100,
				step = 10,
				getFunc = function() return RAEIH.SavedVars.ZoneBA * 100 end,
				setFunc = function(value)
				RAEIH.SavedVars.ZoneBA = value / 100
				RAEIH.SetZone()
				RAEIH.FormatZone()
				RAEIH.OrganizeZone() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.ZoneBA * 100,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Horizontal Position",
				getFunc = function() return RAEIH.SavedVars.ZoneX end,
				setFunc = function(value)
				RAEIH.SavedVars.ZoneX = value
				RAEIH_Zone:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.ZoneX, RAEIH.SavedVars.ZoneY)
				RAEIH.SetZone()
				RAEIH.FormatZone()
				RAEIH.OrganizeZone() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ZoneX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Vertical Position",
				getFunc = function() return RAEIH.SavedVars.ZoneY end,
				setFunc = function(value)
				RAEIH.SavedVars.ZoneY = value
				RAEIH_Zone:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.ZoneX, RAEIH.SavedVars.ZoneY)
				RAEIH.SetZone()
				RAEIH.FormatZone()
				RAEIH.OrganizeZone() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ZoneY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Horizantal Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.ZoneIconX end,
				setFunc = function(value)
				RAEIH.SavedVars.ZoneIconX = value
				RAEIH.SetZone()
				RAEIH.FormatZone()
				RAEIH.OrganizeZone() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ZoneIconX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Vertical Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.ZoneIconY end,
				setFunc = function(value)
				RAEIH.SavedVars.ZoneIconY = value
				RAEIH.SetZone()
				RAEIH.FormatZone()
				RAEIH.OrganizeZone() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ZoneIconY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			}
		}
	},

	-- COORDINATES
	{
		type = "submenu",
		name = "Coordinates",

			controls = {

			{
				type = "checkbox",
				name = "Enable Coordinates",
				getFunc = function() return RAEIH.SavedVars.ShowCoordinates end,
				setFunc = function(value)
				RAEIH.SavedVars.ShowCoordinates = value
				RAEIH_Coordinates:SetHidden(not RAEIH.SavedVars.ShowCoordinates)
				RAEIH.SetCoordinates()
				RAEIH.FormatCoordinates()
				RAEIH.OrganizeCoordinates()	end,
				width = "full",
				default = RAEIH.DefaultSavedVars.ShowCoordinates
			},

			{
				type = "dropdown",
				name = "Font Type",
				choices = LMP:List(LMP.MediaType.FONT),
				getFunc = function() return RAEIH.SavedVars.CoordinatesFont end,
				setFunc = function(value)
				RAEIH.SavedVars.CoordinatesFont = value
				RAEIH.SetCoordinates()
				RAEIH.FormatCoordinates()
				RAEIH.OrganizeCoordinates() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.CoordinatesFont
			},

			{
				type = "dropdown",
				name = "Font Style",
				choices = {"Normal", "Outline", "Shadow", "Soft Shadow - Thick", "Soft Shadow - Thin", "Thick Outline"},
				getFunc = function() return RAEIH.SavedVars.CoordinatesFontStyle end,
				setFunc = function(value)
				RAEIH.SavedVars.CoordinatesFontStyle = value
				RAEIH.SetCoordinates()
				RAEIH.FormatCoordinates()
				RAEIH.OrganizeCoordinates() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.CoordinatesFontStyle
			},

			{
				type = "slider",
				name = "Font Size",
				min = 8,
				max = 72,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.CoordinatesFontSize end,
				setFunc = function(value)
				RAEIH.SavedVars.CoordinatesFontSize = value
				RAEIH.SetCoordinates()
				RAEIH.FormatCoordinates()
				RAEIH.OrganizeCoordinates() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.CoordinatesFontSize
			},

			{
				type = "dropdown",
				name = "Icon Size",
				choices = {"16", "24", "32", "40", "48", "56", "64"},
				getFunc = function() return RAEIH.SavedVars.CoordinatesIconW end,
				setFunc = function(value)
				RAEIH.SavedVars.CoordinatesIconW = value
				RAEIH.SavedVars.CoordinatesIconH = value
				RAEIH_Coordinates_Icon:SetDimensions(RAEIH.SavedVars.CoordinatesIconW, RAEIH.SavedVars.CoordinatesIconH)
				RAEIH.SetCoordinates()
				RAEIH.FormatCoordinates()
				RAEIH.OrganizeCoordinates() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.CoordinatesIconW
			},

			{
				type = "colorpicker",
				name = "Coordinates Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.CoordinatesDefaultColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.CoordinatesDefaultColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetCoordinates()
				RAEIH.FormatCoordinates()
				RAEIH.OrganizeCoordinates() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.CoordinatesDefaultColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.CoordinatesDefaultColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.CoordinatesDefaultColour)
				}
			},

			{
				type = "colorpicker",
				name = "X Value Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.CoordinatesXColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.CoordinatesXColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetCoordinates()
				RAEIH.FormatCoordinates()
				RAEIH.OrganizeCoordinates() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.CoordinatesXColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.CoordinatesXColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.CoordinatesXColour)
				}
			},

			{
				type = "colorpicker",
				name = "Y Value Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.CoordinatesYColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.CoordinatesYColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetCoordinates()
				RAEIH.FormatCoordinates()
				RAEIH.OrganizeCoordinates() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.CoordinatesYColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.CoordinatesYColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.CoordinatesYColour)
				}
			},

			{
				type = "slider",
				name = "Background Alpha",
				min = 0,
				max = 100,
				step = 10,
				getFunc = function() return RAEIH.SavedVars.CoordinatesBA * 100 end,
				setFunc = function(value)
				RAEIH.SavedVars.CoordinatesBA = value / 100
				RAEIH.SetCoordinates()
				RAEIH.FormatCoordinates()
				RAEIH.OrganizeCoordinates() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.CoordinatesBA * 100,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Horizontal Position",
				getFunc = function() return RAEIH.SavedVars.CoordinatesX end,
				setFunc = function(value)
				RAEIH.SavedVars.CoordinatesX = value
				RAEIH_Coordinates:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.CoordinatesX, RAEIH.SavedVars.CoordinatesY)
				RAEIH.SetCoordinates()
				RAEIH.FormatCoordinates()
				RAEIH.OrganizeCoordinates() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.CoordinatesX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Vertical Position",
				getFunc = function() return RAEIH.SavedVars.CoordinatesY end,
				setFunc = function(value)
				RAEIH.SavedVars.CoordinatesY = value
				RAEIH_Coordinates:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.CoordinatesX, RAEIH.SavedVars.CoordinatesY)
				RAEIH.SetCoordinates()
				RAEIH.FormatCoordinates()
				RAEIH.OrganizeCoordinates() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.CoordinatesY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Horizantal Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.CoordinatesIconX end,
				setFunc = function(value)
				RAEIH.SavedVars.CoordinatesIconX = value
				RAEIH.SetCoordinates()
				RAEIH.FormatCoordinates()
				RAEIH.OrganizeCoordinates() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.CoordinatesIconX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Vertical Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.CoordinatesIconY end,
				setFunc = function(value)
				RAEIH.SavedVars.CoordinatesIconY = value
				RAEIH.SetCoordinates()
				RAEIH.FormatCoordinates()
				RAEIH.OrganizeCoordinates() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.CoordinatesIconY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			}
		}
	},

	-- LVR
	{
		type = "submenu",
		name = "LVR (Level & Veteran Rank)",

			controls = {
			{
				type = "checkbox",
				name = "Enable LVR",
				getFunc = function() return RAEIH.SavedVars.ShowLVR end,
				setFunc = function(value)
				RAEIH.SavedVars.ShowLVR = value
				RAEIH_LVR:SetHidden(not RAEIH.SavedVars.ShowLVR)
				RAEIH.SetLVR()
				RAEIH.FormatLVR()
				RAEIH.OrganizeLVR()	end,
				width = "full",
				default = RAEIH.DefaultSavedVars.ShowLVR
			},

			{
				type = "dropdown",
				name = "Font Type",
				choices = LMP:List(LMP.MediaType.FONT),
				getFunc = function() return RAEIH.SavedVars.LVRFont end,
				setFunc = function(value)
				RAEIH.SavedVars.LVRFont = value
				RAEIH.SetLVR()
				RAEIH.FormatLVR()
				RAEIH.OrganizeLVR() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.LVRFont
			},

			{
				type = "dropdown",
				name = "Font Style",
				choices = {"Normal", "Outline", "Shadow", "Soft Shadow - Thick", "Soft Shadow - Thin", "Thick Outline"},
				getFunc = function() return RAEIH.SavedVars.LVRFontStyle end,
				setFunc = function(value)
				RAEIH.SavedVars.LVRFontStyle = value
				RAEIH.SetLVR()
				RAEIH.FormatLVR()
				RAEIH.OrganizeLVR() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.LVRFontStyle
			},

			{
				type = "slider",
				name = "Font Size",
				min = 8,
				max = 72,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.LVRFontSize end,
				setFunc = function(value)
				RAEIH.SavedVars.LVRFontSize = value
				RAEIH.SetLVR()
				RAEIH.FormatLVR()
				RAEIH.OrganizeLVR() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.LVRFontSize
			},

			{
				type = "dropdown",
				name = "Icon Size",
				choices = {"16", "24", "32", "40", "48", "56", "64"},
				getFunc = function() return RAEIH.SavedVars.LVRIconW end,
				setFunc = function(value)
				RAEIH.SavedVars.LVRIconW = value
				RAEIH.SavedVars.LVRIconH = value
				RAEIH_LVR_Icon:SetDimensions(RAEIH.SavedVars.LVRIconW, RAEIH.SavedVars.LVRIconH)
				RAEIH.SetLVR()
				RAEIH.FormatLVR()
				RAEIH.OrganizeLVR() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.LVRIconW
			},

			{
				type = "colorpicker",
				name = "LVR Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.LVRDefaultColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.LVRDefaultColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetLVR()
				RAEIH.FormatLVR()
				RAEIH.OrganizeLVR() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.LVRDefaultColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.LVRDefaultColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.LVRDefaultColour)
				}
			},

			{
				type = "colorpicker",
				name = "LVR Value Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.LVRColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.LVRColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetLVR()
				RAEIH.FormatLVR()
				RAEIH.OrganizeLVR() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.LVRColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.LVRColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.LVRColour)
				}
			},

			{
				type = "slider",
				name = "Background Alpha",
				min = 0,
				max = 100,
				step = 10,
				getFunc = function() return RAEIH.SavedVars.LVRBA * 100 end,
				setFunc = function(value)
				RAEIH.SavedVars.LVRBA = value / 100
				RAEIH.SetLVR()
				RAEIH.FormatLVR()
				RAEIH.OrganizeLVR() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.LVRBA * 100,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Horizontal Position",
				getFunc = function() return RAEIH.SavedVars.LVRX end,
				setFunc = function(value)
				RAEIH.SavedVars.LVRX = value
				RAEIH_LVR:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.LVRX, RAEIH.SavedVars.LVRY)
				RAEIH.SetLVR()
				RAEIH.FormatLVR()
				RAEIH.OrganizeLVR() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.LVRX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Vertical Position",
				getFunc = function() return RAEIH.SavedVars.LVRY end,
				setFunc = function(value)
				RAEIH.SavedVars.LVRY = value
				RAEIH_LVR:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.LVRX, RAEIH.SavedVars.LVRY)
				RAEIH.SetLVR()
				RAEIH.FormatLVR()
				RAEIH.OrganizeLVR() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.LVRY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Horizantal Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.LVRIconX end,
				setFunc = function(value)
				RAEIH.SavedVars.LVRIconX = value
				RAEIH.SetLVR()
				RAEIH.FormatLVR()
				RAEIH.OrganizeLVR() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.LVRIconX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Vertical Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.LVRIconY end,
				setFunc = function(value)
				RAEIH.SavedVars.LVRIconY = value
				RAEIH.SetLVR()
				RAEIH.FormatLVR()
				RAEIH.OrganizeLVR() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.LVRIconY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			}
		}
	},

	-- XVP
	{
		type = "submenu",
		name = "XVP (Exp. & Veteran Points)",

			controls = {
			{
				type = "checkbox",
				name = "Enable XVP",
				getFunc = function() return RAEIH.SavedVars.ShowXVP end,
				setFunc = function(value)
				RAEIH.SavedVars.ShowXVP = value
				RAEIH_XVP:SetHidden(not RAEIH.SavedVars.ShowXVP)
				RAEIH.SetXVP()
				RAEIH.FormatXVP()
				RAEIH.OrganizeXVP() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ShowXVP
			},

			{
				type = "dropdown",
				name = "XVP Format",
				choices = {"Current/Max (%)", "Current/Max", "% Only"},
				getFunc = function() return RAEIH.SavedVars.XVPFormat end,
				setFunc = function(value)
				RAEIH.SavedVars.XVPFormat = value
				RAEIH.SetXVP()
				RAEIH.FormatXVP()
				RAEIH.OrganizeXVP()	end,
				width = "half",
				default = RAEIH.DefaultSavedVars.XVPFormat
			},

			{
				type = "dropdown",
				name = "Font Type",
				choices = LMP:List(LMP.MediaType.FONT),
				getFunc = function() return RAEIH.SavedVars.XVPFont end,
				setFunc = function(value)
				RAEIH.SavedVars.XVPFont = value
				RAEIH.SetXVP()
				RAEIH.FormatXVP()
				RAEIH.OrganizeXVP() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.XVPFont
			},

			{
				type = "dropdown",
				name = "Font Style",
				choices = {"Normal", "Outline", "Shadow", "Soft Shadow - Thick", "Soft Shadow - Thin", "Thick Outline"},
				getFunc = function() return RAEIH.SavedVars.XVPFontStyle end,
				setFunc = function(value)
				RAEIH.SavedVars.XVPFontStyle = value
				RAEIH.SetXVP()
				RAEIH.FormatXVP()
				RAEIH.OrganizeXVP() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.XVPFontStyle
			},

			{
				type = "slider",
				name = "Font Size",
				min = 8,
				max = 72,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.XVPFontSize end,
				setFunc = function(value)
				RAEIH.SavedVars.XVPFontSize = value
				RAEIH.SetXVP()
				RAEIH.FormatXVP()
				RAEIH.OrganizeXVP() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.XVPFontSize
			},

			{
				type = "dropdown",
				name = "Icon Size",
				choices = {"16", "24", "32", "40", "48", "56", "64"},
				getFunc = function() return RAEIH.SavedVars.XVPIconW end,
				setFunc = function(value)
				RAEIH.SavedVars.XVPIconW = value
				RAEIH.SavedVars.XVPIconH = value
				RAEIH_XVP_Icon:SetDimensions(RAEIH.SavedVars.XVPIconW, RAEIH.SavedVars.XVPIconH)
				RAEIH.SetXVP()
				RAEIH.FormatXVP()
				RAEIH.OrganizeXVP() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.XVPIconW
			},

			{
				type = "colorpicker",
				name = "XVP Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.XVPDefaultColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.XVPDefaultColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetXVP()
				RAEIH.FormatXVP()
				RAEIH.OrganizeXVP() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.XVPDefaultColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.XVPDefaultColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.XVPDefaultColour)
				}
			},

			{
				type = "colorpicker",
				name = "Early Stage Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.XVPESColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.XVPESColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetXVP()
				RAEIH.FormatXVP()
				RAEIH.OrganizeXVP() end,
				width = "full",
				tooltip = "Less than 25% of total XVP gained",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.XVPESColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.XVPESColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.XVPESColour)
				}
			},

			{
				type = "colorpicker",
				name = "Mid-Stage Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.XVPMSColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.XVPMSColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetXVP()
				RAEIH.FormatXVP()
				RAEIH.OrganizeXVP() end,
				width = "full",
				tooltip = "Current gained XVP is between 25% and 75%",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.XVPMSColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.XVPMSColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.XVPMSColour)
				}
			},

			{
				type = "colorpicker",
				name = "Late Stage Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.XVPLSColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.XVPLSColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetXVP()
				RAEIH.FormatXVP()
				RAEIH.OrganizeXVP() end,
				width = "full",
				tooltip = "More than 75% XVP gained",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.XVPLSColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.XVPLSColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.XVPLSColour)
				}
			},

			{
				type = "slider",
				name = "Background Alpha",
				min = 0,
				max = 100,
				step = 10,
				getFunc = function() return RAEIH.SavedVars.XVPBA * 100 end,
				setFunc = function(value)
				RAEIH.SavedVars.XVPBA = value / 100
				RAEIH.SetXVP()
				RAEIH.FormatXVP()
				RAEIH.OrganizeXVP() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.XVPBA * 100,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Horizontal Position",
				getFunc = function() return RAEIH.SavedVars.XVPX end,
				setFunc = function(value)
				RAEIH.SavedVars.XVPX = value
				RAEIH_XVP:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.XVPX, RAEIH.SavedVars.XVPY)
				RAEIH.SetXVP()
				RAEIH.FormatXVP()
				RAEIH.OrganizeXVP() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.XVPX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Vertical Position",
				getFunc = function() return RAEIH.SavedVars.XVPY end,
				setFunc = function(value)
				RAEIH.SavedVars.XVPY = value
				RAEIH_XVP:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.XVPX, RAEIH.SavedVars.XVPY)
				RAEIH.SetXVP()
				RAEIH.FormatXVP()
				RAEIH.OrganizeXVP() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.XVPY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Horizantal Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.XVPIconX end,
				setFunc = function(value)
				RAEIH.SavedVars.XVPIconX = value
				RAEIH.SetXVP()
				RAEIH.FormatXVP()
				RAEIH.OrganizeXVP() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.XVPIconX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Vertical Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.XVPIconY end,
				setFunc = function(value)
				RAEIH.SavedVars.XVPIconY = value
				RAEIH.SetXVP()
				RAEIH.FormatXVP()
				RAEIH.OrganizeXVP() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.XVPIconY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			}
		}
	},

	-- XVP PER HOUR
	{
		type = "submenu",
		name = "XVP per Hour (XP & VP / Hour)",

			controls = {
			{
				type = "checkbox",
				name = "Enable XVP per Hour",
				getFunc = function() return RAEIH.SavedVars.ShowXVPperHour end,
				setFunc = function(value)
				RAEIH.SavedVars.ShowXVPperHour = value
				RAEIH_XVPperHour:SetHidden(not RAEIH.SavedVars.ShowXVPperHour)
				RAEIH.SetXVPperHour()
				RAEIH.FormatXVPperHour()
				RAEIH.OrganizeXVPperHour()	end,
				width = "full",
				default = RAEIH.DefaultSavedVars.ShowXVPperHour
			},

			{
				type = "dropdown",
				name = "Font Type",
				choices = LMP:List(LMP.MediaType.FONT),
				getFunc = function() return RAEIH.SavedVars.XVPperHourFont end,
				setFunc = function(value)
				RAEIH.SavedVars.XVPperHourFont = value
				RAEIH.SetXVPperHour()
				RAEIH.FormatXVPperHour()
				RAEIH.OrganizeXVPperHour() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.XVPperHourFont
			},

			{
				type = "dropdown",
				name = "Font Style",
				choices = {"Normal", "Outline", "Shadow", "Soft Shadow - Thick", "Soft Shadow - Thin", "Thick Outline"},
				getFunc = function() return RAEIH.SavedVars.XVPperHourFontStyle end,
				setFunc = function(value)
				RAEIH.SavedVars.XVPperHourFontStyle = value
				RAEIH.SetXVPperHour()
				RAEIH.FormatXVPperHour()
				RAEIH.OrganizeXVPperHour() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.XVPperHourFontStyle
			},

			{
				type = "slider",
				name = "Font Size",
				min = 8,
				max = 72,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.XVPperHourFontSize end,
				setFunc = function(value)
				RAEIH.SavedVars.XVPperHourFontSize = value
				RAEIH.SetXVPperHour()
				RAEIH.FormatXVPperHour()
				RAEIH.OrganizeXVPperHour() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.XVPperHourFontSize
			},

			{
				type = "dropdown",
				name = "Icon Size",
				choices = {"16", "24", "32", "40", "48", "56", "64"},
				getFunc = function() return RAEIH.SavedVars.XVPperHourIconW end,
				setFunc = function(value)
				RAEIH.SavedVars.XVPperHourIconW = value
				RAEIH.SavedVars.XVPperHourIconH = value
				RAEIH_XVPperHour_Icon:SetDimensions(RAEIH.SavedVars.XVPperHourIconW, RAEIH.SavedVars.XVPperHourIconH)
				RAEIH.SetXVPperHour()
				RAEIH.FormatXVPperHour()
				RAEIH.OrganizeXVPperHour() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.XVPperHourIconW
			},


			{
				type = "colorpicker",
				name = "XVP/hr Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.XVPperHourDefaultColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.XVPperHourDefaultColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetXVPperHour()
				RAEIH.FormatXVPperHour()
				RAEIH.OrganizeXVPperHour() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.XVPperHourDefaultColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.XVPperHourDefaultColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.XVPperHourDefaultColour)
				}
			},

			{
				type = "colorpicker",
				name = "XVP Value Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.XVPperHourColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.XVPperHourColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetXVPperHour()
				RAEIH.FormatXVPperHour()
				RAEIH.OrganizeXVPperHour() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.XVPperHourColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.XVPperHourColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.XVPperHourColour)
				}
			},

			{
				type = "slider",
				name = "Background Alpha",
				min = 0,
				max = 100,
				step = 10,
				getFunc = function() return RAEIH.SavedVars.XVPperHourBA * 100 end,
				setFunc = function(value)
				RAEIH.SavedVars.XVPperHourBA = value / 100
				RAEIH.SetXVPperHour()
				RAEIH.FormatXVPperHour()
				RAEIH.OrganizeXVPperHour() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.XVPperHourBA * 100,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Horizontal Position",
				getFunc = function() return RAEIH.SavedVars.XVPperHourX end,
				setFunc = function(value)
				RAEIH.SavedVars.XVPperHourX = value
				RAEIH_XVPperHour:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.XVPperHourX, RAEIH.SavedVars.XVPperHourY)
				RAEIH.SetXVPperHour()
				RAEIH.FormatXVPperHour()
				RAEIH.OrganizeXVPperHour() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.XVPperHourX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Vertical Position",
				getFunc = function() return RAEIH.SavedVars.XVPperHourY end,
				setFunc = function(value)
				RAEIH.SavedVars.XVPperHourY = value
				RAEIH_XVPperHour:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.XVPperHourX, RAEIH.SavedVars.XVPperHourY)
				RAEIH.SetXVPperHour()
				RAEIH.FormatXVPperHour()
				RAEIH.OrganizeXVPperHour() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.XVPperHourY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Horizantal Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.XVPperHourIconX end,
				setFunc = function(value)
				RAEIH.SavedVars.XVPperHourIconX = value
				RAEIH.SetXVPperHour()
				RAEIH.FormatXVPperHour()
				RAEIH.OrganizeXVPperHour() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.XVPperHourIconX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Vertical Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.XVPperHourIconY end,
				setFunc = function(value)
				RAEIH.SavedVars.XVPperHourIconY = value
				RAEIH.SetXVPperHour()
				RAEIH.FormatXVPperHour()
				RAEIH.OrganizeXVPperHour() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.XVPperHourIconY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			}
		}
	},

	-- GOLD
	{
		type = "submenu",
		name = "Gold",

			controls = {
			{
				type = "checkbox",
				name = "Enable Gold",
				getFunc = function() return RAEIH.SavedVars.ShowGold end,
				setFunc = function(value)
				RAEIH.SavedVars.ShowGold = value
				RAEIH_Gold:SetHidden(not RAEIH.SavedVars.ShowGold)
				RAEIH.SetGold()
				RAEIH.FormatGold()
				RAEIH.OrganizeGold() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.ShowGold
			},

			{
				type = "dropdown",
				name = "Font Type",
				choices = LMP:List(LMP.MediaType.FONT),
				getFunc = function() return RAEIH.SavedVars.GoldFont end,
				setFunc = function(value)
				RAEIH.SavedVars.GoldFont = value
				RAEIH.SetGold()
				RAEIH.FormatGold()
				RAEIH.OrganizeGold() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.GoldFont
			},

			{
				type = "dropdown",
				name = "Font Style",
				choices = {"Normal", "Outline", "Shadow", "Soft Shadow - Thick", "Soft Shadow - Thin", "Thick Outline"},
				getFunc = function() return RAEIH.SavedVars.GoldFontStyle end,
				setFunc = function(value)
				RAEIH.SavedVars.GoldFontStyle = value
				RAEIH.SetGold()
				RAEIH.FormatGold()
				RAEIH.OrganizeGold() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.GoldFontStyle
			},

			{
				type = "slider",
				name = "Font Size",
				min = 8,
				max = 72,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.GoldFontSize end,
				setFunc = function(value)
				RAEIH.SavedVars.GoldFontSize = value
				RAEIH.SetGold()
				RAEIH.FormatGold()
				RAEIH.OrganizeGold() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.GoldFontSize
			},

			{
				type = "dropdown",
				name = "Icon Size",
				choices = {"16", "24", "32", "40", "48", "56", "64"},
				getFunc = function() return RAEIH.SavedVars.GoldIconW end,
				setFunc = function(value)
				RAEIH.SavedVars.GoldIconW = value
				RAEIH.SavedVars.GoldIconH = value
				RAEIH_Gold_Icon:SetDimensions(RAEIH.SavedVars.GoldIconW, RAEIH.SavedVars.GoldIconH)
				RAEIH.SetGold()
				RAEIH.FormatGold()
				RAEIH.OrganizeGold() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.GoldIconW
			},

			{
				type = "colorpicker",
				name = "Gold Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.GoldDefaultColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.GoldDefaultColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetGold()
				RAEIH.FormatGold()
				RAEIH.OrganizeGold() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.GoldDefaultColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.GoldDefaultColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.GoldDefaultColour)
				}
			},

			{
				type = "slider",
				name = "Background Alpha",
				min = 0,
				max = 100,
				step = 10,
				getFunc = function() return RAEIH.SavedVars.GoldBA * 100 end,
				setFunc = function(value)
				RAEIH.SavedVars.GoldBA = value / 100
				RAEIH.SetGold()
				RAEIH.FormatGold()
				RAEIH.OrganizeGold() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.GoldBA * 100,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Horizontal Position",
				getFunc = function() return RAEIH.SavedVars.GoldX end,
				setFunc = function(value)
				RAEIH.SavedVars.GoldX = value
				RAEIH_Gold:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.GoldX, RAEIH.SavedVars.GoldY)
				RAEIH.SetGold()
				RAEIH.FormatGold()
				RAEIH.OrganizeGold() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.GoldX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Vertical Position",
				getFunc = function() return RAEIH.SavedVars.GoldY end,
				setFunc = function(value)
				RAEIH.SavedVars.GoldY = value
				RAEIH_Gold:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.GoldX, RAEIH.SavedVars.GoldY)
				RAEIH.SetGold()
				RAEIH.FormatGold()
				RAEIH.OrganizeGold() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.GoldY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Horizantal Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.GoldIconX end,
				setFunc = function(value)
				RAEIH.SavedVars.GoldIconX = value
				RAEIH.SetGold()
				RAEIH.FormatGold()
				RAEIH.OrganizeGold() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.GoldIconX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Vertical Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.GoldIconY end,
				setFunc = function(value)
				RAEIH.SavedVars.GoldIconY = value
				RAEIH.SetGold()
				RAEIH.FormatGold()
				RAEIH.OrganizeGold() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.GoldIconY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			}
		}
	},

	-- GOLD PER HOUR
	{
		type = "submenu",
		name = "Gold per Hour",

			controls = {
			{
				type = "checkbox",
				name = "Enable Gold per Hour",
				getFunc = function() return RAEIH.SavedVars.ShowGoldperHour end,
				setFunc = function(value)
				RAEIH.SavedVars.ShowGoldperHour = value
				RAEIH_GoldperHour:SetHidden(not RAEIH.SavedVars.ShowGoldperHour)
				RAEIH.SetGoldperHour()
				RAEIH.FormatGoldperHour()
				RAEIH.OrganizeGoldperHour()	end,
				width = "full",
				default = RAEIH.DefaultSavedVars.ShowGoldperHour
			},

			{
				type = "dropdown",
				name = "Font Type",
				choices = LMP:List(LMP.MediaType.FONT),
				getFunc = function() return RAEIH.SavedVars.GoldperHourFont end,
				setFunc = function(value)
				RAEIH.SavedVars.GoldperHourFont = value
				RAEIH.SetGoldperHour()
				RAEIH.FormatGoldperHour()
				RAEIH.OrganizeGoldperHour() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.GoldperHourFont
			},

			{
				type = "dropdown",
				name = "Font Style",
				choices = {"Normal", "Outline", "Shadow", "Soft Shadow - Thick", "Soft Shadow - Thin", "Thick Outline"},
				getFunc = function() return RAEIH.SavedVars.GoldperHourFontStyle end,
				setFunc = function(value)
				RAEIH.SavedVars.GoldperHourFontStyle = value
				RAEIH.SetGoldperHour()
				RAEIH.FormatGoldperHour()
				RAEIH.OrganizeGoldperHour() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.GoldperHourFontStyle
			},

			{
				type = "slider",
				name = "Font Size",
				min = 8,
				max = 72,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.GoldperHourFontSize end,
				setFunc = function(value)
				RAEIH.SavedVars.GoldperHourFontSize = value
				RAEIH.SetGoldperHour()
				RAEIH.FormatGoldperHour()
				RAEIH.OrganizeGoldperHour() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.GoldperHourFontSize
			},

			{
				type = "dropdown",
				name = "Icon Size",
				choices = {"16", "24", "32", "40", "48", "56", "64"},
				getFunc = function() return RAEIH.SavedVars.GoldperHourIconW end,
				setFunc = function(value)
				RAEIH.SavedVars.GoldperHourIconW = value
				RAEIH.SavedVars.GoldperHourIconH = value
				RAEIH_GoldperHour_Icon:SetDimensions(RAEIH.SavedVars.GoldperHourIconW, RAEIH.SavedVars.GoldperHourIconH)
				RAEIH.SetGoldperHour()
				RAEIH.FormatGoldperHour()
				RAEIH.OrganizeGoldperHour() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.GoldperHourIconW
			},

			{
				type = "colorpicker",
				name = "G/hr Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.GoldperHourDefaultColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.GoldperHourDefaultColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetGoldperHour()
				RAEIH.FormatGoldperHour()
				RAEIH.OrganizeGoldperHour() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.GoldperHourDefaultColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.GoldperHourDefaultColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.GoldperHourDefaultColour)
				}
			},

			{
				type = "colorpicker",
				name = "Value Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.GoldperHourColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.GoldperHourColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetGoldperHour()
				RAEIH.FormatGoldperHour()
				RAEIH.OrganizeGoldperHour() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.GoldperHourColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.GoldperHourColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.GoldperHourColour)
				}
			},

			{
				type = "slider",
				name = "Background Alpha",
				min = 0,
				max = 100,
				step = 10,
				getFunc = function() return RAEIH.SavedVars.GoldperHourBA * 100 end,
				setFunc = function(value)
				RAEIH.SavedVars.GoldperHourBA = value / 100
				RAEIH.SetGoldperHour()
				RAEIH.FormatGoldperHour()
				RAEIH.OrganizeGoldperHour() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.GoldperHourBA * 100,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Horizontal Position",
				getFunc = function() return RAEIH.SavedVars.GoldperHourX end,
				setFunc = function(value)
				RAEIH.SavedVars.GoldperHourX = value
				RAEIH_GoldperHour:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.GoldperHourX, RAEIH.SavedVars.GoldperHourY)
				RAEIH.SetGoldperHour()
				RAEIH.FormatGoldperHour()
				RAEIH.OrganizeGoldperHour() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.GoldperHourX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Vertical Position",
				getFunc = function() return RAEIH.SavedVars.GoldperHourY end,
				setFunc = function(value)
				RAEIH.SavedVars.GoldperHourY = value
				RAEIH_GoldperHour:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.GoldperHourX, RAEIH.SavedVars.GoldperHourY)
				RAEIH.SetGoldperHour()
				RAEIH.FormatGoldperHour()
				RAEIH.OrganizeGoldperHour() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.GoldperHourY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Horizantal Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.GoldperHourIconX end,
				setFunc = function(value)
				RAEIH.SavedVars.GoldperHourIconX = value
				RAEIH.SetGoldperHour()
				RAEIH.FormatGoldperHour()
				RAEIH.OrganizeGoldperHour() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.GoldperHourIconX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Vertical Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.GoldperHourIconY end,
				setFunc = function(value)
				RAEIH.SavedVars.GoldperHourIconY = value
				RAEIH.SetGoldperHour()
				RAEIH.FormatGoldperHour()
				RAEIH.OrganizeGoldperHour() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.GoldperHourIconY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			}
		}
	},

	-- BANKED GOLD
	{
		type = "submenu",
		name = "Banked Gold",

			controls = {
			{
				type = "checkbox",
				name = "Enable Banked Gold",
				getFunc = function() return RAEIH.SavedVars.ShowBankedGold end,
				setFunc = function(value)
				RAEIH.SavedVars.ShowBankedGold = value
				RAEIH_BankedGold:SetHidden(not RAEIH.SavedVars.ShowBankedGold)
				RAEIH.SetBankedGold()
				RAEIH.FormatBankedGold()
				RAEIH.OrganizeBankedGold() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.ShowBankedGold
			},

			{
				type = "dropdown",
				name = "Font Type",
				choices = LMP:List(LMP.MediaType.FONT),
				getFunc = function() return RAEIH.SavedVars.BankedGoldFont end,
				setFunc = function(value)
				RAEIH.SavedVars.BankedGoldFont = value
				RAEIH.SetBankedGold()
				RAEIH.FormatBankedGold()
				RAEIH.OrganizeBankedGold() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.BankedGoldFont
			},

			{
				type = "dropdown",
				name = "Font Style",
				choices = {"Normal", "Outline", "Shadow", "Soft Shadow - Thick", "Soft Shadow - Thin", "Thick Outline"},
				getFunc = function() return RAEIH.SavedVars.BankedGoldFontStyle end,
				setFunc = function(value)
				RAEIH.SavedVars.BankedGoldFontStyle = value
				RAEIH.SetBankedGold()
				RAEIH.FormatBankedGold()
				RAEIH.OrganizeBankedGold() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.BankedGoldFontStyle
			},

			{
				type = "slider",
				name = "Font Size",
				min = 8,
				max = 72,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.BankedGoldFontSize end,
				setFunc = function(value)
				RAEIH.SavedVars.BankedGoldFontSize = value
				RAEIH.SetBankedGold()
				RAEIH.FormatBankedGold()
				RAEIH.OrganizeBankedGold() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.BankedGoldFontSize
			},

			{
				type = "dropdown",
				name = "Icon Size",
				choices = {"16", "24", "32", "40", "48", "56", "64"},
				getFunc = function() return RAEIH.SavedVars.BankedGoldIconW end,
				setFunc = function(value)
				RAEIH.SavedVars.BankedGoldIconW = value
				RAEIH.SavedVars.BankedGoldIconH = value
				RAEIH_BankedGold_Icon:SetDimensions(RAEIH.SavedVars.BankedGoldIconW, RAEIH.SavedVars.BankedGoldIconH)
				RAEIH.SetBankedGold()
				RAEIH.FormatBankedGold()
				RAEIH.OrganizeBankedGold() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.BankedGoldIconW
			},

			{
				type = "colorpicker",
				name = "Banked Gold Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.BankedGoldDefaultColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.BankedGoldDefaultColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetBankedGold()
				RAEIH.FormatBankedGold()
				RAEIH.OrganizeBankedGold() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.BankedGoldDefaultColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.BankedGoldDefaultColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.BankedGoldDefaultColour)
				}
			},

			{
				type = "slider",
				name = "Background Alpha",
				min = 0,
				max = 100,
				step = 10,
				getFunc = function() return RAEIH.SavedVars.BankedGoldBA * 100 end,
				setFunc = function(value)
				RAEIH.SavedVars.BankedGoldBA = value / 100
				RAEIH.SetBankedGold()
				RAEIH.FormatBankedGold()
				RAEIH.OrganizeBankedGold() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.BankedGoldBA * 100,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Horizontal Position",
				getFunc = function() return RAEIH.SavedVars.BankedGoldX end,
				setFunc = function(value)
				RAEIH.SavedVars.BankedGoldX = value
				RAEIH_BankedGold:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.BankedGoldX, RAEIH.SavedVars.BankedGoldY)
				RAEIH.SetBankedGold()
				RAEIH.FormatBankedGold()
				RAEIH.OrganizeBankedGold() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.BankedGoldX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Vertical Position",
				getFunc = function() return RAEIH.SavedVars.BankedGoldY end,
				setFunc = function(value)
				RAEIH.SavedVars.BankedGoldY = value
				RAEIH_BankedGold:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.BankedGoldX, RAEIH.SavedVars.BankedGoldY)
				RAEIH.SetBankedGold()
				RAEIH.FormatBankedGold()
				RAEIH.OrganizeBankedGold() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.BankedGoldY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Horizantal Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.BankedGoldIconX end,
				setFunc = function(value)
				RAEIH.SavedVars.BankedGoldIconX = value
				RAEIH.SetBankedGold()
				RAEIH.FormatBankedGold()
				RAEIH.OrganizeBankedGold() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.BankedGoldIconX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Vertical Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.BankedGoldIconY end,
				setFunc = function(value)
				RAEIH.SavedVars.BankedGoldIconY = value
				RAEIH.SetBankedGold()
				RAEIH.FormatBankedGold()
				RAEIH.OrganizeBankedGold() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.BankedGoldIconY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			}
		}
	},

	-- DURABILITY
	{
		type = "submenu",
		name = "Durability (Item Conditions)",

			controls = {
			{
				type = "description",
				title = "Durability Acronyms",
				text = "HD: Head, CH: Chest, SH: Shoulders, HN: Hands, WS: Waist, LG: Legs, FT: Feet, MH: Mainhand, OH: Offhand",
				width = "full"
			},

			{
				type = "checkbox",
				name = "Enable Durability",
				getFunc = function() return RAEIH.SavedVars.ShowDurability end,
				setFunc = function(value)
				RAEIH.SavedVars.ShowDurability = value
				RAEIH_Durability:SetHidden(not RAEIH.SavedVars.ShowDurability)
				RAEIH.SetDurability()
				RAEIH.FormatDurability()
				RAEIH.OrganizeDurability() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ShowDurability
			},

			{
				type = "dropdown",
				name = "Durability Format",
				choices = {"General% (Lowest Item%)", "General%", "Lowest Item%"},
				getFunc = function() return RAEIH.SavedVars.DurabilityFormat end,
				setFunc = function(value)
				RAEIH.SavedVars.DurabilityFormat = value
				RAEIH.SetDurability()
				RAEIH.FormatDurability()
				RAEIH.OrganizeDurability() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.DurabilityFormat
			},

			{
				type = "checkbox",
				name = "Enable Auto Repair",
				getFunc = function() return RAEIH.SavedVars.AutoRepairEnabled end,
				setFunc = function(value)
				RAEIH.SavedVars.AutoRepairEnabled = value end,
				width = "half",
				tooltip = "It'll be effective even if Durability module is disabled",
				default = RAEIH.DefaultSavedVars.AutoRepairEnabled
				-- warning = ""
			},

			{
				type = "slider",
				name = "AR Threshold as %",
				min = 1,
				max = 100,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.AutoRepairThreshold end,
				setFunc = function(value)
				RAEIH.SavedVars.AutoRepairThreshold = value end,
				width = "half",
				disabled = function() return not RAEIH.SavedVars.AutoRepairEnabled end,
				default = RAEIH.DefaultSavedVars.AutoRepairThreshold,
				tooltip = "It's item specific. That means, If you set it to 25% and when you interact with store, your worn items that is below 25% condition will be repaired while others won't"
			},

			{
				type = "dropdown",
				name = "Font Type",
				choices = LMP:List(LMP.MediaType.FONT),
				getFunc = function() return RAEIH.SavedVars.DurabilityFont end,
				setFunc = function(value)
				RAEIH.SavedVars.DurabilityFont = value
				RAEIH.SetDurability()
				RAEIH.FormatDurability()
				RAEIH.OrganizeDurability() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.DurabilityFont
			},

			{
				type = "dropdown",
				name = "Font Style",
				choices = {"Normal", "Outline", "Shadow", "Soft Shadow - Thick", "Soft Shadow - Thin", "Thick Outline"},
				getFunc = function() return RAEIH.SavedVars.DurabilityFontStyle end,
				setFunc = function(value)
				RAEIH.SavedVars.DurabilityFontStyle = value
				RAEIH.SetDurability()
				RAEIH.FormatDurability()
				RAEIH.OrganizeDurability() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.DurabilityFontStyle
			},

			{
				type = "slider",
				name = "Font Size",
				min = 8,
				max = 72,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.DurabilityFontSize end,
				setFunc = function(value)
				RAEIH.SavedVars.DurabilityFontSize = value
				RAEIH.SetDurability()
				RAEIH.FormatDurability()
				RAEIH.OrganizeDurability() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.DurabilityFontSize
			},

			{
				type = "dropdown",
				name = "Icon Size",
				choices = {"16", "24", "32", "40", "48", "56", "64"},
				getFunc = function() return RAEIH.SavedVars.DurabilityIconW end,
				setFunc = function(value)
				RAEIH.SavedVars.DurabilityIconW = value
				RAEIH.SavedVars.DurabilityIconH = value
				RAEIH_Durability_Icon:SetDimensions(RAEIH.SavedVars.DurabilityIconW, RAEIH.SavedVars.DurabilityIconH)
				RAEIH.SetDurability()
				RAEIH.FormatDurability()
				RAEIH.OrganizeDurability() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.DurabilityIconW
			},

			{
				type = "colorpicker",
				name = "Default Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.DurabilityDefaultColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.DurabilityDefaultColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetDurability()
				RAEIH.FormatDurability()
				RAEIH.OrganizeDurability() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.DurabilityDefaultColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.DurabilityDefaultColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.DurabilityDefaultColour)
				}
			},

			{
				type = "colorpicker",
				name = "Low Durability Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.DurabilityAlertColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.DurabilityAlertColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetDurability()
				RAEIH.FormatDurability()
				RAEIH.OrganizeDurability() end,
				width = "full",
				tooltip = "Durability is less than 25%",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.DurabilityAlertColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.DurabilityAlertColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.DurabilityAlertColour)
				}
			},

			{
				type = "colorpicker",
				name = "Medium Durability Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.DurabilityWarningColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.DurabilityWarningColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetDurability()
				RAEIH.FormatDurability()
				RAEIH.OrganizeDurability() end,
				width = "full",
				tooltip = "Durability is between 25% and 75%",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.DurabilityWarningColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.DurabilityWarningColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.DurabilityWarningColour)
				}
			},

			{
				type = "colorpicker",
				name = "High Durability Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.DurabilityNormalColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.DurabilityNormalColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetDurability()
				RAEIH.FormatDurability()
				RAEIH.OrganizeDurability() end,
				width = "full",
				tooltip = "Durability is higher than 75%",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.DurabilityNormalColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.DurabilityNormalColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.DurabilityNormalColour)
				}
			},

			{
				type = "slider",
				name = "Background Alpha",
				min = 0,
				max = 100,
				step = 10,
				getFunc = function() return RAEIH.SavedVars.DurabilityBA * 100 end,
				setFunc = function(value)
				RAEIH.SavedVars.DurabilityBA = value / 100
				RAEIH.SetDurability()
				RAEIH.FormatDurability()
				RAEIH.OrganizeDurability() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.DurabilityBA * 100,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Horizontal Position",
				getFunc = function() return RAEIH.SavedVars.DurabilityX end,
				setFunc = function(value)
				RAEIH.SavedVars.DurabilityX = value
				RAEIH_Durability:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.DurabilityX, RAEIH.SavedVars.DurabilityY)
				RAEIH.SetDurability()
				RAEIH.FormatDurability()
				RAEIH.OrganizeDurability() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.DurabilityX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Vertical Position",
				getFunc = function() return RAEIH.SavedVars.DurabilityY end,
				setFunc = function(value)
				RAEIH.SavedVars.DurabilityY = value
				RAEIH_Durability:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.DurabilityX, RAEIH.SavedVars.DurabilityY)
				RAEIH.SetDurability()
				RAEIH.FormatDurability()
				RAEIH.OrganizeDurability() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.DurabilityY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Horizantal Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.DurabilityIconX end,
				setFunc = function(value)
				RAEIH.SavedVars.DurabilityIconX = value
				RAEIH.SetDurability()
				RAEIH.FormatDurability()
				RAEIH.OrganizeDurability() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.DurabilityIconX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Vertical Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.DurabilityIconY end,
				setFunc = function(value)
				RAEIH.SavedVars.DurabilityIconY = value
				RAEIH.SetDurability()
				RAEIH.FormatDurability()
				RAEIH.OrganizeDurability() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.DurabilityIconY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			}
		}
	},

	-- REPAIR COST
	{
		type = "submenu",
		name = "Repair Cost",

			controls = {
			{
				type = "checkbox",
				name = "Enable Repair Cost",
				getFunc = function() return RAEIH.SavedVars.ShowRepairCost end,
				setFunc = function(value)
				RAEIH.SavedVars.ShowRepairCost = value
				RAEIH_RepairCost:SetHidden(not RAEIH.SavedVars.ShowRepairCost)
				RAEIH.SetRepairCost()
				RAEIH.FormatRepairCost()
				RAEIH.OrganizeRepairCost() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.ShowRepairCost
			},

			{
				type = "dropdown",
				name = "Font Type",
				choices = LMP:List(LMP.MediaType.FONT),
				getFunc = function() return RAEIH.SavedVars.RepairCostFont end,
				setFunc = function(value)
				RAEIH.SavedVars.RepairCostFont = value
				RAEIH.SetRepairCost()
				RAEIH.FormatRepairCost()
				RAEIH.OrganizeRepairCost() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.RepairCostFont
			},

			{
				type = "dropdown",
				name = "Font Style",
				choices = {"Normal", "Outline", "Shadow", "Soft Shadow - Thick", "Soft Shadow - Thin", "Thick Outline"},
				getFunc = function() return RAEIH.SavedVars.RepairCostFontStyle end,
				setFunc = function(value)
				RAEIH.SavedVars.RepairCostFontStyle = value
				RAEIH.SetRepairCost()
				RAEIH.FormatRepairCost()
				RAEIH.OrganizeRepairCost() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.RepairCostFontStyle
			},

			{
				type = "slider",
				name = "Font Size",
				min = 8,
				max = 72,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.RepairCostFontSize end,
				setFunc = function(value)
				RAEIH.SavedVars.RepairCostFontSize = value
				RAEIH.SetRepairCost()
				RAEIH.FormatRepairCost()
				RAEIH.OrganizeRepairCost() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.RepairCostFontSize
			},

			{
				type = "dropdown",
				name = "Icon Size",
				choices = {"16", "24", "32", "40", "48", "56", "64"},
				getFunc = function() return RAEIH.SavedVars.RepairCostIconW end,
				setFunc = function(value)
				RAEIH.SavedVars.RepairCostIconW = value
				RAEIH.SavedVars.RepairCostIconH = value
				RAEIH_RepairCost_Icon:SetDimensions(RAEIH.SavedVars.RepairCostIconW, RAEIH.SavedVars.RepairCostIconH)
				RAEIH.SetRepairCost()
				RAEIH.FormatRepairCost()
				RAEIH.OrganizeRepairCost() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.RepairCostIconW
			},

			{
				type = "colorpicker",
				name = "High Repair Cost Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.RepairCostAlertColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.RepairCostAlertColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetRepairCost()
				RAEIH.FormatRepairCost()
				RAEIH.OrganizeRepairCost() end,
				width = "full",
				tooltip = "+1000g",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.RepairCostAlertColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.RepairCostAlertColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.RepairCostAlertColour)
				}
			},

			{
				type = "colorpicker",
				name = "Normal Repair Cost Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.RepairCostWarningColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.RepairCostWarningColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetRepairCost()
				RAEIH.FormatRepairCost()
				RAEIH.OrganizeRepairCost() end,
				width = "full",
				tooltip = "Between 1g and 1000g",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.RepairCostWarningColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.RepairCostWarningColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.RepairCostWarningColour)
				}
			},

			{
				type = "colorpicker",
				name = "Zero Repair Cost Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.RepairCostNormalColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.RepairCostNormalColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetRepairCost()
				RAEIH.FormatRepairCost()
				RAEIH.OrganizeRepairCost() end,
				width = "full",
				tooltip = "Alll items are intact",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.RepairCostNormalColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.RepairCostNormalColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.RepairCostNormalColour)
				}
			},

			{
				type = "slider",
				name = "Background Alpha",
				min = 0,
				max = 100,
				step = 10,
				getFunc = function() return RAEIH.SavedVars.RepairCostBA * 100 end,
				setFunc = function(value)
				RAEIH.SavedVars.RepairCostBA = value / 100
				RAEIH.SetRepairCost()
				RAEIH.FormatRepairCost()
				RAEIH.OrganizeRepairCost() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.RepairCostBA * 100,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Horizontal Position",
				getFunc = function() return RAEIH.SavedVars.RepairCostX end,
				setFunc = function(value)
				RAEIH.SavedVars.RepairCostX = value
				RAEIH_RepairCost:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.RepairCostX, RAEIH.SavedVars.RepairCostY)
				RAEIH.SetRepairCost()
				RAEIH.FormatRepairCost()
				RAEIH.OrganizeRepairCost() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.RepairCostX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Vertical Position",
				getFunc = function() return RAEIH.SavedVars.RepairCostY end,
				setFunc = function(value)
				RAEIH.SavedVars.RepairCostY = value
				RAEIH_RepairCost:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.RepairCostX, RAEIH.SavedVars.RepairCostY)
				RAEIH.SetRepairCost()
				RAEIH.FormatRepairCost()
				RAEIH.OrganizeRepairCost() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.RepairCostY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Horizantal Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.RepairCostIconX end,
				setFunc = function(value)
				RAEIH.SavedVars.RepairCostIconX = value
				RAEIH.SetRepairCost()
				RAEIH.FormatRepairCost()
				RAEIH.OrganizeRepairCost() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.RepairCostIconX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Vertical Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.RepairCostIconY end,
				setFunc = function(value)
				RAEIH.SavedVars.RepairCostIconY = value
				RAEIH.SetRepairCost()
				RAEIH.FormatRepairCost()
				RAEIH.OrganizeRepairCost() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.RepairCostIconY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			}
		}
	},

	-- BAG SLOTS
	{
		type = "submenu",
		name = "Bag Slots",

			controls = {
			{
				type = "description",
				title = "Bag Slots Acronyms",
				text = "F: Free",
				width = "full"
			},

			{
				type = "checkbox",
				name = "Enable Bag Slots",
				getFunc = function() return RAEIH.SavedVars.ShowBagSlots end,
				setFunc = function(value)
				RAEIH.SavedVars.ShowBagSlots = value
				RAEIH_BagSlots:SetHidden(not RAEIH.SavedVars.ShowBagSlots)
				RAEIH.SetBagSlots()
				RAEIH.FormatBagSlots()
				RAEIH.OrganizeBagSlots() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ShowBagSlots
			},

			{
				type = "dropdown",
				name = "Bag Slots Format",
				choices = {"Used/Total (Free)", "Used/Total", "Free/Total"},
				getFunc = function() return RAEIH.SavedVars.BagSlotsFormat end,
				setFunc = function(value)
				RAEIH.SavedVars.BagSlotsFormat = value
				RAEIH.SetBagSlots()
				RAEIH.FormatBagSlots()
				RAEIH.OrganizeBagSlots() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.BagSlotsFormat
			},

			{
				type = "dropdown",
				name = "Font Type",
				choices = LMP:List(LMP.MediaType.FONT),
				getFunc = function() return RAEIH.SavedVars.BagSlotsFont end,
				setFunc = function(value)
				RAEIH.SavedVars.BagSlotsFont = value
				RAEIH.SetBagSlots()
				RAEIH.FormatBagSlots()
				RAEIH.OrganizeBagSlots() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.BagSlotsFont
			},

			{
				type = "dropdown",
				name = "Font Style",
				choices = {"Normal", "Outline", "Shadow", "Soft Shadow - Thick", "Soft Shadow - Thin", "Thick Outline"},
				getFunc = function() return RAEIH.SavedVars.BagSlotsFontStyle end,
				setFunc = function(value)
				RAEIH.SavedVars.BagSlotsFontStyle = value
				RAEIH.SetBagSlots()
				RAEIH.FormatBagSlots()
				RAEIH.OrganizeBagSlots() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.BagSlotsFontStyle
			},

			{
				type = "slider",
				name = "Font Size",
				min = 8,
				max = 72,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.BagSlotsFontSize end,
				setFunc = function(value)
				RAEIH.SavedVars.BagSlotsFontSize = value
				RAEIH.SetBagSlots()
				RAEIH.FormatBagSlots()
				RAEIH.OrganizeBagSlots() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.BagSlotsFontSize
			},

			{
				type = "dropdown",
				name = "Icon Size",
				choices = {"16", "24", "32", "40", "48", "56", "64"},
				getFunc = function() return RAEIH.SavedVars.BagSlotsIconW end,
				setFunc = function(value)
				RAEIH.SavedVars.BagSlotsIconW = value
				RAEIH.SavedVars.BagSlotsIconH = value
				RAEIH_BagSlots_Icon:SetDimensions(RAEIH.SavedVars.BagSlotsIconW, RAEIH.SavedVars.BagSlotsIconH)
				RAEIH.SetBagSlots()
				RAEIH.FormatBagSlots()
				RAEIH.OrganizeBagSlots() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.BagSlotsIconW
			},

			{
				type = "colorpicker",
				name = "Default Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.BagSlotsDefaultColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.BagSlotsDefaultColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetBagSlots()
				RAEIH.FormatBagSlots()
				RAEIH.OrganizeBagSlots() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.BagSlotsDefaultColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.BagSlotsDefaultColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.BagSlotsDefaultColour)
				}
			},

			{
				type = "colorpicker",
				name = "Confined Bag Space Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.BagSlotsAlertColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.BagSlotsAlertColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetBagSlots()
				RAEIH.FormatBagSlots()
				RAEIH.OrganizeBagSlots() end,
				width = "full",
				tooltip = "+75% Full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.BagSlotsAlertColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.BagSlotsAlertColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.BagSlotsAlertColour)
				}
			},

			{
				type = "colorpicker",
				name = "Normal Bag Space Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.BagSlotsWarningColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.BagSlotsWarningColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetBagSlots()
				RAEIH.FormatBagSlots()
				RAEIH.OrganizeBagSlots() end,
				width = "full",
				tooltip = "Usage Between 25% - 75%",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.BagSlotsWarningColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.BagSlotsWarningColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.BagSlotsWarningColour)
				}
			},

			{
				type = "colorpicker",
				name = "Large Bag Space Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.BagSlotsNormalColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.BagSlotsNormalColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetBagSlots()
				RAEIH.FormatBagSlots()
				RAEIH.OrganizeBagSlots() end,
				width = "full",
				tooltip = "+75% Free",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.BagSlotsNormalColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.BagSlotsNormalColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.BagSlotsNormalColour)
				}
			},

			{
				type = "slider",
				name = "Background Alpha",
				min = 0,
				max = 100,
				step = 10,
				getFunc = function() return RAEIH.SavedVars.BagSlotsBA * 100 end,
				setFunc = function(value)
				RAEIH.SavedVars.BagSlotsBA = value / 100
				RAEIH.SetBagSlots()
				RAEIH.FormatBagSlots()
				RAEIH.OrganizeBagSlots() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.BagSlotsBA * 100,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Horizontal Position",
				getFunc = function() return RAEIH.SavedVars.BagSlotsX end,
				setFunc = function(value)
				RAEIH.SavedVars.BagSlotsX = value
				RAEIH_BagSlots:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.BagSlotsX, RAEIH.SavedVars.BagSlotsY)
				RAEIH.SetBagSlots()
				RAEIH.FormatBagSlots()
				RAEIH.OrganizeBagSlots() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.BagSlotsX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Vertical Position",
				getFunc = function() return RAEIH.SavedVars.BagSlotsY end,
				setFunc = function(value)
				RAEIH.SavedVars.BagSlotsY = value
				RAEIH_BagSlots:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.BagSlotsX, RAEIH.SavedVars.BagSlotsY)
				RAEIH.SetBagSlots()
				RAEIH.FormatBagSlots()
				RAEIH.OrganizeBagSlots() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.BagSlotsY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Horizantal Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.BagSlotsIconX end,
				setFunc = function(value)
				RAEIH.SavedVars.BagSlotsIconX = value
				RAEIH.SetBagSlots()
				RAEIH.FormatBagSlots()
				RAEIH.OrganizeBagSlots() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.BagSlotsIconX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Vertical Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.BagSlotsIconY end,
				setFunc = function(value)
				RAEIH.SavedVars.BagSlotsIconY = value
				RAEIH.SetBagSlots()
				RAEIH.FormatBagSlots()
				RAEIH.OrganizeBagSlots() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.BagSlotsIconY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			}
		}
	},

	-- BANK SLOTS
	{
		type = "submenu",
		name = "Bank Slots",

			controls = {
			{
				type = "description",
				title = "Bank Slots Acronyms",
				text = "F: Free",
				width = "full"
			},
			{
				type = "checkbox",
				name = "Enable Bank Slots",
				getFunc = function() return RAEIH.SavedVars.ShowBankSlots end,
				setFunc = function(value)
				RAEIH.SavedVars.ShowBankSlots = value
				RAEIH_BankSlots:SetHidden(not RAEIH.SavedVars.ShowBankSlots)
				RAEIH.SetBankSlots()
				RAEIH.FormatBankSlots()
				RAEIH.OrganizeBankSlots() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ShowBankSlots
			},

			{
				type = "dropdown",
				name = "Bank Slots Format",
				choices = {"Used/Total (Free)", "Used/Total", "Free/Total"},
				getFunc = function() return RAEIH.SavedVars.BankSlotsFormat end,
				setFunc = function(value)
				RAEIH.SavedVars.BankSlotsFormat = value
				RAEIH.SetBankSlots()
				RAEIH.FormatBankSlots()
				RAEIH.OrganizeBankSlots() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.BankSlotsFormat
			},

			{
				type = "dropdown",
				name = "Font Type",
				choices = LMP:List(LMP.MediaType.FONT),
				getFunc = function() return RAEIH.SavedVars.BankSlotsFont end,
				setFunc = function(value)
				RAEIH.SavedVars.BankSlotsFont = value
				RAEIH.SetBankSlots()
				RAEIH.FormatBankSlots()
				RAEIH.OrganizeBankSlots() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.BankSlotsFont
			},

			{
				type = "dropdown",
				name = "Font Style",
				choices = {"Normal", "Outline", "Shadow", "Soft Shadow - Thick", "Soft Shadow - Thin", "Thick Outline"},
				getFunc = function() return RAEIH.SavedVars.BankSlotsFontStyle end,
				setFunc = function(value)
				RAEIH.SavedVars.BankSlotsFontStyle = value
				RAEIH.SetBankSlots()
				RAEIH.FormatBankSlots()
				RAEIH.OrganizeBankSlots() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.BankSlotsFontStyle
			},

			{
				type = "slider",
				name = "Font Size",
				min = 8,
				max = 72,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.BankSlotsFontSize end,
				setFunc = function(value)
				RAEIH.SavedVars.BankSlotsFontSize = value
				RAEIH.SetBankSlots()
				RAEIH.FormatBankSlots()
				RAEIH.OrganizeBankSlots() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.BankSlotsFontSize
			},

			{
				type = "dropdown",
				name = "Icon Size",
				choices = {"16", "24", "32", "40", "48", "56", "64"},
				getFunc = function() return RAEIH.SavedVars.BankSlotsIconW end,
				setFunc = function(value)
				RAEIH.SavedVars.BankSlotsIconW = value
				RAEIH.SavedVars.BankSlotsIconH = value
				RAEIH_BankSlots_Icon:SetDimensions(RAEIH.SavedVars.BankSlotsIconW, RAEIH.SavedVars.BankSlotsIconH)
				RAEIH.SetBankSlots()
				RAEIH.FormatBankSlots()
				RAEIH.OrganizeBankSlots() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.BankSlotsIconW
			},

			{
				type = "colorpicker",
				name = "Default Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.BankSlotsDefaultColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.BankSlotsDefaultColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetBankSlots()
				RAEIH.FormatBankSlots()
				RAEIH.OrganizeBankSlots() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.BankSlotsDefaultColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.BankSlotsDefaultColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.BankSlotsDefaultColour)
				}
			},

			{
				type = "colorpicker",
				name = "Confined Bank Space Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.BankSlotsAlertColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.BankSlotsAlertColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetBankSlots()
				RAEIH.FormatBankSlots()
				RAEIH.OrganizeBankSlots() end,
				width = "full",
				tooltip = "+75% Full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.BankSlotsAlertColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.BankSlotsAlertColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.BankSlotsAlertColour)
				}
			},

			{
				type = "colorpicker",
				name = "Normal Bank Space Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.BankSlotsWarningColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.BankSlotsWarningColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetBankSlots()
				RAEIH.FormatBankSlots()
				RAEIH.OrganizeBankSlots() end,
				width = "full",
				tooltip = "Usage Between 25% and 75%",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.BankSlotsWarningColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.BankSlotsWarningColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.BankSlotsWarningColour)
				}
			},

			{
				type = "colorpicker",
				name = "Large Bank Space Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.BankSlotsNormalColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.BankSlotsNormalColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetBankSlots()
				RAEIH.FormatBankSlots()
				RAEIH.OrganizeBankSlots() end,
				width = "full",
				tooltip = "+75% Empty",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.BankSlotsNormalColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.BankSlotsNormalColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.BankSlotsNormalColour)
				}
			},

			{
				type = "slider",
				name = "Background Alpha",
				min = 0,
				max = 100,
				step = 10,
				getFunc = function() return RAEIH.SavedVars.BankSlotsBA * 100 end,
				setFunc = function(value)
				RAEIH.SavedVars.BankSlotsBA = value / 100
				RAEIH.SetBankSlots()
				RAEIH.FormatBankSlots()
				RAEIH.OrganizeBankSlots() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.BankSlotsBA * 100,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Horizontal Position",
				getFunc = function() return RAEIH.SavedVars.BankSlotsX end,
				setFunc = function(value)
				RAEIH.SavedVars.BankSlotsX = value
				RAEIH_BankSlots:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.BankSlotsX, RAEIH.SavedVars.BankSlotsY)
				RAEIH.SetBankSlots()
				RAEIH.FormatBankSlots()
				RAEIH.OrganizeBankSlots() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.BankSlotsX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Vertical Position",
				getFunc = function() return RAEIH.SavedVars.BankSlotsY end,
				setFunc = function(value)
				RAEIH.SavedVars.BankSlotsY = value
				RAEIH_BankSlots:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.BankSlotsX, RAEIH.SavedVars.BankSlotsY)
				RAEIH.SetBankSlots()
				RAEIH.FormatBankSlots()
				RAEIH.OrganizeBankSlots() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.BankSlotsY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Horizantal Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.BankSlotsIconX end,
				setFunc = function(value)
				RAEIH.SavedVars.BankSlotsIconX = value
				RAEIH.SetBankSlots()
				RAEIH.FormatBankSlots()
				RAEIH.OrganizeBankSlots() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.BankSlotsIconX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Vertical Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.BankSlotsIconY end,
				setFunc = function(value)
				RAEIH.SavedVars.BankSlotsIconY = value
				RAEIH.SetBankSlots()
				RAEIH.FormatBankSlots()
				RAEIH.OrganizeBankSlots() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.BankSlotsIconY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			}
		}
	},

	-- THIEVERY
	{
		type = "submenu",
		name = "Thievery",

			controls = {
			{
				type = "description",
				title = "Thievery Acronyms",
				text = "SI: Stolen Items Number, TV: Total Value, US & UF: Used Sale / Fence Limit (Daily), TS & TF: Total Sale / Fence Limit (Daily)",
				width = "full"
			},
			{
				type = "checkbox",
				name = "Enable Thievery",
				getFunc = function() return RAEIH.SavedVars.ShowThievery end,
				setFunc = function(value)
				RAEIH.SavedVars.ShowThievery = value
				RAEIH_Thievery:SetHidden(not RAEIH.SavedVars.ShowThievery)
				RAEIH.SetThievery()
				RAEIH.FormatThievery()
				RAEIH.OrganizeThievery() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ShowThievery
			},

			{
				type = "dropdown",
				name = "Thievery Format",
				choices = {"SI (TV) » US/TS - UF/TF", "SI (TV) » US/TS", "SI (TV) » UF/TF", "US/TS - UF/TF", "SI (TV)"},
				getFunc = function() return RAEIH.SavedVars.ThieveryFormat end,
				setFunc = function(value)
				RAEIH.SavedVars.ThieveryFormat = value
				RAEIH.SetThievery()
				RAEIH.FormatThievery()
				RAEIH.OrganizeThievery() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ThieveryFormat
			},

			{
				type = "dropdown",
				name = "Font Type",
				choices = LMP:List(LMP.MediaType.FONT),
				getFunc = function() return RAEIH.SavedVars.ThieveryFont end,
				setFunc = function(value)
				RAEIH.SavedVars.ThieveryFont = value
				RAEIH.SetThievery()
				RAEIH.FormatThievery()
				RAEIH.OrganizeThievery() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ThieveryFont
			},

			{
				type = "dropdown",
				name = "Font Style",
				choices = {"Normal", "Outline", "Shadow", "Soft Shadow - Thick", "Soft Shadow - Thin", "Thick Outline"},
				getFunc = function() return RAEIH.SavedVars.ThieveryFontStyle end,
				setFunc = function(value)
				RAEIH.SavedVars.ThieveryFontStyle = value
				RAEIH.SetThievery()
				RAEIH.FormatThievery()
				RAEIH.OrganizeThievery() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ThieveryFontStyle
			},

			{
				type = "slider",
				name = "Font Size",
				min = 8,
				max = 72,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.ThieveryFontSize end,
				setFunc = function(value)
				RAEIH.SavedVars.ThieveryFontSize = value
				RAEIH.SetThievery()
				RAEIH.FormatThievery()
				RAEIH.OrganizeThievery() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ThieveryFontSize
			},

			{
				type = "dropdown",
				name = "Icon Size",
				choices = {"16", "24", "32", "40", "48", "56", "64"},
				getFunc = function() return RAEIH.SavedVars.ThieveryIconW end,
				setFunc = function(value)
				RAEIH.SavedVars.ThieveryIconW = value
				RAEIH.SavedVars.ThieveryIconH = value
				RAEIH_Thievery_Icon:SetDimensions(RAEIH.SavedVars.ThieveryIconW, RAEIH.SavedVars.ThieveryIconH)
				RAEIH.SetThievery()
				RAEIH.FormatThievery()
				RAEIH.OrganizeThievery() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ThieveryIconW
			},

			{
				type = "colorpicker",
				name = "Default Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.ThieveryDefaultColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.ThieveryDefaultColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetThievery()
				RAEIH.FormatThievery()
				RAEIH.OrganizeThievery() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.ThieveryDefaultColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.ThieveryDefaultColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.ThieveryDefaultColour)
				}
			},

			{
				type = "colorpicker",
				name = "High Usage Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.ThieveryAlertColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.ThieveryAlertColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetThievery()
				RAEIH.FormatThievery()
				RAEIH.OrganizeThievery() end,
				width = "full",
				tooltip = "+75% of Daily fencing / laundry right is used",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.ThieveryAlertColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.ThieveryAlertColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.ThieveryAlertColour)
				}
			},

			{
				type = "colorpicker",
				name = "Normal Usage Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.ThieveryWarningColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.ThieveryWarningColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetThievery()
				RAEIH.FormatThievery()
				RAEIH.OrganizeThievery() end,
				width = "full",
				tooltip = "Remaining daily fencing / laundry right to use is between 25% and 75%",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.ThieveryWarningColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.ThieveryWarningColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.ThieveryWarningColour)
				}
			},

			{
				type = "colorpicker",
				name = "Low Usage Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.ThieveryNormalColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.ThieveryNormalColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetThievery()
				RAEIH.FormatThievery()
				RAEIH.OrganizeThievery() end,
				width = "full",
				tooltip = "+75% of daily fencing / laundry right is still available to use",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.ThieveryNormalColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.ThieveryNormalColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.ThieveryNormalColour)
				}
			},

			{
				type = "colorpicker",
				name = "Gold Value Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.ThieveryGoldColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.ThieveryGoldColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetThievery()
				RAEIH.FormatThievery()
				RAEIH.OrganizeThievery() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.ThieveryGoldColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.ThieveryGoldColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.ThieveryGoldColour)
				}
			},

			{
				type = "slider",
				name = "Background Alpha",
				min = 0,
				max = 100,
				step = 10,
				getFunc = function() return RAEIH.SavedVars.ThieveryBA * 100 end,
				setFunc = function(value)
				RAEIH.SavedVars.ThieveryBA = value / 100
				RAEIH.SetThievery()
				RAEIH.FormatThievery()
				RAEIH.OrganizeThievery() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.ThieveryBA * 100,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Horizontal Position",
				getFunc = function() return RAEIH.SavedVars.ThieveryX end,
				setFunc = function(value)
				RAEIH.SavedVars.ThieveryX = value
				RAEIH_Thievery:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.ThieveryX, RAEIH.SavedVars.ThieveryY)
				RAEIH.SetThievery()
				RAEIH.FormatThievery()
				RAEIH.OrganizeThievery() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ThieveryX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Vertical Position",
				getFunc = function() return RAEIH.SavedVars.ThieveryY end,
				setFunc = function(value)
				RAEIH.SavedVars.ThieveryY = value
				RAEIH_Thievery:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.ThieveryX, RAEIH.SavedVars.ThieveryY)
				RAEIH.SetThievery()
				RAEIH.FormatThievery()
				RAEIH.OrganizeThievery() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ThieveryY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Horizantal Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.ThieveryIconX end,
				setFunc = function(value)
				RAEIH.SavedVars.ThieveryIconX = value
				RAEIH.SetThievery()
				RAEIH.FormatThievery()
				RAEIH.OrganizeThievery() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ThieveryIconX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Vertical Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.ThieveryIconY end,
				setFunc = function(value)
				RAEIH.SavedVars.ThieveryIconY = value
				RAEIH.SetThievery()
				RAEIH.FormatThievery()
				RAEIH.OrganizeThievery() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ThieveryIconY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			}
		}
	},

	-- BOUNTY
	{
		type = "submenu",
		name = "Bounty",

			controls = {
			{
				type = "description",
				title = "Bounty Acronyms",
				text = "BT: Bounty Timer, HE: Current Heat",
				width = "full"
			},
			{
				type = "checkbox",
				name = "Enable Bounty",
				getFunc = function() return RAEIH.SavedVars.ShowBounty end,
				setFunc = function(value)
				RAEIH.SavedVars.ShowBounty = value
				RAEIH_Bounty:SetHidden(not RAEIH.SavedVars.ShowBounty)
				RAEIH.SetBounty()
				RAEIH.FormatBounty()
				RAEIH.OrganizeBounty() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ShowBounty
			},

			{
				type = "dropdown",
				name = "Bounty Format",
				choices = {"Status (Bounty)/BT (HE)", "Status (Bounty) » BT", "Status (Bounty)"},
				getFunc = function() return RAEIH.SavedVars.BountyFormat end,
				setFunc = function(value)
				RAEIH.SavedVars.BountyFormat = value
				RAEIH.SetBounty()
				RAEIH.FormatBounty()
				RAEIH.OrganizeBounty() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.BountyFormat
			},

			{
				type = "dropdown",
				name = "Font Type",
				choices = LMP:List(LMP.MediaType.FONT),
				getFunc = function() return RAEIH.SavedVars.BountyFont end,
				setFunc = function(value)
				RAEIH.SavedVars.BountyFont = value
				RAEIH.SetBounty()
				RAEIH.FormatBounty()
				RAEIH.OrganizeBounty() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.BountyFont
			},

			{
				type = "dropdown",
				name = "Font Style",
				choices = {"Normal", "Outline", "Shadow", "Soft Shadow - Thick", "Soft Shadow - Thin", "Thick Outline"},
				getFunc = function() return RAEIH.SavedVars.BountyFontStyle end,
				setFunc = function(value)
				RAEIH.SavedVars.BountyFontStyle = value
				RAEIH.SetBounty()
				RAEIH.FormatBounty()
				RAEIH.OrganizeBounty() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.BountyFontStyle
			},

			{
				type = "slider",
				name = "Font Size",
				min = 8,
				max = 72,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.BountyFontSize end,
				setFunc = function(value)
				RAEIH.SavedVars.BountyFontSize = value
				RAEIH.SetBounty()
				RAEIH.FormatBounty()
				RAEIH.OrganizeBounty() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.BountyFontSize
			},

			{
				type = "dropdown",
				name = "Icon Size",
				choices = {"16", "24", "32", "40", "48", "56", "64"},
				getFunc = function() return RAEIH.SavedVars.BountyIconW end,
				setFunc = function(value)
				RAEIH.SavedVars.BountyIconW = value
				RAEIH.SavedVars.BountyIconH = value
				RAEIH_Bounty_Icon:SetDimensions(RAEIH.SavedVars.BountyIconW, RAEIH.SavedVars.BountyIconH)
				RAEIH.SetBounty()
				RAEIH.FormatBounty()
				RAEIH.OrganizeBounty() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.BountyIconW
			},

			{
				type = "colorpicker",
				name = "Default Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.BountyDefaultColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.BountyDefaultColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetBounty()
				RAEIH.FormatBounty()
				RAEIH.OrganizeBounty() end,
				width = "full",
				tooltip = "+75% Full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.BountyDefaultColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.BountyDefaultColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.BountyDefaultColour)
				}
			},

			{
				type = "colorpicker",
				name = "Fugitive Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.BountyAlertColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.BountyAlertColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetBounty()
				RAEIH.FormatBounty()
				RAEIH.OrganizeBounty() end,
				width = "full",
				-- tooltip = "",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.BountyAlertColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.BountyAlertColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.BountyAlertColour)
				}
			},

			{
				type = "colorpicker",
				name = "Notorious / Disreputable Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.BountyWarningColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.BountyWarningColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetBounty()
				RAEIH.FormatBounty()
				RAEIH.OrganizeBounty() end,
				width = "full",
				-- tooltip = "",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.BountyWarningColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.BountyWarningColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.BountyWarningColour)
				}
			},

			{
				type = "colorpicker",
				name = "Upstanding Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.BountyNormalColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.BountyNormalColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetBounty()
				RAEIH.FormatBounty()
				RAEIH.OrganizeBounty() end,
				width = "full",
				-- tooltip = "",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.BountyNormalColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.BountyNormalColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.BountyNormalColour)
				}
			},

			{
				type = "colorpicker",
				name = "Gold Value Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.BountyGoldColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.BountyGoldColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetThievery()
				RAEIH.FormatThievery()
				RAEIH.OrganizeThievery() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.BountyGoldColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.BountyGoldColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.BountyGoldColour)
				}
			},

			{
				type = "slider",
				name = "Background Alpha",
				min = 0,
				max = 100,
				step = 10,
				getFunc = function() return RAEIH.SavedVars.BountyBA * 100 end,
				setFunc = function(value)
				RAEIH.SavedVars.BountyBA = value / 100
				RAEIH.SetBounty()
				RAEIH.FormatBounty()
				RAEIH.OrganizeBounty() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.BountyBA * 100,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Horizontal Position",
				getFunc = function() return RAEIH.SavedVars.BountyX end,
				setFunc = function(value)
				RAEIH.SavedVars.BountyX = value
				RAEIH_Bounty:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.BountyX, RAEIH.SavedVars.BountyY)
				RAEIH.SetBounty()
				RAEIH.FormatBounty()
				RAEIH.OrganizeBounty() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.BountyX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Vertical Position",
				getFunc = function() return RAEIH.SavedVars.BountyY end,
				setFunc = function(value)
				RAEIH.SavedVars.BountyY = value
				RAEIH_Bounty:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.BountyX, RAEIH.SavedVars.BountyY)
				RAEIH.SetBounty()
				RAEIH.FormatBounty()
				RAEIH.OrganizeBounty() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.BountyY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Horizantal Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.BountyIconX end,
				setFunc = function(value)
				RAEIH.SavedVars.BountyIconX = value
				RAEIH.SetBounty()
				RAEIH.FormatBounty()
				RAEIH.OrganizeBounty() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.BountyIconX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Vertical Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.BountyIconY end,
				setFunc = function(value)
				RAEIH.SavedVars.BountyIconY = value
				RAEIH.SetBounty()
				RAEIH.FormatBounty()
				RAEIH.OrganizeBounty() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.BountyIconY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			}
		}
	},

	-- RIDING
	{
		type = "submenu",
		name = "Riding",

			controls = {
			{
				type = "checkbox",
				name = "Enable Riding Training Tracker",
				getFunc = function() return RAEIH.SavedVars.ShowRiding end,
				setFunc = function(value)
				RAEIH.SavedVars.ShowRiding = value
				RAEIH_Riding:SetHidden(not RAEIH.SavedVars.ShowRiding)
				RAEIH.SetRiding()
				RAEIH.FormatRiding()
				RAEIH.OrganizeRiding() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.ShowRiding
			},

			{
				type = "checkbox",
				name = "Show Weapons While Mounted",
				getFunc = function() return RAEIH.SavedVars.SWWM end,
				setFunc = function(value)
				RAEIH.SavedVars.SWWM = value end,
				width = "full",
				default = RAEIH.DefaultSavedVars.SWWM,
				tooltip = "If enabled, your weapons won't be hidden while you ride your mount. This feature will be effective even if you don't enable Riding Training Tracker"
			},

			{
				type = "dropdown",
				name = "Font Type",
				choices = LMP:List(LMP.MediaType.FONT),
				getFunc = function() return RAEIH.SavedVars.RidingFont end,
				setFunc = function(value)
				RAEIH.SavedVars.RidingFont = value
				RAEIH.SetRiding()
				RAEIH.FormatRiding()
				RAEIH.OrganizeRiding() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.RidingFont
			},

			{
				type = "dropdown",
				name = "Font Style",
				choices = {"Normal", "Outline", "Shadow", "Soft Shadow - Thick", "Soft Shadow - Thin", "Thick Outline"},
				getFunc = function() return RAEIH.SavedVars.RidingFontStyle end,
				setFunc = function(value)
				RAEIH.SavedVars.RidingFontStyle = value
				RAEIH.SetRiding()
				RAEIH.FormatRiding()
				RAEIH.OrganizeRiding() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.RidingFontStyle
			},

			{
				type = "slider",
				name = "Font Size",
				min = 8,
				max = 72,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.RidingFontSize end,
				setFunc = function(value)
				RAEIH.SavedVars.RidingFontSize = value
				RAEIH.SetRiding()
				RAEIH.FormatRiding()
				RAEIH.OrganizeRiding() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.RidingFontSize
			},

			{
				type = "dropdown",
				name = "Icon Size",
				choices = {"16", "24", "32", "40", "48", "56", "64"},
				getFunc = function() return RAEIH.SavedVars.RidingIconW end,
				setFunc = function(value)
				RAEIH.SavedVars.RidingIconW = value
				RAEIH.SavedVars.RidingIconH = value
				RAEIH_Riding_Icon:SetDimensions(RAEIH.SavedVars.RidingIconW, RAEIH.SavedVars.RidingIconH)
				RAEIH.SetRiding()
				RAEIH.FormatRiding()
				RAEIH.OrganizeRiding() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.RidingIconW
			},

			{
				type = "colorpicker",
				name = "Default Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.RidingDefaultColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.RidingDefaultColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetRiding()
				RAEIH.FormatRiding()
				RAEIH.OrganizeRiding() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.RidingDefaultColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.RidingDefaultColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.RidingDefaultColour)
				}
			},

			{
				type = "colorpicker",
				name = "Training Alert Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.RidingAlertColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.RidingAlertColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetRiding()
				RAEIH.FormatRiding()
				RAEIH.OrganizeRiding() end,
				width = "full",
				tooltip = "Training reset time is less than an hour or already waiting to train",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.RidingAlertColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.RidingAlertColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.RidingAlertColour)
				}
			},

			{
				type = "colorpicker",
				name = "Late Training Stage Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.RidingWarningColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.RidingWarningColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetRiding()
				RAEIH.FormatRiding()
				RAEIH.OrganizeRiding() end,
				width = "full",
				tooltip = "Soonest training time is between 1 and 5 hours",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.RidingWarningColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.RidingWarningColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.RidingWarningColour)
				}
			},

			{
				type = "colorpicker",
				name = "Early Training Stage Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.RidingNormalColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.RidingNormalColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetRiding()
				RAEIH.FormatRiding()
				RAEIH.OrganizeRiding() end,
				width = "full",
				tooltip = "Soonest training time is more than 5 hours",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.RidingNormalColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.RidingNormalColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.RidingNormalColour)
				}
			},

			{
				type = "slider",
				name = "Background Alpha",
				min = 0,
				max = 100,
				step = 10,
				getFunc = function() return RAEIH.SavedVars.RidingBA * 100 end,
				setFunc = function(value)
				RAEIH.SavedVars.RidingBA = value / 100
				RAEIH.SetRiding()
				RAEIH.FormatRiding()
				RAEIH.OrganizeRiding() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.RidingBA * 100,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Horizontal Position",
				getFunc = function() return RAEIH.SavedVars.RidingX end,
				setFunc = function(value)
				RAEIH.SavedVars.RidingX = value
				RAEIH_Riding:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.RidingX, RAEIH.SavedVars.RidingY)
				RAEIH.SetRiding()
				RAEIH.FormatRiding()
				RAEIH.OrganizeRiding() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.RidingX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Vertical Position",
				getFunc = function() return RAEIH.SavedVars.RidingY end,
				setFunc = function(value)
				RAEIH.SavedVars.RidingY = value
				RAEIH_Riding:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.RidingX, RAEIH.SavedVars.RidingY)
				RAEIH.SetRiding()
				RAEIH.FormatRiding()
				RAEIH.OrganizeRiding() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.RidingY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Horizantal Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.RidingIconX end,
				setFunc = function(value)
				RAEIH.SavedVars.RidingIconX = value
				RAEIH.SetRiding()
				RAEIH.FormatRiding()
				RAEIH.OrganizeRiding() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.RidingIconX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Vertical Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.RidingIconY end,
				setFunc = function(value)
				RAEIH.SavedVars.RidingIconY = value
				RAEIH.SetRiding()
				RAEIH.FormatRiding()
				RAEIH.OrganizeRiding() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.RidingIconY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			}
		}
	},

	-- BLACKSMITHING
	{
		type = "submenu",
		name = "Blacksmithing",

			controls = {
			{
				type = "description",
				title = "Blacksmithing Format",
				text = "BS (Capacity in Use / Max. Capacity) - Remaining Time for Nearest Research",
				width = "full"
			},

			{
				type = "checkbox",
				name = "Enable Blacksmithing",
				getFunc = function() return RAEIH.SavedVars.ShowBlacksmithing end,
				setFunc = function(value)
				RAEIH.SavedVars.ShowBlacksmithing = value
				RAEIH_Blacksmithing:SetHidden(not RAEIH.SavedVars.ShowBlacksmithing)
				RAEIH.SetBlacksmithing()
				RAEIH.FormatBlacksmithing()
				RAEIH.OrganizeBlacksmithing() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.ShowBlacksmithing
			},

			{
				type = "dropdown",
				name = "Font Type",
				choices = LMP:List(LMP.MediaType.FONT),
				getFunc = function() return RAEIH.SavedVars.BlacksmithingFont end,
				setFunc = function(value)
				RAEIH.SavedVars.BlacksmithingFont = value
				RAEIH.SetBlacksmithing()
				RAEIH.FormatBlacksmithing()
				RAEIH.OrganizeBlacksmithing() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.BlacksmithingFont
			},

			{
				type = "dropdown",
				name = "Font Style",
				choices = {"Normal", "Outline", "Shadow", "Soft Shadow - Thick", "Soft Shadow - Thin", "Thick Outline"},
				getFunc = function() return RAEIH.SavedVars.BlacksmithingFontStyle end,
				setFunc = function(value)
				RAEIH.SavedVars.BlacksmithingFontStyle = value
				RAEIH.SetBlacksmithing()
				RAEIH.FormatBlacksmithing()
				RAEIH.OrganizeBlacksmithing() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.BlacksmithingFontStyle
			},

			{
				type = "slider",
				name = "Font Size",
				min = 8,
				max = 72,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.BlacksmithingFontSize end,
				setFunc = function(value)
				RAEIH.SavedVars.BlacksmithingFontSize = value
				RAEIH.SetBlacksmithing()
				RAEIH.FormatBlacksmithing()
				RAEIH.OrganizeBlacksmithing() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.BlacksmithingFontSize
			},

			{
				type = "dropdown",
				name = "Icon Size",
				choices = {"16", "24", "32", "40", "48", "56", "64"},
				getFunc = function() return RAEIH.SavedVars.BlacksmithingIconW end,
				setFunc = function(value)
				RAEIH.SavedVars.BlacksmithingIconW = value
				RAEIH.SavedVars.BlacksmithingIconH = value
				RAEIH_Blacksmithing_Icon:SetDimensions(RAEIH.SavedVars.BlacksmithingIconW, RAEIH.SavedVars.BlacksmithingIconH)
				RAEIH.SetBlacksmithing()
				RAEIH.FormatBlacksmithing()
				RAEIH.OrganizeBlacksmithing() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.BlacksmithingIconW
			},

			{
				type = "colorpicker",
				name = "Default Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.BlacksmithingDefaultColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.BlacksmithingDefaultColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetBlacksmithing()
				RAEIH.FormatBlacksmithing()
				RAEIH.OrganizeBlacksmithing() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.BlacksmithingDefaultColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.BlacksmithingDefaultColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.BlacksmithingDefaultColour)
				}
			},

			{
				type = "colorpicker",
				name = "Alert Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.BlacksmithingAlertColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.BlacksmithingAlertColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetBlacksmithing()
				RAEIH.FormatBlacksmithing()
				RAEIH.OrganizeBlacksmithing() end,
				width = "full",
				tooltip = "Idle research capacity & Soonest research time is less than an hour",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.BlacksmithingAlertColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.BlacksmithingAlertColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.BlacksmithingAlertColour)
				}
			},

			{
				type = "colorpicker",
				name = "Warning Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.BlacksmithingWarningColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.BlacksmithingWarningColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetBlacksmithing()
				RAEIH.FormatBlacksmithing()
				RAEIH.OrganizeBlacksmithing() end,
				width = "full",
				tooltip = "Unutilized research capacity & Soonest research time is less than 48 hours",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.BlacksmithingWarningColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.BlacksmithingWarningColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.BlacksmithingWarningColour)
				}
			},

			{
				type = "colorpicker",
				name = "Normal Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.BlacksmithingNormalColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.BlacksmithingNormalColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetBlacksmithing()
				RAEIH.FormatBlacksmithing()
				RAEIH.OrganizeBlacksmithing() end,
				width = "full",
				tooltip = "Research in full capacity & Soonest research time is more than 1 day",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.BlacksmithingNormalColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.BlacksmithingNormalColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.BlacksmithingNormalColour)
				}
			},

			{
				type = "slider",
				name = "Background Alpha",
				min = 0,
				max = 100,
				step = 10,
				getFunc = function() return RAEIH.SavedVars.BlacksmithingBA * 100 end,
				setFunc = function(value)
				RAEIH.SavedVars.BlacksmithingBA = value / 100
				RAEIH.SetBlacksmithing()
				RAEIH.FormatBlacksmithing()
				RAEIH.OrganizeBlacksmithing() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.BlacksmithingBA * 100,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Horizontal Position",
				getFunc = function() return RAEIH.SavedVars.BlacksmithingX end,
				setFunc = function(value)
				RAEIH.SavedVars.BlacksmithingX = value
				RAEIH_Blacksmithing:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.BlacksmithingX, RAEIH.SavedVars.BlacksmithingY)
				RAEIH.SetBlacksmithing()
				RAEIH.FormatBlacksmithing()
				RAEIH.OrganizeBlacksmithing() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.BlacksmithingX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Vertical Position",
				getFunc = function() return RAEIH.SavedVars.BlacksmithingY end,
				setFunc = function(value)
				RAEIH.SavedVars.BlacksmithingY = value
				RAEIH_Blacksmithing:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.BlacksmithingX, RAEIH.SavedVars.BlacksmithingY)
				RAEIH.SetBlacksmithing()
				RAEIH.FormatBlacksmithing()
				RAEIH.OrganizeBlacksmithing() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.BlacksmithingY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Horizantal Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.BlacksmithingIconX end,
				setFunc = function(value)
				RAEIH.SavedVars.BlacksmithingIconX = value
				RAEIH.SetBlacksmithing()
				RAEIH.FormatBlacksmithing()
				RAEIH.OrganizeBlacksmithing() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.BlacksmithingIconX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Vertical Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.BlacksmithingIconY end,
				setFunc = function(value)
				RAEIH.SavedVars.BlacksmithingIconY = value
				RAEIH.SetBlacksmithing()
				RAEIH.FormatBlacksmithing()
				RAEIH.OrganizeBlacksmithing() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.BlacksmithingIconY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			}
		}
	},

	-- WOODWORKING
	{
		type = "submenu",
		name = "Woodworking",

			controls = {
			{
				type = "description",
				title = "Woodworking Research",
				text = "WW (Capacity in Use / Max. Capacity) - Remaining Time for Nearest Research",
				width = "full"
			},

			{
				type = "checkbox",
				name = "Enable Woodworking",
				getFunc = function() return RAEIH.SavedVars.ShowWoodworking end,
				setFunc = function(value)
				RAEIH.SavedVars.ShowWoodworking = value
				RAEIH_Woodworking:SetHidden(not RAEIH.SavedVars.ShowWoodworking)
				RAEIH.SetWoodworking()
				RAEIH.FormatWoodworking()
				RAEIH.OrganizeWoodworking() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.ShowWoodworking
			},

			{
				type = "dropdown",
				name = "Font Type",
				choices = LMP:List(LMP.MediaType.FONT),
				getFunc = function() return RAEIH.SavedVars.WoodworkingFont end,
				setFunc = function(value)
				RAEIH.SavedVars.WoodworkingFont = value
				RAEIH.SetWoodworking()
				RAEIH.FormatWoodworking()
				RAEIH.OrganizeWoodworking() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.WoodworkingFont
			},

			{
				type = "dropdown",
				name = "Font Style",
				choices = {"Normal", "Outline", "Shadow", "Soft Shadow - Thick", "Soft Shadow - Thin", "Thick Outline"},
				getFunc = function() return RAEIH.SavedVars.WoodworkingFontStyle end,
				setFunc = function(value)
				RAEIH.SavedVars.WoodworkingFontStyle = value
				RAEIH.SetWoodworking()
				RAEIH.FormatWoodworking()
				RAEIH.OrganizeWoodworking() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.WoodworkingFontStyle
			},

			{
				type = "slider",
				name = "Font Size",
				min = 8,
				max = 72,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.WoodworkingFontSize end,
				setFunc = function(value)
				RAEIH.SavedVars.WoodworkingFontSize = value
				RAEIH.SetWoodworking()
				RAEIH.FormatWoodworking()
				RAEIH.OrganizeWoodworking() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.WoodworkingFontSize
			},

			{
				type = "dropdown",
				name = "Icon Size",
				choices = {"16", "24", "32", "40", "48", "56", "64"},
				getFunc = function() return RAEIH.SavedVars.WoodworkingIconW end,
				setFunc = function(value)
				RAEIH.SavedVars.WoodworkingIconW = value
				RAEIH.SavedVars.WoodworkingIconH = value
				RAEIH_Woodworking_Icon:SetDimensions(RAEIH.SavedVars.WoodworkingIconW, RAEIH.SavedVars.WoodworkingIconH)
				RAEIH.SetWoodworking()
				RAEIH.FormatWoodworking()
				RAEIH.OrganizeWoodworking() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.WoodworkingIconW
			},

			{
				type = "colorpicker",
				name = "Default Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.WoodworkingDefaultColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.WoodworkingDefaultColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetWoodworking()
				RAEIH.FormatWoodworking()
				RAEIH.OrganizeWoodworking() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.WoodworkingDefaultColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.WoodworkingDefaultColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.WoodworkingDefaultColour)
				}
			},

			{
				type = "colorpicker",
				name = "Alert Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.WoodworkingAlertColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.WoodworkingAlertColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetWoodworking()
				RAEIH.FormatWoodworking()
				RAEIH.OrganizeWoodworking() end,
				width = "full",
				tooltip = "Idle research capacity & Soonest research time is less than an hour",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.WoodworkingAlertColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.WoodworkingAlertColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.WoodworkingAlertColour)
				}
			},

			{
				type = "colorpicker",
				name = "Warning Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.WoodworkingWarningColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.WoodworkingWarningColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetWoodworking()
				RAEIH.FormatWoodworking()
				RAEIH.OrganizeWoodworking() end,
				width = "full",
				tooltip = "Unutilized research capacity & Soonest research time is less than 48 hours",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.WoodworkingWarningColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.WoodworkingWarningColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.WoodworkingWarningColour)
				}
			},

			{
				type = "colorpicker",
				name = "Normal Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.WoodworkingNormalColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.WoodworkingNormalColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetWoodworking()
				RAEIH.FormatWoodworking()
				RAEIH.OrganizeWoodworking() end,
				width = "full",
				tooltip = "Research in full capacity & Soonest research time is more than 1 day",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.WoodworkingNormalColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.WoodworkingNormalColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.WoodworkingNormalColour)
				}
			},

			{
				type = "slider",
				name = "Background Alpha",
				min = 0,
				max = 100,
				step = 10,
				getFunc = function() return RAEIH.SavedVars.WoodworkingBA * 100 end,
				setFunc = function(value)
				RAEIH.SavedVars.WoodworkingBA = value / 100
				RAEIH.SetWoodworking()
				RAEIH.FormatWoodworking()
				RAEIH.OrganizeWoodworking() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.WoodworkingBA * 100,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Horizontal Position",
				getFunc = function() return RAEIH.SavedVars.WoodworkingX end,
				setFunc = function(value)
				RAEIH.SavedVars.WoodworkingX = value
				RAEIH_Woodworking:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.WoodworkingX, RAEIH.SavedVars.WoodworkingY)
				RAEIH.SetWoodworking()
				RAEIH.FormatWoodworking()
				RAEIH.OrganizeWoodworking() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.WoodworkingX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Vertical Position",
				getFunc = function() return RAEIH.SavedVars.WoodworkingY end,
				setFunc = function(value)
				RAEIH.SavedVars.WoodworkingY = value
				RAEIH_Woodworking:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.WoodworkingX, RAEIH.SavedVars.WoodworkingY)
				RAEIH.SetWoodworking()
				RAEIH.FormatWoodworking()
				RAEIH.OrganizeWoodworking() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.WoodworkingY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Horizantal Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.WoodworkingIconX end,
				setFunc = function(value)
				RAEIH.SavedVars.WoodworkingIconX = value
				RAEIH.SetWoodworking()
				RAEIH.FormatWoodworking()
				RAEIH.OrganizeWoodworking() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.WoodworkingIconX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Vertical Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.WoodworkingIconY end,
				setFunc = function(value)
				RAEIH.SavedVars.WoodworkingIconY = value
				RAEIH.SetWoodworking()
				RAEIH.FormatWoodworking()
				RAEIH.OrganizeWoodworking() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.WoodworkingIconY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			}
		}
	},

	-- CLOTHING
	{
		type = "submenu",
		name = "Clothing",

			controls = {
			{
				type = "description",
				title = "Clothing Research",
				text = "CL (Capacity in Use / Max. Capacity) - Remaining Time for Nearest Research",
				width = "full"
			},

			{
				type = "checkbox",
				name = "Enable Clothing",
				getFunc = function() return RAEIH.SavedVars.ShowClothing end,
				setFunc = function(value)
				RAEIH.SavedVars.ShowClothing = value
				RAEIH_Clothing:SetHidden(not RAEIH.SavedVars.ShowClothing)
				RAEIH.SetClothing()
				RAEIH.FormatClothing()
				RAEIH.OrganizeClothing() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.ShowClothing
			},

			{
				type = "dropdown",
				name = "Font Type",
				choices = LMP:List(LMP.MediaType.FONT),
				getFunc = function() return RAEIH.SavedVars.ClothingFont end,
				setFunc = function(value)
				RAEIH.SavedVars.ClothingFont = value
				RAEIH.SetClothing()
				RAEIH.FormatClothing()
				RAEIH.OrganizeClothing() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ClothingFont
			},

			{
				type = "dropdown",
				name = "Font Style",
				choices = {"Normal", "Outline", "Shadow", "Soft Shadow - Thick", "Soft Shadow - Thin", "Thick Outline"},
				getFunc = function() return RAEIH.SavedVars.ClothingFontStyle end,
				setFunc = function(value)
				RAEIH.SavedVars.ClothingFontStyle = value
				RAEIH.SetClothing()
				RAEIH.FormatClothing()
				RAEIH.OrganizeClothing() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ClothingFontStyle
			},

			{
				type = "slider",
				name = "Font Size",
				min = 8,
				max = 72,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.ClothingFontSize end,
				setFunc = function(value)
				RAEIH.SavedVars.ClothingFontSize = value
				RAEIH.SetClothing()
				RAEIH.FormatClothing()
				RAEIH.OrganizeClothing() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ClothingFontSize
			},

			{
				type = "dropdown",
				name = "Icon Size",
				choices = {"16", "24", "32", "40", "48", "56", "64"},
				getFunc = function() return RAEIH.SavedVars.ClothingIconW end,
				setFunc = function(value)
				RAEIH.SavedVars.ClothingIconW = value
				RAEIH.SavedVars.ClothingIconH = value
				RAEIH_Clothing_Icon:SetDimensions(RAEIH.SavedVars.ClothingIconW, RAEIH.SavedVars.ClothingIconH)
				RAEIH.SetClothing()
				RAEIH.FormatClothing()
				RAEIH.OrganizeClothing() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ClothingIconW
			},

			{
				type = "colorpicker",
				name = "Default Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.ClothingDefaultColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.ClothingDefaultColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetClothing()
				RAEIH.FormatClothing()
				RAEIH.OrganizeClothing() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.ClothingDefaultColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.ClothingDefaultColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.ClothingDefaultColour)
				}
			},

			{
				type = "colorpicker",
				name = "Alert Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.ClothingAlertColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.ClothingAlertColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetClothing()
				RAEIH.FormatClothing()
				RAEIH.OrganizeClothing() end,
				width = "full",
				tooltip = "Idle research capacity & Soonest research time is less than an hour",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.ClothingAlertColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.ClothingAlertColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.ClothingAlertColour)
				}
			},

			{
				type = "colorpicker",
				name = "Warning Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.ClothingWarningColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.ClothingWarningColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetClothing()
				RAEIH.FormatClothing()
				RAEIH.OrganizeClothing() end,
				width = "full",
				tooltip = "Unutilized research capacity & Soonest research time is less than 48 hours",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.ClothingWarningColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.ClothingWarningColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.ClothingWarningColour)
				}
			},

			{
				type = "colorpicker",
				name = "Normal Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.ClothingNormalColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.ClothingNormalColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetClothing()
				RAEIH.FormatClothing()
				RAEIH.OrganizeClothing() end,
				width = "full",
				tooltip = "Research in full capacity & Soonest research time is more than 1 day",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.ClothingNormalColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.ClothingNormalColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.ClothingNormalColour)
				}
			},

			{
				type = "slider",
				name = "Background Alpha",
				min = 0,
				max = 100,
				step = 10,
				getFunc = function() return RAEIH.SavedVars.ClothingBA * 100 end,
				setFunc = function(value)
				RAEIH.SavedVars.ClothingBA = value / 100
				RAEIH.SetClothing()
				RAEIH.FormatClothing()
				RAEIH.OrganizeClothing() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.ClothingBA * 100,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Horizontal Position",
				getFunc = function() return RAEIH.SavedVars.ClothingX end,
				setFunc = function(value)
				RAEIH.SavedVars.ClothingX = value
				RAEIH_Clothing:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.ClothingX, RAEIH.SavedVars.ClothingY)
				RAEIH.SetClothing()
				RAEIH.FormatClothing()
				RAEIH.OrganizeClothing() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ClothingX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Vertical Position",
				getFunc = function() return RAEIH.SavedVars.ClothingY end,
				setFunc = function(value)
				RAEIH.SavedVars.ClothingY = value
				RAEIH_Clothing:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.ClothingX, RAEIH.SavedVars.ClothingY)
				RAEIH.SetClothing()
				RAEIH.FormatClothing()
				RAEIH.OrganizeClothing() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ClothingY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Horizantal Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.ClothingIconX end,
				setFunc = function(value)
				RAEIH.SavedVars.ClothingIconX = value
				RAEIH.SetClothing()
				RAEIH.FormatClothing()
				RAEIH.OrganizeClothing() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ClothingIconX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Vertical Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.ClothingIconY end,
				setFunc = function(value)
				RAEIH.SavedVars.ClothingIconY = value
				RAEIH.SetClothing()
				RAEIH.FormatClothing()
				RAEIH.OrganizeClothing() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ClothingIconY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			}
		}
	},

	-- SOUL GEMS
	{
		type = "submenu",
		name = "Soul Gems",

			controls = {
			{
				type = "description",
				title = "Soul Gems Acronyms",
				text = "E: Empty",
				width = "full"
			},

			{
				type = "checkbox",
				name = "Enable Soul Gems",
				getFunc = function() return RAEIH.SavedVars.ShowSoulGems end,
				setFunc = function(value)
				RAEIH.SavedVars.ShowSoulGems = value
				RAEIH_SoulGems:SetHidden(not RAEIH.SavedVars.ShowSoulGems)
				RAEIH.SetSoulGems()
				RAEIH.FormatSoulGems()
				RAEIH.OrganizeSoulGems() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ShowSoulGems
			},

			{
				type = "dropdown",
				name = "Soul Gems Format",
				choices = {"Filled/Total (Empty)", "Filled/Total", "Empty/Total", "Empty/Filled"},
				getFunc = function() return RAEIH.SavedVars.SoulGemsFormat end,
				setFunc = function(value)
				RAEIH.SavedVars.SoulGemsFormat = value
				RAEIH.SetSoulGems()
				RAEIH.FormatSoulGems()
				RAEIH.OrganizeSoulGems() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.SoulGemsFormat
			},

			{
				type = "dropdown",
				name = "Font Type",
				choices = LMP:List(LMP.MediaType.FONT),
				getFunc = function() return RAEIH.SavedVars.SoulGemsFont end,
				setFunc = function(value)
				RAEIH.SavedVars.SoulGemsFont = value
				RAEIH.SetSoulGems()
				RAEIH.FormatSoulGems()
				RAEIH.OrganizeSoulGems() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.SoulGemsFont
			},

			{
				type = "dropdown",
				name = "Font Style",
				choices = {"Normal", "Outline", "Shadow", "Soft Shadow - Thick", "Soft Shadow - Thin", "Thick Outline"},
				getFunc = function() return RAEIH.SavedVars.SoulGemsFontStyle end,
				setFunc = function(value)
				RAEIH.SavedVars.SoulGemsFontStyle = value
				RAEIH.SetSoulGems()
				RAEIH.FormatSoulGems()
				RAEIH.OrganizeSoulGems() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.SoulGemsFontStyle
			},

			{
				type = "slider",
				name = "Font Size",
				min = 8,
				max = 72,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.SoulGemsFontSize end,
				setFunc = function(value)
				RAEIH.SavedVars.SoulGemsFontSize = value
				RAEIH.SetSoulGems()
				RAEIH.FormatSoulGems()
				RAEIH.OrganizeSoulGems() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.SoulGemsFontSize
			},

			{
				type = "dropdown",
				name = "Icon Size",
				choices = {"16", "24", "32", "40", "48", "56", "64"},
				getFunc = function() return RAEIH.SavedVars.SoulGemsIconW end,
				setFunc = function(value)
				RAEIH.SavedVars.SoulGemsIconW = value
				RAEIH.SavedVars.SoulGemsIconH = value
				RAEIH_SoulGems_Icon:SetDimensions(RAEIH.SavedVars.SoulGemsIconW, RAEIH.SavedVars.SoulGemsIconH)
				RAEIH.SetSoulGems()
				RAEIH.FormatSoulGems()
				RAEIH.OrganizeSoulGems() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.SoulGemsIconW
			},

			{
				type = "colorpicker",
				name = "Default Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.SoulGemsDefaultColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.SoulGemsDefaultColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetSoulGems()
				RAEIH.FormatSoulGems()
				RAEIH.OrganizeSoulGems() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.SoulGemsDefaultColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.SoulGemsDefaultColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.SoulGemsDefaultColour)
				}
			},

			{
				type = "colorpicker",
				name = "Zero Filled SG Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.SoulGemsAlertColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.SoulGemsAlertColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetSoulGems()
				RAEIH.FormatSoulGems()
				RAEIH.OrganizeSoulGems() end,
				width = "full",
				tooltip = "Filled Soul Gem number is 0",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.SoulGemsAlertColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.SoulGemsAlertColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.SoulGemsAlertColour)
				}
			},

			{
				type = "colorpicker",
				name = "Normal SG Stack Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.SoulGemsWarningColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.SoulGemsWarningColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetSoulGems()
				RAEIH.FormatSoulGems()
				RAEIH.OrganizeSoulGems() end,
				width = "full",
				tooltip = "There are some filled gems but empty gem number is greater than filled gems",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.SoulGemsWarningColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.SoulGemsWarningColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.SoulGemsWarningColour)
				}
			},

			{
				type = "colorpicker",
				name = "High SG Stack Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.SoulGemsNormalColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.SoulGemsNormalColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetSoulGems()
				RAEIH.FormatSoulGems()
				RAEIH.OrganizeSoulGems() end,
				width = "full",
				tooltip = "Filled gem number is more than empty gems",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.SoulGemsNormalColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.SoulGemsNormalColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.SoulGemsNormalColour)
				}
			},

			{
				type = "slider",
				name = "Background Alpha",
				min = 0,
				max = 100,
				step = 10,
				getFunc = function() return RAEIH.SavedVars.SoulGemsBA * 100 end,
				setFunc = function(value)
				RAEIH.SavedVars.SoulGemsBA = value / 100
				RAEIH.SetSoulGems()
				RAEIH.FormatSoulGems()
				RAEIH.OrganizeSoulGems() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.SoulGemsBA * 100,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Horizontal Position",
				getFunc = function() return RAEIH.SavedVars.SoulGemsX end,
				setFunc = function(value)
				RAEIH.SavedVars.SoulGemsX = value
				RAEIH_SoulGems:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.SoulGemsX, RAEIH.SavedVars.SoulGemsY)
				RAEIH.SetSoulGems()
				RAEIH.FormatSoulGems()
				RAEIH.OrganizeSoulGems() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.SoulGemsX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Vertical Position",
				getFunc = function() return RAEIH.SavedVars.SoulGemsY end,
				setFunc = function(value)
				RAEIH.SavedVars.SoulGemsY = value
				RAEIH_SoulGems:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.SoulGemsX, RAEIH.SavedVars.SoulGemsY)
				RAEIH.SetSoulGems()
				RAEIH.FormatSoulGems()
				RAEIH.OrganizeSoulGems() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.SoulGemsY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Horizantal Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.SoulGemsIconX end,
				setFunc = function(value)
				RAEIH.SavedVars.SoulGemsIconX = value
				RAEIH.SetSoulGems()
				RAEIH.FormatSoulGems()
				RAEIH.OrganizeSoulGems() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.SoulGemsIconX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Vertical Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.SoulGemsIconY end,
				setFunc = function(value)
				RAEIH.SavedVars.SoulGemsIconY = value
				RAEIH.SetSoulGems()
				RAEIH.FormatSoulGems()
				RAEIH.OrganizeSoulGems() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.SoulGemsIconY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			}
		}
	},

	-- WEAPON CHARGE
	{
		type = "submenu",
		name = "Weapon Charge",

			controls = {
			{
				type = "description",
				title = "Weapon Charge Acronyms",
				text = "MH: Mainhand, OH: Offhand\n*You need to enable Weapon Charge on Legatus or as a free module to use Auto Weapon Charge feature",
				width = "full"
			},

			{
				type = "checkbox",
				name = "Enable Weapon Charge",
				getFunc = function() return RAEIH.SavedVars.ShowWeaponCharge end,
				setFunc = function(value)
				RAEIH.SavedVars.ShowWeaponCharge = value
				RAEIH_WeaponCharge:SetHidden(not RAEIH.SavedVars.ShowWeaponCharge)
				RAEIH.SetWeaponCharge()
				RAEIH.FormatWeaponCharge()
				RAEIH.OrganizeWeaponCharge() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ShowWeaponCharge
			},

			{
				type = "dropdown",
				name = "Weapon Charge Format",
				choices = {"Current/Max (%)", "Current/Max", "% Only"},
				getFunc = function() return RAEIH.SavedVars.WeaponChargeFormat end,
				setFunc = function(value)
				RAEIH.SavedVars.WeaponChargeFormat = value
				RAEIH.SetWeaponCharge()
				RAEIH.FormatWeaponCharge()
				RAEIH.OrganizeWeaponCharge() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.WeaponChargeFormat
			},

			{
				type = "checkbox",
				name = "Enable Auto Weapon Charge",
				getFunc = function() return RAEIH.SavedVars.AutoChargeWeaponEnabled end,
				setFunc = function(value)
				RAEIH.SavedVars.AutoChargeWeaponEnabled = value
				RAEIH.SetWeaponCharge()
				RAEIH.FormatWeaponCharge()
				RAEIH.OrganizeWeaponCharge() 
				ReloadUI() end,
				width = "half",
				disabled = function() return not RAEIH.SavedVars.ShowWeaponCharge end,
				default = RAEIH.DefaultSavedVars.AutoChargeWeaponEnabled,
				warning = "UI will be reloaded!"
			},

			{
				type = "slider",
				name = "AWC Threshold as %",
				min = 1,
				max = 100,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.AutoChargeWeaponThreshold end,
				setFunc = function(value)
				RAEIH.SavedVars.AutoChargeWeaponThreshold = value
				RAEIH.SetWeaponCharge()
				RAEIH.FormatWeaponCharge()
				RAEIH.OrganizeWeaponCharge() end,
				width = "half",
				disabled = function() return not RAEIH.SavedVars.AutoChargeWeaponEnabled end,
				default = RAEIH.DefaultSavedVars.AutoChargeWeaponThreshold
			},

			{
				type = "dropdown",
				name = "Font Type",
				choices = LMP:List(LMP.MediaType.FONT),
				getFunc = function() return RAEIH.SavedVars.WeaponChargeFont end,
				setFunc = function(value)
				RAEIH.SavedVars.WeaponChargeFont = value
				RAEIH.SetWeaponCharge()
				RAEIH.FormatWeaponCharge()
				RAEIH.OrganizeWeaponCharge() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.WeaponChargeFont
			},

			{
				type = "dropdown",
				name = "Font Style",
				choices = {"Normal", "Outline", "Shadow", "Soft Shadow - Thick", "Soft Shadow - Thin", "Thick Outline"},
				getFunc = function() return RAEIH.SavedVars.WeaponChargeFontStyle end,
				setFunc = function(value)
				RAEIH.SavedVars.WeaponChargeFontStyle = value
				RAEIH.SetWeaponCharge()
				RAEIH.FormatWeaponCharge()
				RAEIH.OrganizeWeaponCharge() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.WeaponChargeFontStyle
			},

			{
				type = "slider",
				name = "Font Size",
				min = 8,
				max = 72,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.WeaponChargeFontSize end,
				setFunc = function(value)
				RAEIH.SavedVars.WeaponChargeFontSize = value
				RAEIH.SetWeaponCharge()
				RAEIH.FormatWeaponCharge()
				RAEIH.OrganizeWeaponCharge() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.WeaponChargeFontSize
			},

			{
				type = "dropdown",
				name = "Icon Size",
				choices = {"16", "24", "32", "40", "48", "56", "64"},
				getFunc = function() return RAEIH.SavedVars.WeaponChargeIconW end,
				setFunc = function(value)
				RAEIH.SavedVars.WeaponChargeIconW = value
				RAEIH.SavedVars.WeaponChargeIconH = value
				RAEIH_WeaponCharge_Icon:SetDimensions(RAEIH.SavedVars.WeaponChargeIconW, RAEIH.SavedVars.WeaponChargeIconH)
				RAEIH.SetWeaponCharge()
				RAEIH.FormatWeaponCharge()
				RAEIH.OrganizeWeaponCharge() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.WeaponChargeIconW
			},

			{
				type = "colorpicker",
				name = "Default Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.WeaponChargeDefaultColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.WeaponChargeDefaultColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetWeaponCharge()
				RAEIH.FormatWeaponCharge()
				RAEIH.OrganizeWeaponCharge() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.WeaponChargeDefaultColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.WeaponChargeDefaultColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.WeaponChargeDefaultColour)
				}
			},

			{
				type = "colorpicker",
				name = "Low Charge Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.WeaponChargeAlertColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.WeaponChargeAlertColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetWeaponCharge()
				RAEIH.FormatWeaponCharge()
				RAEIH.OrganizeWeaponCharge() end,
				width = "full",
				tooltip = "Weapon Charge is less than 25%",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.WeaponChargeAlertColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.WeaponChargeAlertColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.WeaponChargeAlertColour)
				}
			},

			{
				type = "colorpicker",
				name = "Medium Charge Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.WeaponChargeWarningColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.WeaponChargeWarningColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetWeaponCharge()
				RAEIH.FormatWeaponCharge()
				RAEIH.OrganizeWeaponCharge() end,
				width = "full",
				tooltip = "Weapon Charge ratio is between 25% and 75%",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.WeaponChargeWarningColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.WeaponChargeWarningColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.WeaponChargeWarningColour)
				}
			},

			{
				type = "colorpicker",
				name = "High Charge Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.WeaponChargeNormalColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.WeaponChargeNormalColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetWeaponCharge()
				RAEIH.FormatWeaponCharge()
				RAEIH.OrganizeWeaponCharge() end,
				width = "full",
				tooltip = "Weapon Charge is higher than 75%",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.WeaponChargeNormalColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.WeaponChargeNormalColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.WeaponChargeNormalColour)
				}
			},

			{
				type = "slider",
				name = "Background Alpha",
				min = 0,
				max = 100,
				step = 10,
				getFunc = function() return RAEIH.SavedVars.WeaponChargeBA * 100 end,
				setFunc = function(value)
				RAEIH.SavedVars.WeaponChargeBA = value / 100
				RAEIH.SetWeaponCharge()
				RAEIH.FormatWeaponCharge()
				RAEIH.OrganizeWeaponCharge() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.WeaponChargeBA * 100,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Horizontal Position",
				getFunc = function() return RAEIH.SavedVars.WeaponChargeX end,
				setFunc = function(value)
				RAEIH.SavedVars.WeaponChargeX = value
				RAEIH_WeaponCharge:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.WeaponChargeX, RAEIH.SavedVars.WeaponChargeY)
				RAEIH.SetWeaponCharge()
				RAEIH.FormatWeaponCharge()
				RAEIH.OrganizeWeaponCharge() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.WeaponChargeX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Vertical Position",
				getFunc = function() return RAEIH.SavedVars.WeaponChargeY end,
				setFunc = function(value)
				RAEIH.SavedVars.WeaponChargeY = value
				RAEIH_WeaponCharge:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.WeaponChargeX, RAEIH.SavedVars.WeaponChargeY)
				RAEIH.SetWeaponCharge()
				RAEIH.FormatWeaponCharge()
				RAEIH.OrganizeWeaponCharge() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.WeaponChargeY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Horizantal Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.WeaponChargeIconX end,
				setFunc = function(value)
				RAEIH.SavedVars.WeaponChargeIconX = value
				RAEIH.SetWeaponCharge()
				RAEIH.FormatWeaponCharge()
				RAEIH.OrganizeWeaponCharge() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.WeaponChargeIconX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Vertical Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.WeaponChargeIconY end,
				setFunc = function(value)
				RAEIH.SavedVars.WeaponChargeIconY = value
				RAEIH.SetWeaponCharge()
				RAEIH.FormatWeaponCharge()
				RAEIH.OrganizeWeaponCharge() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.WeaponChargeIconY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			}
		}
	},

	-- ATTRIBUTE POINTS
	{
		type = "submenu",
		name = "Attribute Points",

			controls = {
			{
				type = "description",
				title = "Attribute Pts. Acronyms",
				text = "U: Unspent Points",
				width = "full"
			},

			{
				type = "checkbox",
				name = "Enable Attribute Points",
				getFunc = function() return RAEIH.SavedVars.ShowAttributePoints end,
				setFunc = function(value)
				RAEIH.SavedVars.ShowAttributePoints = value
				RAEIH_AttributePoints:SetHidden(not RAEIH.SavedVars.ShowAttributePoints)
				RAEIH.SetAttributePoints()
				RAEIH.FormatAttributePoints()
				RAEIH.OrganizeAttributePoints() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ShowAttributePoints
			},

			{
				type = "dropdown",
				name = "Attribute Points Format",
				choices = {"Spent/Total (Unspent)", "Spent/Total", "Unspent/Total"},
				getFunc = function() return RAEIH.SavedVars.AttributePointsFormat end,
				setFunc = function(value)
				RAEIH.SavedVars.AttributePointsFormat = value
				RAEIH.SetAttributePoints()
				RAEIH.FormatAttributePoints()
				RAEIH.OrganizeAttributePoints() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.AttributePointsFormat
			},

			{
				type = "dropdown",
				name = "Font Type",
				choices = LMP:List(LMP.MediaType.FONT),
				getFunc = function() return RAEIH.SavedVars.AttributePointsFont end,
				setFunc = function(value)
				RAEIH.SavedVars.AttributePointsFont = value
				RAEIH.SetAttributePoints()
				RAEIH.FormatAttributePoints()
				RAEIH.OrganizeAttributePoints() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.AttributePointsFont
			},

			{
				type = "dropdown",
				name = "Font Style",
				choices = {"Normal", "Outline", "Shadow", "Soft Shadow - Thick", "Soft Shadow - Thin", "Thick Outline"},
				getFunc = function() return RAEIH.SavedVars.AttributePointsFontStyle end,
				setFunc = function(value)
				RAEIH.SavedVars.AttributePointsFontStyle = value
				RAEIH.SetAttributePoints()
				RAEIH.FormatAttributePoints()
				RAEIH.OrganizeAttributePoints() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.AttributePointsFontStyle
			},

			{
				type = "slider",
				name = "Font Size",
				min = 8,
				max = 72,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.AttributePointsFontSize end,
				setFunc = function(value)
				RAEIH.SavedVars.AttributePointsFontSize = value
				RAEIH.SetAttributePoints()
				RAEIH.FormatAttributePoints()
				RAEIH.OrganizeAttributePoints() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.AttributePointsFontSize
			},

			{
				type = "dropdown",
				name = "Icon Size",
				choices = {"16", "24", "32", "40", "48", "56", "64"},
				getFunc = function() return RAEIH.SavedVars.AttributePointsIconW end,
				setFunc = function(value)
				RAEIH.SavedVars.AttributePointsIconW = value
				RAEIH.SavedVars.AttributePointsIconH = value
				RAEIH_AttributePoints_Icon:SetDimensions(RAEIH.SavedVars.AttributePointsIconW, RAEIH.SavedVars.AttributePointsIconH)
				RAEIH.SetAttributePoints()
				RAEIH.FormatAttributePoints()
				RAEIH.OrganizeAttributePoints() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.AttributePointsIconW
			},

			{
				type = "colorpicker",
				name = "Default Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.AttributePointsDefaultColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.AttributePointsDefaultColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetAttributePoints()
				RAEIH.FormatAttributePoints()
				RAEIH.OrganizeAttributePoints() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.AttributePointsDefaultColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.AttributePointsDefaultColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.AttributePointsDefaultColour)
				}
			},

			{
				type = "colorpicker",
				name = "Unspent Points Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.AttributePointsAlertColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.AttributePointsAlertColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetAttributePoints()
				RAEIH.FormatAttributePoints()
				RAEIH.OrganizeAttributePoints() end,
				width = "full",
				tooltip = "There are some unspent points",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.AttributePointsAlertColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.AttributePointsAlertColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.AttributePointsAlertColour)
				}
			},

			{
				type = "colorpicker",
				name = "All Points Spent Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.AttributePointsNormalColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.AttributePointsNormalColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetAttributePoints()
				RAEIH.FormatAttributePoints()
				RAEIH.OrganizeAttributePoints() end,
				width = "full",
				tooltip = "There is no unspent points",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.AttributePointsNormalColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.AttributePointsNormalColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.AttributePointsNormalColour)
				}
			},

			{
				type = "slider",
				name = "Background Alpha",
				min = 0,
				max = 100,
				step = 10,
				getFunc = function() return RAEIH.SavedVars.AttributePointsBA * 100 end,
				setFunc = function(value)
				RAEIH.SavedVars.AttributePointsBA = value / 100
				RAEIH.SetAttributePoints()
				RAEIH.FormatAttributePoints()
				RAEIH.OrganizeAttributePoints() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.AttributePointsBA * 100,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Horizontal Position",
				getFunc = function() return RAEIH.SavedVars.AttributePointsX end,
				setFunc = function(value)
				RAEIH.SavedVars.AttributePointsX = value
				RAEIH_AttributePoints:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.AttributePointsX, RAEIH.SavedVars.AttributePointsY)
				RAEIH.SetAttributePoints()
				RAEIH.FormatAttributePoints()
				RAEIH.OrganizeAttributePoints() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.AttributePointsX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Vertical Position",
				getFunc = function() return RAEIH.SavedVars.AttributePointsY end,
				setFunc = function(value)
				RAEIH.SavedVars.AttributePointsY = value
				RAEIH_AttributePoints:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.AttributePointsX, RAEIH.SavedVars.AttributePointsY)
				RAEIH.SetAttributePoints()
				RAEIH.FormatAttributePoints()
				RAEIH.OrganizeAttributePoints() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.AttributePointsY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Horizantal Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.AttributePointsIconX end,
				setFunc = function(value)
				RAEIH.SavedVars.AttributePointsIconX = value
				RAEIH.SetAttributePoints()
				RAEIH.FormatAttributePoints()
				RAEIH.OrganizeAttributePoints() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.AttributePointsIconX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Vertical Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.AttributePointsIconY end,
				setFunc = function(value)
				RAEIH.SavedVars.AttributePointsIconY = value
				RAEIH.SetAttributePoints()
				RAEIH.FormatAttributePoints()
				RAEIH.OrganizeAttributePoints() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.AttributePointsIconY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			}
		}
	},

	-- SKYSHARDS
	{
		type = "submenu",
		name = "SkyShards",

			controls = {

			{
				type = "checkbox",
				name = "Enable SkyShards",
				getFunc = function() return RAEIH.SavedVars.ShowSkyShards end,
				setFunc = function(value)
				RAEIH.SavedVars.ShowSkyShards = value
				RAEIH_SkyShards:SetHidden(not RAEIH.SavedVars.ShowSkyShards)
				RAEIH.SetSkyShards()
				RAEIH.FormatSkyShards()
				RAEIH.OrganizeSkyShards() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.ShowSkyShards
			},

			{
				type = "dropdown",
				name = "Font Type",
				choices = LMP:List(LMP.MediaType.FONT),
				getFunc = function() return RAEIH.SavedVars.SkyShardsFont end,
				setFunc = function(value)
				RAEIH.SavedVars.SkyShardsFont = value
				RAEIH.SetSkyShards()
				RAEIH.FormatSkyShards()
				RAEIH.OrganizeSkyShards() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.SkyShardsFont
			},

			{
				type = "dropdown",
				name = "Font Style",
				choices = {"Normal", "Outline", "Shadow", "Soft Shadow - Thick", "Soft Shadow - Thin", "Thick Outline"},
				getFunc = function() return RAEIH.SavedVars.SkyShardsFontStyle end,
				setFunc = function(value)
				RAEIH.SavedVars.SkyShardsFontStyle = value
				RAEIH.SetSkyShards()
				RAEIH.FormatSkyShards()
				RAEIH.OrganizeSkyShards() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.SkyShardsFontStyle
			},

			{
				type = "slider",
				name = "Font Size",
				min = 8,
				max = 72,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.SkyShardsFontSize end,
				setFunc = function(value)
				RAEIH.SavedVars.SkyShardsFontSize = value
				RAEIH.SetSkyShards()
				RAEIH.FormatSkyShards()
				RAEIH.OrganizeSkyShards() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.SkyShardsFontSize
			},

			{
				type = "dropdown",
				name = "Icon Size",
				choices = {"16", "24", "32", "40", "48", "56", "64"},
				getFunc = function() return RAEIH.SavedVars.SkyShardsIconW end,
				setFunc = function(value)
				RAEIH.SavedVars.SkyShardsIconW = value
				RAEIH.SavedVars.SkyShardsIconH = value
				RAEIH_SkyShards_Icon:SetDimensions(RAEIH.SavedVars.SkyShardsIconW, RAEIH.SavedVars.SkyShardsIconH)
				RAEIH.SetSkyShards()
				RAEIH.FormatSkyShards()
				RAEIH.OrganizeSkyShards() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.SkyShardsIconW
			},

			{
				type = "colorpicker",
				name = "Default Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.SkyShardsDefaultColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.SkyShardsDefaultColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetSkyShards()
				RAEIH.FormatSkyShards()
				RAEIH.OrganizeSkyShards() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.SkyShardsDefaultColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.SkyShardsDefaultColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.SkyShardsDefaultColour)
				}
			},

			{
				type = "colorpicker",
				name = "Early Stage Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.SkyShardsAlertColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.SkyShardsAlertColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetSkyShards()
				RAEIH.FormatSkyShards()
				RAEIH.OrganizeSkyShards() end,
				width = "full",
				tooltip = "You don't have any SkyShard",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.SkyShardsAlertColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.SkyShardsAlertColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.SkyShardsAlertColour)
				}
			},

			{
				type = "colorpicker",
				name = "Mid-Stage Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.SkyShardsWarningColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.SkyShardsWarningColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetSkyShards()
				RAEIH.FormatSkyShards()
				RAEIH.OrganizeSkyShards() end,
				width = "full",
				tooltip = "You have 1 SkyShard",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.SkyShardsWarningColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.SkyShardsWarningColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.SkyShardsWarningColour)
				}
			},

			{
				type = "colorpicker",
				name = "Late Stage Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.SkyShardsNormalColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.SkyShardsNormalColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetSkyShards()
				RAEIH.FormatSkyShards()
				RAEIH.OrganizeSkyShards() end,
				width = "full",
				tooltip = "You have 2 SkyShards",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.SkyShardsNormalColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.SkyShardsNormalColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.SkyShardsNormalColour)
				}
			},

			{
				type = "slider",
				name = "Background Alpha",
				min = 0,
				max = 100,
				step = 10,
				getFunc = function() return RAEIH.SavedVars.SkyShardsBA * 100 end,
				setFunc = function(value)
				RAEIH.SavedVars.SkyShardsBA = value / 100
				RAEIH.SetSkyShards()
				RAEIH.FormatSkyShards()
				RAEIH.OrganizeSkyShards() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.SkyShardsBA * 100,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Horizontal Position",
				getFunc = function() return RAEIH.SavedVars.SkyShardsX end,
				setFunc = function(value)
				RAEIH.SavedVars.SkyShardsX = value
				RAEIH_SkyShards:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.SkyShardsX, RAEIH.SavedVars.SkyShardsY)
				RAEIH.SetSkyShards()
				RAEIH.FormatSkyShards()
				RAEIH.OrganizeSkyShards() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.SkyShardsX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Vertical Position",
				getFunc = function() return RAEIH.SavedVars.SkyShardsY end,
				setFunc = function(value)
				RAEIH.SavedVars.SkyShardsY = value
				RAEIH_SkyShards:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.SkyShardsX, RAEIH.SavedVars.SkyShardsY)
				RAEIH.SetSkyShards()
				RAEIH.FormatSkyShards()
				RAEIH.OrganizeSkyShards() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.SkyShardsY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Horizantal Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.SkyShardsIconX end,
				setFunc = function(value)
				RAEIH.SavedVars.SkyShardsIconX = value
				RAEIH.SetSkyShards()
				RAEIH.FormatSkyShards()
				RAEIH.OrganizeSkyShards() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.SkyShardsIconX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Vertical Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.SkyShardsIconY end,
				setFunc = function(value)
				RAEIH.SavedVars.SkyShardsIconY = value
				RAEIH.SetSkyShards()
				RAEIH.FormatSkyShards()
				RAEIH.OrganizeSkyShards() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.SkyShardsIconY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			}
		}
	},

	-- SKILL POINTS
	{
		type = "submenu",
		name = "Skill Points",

			controls = {
			{
				type = "description",
				title = "Skill Points Acronyms",
				text = "U: Unspent Points",
				width = "full"
			},

			{
				type = "checkbox",
				name = "Enable Skill Points",
				getFunc = function() return RAEIH.SavedVars.ShowSkillPoints end,
				setFunc = function(value)
				RAEIH.SavedVars.ShowSkillPoints = value
				RAEIH_SkillPoints:SetHidden(not RAEIH.SavedVars.ShowSkillPoints)
				RAEIH.SetSkillPoints()
				RAEIH.FormatSkillPoints()
				RAEIH.OrganizeSkillPoints() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ShowSkillPoints
			},

			{
				type = "dropdown",
				name = "Skill Points Format",
				choices = {"Spent/Total (Unspent)", "Spent/Total", "Unspent/Total"},
				getFunc = function() return RAEIH.SavedVars.SkillPointsFormat end,
				setFunc = function(value)
				RAEIH.SavedVars.SkillPointsFormat = value
				RAEIH.SetSkillPoints()
				RAEIH.FormatSkillPoints()
				RAEIH.OrganizeSkillPoints() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.SkillPointsFormat
			},

			{
				type = "dropdown",
				name = "Font Type",
				choices = LMP:List(LMP.MediaType.FONT),
				getFunc = function() return RAEIH.SavedVars.SkillPointsFont end,
				setFunc = function(value)
				RAEIH.SavedVars.SkillPointsFont = value
				RAEIH.SetSkillPoints()
				RAEIH.FormatSkillPoints()
				RAEIH.OrganizeSkillPoints() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.SkillPointsFont
			},

			{
				type = "dropdown",
				name = "Font Style",
				choices = {"Normal", "Outline", "Shadow", "Soft Shadow - Thick", "Soft Shadow - Thin", "Thick Outline"},
				getFunc = function() return RAEIH.SavedVars.SkillPointsFontStyle end,
				setFunc = function(value)
				RAEIH.SavedVars.SkillPointsFontStyle = value
				RAEIH.SetSkillPoints()
				RAEIH.FormatSkillPoints()
				RAEIH.OrganizeSkillPoints() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.SkillPointsFontStyle
			},

			{
				type = "slider",
				name = "Font Size",
				min = 8,
				max = 72,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.SkillPointsFontSize end,
				setFunc = function(value)
				RAEIH.SavedVars.SkillPointsFontSize = value
				RAEIH.SetSkillPoints()
				RAEIH.FormatSkillPoints()
				RAEIH.OrganizeSkillPoints() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.SkillPointsFontSize
			},

			{
				type = "dropdown",
				name = "Icon Size",
				choices = {"16", "24", "32", "40", "48", "56", "64"},
				getFunc = function() return RAEIH.SavedVars.SkillPointsIconW end,
				setFunc = function(value)
				RAEIH.SavedVars.SkillPointsIconW = value
				RAEIH.SavedVars.SkillPointsIconH = value
				RAEIH_SkillPoints_Icon:SetDimensions(RAEIH.SavedVars.SkillPointsIconW, RAEIH.SavedVars.SkillPointsIconH)
				RAEIH.SetSkillPoints()
				RAEIH.FormatSkillPoints()
				RAEIH.OrganizeSkillPoints() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.SkillPointsIconW
			},

			{
				type = "colorpicker",
				name = "Default Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.SkyShardsDefaultColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.SkyShardsDefaultColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetSkyShards()
				RAEIH.FormatSkyShards()
				RAEIH.OrganizeSkyShards() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.SkyShardsDefaultColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.SkyShardsDefaultColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.SkyShardsDefaultColour)
				}
			},

			{
				type = "colorpicker",
				name = "Unspent Points Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.SkyShardsAlertColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.SkyShardsAlertColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetSkyShards()
				RAEIH.FormatSkyShards()
				RAEIH.OrganizeSkyShards() end,
				width = "full",
				tooltip = "There are some unspent points",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.SkyShardsAlertColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.SkyShardsAlertColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.SkyShardsAlertColour)
				}
			},

			{
				type = "colorpicker",
				name = "All Points Spent Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.SkyShardsNormalColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.SkyShardsNormalColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetSkyShards()
				RAEIH.FormatSkyShards()
				RAEIH.OrganizeSkyShards() end,
				width = "full",
				tooltip = "There is no unspent points",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.SkyShardsNormalColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.SkyShardsNormalColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.SkyShardsNormalColour)
				}
			},

			{
				type = "slider",
				name = "Background Alpha",
				min = 0,
				max = 100,
				step = 10,
				getFunc = function() return RAEIH.SavedVars.SkillPointsBA * 100 end,
				setFunc = function(value)
				RAEIH.SavedVars.SkillPointsBA = value / 100
				RAEIH.SetSkillPoints()
				RAEIH.FormatSkillPoints()
				RAEIH.OrganizeSkillPoints() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.SkillPointsBA * 100,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Horizontal Position",
				getFunc = function() return RAEIH.SavedVars.SkillPointsX end,
				setFunc = function(value)
				RAEIH.SavedVars.SkillPointsX = value
				RAEIH_SkillPoints:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.SkillPointsX, RAEIH.SavedVars.SkillPointsY)
				RAEIH.SetSkillPoints()
				RAEIH.FormatSkillPoints()
				RAEIH.OrganizeSkillPoints() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.SkillPointsX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Vertical Position",
				getFunc = function() return RAEIH.SavedVars.SkillPointsY end,
				setFunc = function(value)
				RAEIH.SavedVars.SkillPointsY = value
				RAEIH_SkillPoints:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.SkillPointsX, RAEIH.SavedVars.SkillPointsY)
				RAEIH.SetSkillPoints()
				RAEIH.FormatSkillPoints()
				RAEIH.OrganizeSkillPoints() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.SkillPointsY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Horizantal Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.SkillPointsIconX end,
				setFunc = function(value)
				RAEIH.SavedVars.SkillPointsIconX = value
				RAEIH.SetSkillPoints()
				RAEIH.FormatSkillPoints()
				RAEIH.OrganizeSkillPoints() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.SkillPointsIconX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Vertical Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.SkillPointsIconY end,
				setFunc = function(value)
				RAEIH.SavedVars.SkillPointsIconY = value
				RAEIH.SetSkillPoints()
				RAEIH.FormatSkillPoints()
				RAEIH.OrganizeSkillPoints() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.SkillPointsIconY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			}
		}
	},

	-- CHAMPION XP
	{
		type = "submenu",
		name = "Champion XP & Enlightment",

			controls = {
			{
				type = "description",
				title = "Format Description",
				text = "CP: Earned or Unspent Points\nEnlightment » If you're in EN Mode, your current EN Pool will be shown after CXP value",
				width = "full"
			},


			{
				type = "checkbox",
				name = "Enable Champion XP",
				getFunc = function() return RAEIH.SavedVars.ShowChampionXP end,
				setFunc = function(value)
				RAEIH.SavedVars.ShowChampionXP = value
				RAEIH_ChampionXP:SetHidden(not RAEIH.SavedVars.ShowChampionXP)
				RAEIH.SetChampionXP()
				RAEIH.FormatChampionXP()
				RAEIH.OrganizeChampionXP() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.ShowChampionXP
			},

			{
				type = "dropdown",
				name = "Champion XP Format",
------------------------------------------------------------------------------------------------------------
--Psyche: Temporarily removed constellation group names from 'RAEIH_ChampionXP' module (causing errors).
------------------------------------------------------------------------------------------------------------
--				choices = {"CP » Current/Max (%) » Sign", "CP » Current/Max (%)", "(CP) Current/Max » Sign", "(CP) Current/Max", "CP » % » Sign", "CP » % Only"},
				choices = {"CP » Current/Max (%)", "(CP) Current/Max", "CP » %", "CP » % Only"},
------------------------------------------------------------------------------------------------------------
				getFunc = function() return RAEIH.SavedVars.ChampionXPFormat end,
				setFunc = function(value)
				RAEIH.SavedVars.ChampionXPFormat = value
				RAEIH.SetChampionXP()
				RAEIH.FormatChampionXP()
				RAEIH.OrganizeChampionXP()	end,
				width = "full",
				default = RAEIH.DefaultSavedVars.ChampionXPFormat
			},

			-- {
			-- 	type = "dropdown",
			-- 	name = "Enlightment Format",
			-- 	choices = {"(CP) Enl. Pool » Sign", "(CP) Enl. Pool", "Enl. Pool » Sign"},
			-- 	getFunc = function() return RAEIH.SavedVars.EnlightmentFormat end,
			-- 	setFunc = function(value)
			-- 	RAEIH.SavedVars.EnlightmentFormat = value
			-- 	RAEIH.SetChampionXP()
			-- 	RAEIH.FormatChampionXP()
			-- 	RAEIH.OrganizeChampionXP()	end,
			-- 	width = "half",
			-- 	default = RAEIH.DefaultSavedVars.EnlightmentFormat
			-- },

			{
				type = "dropdown",
				name = "Font Type",
				choices = LMP:List(LMP.MediaType.FONT),
				getFunc = function() return RAEIH.SavedVars.ChampionXPFont end,
				setFunc = function(value)
				RAEIH.SavedVars.ChampionXPFont = value
				RAEIH.SetChampionXP()
				RAEIH.FormatChampionXP()
				RAEIH.OrganizeChampionXP() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ChampionXPFont
			},

			{
				type = "dropdown",
				name = "Font Style",
				choices = {"Normal", "Outline", "Shadow", "Soft Shadow - Thick", "Soft Shadow - Thin", "Thick Outline"},
				getFunc = function() return RAEIH.SavedVars.ChampionXPFontStyle end,
				setFunc = function(value)
				RAEIH.SavedVars.ChampionXPFontStyle = value
				RAEIH.SetChampionXP()
				RAEIH.FormatChampionXP()
				RAEIH.OrganizeChampionXP() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ChampionXPFontStyle
			},

			{
				type = "slider",
				name = "Font Size",
				min = 8,
				max = 72,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.ChampionXPFontSize end,
				setFunc = function(value)
				RAEIH.SavedVars.ChampionXPFontSize = value
				RAEIH.SetChampionXP()
				RAEIH.FormatChampionXP()
				RAEIH.OrganizeChampionXP() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ChampionXPFontSize
			},

			{
				type = "dropdown",
				name = "Icon Size",
				choices = {"16", "24", "32", "40", "48", "56", "64"},
				getFunc = function() return RAEIH.SavedVars.ChampionXPIconW end,
				setFunc = function(value)
				RAEIH.SavedVars.ChampionXPIconW = value
				RAEIH.SavedVars.ChampionXPIconH = value
				RAEIH_ChampionXP_Icon:SetDimensions(RAEIH.SavedVars.ChampionXPIconW, RAEIH.SavedVars.ChampionXPIconH)
				RAEIH.SetChampionXP()
				RAEIH.FormatChampionXP()
				RAEIH.OrganizeChampionXP() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ChampionXPIconW
			},

			{
				type = "colorpicker",
				name = "Champion XP Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.ChampionXPDefaultColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.ChampionXPDefaultColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetChampionXP()
				RAEIH.FormatChampionXP()
				RAEIH.OrganizeChampionXP() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.ChampionXPDefaultColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.ChampionXPDefaultColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.ChampionXPDefaultColour)
				}
			},

			{
				type = "colorpicker",
				name = "Early Stage Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.ChampionXPESColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.ChampionXPESColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetChampionXP()
				RAEIH.FormatChampionXP()
				RAEIH.OrganizeChampionXP() end,
				width = "half",
				tooltip = "Less than 25% of total Champion XP gained",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.ChampionXPESColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.ChampionXPESColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.ChampionXPESColour)
				}
			},

			{
				type = "colorpicker",
				name = "Mid-Stage Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.ChampionXPMSColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.ChampionXPMSColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetChampionXP()
				RAEIH.FormatChampionXP()
				RAEIH.OrganizeChampionXP() end,
				width = "half",
				tooltip = "Current gained Champion XP is between 25% and 75%",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.ChampionXPMSColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.ChampionXPMSColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.ChampionXPMSColour)
				}
			},

			{
				type = "colorpicker",
				name = "Late Stage Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.ChampionXPLSColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.ChampionXPLSColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetChampionXP()
				RAEIH.FormatChampionXP()
				RAEIH.OrganizeChampionXP() end,
				width = "half",
				tooltip = "More than 75% Champion XP gained",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.ChampionXPLSColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.ChampionXPLSColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.ChampionXPLSColour)
				}
			},

			{
				type = "colorpicker",
				name = "Enlightment Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.ChampionXPENColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.ChampionXPENColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetChampionXP()
				RAEIH.FormatChampionXP()
				RAEIH.OrganizeChampionXP() end,
				width = "half",
				-- tooltip = "More than 75% Champion / Enlightment XP gained",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.ChampionXPENColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.ChampionXPENColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.ChampionXPENColour)
				}
			},

			{
				type = "slider",
				name = "Background Alpha",
				min = 0,
				max = 100,
				step = 10,
				getFunc = function() return RAEIH.SavedVars.ChampionXPBA * 100 end,
				setFunc = function(value)
				RAEIH.SavedVars.ChampionXPBA = value / 100
				RAEIH.SetChampionXP()
				RAEIH.FormatChampionXP()
				RAEIH.OrganizeChampionXP() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.ChampionXPBA * 100,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Horizontal Position",
				getFunc = function() return RAEIH.SavedVars.ChampionXPX end,
				setFunc = function(value)
				RAEIH.SavedVars.ChampionXPX = value
				RAEIH_ChampionXP:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.ChampionXPX, RAEIH.SavedVars.ChampionXPY)
				RAEIH.SetChampionXP()
				RAEIH.FormatChampionXP()
				RAEIH.OrganizeChampionXP() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ChampionXPX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Vertical Position",
				getFunc = function() return RAEIH.SavedVars.ChampionXPY end,
				setFunc = function(value)
				RAEIH.SavedVars.ChampionXPY = value
				RAEIH_ChampionXP:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.ChampionXPX, RAEIH.SavedVars.ChampionXPY)
				RAEIH.SetChampionXP()
				RAEIH.FormatChampionXP()
				RAEIH.OrganizeChampionXP() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ChampionXPY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Horizantal Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.ChampionXPIconX end,
				setFunc = function(value)
				RAEIH.SavedVars.ChampionXPIconX = value
				RAEIH.SetChampionXP()
				RAEIH.FormatChampionXP()
				RAEIH.OrganizeChampionXP() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ChampionXPIconX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Vertical Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.ChampionXPIconY end,
				setFunc = function(value)
				RAEIH.SavedVars.ChampionXPIconY = value
				RAEIH.SetChampionXP()
				RAEIH.FormatChampionXP()
				RAEIH.OrganizeChampionXP() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ChampionXPIconY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			}
		}
	},

	-- ALLIANCE POINTS
	{
		type = "submenu",
		name = "Alliance Points (AvA)",

			controls = {

			{
				type = "checkbox",
				name = "Enable Alliance Points",
				getFunc = function() return RAEIH.SavedVars.ShowAlliancePoints end,
				setFunc = function(value)
				RAEIH.SavedVars.ShowAlliancePoints = value
				RAEIH_AlliancePoints:SetHidden(not RAEIH.SavedVars.ShowAlliancePoints)
				RAEIH.SetAlliancePoints()
				RAEIH.FormatAlliancePoints()
				RAEIH.OrganizeAlliancePoints() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.ShowAlliancePoints
			},

			{
				type = "dropdown",
				name = "Font Type",
				choices = LMP:List(LMP.MediaType.FONT),
				getFunc = function() return RAEIH.SavedVars.AlliancePointsFont end,
				setFunc = function(value)
				RAEIH.SavedVars.AlliancePointsFont = value
				RAEIH.SetAlliancePoints()
				RAEIH.FormatAlliancePoints()
				RAEIH.OrganizeAlliancePoints() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.AlliancePointsFont
			},

			{
				type = "dropdown",
				name = "Font Style",
				choices = {"Normal", "Outline", "Shadow", "Soft Shadow - Thick", "Soft Shadow - Thin", "Thick Outline"},
				getFunc = function() return RAEIH.SavedVars.AlliancePointsFontStyle end,
				setFunc = function(value)
				RAEIH.SavedVars.AlliancePointsFontStyle = value
				RAEIH.SetAlliancePoints()
				RAEIH.FormatAlliancePoints()
				RAEIH.OrganizeAlliancePoints() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.AlliancePointsFontStyle
			},

			{
				type = "slider",
				name = "Font Size",
				min = 8,
				max = 72,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.AlliancePointsFontSize end,
				setFunc = function(value)
				RAEIH.SavedVars.AlliancePointsFontSize = value
				RAEIH.SetAlliancePoints()
				RAEIH.FormatAlliancePoints()
				RAEIH.OrganizeAlliancePoints() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.AlliancePointsFontSize
			},

			{
				type = "dropdown",
				name = "Icon Size",
				choices = {"16", "24", "32", "40", "48", "56", "64"},
				getFunc = function() return RAEIH.SavedVars.AlliancePointsIconW end,
				setFunc = function(value)
				RAEIH.SavedVars.AlliancePointsIconW = value
				RAEIH.SavedVars.AlliancePointsIconH = value
				RAEIH_AlliancePoints_Icon:SetDimensions(RAEIH.SavedVars.AlliancePointsIconW, RAEIH.SavedVars.AlliancePointsIconH)
				RAEIH.SetAlliancePoints()
				RAEIH.FormatAlliancePoints()
				RAEIH.OrganizeAlliancePoints() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.AlliancePointsIconW
			},

			{
				type = "colorpicker",
				name = "Alliance Points Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.AlliancePointsDefaultColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.AlliancePointsDefaultColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetSkyShards()
				RAEIH.FormatSkyShards()
				RAEIH.OrganizeSkyShards() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.AlliancePointsDefaultColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.AlliancePointsDefaultColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.AlliancePointsDefaultColour)
				}
			},

			{
				type = "slider",
				name = "Background Alpha",
				min = 0,
				max = 100,
				step = 10,
				getFunc = function() return RAEIH.SavedVars.AlliancePointsBA * 100 end,
				setFunc = function(value)
				RAEIH.SavedVars.AlliancePointsBA = value / 100
				RAEIH.SetAlliancePoints()
				RAEIH.FormatAlliancePoints()
				RAEIH.OrganizeAlliancePoints() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.AlliancePointsBA * 100,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Horizontal Position",
				getFunc = function() return RAEIH.SavedVars.AlliancePointsX end,
				setFunc = function(value)
				RAEIH.SavedVars.AlliancePointsX = value
				RAEIH_AlliancePoints:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.AlliancePointsX, RAEIH.SavedVars.AlliancePointsY)
				RAEIH.SetAlliancePoints()
				RAEIH.FormatAlliancePoints()
				RAEIH.OrganizeAlliancePoints() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.AlliancePointsX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Vertical Position",
				getFunc = function() return RAEIH.SavedVars.AlliancePointsY end,
				setFunc = function(value)
				RAEIH.SavedVars.AlliancePointsY = value
				RAEIH_AlliancePoints:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.AlliancePointsX, RAEIH.SavedVars.AlliancePointsY)
				RAEIH.SetAlliancePoints()
				RAEIH.FormatAlliancePoints()
				RAEIH.OrganizeAlliancePoints() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.AlliancePointsY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Horizantal Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.AlliancePointsIconX end,
				setFunc = function(value)
				RAEIH.SavedVars.AlliancePointsIconX = value
				RAEIH.SetAlliancePoints()
				RAEIH.FormatAlliancePoints()
				RAEIH.OrganizeAlliancePoints() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.AlliancePointsIconX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Vertical Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.AlliancePointsIconY end,
				setFunc = function(value)
				RAEIH.SavedVars.AlliancePointsIconY = value
				RAEIH.SetAlliancePoints()
				RAEIH.FormatAlliancePoints()
				RAEIH.OrganizeAlliancePoints() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.AlliancePointsIconY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			}
		}
	},

	-- AVA RANK
	{
		type = "submenu",
		name = "AvA Rank",

			controls = {
			{
				type = "checkbox",
				name = "Enable AvA Rank",
				getFunc = function() return RAEIH.SavedVars.ShowAvARank end,
				setFunc = function(value)
				if value == true and RAEIH.SavedVars.AvAAutoShow == true then
					RAEIH.SavedVars.AvAAutoShow = false
				end
				RAEIH.SavedVars.ShowAvARank = value
				RAEIH_AvARank:SetHidden(not RAEIH.SavedVars.ShowAvARank)
				RAEIH.SetAvARank()
				RAEIH.FormatAvARank()
				RAEIH.OrganizeAvARank() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.ShowAvARank
			},

			{
				type = "checkbox",
				name = "Enable Detailed Format",
				getFunc = function() return RAEIH.SavedVars.AvARankDetailed end,
				setFunc = function(value)
				if value == false then 
					RAEIH.SavedVars.AvAAutoShow = false
					RAEIH.SavedVars.ShowAvARank = true
				else
					RAEIH.SavedVars.ShowAvARank = true
				end
				RAEIH.SavedVars.AvARankDetailed = value
				RAEIH.SetAvARank()
				RAEIH.FormatAvARank()
				RAEIH.OrganizeAvARank() end,
				width = "half",
				tooltip = "Module will have multiple lines with some extended information",
				warning = "Don't enable this if it's already attached to Legatus bar!",
				default = RAEIH.DefaultSavedVars.AvARankDetailed
			},

			{
				type = "checkbox",
				name = "Auto-Enable in AvA World",
				getFunc = function() return RAEIH.SavedVars.AvAAutoShow end,
				setFunc = function(value)
				if value == false and RAEIH.SavedVars.ShowAvARank == false then
					RAEIH.SavedVars.ShowAvARank = true
					RAEIH_AvARank:SetHidden(false)
				end
				RAEIH.SavedVars.AvAAutoShow = value
				RAEIH.SetAvARank()
				RAEIH.FormatAvARank()
				RAEIH.OrganizeAvARank() end,
				width = "half",
				tooltip = "If enabled, AvA Rank module will be enabled when you enter Cyrodiil and disabled when you leave",
				disabled = function() return not RAEIH.SavedVars.AvARankDetailed end,
				default = RAEIH.DefaultSavedVars.AvAAutoShow
			},

			{
				type = "dropdown",
				name = "AvA Rank Format",
				choices = {"Rank » Current/Max (%)", "Current/Max (%)", "Current/Max", "Rank » %", "% Only"},
				getFunc = function() return RAEIH.SavedVars.AvARankFormat end,
				setFunc = function(value)
				RAEIH.SavedVars.AvARankFormat = value
				RAEIH.SetAvARank()
				RAEIH.FormatAvARank()
				RAEIH.OrganizeAvARank()	end,
				width = "full",
				tooltip = "Only matters if it's attached to Legatus or detailed format is disabled",
				disabled = function() return RAEIH.SavedVars.AvARankDetailed end,
				default = RAEIH.DefaultSavedVars.AvARankFormat
			},

			{
				type = "dropdown",
				name = "Font Type",
				choices = LMP:List(LMP.MediaType.FONT),
				getFunc = function() return RAEIH.SavedVars.AvARankFont end,
				setFunc = function(value)
				RAEIH.SavedVars.AvARankFont = value
				RAEIH.SetAvARank()
				RAEIH.FormatAvARank()
				RAEIH.OrganizeAvARank() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.AvARankFont
			},

			{
				type = "dropdown",
				name = "Font Style",
				choices = {"Normal", "Outline", "Shadow", "Soft Shadow - Thick", "Soft Shadow - Thin", "Thick Outline"},
				getFunc = function() return RAEIH.SavedVars.AvARankFontStyle end,
				setFunc = function(value)
				RAEIH.SavedVars.AvARankFontStyle = value
				RAEIH.SetAvARank()
				RAEIH.FormatAvARank()
				RAEIH.OrganizeAvARank() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.AvARankFontStyle
			},

			{
				type = "slider",
				name = "Font Size",
				min = 8,
				max = 72,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.AvARankFontSize end,
				setFunc = function(value)
				RAEIH.SavedVars.AvARankFontSize = value
				RAEIH.SetAvARank()
				RAEIH.FormatAvARank()
				RAEIH.OrganizeAvARank() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.AvARankFontSize
			},

			{
				type = "dropdown",
				name = "Icon Size",
				choices = {"16", "24", "32", "40", "48", "56", "64"},
				getFunc = function() return RAEIH.SavedVars.AvARankIconW end,
				setFunc = function(value)
				RAEIH.SavedVars.AvARankIconW = value
				RAEIH.SavedVars.AvARankIconH = value
				RAEIH_AvARank_Icon:SetDimensions(RAEIH.SavedVars.AvARankIconW, RAEIH.SavedVars.AvARankIconH)
				RAEIH.SetAvARank()
				RAEIH.FormatAvARank()
				RAEIH.OrganizeAvARank() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.AvARankIconW
			},

			{
				type = "colorpicker",
				name = "Default Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.AvARankDefaultColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.AvARankDefaultColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetAvARank()
				RAEIH.FormatAvARank()
				RAEIH.OrganizeAvARank() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.AvARankDefaultColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.AvARankDefaultColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.AvARankDefaultColour)
				}
			},

			{
				type = "colorpicker",
				name = "AvA Rank & Camp. Name Colours",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.AvARankColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.AvARankColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetAvARank()
				RAEIH.FormatAvARank()
				RAEIH.OrganizeAvARank() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.AvARankColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.AvARankColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.AvARankColour)
				}
			},

			{
				type = "colorpicker",
				name = "Alliance Points Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.AvARankAPColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.AvARankAPColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetAvARank()
				RAEIH.FormatAvARank()
				RAEIH.OrganizeAvARank() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.AvARankAPColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.AvARankAPColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.AvARankAPColour)
				}
			},

			{
				type = "colorpicker",
				name = "Early Stage Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.AvARankESColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.AvARankESColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetAvARank()
				RAEIH.FormatAvARank()
				RAEIH.OrganizeAvARank() end,
				width = "full",
				tooltip = "Less than 25% of total AvA Rank Points gained",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.AvARankESColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.AvARankESColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.AvARankESColour)
				}
			},

			{
				type = "colorpicker",
				name = "Mid-Stage Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.AvARankMSColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.AvARankMSColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetAvARank()
				RAEIH.FormatAvARank()
				RAEIH.OrganizeAvARank() end,
				width = "full",
				tooltip = "Current gained AvA Rank Point is between 25% and 75%",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.AvARankMSColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.AvARankMSColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.AvARankMSColour)
				}
			},

			{
				type = "colorpicker",
				name = "Late Stage Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.AvARankLSColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.AvARankLSColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetAvARank()
				RAEIH.FormatAvARank()
				RAEIH.OrganizeAvARank() end,
				width = "full",
				tooltip = "More than 75% AvA Rank Points gained",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.AvARankLSColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.AvARankLSColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.AvARankLSColour)
				}
			},			

			{
				type = "slider",
				name = "Background Alpha",
				min = 0,
				max = 100,
				step = 10,
				getFunc = function() return RAEIH.SavedVars.AvARankBA * 100 end,
				setFunc = function(value)
				RAEIH.SavedVars.AvARankBA = value / 100
				RAEIH.SetAvARank()
				RAEIH.FormatAvARank()
				RAEIH.OrganizeAvARank() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.AvARankBA * 100,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Horizontal Position",
				getFunc = function() return RAEIH.SavedVars.AvARankX end,
				setFunc = function(value)
				RAEIH.SavedVars.AvARankX = value
				RAEIH_AvARank:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.AvARankX, RAEIH.SavedVars.AvARankY)
				RAEIH.SetAvARank()
				RAEIH.FormatAvARank()
				RAEIH.OrganizeAvARank() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.AvARankX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Vertical Position",
				getFunc = function() return RAEIH.SavedVars.AvARankY end,
				setFunc = function(value)
				RAEIH.SavedVars.AvARankY = value
				RAEIH_AvARank:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.AvARankX, RAEIH.SavedVars.AvARankY)
				RAEIH.SetAvARank()
				RAEIH.FormatAvARank()
				RAEIH.OrganizeAvARank() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.AvARankY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Horizantal Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.AvARankIconX end,
				setFunc = function(value)
				RAEIH.SavedVars.AvARankIconX = value
				RAEIH.SetAvARank()
				RAEIH.FormatAvARank()
				RAEIH.OrganizeAvARank() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.AvARankIconX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Vertical Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.AvARankIconY end,
				setFunc = function(value)
				RAEIH.SavedVars.AvARankIconY = value
				RAEIH.SetAvARank()
				RAEIH.FormatAvARank()
				RAEIH.OrganizeAvARank() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.AvARankIconY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			}
		}
	},

	-- ACHIEVEMENT POINTS
	{
		type = "submenu",
		name = "Achievement Points",

			controls = {

			{
				type = "checkbox",
				name = "Enable Achievement Points",
				getFunc = function() return RAEIH.SavedVars.ShowAchievementPoints end,
				setFunc = function(value)
				RAEIH.SavedVars.ShowAchievementPoints = value
				RAEIH_AchievementPoints:SetHidden(not RAEIH.SavedVars.ShowAchievementPoints)
				RAEIH.SetAchievementPoints()
				RAEIH.FormatAchievementPoints()
				RAEIH.OrganizeAchievementPoints() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ShowAchievementPoints
			},

			{
				type = "dropdown",
				name = "Achievement Pts. Format",
				choices = {"Current/Max (%)", "Current/Max", "% Only"},
				getFunc = function() return RAEIH.SavedVars.AchievementPointsFormat end,
				setFunc = function(value)
				RAEIH.SavedVars.AchievementPointsFormat = value
				RAEIH.SetAchievementPoints()
				RAEIH.FormatAchievementPoints()
				RAEIH.OrganizeAchievementPoints() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.AchievementPointsFormat
			},

			{
				type = "dropdown",
				name = "Font Type",
				choices = LMP:List(LMP.MediaType.FONT),
				getFunc = function() return RAEIH.SavedVars.AchievementPointsFont end,
				setFunc = function(value)
				RAEIH.SavedVars.AchievementPointsFont = value
				RAEIH.SetAchievementPoints()
				RAEIH.FormatAchievementPoints()
				RAEIH.OrganizeAchievementPoints() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.AchievementPointsFont
			},

			{
				type = "dropdown",
				name = "Font Style",
				choices = {"Normal", "Outline", "Shadow", "Soft Shadow - Thick", "Soft Shadow - Thin", "Thick Outline"},
				getFunc = function() return RAEIH.SavedVars.AchievementPointsFontStyle end,
				setFunc = function(value)
				RAEIH.SavedVars.AchievementPointsFontStyle = value
				RAEIH.SetAchievementPoints()
				RAEIH.FormatAchievementPoints()
				RAEIH.OrganizeAchievementPoints() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.AchievementPointsFontStyle
			},

			{
				type = "slider",
				name = "Font Size",
				min = 8,
				max = 72,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.AchievementPointsFontSize end,
				setFunc = function(value)
				RAEIH.SavedVars.AchievementPointsFontSize = value
				RAEIH.SetAchievementPoints()
				RAEIH.FormatAchievementPoints()
				RAEIH.OrganizeAchievementPoints() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.AchievementPointsFontSize
			},

			{
				type = "dropdown",
				name = "Icon Size",
				choices = {"16", "24", "32", "40", "48", "56", "64"},
				getFunc = function() return RAEIH.SavedVars.AchievementPointsIconW end,
				setFunc = function(value)
				RAEIH.SavedVars.AchievementPointsIconW = value
				RAEIH.SavedVars.AchievementPointsIconH = value
				RAEIH.SetAchievementPoints()
				RAEIH.FormatAchievementPoints()
				RAEIH.OrganizeAchievementPoints() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.AchievementPointsIconW
			},

			{
				type = "colorpicker",
				name = "Default Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.AchievementPointsDefaultColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.AchievementPointsDefaultColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetAchievementPoints()
				RAEIH.FormatAchievementPoints()
				RAEIH.OrganizeAchievementPoints() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.AchievementPointsDefaultColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.AchievementPointsDefaultColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.AchievementPointsDefaultColour)
				}
			},

			{
				type = "colorpicker",
				name = "Early Stage Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.AchievementPointsAlertColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.AchievementPointsAlertColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetAchievementPoints()
				RAEIH.FormatAchievementPoints()
				RAEIH.OrganizeAchievementPoints() end,
				width = "full",
				tooltip = "Less than 25% of total achievements completed",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.AchievementPointsAlertColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.AchievementPointsAlertColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.AchievementPointsAlertColour)
				}
			},

			{
				type = "colorpicker",
				name = "Mid-Stage Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.AchievementPointsWarningColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.AchievementPointsWarningColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetAchievementPoints()
				RAEIH.FormatAchievementPoints()
				RAEIH.OrganizeAchievementPoints() end,
				width = "full",
				tooltip = "Achievement completion ratio is between 25% and 75%",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.AchievementPointsWarningColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.AchievementPointsWarningColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.AchievementPointsWarningColour)
				}
			},

			{
				type = "colorpicker",
				name = "Late Stage Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.AchievementPointsNormalColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.AchievementPointsNormalColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetAchievementPoints()
				RAEIH.FormatAchievementPoints()
				RAEIH.OrganizeAchievementPoints() end,
				width = "full",
				tooltip = "75% of total achievements completed",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.AchievementPointsNormalColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.AchievementPointsNormalColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.AchievementPointsNormalColour)
				}
			},

			{
				type = "slider",
				name = "Background Alpha",
				min = 0,
				max = 100,
				step = 10,
				getFunc = function() return RAEIH.SavedVars.AchievementPointsBA * 100 end,
				setFunc = function(value)
				RAEIH.SavedVars.AchievementPointsBA = value / 100
				RAEIH.SetAchievementPoints()
				RAEIH.FormatAchievementPoints()
				RAEIH.OrganizeAchievementPoints() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.AchievementPointsBA * 100,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Horizontal Position",
				getFunc = function() return RAEIH.SavedVars.AchievementPointsX end,
				setFunc = function(value)
				RAEIH.SavedVars.AchievementPointsX = value
				RAEIH_AchievementPoints:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.AchievementPointsX, RAEIH.SavedVars.AchievementPointsY)
				RAEIH.SetAchievementPoints()
				RAEIH.FormatAchievementPoints()
				RAEIH.OrganizeAchievementPoints() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.AchievementPointsX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Vertical Position",
				getFunc = function() return RAEIH.SavedVars.AchievementPointsY end,
				setFunc = function(value)
				RAEIH.SavedVars.AchievementPointsY = value
				RAEIH_AchievementPoints:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.AchievementPointsX, RAEIH.SavedVars.AchievementPointsY)
				RAEIH.SetAchievementPoints()
				RAEIH.FormatAchievementPoints()
				RAEIH.OrganizeAchievementPoints() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.AchievementPointsY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Horizantal Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.AchievementPointsIconX end,
				setFunc = function(value)
				RAEIH.SavedVars.AchievementPointsIconX = value
				RAEIH.SetAchievementPoints()
				RAEIH.FormatAchievementPoints()
				RAEIH.OrganizeAchievementPoints() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.AchievementPointsIconX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Vertical Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.AchievementPointsIconY end,
				setFunc = function(value)
				RAEIH.SavedVars.AchievementPointsIconY = value
				RAEIH.SetAchievementPoints()
				RAEIH.FormatAchievementPoints()
				RAEIH.OrganizeAchievementPoints() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.AchievementPointsIconY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			}
		}
	},

	-- FRIENDS
	{
		type = "submenu",
		name = "Friends",

			controls = {

			{
				type = "checkbox",
				name = "Enable Friends",
				getFunc = function() return RAEIH.SavedVars.ShowFriends end,
				setFunc = function(value)
				RAEIH.SavedVars.ShowFriends = value
				RAEIH_Friends:SetHidden(not RAEIH.SavedVars.ShowFriends)
				RAEIH.SetFriends()
				RAEIH.FormatFriends()
				RAEIH.OrganizeFriends() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ShowFriends
			},

			{
				type = "dropdown",
				name = "Friends Format",
				choices = {"Online/Total (Offline)", "Online/Total", "Online/Offline"},
				getFunc = function() return RAEIH.SavedVars.FriendsFormat end,
				setFunc = function(value)
				RAEIH.SavedVars.FriendsFormat = value
				RAEIH.SetFriends()
				RAEIH.FormatFriends()
				RAEIH.OrganizeFriends() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.FriendsFormat
			},

			{
				type = "dropdown",
				name = "Font Type",
				choices = LMP:List(LMP.MediaType.FONT),
				getFunc = function() return RAEIH.SavedVars.FriendsFont end,
				setFunc = function(value)
				RAEIH.SavedVars.FriendsFont = value
				RAEIH.SetFriends()
				RAEIH.FormatFriends()
				RAEIH.OrganizeFriends() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.FriendsFont
			},

			{
				type = "dropdown",
				name = "Font Style",
				choices = {"Normal", "Outline", "Shadow", "Soft Shadow - Thick", "Soft Shadow - Thin", "Thick Outline"},
				getFunc = function() return RAEIH.SavedVars.FriendsFontStyle end,
				setFunc = function(value)
				RAEIH.SavedVars.FriendsFontStyle = value
				RAEIH.SetFriends()
				RAEIH.FormatFriends()
				RAEIH.OrganizeFriends() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.FriendsFontStyle
			},

			{
				type = "slider",
				name = "Font Size",
				min = 8,
				max = 72,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.FriendsFontSize end,
				setFunc = function(value)
				RAEIH.SavedVars.FriendsFontSize = value
				RAEIH.SetFriends()
				RAEIH.FormatFriends()
				RAEIH.OrganizeFriends() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.FriendsFontSize
			},

			{
				type = "dropdown",
				name = "Icon Size",
				choices = {"16", "24", "32", "40", "48", "56", "64"},
				getFunc = function() return RAEIH.SavedVars.FriendsIconW end,
				setFunc = function(value)
				RAEIH.SavedVars.FriendsIconW = value
				RAEIH.SavedVars.FriendsIconH = value
				RAEIH_Friends_Icon:SetDimensions(RAEIH.SavedVars.FriendsIconW, RAEIH.SavedVars.FriendsIconH)
				RAEIH.SetFriends()
				RAEIH.FormatFriends()
				RAEIH.OrganizeFriends() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.FriendsIconW
			},

			{
				type = "colorpicker",
				name = "Default Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.FriendsDefaultColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.FriendsDefaultColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetFriends()
				RAEIH.FormatFriends()
				RAEIH.OrganizeFriends() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.FriendsDefaultColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.FriendsDefaultColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.FriendsDefaultColour)
				}
			},

			{
				type = "colorpicker",
				name = "No One Online",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.FriendsAlertColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.FriendsAlertColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetFriends()
				RAEIH.FormatFriends()
				RAEIH.OrganizeFriends() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.FriendsAlertColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.FriendsAlertColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.FriendsAlertColour)
				}
			},

			{
				type = "colorpicker",
				name = "Some People Online",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.FriendsWarningColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.FriendsWarningColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetFriends()
				RAEIH.FormatFriends()
				RAEIH.OrganizeFriends() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.FriendsWarningColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.FriendsWarningColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.FriendsWarningColour)
				}
			},

			{
				type = "colorpicker",
				name = "Everyone Online",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.FriendsNormalColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.FriendsNormalColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetFriends()
				RAEIH.FormatFriends()
				RAEIH.OrganizeFriends() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.FriendsNormalColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.FriendsNormalColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.FriendsNormalColour)
				}
			},

			{
				type = "slider",
				name = "Background Alpha",
				min = 0,
				max = 100,
				step = 10,
				getFunc = function() return RAEIH.SavedVars.FriendsBA * 100 end,
				setFunc = function(value)
				RAEIH.SavedVars.FriendsBA = value / 100
				RAEIH.SetFriends()
				RAEIH.FormatFriends()
				RAEIH.OrganizeFriends() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.FriendsBA * 100,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Horizontal Position",
				getFunc = function() return RAEIH.SavedVars.FriendsX end,
				setFunc = function(value)
				RAEIH.SavedVars.FriendsX = value
				RAEIH_Friends:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.FriendsX, RAEIH.SavedVars.FriendsY)
				RAEIH.SetFriends()
				RAEIH.FormatFriends()
				RAEIH.OrganizeFriends() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.FriendsX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Vertical Position",
				getFunc = function() return RAEIH.SavedVars.FriendsY end,
				setFunc = function(value)
				RAEIH.SavedVars.FriendsY = value
				RAEIH_Friends:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.FriendsX, RAEIH.SavedVars.FriendsY)
				RAEIH.SetFriends()
				RAEIH.FormatFriends()
				RAEIH.OrganizeFriends() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.FriendsY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Horizantal Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.FriendsIconX end,
				setFunc = function(value)
				RAEIH.SavedVars.FriendsIconX = value
				RAEIH.SetFriends()
				RAEIH.FormatFriends()
				RAEIH.OrganizeFriends() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.FriendsIconX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Vertical Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.FriendsIconY end,
				setFunc = function(value)
				RAEIH.SavedVars.FriendsIconY = value
				RAEIH.SetFriends()
				RAEIH.FormatFriends()
				RAEIH.OrganizeFriends() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.FriendsIconY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			}
		}
	},

	-- TIME PLAYED
	{
		type = "submenu",
		name = "Time Played",

			controls = {

			{
				type = "description",
				title = "Format",
				text = "Total Time Played (This Session Played)\nAPI returns this data and it's character specific",
				width = "full"
			},

			{
				type = "checkbox",
				name = "Enable Time Played",
				getFunc = function() return RAEIH.SavedVars.ShowTimePlayed end,
				setFunc = function(value)
				RAEIH.SavedVars.ShowTimePlayed = value
				RAEIH_TimePlayed:SetHidden(not RAEIH.SavedVars.ShowTimePlayed)
				RAEIH.SetTimePlayed()
				RAEIH.FormatTimePlayed()
				RAEIH.OrganizeTimePlayed() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.ShowTimePlayed
			},

			{
				type = "dropdown",
				name = "Font Type",
				choices = LMP:List(LMP.MediaType.FONT),
				getFunc = function() return RAEIH.SavedVars.TimePlayedFont end,
				setFunc = function(value)
				RAEIH.SavedVars.TimePlayedFont = value
				RAEIH.SetTimePlayed()
				RAEIH.FormatTimePlayed()
				RAEIH.OrganizeTimePlayed() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.TimePlayedFont
			},

			{
				type = "dropdown",
				name = "Font Style",
				choices = {"Normal", "Outline", "Shadow", "Soft Shadow - Thick", "Soft Shadow - Thin", "Thick Outline"},
				getFunc = function() return RAEIH.SavedVars.TimePlayedFontStyle end,
				setFunc = function(value)
				RAEIH.SavedVars.TimePlayedFontStyle = value
				RAEIH.SetTimePlayed()
				RAEIH.FormatTimePlayed()
				RAEIH.OrganizeTimePlayed() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.TimePlayedFontStyle
			},

			{
				type = "slider",
				name = "Font Size",
				min = 8,
				max = 72,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.TimePlayedFontSize end,
				setFunc = function(value)
				RAEIH.SavedVars.TimePlayedFontSize = value
				RAEIH.SetTimePlayed()
				RAEIH.FormatTimePlayed()
				RAEIH.OrganizeTimePlayed() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.TimePlayedFontSize
			},

			{
				type = "dropdown",
				name = "Icon Size",
				choices = {"16", "24", "32", "40", "48", "56", "64"},
				getFunc = function() return RAEIH.SavedVars.TimePlayedIconW end,
				setFunc = function(value)
				RAEIH.SavedVars.TimePlayedIconW = value
				RAEIH.SavedVars.TimePlayedIconH = value
				RAEIH_TimePlayed_Icon:SetDimensions(RAEIH.SavedVars.TimePlayedIconW, RAEIH.SavedVars.TimePlayedIconH)
				RAEIH.SetTimePlayed()
				RAEIH.FormatTimePlayed()
				RAEIH.OrganizeTimePlayed() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.TimePlayedIconW
			},

			{
				type = "colorpicker",
				name = "Default Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.TimePlayedDefaultColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.TimePlayedDefaultColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetTimePlayed()
				RAEIH.FormatTimePlayed()
				RAEIH.OrganizeTimePlayed() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.TimePlayedDefaultColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.TimePlayedDefaultColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.TimePlayedDefaultColour)
				}
			},

			{
				type = "colorpicker",
				name = "Value Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.TimePlayedNormalColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.TimePlayedNormalColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetTimePlayed()
				RAEIH.FormatTimePlayed()
				RAEIH.OrganizeTimePlayed() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.TimePlayedNormalColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.TimePlayedNormalColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.TimePlayedNormalColour)
				}
			},

			{
				type = "slider",
				name = "Background Alpha",
				min = 0,
				max = 100,
				step = 10,
				getFunc = function() return RAEIH.SavedVars.TimePlayedBA * 100 end,
				setFunc = function(value)
				RAEIH.SavedVars.TimePlayedBA = value / 100
				RAEIH.SetTimePlayed()
				RAEIH.FormatTimePlayed()
				RAEIH.OrganizeTimePlayed() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.TimePlayedBA * 100,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Horizontal Position",
				getFunc = function() return RAEIH.SavedVars.TimePlayedX end,
				setFunc = function(value)
				RAEIH.SavedVars.TimePlayedX = value
				RAEIH_TimePlayed:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.TimePlayedX, RAEIH.SavedVars.TimePlayedY)
				RAEIH.SetTimePlayed()
				RAEIH.FormatTimePlayed()
				RAEIH.OrganizeTimePlayed() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.TimePlayedX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Vertical Position",
				getFunc = function() return RAEIH.SavedVars.TimePlayedY end,
				setFunc = function(value)
				RAEIH.SavedVars.TimePlayedY = value
				RAEIH_TimePlayed:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.TimePlayedX, RAEIH.SavedVars.TimePlayedY)
				RAEIH.SetTimePlayed()
				RAEIH.FormatTimePlayed()
				RAEIH.OrganizeTimePlayed() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.TimePlayedY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Horizantal Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.TimePlayedIconX end,
				setFunc = function(value)
				RAEIH.SavedVars.TimePlayedIconX = value
				RAEIH.SetTimePlayed()
				RAEIH.FormatTimePlayed()
				RAEIH.OrganizeTimePlayed() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.TimePlayedIconX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Vertical Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.TimePlayedIconY end,
				setFunc = function(value)
				RAEIH.SavedVars.TimePlayedIconY = value
				RAEIH.SetTimePlayed()
				RAEIH.FormatTimePlayed()
				RAEIH.OrganizeTimePlayed() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.TimePlayedIconY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			}
		}
	},

	-- COMBAT STATE
	{
		type = "submenu",
		name = "Combat State",

			controls = {

			{
				type = "checkbox",
				name = "Enable Combat State",
				getFunc = function() return RAEIH.SavedVars.ShowCombatState end,
				setFunc = function(value)
				RAEIH.SavedVars.ShowCombatState = value
				RAEIH_CombatState:SetHidden(not RAEIH.SavedVars.ShowCombatState)
				RAEIH.SetCombatState()
				RAEIH.FormatCombatState()
				RAEIH.OrganizeCombatState() end,
				width = "full",				
				default = RAEIH.DefaultSavedVars.ShowCombatState
			},

			{
				type = "checkbox",
				name = "Enable Weapon Auto Sheat",
				getFunc = function() return RAEIH.SavedVars.AutoSheatWeapon end,
				setFunc = function(value)
				RAEIH.SavedVars.AutoSheatWeapon = value end,
				width = "half",
				tooltip = "Weapons will be sheated after leaving combat. You don't have to enable Combat State module to get it worked",
				default = RAEIH.DefaultSavedVars.AutoSheatWeapon
			},

			{
				type = "slider",
				name = "Time Before Auto-Sheat (Sec)",
				min = 1,
				max = 30,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.SheatTimer / 1000 end,
				setFunc = function(value) RAEIH.SavedVars.SheatTimer = value * 1000 end,
				width = "half",
				tooltip = "After leaving combat, character will wait X seconds to auto-sheat weapons",
				default = RAEIH.DefaultSavedVars.SheatTimer
			},

			{
				type = "checkbox",
				name = "Switch Compass Colour",
				getFunc = function() return RAEIH.SavedVars.SCCByCombat end,
				setFunc = function(value)
				RAEIH.SavedVars.SCCByCombat = value end,
				width = "half",
				tooltip = "Changes compass frame colour when in combat. You don't have to enable Combat State module to get it worked",
				default = RAEIH.DefaultSavedVars.SCCByCombat
			},

			{
				type = "colorpicker",
				name = "In-Combat Colour of Compass Frame",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.SCCInCombatColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.SCCInCombatColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetCombatState()
				RAEIH.FormatCombatState()
				RAEIH.OrganizeCombatState() end,
				width = "half",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.SCCInCombatColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.SCCInCombatColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.SCCInCombatColour)
				}
			},

			{
				type = "dropdown",
				name = "Font Type",
				choices = LMP:List(LMP.MediaType.FONT),
				getFunc = function() return RAEIH.SavedVars.CombatStateFont end,
				setFunc = function(value)
				RAEIH.SavedVars.CombatStateFont = value
				RAEIH.SetCombatState()
				RAEIH.FormatCombatState()
				RAEIH.OrganizeCombatState() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.CombatStateFont
			},

			{
				type = "dropdown",
				name = "Font Style",
				choices = {"Normal", "Outline", "Shadow", "Soft Shadow - Thick", "Soft Shadow - Thin", "Thick Outline"},
				getFunc = function() return RAEIH.SavedVars.CombatStateFontStyle end,
				setFunc = function(value)
				RAEIH.SavedVars.CombatStateFontStyle = value
				RAEIH.SetCombatState()
				RAEIH.FormatCombatState()
				RAEIH.OrganizeCombatState() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.CombatStateFontStyle
			},

			{
				type = "slider",
				name = "Font Size",
				min = 8,
				max = 72,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.CombatStateFontSize end,
				setFunc = function(value)
				RAEIH.SavedVars.CombatStateFontSize = value
				RAEIH.SetCombatState()
				RAEIH.FormatCombatState()
				RAEIH.OrganizeCombatState() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.CombatStateFontSize
			},

			{
				type = "dropdown",
				name = "Icon Size",
				choices = {"16", "24", "32", "40", "48", "56", "64"},
				getFunc = function() return RAEIH.SavedVars.CombatStateIconW end,
				setFunc = function(value)
				RAEIH.SavedVars.CombatStateIconW = value
				RAEIH.SavedVars.CombatStateIconH = value
				RAEIH_CombatState_Icon:SetDimensions(RAEIH.SavedVars.CombatStateIconW, RAEIH.SavedVars.CombatStateIconH)
				RAEIH.SetCombatState()
				RAEIH.FormatCombatState()
				RAEIH.OrganizeCombatState() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.CombatStateIconW
			},

			{
				type = "colorpicker",
				name = "In Combat Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.CombatStateAlertColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.CombatStateAlertColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetCombatState()
				RAEIH.FormatCombatState()
				RAEIH.OrganizeCombatState() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.CombatStateAlertColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.CombatStateAlertColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.CombatStateAlertColour)
				}
			},

			{
				type = "colorpicker",
				name = "Out-of-Combat Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.CombatStateNormalColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.CombatStateNormalColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetCombatState()
				RAEIH.FormatCombatState()
				RAEIH.OrganizeCombatState() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.CombatStateNormalColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.CombatStateNormalColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.CombatStateNormalColour)
				}
			},

			{
				type = "slider",
				name = "Background Alpha",
				min = 0,
				max = 100,
				step = 10,
				getFunc = function() return RAEIH.SavedVars.CombatStateBA * 100 end,
				setFunc = function(value)
				RAEIH.SavedVars.CombatStateBA = value / 100
				RAEIH.SetCombatState()
				RAEIH.FormatCombatState()
				RAEIH.OrganizeCombatState() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.CombatStateBA * 100,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Horizontal Position",
				getFunc = function() return RAEIH.SavedVars.CombatStateX end,
				setFunc = function(value)
				RAEIH.SavedVars.CombatStateX = value
				RAEIH_CombatState:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.CombatStateX, RAEIH.SavedVars.CombatStateY)
				RAEIH.SetCombatState()
				RAEIH.FormatCombatState()
				RAEIH.OrganizeCombatState() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.CombatStateX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Vertical Position",
				getFunc = function() return RAEIH.SavedVars.CombatStateY end,
				setFunc = function(value)
				RAEIH.SavedVars.CombatStateY = value
				RAEIH_CombatState:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.CombatStateX, RAEIH.SavedVars.CombatStateY)
				RAEIH.SetCombatState()
				RAEIH.FormatCombatState()
				RAEIH.OrganizeCombatState() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.CombatStateY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Horizantal Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.CombatStateIconX end,
				setFunc = function(value)
				RAEIH.SavedVars.CombatStateIconX = value
				RAEIH.SetCombatState()
				RAEIH.FormatCombatState()
				RAEIH.OrganizeCombatState() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.CombatStateIconX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Vertical Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.CombatStateIconY end,
				setFunc = function(value)
				RAEIH.SavedVars.CombatStateIconY = value
				RAEIH.SetCombatState()
				RAEIH.FormatCombatState()
				RAEIH.OrganizeCombatState() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.CombatStateIconY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			}
		}
	},

	-- VAMPIRISM
	{
		type = "submenu",
		name = "Vampirism",

			controls = {

			{
				type = "checkbox",
				name = "Enable Vampirism",
				getFunc = function() return RAEIH.SavedVars.ShowVampirism end,
				setFunc = function(value)
				RAEIH.SavedVars.ShowVampirism = value
				RAEIH_Vampirism:SetHidden(not RAEIH.SavedVars.ShowVampirism)
				RAEIH.SetVampirism()
				RAEIH.FormatVampirism()
				RAEIH.OrganizeVampirism()
				 end,
				width = "full",
				default = RAEIH.DefaultSavedVars.ShowVampirism
			},

			{
				type = "dropdown",
				name = "Font Type",
				choices = LMP:List(LMP.MediaType.FONT),
				getFunc = function() return RAEIH.SavedVars.VampirismFont end,
				setFunc = function(value)
				RAEIH.SavedVars.VampirismFont = value
				RAEIH.SetVampirism()
				RAEIH.FormatVampirism()
				RAEIH.OrganizeVampirism() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.VampirismFont
			},

			{
				type = "dropdown",
				name = "Font Style",
				choices = {"Normal", "Outline", "Shadow", "Soft Shadow - Thick", "Soft Shadow - Thin", "Thick Outline"},
				getFunc = function() return RAEIH.SavedVars.VampirismFontStyle end,
				setFunc = function(value)
				RAEIH.SavedVars.VampirismFontStyle = value
				RAEIH.SetVampirism()
				RAEIH.FormatVampirism()
				RAEIH.OrganizeVampirism() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.VampirismFontStyle
			},

			{
				type = "slider",
				name = "Font Size",
				min = 8,
				max = 72,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.VampirismFontSize end,
				setFunc = function(value)
				RAEIH.SavedVars.VampirismFontSize = value
				RAEIH.SetVampirism()
				RAEIH.FormatVampirism()
				RAEIH.OrganizeVampirism() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.VampirismFontSize
			},

			{
				type = "dropdown",
				name = "Icon Size",
				choices = {"16", "24", "32", "40", "48", "56", "64"},
				getFunc = function() return RAEIH.SavedVars.VampirismIconW end,
				setFunc = function(value)
				RAEIH.SavedVars.VampirismIconW = value
				RAEIH.SavedVars.VampirismIconH = value
				RAEIH_Vampirism_Icon:SetDimensions(RAEIH.SavedVars.VampirismIconW, RAEIH.SavedVars.VampirismIconH)
				RAEIH.SetVampirism()
				RAEIH.FormatVampirism()
				RAEIH.OrganizeVampirism() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.VampirismIconW
			},

			{
				type = "colorpicker",
				name = "Default Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.VampirismDefaultColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.VampirismDefaultColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetVampirism()
				RAEIH.FormatVampirism()
				RAEIH.OrganizeVampirism() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.VampirismDefaultColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.VampirismDefaultColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.VampirismDefaultColour)
				}
			},

			{
				type = "colorpicker",
				name = "Stage 4 Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.VampirismAlertColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.VampirismAlertColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetVampirism()
				RAEIH.FormatVampirism()
				RAEIH.OrganizeVampirism() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.VampirismAlertColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.VampirismAlertColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.VampirismAlertColour)
				}
			},

			{
				type = "colorpicker",
				name = "Stage 3 Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.VampirismWarningColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.VampirismWarningColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetVampirism()
				RAEIH.FormatVampirism()
				RAEIH.OrganizeVampirism() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.VampirismWarningColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.VampirismWarningColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.VampirismWarningColour)
				}
			},

			{
				type = "colorpicker",
				name = "Stage 2 Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.VampirismNormalColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.VampirismNormalColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetVampirism()
				RAEIH.FormatVampirism()
				RAEIH.OrganizeVampirism() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.VampirismNormalColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.VampirismNormalColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.VampirismNormalColour)
				}
			},

			{
				type = "slider",
				name = "Background Alpha",
				min = 0,
				max = 100,
				step = 10,
				getFunc = function() return RAEIH.SavedVars.VampirismBA * 100 end,
				setFunc = function(value)
				RAEIH.SavedVars.VampirismBA = value / 100
				RAEIH.SetVampirism()
				RAEIH.FormatVampirism()
				RAEIH.OrganizeVampirism() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.VampirismBA * 100,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Horizontal Position",
				getFunc = function() return RAEIH.SavedVars.VampirismX end,
				setFunc = function(value)
				RAEIH.SavedVars.VampirismX = value
				RAEIH_Vampirism:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.VampirismX, RAEIH.SavedVars.VampirismY)
				RAEIH.SetVampirism()
				RAEIH.FormatVampirism()
				RAEIH.OrganizeVampirism() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.VampirismX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Vertical Position",
				getFunc = function() return RAEIH.SavedVars.VampirismY end,
				setFunc = function(value)
				RAEIH.SavedVars.VampirismY = value
				RAEIH_Vampirism:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.VampirismX, RAEIH.SavedVars.VampirismY)
				RAEIH.SetVampirism()
				RAEIH.FormatVampirism()
				RAEIH.OrganizeVampirism() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.VampirismY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Horizantal Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.VampirismIconX end,
				setFunc = function(value)
				RAEIH.SavedVars.VampirismIconX = value
				RAEIH.SetVampirism()
				RAEIH.FormatVampirism()
				RAEIH.OrganizeVampirism() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.VampirismIconX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Vertical Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.VampirismIconY end,
				setFunc = function(value)
				RAEIH.SavedVars.VampirismIconY = value
				RAEIH.SetVampirism()
				RAEIH.FormatVampirism()
				RAEIH.OrganizeVampirism() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.VampirismIconY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			}
		}
	},

	-- LYCANTHROPY
	{
		type = "submenu",
		name = "Lycanthropy",

			controls = {

			{
				type = "checkbox",
				name = "Enable Lycanthropy",
				getFunc = function() return RAEIH.SavedVars.ShowLycanthropy end,
				setFunc = function(value)
				if value == true and RAEIH.SavedVars.AutoShowLycanthropy == true then
					RAEIH.SavedVars.AutoShowLycanthropy = false
					RAEIH_Lycanthropy:SetHidden(false)
				end
				RAEIH.SavedVars.ShowLycanthropy = value
				RAEIH_Lycanthropy:SetHidden(not RAEIH.SavedVars.ShowLycanthropy)
				RAEIH.SetLycanthropy()
				RAEIH.FormatLycanthropy()
				RAEIH.OrganizeLycanthropy()
				 end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ShowLycanthropy
			},

			{
				type = "checkbox",
				name = "Auto-Enable Lycanthropy",
				getFunc = function() return RAEIH.SavedVars.AutoShowLycanthropy end,
				setFunc = function(value)
				RAEIH.SavedVars.AutoShowLycanthropy = value
				if value == true then
					RAEIH.SavedVars.ShowLycanthropy = false
					RAEIH_Lycanthropy:SetHidden(true)
				end
				RAEIH.SetLycanthropy()
				RAEIH.FormatLycanthropy()
				RAEIH.OrganizeLycanthropy()
				 end,
				width = "half",
				tooltip = "Auto-Show Lycanthropy only while in Werewolf form",
				warning = "If It's on Legatus, remove it from there first!",
				default = RAEIH.DefaultSavedVars.AutoShowLycanthropy
			},

			{
				type = "dropdown",
				name = "Font Type",
				choices = LMP:List(LMP.MediaType.FONT),
				getFunc = function() return RAEIH.SavedVars.LycanthropyFont end,
				setFunc = function(value)
				RAEIH.SavedVars.LycanthropyFont = value
				RAEIH.SetLycanthropy()
				RAEIH.FormatLycanthropy()
				RAEIH.OrganizeLycanthropy() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.LycanthropyFont
			},

			{
				type = "dropdown",
				name = "Font Style",
				choices = {"Normal", "Outline", "Shadow", "Soft Shadow - Thick", "Soft Shadow - Thin", "Thick Outline"},
				getFunc = function() return RAEIH.SavedVars.LycanthropyFontStyle end,
				setFunc = function(value)
				RAEIH.SavedVars.LycanthropyFontStyle = value
				RAEIH.SetLycanthropy()
				RAEIH.FormatLycanthropy()
				RAEIH.OrganizeLycanthropy() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.LycanthropyFontStyle
			},

			{
				type = "slider",
				name = "Font Size",
				min = 8,
				max = 72,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.LycanthropyFontSize end,
				setFunc = function(value)
				RAEIH.SavedVars.LycanthropyFontSize = value
				RAEIH.SetLycanthropy()
				RAEIH.FormatLycanthropy()
				RAEIH.OrganizeLycanthropy() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.LycanthropyFontSize
			},

			{
				type = "dropdown",
				name = "Icon Size",
				choices = {"16", "24", "32", "40", "48", "56", "64"},
				getFunc = function() return RAEIH.SavedVars.LycanthropyIconW end,
				setFunc = function(value)
				RAEIH.SavedVars.LycanthropyIconW = value
				RAEIH.SavedVars.LycanthropyIconH = value
				RAEIH_Lycanthropy_Icon:SetDimensions(RAEIH.SavedVars.LycanthropyIconW, RAEIH.SavedVars.LycanthropyIconH)
				RAEIH.SetLycanthropy()
				RAEIH.FormatLycanthropy()
				RAEIH.OrganizeLycanthropy() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.LycanthropyIconW
			},

			{
				type = "colorpicker",
				name = "Default Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.LycanthropyDefaultColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.LycanthropyDefaultColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetLycanthropy()
				RAEIH.FormatLycanthropy()
				RAEIH.OrganizeLycanthropy() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.LycanthropyDefaultColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.LycanthropyDefaultColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.LycanthropyDefaultColour)
				}
			},

			{
				type = "colorpicker",
				name = "Late Stage",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.LycanthropyAlertColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.LycanthropyAlertColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetLycanthropy()
				RAEIH.FormatLycanthropy()
				RAEIH.OrganizeLycanthropy() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.LycanthropyAlertColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.LycanthropyAlertColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.LycanthropyAlertColour)
				}
			},

			{
				type = "colorpicker",
				name = "Mid-Stage",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.LycanthropyWarningColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.LycanthropyWarningColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetLycanthropy()
				RAEIH.FormatLycanthropy()
				RAEIH.OrganizeLycanthropy() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.LycanthropyWarningColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.LycanthropyWarningColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.LycanthropyWarningColour)
				}
			},

			{
				type = "colorpicker",
				name = "Early Stage",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.LycanthropyNormalColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.LycanthropyNormalColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetLycanthropy()
				RAEIH.FormatLycanthropy()
				RAEIH.OrganizeLycanthropy() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.LycanthropyNormalColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.LycanthropyNormalColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.LycanthropyNormalColour)
				}
			},

			{
				type = "slider",
				name = "Background Alpha",
				min = 0,
				max = 100,
				step = 10,
				getFunc = function() return RAEIH.SavedVars.LycanthropyBA * 100 end,
				setFunc = function(value)
				RAEIH.SavedVars.LycanthropyBA = value / 100
				RAEIH.SetLycanthropy()
				RAEIH.FormatLycanthropy()
				RAEIH.OrganizeLycanthropy() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.LycanthropyBA * 100,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Horizontal Position",
				getFunc = function() return RAEIH.SavedVars.LycanthropyX end,
				setFunc = function(value)
				RAEIH.SavedVars.LycanthropyX = value
				RAEIH_Lycanthropy:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.LycanthropyX, RAEIH.SavedVars.LycanthropyY)
				RAEIH.SetLycanthropy()
				RAEIH.FormatLycanthropy()
				RAEIH.OrganizeLycanthropy() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.LycanthropyX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Vertical Position",
				getFunc = function() return RAEIH.SavedVars.LycanthropyY end,
				setFunc = function(value)
				RAEIH.SavedVars.LycanthropyY = value
				RAEIH_Lycanthropy:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.LycanthropyX, RAEIH.SavedVars.LycanthropyY)
				RAEIH.SetLycanthropy()
				RAEIH.FormatLycanthropy()
				RAEIH.OrganizeLycanthropy() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.LycanthropyY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Horizantal Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.LycanthropyIconX end,
				setFunc = function(value)
				RAEIH.SavedVars.LycanthropyIconX = value
				RAEIH.SetLycanthropy()
				RAEIH.FormatLycanthropy()
				RAEIH.OrganizeLycanthropy() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.LycanthropyIconX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Vertical Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.LycanthropyIconY end,
				setFunc = function(value)
				RAEIH.SavedVars.LycanthropyIconY = value
				RAEIH.SetLycanthropy()
				RAEIH.FormatLycanthropy()
				RAEIH.OrganizeLycanthropy() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.LycanthropyIconY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			}
		}
	},

	-- CRAFTING XP
	{
		type = "submenu",
		name = "Crafting XP",

			controls = {

			{
				type = "checkbox",
				name = "Enable Crafting XP",
				getFunc = function() return RAEIH.SavedVars.ShowCraftingXP end,
				setFunc = function(value)
				RAEIH.SavedVars.ShowCraftingXP = value
				if value == true then
					RAEIH.SavedVars.AutoShowCraftingXP = false
					RAEIH_CraftingXP:SetHidden(false)
				else
					RAEIH_CraftingXP:SetHidden(true)
				end
				RAEIH.SetCraftingXP()
				RAEIH.FormatCraftingXP()
				RAEIH.OrganizeCraftingXP()
				 end,
				width = "half",
				tooltip = "General auto-hiding rules will be in effect",
				default = RAEIH.DefaultSavedVars.ShowCraftingXP
			},

			{
				type = "checkbox",
				name = "Auto-Enable Crafting XP",
				getFunc = function() return RAEIH.SavedVars.AutoShowCraftingXP end,
				setFunc = function(value)
				RAEIH.SavedVars.AutoShowCraftingXP = value
				if value == true then
					RAEIH.SavedVars.ShowCraftingXP = false
					RAEIH_CraftingXP:SetHidden(true)
				end
				RAEIH.SetCraftingXP()
				RAEIH.FormatCraftingXP()
				RAEIH.OrganizeCraftingXP()
				 end,
				width = "half",
				tooltip = "Auto-Show CraftingXP only while interacting with crafting stations",
				default = RAEIH.DefaultSavedVars.AutoShowCraftingXP
			},

			{
				type = "dropdown",
				name = "Font Type",
				choices = LMP:List(LMP.MediaType.FONT),
				getFunc = function() return RAEIH.SavedVars.CraftingXPFont end,
				setFunc = function(value)
				RAEIH.SavedVars.CraftingXPFont = value
				RAEIH.SetCraftingXP()
				RAEIH.FormatCraftingXP()
				RAEIH.OrganizeCraftingXP() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.CraftingXPFont
			},

			{
				type = "dropdown",
				name = "Font Style",
				choices = {"Normal", "Outline", "Shadow", "Soft Shadow - Thick", "Soft Shadow - Thin", "Thick Outline"},
				getFunc = function() return RAEIH.SavedVars.CraftingXPFontStyle end,
				setFunc = function(value)
				RAEIH.SavedVars.CraftingXPFontStyle = value
				RAEIH.SetCraftingXP()
				RAEIH.FormatCraftingXP()
				RAEIH.OrganizeCraftingXP() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.CraftingXPFontStyle
			},

			{
				type = "slider",
				name = "Font Size",
				min = 8,
				max = 72,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.CraftingXPFontSize end,
				setFunc = function(value)
				RAEIH.SavedVars.CraftingXPFontSize = value
				RAEIH.SetCraftingXP()
				RAEIH.FormatCraftingXP()
				RAEIH.OrganizeCraftingXP() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.CraftingXPFontSize
			},

			{
				type = "dropdown",
				name = "Icon Size",
				choices = {"16", "24", "32", "40", "48", "56", "64"},
				getFunc = function() return RAEIH.SavedVars.CraftingXPIconW end,
				setFunc = function(value)
				RAEIH.SavedVars.CraftingXPIconW = value
				RAEIH.SavedVars.CraftingXPIconH = value
				RAEIH_CraftingXP_Icon:SetDimensions(RAEIH.SavedVars.CraftingXPIconW, RAEIH.SavedVars.CraftingXPIconH)
				RAEIH.SetCraftingXP()
				RAEIH.FormatCraftingXP()
				RAEIH.OrganizeCraftingXP() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.CraftingXPIconW
			},

			{
				type = "colorpicker",
				name = "Default Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.CraftingXPDefaultColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.CraftingXPDefaultColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetCraftingXP()
				RAEIH.FormatCraftingXP()
				RAEIH.OrganizeCraftingXP() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.CraftingXPDefaultColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.CraftingXPDefaultColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.CraftingXPDefaultColour)
				}
			},

			{
				type = "colorpicker",
				name = "Value Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.CraftingXPValueColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.CraftingXPValueColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetCraftingXP()
				RAEIH.FormatCraftingXP()
				RAEIH.OrganizeCraftingXP() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.CraftingXPValueColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.CraftingXPValueColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.CraftingXPValueColour)
				}
			},

			{
				type = "slider",
				name = "Background Alpha",
				min = 0,
				max = 100,
				step = 10,
				getFunc = function() return RAEIH.SavedVars.CraftingXPBA * 100 end,
				setFunc = function(value)
				RAEIH.SavedVars.CraftingXPBA = value / 100
				RAEIH.SetCraftingXP()
				RAEIH.FormatCraftingXP()
				RAEIH.OrganizeCraftingXP() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.CraftingXPBA * 100,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Horizontal Position",
				getFunc = function() return RAEIH.SavedVars.CraftingXPX end,
				setFunc = function(value)
				RAEIH.SavedVars.CraftingXPX = value
				RAEIH_CraftingXP:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.CraftingXPX, RAEIH.SavedVars.CraftingXPY)
				RAEIH.SetCraftingXP()
				RAEIH.FormatCraftingXP()
				RAEIH.OrganizeCraftingXP() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.CraftingXPX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Vertical Position",
				getFunc = function() return RAEIH.SavedVars.CraftingXPY end,
				setFunc = function(value)
				RAEIH.SavedVars.CraftingXPY = value
				RAEIH_CraftingXP:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.CraftingXPX, RAEIH.SavedVars.CraftingXPY)
				RAEIH.SetCraftingXP()
				RAEIH.FormatCraftingXP()
				RAEIH.OrganizeCraftingXP() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.CraftingXPY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Horizantal Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.CraftingXPIconX end,
				setFunc = function(value)
				RAEIH.SavedVars.CraftingXPIconX = value
				RAEIH.SetCraftingXP()
				RAEIH.FormatCraftingXP()
				RAEIH.OrganizeCraftingXP() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.CraftingXPIconX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Vertical Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.CraftingXPIconY end,
				setFunc = function(value)
				RAEIH.SavedVars.CraftingXPIconY = value
				RAEIH.SetCraftingXP()
				RAEIH.FormatCraftingXP()
				RAEIH.OrganizeCraftingXP() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.CraftingXPIconY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			}
		}
	},

	-- NOTIFICATION
	{
		type = "submenu",
		name = "NOTIFICATION",

			controls = {

			{
				type = "checkbox",
				name = "Enable Notifications",
				getFunc = function() return RAEIH.SavedVars.ShowNotification end,
				setFunc = function(value)
				if value == false then
					RAEIH.SavedVars.NotificationWhisper = false
					RAEIH.SavedVars.NotificationRecharge = false
					RAEIH.SavedVars.NotificationDurability = false
				end
				RAEIH.SavedVars.ShowNotification = value
				RAEIH_Notification:SetHidden(not RAEIH.SavedVars.ShowNotification)
				RAEIH.SetNotification()
				RAEIH.FormatNotification()
				RAEIH.OrganizeNotification()
				end,
				width = "half",
				tooltip = "Notification module will flicker when there is an event for you to see",
				default = RAEIH.DefaultSavedVars.ShowNotification
			},

			{
				type = "slider",
				name = "Time Period",
				min = 3,
				max = 1800,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.IgnoreMSGSecond end,
				setFunc = function(value)
				RAEIH.SavedVars.IgnoreMSGSecond = value
				RAEIH.SetNotification()
				RAEIH.FormatNotification()
				RAEIH.OrganizeNotification() end,
				tooltip = "Notification will disappear after X seconds",
				width = "half",
				default = RAEIH.DefaultSavedVars.IgnoreMSGSecond
			},

			{
				type = "checkbox",
				name = "Whisper Notification",
				getFunc = function() return RAEIH.SavedVars.NotificationWhisper end,
				setFunc = function(value)
				RAEIH.SavedVars.NotificationWhisper = value
				RAEIH.SetNotification()
				RAEIH.FormatNotification()
				RAEIH.OrganizeNotification()
				end,
				width = "half",
				tooltip = "Module will let you know when you have a whisper",
				disabled = function() return not RAEIH.SavedVars.ShowNotification end,
				default = RAEIH.DefaultSavedVars.NotificationWhisper
			},

			{
				type = "checkbox",
				name = "Weapon Charge Notification",
				getFunc = function() return RAEIH.SavedVars.NotificationRecharge end,
				setFunc = function(value)
				RAEIH.SavedVars.NotificationRecharge = value
				RAEIH.SetNotification()
				RAEIH.FormatNotification()
				RAEIH.OrganizeNotification()
				end,
				width = "half",
				tooltip = "Module will let you know when one of your weapons recharged automatically",
				disabled = function() return not RAEIH.SavedVars.ShowNotification end,
				default = RAEIH.DefaultSavedVars.NotificationRecharge
			},

			{
				type = "checkbox",
				name = "Durability Notification",
				getFunc = function() return RAEIH.SavedVars.NotificationDurability end,
				setFunc = function(value)
				RAEIH.SavedVars.NotificationDurability = value
				RAEIH.SetNotification()
				RAEIH.FormatNotification()
				RAEIH.OrganizeNotification()
				end,
				width = "half",
				tooltip = "Module will let you know when your general durability is below 25%",
				disabled = function() return not RAEIH.SavedVars.ShowNotification end,
				default = RAEIH.DefaultSavedVars.NotificationDurability
			},

			{
				type = "dropdown",
				name = "Font Type",
				choices = LMP:List(LMP.MediaType.FONT),
				getFunc = function() return RAEIH.SavedVars.NotificationFont end,
				setFunc = function(value)
				RAEIH.SavedVars.NotificationFont = value
				RAEIH.SetNotification()
				RAEIH.FormatNotification()
				RAEIH.OrganizeNotification() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.NotificationFont
			},

			{
				type = "dropdown",
				name = "Font Style",
				choices = {"Normal", "Outline", "Shadow", "Soft Shadow - Thick", "Soft Shadow - Thin", "Thick Outline"},
				getFunc = function() return RAEIH.SavedVars.NotificationFontStyle end,
				setFunc = function(value)
				RAEIH.SavedVars.NotificationFontStyle = value
				RAEIH.SetNotification()
				RAEIH.FormatNotification()
				RAEIH.OrganizeNotification() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.NotificationFontStyle
			},

			{
				type = "slider",
				name = "Font Size",
				min = 8,
				max = 72,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.NotificationFontSize end,
				setFunc = function(value)
				RAEIH.SavedVars.NotificationFontSize = value
				RAEIH.SetNotification()
				RAEIH.FormatNotification()
				RAEIH.OrganizeNotification() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.NotificationFontSize
			},

			{
				type = "dropdown",
				name = "Icon Size",
				choices = {"16", "24", "32", "40", "48", "56", "64"},
				getFunc = function() return RAEIH.SavedVars.NotificationIconW end,
				setFunc = function(value)
				RAEIH.SavedVars.NotificationIconW = value
				RAEIH.SavedVars.NotificationIconH = value
				RAEIH_Notification_Icon:SetDimensions(RAEIH.SavedVars.NotificationIconW, RAEIH.SavedVars.NotificationIconH)
				RAEIH.SetNotification()
				RAEIH.FormatNotification()
				RAEIH.OrganizeNotification() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.NotificationIconW
			},

			{
				type = "colorpicker",
				name = "Default Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.NotificationDefaultColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.NotificationDefaultColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetNotification()
				RAEIH.FormatNotification()
				RAEIH.OrganizeNotification() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.NotificationDefaultColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.NotificationDefaultColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.NotificationDefaultColour)
				}
			},

			{
				type = "colorpicker",
				name = "Alert Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.NotificationAlertColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.NotificationAlertColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetNotification()
				RAEIH.FormatNotification()
				RAEIH.OrganizeNotification() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.NotificationAlertColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.NotificationAlertColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.NotificationAlertColour)
				}
			},

			{
				type = "colorpicker",
				name = "Warning Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.NotificationWarningColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.NotificationWarningColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetNotification()
				RAEIH.FormatNotification()
				RAEIH.OrganizeNotification() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.NotificationWarningColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.NotificationWarningColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.NotificationWarningColour)
				}
			},

			{
				type = "slider",
				name = "Background Alpha",
				min = 0,
				max = 100,
				step = 10,
				getFunc = function() return RAEIH.SavedVars.NotificationBA * 100 end,
				setFunc = function(value)
				RAEIH.SavedVars.NotificationBA = value / 100
				RAEIH.SetNotification()
				RAEIH.FormatNotification()
				RAEIH.OrganizeNotification() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.NotificationBA * 100,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Horizontal Position",
				getFunc = function() return RAEIH.SavedVars.NotificationX end,
				setFunc = function(value)
				RAEIH.SavedVars.NotificationX = value
				RAEIH_Notification:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.NotificationX, RAEIH.SavedVars.NotificationY)
				RAEIH.SetNotification()
				RAEIH.FormatNotification()
				RAEIH.OrganizeNotification() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.NotificationX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "editbox",
				name = "Vertical Position",
				getFunc = function() return RAEIH.SavedVars.NotificationY end,
				setFunc = function(value)
				RAEIH.SavedVars.NotificationY = value
				RAEIH_Notification:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.NotificationX, RAEIH.SavedVars.NotificationY)
				RAEIH.SetNotification()
				RAEIH.FormatNotification()
				RAEIH.OrganizeNotification() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.NotificationY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Horizantal Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.NotificationIconX end,
				setFunc = function(value)
				RAEIH.SavedVars.NotificationIconX = value
				RAEIH.SetNotification()
				RAEIH.FormatNotification()
				RAEIH.OrganizeNotification() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.NotificationIconX,
				warning = "It's not advised to change it if this module attached to the Legatus"
			},

			{
				type = "slider",
				name = "Icon Vertical Position",
				min = -80,
				max = 80,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.NotificationIconY end,
				setFunc = function(value)
				RAEIH.SavedVars.NotificationIconY = value
				RAEIH.SetNotification()
				RAEIH.FormatNotification()
				RAEIH.OrganizeNotification() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.NotificationIconY,
				warning = "It's not advised to change it if this module attached to the Legatus"
			}
		}
	},

	-- Extended Modules Description
	{
		type = "description",
		title = "\n»   EXTENDED MODULES",
		text = "Here you will find some extended modules that does more heavy work than normal modules and have much more info about specific subjects\"\n\n\n",
		width = "full"
	},

	-- CHAMBERLAIN
	{
		type = "submenu",
		name = "Chamberlain",

			controls = {

			{
				type = "description",
				title = "Description",
				text = "Chamberlain will keep records of some specific financial actions. Each day will have a separate record. So, too keep your saved variable file small, reset ledger time to time. Once a week or more for example.",
				width = "full"
			},

			{
				type = "checkbox",
				name = "Enable Chamberlain",
				getFunc = function() return RAEIH.SavedVars.EnableChamberlain end,
				setFunc = function(value)
				RAEIH.SavedVars.EnableChamberlain = value
				if value == true and RAEIH_Chamberlain == nil then
					RAEIH.CreateChamberlain()
					RAEIH.OrganizeChamberlain()
					RAEIH.FormatChamberlain()
					RAEIH.SetChamberlain()												
				elseif value == false and RAEIH_Chamberlain ~= nil then
					RAEIH_Chamberlain:SetHidden(true)
				elseif value == true and RAEIH_Chamberlain ~= nil then
					RAEIH.SetChamberlain()
					RAEIH_Chamberlain:SetHidden(false)
				end	end,
				width = "half",
				tooltip = "Chamberlain will record financial movements as long as it's enabled. Being hidden doesn't stop it",				
				default = RAEIH.DefaultSavedVars.EnableChamberlain
			},

			{
				type = "dropdown",
				name = "Panel Format",
				choices = {"Extended", "Summary"},
				getFunc = function() return RAEIH.SavedVars.ChamberlainFormat end,
				setFunc = function(value) RAEIH.ChamberlainFormatChange(value) end,
				width = "half",
				tooltip = "While Extended mode shows whole details, Summary mode will hide Income and Expense panels",
				disabled = function() return not RAEIH.SavedVars.EnableChamberlain end,
				default = RAEIH.DefaultSavedVars.ChamberlainFormat
			},

			{
				type = "checkbox",
				name = "Use Legatus Auto-Hide Rules",
				getFunc = function() return RAEIH.SavedVars.ChamberlainUseAHRules end,
				setFunc = function(value)
				RAEIH.SavedVars.ChamberlainUseAHRules = value end,
				width = "half",				
				default = RAEIH.DefaultSavedVars.ChamberlainUseAHRules
			},

			{
				type = "button",
				name = "Reset Ledger",
				func = function(value)
				RAEIH.SavedVars.ChamberlainLedger = {} 
				ReloadUI() end,
				warning = "Whole data will be erased for this character and UI will be reloaded!",
				disabled = function() return not RAEIH.SavedVars.EnableChamberlain end,
				width = "half"
			},

			{
				type = "dropdown",
				name = "Font Type",
				choices = LMP:List(LMP.MediaType.FONT),
				getFunc = function() return RAEIH.SavedVars.ChamberlainFont end,
				setFunc = function(value)
				RAEIH.SavedVars.ChamberlainFont = value
				RAEIH.SetChamberlain()
				RAEIH.FormatChamberlain()
				RAEIH.OrganizeChamberlain() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ChamberlainFont
			},

			{
				type = "dropdown",
				name = "Font Style",
				choices = {"Normal", "Outline", "Shadow", "Soft Shadow - Thick", "Soft Shadow - Thin", "Thick Outline"},
				getFunc = function() return RAEIH.SavedVars.ChamberlainFontStyle end,
				setFunc = function(value)
				RAEIH.SavedVars.ChamberlainFontStyle = value
				RAEIH.SetChamberlain()
				RAEIH.FormatChamberlain()
				RAEIH.OrganizeChamberlain() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ChamberlainFontStyle
			},

			{
				type = "slider",
				name = "Font Size",
				min = 8,
				max = 72,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.ChamberlainFontSize end,
				setFunc = function(value)
				RAEIH.SavedVars.ChamberlainFontSize = value
				RAEIH.SetChamberlain()
				RAEIH.FormatChamberlain()
				RAEIH.OrganizeChamberlain() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ChamberlainFontSize
			},

			{
				type = "slider",
				name = "Background Alpha",
				min = 0,
				max = 100,
				step = 10,
				getFunc = function() return RAEIH.SavedVars.ChamberlainBA * 100 end,
				setFunc = function(value)
				RAEIH.SavedVars.ChamberlainBA = value / 100
				RAEIH.SetChamberlain()
				RAEIH.FormatChamberlain()
				RAEIH.OrganizeChamberlain() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ChamberlainBA * 100
			},

			{
				type = "colorpicker",
				name = "Income/Profit Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.ChamberlainNormalColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.ChamberlainNormalColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetChamberlain()
				RAEIH.FormatChamberlain()
				RAEIH.OrganizeChamberlain() end,
				width = "half",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.ChamberlainNormalColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.ChamberlainNormalColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.ChamberlainNormalColour)
				}
			},

			{
				type = "colorpicker",
				name = "Expense/Loss Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.ChamberlainAlertColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.ChamberlainAlertColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetChamberlain()
				RAEIH.FormatChamberlain()
				RAEIH.OrganizeChamberlain() end,
				width = "half",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.ChamberlainAlertColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.ChamberlainAlertColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.ChamberlainAlertColour)
				}
			},

			{
				type = "colorpicker",
				name = "Gold Value Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.ChamberlainWarningColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.ChamberlainWarningColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetChamberlain()
				RAEIH.FormatChamberlain()
				RAEIH.OrganizeChamberlain() end,
				width = "half",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.ChamberlainWarningColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.ChamberlainWarningColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.ChamberlainWarningColour)
				}
			},

			{
				type = "editbox",
				name = "Panel Width",
				getFunc = function() return RAEIH.SavedVars.ChamberlainW end,
				setFunc = function(value)
				RAEIH.SavedVars.ChamberlainW = value
				RAEIH_Chamberlain:SetDimensions(RAEIH.SavedVars.ChamberlainW, RAEIH.SavedVars.ChamberlainH)
				RAEIH.SetChamberlain()
				RAEIH.FormatChamberlain()
				RAEIH.OrganizeChamberlain() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ChamberlainW
			},

			{
				type = "editbox",
				name = "Horizontal Position",
				getFunc = function() return RAEIH.SavedVars.ChamberlainX end,
				setFunc = function(value)
				RAEIH.SavedVars.ChamberlainX = value
				RAEIH_Chamberlain:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.ChamberlainX, RAEIH.SavedVars.ChamberlainY)
				RAEIH.SetChamberlain()
				RAEIH.FormatChamberlain()
				RAEIH.OrganizeChamberlain() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ChamberlainX
			},

			{
				type = "editbox",
				name = "Vertical Position",
				getFunc = function() return RAEIH.SavedVars.ChamberlainY end,
				setFunc = function(value)
				RAEIH.SavedVars.ChamberlainY = value
				RAEIH_Chamberlain:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.ChamberlainX, RAEIH.SavedVars.ChamberlainY)
				RAEIH.SetChamberlain()
				RAEIH.FormatChamberlain()
				RAEIH.OrganizeChamberlain() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ChamberlainY,
			},
		}
	},

	-- Extra Features Description
	{
		type = "description",
		title = "\n»   EXTRA FEATURES",
		text = "These are some extra features that InfoHub provides like \"Generic Subtitles\" and \"Reticle Target Information\"\n\n\n",
		width = "full"
	},

	-- SUBTITLES
	{
		type = "submenu",
		name = "Subtitles",

			controls = {

			{
				type = "checkbox",
				name = "Enable Subtitles",
				getFunc = function() return RAEIH.SavedVars.ShowSubtitles end,
				setFunc = function(value)
				RAEIH.SavedVars.ShowSubtitles = value
				RAEIH.FormatSubtitles()
				RAEIH.OrganizeSubtitles() end,
				width = "full",
				default = RAEIH.DefaultSavedVars.ShowSubtitles
			},

			{
				type = "button",
				name = "Test Subtitles (Short)",
				func = function() RAEIH.TestSubtitles2() end,
				disabled = function() return not RAEIH.SavedVars.ShowSubtitles end,
				width = "half"
			},

			{
				type = "button",
				name = "Test Subtitles (Long)",
				func = function() RAEIH.TestSubtitles() end,
				disabled = function() return not RAEIH.SavedVars.ShowSubtitles end,
				width = "half"
			},			

			{
				type = "checkbox",
				name = "Show NPC Name",
				getFunc = function() return RAEIH.SavedVars.ShowNPCName end,
				setFunc = function(value)
				RAEIH.SavedVars.ShowNPCName = value
				RAEIH.FormatSubtitles()
				RAEIH.OrganizeSubtitles() end,
				width = "half",
				disabled = function() return not RAEIH.SavedVars.ShowSubtitles end,
				default = RAEIH.DefaultSavedVars.ShowNPCName
			},

			{
				type = "checkbox",
				name = "Alignment to Center",
				getFunc = function() return RAEIH.SavedVars.SubtitlesAlignment end,
				setFunc = function(value)
				RAEIH.SavedVars.SubtitlesAlignment = value
				if value == true then
					RAEIH.SavedVars.SubtitlesX = RAEIH_Subtitles:GetLeft()
					RAEIH.SavedVars.SubtitlesY = RAEIH_Subtitles:GetTop()
					RAEIH_Subtitles:ClearAnchors()
					RAEIH_Subtitles:SetAnchor(TOP, GuiRoot, TOP, 0, RAEIH.SavedVars.SubtitlesY)
				end
				RAEIH.FormatSubtitles()
				RAEIH.OrganizeSubtitles() end,
				width = "half",
				disabled = function() return not RAEIH.SavedVars.ShowSubtitles end,
				default = RAEIH.DefaultSavedVars.SubtitlesAlignment
			},

			{
				type = "dropdown",
				name = "Subtitles Format",
				choices = {"Default", "Brackets", "Slashes", "Hypens", "Default Multiline", "Brackets Multiline", "Slashes Multiline", "Hypens Multiline"},
				getFunc = function() return RAEIH.SavedVars.SubtitlesFormat end,
				setFunc = function(value)
				RAEIH.SavedVars.SubtitlesFormat = value
				RAEIH.FormatSubtitles()
				RAEIH.OrganizeSubtitles() end,
				width = "half",
				disabled = function() return not RAEIH.SavedVars.ShowSubtitles end,
				default = RAEIH.DefaultSavedVars.SubtitlesFormat
			},

			{
				type = "slider",
				name = "Fade Time",
				min = 5,
				max = 60,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.SubtitlesFadeTime/1000 end,
				setFunc = function(value)
				RAEIH.SavedVars.SubtitlesFadeTime = value*1000
				RAEIH.FormatSubtitles()
				RAEIH.OrganizeSubtitles() end,
				width = "half",
				tooltip = "In seconds",
				disabled = function() return not RAEIH.SavedVars.ShowSubtitles end,
				default = RAEIH.DefaultSavedVars.SubtitlesFadeTime/1000
			},

			{
				type = "dropdown",
				name = "Font Type",
				choices = LMP:List(LMP.MediaType.FONT),
				getFunc = function() return RAEIH.SavedVars.SubtitlesFont end,
				setFunc = function(value)
				RAEIH.SavedVars.SubtitlesFont = value
				RAEIH.FormatSubtitles()
				RAEIH.OrganizeSubtitles() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.SubtitlesFont
			},

			{
				type = "dropdown",
				name = "Font Style",
				choices = {"Normal", "Outline", "Shadow", "Soft Shadow - Thick", "Soft Shadow - Thin", "Thick Outline"},
				getFunc = function() return RAEIH.SavedVars.SubtitlesFontStyle end,
				setFunc = function(value)
				RAEIH.SavedVars.SubtitlesFontStyle = value
				RAEIH.FormatSubtitles()
				RAEIH.OrganizeSubtitles() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.SubtitlesFontStyle
			},

			{
				type = "slider",
				name = "Font Size",
				min = 8,
				max = 72,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.SubtitlesFontSize end,
				setFunc = function(value)
				RAEIH.SavedVars.SubtitlesFontSize = value
				RAEIH.FormatSubtitles()
				RAEIH.OrganizeSubtitles() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.SubtitlesFontSize
			},

			{
				type = "dropdown",
				name = "Icon Size",
				choices = {"16", "24", "32", "40", "48", "56", "64"},
				getFunc = function() return RAEIH.SavedVars.SubtitlesIconW end,
				setFunc = function(value)
				RAEIH.SavedVars.SubtitlesIconW = value
				RAEIH.SavedVars.SubtitlesIconH = value
				RAEIH.FormatSubtitles()
				RAEIH.OrganizeSubtitles() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.SubtitlesIconW
			},

			{
				type = "colorpicker",
				name = "Default Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.SubtitlesDefaultColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.SubtitlesDefaultColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.FormatSubtitles()
				RAEIH.OrganizeSubtitles() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.SubtitlesDefaultColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.SubtitlesDefaultColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.SubtitlesDefaultColour)
				}
			},

			{
				type = "colorpicker",
				name = "NPC Name Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.SubtitlesNNameColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.SubtitlesNNameColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.FormatSubtitles()
				RAEIH.OrganizeSubtitles() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.SubtitlesNNameColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.SubtitlesNNameColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.SubtitlesNNameColour)
				}
			},

			{
				type = "editbox",
				name = "Horizontal Position",
				getFunc = function() return RAEIH.SavedVars.SubtitlesX end,
				setFunc = function(value)
				RAEIH.SavedVars.SubtitlesX = value
				RAEIH_Subtitles:ClearAnchors()
				RAEIH_Subtitles:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.SubtitlesX, RAEIH.SavedVars.SubtitlesY)
				RAEIH.FormatSubtitles()
				RAEIH.OrganizeSubtitles() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.SubtitlesX
			},

			{
				type = "editbox",
				name = "Vertical Position",
				getFunc = function() return RAEIH.SavedVars.SubtitlesY end,
				setFunc = function(value)
				RAEIH.SavedVars.SubtitlesY = value
				RAEIH_Subtitles:ClearAnchors()
				RAEIH_Subtitles:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.SubtitlesX, RAEIH.SavedVars.SubtitlesY)
				RAEIH.FormatSubtitles()
				RAEIH.OrganizeSubtitles() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.SubtitlesY
			},
		}
	},

	-- RETICLE
	{
		type = "submenu",
		name = "Reticle & Target",

			controls = {

			{
				type = "description",
				title = "TARGET INFO FORMATS",
				text = "\nExtended: LVR, Name, Health, Gender, Race, Class, Title/Caption, AvA Rank Name, Alliance",
				width = "full"
			},

			{
				type = "description",
				text = "Semi-Extended: LVR, Name, Health, Race, Class, Title/Caption, Alliance",
				width = "full"
			},

			{
				type = "description",
				text = "Normal: LVR, Name, Health, Alliance, Title/Caption\n\nBasics: LVR, Name, Health",
				width = "full"
			},

			{
				type = "description",
				title = "TARGET INFORMATION SETTINGS",
				text = "Set target information options",
				width = "full"
			},

			{
				type = "checkbox",
				name = "Enable Reticle Target Info",
				getFunc = function() return RAEIH.SavedVars.ShowTargetInfo end,
				setFunc = function(value)
				RAEIH.SavedVars.ShowTargetInfo = value
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "half",
				default = RAEIH.DefaultSavedVars.ShowTargetInfo
			},

			{
				type = "checkbox",
				name = "Ignore Critters/Animals",
				getFunc = function() return RAEIH.SavedVars.ReticleIgnoreCritter end,
				setFunc = function(value)
				RAEIH.SavedVars.ReticleIgnoreCritter = value
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "half",
				tooltip = "Level 1 neutral critter and animal targets like rat, chicken, beetle, sheep and pig will be ignored. Bugs that used for fishing, friendly animals like cat and horse or other unique animals won't be ignored",
				disabled = function() return not RAEIH.SavedVars.ShowTargetInfo end,
				default = RAEIH.DefaultSavedVars.ReticleIgnoreCritter
			},

			{
				type = "dropdown",
				name = "General Info Format",
				choices = {"Extended", "Semi-Extended", "Normal", "Basics"},
				getFunc = function() return RAEIH.SavedVars.ReticleFormat end,
				setFunc = function(value)
				RAEIH.SavedVars.ReticleFormat = value
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "half",
				disabled = function() return not RAEIH.SavedVars.ShowTargetInfo end,
				default = RAEIH.DefaultSavedVars.ReticleFormat
			},

			{
				type = "dropdown",
				name = "Health Format",
				choices = {"[Current/Max] [%]", "[Current] [%]", "[Max] [%]", "[%]"},
				getFunc = function() return RAEIH.SavedVars.ReticleHealthFormat end,
				setFunc = function(value)
				RAEIH.SavedVars.ReticleHealthFormat = value
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "half",
				disabled = function() return not RAEIH.SavedVars.ShowTargetInfo end,
				default = RAEIH.DefaultSavedVars.ReticleHealthFormat
			},

			{
				type = "dropdown",
				name = "Font Type",
				choices = LMP:List(LMP.MediaType.FONT),
				getFunc = function() return RAEIH.SavedVars.ReticleFont end,
				setFunc = function(value)
				RAEIH.SavedVars.ReticleFont = value
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "half",
				disabled = function() return not RAEIH.SavedVars.ShowTargetInfo end,
				default = RAEIH.DefaultSavedVars.ReticleFont
			},

			{
				type = "dropdown",
				name = "Font Style",
				choices = {"Normal", "Outline", "Shadow", "Soft Shadow - Thick", "Soft Shadow - Thin", "Thick Outline"},
				getFunc = function() return RAEIH.SavedVars.ReticleFontStyle end,
				setFunc = function(value)
				RAEIH.SavedVars.ReticleFontStyle = value
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "half",
				disabled = function() return not RAEIH.SavedVars.ShowTargetInfo end,
				default = RAEIH.DefaultSavedVars.ReticleFontStyle
			},

			{
				type = "slider",
				name = "Font Size",
				min = 8,
				max = 72,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.ReticleFontSize end,
				setFunc = function(value)
				RAEIH.SavedVars.ReticleFontSize = value
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "full",
				disabled = function() return not RAEIH.SavedVars.ShowTargetInfo end,
				default = RAEIH.DefaultSavedVars.ReticleFontSize
			},

			{
				type = "editbox",
				name = "Horizontal Position",
				getFunc = function() return RAEIH.SavedVars.ReticleX end,
				setFunc = function(value)
				RAEIH.SavedVars.ReticleX = value
				RAEIH_Reticle:ClearAnchors()
				RAEIH_Reticle:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.ReticleX, RAEIH.SavedVars.ReticleY)
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "half",
				disabled = function() return not RAEIH.SavedVars.ShowTargetInfo end,
				default = RAEIH.DefaultSavedVars.ReticleX
			},

			{
				type = "editbox",
				name = "Vertical Position",
				getFunc = function() return RAEIH.SavedVars.ReticleY end,
				setFunc = function(value)
				RAEIH.SavedVars.ReticleY = value
				RAEIH_Reticle:ClearAnchors()
				RAEIH_Reticle:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RAEIH.SavedVars.ReticleX, RAEIH.SavedVars.ReticleY)
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "half",
				disabled = function() return not RAEIH.SavedVars.ShowTargetInfo end,
				default = RAEIH.DefaultSavedVars.ReticleY
			},

			{
				type = "description",
				title = "RETICLE TEXTURE SETTINGS",
				text = "Set reticle texture options",
				width = "full"
			},

			{
				type = "checkbox",
				name = "Enable New Reticle Texture",
				getFunc = function() return RAEIH.SavedVars.ChangeReticleTexture end,
				setFunc = function(value)
				RAEIH.SavedVars.ChangeReticleTexture = value
				if value == false then
					ReloadUI()
				end
				RAEIH.ChangeReticleTexture()
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "full",
				warning = "Disabling this will reload UI",
				default = RAEIH.DefaultSavedVars.ChangeReticleTexture
			},

			{
				type = "dropdown",
				name = "Reticle Texture",
				choices = {"Cross", "Dot"},
				getFunc = function() return RAEIH.SavedVars.ReticleTexture end,
				setFunc = function(value)
				RAEIH.SavedVars.ReticleTexture = value
				RAEIH.OrganizeReticleTexture()
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "half",
				disabled = function() return not RAEIH.SavedVars.ChangeReticleTexture end,
				default = RAEIH.DefaultSavedVars.ReticleTexture
			},

			{
				type = "slider",
				name = "Reticle Texture Scale",
				min = 10,
				max = 100,
				step = 1,
				getFunc = function() return RAEIH.SavedVars.ReticleTextureScale * 100 end,
				setFunc = function(value)
				RAEIH.SavedVars.ReticleTextureScale = value / 100
				if RAEIH_Reticle_Texture ~= nil then
					RAEIH_Reticle_Texture:SetScale(RAEIH.SavedVars.ReticleTextureScale)
				end
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "half",
				disabled = function() return not RAEIH.SavedVars.ChangeReticleTexture end,
				default = RAEIH.DefaultSavedVars.ReticleTextureScale * 100
			}
		}
	},

	-- RETICLE & TARGET COLOURING
	{
		type = "submenu",
		name = "Reticle & Target Colouring",

			controls = {

			{
				type = "description",
				title = "MAIN COLOURING SETTINGS",
				text = "Choose between complete reaction colouring or partial colouring",
				width = "full"
			},

			{
				type = "checkbox",
				name = "Enable Reaction Colouring",
				getFunc = function() return RAEIH.SavedVars.ReticleReactionColouring end,
				setFunc = function(value)
				RAEIH.SavedVars.ReticleReactionColouring = value
				if value == true then RAEIH.SavedVars.ReticlePartialColouring = false end
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "half",
				tooltip = "All of the parts of the target information will have reaction colours",
				disabled = function() return RAEIH.SavedVars.ReticlePartialColouring end,
				default = RAEIH.DefaultSavedVars.ReticleReactionColouring
			},

			{
				type = "checkbox",
				name = "Use RC for Ret. Texture",
				getFunc = function() return RAEIH.SavedVars.ReticleUseRCforRT end,
				setFunc = function(value)
				RAEIH.SavedVars.ReticleUseRCforRT = value
				if value == true then RAEIH.SavedVars.ReticleUsePCforRT = false end
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "half",
				tooltip = "Use reaction colours for reticle texture",
				warning = "Requires \"Enable Reaction Colours\" option as ON",
				disabled = function() return RAEIH.SavedVars.ReticleUsePCforRT end,
				default = RAEIH.DefaultSavedVars.ReticleUseRCforRT
			},

			{
				type = "checkbox",
				name = "Enable Partial Colouring",
				getFunc = function() return RAEIH.SavedVars.ReticlePartialColouring end,
				setFunc = function(value)
				RAEIH.SavedVars.ReticlePartialColouring = value
				if value == true then RAEIH.SavedVars.ReticleReactionColouring = false end
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "half",
				tooltip = "If selected, you will be able to select some extra colouring options for target infrmation",
				disabled = function() return RAEIH.SavedVars.ReticleReactionColouring end,
				default = RAEIH.DefaultSavedVars.ReticlePartialColouring
			},

			{
				type = "checkbox",
				name = "Use PC for Ret. Texture",
				getFunc = function() return RAEIH.SavedVars.ReticleUsePCforRT end,
				setFunc = function(value)
				RAEIH.SavedVars.ReticleUsePCforRT = value
				if value == true then RAEIH.SavedVars.ReticleUseRCforRT = false end
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "half",
				tooltip = "Use partial (single) colour for reticle texture",
				warning = "Requires \"Enable Partial Colours\" option as ON",
				disabled = function() return RAEIH.SavedVars.ReticleUseRCforRT end,
				default = RAEIH.DefaultSavedVars.ReticleUsePCforRT
			},

			{
				type = "description",
				title = "PARTIAL COLOURING SETTINGS",
				text = "Each part can be coloured by a colouring mode or a single colour that you choose. If you use this, check below to see what colours defined and change them as you like",
				width = "full"
			},

			{
				type = "dropdown",
				name = "LVR Colouring Mode",
				choices = {"Difficulty Mode", "Reaction Mode", "Alliance Mode", "Single Colour Mode"},
				getFunc = function() return RAEIH.SavedVars.ReticleLVRMode end,
				setFunc = function(value)
				RAEIH.SavedVars.ReticleLVRMode = value
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "half",
				disabled = function() return not RAEIH.SavedVars.ReticlePartialColouring end,
				default = RAEIH.DefaultSavedVars.ReticleLVRMode
			},

			{
				type = "dropdown",
				name = "Name Colouring Mode",
				choices = {"Difficulty Mode", "Reaction Mode", "Alliance Mode", "Single Colour Mode"},
				getFunc = function() return RAEIH.SavedVars.ReticleNameMode end,
				setFunc = function(value)
				RAEIH.SavedVars.ReticleNameMode = value
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "half",
				disabled = function() return not RAEIH.SavedVars.ReticlePartialColouring end,
				default = RAEIH.DefaultSavedVars.ReticleNameMode
			},

			{
				type = "dropdown",
				name = "Health Colouring Mode",
				choices = {"Difficulty Mode", "Reaction Mode", "Alliance Mode", "Single Colour Mode"},
				getFunc = function() return RAEIH.SavedVars.ReticleHealthMode end,
				setFunc = function(value)
				RAEIH.SavedVars.ReticleHealthMode = value
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "half",
				disabled = function() return not RAEIH.SavedVars.ReticlePartialColouring end,
				default = RAEIH.DefaultSavedVars.ReticleHealthMode
			},

			{
				type = "dropdown",
				name = "Gender Colouring Mode",
				choices = {"Difficulty Mode", "Reaction Mode", "Alliance Mode", "Split Gender Mode", "Single Colour Mode"},
				getFunc = function() return RAEIH.SavedVars.ReticleGenderMode end,
				setFunc = function(value)
				RAEIH.SavedVars.ReticleGenderMode = value
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "half",
				disabled = function() return not RAEIH.SavedVars.ReticlePartialColouring end,
				default = RAEIH.DefaultSavedVars.ReticleGenderMode
			},

			{
				type = "dropdown",
				name = "Race Colouring Mode",
				choices = {"Difficulty Mode", "Reaction Mode", "Ext. Alliance Mode", "Single Colour Mode"},
				getFunc = function() return RAEIH.SavedVars.ReticleRaceMode end,
				setFunc = function(value)
				RAEIH.SavedVars.ReticleRaceMode = value
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "half",
				tooltip = "For races, also Imperials will have a unique colour",
				disabled = function() return not RAEIH.SavedVars.ReticlePartialColouring end,
				default = RAEIH.DefaultSavedVars.ReticleRaceMode
			},

			{
				type = "dropdown",
				name = "Class Colouring Mode",
				choices = {"Difficulty Mode", "Reaction Mode", "Alliance Mode", "Single Colour Mode"},
				getFunc = function() return RAEIH.SavedVars.ReticleClassMode end,
				setFunc = function(value)
				RAEIH.SavedVars.ReticleClassMode = value
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "half",
				disabled = function() return not RAEIH.SavedVars.ReticlePartialColouring end,
				default = RAEIH.DefaultSavedVars.ReticleClassMode
			},

			{
				type = "dropdown",
				name = "Title / Caption Colouring Mode",
				choices = {"Difficulty Mode", "Reaction Mode", "Alliance Mode", "Single Colour Mode"},
				getFunc = function() return RAEIH.SavedVars.ReticleTiCaMode end,
				setFunc = function(value)
				RAEIH.SavedVars.ReticleTiCaMode = value
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "half",
				disabled = function() return not RAEIH.SavedVars.ReticlePartialColouring end,
				default = RAEIH.DefaultSavedVars.ReticleTiCaMode
			},

			{
				type = "dropdown",
				name = "AvA Rank Colouring Mode",
				choices = {"Difficulty Mode", "Reaction Mode", "Alliance Mode", "Single Colour Mode"},
				getFunc = function() return RAEIH.SavedVars.ReticleAvAMode end,
				setFunc = function(value)
				RAEIH.SavedVars.ReticleAvAMode = value
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "half",
				disabled = function() return not RAEIH.SavedVars.ReticlePartialColouring end,
				default = RAEIH.DefaultSavedVars.ReticleAvAMode
			},

			{
				type = "dropdown",
				name = "Alliance Colouring Mode",
				choices = {"Difficulty Mode", "Reaction Mode", "Alliance Mode", "Single Colour Mode"},
				getFunc = function() return RAEIH.SavedVars.ReticleAllianceMode end,
				setFunc = function(value)
				RAEIH.SavedVars.ReticleAllianceMode = value
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "half",
				disabled = function() return not RAEIH.SavedVars.ReticlePartialColouring end,
				default = RAEIH.DefaultSavedVars.ReticleAllianceMode
			},

			{
				type = "description",
				title = "REACTION COLOURS",
				text = "You may define general reaction colours here",
				width = "full"
			},

			{
				type = "colorpicker",
				name = "No Target Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.ReticleRCNoTarget) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.ReticleRCNoTarget = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "half",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.ReticleRCNoTarget),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.ReticleRCNoTarget),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.ReticleRCNoTarget)
				}
			},

			{
				type = "colorpicker",
				name = "Dead Target Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.ReticleRCDead) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.ReticleRCDead = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "half",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.ReticleRCDead),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.ReticleRCDead),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.ReticleRCDead)
				}
			},

			{
				type = "colorpicker",
				name = "Unidentified Target Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.ReticleRCUnidentified) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.ReticleRCUnidentified = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "half",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.ReticleRCUnidentified),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.ReticleRCUnidentified),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.ReticleRCUnidentified)
				}
			},

			{
				type = "colorpicker",
				name = "Hostile Target Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.ReticleRCHostile) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.ReticleRCHostile = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "half",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.ReticleRCHostile),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.ReticleRCHostile),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.ReticleRCHostile)
				}
			},

			{
				type = "colorpicker",
				name = "Neutral Target Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.ReticleRCNeutral) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.ReticleRCNeutral = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "half",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.ReticleRCNeutral),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.ReticleRCNeutral),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.ReticleRCNeutral)
				}
			},

			{
				type = "colorpicker",
				name = "Friendly Target Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.ReticleRCFriendly) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.ReticleRCFriendly = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "half",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.ReticleRCFriendly),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.ReticleRCFriendly),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.ReticleRCFriendly)
				}
			},

			{
				type = "colorpicker",
				name = "Allied NPC Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.ReticleRCNPCAlly) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.ReticleRCNPCAlly = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "half",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.ReticleRCNPCAlly),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.ReticleRCNPCAlly),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.ReticleRCNPCAlly)
				}
			},

			{
				type = "colorpicker",
				name = "Allied Player Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.ReticleRCPlayerAlly) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.ReticleRCPlayerAlly = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "half",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.ReticleRCPlayerAlly),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.ReticleRCPlayerAlly),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.ReticleRCPlayerAlly)
				}
			},

			-- {
			-- 	type = "colorpicker",
			-- 	name = "Mate Colour (Friend List)",
			-- 	getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.ReticleRCMate) end,
			-- 	setFunc = function(r, g, b) RAEIH.SavedVars.ReticleRCMate = RAEIH.RGBToHex(r, g, b)
			-- 	RAEIH.SetReticle()
			-- 	RAEIH.FormatReticle() end,
			-- 	width = "half",
			-- 	warning = "Under development",
			-- 	disabled = true,
			-- 	default =
			-- 	{
			-- 		r = RAEIH.HexToR(RAEIH.DefaultSavedVars.ReticleRCMate),
			-- 		g = RAEIH.HexToG(RAEIH.DefaultSavedVars.ReticleRCMate),
			-- 		b = RAEIH.HexToB(RAEIH.DefaultSavedVars.ReticleRCMate)
			-- 	}
			-- },

			-- {
			-- 	type = "colorpicker",
			-- 	name = "Guild Member Colour",
			-- 	getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.ReticleRCGuildy) end,
			-- 	setFunc = function(r, g, b) RAEIH.SavedVars.ReticleRCGuildy = RAEIH.RGBToHex(r, g, b)
			-- 	RAEIH.SetReticle()
			-- 	RAEIH.FormatReticle() end,
			-- 	width = "half",
			-- 	warning = "Under development",
			-- 	disabled = true,
			-- 	default =
			-- 	{
			-- 		r = RAEIH.HexToR(RAEIH.DefaultSavedVars.ReticleRCGuildy),
			-- 		g = RAEIH.HexToG(RAEIH.DefaultSavedVars.ReticleRCGuildy),
			-- 		b = RAEIH.HexToB(RAEIH.DefaultSavedVars.ReticleRCGuildy)
			-- 	}
			-- },

			{
				type = "description",
				title = "LVR DIFFICULTY COLOURS",
				text = "Colours that will be used for LVR if you select, difficulty colouring mode",
				width = "full"
			},

			{
				type = "colorpicker",
				name = "Low LVR Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.ReticleLowLVR) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.ReticleLowLVR = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "half",
				tooltip = "At least -5 of your LVR",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.ReticleLowLVR),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.ReticleLowLVR),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.ReticleLowLVR)
				}
			},

			{
				type = "colorpicker",
				name = "Normal LVR Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.ReticleNormalLVR) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.ReticleNormalLVR = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "half",
				tooltip = "Same with your LVR or between -2 and +2",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.ReticleNormalLVR),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.ReticleNormalLVR),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.ReticleNormalLVR)
				}
			},

			{
				type = "colorpicker",
				name = "High LVR Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.ReticleHighLVR) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.ReticleHighLVR = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "full",
				tooltip = "At least +5 of your LVR",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.ReticleHighLVR),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.ReticleHighLVR),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.ReticleHighLVR)
				}
			},

			{
				type = "description",
				title = "GENDER COLOURS",
				text = "You may choose female and male gender colours here",
				width = "full"
			},

			{
				type = "colorpicker",
				name = "Female Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.ReticleFemale) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.ReticleFemale = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "half",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.ReticleFemale),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.ReticleFemale),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.ReticleFemale)
				}
			},

			{
				type = "colorpicker",
				name = "Male Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.ReticleMale) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.ReticleMale = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "half",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.ReticleMale),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.ReticleMale),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.ReticleMale)
				}
			},

			{
				type = "description",
				title = "ALLIANCE SPECIFIC COLOURS",
				text = "You may set different colours for each alliance",
				width = "full"
			},

			{
				type = "colorpicker",
				name = "Imperial Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.ReticleIMP) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.ReticleIMP = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.ReticleIMP),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.ReticleIMP),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.ReticleIMP)
				}
			},

			{
				type = "colorpicker",
				name = "Daggerfall Covenant Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.ReticleDC) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.ReticleDC = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "half",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.ReticleDC),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.ReticleDC),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.ReticleDC)
				}
			},

			{
				type = "colorpicker",
				name = "Aldmeri Dominion Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.ReticleAD) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.ReticleAD = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "half",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.ReticleAD),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.ReticleAD),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.ReticleAD)
				}
			},

			{
				type = "colorpicker",
				name = "Ebonheart Pack Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.ReticleEP) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.ReticleEP = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "half",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.ReticleEP),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.ReticleEP),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.ReticleEP)
				}
			},

			{
				type = "colorpicker",
				name = "No Allegiance Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.ReticleNoAlliance) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.ReticleNoAlliance = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "half",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.ReticleNoAlliance),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.ReticleNoAlliance),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.ReticleNoAlliance)
				}
			},

			{
				type = "description",
				title = "DEFAULT PARTIAL COLOURS",
				text = "These will be used if you don't select any mode for the corresponding part",
				width = "full"
			},

			{
				type = "colorpicker",
				name = "Reticle Texture Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.ReticleTextureColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.ReticleTextureColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "full",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.ReticleTextureColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.ReticleTextureColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.ReticleTextureColour)
				}
			},

			{
				type = "colorpicker",
				name = "Symbol Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.ReticleDefaultColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.ReticleDefaultColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "half",
				tooltip = "Colours of [ ] < > ( ) and alike",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.ReticleDefaultColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.ReticleDefaultColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.ReticleDefaultColour)
				}
			},

			{
				type = "colorpicker",
				name = "Level/Vet. Rank Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.ReticleLVRColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.ReticleLVRColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "half",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.ReticleLVRColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.ReticleLVRColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.ReticleLVRColour)
				}
			},

			{
				type = "colorpicker",
				name = "Name Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.ReticleNameColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.ReticleNameColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "half",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.ReticleNameColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.ReticleNameColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.ReticleNameColour)
				}
			},

			{
				type = "colorpicker",
				name = "Current Health Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.ReticleCHealthColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.ReticleCHealthColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "half",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.ReticleCHealthColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.ReticleCHealthColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.ReticleCHealthColour)
				}
			},

			{
				type = "colorpicker",
				name = "Max. Health Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.ReticleMHealthColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.ReticleMHealthColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "half",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.ReticleMHealthColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.ReticleMHealthColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.ReticleMHealthColour)
				}
			},

			{
				type = "colorpicker",
				name = "Health % Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.ReticleHPercColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.ReticleHPercColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "half",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.ReticleHPercColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.ReticleHPercColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.ReticleHPercColour)
				}
			},

			{
				type = "colorpicker",
				name = "Gender Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.ReticleGenderColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.ReticleGenderColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "half",
				text = "Will be used if you don't split gender colouring",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.ReticleGenderColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.ReticleGenderColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.ReticleGenderColour)
				}
			},

			{
				type = "colorpicker",
				name = "Race Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.ReticleRaceColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.ReticleRaceColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "half",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.ReticleRaceColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.ReticleRaceColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.ReticleRaceColour)
				}
			},

			{
				type = "colorpicker",
				name = "Class Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.ReticleClassColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.ReticleClassColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "half",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.ReticleClassColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.ReticleClassColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.ReticleClassColour)
				}
			},

			{
				type = "colorpicker",
				name = "Title/Caption Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.ReticleTiCaColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.ReticleTiCaColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "half",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.ReticleTiCaColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.ReticleTiCaColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.ReticleTiCaColour)
				}
			},

			{
				type = "colorpicker",
				name = "AvA Rank Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.ReticleAvAColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.ReticleAvAColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "half",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.ReticleAvAColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.ReticleAvAColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.ReticleAvAColour)
				}
			},

			{
				type = "colorpicker",
				name = "Alliance Colour",
				getFunc = function() return RAEIH.HexToRGB(RAEIH.SavedVars.ReticleAllianceColour) end,
				setFunc = function(r, g, b) RAEIH.SavedVars.ReticleAllianceColour = RAEIH.RGBToHex(r, g, b)
				RAEIH.SetReticle()
				RAEIH.FormatReticle() end,
				width = "half",
				default =
				{
					r = RAEIH.HexToR(RAEIH.DefaultSavedVars.ReticleAllianceColour),
					g = RAEIH.HexToG(RAEIH.DefaultSavedVars.ReticleAllianceColour),
					b = RAEIH.HexToB(RAEIH.DefaultSavedVars.ReticleAllianceColour)
				}
			}
		}
	}
}

-- REGISTER SETTINGS

function RAEIH.RegisterSettings()
	LAM2:RegisterAddonPanel("RAEIH_Settings", panelData)
	LAM2:RegisterOptionControls("RAEIH_Settings", optionsData)
end