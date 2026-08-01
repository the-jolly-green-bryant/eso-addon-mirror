local em = GetEventManager()

local base_CombatAlertsCombatEvent = CombatAlerts.CombatEvent
local base_CombatAlertsPoll = CombatAlerts.Poll
local base_CombatAlertsPlayerActivated = CombatAlerts.PlayerActivated
local base_CombatAlertsStartListenting = CombatAlerts.StartListening
local base_CombatAlertsStopListenting = CombatAlerts.StopListening

CombatAlerts.at = {}
CombatAlerts.bloodforge = {}
CombatAlerts.sc = {}
CombatAlerts.moonhunter = {}
CombatAlerts.sc.ratAchEnabled = false
CombatAlerts.sc.isRatAchFailed = false
CombatAlerts.bloodforge.nirnAchEnabled = false
CombatAlerts.bloodforge.isAchFailed = false
CombatAlerts.moonhunter.isShortLeashFailed = false

if CombatAlertsExtended == nil then CombatAlertsExtended = {} end

CombatAlertsExtended.savedVariablesDefault = {
	Settings = {
		CoralAerie = {
			MentalWound = true,
			BlastPowder = true,
			Tether = true,
			HAVarallion = true
		},
		ShipwrightsRegret = {
			Flame = true,
			SoulBomb = true
		},
		Others = {
			PustulentProblems = true,
			CoolingYourHeels = true,
			DSRRunestones = true,
			MHKShortLeash = true,
			ASPositions = true,
			NymicSecrets = true
		}
	}
}

