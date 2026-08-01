-- ==================================================================================================== --
-- # Immersive Interactions
-- # 
-- # It's an addon for ESO. I'm not going to put a fancy license or disclaimer. Go crazy with it.
-- ==================================================================================================== --

do
	local ESO_MAJOR		= 7
	local ESO_MINOR		= 3
	local MAJOR			= 5
	local MINOR			= 0

	ImmersiveFunctions = {}

	ImmersiveData = {
		-- info
		addonInfo = {
			name			= "ImmersiveInteractions",
			displayName		= "Immersive Interactions",
			author			= "@taloskiin in-game, eventHandler on ESOUI",
			version			= ("%s.%s.%s.%s"):format(ESO_MAJOR, ESO_MINOR, MAJOR, MINOR),
			s_version		= "1",
			website			= "http://www.esoui.com/downloads/info502-ImmersiveInteractions.html",
			keywords		= "roleplay, rp, immersion, ui, gui, interface, dialog",
			slash			= "/immacts",
		},

		debugInfo = {
			DEBUG			= false,
			DEBUG_ALL		= false,
			DEBUG_INTERACT	= false,
			DEBUG_TAT		= false,
			DEBUG_TAB		= false,
			DEBUG_OPT		= false,
			DEBUG_ALT		= false,
			DEBUG_VALIDATE	= false,
			DEBUG_SETTINGS	= false,
			DEBUG_GUI		= false,
			DEBUG_OTHER		= false,
		},

		iTime				= -1,
		INVALID_KEY			= nil,

		-- constants
		MAX_TIMER			= 10000,

		-- control booleans
		do_once				= true,

		-- state booleans
		bNotChattering		= true,
		bService			= false,
		bShowRewardArea		= false,
		bRestoreChat		= false,
		bRestoreMini		= false,
		uiHidden			= false,

		opt = {},

		controls = {},

		handles = {},

		states = {},

		handlesKB = {
			["InteractWindow"]		= ZO_InteractWindow,
			["TargetAreaTitle"]		= ZO_InteractWindowTargetAreaTitle,
			["TargetAreaBodyText"]	= ZO_InteractWindowTargetAreaBodyText,
			["PlayerAreaOptions"]	= ZO_InteractWindowPlayerAreaOptions,
			["VerticalSeparator"]	= ZO_InteractWindowVerticalSeparator,
			["WindowTopBG"]			= ZO_InteractWindowTopBG,
			["WindowBottomBG"]		= ZO_InteractWindowBottomBG,
			["RewardArea"]			= ZO_InteractWindowCollapseContainerRewardArea,
			["RewardAreaHeader"]	= ZO_InteractWindowCollapseContainerRewardAreaHeader,
		},

		handlesGP = {

		},

		statesKB = {
			["bHideWindow"]			= "InteractWindow",
			["bHideTitle"]			= "TargetAreaTitle",
			["bHideBodyText"]		= "TargetAreaBodyText",
			["bHideOptions"]		= "PlayerAreaOptions",
			["bHideIcons"]			= "PlayerAreaIcons",
			["bHideVS"]				= "VerticalSeparator",
			["bHideTopBG"]			= "WindowTopBG",
			["bHideBottomBG"]		= "WindowBottomBG",
		},

		statesGP = {

		},

		-- interaction types to ignore for hiding ui elements
		skipTypes = {
			["bank"]				= CHATTER_START_BANK,
			["gbank"]				= CHATTER_START_GUILDBANK,
			["keep"]				= CHATTER_START_KEEP,
			["shop"]				= CHATTER_START_SHOP,
			["stable"]				= CHATTER_START_STABLE,
			["trading"]				= CHATTER_START_TRADINGHOUSE,
			["pack"]				= CHATTER_START_BUY_BAG_SPACE,
		},

		-- interactive objects to ignore for hiding ui elements
		skipTitles = {
			"Board", "Mission", "Shrine",
			"Advertisement", "Book", "Brochure", "Chest", "Crate", "Gravestone", "Journal", "Letter", "Note", "Page", "Scroll", "Writ",
			"Last Will and Testament of Frodibert Fontbonne", -- Wayrest
			"The Gray Passage", -- Dragonstar, Craglorn -- document to start a daily quest
		},

		-- daily quest givers to ignore for hiding ui elements
		skipDaily = {
				-- --[[				Writ Certification			]]-- --
			"Danel Telleno",			-- Writ Accreditor - Alchemy, Enchanting, Provisioning
			"Millenith",				-- Writ Accreditor - Blacksmithing, Clothing, Woodworking
			"Felarian",
			-- TODO Jewelry

				-- --[[					Craglorn				]]-- --
			--"Safa al-", --"Safa al-Satakalaam",
			-- TODO More Craglorn

			-- TODO Mages & Fighters Guild

			-- TODO Bravil, Chorrol, Cheydenhal

			-- TODO Cropsford, Bruma, Vlastarus

			-- TODO Imperial City

			-- TODO Bounty

			-- TODO Scrolls

			-- Unfortunate Prequel Dailies
			--"Jee-", --"Jee-Lar",
			--"Zahari",

			--============================================================--
			--[[					Dark Brotherhood DLC				]]--
			--============================================================--
				-- Anvil, Kvatch daily from boards, which are already skipped
			"Speaker Terenus",
			--============================================================--

			--============================================================--
			--[[					Thieves Guild DLC					]]--
			--============================================================--
				-- All daily from boards, which are already skipped
			--============================================================--

			--============================================================--
			--[[						Orsinium DLC					]]--
			--============================================================--
				-- --[[				Orsinium, Wrothgar			]]-- --
			"Arzorag",				-- Daily Quest Handler
			"Lilyameh",				-- |--> Heresy of Ignorance		(ZAN)	-- Zandadunoz						-- Unfinished Dolmen (UD)
			"Bagrugbesh",			-- |--> Meat for the Masses		(POA)	-- Stop the Poachers				-- Poacher's Encampment
			"Ushang the Untamed",	-- |--> Nature's Bounty			(NB)	-- Kill Corintthac the Abomination	-- The Accursed Nursery
			"Sonolia Muspidius",	-- |--> Reeking of Foul Play	(EDU)	-- Kill King-Chief Edu				-- King-Chief's Throne
			"Cirantille",			-- |--> Scholarly Salvage		(MAD)	-- Defeat Mad Urkazbur				-- The Mad Ogre's Altar
			"Birkhu the Bold",		-- |--> Snow and Steam			(NYZ)	-- Defeat Nyzchaleft				-- Nyzchaleft Falls

				-- --[[			Morkul Stronghold, Wrothgar		]]-- --
			"Guruzug",				-- Daily Delve Handler
			"Nednor",				-- |--> Breakfast of the Bizarre
			"Sergeant Oufa",		-- |--> Fire in the Hold
			"Thazeg",				-- |--> Free Spirits
			"Arushna",				-- |--> Getting a Bellyfull
			"Raynor Vanos",			-- |--> Parts of the Whole
			"Menninia",				-- |--> The Skin Trade
			--============================================================--

			--============================================================--
			--[[					Clockwork City DLC					]]--
			--============================================================--
				-- --[[		The Brass Fortress, Clockwork City	]]-- --
			"Razgurug",
			"Clockwork Facilitator",
			"Bursar of Tributes",
			--============================================================--

			--============================================================--
			--[[						Murkmire DLC					]]--
			--============================================================--
				-- --[[				Lilmoth, Murkmire			]]-- --
			"Varo Hosidias",
			"Bolu",

				-- --[[		Root-Whisper Village, Murkmire		]]-- --
			"Tuwul",
			--============================================================--

			--============================================================--
			--[[						Morrowind						]]--
			--============================================================--
				-- --[[			Vivec City, Vvardenfell			]]-- --
			"Beleru Omoril",		-- 
			"Traylan Omoril",		-- 

				-- --[[			Ald'ruhn, Vvardenfell			]]-- --
			-- NOTE: parsing these names fails when the the post-fix is included, must be hidden characters
			"Numani-", --"Numani-Rasi",
			"Huntmaster Sorim-", --"Huntmaster Sorim-Nakar",
			--============================================================--

			--============================================================--
			--[[						Summerset						]]--
			--============================================================--
				-- --[[				Alinor, Summerset			]]-- --
			"Battlereeve Tanerline",
			"Justiciar Farowel",
			"Justiciar Tanorian",
			--============================================================--

			--============================================================--
			--[[						Elsweyr							]]--
			--============================================================--
				-- --[[			Rimmen, Northern Elsweyr		]]-- --
			--"Battlereeve Tanerline", -- Dragons, arrives after Summerset events
			"Ri'hirr",
			"Nisuzi",

				-- --[[			Senchal, Southern Elsweyr		]]-- --
			"Bruccius Baenius",
			"Guybert Flaubert",

				-- --[[		Dragonguard Sanctum, Tideholm		]]-- --
			"Chizbari the Chipper",
			"Dirge Truptor",
			--============================================================--

			--============================================================--
			--[[						Greymoor						]]--
			--============================================================--
				-- --[[				Solitude, Western Skyrim	]]-- --
			"Swordthane Jylta",
			"Tinzen",
			"Hidaver",

				-- --[[				Markarth, The Reach			]]-- --
			"Nelldena",
			"Gwenyfe",
			"Bralthahawn",
			"Ardanir",
			--============================================================--

			--============================================================--
			--[[						Blackwood						]]--
			--============================================================--
				-- --[[				Leyawiin, Blackwood			]]-- --
			"Deetum-", --"Deetum-Jas",
			"Britta Silanus",

				-- --[[				, The Deadlands		]]-- --
			--"",

				-- --[[				, Fargrave			]]-- --
			--"",
			--============================================================--
		},

		XML = {
			["altEdge"]				= "EsoUI/Art/ChatWindow/chat_BG_edge.dds",
			["altCenter"]			= "EsoUI/Art/ChatWindow/chat_BG_center.dds",
		},

		fontStyle = {
			" ",
			"soft-shadow-thick", "soft-shadow-thin",
			"soft-shadow", "soft-thick", "soft-thin", "soft",
			"shadow-thick", "shadow-thin", "shadow",
			"thick", "thin",
		},
	}

	local OPTION_TO_ICON =
	{
		[CHATTER_START_TALK]						= "EsoUI/Art/Interaction/ConversationAvailable.dds",
		[CHATTER_TALK_CHOICE]						= "EsoUI/Art/Interaction/ConversationAvailable.dds",
		[CHATTER_TALK_CHOICE_MONEY]					= "EsoUI/Art/Interaction/ConversationWithCost.dds",
		[CHATTER_TALK_CHOICE_INTIMIDATE_DISABLED]	= "EsoUI/Art/Interaction/ConversationAvailable.dds",
		[CHATTER_TALK_CHOICE_PERSUADE_DISABLED]		= "EsoUI/Art/Interaction/ConversationAvailable.dds",
		[CHATTER_TALK_CHOICE_CLEMENCY_DISABLED]		= "EsoUI/Art/Interaction/ConversationAvailable.dds",
		[CHATTER_TALK_CHOICE_CLEMENCY_COOLDOWN]		= "EsoUI/Art/Interaction/ConversationAvailable.dds",
		[CHATTER_START_NEW_QUEST_BESTOWAL]			= "EsoUI/Art/Interaction/ConversationAvailable.dds",
		[CHATTER_START_COMPLETE_QUEST]				= "EsoUI/Art/Interaction/QuestCompleteAvailable.dds",
		[CHATTER_START_GIVE_ITEM]					= "EsoUI/Art/Interaction/ConversationAvailable.dds",
		[CHATTER_GUILDKIOSK_IN_TRANSITION]			= "EsoUI/Art/Interaction/ConversationAvailable.dds",
		[CHATTER_START_SHOP]						= "EsoUI/Art/Interaction/StoreAvailable.dds",
		[CHATTER_GOODBYE]							= "EsoUI/Art/Interaction/Goodbye.dds",
		[CHATTER_GENERIC_ACCEPT]					= "EsoUI/Art/Interaction/Accept.dds",
		[CHATTER_COMPLETE_QUEST]					= "EsoUI/Art/Interaction/Accept.dds",
		--
		["audioUp"]									= "EsoUI/Art/CharacterCreate/CharacterCreate_Audio_Up.dds",
		["audioDown"]								= "EsoUI/Art/CharacterCreate/CharacterCreate_Audio_Down.dds",
		["depositUp"]								= "EsoUI/Art/Bank/Bank_TabIcon_Deposit_Up.dds",
		["inventoryUp"]								= "EsoUI/Art/MainMenu/MenuBar_Inventory_Up.dds",
		["acceptUp"]								= "EsoUI/Art/Buttons/Accept_Up.dds",
		["declineUp"]								= "EsoUI/Art/Buttons/Decline_Up.dds",
		["bankUp"]									= "EsoUI/Art/Guild/GuildHistory_IndexIcon_GuildBank_Up.dds",
		["storeUp"]									= "EsoUI/Art/Guild/GuildHistory_IndexIcon_GuildStore_Up.dds",
		["mountsUp"]								= "EsoUI/Art/Mounts/TabIcon_Mounts_Up.dds",
		["questUp"]									= "EsoUI/Art/Inventory/Inventory_TabIcon_Quest_Up.dds",
		["questOver"]								= "EsoUI/Art/Inventory/Inventory_TabIcon_Quest_Over.dds",
		["notifyUp"]								= "EsoUI/Art/ChatWindow/Chat_Notification_Up.dds",
		["notifyOver"]								= "EsoUI/Art/ChatWindow/Chat_Notification_Over.dds",
	}

	-- "EsoUI/Art/Interaction/ConversationAvailable.dds", scale = 0.5, anchor = { RIGHT, LEFT, -9, 1 }, },
	-- "EsoUI/Art/Interaction/StoreAvailable.dds", scale= 0.7, anchor = { RIGHT, LEFT, -4, 1.5 }, },
	-- thanks to acies for experimenting to get the scale and positioning right on some of these icons
	ImmersiveData.icons = {
		["audioUp"] = {
			texture = OPTION_TO_ICON["audioUp"],
			--scale = 1.00,
			--color = { 1.00, 1.00, 1.00, 1.00 },
			--anchor = { RIGHT, LEFT, 0, 0 },
			--[[secondary = {
				placeBehind = true,
				alpha = 1.00
				texture = OPTION_TO_ICON[""],
			},--]]
		},
		["audioDown"] = {
			texture = OPTION_TO_ICON["audioDown"],
			--scale = 1.00,
			--color = { 1.00, 1.00, 1.00, 1.00 },
			--anchor = { RIGHT, LEFT, 0, 0 },
			--[[secondary = {
				placeBehind = true,
				alpha = 1.00
				texture = OPTION_TO_ICON[""],
			},--]]
		},
		["depositUp"] = {
			texture = OPTION_TO_ICON["depositUp"],
			--scale = 1.00,
			--color = { 1.00, 1.00, 1.00, 1.00 },
			--anchor = { RIGHT, LEFT, 0, 0 },
			--[[secondary = {
				placeBehind = true,
				alpha = 1.00
				texture = OPTION_TO_ICON[""],
			},--]]
		},
		["inventoryUp"] = {
			texture = OPTION_TO_ICON["inventoryUp"],
			--scale = 1.00,
			--color = { 1.00, 1.00, 1.00, 1.00 },
			anchor = { RIGHT, LEFT, -4.00, 1.00 },
			--[[secondary = {
				placeBehind = true,
				alpha = 1.00
				texture = OPTION_TO_ICON[""],
			},--]]
		},
		["acceptUp"] = {
			texture = OPTION_TO_ICON["acceptUp"],
			--scale = 1.00,
			color = { 0.50, 1.00, 0, 1.00 },
			anchor = { RIGHT, LEFT, -4.00, 1.00 },
			--[[secondary = {
				placeBehind = true,
				alpha = 1.00
				texture = OPTION_TO_ICON[""],
			},--]]
		},
		["declineUp"] = {
			texture = OPTION_TO_ICON["declineUp"],
			scale = 0.70,
			--color = { 1.00, 1.00, 1.00, 1.00 },
			anchor = { RIGHT, LEFT, -9.00, 1.00 },
			--[[secondary = {
				placeBehind = true,
				alpha = 1.00
				texture = OPTION_TO_ICON[""],
			},--]]
		},
		["bankUp"] = {
			texture = OPTION_TO_ICON["bankUp"],
			--scale = 1.00,
			--color = { 1.00, 1.00, 1.00, 1.00 },
			anchor = { RIGHT, LEFT, -4.00, 0 },
			--[[secondary = {
				placeBehind = true,
				alpha = 1.00
				texture = OPTION_TO_ICON[""],
			},--]]
		},
		["storeUp"] = {
			texture = OPTION_TO_ICON["storeUp"],
			--scale = 1.00,
			--color = { 1.00, 1.00, 1.00, 1.00 },
			anchor = { RIGHT, LEFT, -4.00, 1.50 },
			--[[secondary = {
				placeBehind = true,
				alpha = 1.00
				texture = OPTION_TO_ICON[""],
			},--]]
		},
		["mountsUp"] = {
			texture = OPTION_TO_ICON["mountsUp"],
			scale = 1.20,
			--color = { 1.00, 1.00, 1.00, 1.00 },
			anchor = { RIGHT, LEFT, -3.00, 1.00 },
			--[[secondary = {
				placeBehind = true,
				alpha = 1.00
				texture = OPTION_TO_ICON[""],
			},--]]
		},
		["questUp"] = {
			texture = OPTION_TO_ICON["questUp"],
			scale = 1.50,
			--color = { 1.00, 1.00, 1.00, 1.00 },
			anchor = { RIGHT, LEFT, 2.50, 1.00 },
			secondary = {
				placeBehind = true,
				texture = OPTION_TO_ICON["questOver"],
				alpha = 0.70
			},
		},
		["notifyUp"] = {
			texture = OPTION_TO_ICON["notifyUp"],
			--scale = 1.00,
			--color = { 1.00, 1.00, 1.00, 1.00 },
			--anchor = { RIGHT, LEFT, 0, 0 },
			secondary = {
				placeBehind = true,
				texture = OPTION_TO_ICON["notifyOver"],
				alpha = 0.90
			},
		},
		["disabledColor"] = {
			ZO_DEFAULT_DISABLED_COLOR.r,
			ZO_DEFAULT_DISABLED_COLOR.g,
			ZO_DEFAULT_DISABLED_COLOR.b,
			ZO_DEFAULT_DISABLED_COLOR.a,
		},
		["disabledIcon"] = { 0.75, 0.75, 0.75, 1.00 },
	}

	ImmersiveData.iconsByType = {
		[CHATTER_GENERIC_ACCEPT]								= ImmersiveData.icons["acceptUp"],		--:42
		[CHATTER_COMPLETE_QUEST]								= ImmersiveData.icons["acceptUp"],		--:43
		[CHATTER_START_TALK]									= ImmersiveData.icons["notifyUp"],		--:100
		[CHATTER_TALK_CHOICE]									= ImmersiveData.icons["notifyUp"],		--:101
		[CHATTER_TALK_CHOICE_MONEY]								= ImmersiveData.icons["depositUp"],		--:102
		[CHATTER_TALK_CHOICE_INTIMIDATE_DISABLED]				= ImmersiveData.icons["declineUp"],		--:103
		[CHATTER_TALK_CHOICE_PERSUADE_DISABLED]					= ImmersiveData.icons["declineUp"],		--:104
		[CHATTER_TALK_CHOICE_PAY_BOUNTY]						= ImmersiveData.icons["depositUp"],		--:105
		[CHATTER_TALK_CHOICE_USE_CLEMENCY]						= ImmersiveData.icons["acceptUp"],		--:106
		[CHATTER_TALK_CHOICE_CLEMENCY_DISABLED]					= ImmersiveData.icons["declineUp"],		--:107
		[CHATTER_TALK_CHOICE_CLEMENCY_COOLDOWN]					= ImmersiveData.icons["declineUp"],		--:108
		[CHATTER_TALK_CHOICE_USE_SHADOWY_CONNECTIONS]			= ImmersiveData.icons["acceptUp"],		--:109
		[CHATTER_TALK_CHOICE_SHADOWY_CONNECTIONS_UNAVAILABLE]	= ImmersiveData.icons["declineUp"],		--:110
		[CHATTER_START_NEW_QUEST_BESTOWAL]						= ImmersiveData.icons["questUp"],		--:200
		[CHATTER_START_COMPLETE_QUEST]							= ImmersiveData.icons["notifyUp"],		--:300
		[CHATTER_START_PAY_BOUNTY]								= ImmersiveData.icons["depositUp"],		--:500
		[CHATTER_START_SHOP]									= ImmersiveData.icons["storeUp"],		--:600
		[CHATTER_START_BANK]									= ImmersiveData.icons["bankUp"],		--:1200
		[CHATTER_START_BUY_BAG_SPACE]							= ImmersiveData.icons["inventoryUp"],	--:1600
		[CHATTER_PROMPT_BUY_BAG_SPACE]							= ImmersiveData.icons["inventoryUp"],	--:1601
		[CHATTER_START_STABLE]									= ImmersiveData.icons["mountsUp"],		--:3100
		[CHATTER_START_GUILDBANK]								= ImmersiveData.icons["bankUp"],		--:3300
		[CHATTER_START_TRADINGHOUSE]							= ImmersiveData.icons["storeUp"],		--:3400
		[CHATTER_START_GUILDKIOSK_BID]							= ImmersiveData.icons["depositUp"],		--:3800
		[CHATTER_START_GUILDKIOSK_PURCHASE]						= ImmersiveData.icons["acceptUp"],		--:3900
		[CHATTER_START_ADVANCE_COMPLETABLE_QUEST_CONDITIONS]	= ImmersiveData.icons["acceptUp"],		--:4000
		[CHATTER_START_USE_CLEMENCY]							= ImmersiveData.icons["notifyUp"],		--:4400
		[CHATTER_START_USE_SHADOWY_CONNECTIONS]					= ImmersiveData.icons["notifyUp"],		--:4500
		[SI_CONVERSATION_OPTION_SPEECHCRAFT_INTIMIDATE]			= ImmersiveData.icons["acceptUp"],		--:6356
		[SI_CONVERSATION_OPTION_SPEECHCRAFT_PERSUADE]			= ImmersiveData.icons["acceptUp"],		--:6357
		[SI_CONVERSATION_OPTION_SPEECHCRAFT_CLEMENCY]			= ImmersiveData.icons["acceptUp"],		--:6358
		[CHATTER_GOODBYE]										= ImmersiveData.icons["declineUp"],		--:10000
	}

	--
	ImmersiveData.ctrls = {}

	function ImmersiveFunctions.GetData(key)
		--if not ImmersiveData[key] then
			--df("SetData::invalid_key::"..key)
		--end

		return ImmersiveData[key]
	end

	function ImmersiveFunctions.SetData(key, val)
		-- only modify existing data, don't create new data members
		--[[if ImmersiveData[key] then
			ImmersiveData[key] = val
		else
			-- non-existent entry
			df("SetData::invalid_key::"..key)
		end--]]
		ImmersiveData[key] = val

		return ImmersiveData[key]
	end

	function ImmersiveFunctions.IsArray(key)
		if key == "opt" then
			return true
		end

		return false -- non-existent array
	end

	function ImmersiveFunctions.InitArray(key)
		-- only modify existing data, don't create new data members
		if ImmersiveFunctions.IsArray(key) then
			ImmersiveData[key] = {}
			return true
		end

		df("InitArray::invalid_key::"..key)
		return false -- non-existent array
	end

	function ImmersiveFunctions.SetDataArray(key, index, val)
		-- only modify existing data, don't create new data members
		if ImmersiveData[key] and type(ImmersiveData[key]) == "table" then
			if val ~= nil then
				if index == nil then
					if type(val) == "table" then
						ImmersiveData[key] = val
					end
				elseif ImmersiveData[key][index] ~= nil then
					ImmersiveData[key][index] = val
				end
			end
			--CHAT_SYSTEM:AddMessage(tostring(ImmersiveData[key][index]))
			return true
		end

		df("SetDataArray::invalid_key::"..key)
		return false -- non-existent array
	end
end
