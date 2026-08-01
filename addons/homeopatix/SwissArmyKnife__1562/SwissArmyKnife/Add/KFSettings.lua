-- Menu Settings Addon File
-- @author    : Homeo
-- @lastModif : 23/09/2017

--------------------
--- MENU SETTING ---
--------------------
function CreateMenu()	
	local MYSETTINGSNAME = "SwissArmyKnifeOptions"

	local LAM = LibStub("LibAddonMenu-2.0")

	local KFpanelData = {
		type = "panel",
		name = SAK.name,
		displayName = "|cff0000Swiss|r|cffffffArmy|r|cff0000Knife|r",
		author = SAK.author,
		version = SAK.version,
		registerForRefresh = true,
		registerForDefaults = true,
		slashCommand = "/kfs"
	}
	
	LAM:RegisterAddonPanel(MYSETTINGSNAME, KFpanelData)

	local LAM2 = LibStub("LibAddonMenu-2.0")

	local KFoptionsTable = {
	[1] = {
			type = "header",
			name = zo_strformat("|c3f7fff<<1>>|r", SAK.lang.KF_GENERAL_ST_1)
	},
	[2] = {
              type = "checkbox",
              name = SAK.lang.KF_GENERAL_ST_2,
              tooltip = SAK.lang.KF_GENERAL_ST_2_1,
              getFunc = function() return SAK.settings.ALL_CHAR end,
              setFunc = function(value) if(value == true) then 
						SAK.settings.ALL_CHAR = true
					else
						SAK.settings.ALL_CHAR = false
					end
			ReloadUI("ingame")
			end,
		warning = zo_strformat("|cff0000<<1>>|r", SAK.lang.KF_GENERAL_ST_3),
		default = SAK.settings.ALL_CHAR
         },
	[3] = {
			type = "header",
			name = zo_strformat("|c3f7fff<<1>>|r", SAK.lang.KF_SETTINGS_1)
	},
	[4] = {
              type = "checkbox",
              name = SAK.lang.KF_DIS_START_1,
              tooltip = SAK.lang.KF_DIS_START_2,
              getFunc = function() return SAK.settings.DISPLAY_AT_START end,
              setFunc = function(value) if(value == false) then 
						SAK.settings.DISPLAY_AT_START = false
					else
						SAK.settings.DISPLAY_AT_START = true
					end
			ReloadUI("ingame")
			end,
		warning = zo_strformat("|cff0000<<1>>|r", SAK.lang.KF_GENERAL_ST_3),
		default = SAK.settings.DISPLAY_THIEF
         },
	[5] = {
              type = "checkbox",
              name = SAK.lang.KF_COMBAT_1,
              tooltip = SAK.lang.KF_COMBAT_2,
              getFunc = function() return SAK.settings.DISPLAYINCOMBAT end,
              setFunc = function(value) if(value == false) then 
						SAK.settings.DISPLAYINCOMBAT = false
					else
						SAK.settings.DISPLAYINCOMBAT = true
					end
			end,
		default = SAK.settings.DISPLAYINCOMBAT
         },
         [6] = {
              type = "checkbox",
              name = SAK.lang.KF_SLASH_3,
              tooltip = SAK.lang.KF_SLASH_3,
              getFunc = function() return SAK.settings.MUST_BE_SHOWN end,
              setFunc = function(value) if(value == false) then 
						HideKey()
					else
						ShowKey()
					end
			end,
		default = SAK.settings.MUST_BE_SHOWN
         },
	[7] = {
              type = "checkbox",
              name = zo_strformat("<<1>> <<2>> <<3>>", SAK.lang.KF_SLASH_5, SAK.clefIcon, SAK.lang.KF_SLASH_5_2),
              tooltip = zo_strformat("<<1>> <<2>> <<3>> <<4>> <<5>>", SAK.lang.KF_SLASH_5, SAK.clefIcon, SAK.lang.KF_SLASH_10_2, SAK.clefBis, SAK.lang.KF_SLASH_5_2),
              getFunc = function() return SAK.settings.SHOW_KEY_ALL end,
              setFunc = function(value) if(value == false) then
						DisplayNone()
					else
						DisplayAll()
					end
			 end,
		default = SAK.settings.SHOW_KEY_ALL
         },
	[8] = {
        type = "submenu",
        name = SAK.lang.KF_BANDEAU_1,
        controls = {
	[1] = {
			type = "header",
			name = zo_strformat("|c3f7fff<<1>>|r", SAK.lang.KF_BANDEAU_6)
	},
	[2] = {
        	type = "checkbox",
                name = zo_strformat("<<1>> <<2>> <<3>> <<4>> <<5>> <<6>>", SAK.lang.KF_BANDEAU_2, SAK.sigilIcon, SAK.clefIcon, SAK.clefBis, SAK.clefIcon, SAK.clefIcon),
		tooltip = "",
		getFunc = function() return SAK.settings.DISPLAY_DEADRIC end,
              	setFunc = function(value) if(value == false) then 
						SAK.settings.DISPLAY_DEADRIC = false
					else
						SAK.settings.DISPLAY_DEADRIC = true
						SAK.settings.DISPLAY_POTION = false
						SAK.settings.DISPLAY_SOULGEM = false
						SAK.settings.DISPLAY_WRIT = false
						SAK.settings.DISPLAY_COMBAT_POPO = false
						SAK.settings.DISPLAY_STEALING = false
						SAK.settings.Display_Bandeau = 1
					end
			end,
                default = SAK.settings.DISPLAY_DEADRIC
    		},
	[3] = {
        	type = "checkbox",
                name = zo_strformat("<<1>> <<2>> <<3>> <<4>>", SAK.lang.KF_BANDEAU_3, "|t90%:90%:"..SAK.iconPoHeal_2.."|t", "|t90%:90%:"..SAK.iconPoMana_2.."|t", "|t90%:90%:"..SAK.iconPoStam_2.."|t"),
		tooltip = "",
		getFunc = function() return SAK.settings.DISPLAY_POTION end,
              	setFunc = function(value) if(value == false) then 
						SAK.settings.DISPLAY_POTION = false
					else
						SAK.settings.DISPLAY_DEADRIC = false
						SAK.settings.DISPLAY_POTION = true
						SAK.settings.DISPLAY_SOULGEM = false
						SAK.settings.DISPLAY_WRIT = false
						SAK.settings.DISPLAY_COMBAT_POPO = false
						SAK.settings.DISPLAY_STEALING = false
						SAK.settings.Display_Bandeau = 2
					end
			end,
                default = SAK.settings.DISPLAY_POTION
    		},
	[4] = {
        	type = "checkbox",
                name = zo_strformat("<<1>> <<2>> <<3>> <<4>>", SAK.lang.KF_BANDEAU_4, "|t90%:90%:"..SAK.iconLockPick_2.."|t", "|t90%:90%:"..SAK.iconSoulGemEmpty_2.."|t", "|t90%:90%:"..SAK.iconSoulGemFilled_2.."|t"),
		tooltip = "",
		getFunc = function() return SAK.settings.DISPLAY_SOULGEM end,
              	setFunc = function(value) if(value == false) then 
						SAK.settings.DISPLAY_SOULGEM = false
					else
						SAK.settings.DISPLAY_DEADRIC = false
						SAK.settings.DISPLAY_POTION = false
						SAK.settings.DISPLAY_SOULGEM = true
						SAK.settings.DISPLAY_WRIT = false
						SAK.settings.DISPLAY_COMBAT_POPO = false
						SAK.settings.DISPLAY_STEALING = false
						SAK.settings.Display_Bandeau = 3
					end
			end,
                default = SAK.settings.DISPLAY_SOULGEM
    		},
	[5] = {
        	type = "checkbox",
                name = zo_strformat("<<1>> <<2>> <<3>> <<4>> <<5>> <<6>> <<7>>", SAK.lang.KF_BANDEAU_5, "|t110%:110%:"..SAK.IconClothing.."|t", "|t110%:110%:"..SAK.IconBlacksmith.."|t", "|t110%:110%:"..SAK.IconWoodwork.."|t", "|t110%:110%:"..SAK.IconEnchant.."|t", "|t110%:110%:"..SAK.IconProvision.."|t", "|t110%:110%:"..SAK.IconAlchemy.."|t"),
		tooltip = "",
		getFunc = function() return SAK.settings.DISPLAY_WRIT end,
              	setFunc = function(value) if(value == false) then 
						SAK.settings.DISPLAY_WRIT = false
					else
						SAK.settings.DISPLAY_DEADRIC = false
						SAK.settings.DISPLAY_POTION = false
						SAK.settings.DISPLAY_SOULGEM = false
						SAK.settings.DISPLAY_WRIT = true
						SAK.settings.DISPLAY_COMBAT_POPO = false
						SAK.settings.DISPLAY_STEALING = false
						SAK.settings.Display_Bandeau = 4
					end
			end,
                default = SAK.settings.DISPLAY_WRIT
    		},
	[6] = {
        	type = "checkbox",
                name = zo_strformat("<<1>> <<2>> <<3>> <<4>>", SAK.lang.KF_BANDEAU_7, "|t110%:110%:"..SAK.iconCombat_1.."|t", "|t110%:110%:"..SAK.iconCombat_2.."|t", "|t110%:110%:"..SAK.iconCombat_3.."|t"),
		tooltip = "",
		getFunc = function() return SAK.settings.DISPLAY_COMBAT_POPO end,
              	setFunc = function(value) if(value == false) then 
						SAK.settings.DISPLAY_COMBAT_POPO = false
					else
						SAK.settings.DISPLAY_DEADRIC = false
						SAK.settings.DISPLAY_POTION = false
						SAK.settings.DISPLAY_SOULGEM = false
						SAK.settings.DISPLAY_WRIT = false
						SAK.settings.DISPLAY_COMBAT_POPO = true
						SAK.settings.DISPLAY_STEALING = false
						SAK.settings.Display_Bandeau = 5
					end
			end,
                default = SAK.settings.DISPLAY_COMBAT_POPO
    		},
	[7] = {
        	type = "checkbox",
                name = zo_strformat("<<1>> <<2>> <<3>> <<4>> <<5>> <<6>>", SAK.lang.KF_BANDEAU_8, "|t90%:90%:"..SAK.iconLockPick_2.."|t", "|t90%:90%:"..SAK.IconMonk.."|t", "|t90%:90%:"..SAK.IconEdit.."|t", "|t90%:90%:"..SAK.IconPoVanish.."|t", "|t90%:90%:"..SAK.IconPoInvi.."|t"),
		tooltip = "",
		getFunc = function() return SAK.settings.DISPLAY_STEALING end,
              	setFunc = function(value) if(value == false) then 
						SAK.settings.DISPLAY_STEALING = false
					else
						SAK.settings.DISPLAY_STEALING = true
						SAK.settings.DISPLAY_DEADRIC = false
						SAK.settings.DISPLAY_POTION = false
						SAK.settings.DISPLAY_SOULGEM = false
						SAK.settings.DISPLAY_WRIT = false
						SAK.settings.DISPLAY_COMBAT_POPO = false
						SAK.settings.Display_Bandeau = 6
					end
			end,
                default = SAK.settings.DISPLAY_STEALING
    		},
	},
	},
	[9] = {
        type = "submenu",
        name = "Display",
        controls = {
	[1] = {
        	type = "description",
        	title = nil,	--(optional)
        	text = zo_strformat("|cff0000<<1>>|r", SAK.lang.KF_SETTINGS_15),
        	width = "full",	--or "half" (optional)
    		},
	[2] = {
			type = "header",
			name = zo_strformat("|c3f7fff<<1>>|r", "Display addon part")
	},
	[3] = {
              type = "checkbox",
              name = SAK.lang.KF_THIEF_4,
              tooltip = SAK.lang.KF_THIEF_5,
              getFunc = function() return SAK.settings.DISPLAY_THIEF end,
              setFunc = function(value) if(value == false) then 
						SAK.settings.DISPLAY_THIEF = false
					else
						SAK.settings.DISPLAY_THIEF = true
					end
			end,
		default = SAK.settings.DISPLAY_THIEF
         },
	[4] = {
              type = "checkbox",
              name = SAK.lang.KF_GENERAL_ST_4,
              tooltip = SAK.lang.KF_GENERAL_ST_4_1,
              getFunc = function() return SAK.settings.DISPLAY_XP end,
              setFunc = function(value) if(value == false) then 
						SAK.settings.DISPLAY_XP = false
					else
						SAK.settings.DISPLAY_XP = true
					end
			end,
		default = SAK.settings.DISPLAY_XP
         },
	[5] = {
              type = "checkbox",
              name = SAK.lang.KF_TIME_PLAYED_11,
              tooltip = SAK.lang.KF_TIME_PLAYED_12,
              getFunc = function() return SAK.settings.DISPLAY_CH_PT end,
              setFunc = function(value) if(value == false) then 
						SAK.settings.DISPLAY_CH_PT = false
					else
						SAK.settings.DISPLAY_CH_PT = true
					end
			end,
		default = SAK.settings.DISPLAY_CH_PT
         },
	[6] = {
              type = "checkbox",
              name = SAK.lang.KF_GENERAL_ST_8_2,
              tooltip = SAK.lang.KF_GENERAL_ST_8_3,
              getFunc = function() return SAK.settings.DISPLAY_POOLBAR end,
              setFunc = function(value) if(value == false) then 
						SAK.settings.DISPLAY_POOLBAR = false
					else
						SAK.settings.DISPLAY_POOLBAR = true
					end
			end,
		default = SAK.settings.DISPLAY_POOLBAR
         },
	[7] = {
              type = "checkbox",
              name = SAK.lang.KF_TIME_PLAYED_1,
              tooltip = SAK.lang.KF_TIME_PLAYED_2,
              getFunc = function() return SAK.settings.DISPLAY_TIME_PLAYED end,
              setFunc = function(value) if(value == false) then 
						SAK.settings.DISPLAY_TIME_PLAYED = false
					else
						SAK.settings.DISPLAY_TIME_PLAYED = true
					end
			end,
		default = SAK.settings.DISPLAY_TIME_PLAYED
         },
	[8] = {
              type = "checkbox",
              name = SAK.lang.KF_TIME_PLAYED_7,
              tooltip = SAK.lang.KF_TIME_PLAYED_8,
              getFunc = function() return SAK.settings.DISPLAY_SESSION_GOLD end,
              setFunc = function(value) if(value == false) then 
						SAK.settings.DISPLAY_SESSION_GOLD = false
					else
						SAK.settings.DISPLAY_SESSION_GOLD = true
					end
			end,
		default = SAK.settings.DISPLAY_SESSION_GOLD
         },
	[9] = {
              type = "checkbox",
              name = SAK.lang.KF_REPAIRCOST_1,
              tooltip = SAK.lang.KF_REPAIRCOST_2,
              getFunc = function() return SAK.settings.DISPLAY_REPAIRCOST end,
              setFunc = function(value) if(value == false) then 
						SAK.settings.DISPLAY_REPAIRCOST = false
					else
						SAK.settings.DISPLAY_REPAIRCOST = true
					end
			end,
		default = SAK.settings.DISPLAY_REPAIRCOST
         },
	[10] = {
              type = "checkbox",
                name = zo_strformat("<<1>>", SAK.lang.KF_MOUNT_1),
		tooltip = SAK.lang.KF_MOUNT_2,
		getFunc = function() return SAK.settings.DISPLAY_MOUNT end,
              	setFunc = function(value) if(value == false) then 
						SAK.settings.DISPLAY_MOUNT = false
					else
						SAK.settings.DISPLAY_MOUNT = true
					end
			end,
                default = SAK.settings.DISPLAY_MOUNT
         },
	[11] = {
              type = "checkbox",
                name = zo_strformat("<<1>>", SAK.lang.KF_BAGBANK_1),
		tooltip = SAK.lang.KF_BAGBANK_2,
		getFunc = function() return SAK.settings.DISPLAY_BAGBANK end,
              	setFunc = function(value) if(value == false) then 
						SAK.settings.DISPLAY_BAGBANK = false
					else
						SAK.settings.DISPLAY_BAGBANK = true
					end
			end,
                default = SAK.settings.DISPLAY_BAGBANK
         },
	[12] = {
              type = "checkbox",
                name = zo_strformat("<<1>>", SAK.lang.KF_TRAVEL_1),
		tooltip = SAK.lang.KF_TRAVEL_2,
		getFunc = function() return SAK.settings.DISPLAY_TRAVEL end,
              	setFunc = function(value) if(value == false) then 
						SAK.settings.DISPLAY_TRAVEL = false
					else
						SAK.settings.DISPLAY_TRAVEL = true
					end
			end,
                default = SAK.settings.DISPLAY_TRAVEL
         },
	[13] = {
              type = "checkbox",
              name = SAK.lang.KF_CRYSTAL_1,
              tooltip = zo_strformat("<<1>>  <<2>>", SAK.lang.KF_CRYSTAL_1, SAK.IconTransmute),
              getFunc = function() return SAK.settings.DISPLAY_TRANSMUTE end,
              setFunc = function(value) if(value == false) then 
						SAK.settings.DISPLAY_TRANSMUTE = false
					else
						SAK.settings.DISPLAY_TRANSMUTE = true
					end
			end,
		default = SAK.settings.DISPLAY_TRANSMUTE
         },
	[14] = {
              type = "checkbox",
              name = SAK.lang.KF_CRYSTAL_2,
              tooltip = zo_strformat("<<1>>  <<2>>", SAK.lang.KF_CRYSTAL_2, SAK.IconVoucher),
              getFunc = function() return SAK.settings.DISPLAY_WRITVOUCHER end,
              setFunc = function(value) if(value == false) then 
						SAK.settings.DISPLAY_WRITVOUCHER = false
					else
						SAK.settings.DISPLAY_WRITVOUCHER = true
					end
			end,
		default = SAK.settings.DISPLAY_WRITVOUCHER
         },
	[15] = {
              type = "checkbox",
              name = SAK.lang.KF_SETTINGS_17,
              tooltip = zo_strformat("<<1>>  <<2>>", SAK.lang.KF_SETTINGS_17, SAK.IconMail),
              getFunc = function() return SAK.settings.DISPLAY_MAIL end,
              setFunc = function(value) if(value == false) then 
						SAK.settings.DISPLAY_MAIL = false
					else
						SAK.settings.DISPLAY_MAIL = true
					end
			end,
		default = SAK.settings.DISPLAY_MAIL
         },
	[16] = {
        	type = "button",
        	name = SAK.lang.KF_SETTINGS_16,
        	tooltip = "",
        	func = function() ReloadUI("ingame") end,
        	width = "full",	
		warning = zo_strformat("|cff0000<<1>>|r", SAK.lang.KF_GENERAL_ST_3),
    		},
	},
	},
	[10] = {
        type = "submenu",
        name = SAK.lang.KF_JUNK_7,
        controls = {
	[1] = {
		type = "header",
		name = zo_strformat("|c3f7fff<<1>>|r", "Set Junk or Set Lock")
	},
	[2] = {
              type = "checkbox",
              name = SAK.lang.KF_JUNK_10,
              tooltip = SAK.lang.KF_JUNK_10,
              getFunc = function() return SAK.settings.DISPLAY_AUTO_JUNKED end,
              setFunc = function(value) if(value == false) then 
						SAK.settings.DISPLAY_AUTO_JUNKED = false
					else
						SAK.settings.DISPLAY_AUTO_JUNKED = true
					end
			end,
		default = SAK.settings.DISPLAY_AUTO_JUNKED
         },
	[3] = {
              type = "checkbox",
              name = SAK.lang.KF_JUNK_4,
              tooltip = SAK.lang.KF_JUNK_1,
              getFunc = function() return SAK.settings.DISPLAY_JUNK end,
              setFunc = function(value) if(value == false) then 
						SAK.settings.DISPLAY_JUNK = false
					else
						SAK.settings.DISPLAY_JUNK = true
					end
			end,
		default = SAK.settings.DISPLAY_JUNK
         },
	[4] = {
              type = "checkbox",
              name = SAK.lang.KF_JUNK_8,
              tooltip = SAK.lang.KF_JUNK_8,
              getFunc = function() return SAK.settings.DISPLAY_JUNKED end,
              setFunc = function(value) if(value == false) then 
						SAK.settings.DISPLAY_JUNKED = false
					else
						SAK.settings.DISPLAY_JUNKED = true
					end
			end,
		default = SAK.settings.DISPLAY_JUNKED
         },
	[5] = {
              type = "checkbox",
              name = SAK.lang.KF_JUNK_9,
              tooltip = SAK.lang.KF_JUNK_9,
              getFunc = function() return SAK.settings.DISPLAY_LOCKED end,
              setFunc = function(value) if(value == false) then 
						SAK.settings.DISPLAY_LOCKED = false
					else
						SAK.settings.DISPLAY_LOCKED = true
					end
			end,
		default = SAK.settings.DISPLAY_LOCKED
         },
	[6] = {
              type = "checkbox",
              name = SAK.lang.KF_JUNK_11,
              tooltip = SAK.lang.KF_JUNK_11,
              getFunc = function() return SAK.settings.DISPLAY_LOOT_CHAT end,
              setFunc = function(value) if(value == false) then 
						SAK.settings.DISPLAY_LOOT_CHAT = false
					else
						SAK.settings.DISPLAY_LOOT_CHAT = true
					end
			end,
		default = SAK.settings.DISPLAY_LOOT_CHAT
         },
	},
	},
	[11] = {
        type = "submenu",
        name = SAK.lang.KF_STATS_4,
        controls = {
	[1] = {
		type = "header",
		name = zo_strformat("|c3f7fff<<1>>|r", "Experience")
	},
	[2] = {
              type = "checkbox",
              name = SAK.lang.KF_GENERAL_ST_8,
              tooltip = SAK.lang.KF_GENERAL_ST_8_1,
              getFunc = function() return SAK.settings.DISPLAY_POOL end,
              setFunc = function(value) if(value == false) then 
						SAK.settings.DISPLAY_POOL = false
					else
						SAK.settings.DISPLAY_POOL = true
					end
			end,
		default = SAK.settings.DISPLAY_POOL
         },
	},
	},
	[12] = {
        type = "submenu",
        name = SAK.lang.KF_STATS_1,
        controls = {
	[1] = {
              type = "checkbox",
              name = zo_strformat("<<1>> <<2>>", SAK.lang.KF_MONEY_1, SAK.GoldIcon),
              getFunc = function() return SAK.settings.DISPLAY_GOLD end,
              setFunc = function(value) if(value == false) then 
						SAK.settings.DISPLAY_GOLD = false
						SAK.settings.DISPLAY_TELVAR = true
						SAK.settings.DISPLAY_ALLIANCE = false
					else
						SAK.settings.DISPLAY_GOLD = true
						SAK.settings.DISPLAY_TELVAR = false
						SAK.settings.DISPLAY_ALLIANCE = false
					end
			end,
		default = SAK.settings.DISPLAY_GOLD
         },
	[2] = {
              type = "checkbox",
              name = zo_strformat("<<1>> <<2>>", SAK.lang.KF_MONEY_2, SAK.TelVarIcon),
              getFunc = function() return SAK.settings.DISPLAY_TELVAR end,
              setFunc = function(value) if(value == false) then 
						SAK.settings.DISPLAY_GOLD = true
						SAK.settings.DISPLAY_TELVAR = false
						SAK.settings.DISPLAY_ALLIANCE = false
					else
						SAK.settings.DISPLAY_GOLD = false
						SAK.settings.DISPLAY_TELVAR = true
						SAK.settings.DISPLAY_ALLIANCE = false
					end
			end,
		default = SAK.settings.DISPLAY_TELVAR
         },
	[3] = {
              type = "checkbox",
              name = zo_strformat("<<1>> <<2>>", SAK.lang.KF_MONEY_3, SAK.AlliIcon),
              getFunc = function() return SAK.settings.DISPLAY_ALLIANCE end,
              setFunc = function(value) if(value == false) then 
						SAK.settings.DISPLAY_GOLD = true
						SAK.settings.DISPLAY_TELVAR = false
						SAK.settings.DISPLAY_ALLIANCE = false
					else
						SAK.settings.DISPLAY_GOLD = false
						SAK.settings.DISPLAY_TELVAR = false
						SAK.settings.DISPLAY_ALLIANCE = true
					end
			end,
		default = SAK.settings.DISPLAY_ALLIANCE
         },
	[4] = {
              type = "checkbox",
              name = SAK.lang.KF_TIME_PLAYED_9,
              tooltip = SAK.lang.KF_TIME_PLAYED_10,
              getFunc = function() return SAK.settings.REPAIR_COST_DISPLAY end,
              setFunc = function(value) if(value == false) then 
						SAK.settings.REPAIR_COST_DISPLAY = false
					else
						SAK.settings.REPAIR_COST_DISPLAY = true
					end
			end,
		default = SAK.settings.REPAIR_COST_DISPLAY
         },
	
	[5] = {
        	type = "button",
        	name = SAK.lang.KF_STATS_2,
        	tooltip = SAK.lang.KF_STATS_3,
        	func = function() SAK.settings.CONNECTED_TIME = GetTimeStamp()
				  SAK.settings.GOLD_CONNECTED = GoldAtConnection()
				updateUI()
			end,
        	width = "full",	--or "half" (optional)
    	},
	},
	},
	[13] = {
        type = "submenu",
        name = "BANK",
        controls = {
	[1] = {
			type = "header",
			name = zo_strformat("|c3f7fff<<1>>|r", SAK.lang.KF_SETTINGS_2)
	},
	[2] = {
        	type = "checkbox",
              name = SAK.lang.KF_USE_BANK,
              tooltip = SAK.lang.KF_USE_BANK,
              getFunc = function() return SAK.settings.USE_BANK end,
              setFunc = function(value) if(value == false) then 
						SAK.settings.USE_BANK = false
					else
						SAK.settings.USE_BANK = true
					end
			ReloadUI("ingame")
			end,
		warning = zo_strformat("|cff0000<<1>>|r", SAK.lang.KF_GENERAL_ST_3),
		default = SAK.settings.USE_BANK
    	},
	[3] = {
			type = "header",
			name = zo_strformat("|c3f7fff<<1>>|r", SAK.lang.KF_SETTINGS_21)
	},
	[4] = {
        	type = "checkbox",
              name = SAK.lang.KF_DEPOSIT_MONEY,
              tooltip = SAK.lang.KF_DEPOSIT_MONEY,
              getFunc = function() return SAK.settings.DEPOSIT_MONEY end,
              setFunc = function(value) if(value == false) then 
						SAK.settings.DEPOSIT_MONEY = false
					else
						SAK.settings.DEPOSIT_MONEY = true
					end
			ReloadUI("ingame")
			end,
		warning = zo_strformat("|cff0000<<1>>|r", SAK.lang.KF_GENERAL_ST_3),
		default = SAK.settings.DEPOSIT_MONEY
    	},

	[5] = {
              type = "slider",
              name = zo_strformat("<<1>> <<2>>", SAK.GoldIcon, SAK.lang.KF_SLASH_18),
              tooltip = zo_strformat("<<1>> <<2>> <<3>>", SAK.lang.KF_SLASH_20, SAK.settings.MINIMUM_GOLD_SAVINGS, SAK.GoldIcon),
              min = 0,
              max = 100000,
	      step = 50,
              getFunc = function() return SAK.settings.MINIMUM_GOLD_SAVINGS end,
              setFunc = function(value) setGold(value) end,
		default = SAK.settings.MINIMUM_GOLD_SAVINGS
         },
	[6] = {
        	type = "checkbox",
              name = SAK.lang.KF_DEPOSIT_TELVAR,
              tooltip = SAK.lang.KF_DEPOSIT_TELVAR,
              getFunc = function() return SAK.settings.DEPOSIT_TELVAR end,
              setFunc = function(value) if(value == false) then 
						SAK.settings.DEPOSIT_TELVAR = false
					else
						SAK.settings.DEPOSIT_TELVAR = true
					end
			ReloadUI("ingame")
			end,
		warning = zo_strformat("|cff0000<<1>>|r", SAK.lang.KF_GENERAL_ST_3),
		default = SAK.settings.DEPOSIT_TELVAR
    	},
	[7] = {
              type = "slider",
              name = zo_strformat("<<1>> <<2>>", SAK.TelVarIcon, SAK.lang.KF_SLASH_19),
              tooltip = zo_strformat("<<1>> <<2>> <<3>>", SAK.lang.KF_SLASH_21, SAK.settings.MINIMUM_TELVAR_SAVINGS, SAK.TelVarIcon),
              min = 0,
              max = 10000,
	      step = 10,
              getFunc = function() return SAK.settings.MINIMUM_TELVAR_SAVINGS end,
              setFunc = function(value) setStones(value) end,
		default = SAK.settings.MINIMUM_TELVAR_SAVINGS
         },
	[8] = {
        	type = "checkbox",
              name = SAK.lang.KF_DEPOSIT_ALLIANCE,
              tooltip = SAK.lang.KF_DEPOSIT_ALLIANCE,
              getFunc = function() return SAK.settings.DEPOSIT_ALLIANCE end,
              setFunc = function(value) if(value == false) then 
						SAK.settings.DEPOSIT_ALLIANCE = false
					else
						SAK.settings.DEPOSIT_ALLIANCE = true
					end
			ReloadUI("ingame")
			end,
		warning = zo_strformat("|cff0000<<1>>|r", SAK.lang.KF_GENERAL_ST_3),
		default = SAK.settings.DEPOSIT_ALLIANCE
    	},
	[9] = {
              type = "slider",
              name = zo_strformat("<<1>> <<2>>", SAK.AlliIcon, SAK.lang.KF_ALLI_1),
              tooltip = zo_strformat("<<1>> <<2>> <<3>>", SAK.lang.KF_SLASH_21, SAK.settings.MINIMUM_ALLIANCE_SAVINGS, SAK.AlliIcon),
              min = 0,
              max = 10000,
	      step = 10,
              getFunc = function() return SAK.settings.MINIMUM_ALLIANCE_SAVINGS end,
              setFunc = function(value) setStonesAlliance(value) end,
		default = SAK.settings.MINIMUM_ALLIANCE_SAVINGS
         },
	[10] = {
        	type = "checkbox",
              name = SAK.lang.KF_DEPOSIT_WRIT,
              tooltip = SAK.lang.KF_DEPOSIT_WRIT,
              getFunc = function() return SAK.settings.DEPOSIT_WRIT end,
              setFunc = function(value) if(value == false) then 
						SAK.settings.DEPOSIT_WRIT = false
					else
						SAK.settings.DEPOSIT_WRIT = true
					end
			ReloadUI("ingame")
			end,
		warning = zo_strformat("|cff0000<<1>>|r", SAK.lang.KF_GENERAL_ST_3),
		default = SAK.settings.DEPOSIT_WRIT
    	},
	[11] = {
              type = "slider",
              name = zo_strformat("<<1>> <<2>>", SAK.IconVoucher, SAK.lang.KF_ALLI_3),
              tooltip = zo_strformat("<<1>> <<2>> <<3>>", SAK.lang.KF_ALLI_4, SAK.settings.MINIMUM_WRITVOUCHER_SAVINGS, SAK.IconVoucher),
              min = 0,
              max = 200,
	      step = 1,
              getFunc = function() return SAK.settings.MINIMUM_WRITVOUCHER_SAVINGS end,
              setFunc = function(value) setWritVoucher(value) end,
		default = SAK.settings.MINIMUM_WRITVOUCHER_SAVINGS
         },
	[12] = {
			type = "header",
			name = zo_strformat("|c3f7fff<<1>>|r", SAK.lang.KF_TELVAR)
	},
	[13] = {
              type = "checkbox",
              name = SAK.lang.KF_TELVAR_1,
              tooltip = SAK.lang.KF_TELVAR_2,
              getFunc = function() return SAK.settings.DISPLAY_ALARM_TELVAR end,
              setFunc = function(value) if(value == false) then 
						SAK.settings.DISPLAY_ALARM_TELVAR = false
					else
						SAK.settings.DISPLAY_ALARM_TELVAR = true
					end
			end,
		default = SAK.settings.DISPLAY_ALARM_TELVAR
         },
	[14] = {
              type = "slider",
              name = zo_strformat("<<1>> <<2>>", SAK.TelVarIcon, SAK.lang.KF_TELVAR_3),
              tooltip = zo_strformat("<<1>> <<2>>", SAK.lang.KF_TELVAR_4, SAK.lang.KF_TELVAR_2),
              min = 0,
              max = 10000,
	      step = 10,
              getFunc = function() return SAK.settings.MAXIMUM_TELVAR_SAVINGS end,
              setFunc = function(value) setStonesAlarm(value) end,
		default = SAK.settings.MAXIMUM_TELVAR_SAVINGS
         },
	},
	},
	[14] = {
        type = "submenu",
        name = SAK.lang.KF_SETTINGS_1_1,
        controls = {
	[1] = {
			type = "header",
			name = zo_strformat("|c3f7fff<<1>>|r", SAK.lang.KF_SEUIL_REP_1)
	},
	[2] = {
              type = "slider",
              name = zo_strformat("<<1>>", SAK.lang.KF_SEUIL_REP_2),
              tooltip = zo_strformat("<<1>>", SAK.lang.KF_SEUIL_REP_3),
              min = 0,
              max = 100,
              getFunc = function() return SAK.settings.SEUIL_REPAIR end,
              setFunc = function(value) setSeuil(value) end,
		default = SAK.settings.SEUIL_REPAIR
         },
	[3] = {
		type = "colorpicker",
		name = SAK.lang.KF_SEUIL_REP_6,
		tooltip = SAK.lang.KF_SEUIL_REP_6_2,
		getFunc = function()
			return SAK.settings.colour.r, SAK.settings.colour.g, SAK.settings.colour.b, SAK.settings.colour.a
		end,
		setFunc = function(r,g,b,a)
			SAK.settings.colour = {r=r,g=g,b=b,a=a}
			updateUI()
		end,
		default = SAK.settings.colour
	},
	[4] = {
		type = "colorpicker",
		name = SAK.lang.KF_SEUIL_REP_7,
		tooltip = SAK.lang.KF_SEUIL_REP_7_2,
		getFunc = function()
			return SAK.settings.colorTexte.r, SAK.settings.colorTexte.g, SAK.settings.colorTexte.b, SAK.settings.colorTexte.a
		end,
		setFunc = function(r,g,b,a)
			SAK.settings.colorTexte = {r=r,g=g,b=b,a=a}
			updateUI()
		end,
		default = SAK.settings.colorTexte
	},
	[5] = {
			type = "header",
			name = zo_strformat("|c3f7fff<<1>>|r", SAK.lang.KF_SEUIL_REPA_1)
	},
	[6] = {
              type = "slider",
              name = zo_strformat("<<1>>", SAK.lang.KF_SEUIL_REPA_2),
              tooltip = zo_strformat("<<1>>", SAK.lang.KF_SEUIL_REPA_3),
              min = 0,

              max = 100,
              getFunc = function() return SAK.settings.SEUIL_REPAIR_ARM end,
              setFunc = function(value) setSeuil_arm(value) end,
		default = SAK.settings.SEUIL_REPAIR_ARM
         },
	[7] = {
		type = "colorpicker",
		name = SAK.lang.KF_SEUIL_REPA_6,
		tooltip = SAK.lang.KF_SEUIL_REPA_6_2,
		getFunc = function()
			return SAK.settings.colour_arm.r, SAK.settings.colour_arm.g, SAK.settings.colour_arm.b, SAK.settings.colour_arm.a
		end,
		setFunc = function(r,g,b,a)
			SAK.settings.colour_arm = {r=r,g=g,b=b,a=a}
			updateUI()
		end,
		default = SAK.settings.colour_arm
	},
	[8] = {
		type = "colorpicker",
		name = SAK.lang.KF_SEUIL_REPA_7,
		tooltip = SAK.lang.KF_SEUIL_REPA_7_2,
		getFunc = function()
			return SAK.settings.colorTexte_arm.r, SAK.settings.colorTexte_arm.g, SAK.settings.colorTexte_arm.b, SAK.settings.colorTexte_arm.a
		end,
		setFunc = function(r,g,b,a)
			SAK.settings.colorTexte_arm = {r=r,g=g,b=b,a=a}
			updateUI()
		end,
		default = SAK.settings.colorTexte_arm
	},
	[9] = {
			type = "header",
			name = zo_strformat("|c3f7fff<<1>>|r", SAK.lang.KF_AUTO_REPA_1)
	},
	[10] = {
              type = "checkbox",
              name = SAK.lang.KF_AUTO_REPA_2,
              tooltip = SAK.lang.KF_AUTO_REPA_2,
              getFunc = function() return SAK.settings.DISPLAY_REPAIR end,
              setFunc = function(value) if(value == false) then 
						SAK.settings.DISPLAY_REPAIR = false
						SAK.settings.DISPLAY_REPAIR_TXT = false
					else
						SAK.settings.DISPLAY_REPAIR = true
						SAK.settings.DISPLAY_REPAIR_TXT = true
					end
			end,
		default = SAK.settings.DISPLAY_REPAIR
         },
	[11] = {
              type = "checkbox",
              name = SAK.lang.KF_AUTO_REPA_4,
              tooltip = SAK.lang.KF_AUTO_REPA_4,
              getFunc = function() return SAK.settings.DISPLAY_REPAIR_TXT end,
              setFunc = function(value) if(value == false) then 
						SAK.settings.DISPLAY_REPAIR_TXT = false
					else
						SAK.settings.DISPLAY_REPAIR_TXT = true
					end
			end,
		default = SAK.settings.DISPLAY_REPAIR_TXT
         },
	[12] = {
			type = "header",
			name = zo_strformat("|c3f7fff<<1>>|r", SAK.lang.KF_AUTO_REPA_6)
	},
	[13] = {
              type = "checkbox",
              name = SAK.lang.KF_AUTO_REPA_7,
              tooltip = SAK.lang.KF_AUTO_REPA_7,
              getFunc = function() return SAK.settings.DISPLAY_RECHARGE end,
              setFunc = function(value) if(value == false) then 
						SAK.settings.DISPLAY_RECHARGE = false
						SAK.settings.DISPLAY_RECHARGE_TXT = false
					else
						SAK.settings.DISPLAY_RECHARGE = true
						SAK.settings.DISPLAY_RECHARGE_TXT = true
					end
			end,
		default = SAK.settings.DISPLAY_RECHARGE
         },
	[14] = {
              type = "checkbox",
              name = SAK.lang.KF_AUTO_REPA_9,
              tooltip = SAK.lang.KF_AUTO_REPA_9,
              getFunc = function() return SAK.settings.DISPLAY_RECHARGE_TXT end,
              setFunc = function(value) if(value == false) then 
						SAK.settings.DISPLAY_RECHARGE_TXT = false
					else
						SAK.settings.DISPLAY_RECHARGE_TXT = true
					end
			end,
		default = SAK.settings.DISPLAY_RECHARGE_TXT
         },
	[15] = {
              type = "slider",
              name = zo_strformat("<<1>>", SAK.lang.KF_AUTO_REPA_10),
              tooltip = zo_strformat("<<1>>", SAK.lang.KF_AUTO_REPA_10),
              min = 0,
              max = 100,
              getFunc = function() return SAK.settings.SEUIL_CHARGE_AUTO end,
              setFunc = function(value) setSeuilAutoCharge(value) end,
		default = SAK.settings.SEUIL_CHARGE_AUTO
         },
	},
	},
	[15] = {
        type = "submenu",
        name = SAK.lang.KF_SETTINGS_2_1,
        controls = {
    	   [1] = {
        	type = "description",
        	title = nil,	--(optional)
        	text = zo_strformat("|cff0000<<1>>|r", SAK.lang.KF_SETTINGS_3_1),
        	width = "full",	--or "half" (optional)
    		},
	    [2] = {
        	type = "header",
        	name = zo_strformat("|cff6600<<1>>|r", SAK.lang.KF_SETTINGS_4),
        	width = "full",	--or "half" (optional)
    		},
            [3] = {
                type = "editbox",
                name = zo_strformat("<<1>>", SAK.lang.KF_SETTINGS_5),
                getFunc = function() return SAK.settings.SAY_HELLO end,
                setFunc = function(text) SAK.settings.SAY_HELLO = text end,
                isMultiline = true,	--boolean
                width = "full",	--or "half" (optional)
                default = SAK.settings.SAY_HELLO
            },
	    [4] = {
                type = "editbox",
                name = zo_strformat("<<1>>", SAK.lang.KF_SETTINGS_6),
                getFunc = function() return SAK.settings.SAY_THANKS end,
                setFunc = function(text) SAK.settings.SAY_THANKS=text end,
                isMultiline = true,	--boolean
                width = "full",	--or "half" (optional)
                default = SAK.settings.SAY_THANKS
            },
		[5] = {
        	type = "header",
        	name = zo_strformat("|c00ffe6<<1>>|r", SAK.lang.KF_SETTINGS_7),
        	width = "full",	--or "half" (optional)
    		},
	    [6] = {
                type = "editbox",
                name = zo_strformat("<<1>>", SAK.lang.KF_SETTINGS_8),
                getFunc = function() return SAK.settings.SAY_PLOP end,
                setFunc = function(text) SAK.settings.SAY_PLOP=text end,
                isMultiline = true,	--boolean
                width = "full",	--or "half" (optional)
                default = SAK.settings.SAY_PLOP
            },
		[7] = {
        	type = "header",
        	name = zo_strformat("|c33cc33<<1>>|r", SAK.lang.KF_SETTINGS_9),
        	width = "full",	--or "half" (optional)
    		},
	    [8] = {
                type = "editbox",
                name = zo_strformat("<<1>>", SAK.lang.KF_SETTINGS_10),
                getFunc = function() return SAK.settings.SAY_GUILD_1 end,
                setFunc = function(text) SAK.settings.SAY_GUILD_1=text end,
                isMultiline = true,	--boolean
                width = "full",	--or "half" (optional)
                default = SAK.settings.SAY_GUILD_1
            },
	    [9] = {
                type = "editbox",
                name = zo_strformat("<<1>>", SAK.lang.KF_SETTINGS_11),
                getFunc = function() return SAK.settings.SAY_GUILD_2 end,
                setFunc = function(text) SAK.settings.SAY_GUILD_2=text end,
                isMultiline = true,	--boolean
                width = "full",	--or "half" (optional)
                default = SAK.settings.SAY_GUILD_2
            },
	    [10] = {
                type = "editbox",
                name = zo_strformat("<<1>>", SAK.lang.KF_SETTINGS_12),
                getFunc = function() return SAK.settings.SAY_GUILD_3 end,
                setFunc = function(text) SAK.settings.SAY_GUILD_3=text end,
                isMultiline = true,	--boolean
                width = "full",	--or "half" (optional)
                default = SAK.settings.SAY_GUILD_3
            },
	    [11] = {
                type = "editbox",
                name = zo_strformat("<<1>>", SAK.lang.KF_SETTINGS_13),
                getFunc = function() return SAK.settings.SAY_GUILD_4 end,
                setFunc = function(text) SAK.settings.SAY_GUILD_4=text end,
                isMultiline = true,	--boolean
                width = "full",	--or "half" (optional)

                default = SAK.settings.SAY_GUILD_4

            },
	    [12] = {
                type = "editbox",
                name = zo_strformat("<<1>>", SAK.lang.KF_SETTINGS_14),
                getFunc = function() return SAK.settings.SAY_GUILD_5 end,
                setFunc = function(text) SAK.settings.SAY_GUILD_5=text end,
                isMultiline = true,	--boolean
                width = "full",	--or "half" (optional)
                default = SAK.settings.SAY_GUILD_5
            },
        },
    },
	[16] = {
        type = "submenu",
        name = SAK.lang.KF_HOUSE_1,
        controls = {
    	   [1] = {
        	type = "description",
        	title = nil,	--(optional)
        	text = zo_strformat("|cffffff<<1>>|r", SAK.lang.KF_HOUSE_2),
        	width = "full",	--or "half" (optional)
    		},
	    [2] = {
        	type = "header",
        	name = zo_strformat("|cff6600<<1>>|r", SAK.settings.BASE_HOME),
        	width = "full",	--or "half" (optional)
    		},
	    [3] = {
        	type = "button",
        	name = SAK.lang.KF_HOUSE_3,
        	func = function() JollyJumper() end,
        	width = "full",	--or "half" (optional)
    		},
        },
    },[17] = {
        type = "submenu",
        name = SAK.lang.KF_THIEF_1,
        controls = {
	[1] = {
        	type = "header",
        	name = zo_strformat("|cff6600<<1>>|r", SAK.lang.KF_THIEF_1),
        	width = "full",	--or "half" (optional)
    		},
	    [2] = {
        	type = "checkbox",
                name = zo_strformat("<<1>>", SAK.lang.KF_THIEF_3),
		tooltip = SAK.lang.KF_THIEF_2,
		getFunc = function() return SAK.settings.DISPLAY_WARNING end,
              	setFunc = function(value) if(value == false) then 
						SAK.settings.DISPLAY_WARNING = false
					else
						SAK.settings.DISPLAY_WARNING = true
					end
			end,
                default = SAK.settings.DISPLAY_WARNING
    		},
	[3] = {
        	type = "checkbox",
                name = zo_strformat("<<1>> <<2>><<3>>", SAK.lang.KF_THIEF_6, SAK.heatIcon, SAK.heatIconWhite),
		tooltip = SAK.lang.KF_THIEF_2,
		getFunc = function() return SAK.settings.DISPLAY_HEAT end,
              	setFunc = function(value) if(value == false) then 
						SAK.settings.DISPLAY_HEAT = false
					else
						SAK.settings.DISPLAY_HEAT = true
					end
			end,
                default = SAK.settings.DISPLAY_HEAT
    		},
	[4] = {
        	type = "checkbox",
                name = zo_strformat("<<1>> <<2>>", SAK.lang.KF_THIEF_7, SAK.daggerIconRed),
		tooltip = SAK.lang.KF_THIEF_2,
		getFunc = function() return SAK.settings.DISPLAY_DAGGER end,
              	setFunc = function(value) if(value == false) then 
						SAK.settings.DISPLAY_DAGGER = false
					else
						SAK.settings.DISPLAY_DAGGER = true
					end
			end,
                default = SAK.settings.DISPLAY_DAGGER
    		},
        },
    },
	[18] = {
        type = "submenu",
        name = "BAG & BANK SIZE",
        controls = {
	[1] = {
			type = "header",
			name = zo_strformat("|c3f7fff<<1>>|r", "BAG & BANK")
	},
	[2] = {
              type = "slider",
              name = zo_strformat("<<1>> <<2>>", SAK.BagIcon, SAK.lang.KF_BAG_1),
              tooltip = zo_strformat("<<1>>", SAK.lang.KF_BAG_2),
              min = 0,
              max = GetBagSize(BAG_BACKPACK),
	      step = 1,
              getFunc = function() return SAK.settings.MIN_BAG_TRESHOLD end,
              setFunc = function(value) setBagSizeTreshold(value) end,
		default = SAK.settings.MIN_BAG_TRESHOLD
         },
	[3] = {
        	type = "checkbox",
                name = SAK.lang.KF_JUNK_5,
		tooltip = SAK.lang.KF_JUNK_6,
		getFunc = function() return SAK.settings.DISPLAY_JUNK_BAG end,
              	setFunc = function(value) if(value == false) then 
						SAK.settings.DISPLAY_JUNK_BAG = false
					else
						SAK.settings.DISPLAY_JUNK_BAG = true
					end
			end,
                default = SAK.settings.DISPLAY_JUNK_BAG
    		},
	},
	},
	[19] = {
        type = "submenu",
        name = "WRIT HELPER WINDOW",
        controls = {
	[1] = {
			type = "header",
			name = zo_strformat("|c3f7fff<<1>>|r", "WRIT WINDOW")
	},
	[2] = {
        	type = "checkbox",
                name = SAK.lang.KF_WRIT_HELPER_1,
		tooltip = SAK.lang.KF_WRIT_HELPER_2,
		getFunc = function() return SAK.settings.DISPLAY_WRITHELPER_WINDOW end,
              	setFunc = function(value) if(value == false) then 
						SAK.settings.DISPLAY_WRITHELPER_WINDOW = false
					else
						SAK.settings.DISPLAY_WRITHELPER_WINDOW = true
					end
			end,
                default = SAK.settings.DISPLAY_WRITHELPER_WINDOW
    		},
	[3] = {
        	type = "checkbox",
                name = SAK.lang.KF_WRIT_HELPER_3,
		tooltip = SAK.lang.KF_WRIT_HELPER_4,
		getFunc = function() return SAK.settings.DISPLAY_WRITHELPER_WINDOW_WARNING end,
              	setFunc = function(value) if(value == false) then 
						SAK.settings.DISPLAY_WRITHELPER_WINDOW_WARNING = false
					else
						SAK.settings.DISPLAY_WRITHELPER_WINDOW_WARNING = true
					end
			end,
                default = SAK.settings.DISPLAY_WRITHELPER_WINDOW_WARNING
    		},
	[4] = {
        	type = "checkbox",
                name = SAK.lang.KF_WRIT_HELPER_5,
		tooltip = SAK.lang.KF_WRIT_HELPER_6,
		getFunc = function() return SAK.settings.DISPLAY_WRITHELPER_WINDOW_LFG end,
              	setFunc = function(value) if(value == false) then 
						SAK.settings.DISPLAY_WRITHELPER_WINDOW_LFG = false
					else
						SAK.settings.DISPLAY_WRITHELPER_WINDOW_LFG = true
					end
			end,
                default = SAK.settings.DISPLAY_WRITHELPER_WINDOW_LFG
    		},
	},
	},
	[20] = {
        type = "submenu",
        name = "Donations",
        controls = {
		[1] = {
        	type = "description",
        	title = nil,	
        	text = zo_strformat("|cffffff<<1>>|r", SAK.lang.KF_DONATE_1),
        	width = "full",	
    		},
		[2] = {
        	type = "button",
        	name = SAK.lang.KF_DONATE_7,
        	tooltip = "",
        	func = function() SendGold(0) end,
        	width = "full",	
    		},
		[3] = {
        	type = "header",
        	name = zo_strformat("|c3f7fff<<1>>|r", SAK.lang.KF_DONATE_2),
        	width = "full",	
    		},
		[4] = {
        	type = "button",
        	name = SAK.lang.KF_DONATE_3,
        	tooltip = "",
        	func = function() SendGold(100) end,
        	width = "half",	
    		},
		[5] = {
        	type = "button",
        	name = SAK.lang.KF_DONATE_4,
        	tooltip = "",
        	func = function() SendGold(1000) end,
        	width = "half",	
    		},
		[6] = {
        	type = "button",
        	name = SAK.lang.KF_DONATE_5,
        	tooltip = "",
        	func = function() SendGold(10000) end,
        	width = "half",	
    		},
		[7] = {
        	type = "button",
        	name = SAK.lang.KF_DONATE_6,
        	tooltip = "",
        	func = function() SendGold(100000) end,
        	width = "half",	
    		},
        },
	},
    }

	
    	LAM2:RegisterOptionControls(MYSETTINGSNAME, KFoptionsTable)
end