CombatAlertsExtended.stormIsActive = false
CombatAlertsExtended.TetherID = -1
CombatAlertsExtended.langs = {}
CombatAlertsExtended.selectedLang = {}
CombatAlertsExtended.langs.ru = {
	ADDONMENU_DONATE_TOOLTIP = "Если мой аддон помог вам в чем-либо, то буду признателен любой поддержке (только EU сервер)",
	ADDONMENU_CORALAERIE_HEADER = "Коралловое гнездо",
	ADDONMENU_SHIPWRIGHTSREGRET_HEADER = "Горе корабела",
	ADDONMENU_OTHERS_HEADER = "Прочее",
	ADDONMENU_CORALAERIE_MENTALWOUND = "Разрушение разума",
	ADDONMENU_CORALAERIE_MENTALWOUND_TOOLTIP = "Переключить отображение таймера умения 'Разрушение разума'",
	ADDONMENU_CORALAERIE_BLASTPOWDER = "Blast Powder",
	ADDONMENU_CORALAERIE_BLASTPOWDER_TOOLTIP = "Переключить отображение умения 'Blast Powder'",
	ADDONMENU_CORALAERIE_TETHER = "Связь",
	ADDONMENU_CORALAERIE_TETHER_TOOLTIP = "Переключить отображение таймера умения 'Связь'",
	ADDONMENU_CORALAERIE_HA_VARRALION = "'Уничтожение' Вараллиона",
	ADDONMENU_CORALAERIE_HA_VARRALION_TOOLTIP = "Переключить отображение HA атаки Вараллиона, когда он ее использует против игрока, не являющимся танком",
	ADDONMENU_SHIPWRIGHTSREGRET_FLAME = "Пламя",
	ADDONMENU_SHIPWRIGHTSREGRET_FLAME_TOOLTIP = "Переключить отображение умения склетов 'Пламя'",
	ADDONMENU_SHIPWRIGHTSREGRET_SOULBOMB = "Мина душ",
	ADDONMENU_SHIPWRIGHTSREGRET_SOULBOMB_TOOLTIP = "Переключить отображение рекомендуемого стака игроков во время способности 'Мина душ'",
	ADDONMENU_OTHERS_PUSTULENTPROBLEMS = "Достижение 'Гнойные проблемы'",
	ADDONMENU_OTHERS_PUSTULENTPROBLEMS_TOOLTIP = "Переключить отслеживание выполения достижения 'Гнойные проблемы' Пика призывательницы дракона",
	ADDONMENU_OTHERS_COOLINGYOURHEELS = "Достижение 'Ноги в холоде'",
	ADDONMENU_OTHERS_COOLINGYOURHEELS_TOOLTIP = "Переключить отслеживание выполения достижения 'Ноги в холоде' Кузницы кровавого корня",
	ADDONMENU_OTHERS_DSRRUNESTONES = "Скрытые руны DSR",
	ADDONMENU_OTHERS_DSRRUNESTONES_TOOLTIP = "Переключить отображение 3д-меток в триале DSR, где может быть найдена руна (требуется OdySupportIcons)",
	ADDONMENU_OTHERS_MHKSHORTLEASH = "Достижение 'На коротком поводке'",
	ADDONMENU_OTHERS_MHKSHORTLEASH_TOOLTIP = "Переключить отслеживание выполения достижения 'На коротком поводке' Крепости лунного охотника",
	ADDONMENU_OTHERS_ASSHOWPOS = "Отображение позиций в AS",
	ADDONMENU_OTHERS_ASSHOWPOS_TOOLTIP = "Отображение позиций ДД и кайта в AS на Олмсе (требуется OdySupportIcons). При переключении требуется перезагрузка интерфейса",
	ADDONMENU_OTHERS_NYMIC_SECRETS = "Отображение головоломок в оплоте Нимик",
	ADDONMENU_OTHERS_NYMIC_SECRETS_TOOLTIP = "Отображение подсказок для головомок в оплоте Нимик (требуется odySupportIcons). При переключении требуется перезагрузка интерфейса"
}
CombatAlertsExtended.langs.en = {
	ADDONMENU_DONATE_TOOLTIP = "If my addon helped you in anything, then I will be grateful for any support (EU server only)",
	ADDONMENU_CORALAERIE_HEADER = "Coral Aerie",
	ADDONMENU_SHIPWRIGHTSREGRET_HEADER = "Shipwright's Regret",
	ADDONMENU_OTHERS_HEADER = "Others",
	ADDONMENU_CORALAERIE_MENTALWOUND = "Mental Wound",
	ADDONMENU_CORALAERIE_MENTALWOUND_TOOLTIP = "Switch cast timer display for Varallion's 'Tether' HM ability",
	ADDONMENU_CORALAERIE_BLASTPOWDER = "Blast Powder",
	ADDONMENU_CORALAERIE_BLASTPOWDER_TOOLTIP = "Switch cast display for Sarydil's 'Blast Powder' ability",
	ADDONMENU_CORALAERIE_TETHER = "Tether",
	ADDONMENU_CORALAERIE_TETHER_TOOLTIP = "Switch cast timer display for Varallion's 'Tether' HM ability",
	ADDONMENU_CORALAERIE_HA_VARRALION = "Varallion's Heavy Attack",
	ADDONMENU_CORALAERIE_HA_VARRALION_TOOLTIP = "Switch cast display of Varralion's heavy attack, when he casts it not on a tank",
	ADDONMENU_SHIPWRIGHTSREGRET_FLAME = "Flame",
	ADDONMENU_SHIPWRIGHTSREGRET_FLAME_TOOLTIP = "Switch cast warning for skeleton's 'Flame' ability",
	ADDONMENU_SHIPWRIGHTSREGRET_SOULBOMB = "Soul Bomb",
	ADDONMENU_SHIPWRIGHTSREGRET_SOULBOMB_TOOLTIP = "Switch hint with recommended group stack for Foreman Bradiggan's 'Soul bomb' HM",
	ADDONMENU_OTHERS_PUSTULENTPROBLEMS = "'Pustulent Problems' achievement",
	ADDONMENU_OTHERS_PUSTULENTPROBLEMS_TOOLTIP = "Switch tracking of 'Pustulent Problems' achievement",
	ADDONMENU_OTHERS_COOLINGYOURHEELS = "'Cooling Your Heels' achievement",
	ADDONMENU_OTHERS_COOLINGYOURHEELS_TOOLTIP = "Switch tracking of 'Cooling Your Heels' achievement",
	ADDONMENU_OTHERS_DSRRUNESTONES = "Hidden runes DSR",
	ADDONMENU_OTHERS_DSRRUNESTONES_TOOLTIP = "Switch 3D-markers in the DSR trial, where you can find runestones (requires OdySupportIcons)",
	ADDONMENU_OTHERS_MHKSHORTLEASH = "'On a Short Leash' achievement",
	ADDONMENU_OTHERS_MHKSHORTLEASH_TOOLTIP = "Switch tracking of 'On a Short Leash' achievement",
	ADDONMENU_OTHERS_ASSHOWPOS = "Show positions in AS",
	ADDONMENU_OTHERS_ASSHOWPOS_TOOLTIP = "Switch DD positions and their kite in AS (requires OdySupportIcons). This option requires reload UI",
	ADDONMENU_OTHERS_NYMIC_SECRETS = "Show secrets in Nymic bastion",
	ADDONMENU_OTHERS_NYMIC_SECRETS_TOOLTIP = "Show additional hints for Nymic's secrects (requires OdySupportIcons). This option requires reload UI"
}

function CombatAlertsExtended.Clear3DMarkers(array)
	for i in pairs(array) do
        OSI.DiscardPositionIcon(array[i])
    end
	array = {}
end

function CombatAlerts.StartListening()
	local db = CombatAlertsExtended.savedVariables.Settings
	
	if ((CombatAlerts.zoneId == 1344) and (OSI ~= nil) and (db.Others.DSRRunestones)) then
		CombatAlertsExtended.DreadSailRunestones(false)
	end
	base_CombatAlertsStartListenting()
end

function CombatAlerts.StopListening()
	local db = CombatAlertsExtended.savedVariables.Settings
	if ((CombatAlerts.zoneId == 1344) and (OSI ~= nil) and (db.Others.DSRRunestones)) then
		CombatAlertsExtended.DreadSailRunestones(true)
	end
	CombatAlerts.moonhunter.isShortLeashFailed = false
	
	if (CombatAlertsExtended.TetherID > 0) then
		CombatAlerts.CastAlertsStop(CombatAlertsExtended.TetherID)
	end
	
	base_CombatAlertsStopListenting()
end

function CombatAlertsExtended.ASPlayerPositions(mode)
	local playerPositions = {
		["ddpos1"] = {x = 97017, y = 61450, z = 100718, texture = "odysupporticons/icons/squares/squaretwo_red_one.dds", size = 100, color = {1,1,1,1}},
		["ddpos2"] = {x = 97512, y = 61450, z = 100251, texture = "odysupporticons/icons/squares/squaretwo_red_two.dds", size = 100, color = {1,1,1,1}},
		["ddpos3"] = {x = 98061, y = 61450, z = 99869, texture = "odysupporticons/icons/squares/squaretwo_red_three.dds", size = 100, color = {1,1,1,1}},
		["ddpos4"] = {x = 98581, y = 61450, z = 99669, texture = "odysupporticons/icons/squares/squaretwo_red_four.dds", size = 100, color = {1,1,1,1}},
		["ddpos5"] = {x = 99084, y = 61450, z = 99648, texture = "odysupporticons/icons/squares/squaretwo_red_five.dds", size = 100, color = {1,1,1,1}},
		["ddpos6"] = {x = 99547, y = 61450, z = 99714, texture = "odysupporticons/icons/squares/squaretwo_red_six.dds", size = 100, color = {1,1,1,1}},
		["ddpos7"] = {x = 100146, y = 61450, z = 100134, texture = "odysupporticons/icons/squares/squaretwo_red_seven.dds", size = 100, color = {1,1,1,1}},
		["ddpos8"] = {x = 100730, y = 61450, z = 100697, texture = "odysupporticons/icons/squares/squaretwo_red_eight.dds", size = 100, color = {1,1,1,1}}
	}
	
	if (mode) then
		local function enableIcon(name)
			local iconData = playerPositions[name]
			local icon = OSI.CreatePositionIcon(iconData.x, iconData.y, iconData.z, iconData.texture, iconData.size, iconData.color)
			CombatAlertsExtended.icons[name] = icon
		end
		
		enableIcon("ddpos1")
		enableIcon("ddpos2")
		enableIcon("ddpos3")
		enableIcon("ddpos4")
		enableIcon("ddpos5")
		enableIcon("ddpos6")
		enableIcon("ddpos7")
		enableIcon("ddpos8")
	else
		if (CombatAlertsExtended.icons["ddpos1"] ~= nil) then
			CombatAlertsExtended.Clear3DMarkers(CombatAlertsExtended.icons)
		end
	end
end

function CombatAlertsExtended.NymicPositions(mode)
	local redPositions = {
		["Rhint1"] = {x = 54164, y = 54700, z = 86008, texture = "CombatAlertsExtended/icons/bastion_1.dds", color = {1,1,1,1}},
		["Rhint2"] = {x = 54483, y = 54700, z = 86427, texture = "CombatAlertsExtended/icons/bastion_2.dds", color = {1,1,1,1}},
		["Rhint3"] = {x = 54751, y = 54700, z = 86878, texture = "CombatAlertsExtended/icons/bastion_3.dds", color = {1,1,1,1}},
		["Rhint4"] = {x = 54932, y = 54700, z = 87344, texture = "CombatAlertsExtended/icons/bastion_4.dds", color = {1,1,1,1}}
	}

	local bluePositions = {
		["Bstatue1"] = {x = 61346, y = 55152, z = 60106, texture = "odysupporticons/icons/arrow.dds", color = {0.5490,0.6627,0.995,1}},
		["Bstatue2"] = {x = 72239, y = 55391, z = 42506, texture = "odysupporticons/icons/arrow.dds", color = {0.5490,0.6627,0.995,1}},
		["Bstatue3"] = {x = 86345, y = 56259, z = 54010, texture = "odysupporticons/icons/arrow.dds", color = {0.5490,0.6627,0.995,1}},
		["Bstatue4"] = {x = 63861, y = 55241, z = 48887, texture = "odysupporticons/icons/arrow.dds", color = {0.5490,0.6627,0.995,1}},
		["BHunger1"] = {x = 83495, y = 55257, z = 38870, texture = "CombatAlertsExtended/icons/hunger.dds", color = {1,1,1,1}},
		["BHunger2"] = {x = 78026, y = 54074, z = 47565, texture = "CombatAlertsExtended/icons/hunger.dds", color = {1,1,1,1}},
		["BHunger3"] = {x = 93574, y = 55107, z = 59082, texture = "CombatAlertsExtended/icons/hunger.dds", color = {1,1,1,1}},
		["BHunger4"] = {x = 60652, y = 55134, z = 61004, texture = "CombatAlertsExtended/icons/hunger.dds", color = {1,1,1,1}}
	}

	local greenPositions = {
		["Gred1"] 	= {x = 95369, y = 55262, z = 65477, texture = "odysupporticons/icons/arrow.dds", color = {0.8078,0.1764,0.1764,1}},
		["Gred2"] 	= {x = 101691, y = 56929, z = 81289, texture = "odysupporticons/icons/arrow.dds", color = {0.8078,0.1764,0.1764,1}},
		["Gred3"] 	= {x = 76603, y = 55302, z = 95987, texture = "odysupporticons/icons/arrow.dds", color = {0.8078,0.1764,0.1764,1}},
		["Gred4"] 	= {x = 77517, y = 55282, z = 100020, texture = "odysupporticons/icons/arrow.dds", color = {0.8078,0.1764,0.1764,1}},
		["Gred5"] 	= {x = 106904, y = 54991, z = 83875, texture = "odysupporticons/icons/arrow.dds", color = {0.8078,0.1764,0.1764,1}},
		["Gred6"] 	= {x = 93556, y = 54991, z = 74646, texture = "odysupporticons/icons/arrow.dds", color = {0.8078,0.1764,0.1764,1}},
		["Ggreen1"] = {x = 95533, y = 55258, z = 65109, texture = "odysupporticons/icons/arrow.dds", color = {0.5725,0.8274,0.2078,1}},
		["Ggreen2"] = {x = 98444, y = 54991, z = 98259, texture = "odysupporticons/icons/arrow.dds", color = {0.5725,0.8274,0.2078,1}},
		["Ggreen3"] = {x = 90797, y = 53691, z = 91100, texture = "odysupporticons/icons/arrow.dds", color = {0.5725,0.8274,0.2078,1}},
		["Ggreen4"] = {x = 76930, y = 55292, z = 100099, texture = "odysupporticons/icons/arrow.dds", color = {0.5725,0.8274,0.2078,1}},
		["Ggreen5"] = {x = 87837, y = 53491, z = 91439, texture = "odysupporticons/icons/arrow.dds", color = {0.5725,0.8274,0.2078,1}},
		["Ggreen6"] = {x = 97061, y = 56929, z = 78306, texture = "odysupporticons/icons/arrow.dds", color = {0.5725,0.8274,0.2078,1}}
	}


	if (mode) then
		local function enableIcon(name, markersArray)
			local iconData = markersArray[name]
			local icon = OSI.CreatePositionIcon(iconData.x, iconData.y, iconData.z, iconData.texture, 100, iconData.color)
			CombatAlertsExtended.icons[name] = icon
		end

		enableIcon("Rhint1", redPositions)
		enableIcon("Rhint2", redPositions)
		enableIcon("Rhint3", redPositions)
		enableIcon("Rhint4", redPositions)
		enableIcon("Bstatue1", bluePositions)
		enableIcon("Bstatue2", bluePositions)
		enableIcon("Bstatue3", bluePositions)
		enableIcon("Bstatue4", bluePositions)
		enableIcon("BHunger1", bluePositions)
		enableIcon("BHunger2", bluePositions)
		enableIcon("BHunger3", bluePositions)
		enableIcon("BHunger4", bluePositions)
		enableIcon("Gred1", greenPositions)
		enableIcon("Gred2", greenPositions)
		enableIcon("Gred3", greenPositions)
		enableIcon("Ggreen1", greenPositions)
		enableIcon("Ggreen2", greenPositions)
		enableIcon("Ggreen3", greenPositions)

	else
		if (CombatAlertsExtended.icons["Rhint1"] ~= nil) then
			CombatAlertsExtended.Clear3DMarkers(CombatAlertsExtended.icons)
		end
	end
end

function CombatAlertsExtended.DreadSailRunestones(mode)
	local runestonesPositions = {
		["rune1"] = {x = 20411, y = 36785, z = 39579},
		["rune2"] = {x = 12978, y = 37345, z = 29165},
		["rune3"] = {x = 41489, y = 36788, z = 23992},
		["rune4"] = {x = 41213, y = 36806, z = 11735},
		["rune5"] = {x = 46656, y = 36825, z = 30250},
		["rune6"] = {x = 127720, y = 38008, z = 160150},
		["rune7"] = {x = 142091, y = 38249, z = 165583},
		["rune8"] = {x = 146410, y = 38236, z = 177617},
		["rune9"] = {x = 147747, y = 38229, z = 160142},
		["rune10"] = {x = 156722, y = 40509, z = 151923}
	}
	
	if (mode) then
		local function enableIcon(name)
			local iconData = runestonesPositions[name]
			local icon = OSI.CreatePositionIcon(iconData.x, iconData.y, iconData.z, "odysupporticons/icons/arrow.dds", 150, {1,1,1})
			CombatAlertsExtended.icons[name] = icon
		end
		
		if (CombatAlertsExtended.icons["rune1"] == nil) then
			enableIcon("rune1")
			enableIcon("rune2")
			enableIcon("rune3")
			enableIcon("rune4")
			enableIcon("rune5")
			enableIcon("rune6")
			enableIcon("rune7")
			enableIcon("rune8")
			enableIcon("rune9")
			enableIcon("rune10")
		end
	else
		if (CombatAlertsExtended.icons["rune1"] ~= nil) then
			CombatAlertsExtended.Clear3DMarkers(CombatAlertsExtended.icons)
		end
	end
end

function CombatAlertsExtended.AddonLoaded( event, addon )

	if addon ~= "CombatAlertsExtended" then return end
	
	if (GetCVar("language.2") == "ru") then
		CombatAlertsExtended.selectedLang = CombatAlertsExtended.langs.ru
	else
		CombatAlertsExtended.selectedLang = CombatAlertsExtended.langs.en
	end
	
	CombatAlertsExtended.savedVariables = ZO_SavedVars:NewAccountWide("CombatAlertsExtended_data", 3, nil, CombatAlertsExtended.savedVariablesDefault, nil)
	CombatAlertsExtended.LoadAddonMenu()
	em:UnregisterForEvent("CombatAlertsExtendedLoaded", EVENT_ADD_ON_LOADED)
end

function CombatAlertsExtended.LoadAddonMenu()
	local db = CombatAlertsExtended.savedVariables.Settings
	local lang = CombatAlertsExtended.selectedLang
	
	local panelData = {
		type = "panel",
		name = "Combat Alerts Extended",
		displayName = "Combat Alerts Extended",
		author = "@DrSova",
		version = "1.0.2",
		slashCommand = "/cae",	--(optional) will register a keybind to open to this panel
		registerForRefresh = true,	--boolean (optional) (will refresh all options controls when a setting is changed and when the panel is shown)
		registerForDefaults = true,	--boolean (optional) (will set all options controls back to default values)
	}
	
	local optionsTable = {
		{
			type = "button",
			name = "Donate",
			tooltip = lang.ADDONMENU_DONATE_TOOLTIP,
			func = function()
				  local function PrefillMail()
					ZO_MailSendToField:SetText("@DrSova")
					ZO_MailSendSubjectField:SetText("Combat Alerts Extended")
					ZO_MailSendBodyField:TakeFocus()
				  end
					SCENE_MANAGER:Show('mailSend')
					zo_callLater(PrefillMail, 250)
			end,
			width = "half",
			warning = "",	
		},
		{
			type = "header",
			name = lang.ADDONMENU_CORALAERIE_HEADER
		},
		{
			type = "checkbox",
			name = lang.ADDONMENU_CORALAERIE_MENTALWOUND,
			tooltip = lang.ADDONMENU_CORALAERIE_MENTALWOUND_TOOLTIP,
			default = true,
			getFunc = function() return db.CoralAerie.MentalWound end,
			setFunc = function(value) db.CoralAerie.MentalWound = value end,
		},
		{
			type = "checkbox",
			name = lang.ADDONMENU_CORALAERIE_BLASTPOWDER,
			tooltip = lang.ADDONMENU_CORALAERIE_BLASTPOWDER_TOOLTIP,
			default = true,
			getFunc = function() return db.CoralAerie.BlastPowder end,
			setFunc = function(value) db.CoralAerie.BlastPowder = value end,
		},
		{
			type = "checkbox",
			name = lang.ADDONMENU_CORALAERIE_TETHER,
			tooltip = lang.ADDONMENU_CORALAERIE_TETHER_TOOLTIP,
			default = true,
			getFunc = function() return db.CoralAerie.Tether end,
			setFunc = function(value) db.CoralAerie.Tether = value end,
		},
		{
			type = "checkbox",
			name = lang.ADDONMENU_CORALAERIE_HA_VARRALION,
			tooltip = lang.ADDONMENU_CORALAERIE_HA_VARRALION_TOOLTIP,
			default = true,
			getFunc = function() return db.CoralAerie.HAVarallion end,
			setFunc = function(value) db.CoralAerie.HAVarallion = value end,
		},
		{
			type = "header",
			name = lang.ADDONMENU_SHIPWRIGHTSREGRET_HEADER
		},
		{
			type = "checkbox",
			name = lang.ADDONMENU_SHIPWRIGHTSREGRET_FLAME,
			tooltip = lang.ADDONMENU_SHIPWRIGHTSREGRET_FLAME_TOOLTIP,
			default = true,
			getFunc = function() return db.ShipwrightsRegret.Flame end,
			setFunc = function(value) db.ShipwrightsRegret.Flame = value end,
		},
		{
			type = "checkbox",
			name = lang.ADDONMENU_SHIPWRIGHTSREGRET_SOULBOMB,
			tooltip = lang.ADDONMENU_SHIPWRIGHTSREGRET_SOULBOMB_TOOLTIP,
			default = true,
			getFunc = function() return db.ShipwrightsRegret.SoulBomb end,
			setFunc = function(value) db.ShipwrightsRegret.SoulBomb = value end,
		},
		{
			type = "header",
			name = lang.ADDONMENU_OTHERS_HEADER
		},
		{
			type = "checkbox",
			name = lang.ADDONMENU_OTHERS_PUSTULENTPROBLEMS,
			tooltip = lang.ADDONMENU_OTHERS_PUSTULENTPROBLEMS_TOOLTIP,
			default = true,
			getFunc = function() return db.Others.PustulentProblems end,
			setFunc = function(value) db.Others.PustulentProblems = value end,
		},
		{
			type = "checkbox",
			name = lang.ADDONMENU_OTHERS_COOLINGYOURHEELS,
			tooltip = lang.ADDONMENU_OTHERS_COOLINGYOURHEELS_TOOLTIP,
			default = true,
			getFunc = function() return db.Others.CoolingYourHeels end,
			setFunc = function(value) db.Others.CoolingYourHeels = value end,
		},
		{
			type = "checkbox",
			name = lang.ADDONMENU_OTHERS_DSRRUNESTONES,
			tooltip = lang.ADDONMENU_OTHERS_DSRRUNESTONES_TOOLTIP,
			default = true,
			getFunc = function() return db.Others.DSRRunestones end,
			setFunc = function(value) db.Others.DSRRunestones = value end,
		},
		{
			type = "checkbox",
			name = lang.ADDONMENU_OTHERS_MHKSHORTLEASH,
			tooltip = lang.ADDONMENU_OTHERS_MHKSHORTLEASH_TOOLTIP,
			default = true,
			getFunc = function() return db.Others.MHKShortLeash end,
			setFunc = function(value) db.Others.MHKShortLeash = value end,
		},
		{
			type = "checkbox",
			name = lang.ADDONMENU_OTHERS_ASSHOWPOS,
			tooltip = lang.ADDONMENU_OTHERS_ASSHOWPOS_TOOLTIP,
			default = true,
			getFunc = function() return db.Others.ASPositions end,
			setFunc = function(value) db.Others.ASPositions = value end,
		},
		{
			type = "checkbox",
			name = lang.ADDONMENU_OTHERS_NYMIC_SECRETS,
			tooltip = lang.ADDONMENU_OTHERS_NYMIC_SECRETS_TOOLTIP,
			default = true,
			getFunc = function() return db.Others.NymicSecrets end,
			setFunc = function(value) db.Others.NymicSecrets = value end,
		}
	}

	local menu = LibAddonMenu2
	if not LibAddonMenu2 then return end
	
	local panel = menu:RegisterAddonPanel("CombatAlertsExtended_Options", panelData)
	menu:RegisterOptionControls("CombatAlertsExtended_Options", optionsTable)
end

function CombatAlerts.PlayerActivated( eventCode, initial )
	CombatAlertsExtended.icons = {}
	CombatAlertsExtended.KiteASicons = {}
	
	CombatAlertsExtended.Clear3DMarkers(CombatAlertsExtended.icons)
	CombatAlertsExtended.Clear3DMarkers(CombatAlertsExtended.KiteASicons)

	local db = CombatAlertsExtended.savedVariables.Settings
	CombatAlerts.zoneId = GetZoneId(GetUnitZoneIndex("player"))
	
	if (CombatAlerts.zoneId == 1000 and (db.Others.ASPositions)) then
		if (OSI ~= nil) then
			CombatAlertsExtended.ASPlayerPositions(true)
		end
	end

	if (CombatAlerts.zoneId == 1420 and (db.Others.NymicSecrets)) then
		if (OSI ~= nil) then
			CombatAlertsExtended.NymicPositions(true)
		end
	end
	
	if (CombatAlerts.zoneId == 1344 and (db.Others.DSRRunestones)) then
		if (OSI ~= nil) then
			CombatAlertsExtended.DreadSailRunestones(true)
		end
	end
	
	if (CombatAlerts.zoneId == 1010 and db.Others.PustulentProblems) then
		if (not CombatAlerts.sc.ratAchEnabled) then
			CombatAlerts.sc.ratAchEnabled = true
			CombatAlerts.AlertChat(LocalizeString("Starting tracking |H1:achievement:1984:0:0|h|h"));
		end
	elseif (CombatAlerts.zoneId == 973 and db.Others.CoolingYourHeels) then
		if (not CombatAlerts.bloodforge.nirnAchEnabled) then
			local BloodForgeAchievement = function( eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId )
				
				if (abilityId == 87303 and targetType == COMBAT_UNIT_TYPE_PLAYER) then 
					CombatAlerts.AlertChat(string.format("Failed |H1:achievement:1816:0:0|h|h"))
					CombatAlerts.sc.isAchFailed = true
					EVENT_MANAGER:UnregisterForEvent("CombatAlertsExtended_Bloodforge", EVENT_COMBAT_EVENT)
				end
			end
			
			CombatAlerts.bloodforge.nirnAchEnabled = true
			CombatAlerts.AlertChat(LocalizeString("Starting tracking |H1:achievement:1816:0:0|h|h"));
			EVENT_MANAGER:RegisterForEvent("CombatAlertsExtended_Bloodforge", EVENT_COMBAT_EVENT, BloodForgeAchievement)
		end
	else
		CombatAlerts.sc.ratAchEnabled = false
		CombatAlerts.sc.isRatAchFailed = false
		CombatAlerts.bloodforge.nirnAchEnabled = false
		CombatAlerts.bloodforge.isAchFailed = false
		CombatAlerts.moonhunter.isShortLeashFailed = false
	end
	base_CombatAlertsPlayerActivated(eventCode, initial)
end

function CombatAlerts.CombatEvent( eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId )
	local overwritten = false;
	local db = CombatAlertsExtended.savedVariables.Settings
	
	-- some test
	if (result == ACTION_RESULT_BEGIN) then
		--CHAT_ROUTER:AddSystemMessage(string.format("event %d result %d abilityName %s sourceName %s sourceType %d hitValue %d powerType %d damageType %d sourceUnitId %d targetUnitId %d abilityId %d targetName %s targetType %s",eventCode, result, abilityName, sourceName, sourceType, hitValue, powerType, damageType, sourceUnitId, targetUnitId, abilityId, targetName, targetType))
	end
	
	-- Ascending Tide
	
	if (result == ACTION_RESULT_BEGIN and abilityId == 165849 and hitValue == 1000 and db.ShipwrightsRegret.Flame) then 
		CombatAlerts.Alert(nil, GetAbilityName(abilityId), 0xFFD700FF, SOUNDS.DUEL_START, 1500)
		overwritten = true
	elseif (result == ACTION_RESULT_EFFECT_GAINED and abilityId == CombatAlertsData.at.bomb2 and db.ShipwrightsRegret.SoulBomb) then
		if (CombatAlerts.units[targetUnitId]) then
			targetName = CombatAlerts.units[targetUnitId].name
		end
		table.insert(CombatAlerts.tide.bombs, targetName)
		if (#CombatAlerts.tide.bombs > 1) then
			
			CombatAlerts.unitsName = {}
			clean_units = {}
			
			for i = 1, GetGroupSize() do
				local unitTag = GetGroupUnitTagByIndex(i)
				local name = GetUnitDisplayName(unitTag)
				table.insert(CombatAlerts.unitsName,name)
			end
			
			local t = {}
			for i = 1, #CombatAlerts.tide.bombs do
				t[CombatAlerts.tide.bombs[i]] = true;
			end
			for i = #CombatAlerts.unitsName, 1, -1 do
				if t[CombatAlerts.unitsName[i]] then
					table.remove(CombatAlerts.unitsName, i)
				end
			end
			clean_units = CombatAlerts.unitsName;
			table.sort(clean_units)
			table.sort(CombatAlerts.tide.bombs)
			
			first_pair = table.concat({CombatAlerts.tide.bombs[1], clean_units[1]}, " + ")
			second_pair = table.concat({CombatAlerts.tide.bombs[2], clean_units[2]}, " + ")
			
			if ((CombatAlerts.tide.bombs[1] == GetDisplayName()) or (clean_units[1] == GetDisplayName())) then 
				CombatAlerts.Alert(GetFormattedAbilityName(abilityId), first_pair, 0xCC3399FF, SOUNDS.CHAMPION_POINTS_COMMITTED, 7000)
			else 
				CombatAlerts.Alert(GetFormattedAbilityName(abilityId), second_pair, 0xCC3399FF, SOUNDS.CHAMPION_POINTS_COMMITTED, 7000)
			end
			CombatAlerts.tide.bombs = { }
			CombatAlerts.unitsName = { }
			clean_units = { }
		end
		overwritten = true
	elseif (result == ACTION_RESULT_EFFECT_GAINED and (abilityId == 163148 or abilityId == 163152) and db.CoralAerie.MentalWound) then
		if (CombatAlerts.panel.tag ~= "varallion") then
			CombatAlerts.TogglePanel(true, "DOT", true, true)
			CombatAlerts.panel.tag = "varallion"
		end
		CombatAlerts.at.dotStarted = GetGameTimeMilliseconds()
	elseif (result == ACTION_RESULT_BEGIN and abilityId == 158909 and db.CoralAerie.BlastPowder) then
		CombatAlerts.AlertCast(abilityId, nil, hitValue + 1000, { -2, 2 })
		overwritten = true
	elseif (result == ACTION_RESULT_EFFECT_GAINED and CombatAlertsData.at.links[abilityId] and db.CoralAerie.MentalWound) then
		if (CombatAlerts.units[targetUnitId]) then
			targetName = CombatAlerts.units[targetUnitId].name
		end
		if (CombatAlertsData.at.links[abilityId] == 1) then
			CombatAlerts.tide.link1 = targetName
		else
			CombatAlerts.Alert(GetFormattedAbilityName(abilityId), string.format("%s / %s", CombatAlerts.tide.link1, targetName), 0xCC3399FF, SOUNDS.CHAMPION_POINTS_COMMITTED, 2000)
			CombatAlertsExtended.TetherID = CombatAlerts.CastAlertsStart(CombatAlertsData.sunspire.meteorIcon, string.format("%s / %s", CombatAlerts.tide.link1, targetName), 28000, nil, nil, { 28000, "", 1, 0, 1, 0.5, nil })
			CombatAlerts.tide.link1 = ""
		end
		overwritten = true
	elseif (result == ACTION_RESULT_BEGIN and abilityId == 158778 and db.CoralAerie.HAVarallion) then
		if (CombatAlerts.units[targetUnitId] ~= nil) then
			local targetTag = CombatAlerts.units[targetUnitId].tag

			if (GetGroupMemberSelectedRole(targetTag) ~= LFG_ROLE_TANK) then
				zo_callLater(function() CombatAlerts.Alert(nil, "", 0xFFD700FF, SOUNDS.DUEL_START, 1500) end, 500)
				CombatAlerts.AlertCast(abilityId, sourceName, hitValue, { 0, 0, false, { 1, 0, 0.6, 0.8 } })
				overwritten = true
			end
		end
	--Moon Hunter Keep
	elseif (result == ACTION_RESULT_DAMAGE and abilityId == 104412 and db.Others.MHKShortLeash and not CombatAlerts.moonhunter.isShortLeashFailed) then
		CombatAlerts.AlertChat(string.format("Failed |H1:achievement:2300:0:0|h|h"))
		CombatAlerts.moonhunter.isShortLeashFailed = true
	--AS
	--Start AS Kite
	elseif (result == ACTION_RESULT_BEGIN and abilityId == 98535 and (OSI ~= nil) and db.Others.ASPositions and not CombatAlertsExtended.stormIsActive) then
		CombatAlertsExtended.stormIsActive = true
		local DDPositions = {
			{97017, 100718, 180 + 20, 2200},
			{97512, 100251, 180 + 40, 2200},
			{98061, 99869, 180 + 60, 2200},
			{98581, 99669, 180 + 80, 2200},
			{99084, 99648, 180 + 100, 2200},
			{99547, 99714, 180 + 110, 2200},
			{100146, 100134, 180 + 130, 2200},
			{100730, 100697, 180 + 140, 2200}
		}
		local function enableIcon(x, z, dd, i)
			local icon = OSI.CreatePositionIcon(x, 61450, z, "odysupporticons/icons/squares/squaretwo_yellow.dds", 50, {1,1,1})
			CombatAlertsExtended.KiteASicons[string.format("ddkitepos_%d_%d", dd, i)] = icon
		end
		local function getSegmentPoints(x, y, angle, length)
			local segmentPoints = {}
			for i = 1, 5 do
				local x_coord = x + (length / 5) * (i - 1) * math.cos(math.rad(angle))
				local y_coord = y + (length / 5) * (i - 1) * math.sin(math.rad(angle))
				segmentPoints[i] = {x = x_coord, y = y_coord}
			end
			return segmentPoints
		end

		for i = 1, 8 do
			local info = DDPositions[i]
			local segments = getSegmentPoints(info[1], info[2], info[3], info[4])
			for k = 2, 5 do
				local segment = segments[k]
				enableIcon(segment.x, segment.y, i, k)
			end
		end

		zo_callLater(function() CombatAlertsExtended.Clear3DMarkers(CombatAlertsExtended.KiteASicons) CombatAlertsExtended.stormIsActive = false end, 6000)
	--ScaleCaller Peak
	elseif (result == ACTION_RESULT_DAMAGE and abilityId == 100285 and CombatAlerts.sc.ratAchEnabled and not CombatAlerts.sc.isRatAchFailed) then
		if (CombatAlerts.units[targetUnitId]) then
			targetName = CombatAlerts.units[targetUnitId].name
		end
		
		CombatAlerts.AlertChat(string.format("Failed |H1:achievement:1984:0:0|h|h by %s", targetName))
		CombatAlerts.sc.isRatAchFailed = true
	end
	
	if (overwritten) then
		return
	end
	
	base_CombatAlertsCombatEvent( eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId )
end

function CombatAlerts.Poll()
	local db = CombatAlertsExtended.savedVariables.Settings
	
	-- Coral Aerie
	if (CombatAlerts.zoneId == 1301 and db.CoralAerie.MentalWound) then
		local currentTime = GetGameTimeMilliseconds()
		
		if (CombatAlerts.panel.tag == "varallion") then 
			time = CombatAlerts.at.dotStarted - currentTime

			if (time < -30000) then
				CombatAlerts.panel.rows[1].data:SetText("INCOMING")
				CombatAlerts.panel.SetRowColor(1, 1, 0, 0, 1)
			else
				CombatAlerts.panel.rows[1].data:SetText(string.format("NEXT: %ss", zo_floor((30000 - (-1 * time)) / 1000)))
				CombatAlerts.panel.SetRowColor(1, 0, 1, 0, 1)
			end
		end
		
	end
	
	base_CombatAlertsPoll()
end

em:RegisterForEvent("CombatAlertsExtendedLoaded", EVENT_ADD_ON_LOADED, CombatAlertsExtended.AddonLoaded)