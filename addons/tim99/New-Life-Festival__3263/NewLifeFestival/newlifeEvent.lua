tim99_NewLifeFestival = tim99_NewLifeFestival or {}
local tny = tim99_NewLifeFestival
-- ************************************************************
-- **** https://en.uesp.net/wiki/Online:New_Life_Festival  ****
-- ************************************************************
tny = {
	name           = "NewLifeFestival",
	author         = "|c595959tim99|r",
	srvName        = string.sub(GetWorldName(),1,2),
	firstCall      = true,
	isOnAvaBreak   = false,
--	isWait4Drink   = false,
	isAubatha      = false,
	isRegGetInv    = false,
	closeBanker    = false,
	waitForInvItem = "",
	waitForInvQuan = "",
	aubatStep      = 0,
	svChr          = {},
	svAcc          = {},
	c_TNY          = ZO_ColorDef:New("9B30FF"),
	cl_red         = ZO_ColorDef:New("FF6666"), cd_red = ZO_ColorDef:New("FF0000"),
	cl_grn         = ZO_ColorDef:New("66FF66"), cd_grn = ZO_ColorDef:New("00FF00"), 
	c3_gry         = ZO_ColorDef:New("333333"), c6_gry = ZO_ColorDef:New("666666"), c9_gry = ZO_ColorDef:New("999999"),
	c_orng         = ZO_ColorDef:New("FF9900"),	
	cl_blu         = ZO_ColorDef:New("6699FF"),
  --[[▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
      ██████████████████████████████████████████████████████© tim99████
      ██1█▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀████
      ████         ▄▄▄ ▄ ▄ ▄▄▄ ▄▄  ▄▄▄     ▄▄  ▄▄▄ ▄▄▄ ▄▄▄         ████
      ██3█         █■■ █ █ █■■ █ █  █  ▄▄▄ █ █ █■█  █  █■■         ████
      █3██         ▀▀▀  ▀  ▀▀▀ ▀ ▀  ▀      ▀▀  ▀ ▀  ▀  ▀▀▀         ████
      ██7█▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄████
      █████████████████████████ event-start ███████████████████████████
      ████▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀████--]]
  --[[████--]]           EVENT_START_DAY   = 16               ,--[[████--]]
  --[[████--]]           EVENT_START_MONTH = 12               ,--[[████--]]
  --[[████--]]           EVENT_START_YEAR  = 2021             ,--[[████--]]
  --[[████▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄████
      ██████████████████████████ event-end ████████████████████████████
      ████▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀████--]]
  --[[████--]]           EVENT_END_DAY     = 04               ,--[[████--]]
  --[[████--]]           EVENT_END_MONTH   = 01               ,--[[████--]]
  --[[████--]]           EVENT_END_YEAR    = 2022             ,--[[████
      ████▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄██2█
      ██████████████████████████████████████████████████████████████4██
      ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀--]]
}
tny.svDefChr = {}
tny.svDefAcc = {
	anchor         = {TOPLEFT, TOPLEFT, 100, 100},
	shownBy        = "keybind",
	skipDlg        = true,
	isHidden       = false,
	debugLog       = false,
	autoTrackQ     = true,
--	useMead        = false,
	autoFollowQ    = false,
	markTrackedQ   = true,
	showShrine     = false,
	markJunk       = true,
	deleteJunk     = false,
	portRawlHome   = false,
	getFish        = true,
	showTickets    = true,
	enableFastWs   = true,
	chatMarkJunk   = false,
	chatDelJunk    = true,
	chatDelRunes   = true,
	chatTravelInfo = true,
	tipOrKill      = "tip",
	closeBanker    = true,
	dismisBanker   = false,
	snowball       = false,
	kaninchen      = false,
	feuerspucker   = false,
	schwertschl    = false,
	jongleur       = false,
	badetuch       = false,
	schlammball    = false,
	hood1          = false,
	hood2          = false,
	delPurpWrits   = false,
	delBlueWrits   = false,
}
--[[  TO DO
     █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
     █ -                                                    █
     █■■■■■■■■■■■■■■■■■■■■■■MAYBE?■■■■■■■■■■■■■■■■■■■■■■■■■■█
     █ -Mouse3 ports back to Breda?                         █
     █    └» Maybe automatically after finished last step?  █
     █ -AcceptQuest ports automatically to 1st Questloc?    █
     █ -PORT to Loc depend on Q-step | Queststeps possible? █
     █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█
--]]
local NLFeventQuests = {
	[1]	= {questid = 5837, achie = 1666, fastTravel = 65,  locations = 2 }, --Stonefalls
	[2]	= {questid = 5855, achie = 1669, fastTravel = 52,  locations = 1 }, --Shadowfen
	[3]	= {questid = 5838, achie = 1548, fastTravel = 121, locations = 1 }, --Auridon
	[4]	= {questid = 5852, achie = 1668, fastTravel = 164, locations = 1 }, --Grahtwood
	[5]	= {questid = 5856, achie = 1672, fastTravel = 181, locations = 1 }, --Betnikh
	[6]	= {questid = 5811, achie = 1671, fastTravel = 87,  locations = 2 }, --Eastmarch
	[7]	= {questid = 5834, achie = 1670, fastTravel = 162, locations = 1 }, --ReapersMarch
	[8]	= {questid = 5839, achie = 1673, fastTravel = 44,  locations = 1 }, --Alikr
	[9]	= {questid = 5845, achie = 1667, fastTravel = 15,  locations = 1 }, --Stormhaven
	[10]= {questid = 6588, achie = 0   , fastTravel = 0,   locations = 0 }, --random selection
}
local NLFeventQuestsTranslate = {
	['de'] = {
		[1]	= "Lavafußstampfer",
		[2]	= "Fischgunstfestmahl",
		[3]	= "Schlammballschlacht",
		[4]	= "Die Kriegswaisenreise",
		[5]	= "Steinzahnsause", 
		[6]	= "Der Schneebärensprung",
		[7]	= "Die Prüfung der Fünfkrallenlist",
		[8]	= "Signalfeuersprint",
		[9]	= "Burgbardenherausforderung",
		[10]= "Der Altjahrsritus"
	},
	['ru'] = {
		[1]	= "Пляска лавовых ног",
		[2]	= "Пир рыбного блага",
		[3]	= "Грязеброс",
		[4]	= "Паломничество сирот войны", 
		[5]	= "Удар Каменного Зуба",
		[6]	= "Ныряние снежного медведя",
		[7]	= "Испытание когтистого коварства",
		[8]	= "Забег сигнальных огней",
		[9]	= "Замковое состязание очарования",
		[10]= "Обычаи Старой жизни"
	},
	['fr'] = {
		[1]	= "Danser Lave-alse",
		[2]	= "Festin de la Manne poissonneuse",
		[3]	= "Boules de boue et bonne humeur",
		[4]	= "Le séjour des orphelins de guerre",
		[5]	= "La bringue à Pierrecroc",
		[6]	= "Le plongeon de l'ours des neiges",
		[7]	= "L'Épreuve de la Ruse à cinq griffes",
		[8]	= "La course des fanaux",
		[9]	= "Le défi de la vie de château",
		[10]= "Observance de la Vieille Vie"
	},
	['en'] = {
		[1]	= "Lava Foot Stomp",
		[2]	= "Fish Boon Feast",
		[3]	= "Mud Ball Merriment",
		[4]	= "War Orphan's Sojourn",
		[5]	= "Stonetooth Bash",
		[6]	= "Snow Bear Plunge",
		[7]	= "The Trial of Five-Clawed Guile",
		[8]	= "Signal Fire Sprint",
		[9]	= "Castle Charm Challenge",
		[10]= "Old Life Observance"
	}
}
local Startquest = {["Das Neujahrsfest"]=true,["The New Life Festival"]=true,["Le Festival de la Nouvelle vie"]=true,["Праздник Новой жизни"]=true,}	
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
-- /script local quoff=select(2,GetOfferedQuestInfo()) StartChatInput("[\""..quoff.."\"]=true,")
-- FalseAlertQuestOffered is only needed if you wanna stop at QuestAccept, to accept manually but skip all the text before
-- right now its not implemented, you autoAccept the offered quest. Changed my mind a couple times about that last step, so i leave it here
local FalseAlertQuestOffered = { --just needed if (skipDialogs=true AND autoAcceptQuests=false); currently not used
	--Breda
	["Wer ist das diesjährige Ziel?"]=true,["Was für Auftritte?"]=true,["Das klingt ja simpel genug. Was muss ich tun?"]=true,["Wie soll ich das anstellen?"]=true,["Was für ein Anstecker?"]=true,
	["Who is this year's target?"]=true,["What sort of performances?"]=true,["That sounds simple enough. What would I do?"]=true,["How would I do that?"]=true,["What sort of pin?"]=true,
	--Petronius
	["Was muss ich tun, um mitzumachen?"]=true,["What do I need to do to participate?"]=true,
}
local TipOrKill = {
	["Nun gut. Ich bin bereit zu spenden."]=true,["All right. I'm ready to donate."]=true,["Très bien. Je suis prêt à donner."]=true,["Хорошо. Я готов сделать пожертвование."]=true,
}
--Naming and shaming
-- /script local _,name=GetGameCameraInteractableActionInfo()  StartChatInput("[\""..name.."\"]=true, ")
local MAIN_NPC_QUEST = {
	["Breda"]=true, ["Breda"]=true, ["Брэда"]=true, ["Bréda"]=true, 
	["Petronius Galenus"]=true, ["Петроний Гален"]=true, --same in DE,EN,FR
}
local SIDE_NPC_QUEST = { 
	["Ormurrel"]=true, ["Ормуррель"]=true, --same in DE,EN,FR													--Grahtwood
	["Tumira"]=true, ["Тумира"]=true, --same in DE,EN,FR														--ReapersMarch
	["Zartes-Herz"]=true, ["Gentle-Heart"]=true, ["Cœur-Tendre"]=true, ["Нежное-Сердце"]=true, 					--Shadowfen
	["Matrone Borbuga"]=true, ["Matron Borbuga"]=true, ["La matronne Borbuga"]=true, ["Матрона Борбуга"]=true,	--Betnikh
}
local SIDE_NPC_ALIKR = { --needs extra attension																--Alikr
	["Aubatha"]=true, ["Обата"]=true, --same in DE,EN,FR
}
local FESTIVAL_VENDOORS = {
	["Raeififeh"]=true, ["Рейфифе"]=true, --same in DE,EN,FR
	["Snegburgak"]=true, ["Снегбургак"]=true, --same in DE,EN,FR
}
local ANNOYING_NPC = {
	["Galthonor"]=true, ["Гальтонор"]=true, --same in DE,EN,FR					--ReapersMarch
	["Dagnir Hartherz"]=true, ["Dagnir Hard-Heart"]=true, ["Dagnir Cœur-de-pierre"]=true, ["Дагнир Твердое Сердце"]=true, --Stonefalls Fishcavern
	
}
local COOK = {["Ich habe das Versorgergesuch abgeschlossen."]=true,["I completed the provisioning request."] =true,["Я выполнил заказ на снабжение."]         =true,["J'ai rempli la commande de cuisine."]        =true,}
local WOOD = {["Ich habe das Schreinergesuch abgeschlossen."]=true,["I completed the woodworking request."]  =true,["Я выполнил заказ на деревянные изделия."]=true,["J'ai rempli la commande de travail du bois."]=true,}
local CLOTH= {["Ich habe das Schneidergesuch abgeschlossen."]=true,["I completed the clothier request."]     =true,["Я выполнил заказ на шитье изделий."]     =true,["J'ai rempli la commande de couture."]        =true,}
local FORGE= {["Ich habe das Schmiedegesuch abgeschlossen."] =true,["I completed the blacksmithing request."]=true,["Я выполнил заказ на кованые изделия."]   =true,["J'ai rempli la commande de forge."]          =true,}
--
--quest steps for fasttravel via wayshrine (no costs)
local destOld = {
    [1] = {qstep = "to Petronius Galenus", travelIdx =  89, qstepDE = "mit Petronius Galenus", qstepRU = "с Петронием Галеном",	qstepFR = "à Petronius Galenus"},
    [2] = {qstep = "Auridon",              travelIdx = 176, },
    [3] = {qstep = "Reaper's March",       travelIdx = 157, },
    [4] = {qstep = "Glenumbra",            travelIdx =   5, },
    [5] = {qstep = "Bangkorai",            travelIdx =  34, },
    [6] = {qstep = "Stonefalls",           travelIdx =  73, },
    [7] = {qstep = "Rift",                 travelIdx = 120, },
}
local destOrg = {
     [1] = {qstep = "Talk to Breda",    travelIdx =  89, qstepDE = "Sprecht mit Breda",     qstepRU = "Поговорить с Брэдой",        qstepFR = "Parlez à Bréda"           }, --return
     [2] = {qstep = "speak with Breda", travelIdx =  89, qstepDE = "mit Breda sprechen",    qstepRU = "поговорить с Брэдой",        qstepFR = "parler à Bréda"           }, --return
     [3] = {qstep = "return to Breda",  travelIdx =  89, qstepDE = "Breda zurückkehren",    qstepRU = "вернуться к Брэде",          qstepFR = "retourner voir Bréda"     }, --return
     [4] = {qstep = "throw mud balls",  travelIdx = 121, qstepDE = "Schlammballschlacht",   qstepRU = "забросать комками грязи",    qstepFR = "lancer des boules de boue"}, --Auridon
     [5] = {qstep = "Aubatha",          travelIdx =  44, qstepDE = "Aubatha",               qstepRU = "Обатой",                     qstepFR = "Aubatha"                  }, --Alikr
     [6] = {qstep = "Alcaire Keep",     travelIdx =  15, qstepDE = "Burg Alcaire",          qstepRU = "замке Алькаира",             qstepFR = "fort d'Alcaire"           }, --Sturmhafen
     [7] = {qstep = "Stonetooth Bash",  travelIdx = 181, qstepDE = "Steinzahn%-Festung",    qstepRU = "крепость Каменного Зуба",    qstepFR = "forteresse de Pierrecroc" }, --Betnikh
     [8] = {qstep = "Tumira",           travelIdx = 162, qstepDE = "Tumira",                qstepRU = "Тумира",                     qstepFR = "Tumira"                   }, --Schnittermark
     [9] = {qstep = "Ormurrel",         travelIdx = 164, qstepDE = "Ormurrel",              qstepRU = "Ормуррелем",                 qstepFR = "Ormurrel"                 }, --Grahtwald
    [10] = {qstep = "Cub's Tumble",     travelIdx =  87, qstepDE = "Jungensturz",           qstepRU = "Бултых Медвежонка",          qstepFR = "Galipette de l'ourson"    }, --Ostmarsch 1
    [11] = {qstep = "Horker's Drop",    travelIdx =  89, qstepDE = "Horkersturz",           qstepRU = "мост Заплыв Хоркера",        qstepFR = "l'À%-pic du horqueur"     }, --Ostmarsch 2
    [12] = {qstep = "Dead Man's Fall",  travelIdx =  90, qstepDE = "Totmannssturz",         qstepRU = "Прыжок Мертвеца",            qstepFR = "Chute du mort"            }, --Ostmarsch 3
    [13] = {qstep = "Watch House Inn",  travelIdx =  65, qstepDE = "Wacht in Davons",       qstepRU = "трактире «Сторожка»",        qstepFR = "à l'auberge du Guet"      }, --Steinfälle 1
    [14] = {qstep = "Fish Stink",       travelIdx =  65, qstepDE = "Fischgestank",          qstepRU = "таверне «Рыбья вонь»",       qstepFR = "taverne du Poisson puant" }, --Steinfälle 2
    [15] = {qstep = "Ebony Flask",      travelIdx =  67, qstepDE = "Ebenholzflasche",       qstepRU = "таверне «Эбонитовая фляга»", qstepFR = "Flasque d'ébène"          }, --Steinfälle 3
    [16] = {qstep = "Hlaalu House",     travelIdx =  67, qstepDE = "Hlaalu%-Haus",          qstepRU = "доме Хлаалу",                qstepFR = "maison Hlaalu"            }, --Steinfälle 4
    [17] = {qstep = "Gentle%-Heart",    travelIdx =  52, qstepDE = "Zartes%-Herz in Zisch", qstepRU = "Нежным%-Сердцем в Хиссмире", qstepFR = "Cœur%-Tendre à Hissmir"   }, --Schattenfenn
    [18] = {qstep = "Fish Boon Feast",  travelIdx =  51, qstepDE = "Fischgunstfestmahl",    qstepRU = "Пира рыбного блага",         qstepFR = "la manne poissonneuse"    }, --Schattenfenn Angelplatz
}
tny.GETFROMBANK={
	[1]  = {cnt=1, name="Schmitzflosse", id=100393, link="|H1:item:100393:27:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"},
	[2]  = {cnt=1, name="Schaberegel",   id=100394, link="|H1:item:100394:27:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"},
	[3]  = {cnt=1, name="Seegurke",      id=100395, link="|H1:item:100395:27:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"},
}

--local logger = LibDebugLogger("tim99_NewLifeFestival")
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
local function GetNiceDateTime(i_unixtime) return os.date("%d.%m.%Y %X", i_unixtime) end
local function GetNiceDate(i_unixtime) return os.date("%d.%m.%Y", i_unixtime) end
local function GetNiceTime(i_unixtime) return os.date("%X", i_unixtime) end
----------------------------------------------------------------------------------------------------
--from xml-layout
function Tim99_NewYearEventSaveAnchor()
	local isValidAnchor, point, relativeTo, relativePoint, offsetX, offsetY = TimNewYearUI:GetAnchor()
	if isValidAnchor then tny.svAcc.anchor={point, relativePoint, offsetX, offsetY} end
end
----------------------------------------------------------------------------------------------------
--from xml-bindings
function Tim99_ToggleNewLifeMainWindow()
	if TimNewYearUI:IsHidden() then
		TimNewYearUI:SetHidden(false)
		tny.svAcc.isHidden=false
		tny.refreshUI(true)
	else
		TimNewYearUI:SetHidden(true)
		tny.svAcc.isHidden=true
	end
end
----------------------------------------------------------------------------------------------------
--from xml-bindings
function Tim99_PortToSnowballHouse()
	if IsCollectibleUnlocked(GetCollectibleIdForHouse(63))==true then
		RequestJumpToHouse(63,true)
	else
		if GetWorldName()=="EU Megaserver" then
			JumpToSpecificHouse("@tïm'99", 63)
		else
			JumpToSpecificHouse("@Karthrag_Inak", 63) --thx for letting me/us use it
		end
	end
end
----------------------------------------------------------------------------------------------------
--local function OnPlayerAlive()
--	EVENT_MANAGER:UnregisterForEvent(tny.name, EVENT_PLAYER_ALIVE)
--	if tny.svAcc.useMead==true and tny.isOnAvaBreak==false and tny.isWait4Drink==false then 
--		tny.drinkAndVerify()
--	end
--end
----------------------------------------------------------------------------------------------------
--local function OnPlayerNotSwimming()
--	EVENT_MANAGER:UnregisterForEvent(tny.name, EVENT_PLAYER_NOT_SWIMMING)
--	if tny.svAcc.useMead==true and tny.isOnAvaBreak==false and tny.isWait4Drink==false then 
--		tny.drinkAndVerify()
--	end
--end
----------------------------------------------------------------------------------------------------
--local function OnMounted(eventCode,mounted)
--	EVENT_MANAGER:UnregisterForEvent(tny.name, EVENT_MOUNTED_STATE_CHANGED)
--	if mounted==false and tny.svAcc.useMead==true and tny.isOnAvaBreak==false and tny.isWait4Drink==false then 
--		tny.drinkAndVerify() 
--	end
--end
----------------------------------------------------------------------------------------------------
--function tny.useBredasPott()
--	--EVENT_MANAGER:UnregisterForUpdate("BredasCallback")
--	if tny.isOnAvaBreak==false and tny.isWait4Drink==false then
--		tny.isWait4Drink=true
--		local control=WINDOW_MANAGER:GetControlByName("TIM99_NewYear_Mug")
--		if control~=nil then control:SetMouseEnabled(false) end
--		if IsCollectibleUsable(1168) and not IsCollectibleBlocked(1168) then
--			local cooldown,duration = GetCollectibleCooldownAndDuration(1168)
--			if cooldown + duration == 0 then
--				if tny.svAcc.debugLog then CHAT_SYSTEM:AddMessage(tny.c_orng:Colorize("UseCollectible(1168)")) end
--				StopAllMovement()
--				UseCollectible(1168)
--			else
--				if tny.svAcc.debugLog then CHAT_SYSTEM:AddMessage(tny.c_orng:Colorize("Not used UseCollectible(1168). Was still in duration or cooldown.")) end
--			end 
--		else
--			local blockReason=GetCollectibleBlockReason(1168)
--			if tny.svAcc.debugLog then CHAT_SYSTEM:AddMessage(string.format("blockReason= ",tostring(blockReason))) end
--			if blockReason == COLLECTIBLE_USAGE_BLOCK_REASON_BLOCKED_BY_SUBZONE or blockReason == COLLECTIBLE_USAGE_BLOCK_REASON_BLOCKED_BY_ZONE then
--				--paused cause AvA
--				--REACTIVATED in tny.OnPlayerActivated()
--			elseif blockReason == COLLECTIBLE_USAGE_BLOCK_REASON_DEAD then
--				--paused cause death
--				EVENT_MANAGER:RegisterForEvent(tny.name, EVENT_PLAYER_ALIVE, OnPlayerAlive)
--			elseif blockReason == COLLECTIBLE_USAGE_BLOCK_REASON_IN_WATER then
--				--paused cause swimming
--				EVENT_MANAGER:RegisterForEvent(tny.name, EVENT_PLAYER_NOT_SWIMMING, OnPlayerNotSwimming)
--			elseif blockReason == COLLECTIBLE_USAGE_BLOCK_REASON_ON_MOUNT then
--				--paused cause riding
--				EVENT_MANAGER:RegisterForEvent(tny.name, EVENT_MOUNTED_STATE_CHANGED, OnMounted)
--			elseif blockReason == COLLECTIBLE_USAGE_BLOCK_REASON_ON_COOLDOWN then
--				--no handling: maybe not for this collectible possible
--			elseif blockReason == COLLECTIBLE_USAGE_BLOCK_REASON_NOT_BLOCKED then --WTF...blockreason:REASON_NOT_BLOCKED?
--				--no handling: find and avoid if happens
--			else
--				if tny.svAcc.debugLog then CHAT_SYSTEM:AddMessage(tny.c_orng:Colorize("-E- Unknown blockreason...")) end
--				--EVENT_MANAGER:RegisterForUpdate("BredasCallback", 10000, BredasCallback) --try again in 10s
--			end
--		end
--		zo_callLater(function()
--			local cooldown,duration = GetCollectibleCooldownAndDuration(1168)
--			zo_callLater(function()
--				tny.isWait4Drink=false
--				if control~=nil then control:SetMouseEnabled(true) end
--			end,(cooldown+duration+100))
--		end,500)
--	end
--end
----------------------------------------------------------------------------------------------------
--function tny.hasXpBuffEnabled()
--	local foundIt=false
--	for i = 1, GetNumBuffs("player") do
--		local _,_,timeEnding,_,_,_,_,_,_,_,abilityId,_,_=GetUnitBuffInfo("player",i)
--		if abilityId==91449 or abilityId==86075 then
--			if tny.svAcc.debugLog then local duration=timeEnding-(GetGameTimeMilliseconds()/1000) CHAT_SYSTEM:AddMessage(string.format("hasXpBuffEnabled, duration=%ss (%smin)",tostring(math.floor(duration)),tostring(math.floor(duration/60)))) end
--			foundIt=true
--			break
--		end
--	end
--	return foundIt
--end
----------------------------------------------------------------------------------------------------
--function tny.drinkAndVerify()
--	--dont trigger yourself
--	if tny.isWait4Drink==true then return end
--	--use meadmug if not ava, but chatmessage can be sent though if buff ran out
--	if tny.isOnAvaBreak==false then tny.useBredasPott() end
--	--check if really applied
--	zo_callLater(function() 
--		if not tny.hasXpBuffEnabled() then
--			ZO_Alert(ERROR, SOUNDS.GENERAL_ALERT_ERROR ,GetString(aTIM99_NLF_INGAME_ERR_USEBUFF))
--			CHAT_SYSTEM:AddMessage("[NLF] "..tny.c_orng:Colorize(GetString(aTIM99_NLF_INGAME_ERR_USEBUFF)))
--			--no loop: if it doesnt work... user should just activate it manually 
--		end
--	end,5000)
--end
----------------------------------------------------------------------------------------------------
--function tny.refreshXPBuffLabel()
--	--sadly sometimes the event doesn't trigger (maybe in loading screen), so check every loading screen for it
--	local ctrlB=WINDOW_MANAGER:GetControlByName("TIM99_NewYear_Bg")
--	if not ctrlB then return end
--	if tny.hasXpBuffEnabled() then
--		ctrlB:SetHidden(true)
--	else
--		ctrlB:SetHidden(false)
--	end
--end
----------------------------------------------------------------------------------------------------
--Menü
function tny.initMenu()
	local itemTrash = {
		[1]="|H1:item:96956:2:1:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h",
		[2]="|H1:item:96955:2:1:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h",
		[3]="|H1:item:96959:2:1:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h",
		[4]="|H1:item:96958:2:1:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h",
	}
	local LAM2 = LibAddonMenu2
	local panelData = {
		type        = "panel",
		--name        = "|c9B30FF"..GetString(aTIM99_NLF_MENU_TITLE).."|r",
		name        = "|c9B30FFNewLife-Festival|r", --do not translate in Addon-Menu, too confusing
		author      = "|c9B30FFtim99|r",
		version	    = "666",
		website		= "https://www.esoui.com/downloads/info3263-NewLifeFestival.html",
		--feedback	= "https://www.esoui.com/downloads/info3263-NewLifeFestival.html#comments",
		donation	= "https://www.esoui.com/forums/member.php?userid=33743",
		registerForRefresh = true,	--will refresh all options controls when a setting is changed and when the panel is shown
		registerForDefaults = true	--will set all options controls back to default values
	}
	LAM2:RegisterAddonPanel("Tim99_NewLifeFestival_AddonOptions", panelData)
	tim99_NewLifeFestival.fragment = ZO_FadeSceneFragment:New(TimNewYearUI, true, 0)

	CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(panel)
		if panel~=Tim99_NewLifeFestival_AddonOptions then return end
		SCENE_MANAGER:GetScene('gameMenuInGame'):AddFragment(tim99_NewLifeFestival.fragment)
	end)
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", function(panel)
		if panel~=Tim99_NewLifeFestival_AddonOptions then return end
		SCENE_MANAGER:GetScene('gameMenuInGame'):RemoveFragment(tim99_NewLifeFestival.fragment)
	end)
--===============================================================================================--
	local optionsData = {
		{	type		= "description",
			title		= "|c9B30FF"..GetString(aTIM99_NLF_MENU_HEADER1_HEADER).."...|r",
			text		=  "|cffaa00*|r |c999999"..GetString(aTIM99_NLF_MENU_HEADER1_DESCR_1).."|r\n"..
							"|cffaa00*|r |c999999"..GetString(aTIM99_NLF_MENU_HEADER1_DESCR_2).."|r\n"..
							"|cffaa00*|r |c999999"..GetString(aTIM99_NLF_MENU_HEADER1_DESCR_3).."|r",
			width 		= "full",
		}, ------------------------------------------------------------------------
		{	type		= "description",
			title		= "|c9B30FF"..GetString(aTIM99_NLF_MENU_HEADER2_HEADER).."|r",
			text		=  "|cffaa00*|r |c999999"..GetString(aTIM99_NLF_MENU_HEADER2_DESCR_1).."|r\n"..
							"|cffaa00*|r |c999999"..GetString(aTIM99_NLF_MENU_HEADER2_DESCR_2).."|r\n"..
							"|cffaa00*|r |c999999"..GetString(aTIM99_NLF_MENU_HEADER2_DESCR_3).."|r\n"..
							"|cffaa00*|r |c999999"..GetString(aTIM99_NLF_MENU_HEADER2_DESCR_4).."|r",
			width		= "half",
		}, ----------------------------------------------------------------------------
		{	type		= "texture",
			image		= "/esoui/art/icons/assistant_banker_01.dds",
			--text      = "I have come here to chew bubblegum and kick ass... and I'm all out of bubblegum",
			imageWidth	= 96,
			imageHeight	= 96,
			width		= "half",
		}, 
		--========================================================================--
		{	type = "submenu",
			name = string.format("%s %s",tny.c_TNY:Colorize(zo_iconFormatInheritColor("/esoui/art/tutorial/menubar_system_up.dds",40,40)),tny.c_TNY:Colorize(GetString(aTIM99_NLF_MENU_MAIN_SETTINGS))),
			controls = {
				{	type = "dropdown",
					name = GetString(aTIM99_NLF_MENU_SHOWWINDOW_TEXT),
					choices = {
						(GetString(aTIM99_NLF_MENU_SHOWWINDOW_OPT1)),
						(GetString(aTIM99_NLF_MENU_SHOWWINDOW_OPT2)),
						(GetString(aTIM99_NLF_MENU_SHOWWINDOW_OPT3)),
						(GetString(aTIM99_NLF_MENU_SHOWWINDOW_OPT4)),
					},
					choicesValues = {"keybind", "hudall", "hud", "hudui",},
					getFunc = function() return tny.svAcc.shownBy end,
					setFunc = function(value) tny.svAcc.shownBy=value end,
					default = tny.svDefAcc.shownBy,
				}, -------------------------------------------
--				{	type = "checkbox",
--					name = GetString(aTIM99_NLF_MENU_USEXPBUFF_TEXT),
--					getFunc = function() return tny.svAcc.useMead end,
--					setFunc = function(value) 
--						tny.svAcc.useMead=value
--						if value then
--							if not tny.hasXpBuffEnabled() then 
--								zo_callLater(function() tny.drinkAndVerify() end,1000)
--							end
--						end
--					end,
--					default = tny.svDefAcc.useMead,
--					width = "full",
--				}, -------------------------------------------
				{	type = "checkbox",
					name = GetString(aTIM99_NLF_MENU_AUTOTRACKQUEST),
					getFunc = function() return tny.svAcc.autoTrackQ end,
					setFunc = function(value) tny.svAcc.autoTrackQ=value end,
					default = tny.svDefAcc.autoTrackQ,
					width = "full",
				}, -------------------------------------------
				{	type = "checkbox",
					name = GetString(aTIM99_NLF_MENU_PORTRAWLHOME_TEXT),
					getFunc = function() return tny.svAcc.portRawlHome end,
					setFunc = function(value) tny.svAcc.portRawlHome=value end,
					default = tny.svDefAcc.portRawlHome,
					width = "full",
				}, -------------------------------------------
				{	type = "divider",
					alpha = 0.4,
				}, -------------------------------------------
				{	type = "checkbox",
					name = GetString(aTIM99_NLF_MENU_SKIPDIALOGS_TEXT),
					getFunc = function() return tny.svAcc.skipDlg end,
					setFunc = function(value)
						tny.svAcc.skipDlg=value
						if not value then
							EVENT_MANAGER:UnregisterForEvent(tny.name,EVENT_CHATTER_BEGIN)
							EVENT_MANAGER:UnregisterForEvent(tny.name,EVENT_CONVERSATION_UPDATED)
							EVENT_MANAGER:UnregisterForEvent(tny.name,EVENT_QUEST_OFFERED)
							EVENT_MANAGER:UnregisterForEvent(tny.name,EVENT_QUEST_COMPLETE_DIALOG)
							EVENT_MANAGER:UnregisterForEvent(tny.name,EVENT_CHATTER_END)
						elseif value==true then 
							EVENT_MANAGER:RegisterForEvent(tny.name,EVENT_CHATTER_BEGIN,tny.onChatterBegin)
						else
							CHAT_SYSTEM:AddMessage(tny.cd_red:Colorize(string.format(GetString(aTIM99_NLF_MENU_SKIPDIALOGS_ERR),tostring(value))))
						end
					end,
					default = tny.svDefAcc.skipDlg,
					width = "full",
					requiresReload = true,
				}, -------------------------------------------
				{	type = "checkbox",
					name = GetString(aTIM99_NLF_MENU_AUTOFOLLOWQ_TEXT),
					getFunc = function() return tny.svAcc.autoFollowQ end,
					setFunc = function(value) tny.svAcc.autoFollowQ=value end,
					default = tny.svDefAcc.autoFollowQ,
					width = "full",
					disabled = function() return not tny.svAcc.skipDlg end,
				}, -------------------------------------------
				{	type = "dropdown",
					name = GetString(aTIM99_NLF_MENU_TIPORKILL_TEXT),
					choices = {
						(GetString(aTIM99_NLF_MENU_TIPORKILL_OPT1)),
						(GetString(aTIM99_NLF_MENU_TIPORKILL_OPT2)),
						(GetString(aTIM99_NLF_MENU_TIPORKILL_OPT3)),
					},
					choicesValues = {"tip", "kill", "ask",},
					getFunc = function() return tny.svAcc.tipOrKill end,
					setFunc = function(value) tny.svAcc.tipOrKill=value end,
					default = tny.svDefAcc.tipOrKill,
					disabled = function() return not tny.svAcc.skipDlg end,
				}, -------------------------------------------
				{	type = "divider",
					alpha = 0.4,
				}, -------------------------------------------
				{	type = "checkbox",
					name = GetString(aTIM99_NLF_MENU_GETFISHBANK_TEXT),
					getFunc = function() return tny.svAcc.getFish end,
					setFunc = function(value) tny.svAcc.getFish=value end,
					default = tny.svDefAcc.getFish,
					width = "full",
					requiresReload = true,
				}, -------------------------------------------
				{	type = "checkbox",
					name = GetString(aTIM99_NLF_MENU_CLOSEBANK_TEXT),
					getFunc = function() return tny.svAcc.closeBanker end,
					setFunc = function(value) tny.svAcc.closeBanker=value end,
					default = tny.svDefAcc.closeBanker,
					width = "half",
					disabled = function() return not tny.svAcc.getFish end,
				}, -------------------------------------------
				{	type = "checkbox",
					name = GetString(aTIM99_NLF_MENU_DISMISBANK_TEXT),
					getFunc = function() return tny.svAcc.dismisBanker end,
					setFunc = function(value) tny.svAcc.dismisBanker=value end,
					default = tny.svDefAcc.dismisBanker,
					width = "half",
					disabled = function() return not (tny.svAcc.getFish and tny.svAcc.closeBanker) end,
				}, -------------------------------------------
				{	type = "divider",
					alpha = 0.4,
				}, -------------------------------------------
				{	type = "checkbox",
					name = GetString(aTIM99_NLF_MENU_FASTWAYSHRINE_TEXT),
					tooltip = GetString(aTIM99_NLF_MENU_FASTWAYSHRINE_TTIP),
					getFunc = function() return tny.svAcc.enableFastWs end,
					setFunc = function(value) 
						tny.svAcc.enableFastWs=value
						if not value then
							EVENT_MANAGER:UnregisterForEvent(tny.name,EVENT_START_FAST_TRAVEL_INTERACTION)
						elseif value==true then 
							EVENT_MANAGER:RegisterForEvent(tny.name,EVENT_START_FAST_TRAVEL_INTERACTION,tny.onFastTravelInteraction)
						else
							CHAT_SYSTEM:AddMessage(tny.cd_red:Colorize(string.format(GetString(aTIM99_NLF_MENU_SKIPDIALOGS_ERR),tostring(value))))
						end
					end,
					default = tny.svDefAcc.enableFastWs,
					width = "half",
					requiresReload = true,
				}, -------------------------------------------
				{	type = "checkbox",
					name = GetString(aTIM99_NLF_MENU_CHATTRAVEL_TEXT),
					getFunc = function() return tny.svAcc.chatTravelInfo end,
					setFunc = function(value) tny.svAcc.chatTravelInfo=value end,
					disabled = function() return not tny.svAcc.enableFastWs end,
					default = tny.svDefAcc.chatTravelInfo,
					width = "half",
				}, -------------------------------------------
				{	type = "divider",
					alpha = 0.4,
				}, -------------------------------------------
				{	type = "description",
					title = GetString(aTIM99_NLF_MENU_DELITEM_TEXT),
					width = "full",
				}, -------------------------------------------
				{	type = "checkbox",
					name = "  |H1:item:156735:4:6:0:0:0:117954:0:0:0:0:0:0:0:0:0:0:0:0:0:10000|h|h",
					getFunc = function() return tny.svAcc.delBlueWrits end,
					setFunc = function(value) tny.svAcc.delBlueWrits=value end,
					default = tny.svDefAcc.delBlueWrits,
					width = "full",
				}, -------------------------------------------
				{	type = "checkbox",
					name = "  |H1:item:167170:5:6:0:0:0:33819:0:0:0:0:0:0:0:0:0:0:0:0:0:10000|h|h",
					getFunc = function() return tny.svAcc.delPurpWrits end,
					setFunc = function(value) tny.svAcc.delPurpWrits=value end,
					default = tny.svDefAcc.delPurpWrits,
					width = "full",
				}, -------------------------------------------
			},
		},
		--========================================================================--
		{	type = "submenu",
			name = string.format("%s %s",tny.c_TNY:Colorize(zo_iconFormatInheritColor("/esoui/art/tutorial/inventory_tabicon_junk_up.dds",40,40)),tny.c_TNY:Colorize(GetString(aTIM99_NLF_MENU_MAIN_WHITEJUNK))),
			controls = {
				{	type = "description",
					title = " "..tny.c_TNY:Colorize(GetString(aTIM99_NLF_MENU_JUNKITEMS_LIST)),
					text =  "|u1:30::|u"..zo_iconFormat(GetItemLinkIcon(itemTrash[1]),24,24).."   "..itemTrash[1].."\n"..
							"|u1:30::|u"..zo_iconFormat(GetItemLinkIcon(itemTrash[2]),24,24).."   "..itemTrash[2].."\n"..
							"|u1:30::|u"..zo_iconFormat(GetItemLinkIcon(itemTrash[3]),24,24).."   "..itemTrash[3].."\n"..
							"|u1:30::|u"..zo_iconFormat(GetItemLinkIcon(itemTrash[4]),20,20).."    "..itemTrash[4],
					width = "full",
				}, -------------------------------------------
				{	type = "divider",
					alpha = 0.4,
				}, -------------------------------------------
				{	type = "checkbox",
					name = GetString(aTIM99_NLF_MENU_MARKJUNK),
					getFunc = function() return tny.svAcc.markJunk end,
					setFunc = function(value) 
						tny.svAcc.markJunk=value
						if value then
							tny.svAcc.deleteJunk=false
						end
					end,
					default = tny.svDefAcc.markJunk,
					width = "half",
				}, -------------------------------------------
				{	type = "checkbox",
					name = GetString(aTIM99_NLF_MENU_CHATMARKJUNK_TEXT),
					getFunc = function() return tny.svAcc.chatMarkJunk end,
					setFunc = function(value) tny.svAcc.chatMarkJunk=value end,
					disabled = function() return not tny.svAcc.markJunk end,
					default = tny.svDefAcc.chatMarkJunk,
					width = "half",
				}, -------------------------------------------
				{	type = "checkbox",
					name = GetString(aTIM99_NLF_MENU_DELETEJUNK),
					getFunc = function() return tny.svAcc.deleteJunk end,
					setFunc = function(value) 
						tny.svAcc.deleteJunk=value
						if value then
							tny.svAcc.markJunk=false
						end
					end,
					default = tny.svDefAcc.deleteJunk,
					width = "half",
				}, -------------------------------------------
				{	type = "checkbox",
					name = GetString(aTIM99_NLF_MENU_CHATDELJUNK_TEXT),
					getFunc = function() return tny.svAcc.chatDelJunk end,
					setFunc = function(value) tny.svAcc.chatDelJunk=value end,
					disabled = function() return not tny.svAcc.deleteJunk end,
					default = tny.svDefAcc.chatDelJunk,
					width = "half",
				}, -------------------------------------------
			},
		},
		--========================================================================--
		{	type = "submenu",
			name = string.format("%s %s",tny.c_TNY:Colorize(zo_iconFormatInheritColor("/esoui/art/tutorial/inventory_tabicon_junk_up.dds",40,40)),tny.c_TNY:Colorize(GetString(aTIM99_NLF_MENU_MAIN_GOLDENJUNK))),
			controls = {
				{	type = "description",
					title = " "..tny.c_TNY:Colorize(GetString(aTIM99_NLF_MENU_DELITEM_TEXT)),
					width = "full",
				}, -------------------------------------------
				{	type = "checkbox",
					name = GetString(aTIM99_NLF_MENU_ALLGOLDONOFF_TEXT),
					getFunc = function() return 
						tny.svAcc.snowball and 
						tny.svAcc.kaninchen  and 
						tny.svAcc.feuerspucker and 
						tny.svAcc.schwertschl and 
						tny.svAcc.jongleur and 
						tny.svAcc.badetuch and 
						tny.svAcc.schlammball and 
						tny.svAcc.hood1 and 
						tny.svAcc.hood2 end,
					setFunc = function(value) 
						tny.svAcc.snowball=value
						tny.svAcc.kaninchen=value
						tny.svAcc.feuerspucker=value
						tny.svAcc.schwertschl=value
						tny.svAcc.jongleur=value
						tny.svAcc.badetuch=value
						tny.svAcc.schlammball=value
						tny.svAcc.hood1=value
						tny.svAcc.hood2=value
					end,
					default = false,
					width = "full",
				}, -------------------------------------------
				{	type = "divider",
					alpha = 0.4,
				}, -------------------------------------------
				{	type = "checkbox",
					name = " |H1:item:171330:124:6:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
					getFunc = function() return tny.svAcc.snowball end,
					setFunc = function(value) tny.svAcc.snowball=value end,
					default = tny.svDefAcc.snowball,
					width = "full",
				}, -------------------------------------------
				{	type = "checkbox",
					name = " |H1:item:182487:124:6:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
					getFunc = function() return tny.svAcc.kaninchen end,
					setFunc = function(value) tny.svAcc.kaninchen=value end,
					default = tny.svDefAcc.kaninchen,
					width = "full",
				}, -------------------------------------------
				{	type = "checkbox",
					name = " |H1:item:96395:124:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
					getFunc = function() return tny.svAcc.feuerspucker end,
					setFunc = function(value) tny.svAcc.feuerspucker=value end,
					default = tny.svDefAcc.feuerspucker,
					width = "full",
				}, -------------------------------------------
				{	type = "checkbox",
					name = " |H1:item:96392:124:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
					getFunc = function() return tny.svAcc.schwertschl end,
					setFunc = function(value) tny.svAcc.schwertschl=value end,
					default = tny.svDefAcc.schwertschl,
					width = "full",
				}, -------------------------------------------
				{	type = "checkbox",
					name = " |H1:item:96393:124:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
					getFunc = function() return tny.svAcc.jongleur end,
					setFunc = function(value) tny.svAcc.jongleur=value end,
					default = tny.svDefAcc.jongleur,
					width = "full",
				}, -------------------------------------------
				{	type = "checkbox",
					name = " |H1:item:96951:124:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
					getFunc = function() return tny.svAcc.badetuch end,
					setFunc = function(value) tny.svAcc.badetuch=value end,
					default = tny.svDefAcc.badetuch,
					width = "full",
				}, -------------------------------------------
				{	type = "checkbox",
					name = " |H1:item:96391:124:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
					getFunc = function() return tny.svAcc.schlammball end,
					setFunc = function(value) tny.svAcc.schlammball=value end,
					default = tny.svDefAcc.schlammball,
					width = "full",
				}, -------------------------------------------
				{	type = "checkbox",
					name = " |H1:item:96953:124:6:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
					getFunc = function() return tny.svAcc.hood1 end,
					setFunc = function(value) tny.svAcc.hood1=value end,
					default = tny.svDefAcc.hood1,
					width = "full",
				}, -------------------------------------------
				{	type = "checkbox",
					name = " |H1:item:96952:124:6:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
					getFunc = function() return tny.svAcc.hood2 end,
					setFunc = function(value) tny.svAcc.hood2=value end,
					default = tny.svDefAcc.hood2,
					width = "full",
				}, -------------------------------------------
				{	type = "divider",
					alpha = 0.4,
				}, -------------------------------------------
				{	type = "checkbox",
					name = GetString(aTIM99_NLF_MENU_CHATDELJUNK_TEXT),
					getFunc = function() return tny.svAcc.chatDelRunes end,
					setFunc = function(value) tny.svAcc.chatDelRunes=value end,
					default = tny.svDefAcc.chatDelRunes,
					width = "full",
				}, -------------------------------------------
			},
		},
		--========================================================================--
		{	type = "submenu",
			name = string.format("%s %s",tny.c_TNY:Colorize(zo_iconFormatInheritColor("/esoui/art/tutorial/dyes_toolicon_fill_up.dds",40,40)),tny.c_TNY:Colorize(GetString(aTIM99_NLF_MENU_MAIN_VISUALS))),
			controls = {
				{	type = "checkbox",
					name = GetString(aTIM99_NLF_MENU_SHOWSHRINE_TEXT),
					getFunc = function() return tny.svAcc.showShrine end,
					setFunc = function(value)
						tny.svAcc.showShrine=value
						local button=WINDOW_MANAGER:GetControlByName("TIM99_NewYear_JumpToBreda2")
						if value then
							if button then button:SetHidden(false) end
						else
							if button then button:SetHidden(true) end
						end
					end,
					default = tny.svDefAcc.showShrine,
					width = "full",
				}, -------------------------------------------
				{	type = "checkbox",
					name = GetString(aTIM99_NLF_MENU_SHOWTICKETS_TEXT),
					getFunc = function() return tny.svAcc.showTickets end,
					setFunc = function(value)
						tny.svAcc.showTickets=value
						local label=WINDOW_MANAGER:GetControlByName("TIM99_NewYear_EventTickets")
						if value then
							if label then label:SetHidden(false) end
						else
							if label then label:SetHidden(true) end
						end
					end,
					default = tny.svDefAcc.showTickets,
					width = "full",
				}, -------------------------------------------
				{	type = "checkbox",
					name = GetString(aTIM99_NLF_MENU_TRACKEDQUEST_TEXT),
					getFunc = function() return tny.svAcc.markTrackedQ end,
					setFunc = function(value) 
						tny.svAcc.markTrackedQ=value 
						tny.refreshTrackedQuest()
					end,
					default = tny.svDefAcc.markTrackedQ,
					width = "full",
				}, -------------------------------------------
			},
		},
		--========================================================================--
		{	type = "header",
			name = string.format("%s %s",tny.c_TNY:Colorize(zo_iconFormatInheritColor("/esoui/art/tutorial/help_tabicon_tutorial_up.dds",40,40)),tny.c_TNY:Colorize(GetString(aTIM99_NLF_MENU_MAIN_OTHERS))),
		}, ------------------------------------------------------------------------
		{	type = "checkbox",
			name = GetString(aTIM99_NLF_MENU_SHOWDEBUG_TEXT),
			getFunc = function() return tny.svAcc.debugLog end,
			setFunc = function(value) tny.svAcc.debugLog=value end,
			default = tny.svDefAcc.debugLog,
			width = "full",
		}, ------------------------------------------------------------------------
		
	}
	LAM2:RegisterOptionControls("Tim99_NewLifeFestival_AddonOptions", optionsData)
end
----------------------------------------------------------------------------------------------------
function tny.portToNearestWayshrine(i,btn)
	if tny.isOnAvaBreak==true then return end
	if tny.svAcc.debugLog then CHAT_SYSTEM:AddMessage(tny.c_orng:Colorize(string.format("PortToNearestWayshrine i=%s",i))) end
	--some exception:
	--couldnt figure out the queststep to port automatically, so for now it's:
			--leftclick 1st-Loc, rightclick 2nd-Loc
	--Auridon, owned house is closer
	if i==121 and btn==1 then	
		if IsCollectibleUnlocked(GetCollectibleIdForHouse(4))==true then
			if tny.svAcc.debugLog then CHAT_SYSTEM:AddMessage(tny.c_orng:Colorize("   > prefered house")) end
			RequestJumpToHouse(4,true)
		else
			FastTravelToNode(i)
		end
	--Eastmarch 2-Locs, owned house is closer for 1st loc
	elseif i==87 then	
		if btn==1 then
			if IsCollectibleUnlocked(GetCollectibleIdForHouse(29))==true then
				if tny.svAcc.debugLog then CHAT_SYSTEM:AddMessage(tny.c_orng:Colorize("   > prefered house")) end
				RequestJumpToHouse(29,true)
			else
				FastTravelToNode(i)
			end
		elseif btn==2 then
			FastTravelToNode(90)
		end
	--Stonefalls 2-Locs, owned house is closer for 2nd loc
	elseif i==65 then
		if btn==1 then
			FastTravelToNode(i)
		elseif btn==2 then
			if IsCollectibleUnlocked(GetCollectibleIdForHouse(3))==true then
				if tny.svAcc.debugLog then CHAT_SYSTEM:AddMessage(tny.c_orng:Colorize("   > prefered house")) end
				RequestJumpToHouse(3,true)
			else
				FastTravelToNode(67)
			end
		end
	--ReapersMarch Setting for wayshrine OR house
	elseif i==162 then
		if tny.svAcc.portRawlHome==true and IsCollectibleUnlocked(GetCollectibleIdForHouse(23))==true then
			RequestJumpToHouse(23,true)
		else
			FastTravelToNode(i)
		end
	--all others
	else
		if btn==1 then FastTravelToNode(i) end
	end
	SCENE_MANAGER:ShowBaseScene()
	ZO_ChatSystem_ExitChat()
end
----------------------------------------------------------------------------------------------------
function tny.onSceneChangeAll(oldState, newState)
	if tny.isOnAvaBreak==true then return end
	local mScene = SCENE_MANAGER:GetCurrentScene():GetName()
	if tny.svAcc.shownBy == "hudall" then
		if mScene=="hud" or mScene=="hudui" then TimNewYearUI:SetHidden(false) else TimNewYearUI:SetHidden(true) end
	elseif tny.svAcc.shownBy == "hud" then
		if mScene=="hud" then TimNewYearUI:SetHidden(false) else TimNewYearUI:SetHidden(true) end
	elseif tny.svAcc.shownBy == "hudui" then
		if mScene=="hudui" then TimNewYearUI:SetHidden(false) else TimNewYearUI:SetHidden(true) end
	else --"keybind"
		if tny.svAcc.isHidden==false then
			if mScene=="hud" or mScene=="hudui" then TimNewYearUI:SetHidden(false) else TimNewYearUI:SetHidden(true) end
		end
	end
end
----------------------------------------------------------------------------------------------------
function tny.refreshTrackedQuest()
	if tny.isOnAvaBreak==true then return end
	for i = 1, #NLFeventQuests do
		local ctrlQ = WINDOW_MANAGER:GetControlByName("TIM99_NewYearEvent_Quest"..i)
		if not ctrlQ then return end
		for j=1,MAX_JOURNAL_QUESTS do
			if IsValidQuestIndex(j) then
				local questName,_,_,_,_,_,tracked,_,_,_,_=GetJournalQuestInfo(j)
				if questName==NLFeventQuests[i].qname then
					if tny.svAcc.markTrackedQ and tracked then
						ctrlQ:SetNormalFontColor( 1, 1, 0, 1) --//#FFFF00 yellow
						ctrlQ:SetMouseOverFontColor( 1, 1, 0,.7)
						ctrlQ:SetPressedFontColor( 1, 1, 0,.4)
					else
						ctrlQ:SetNormalFontColor( 1,.6, 0, 1) --//#FF9900 orange
						ctrlQ:SetMouseOverFontColor( 1,.6, 0,.7)
						ctrlQ:SetPressedFontColor( 1,.6, 0,.4)
					end
				end
			end
		end
	end
end
----------------------------------------------------------------------------------------------------
function tny.refreshUI(getBuff)
	local todayReset
	local foundIt=false 
	getBuff=getBuff or false
	for i = 1, #NLFeventQuests do
		local ctrlQ = WINDOW_MANAGER:GetControlByName("TIM99_NewYearEvent_Quest"..i)
		if not ctrlQ then return end
		
		--Achievement-icon
		local ico=" "
		if NLFeventQuests[i].achie==0 then
			ico = zo_iconFormat("/esoui/art/champion/actionbar/champion_bar_slot_frame_disabled.dds",21,21)
		else
			local _,_,_,icon,compl,_,_=GetAchievementInfo(NLFeventQuests[i].achie)
			if compl==true then	
				ico = zo_iconFormat(icon, 21,21) 
			else
				ico = zo_iconFormat("/esoui/art/castbar/forbiddenaction.dds",21,21)
			end
		end
		
		--Colors
		if tny.svChr[NLFeventQuests[i].qname] and tny.svChr[NLFeventQuests[i].qname]>0 then
			if tny.srvName=="EU" then
				local diff=zo_floor(GetDiffBetweenTimeStamps(GetTimeStamp(),1641006000)/(24*60*60))
				todayReset=1641006000+(diff*24*60*60) --04:00 (UTC+1)
			else
				local diff=zo_floor(GetDiffBetweenTimeStamps(GetTimeStamp(),1641031200)/(24*60*60))
				todayReset=1641031200+(diff*24*60*60) --11:00 (UTC+1)
			end
			if tny.svChr[NLFeventQuests[i].qname]>=todayReset then
				ctrlQ:SetNormalFontColor(0,1,0,1) --//#66ff66=(.4,1,.4,1) //#00FF00=(0,1,0,1)
				ctrlQ:SetMouseOverFontColor(0,1,0,0.7)
				ctrlQ:SetPressedFontColor(0,1,0,0.4)
			else
				ctrlQ:SetNormalFontColor(1,0,0,1) --//#FF6666=(1,.4,.4,1) //#FF0000=(1,0,0,1)
				ctrlQ:SetMouseOverFontColor(1,0,0,0.7)
				ctrlQ:SetPressedFontColor(1,0,0,0.4)
			end
		else
			ctrlQ:SetNormalFontColor(.4,.4,.4, 1) --#666666
			ctrlQ:SetMouseOverFontColor(.4,.4,.4, 0.7)
			ctrlQ:SetPressedFontColor(.4,.4,.4,0.4)
		end
		
		--Mark active quests; Set destination for Pedros quest (unknown before)
		if i==10 then --init
			foundIt=false 
			ctrlQ:SetMouseEnabled(false) 
		end
		for j=1,MAX_JOURNAL_QUESTS do
			if IsValidQuestIndex(j) then
				--do for all eventquests
				local questName,_,activeStepText,_,_,_,tracked,_,_,_,_=GetJournalQuestInfo(j)
				if questName==NLFeventQuests[i].qname then
					if tny.svAcc.markTrackedQ and tracked then
						ctrlQ:SetNormalFontColor( 1, 1, 0, 1) --//#FFFF00 yellow
						ctrlQ:SetMouseOverFontColor( 1, 1, 0,.7)
						ctrlQ:SetPressedFontColor( 1, 1, 0,.4)
					else
						ctrlQ:SetNormalFontColor( 1,.6, 0, 1) --//#FF9900 orange
						ctrlQ:SetMouseOverFontColor( 1,.6, 0,.7)
						ctrlQ:SetPressedFontColor( 1,.6, 0,.4)
					end
				end
				--do only for last eventquest (exception)
				if i==10 then
					if questName==NLFeventQuests[i].qname then
						if tny.svAcc.debugLog then CHAT_SYSTEM:AddMessage("quest="..tny.c_orng:Colorize(activeStepText)) end
						if string.find(activeStepText, zo_strformat("<<1>>",GetZoneNameById(41)))~=nil then --Stonefalls
							foundIt=true
							ctrlQ:SetHandler("OnClicked",function(self,button) FastTravelToNode(73) end)
						elseif string.find(activeStepText, zo_strformat("<<1>>",GetZoneNameById(382)))~=nil then --ReapersMarch
							foundIt=true
							ctrlQ:SetHandler("OnClicked",function(self,button) FastTravelToNode(157) end)
						elseif string.find(activeStepText, zo_strformat("<<1>>",GetZoneNameById(3)))~=nil then --Glenumbra
							foundIt=true
							ctrlQ:SetHandler("OnClicked",function(self,button) FastTravelToNode(5) end)
						elseif string.find(activeStepText, zo_strformat("<<1>>",GetZoneNameById(381)))~=nil then --Auridon
							foundIt=true
							ctrlQ:SetHandler("OnClicked",function(self,button) FastTravelToNode(176) end)
						elseif string.find(activeStepText, zo_strformat("<<1>>",GetZoneNameById(92)))~=nil then --Bangkorai
							foundIt=true
							ctrlQ:SetHandler("OnClicked",function(self,button) FastTravelToNode(34) end)
						elseif string.find(activeStepText, zo_strformat("<<1>>",GetZoneNameById(103)))~=nil then --Rift
							foundIt=true
							ctrlQ:SetHandler("OnClicked",function(self,button) FastTravelToNode(120) end)
						end
						if foundIt==true then
							if tny.svAcc.debugLog then CHAT_SYSTEM:AddMessage(tny.cd_grn:Colorize("foundIt")) end
							ctrlQ:SetMouseEnabled(true)
							ctrlQ:EnableMouseButton(1,true)
							ctrlQ:SetClickSound(SOUNDS.DIALOG_ACCEPT)
						else
							--unknown location???
							if tny.svAcc.debugLog then CHAT_SYSTEM:AddMessage(tny.c_orng:Colorize("unknown location in pedros quest --> fix it!!")) end
							ctrlQ:SetMouseEnabled(false)
						end
					end
				end
			
			end
		end

		--update controls
		ctrlQ:SetText(string.format("%s   %s ",ico,NLFeventQuests[i].qname))
		local myLabelWidth=ctrlQ:GetLabelControl():GetTextWidth()+25
		ctrlQ:SetWidth(myLabelWidth)
		if myLabelWidth > TimNewYearUI:GetWidth() then TimNewYearUI:SetWidth(myLabelWidth) end
	end

--	if getBuff==true then
--		--xp-buff icon and maybe activate
--		local ctrlB=WINDOW_MANAGER:GetControlByName("TIM99_NewYear_Bg")
--		if not ctrlB then return end
--		if tny.hasXpBuffEnabled() then
--			ctrlB:SetHidden(true)
--		else
--			ctrlB:SetHidden(false)
--			if tny.svAcc.useMead then zo_callLater(function() tny.drinkAndVerify() end,1000) end
--		end
--	end
end
----------------------------------------------------------------------------------------------------
--function tny.onEffectChanged(eventCode,changeType,_,effectName,_,beginTime,endTime,_,iconName, _, _, _, _, _, _,abilityId)
--	local durationSeconds=(endTime-beginTime)
--	if tny.svAcc.debugLog then
--		CHAT_SYSTEM:AddMessage(string.format("|c9B30FFonEffectChanged,  changeType [|r%s|c9B30FF], abilityId [|r%s -%s|c9B30FF]|r",changeType,abilityId,effectName)) --1=GAINED 2-FADED 3-UPDATED 4-FULL_REFRESH 5=TRANSFER
--		CHAT_SYSTEM:AddMessage(string.format("|c9B30FF beginTime [|r%s|c9B30FF] - endTime [|r%s|c9B30FF]  duration [|r%s sec |c9B30FFoder|r %s min|c9B30FF]|r",GetNiceTime(beginTime),GetNiceTime(endTime),math.floor(durationSeconds),math.floor(durationSeconds/60)))
--	end
--	local ctrlB=WINDOW_MANAGER:GetControlByName("TIM99_NewYear_Bg")
--	if not ctrlB then CHAT_SYSTEM:AddMessage("-E- |c9B30FFonEffectChanged, WM:GetControlByName failed|r") end
--	--xp-buff
--	if durationSeconds < 1 then
--		if ctrlB then ctrlB:SetHidden(false) end
--		if tny.svAcc.useMead then --auto drink
--			zo_callLater(function() tny.drinkAndVerify() end,1000)
--		end
--	else
--		if ctrlB then ctrlB:SetHidden(true) end
--	end
--end
----------------------------------------------------------------------------------------------------
function tny.onQuestCompleteDialog(eventCode,journalQuestIndex)
	local _,_,confirmComplete,_,_,_=GetJournalQuestEnding(journalQuestIndex)	
	local ticketsFound=false
	local ticketsAmount=0
	if confirmComplete=="" then confirmComplete=GetString(SI_DEFAULT_QUEST_COMPLETE_CONFIRM_TEXT) end
	local rewardDataList=INTERACTION:GetRewardData(journalQuestIndex,false)
	if #rewardDataList==0 then
		if tny.svAcc.debugLog then CHAT_SYSTEM:AddMessage(tny.cl_blu:Colorize("CompleteQuest (reward=0)")) end
		CompleteQuest()
		if tny.svAcc.debugLog then CHAT_SYSTEM:AddMessage(tny.cd_red:Colorize("CloseChatter() (CompleteQuest1)")) end
		INTERACTION:CloseChatter()return
	end
	for i,data in ipairs(rewardDataList) do
		if data.rewardType==REWARD_TYPE_EVENT_TICKETS then
			ticketsFound=true
			ticketsAmount=data.amount
			break
		else
			ticketsFound=false
		end
	end
	if ticketsFound==true then
		local optionText=''
		local myTickets=GetCurrencyAmount(CURT_EVENT_TICKETS,CURRENCY_LOCATION_ACCOUNT)
		if myTickets > (12-ticketsAmount) then
			if IJA_EVENTTICKETSAVER then return end --if IsJustaTicketSaver installed, let it handle this
			ZO_Alert(UI_ALERT_CATEGORY_ERROR,SOUNDS.NEGATIVE_CLICK,GetString(aTIM99_NLF_INGAME_LOOSETICKETS))
			optionText=zo_strformat(tny.cl_red:Colorize("[<<1>>/12 "..GetString(aTIM99_NLF_INGAME_NUMTICKETS).."] <<2>>"),myTickets,confirmComplete)
			INTERACTION:PopulateChatterOption(1,CompleteQuest,optionText,CHATTER_COMPLETE_QUEST)
			return
		else
			if tny.svAcc.debugLog then CHAT_SYSTEM:AddMessage(tny.cl_blu:Colorize(string.format("CompleteQuest (Tickets IS=%s,GET=%s)",myTickets,ticketsAmount))) end
			CompleteQuest()
			if not tny.svAcc.autoFollowQ then
				if tny.svAcc.debugLog then CHAT_SYSTEM:AddMessage(tny.cd_red:Colorize("CloseChatter() (CompleteQuest2)")) end
				INTERACTION:CloseChatter()
				return 
			end
		end
	else
		if tny.svAcc.debugLog then CHAT_SYSTEM:AddMessage(tny.cl_blu:Colorize("CompleteQuest (NoTicketreward)")) end
		CompleteQuest()
		if not tny.svAcc.autoFollowQ then
			if tny.svAcc.debugLog then CHAT_SYSTEM:AddMessage(tny.cd_red:Colorize("CloseChatter() (CompleteQuest3)")) end
			INTERACTION:CloseChatter()
			return
		end
	end	
end
----------------------------------------------------------------------------------------------------
function tny.ConversationUpdated(eventCode,bodyText,optionCount)
	if tny.svAcc.debugLog then CHAT_SYSTEM:AddMessage(tny.c6_gry:Colorize(string.format("another dialog step, options: %s", optionCount))) end
	if tny.isAubatha then tny.aubatStep=tny.aubatStep+1 end
	if optionCount==0 or (tny.isAubatha and tny.aubatStep>8) then --Aubatha talks forever and never has "goodbye" only
		if tny.svAcc.debugLog then CHAT_SYSTEM:AddMessage(tny.cd_red:Colorize("CloseChatter() (another dialog step)")) end
		INTERACTION:CloseChatter()return
	end
	if tny.svAcc.debugLog then CHAT_SYSTEM:AddMessage(tny.c_orng:Colorize(string.format("SelectChatterOption(1), AubathaStep=[%s]",tny.aubatStep))) end
	
	local optionString,optionType=GetChatterOption(1)
	if tny.svAcc.debugLog then CHAT_SYSTEM:AddMessage("optionCount="..tostring(optionCount)..",  optionString="..tostring(optionString)..",  optionType="..tostring(optionType)) end
	if tostring(optionType)=="102" and TipOrKill[tostring(optionString)] then
		if tny.svAcc.tipOrKill=="tip" then
			CHAT_SYSTEM:AddMessage(string.format("|c9B30FF[NLF]|r %s...",GetString(aTIM99_NLF_INGAME_GRAHTINFO_DONATE)))
			SelectChatterOption(1)
		elseif tny.svAcc.tipOrKill=="kill" then
			CHAT_SYSTEM:AddMessage(string.format("|c9B30FF[NLF]|r %s...",GetString(aTIM99_NLF_INGAME_GRAHTINFO_KILL)))
			INTERACTION:CloseChatter()
		else
			CHAT_SYSTEM:AddMessage(string.format("|c9B30FF[NLF]|r %s...",GetString(aTIM99_NLF_INGAME_GRAHTINFO_ASK)))
			--ask me each time: do nothing
		end
	else
		SelectChatterOption(1)
	end
end
----------------------------------------------------------------------------------------------------
function tny.onChatterBegin(eventCode,optionCount)
	if IsShiftKeyDown() then return end
	local optionString,optionType = GetChatterOption(1)
	local _,NPCname = GetGameCameraInteractableActionInfo()
	if tny.svAcc.debugLog then CHAT_SYSTEM:AddMessage(string.format('ChatterBegin: |c00FFFF[%s] - [%s] - #[%s] - [%s]|r',tostring(NPCname),tostring(optionType),tostring(optionCount),tostring(optionString))) end

	--MODIFIED HOFTS AWESOME SCRIPTS FOR HERE (1st=NPC, 2nd=OfferedQuest)
	--Usage: copy to ingame chat while having the specific dialog to the NPC open 
	-- /script local _,name=GetGameCameraInteractableActionInfo() StartChatInput(zo_strformat("NPCname==\""..tostring(name).."\" or	--<<1>>,", GetUnitZone('player')))
	-- /script local quoff=select(2,GetOfferedQuestInfo()) StartChatInput("[\""..quoff.."\"]=true,")
	
	-- Event-Writs
	if tostring(NPCname)=="nil" and tostring(optionType)=="4000" and (COOK[tostring(optionString)] or WOOD[tostring(optionString)] or CLOTH[tostring(optionString)] or FORGE[tostring(optionString)]) then
		if tny.svAcc.debugLog then CHAT_SYSTEM:AddMessage("Eventwrit done") end
		EVENT_MANAGER:RegisterForEvent(tny.name, EVENT_QUEST_COMPLETE_DIALOG, tny.onQuestCompleteDialog)
		EVENT_MANAGER:RegisterForEvent(tny.name, EVENT_CHATTER_END, function()
			if tny.svAcc.debugLog then CHAT_SYSTEM:AddMessage("Unregister all") end
			EVENT_MANAGER:UnregisterForEvent(tny.name, EVENT_CONVERSATION_UPDATED) tny.isAubatha=false tny.aubatStep=0
			EVENT_MANAGER:UnregisterForEvent(tny.name, EVENT_QUEST_OFFERED)
			EVENT_MANAGER:UnregisterForEvent(tny.name, EVENT_QUEST_COMPLETE_DIALOG)
			EVENT_MANAGER:UnregisterForEvent(tny.name, EVENT_CHATTER_END)
		end)
		if optionCount==0 then INTERACTION:CloseChatter()return end
		SelectChatterOption(1)
	
	-- Main quest-giver
	elseif MAIN_NPC_QUEST[NPCname] then
		if optionCount==0 then
			if tny.svAcc.debugLog then CHAT_SYSTEM:AddMessage(tny.cd_red:Colorize("CloseChatter() (onChatterBegin)")) end
			INTERACTION:CloseChatter()return
		end
		--listen if another dialog step will come
		tny.isAubatha=false tny.aubatStep=0
		EVENT_MANAGER:RegisterForEvent(tny.name, EVENT_CONVERSATION_UPDATED, tny.ConversationUpdated)
		--listen if quest incoming
		EVENT_MANAGER:RegisterForEvent(tny.name, EVENT_QUEST_OFFERED, function()
			if tny.svAcc.debugLog then CHAT_SYSTEM:AddMessage("Offered Quest=|c999999"..select(2,GetOfferedQuestInfo()).."|r") end
			if FalseAlertQuestOffered[select(2,GetOfferedQuestInfo())] then --not really a quest, just another dialog step...
				if tny.svAcc.debugLog then CHAT_SYSTEM:AddMessage("|cFF9900 Accept Fakequest  -  |r|c999999"..select(2,GetOfferedQuestInfo()).."|r") end
				AcceptOfferedQuest()
				return
			else
				if tny.svAcc.debugLog then CHAT_SYSTEM:AddMessage(tny.cd_grn:Colorize("AcceptOfferedQuest()")) end
				AcceptOfferedQuest() --uncomment to also accept quest, not just skip dialogue before
				return
			end
		end)
		--listen if quest is finished
		EVENT_MANAGER:RegisterForEvent(tny.name, EVENT_QUEST_COMPLETE_DIALOG, tny.onQuestCompleteDialog)
		--unreg all if dialogbox closed
		EVENT_MANAGER:RegisterForEvent(tny.name, EVENT_CHATTER_END, function()
			if tny.svAcc.debugLog then CHAT_SYSTEM:AddMessage("Unregister all mainNpc") end
			EVENT_MANAGER:UnregisterForEvent(tny.name, EVENT_CONVERSATION_UPDATED) tny.isAubatha=false tny.aubatStep=0
			EVENT_MANAGER:UnregisterForEvent(tny.name, EVENT_QUEST_OFFERED)
			EVENT_MANAGER:UnregisterForEvent(tny.name, EVENT_QUEST_COMPLETE_DIALOG)
			EVENT_MANAGER:UnregisterForEvent(tny.name, EVENT_CHATTER_END)
			tny.refreshUI()
		end)
		--finally our move
		if tny.svAcc.debugLog then CHAT_SYSTEM:AddMessage(tny.c6_gry:Colorize(string.format('first dialog step, options: %s', optionCount))) end
		if optionCount==0 then
			if tny.svAcc.debugLog then CHAT_SYSTEM:AddMessage(tny.c_orng:Colorize("CloseChatter() (first dialog step)")) end
			INTERACTION:CloseChatter()return
		end
		if tny.svAcc.debugLog then CHAT_SYSTEM:AddMessage(tny.c_orng:Colorize("SelectChatterOption(1)")) end
		SelectChatterOption(1)

	-- Event vendoor
	elseif FESTIVAL_VENDOORS[NPCname] then
		if tny.svAcc.debugLog then CHAT_SYSTEM:AddMessage(tny.c_orng:Colorize("SelectChatterOption(1)")) end
		SelectChatterOption(1)

	-- On-location side NPC
	elseif (SIDE_NPC_QUEST[NPCname] or SIDE_NPC_ALIKR[NPCname]) then --quest-steps
		--unreg all if dialogbox closed
		EVENT_MANAGER:RegisterForEvent(tny.name, EVENT_CHATTER_END, function()
			if tny.svAcc.debugLog then CHAT_SYSTEM:AddMessage("Unregister all sideNpc") end
			EVENT_MANAGER:UnregisterForEvent(tny.name, EVENT_CONVERSATION_UPDATED) tny.isAubatha=false tny.aubatStep=0
			EVENT_MANAGER:UnregisterForEvent(tny.name, EVENT_CHATTER_END)
		end)
		--listen if another dialog step
		if SIDE_NPC_ALIKR[NPCname] then tny.isAubatha=true else tny.isAubatha=false end
		tny.aubatStep=0
		EVENT_MANAGER:RegisterForEvent(tny.name, EVENT_CONVERSATION_UPDATED, tny.ConversationUpdated)
		--finally our move 
		if tny.svAcc.debugLog then CHAT_SYSTEM:AddMessage(tny.c6_gry:Colorize(string.format('first sideNPC step, options: %s', optionCount))) end
		if optionCount==0 then 
			if tny.svAcc.debugLog then CHAT_SYSTEM:AddMessage(tny.c_orng:Colorize("CloseChatter() (first sideNPC step)")) end
			INTERACTION:CloseChatter()return 
		end
		if tny.svAcc.debugLog then CHAT_SYSTEM:AddMessage(tny.c_orng:Colorize("SelectChatterOption(1)")) end
		SelectChatterOption(1)

	end	
	-- /script SelectChatterOption(1)
end
----------------------------------------------------------------------------------------------------
function tny.onQuestAdded(eventCode,journalIndex,questName,objectiveName)
	--jetzt ists a scho wurscht
	for i=1,#NLFeventQuests do
		if questName==NLFeventQuests[i].qname then
			if i==1 and IsCollectibleUnlocked(GetCollectibleIdForHouse(3))==true then --Stonefalls
				ZO_Alert(UI_ALERT_CATEGORY_ALERT,SOUNDS.POSITIVE_CLICK,"|cffff00Info - house is nearby at SECOND quest position (3/4)|r")
				break
			elseif i==3 and IsCollectibleUnlocked(GetCollectibleIdForHouse(4))==true then --Auridon
				ZO_Alert(UI_ALERT_CATEGORY_ALERT,SOUNDS.POSITIVE_CLICK,"|cffff00Info - house is nearby at quest position|r")
				break
			elseif i==6 and IsCollectibleUnlocked(GetCollectibleIdForHouse(29))==true then --Eastmarch
				ZO_Alert(UI_ALERT_CATEGORY_ALERT,SOUNDS.POSITIVE_CLICK,"|cffff00Info - house is nearby at FIRST quest position (1/3)|r")
				break
			elseif i==7 and IsCollectibleUnlocked(GetCollectibleIdForHouse(23))==true then --ReapersMarch
				ZO_Alert(UI_ALERT_CATEGORY_ALERT,SOUNDS.POSITIVE_CLICK,"|cffff00Info - house is somewhere at quest position|r")
				break
			end
		end
	end
	tny.refreshUI()
end
----------------------------------------------------------------------------------------------------
function tny.onQuestComplete(eventCode,questName,level,previousExperience,currentExperience,championPoints,questType,instanceDisplayType)
	if questType==QUEST_TYPE_HOLIDAY_EVENT then
		for i=1, #NLFeventQuests do
			if NLFeventQuests[i].qname==questName then 
				tny.svChr[questName]=GetTimeStamp() 
				tny.refreshUI()
			end
		end
	end
end
----------------------------------------------------------------------------------------------------
function tny.onInventorySingleSlotUpdate(eventCode,bagId,slotId,isNew)
	if not isNew then return end
	if IsUnderArrest() then return end
	--if IsItemJunk(bagId, slotId) then return end
	local itemLink=GetItemLink(bagId,slotId)
	local itemId=select(4,ZO_LinkHandler_ParseLink(itemLink))
	--white junk
	if tny.svAcc.markJunk==true or tny.svAcc.deleteJunk==true then
		if itemId=="96956" or	--|H1:item:96956:2:1:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h  [Falsche Jongliermesser]
		   itemId=="96955" or	--|H1:item:96955:2:1:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h  [Falsches Schwert für Schwertschlucker]
		   itemId=="96959" or	--|H1:item:96959:2:1:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h  [Schlammball]
		   itemId=="96958" 		--|H1:item:96958:2:1:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0:0|h|h  [Ölbrötchen eines Feuerspuckers]
		then
			if tny.svAcc.markJunk==true then
				local stackCnt,_=GetSlotStackSize(BAG_BACKPACK,slotId)
				SetItemIsJunk(bagId,slotId,true)
				if tny.svAcc.chatMarkJunk or tny.svAcc.debugLog then
					CHAT_SYSTEM:AddMessage(string.format("|c666666[NLF]|r %s: |cFFFFFF%s|rx%s|cFFFFFF[%s]|r",
						GetString(aTIM99_NLF_INGAME_MARKJUNK), stackCnt, zo_iconFormat(GetItemLinkIcon(itemLink),24,24), itemLink))
				end
				return
			elseif tny.svAcc.deleteJunk==true then
				local stackCnt,_=GetSlotStackSize(BAG_BACKPACK,slotId)
				DestroyItem(bagId,slotId)
				if tny.svAcc.chatDelJunk or tny.svAcc.debugLog then
					CHAT_SYSTEM:AddMessage(string.format("|c666666[NLF]|r %s: |cFFFFFF%s|rx%s|cFFFFFF[%s]|r",
						GetString(aTIM99_NLF_INGAME_DELJUNK), stackCnt, zo_iconFormat(GetItemLinkIcon(itemLink),24,24), itemLink))
				end
				return
			end	
		end
	end
	--golden junk
	if  (itemId=="171330" and tny.svAcc.snowball) or		--|H1:item:171330:124:6:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h  "Runenkiste: Schneeballfreund"
		(itemId=="182487" and tny.svAcc.kaninchen) or		--|H1:item:182487:124:6:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h  "Runenkiste: puderweißes Kaninchen"
		(itemId=="96395"  and tny.svAcc.feuerspucker) or	--|H1:item:96395:124:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h   "Runenkiste: Fackeln des Feuerspuckers"
		(itemId=="96392"  and tny.svAcc.schwertschl) or		--|H1:item:96392:124:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h   "Runenkiste: Klinge des Schwertschluckers"
		(itemId=="96393"  and tny.svAcc.jongleur) or		--|H1:item:96393:124:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h   "Runenkiste: Messer des Jongleurs"
		(itemId=="96951"  and tny.svAcc.badetuch) or		--|H1:item:96951:124:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h   "Runenkiste: nordisches Badetuch"
		(itemId=="96391"  and tny.svAcc.schlammball) or		--|H1:item:96391:124:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h   "Runenkiste: Schlammbeutel"
		(itemId=="96953"  and tny.svAcc.hood1) or			--|H1:item:96953:124:6:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h   "Runenkiste: colovianische Filigranhaube"
		(itemId=="96952"  and tny.svAcc.hood2)				--|H1:item:96952:124:6:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h   "Runenkiste: colovianische Pelzhaube"
	then
		local stackCnt,_=GetSlotStackSize(BAG_BACKPACK,slotId)
		DestroyItem(bagId,slotId)
		if tny.svAcc.chatDelRunes then
			CHAT_SYSTEM:AddMessage(string.format("|c666666[NLF]|r %s: |cFFFFFF%s|rx%s|cFFFFFF[%s]|r",GetString(aTIM99_NLF_INGAME_DELJUNK), stackCnt, zo_iconFormat(GetItemLinkIcon(itemLink),24,24), itemLink))
		end
		return
	end

	--writs
	--|H1:item:167170:5:6:0:0:0:33819:0:0:0:0:0:0:0:0:0:0:0:0:0:10000|h|h   [Kaiserlicher Wohltätigkeitsschrieb] lila
	--|H1:item:156735:4:6:0:0:0:117954:0:0:0:0:0:0:0:0:0:0:0:0:0:10000|h|h  [Tiefwinter-Wohltätigkeitsschrieb]   blau
	if	(itemId=="167169" and tny.svAcc.delPurpWrits) or  --Schmied
		(itemId=="167170" and tny.svAcc.delPurpWrits) or  --Kochen
		(itemId=="167171" and tny.svAcc.delPurpWrits) or  --Schreiner
		(itemId=="167172" and tny.svAcc.delPurpWrits) or  --Schneider
	
		(itemId=="156731" and tny.svAcc.delBlueWrits) or  --Schmied
		(itemId=="156733" and tny.svAcc.delBlueWrits) or  --Schneider
		(itemId=="156735" and tny.svAcc.delBlueWrits)     --Schreiner
	then
		local stackCnt,_=GetSlotStackSize(BAG_BACKPACK,slotId)
		DestroyItem(bagId,slotId)
		if tny.svAcc.chatDelRunes then
			CHAT_SYSTEM:AddMessage(string.format("|c666666[NLF]|r %s: |cFFFFFF%s|rx%s|cFFFFFF[%s]|r",GetString(aTIM99_NLF_INGAME_DELJUNK), stackCnt, zo_iconFormat(GetItemLinkIcon(itemLink),24,24), itemLink))
		end
		return
	end
	---writs ende

end
----------------------------------------------------------------------------------------------------
local function onStoreInventory(eventCode,bagId,slotIndex,isNewItem)
	local myCol="9B30FF"
	--d(string.format("onStoreInventory;  eventCode=%s  bagId=%s  slotIndex=%s",eventCode,bagId,slotIndex))
	if (bagId==BAG_BACKPACK) then
		--CHECK RECEIVED
		if eventCode~=0 and slotIndex~=0 then --would be first run
			--check that we have the expected itemId
			local _itemLink=GetItemLink(bagId,slotIndex)
			local _itemId=GetItemLinkItemId(_itemLink)
			if not(_itemId==tny.waitForInvItem) then 
				--d("|cff0000 not the expected one: |r".._itemId.."/"..tny.waitForInvItem) 
				return 
			end
			--check that we have the expected quantity
			local _quantity=GetSlotStackSize(bagId,slotIndex)
			if not(_quantity==tny.waitForInvQuan) then 
				--d("|cff0000 not the expected qty: |r".._quantity.."/"..tny.waitForInvQuan) 
			end
		end
		--SEND NEXT
		local foundNext=false
		for i=1,#tny.GETFROMBANK do
			--Notlösung: craftgear items, die ich im "onOpenBank"-Loop nicht gefunden hab, haben auch keinen slotIndex: überspringen
			if tny.GETFROMBANK[i].bagId~=0 and tny.GETFROMBANK[i].slotIdx~=0 and GetSlotStackSize(tny.GETFROMBANK[i].bagId,tny.GETFROMBANK[i].slotIdx)>0 then
				local invCnt,bankCnt,crftBagCnt=GetItemLinkStacks(tny.GETFROMBANK[i].link) --leider haben craftgear-items IMMER 0
				if invCnt<tny.GETFROMBANK[i].cnt then --nur items moven, von denen mir was fehlt im Inv
					--d(string.format("%s - %s / %s",tny.GETFROMBANK[i].link,invCnt,tny.GETFROMBANK[i].cnt))
					local bag=tny.GETFROMBANK[i].bagId
					local slot=tny.GETFROMBANK[i].slotIdx
					local cnt=invCnt>0 and tny.GETFROMBANK[i].cnt-invCnt or tny.GETFROMBANK[i].cnt
					local maxcnt=select(2,GetSlotStackSize(bag,slot))
					cnt=cnt>maxcnt and maxcnt or cnt
					local itemLink=GetItemLink(bag,slot)
					local itemId=GetItemLinkItemId(itemLink)
					--local uniqueIdString=Id64ToString(GetItemUniqueId(bag,slot))
					--d("itemLink2="..itemLink..";  bag="..bag.."  slot="..slot)
					tny.waitForInvItem=itemId
					tny.waitForInvQuan=cnt
					tny.GETFROMBANK[i].bagId=0   --reset damit im nächsten Loop nicht das gleiche Item wieder probiert wird
					tny.GETFROMBANK[i].slotIdx=0 --reset damit im nächsten Loop nicht das gleiche Item wieder probiert wird
					foundNext=true
					if not tny.isRegGetInv then
						EVENT_MANAGER:RegisterForEvent("Tim99NLFStoreInv",EVENT_INVENTORY_SINGLE_SLOT_UPDATE,onStoreInventory)
						EVENT_MANAGER:AddFilterForEvent("Tim99NLFStoreInv",EVENT_INVENTORY_SINGLE_SLOT_UPDATE,REGISTER_FILTER_BAG_ID,BAG_BACKPACK)
						tny.isRegGetInv=true
					end
					local emptySlot=FindFirstEmptySlotInBag(BAG_BACKPACK)
					--d(string.format("move bagFrom=%s  slotFrom=%s  bagTo=%s   slotTo=%s  cnt=%s",bag,slot,BAG_BACKPACK,emptySlot,cnt))
					CallSecureProtected("RequestMoveItem",bag,slot,BAG_BACKPACK,emptySlot,cnt)
					--CHAT_SYSTEM:AddMessage(string.format("|c666666[NewLifeFestival]|r    -%sx [%s] |c9B30FFpicked|r",tostring(cnt),tostring(itemLink)))
					tny.closeBanker=true
					break
				end
			end
		end
		--ALL DONE?
		if foundNext==false then
			local invCnt,bankCnt,crftBagCnt=GetItemLinkStacks("|H1:item:100393:27:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")
			myCol=invCnt>0 and "66ff66" or "ff6666"
			CHAT_SYSTEM:AddMessage("    |H1:item:100393:27:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h : |c"..myCol..invCnt.." / "..bankCnt.."|r")
			local invCnt,bankCnt,crftBagCnt=GetItemLinkStacks("|H1:item:100394:27:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")
			myCol=invCnt>0 and "66ff66" or "ff6666"
			CHAT_SYSTEM:AddMessage("    |H1:item:100394:27:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h : |c"..myCol..invCnt.." / "..bankCnt.."|r")
			local invCnt,bankCnt,crftBagCnt=GetItemLinkStacks("|H1:item:100395:27:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")
			myCol=invCnt>0 and "66ff66" or "ff6666"
			CHAT_SYSTEM:AddMessage("    |H1:item:100395:27:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h : |c"..myCol..invCnt.." / "..bankCnt.."|r")
			EVENT_MANAGER:UnregisterForEvent("Tim99NLFStoreInv",EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
			tny.isRegGetInv=false
			StackBag(BAG_BACKPACK)
			StackBag(BAG_BANK)
			StackBag(BAG_SUBSCRIBER_BANK)
			CHAT_SYSTEM:AddMessage(string.format("|c9B30FF[NLF]|r %s",GetString(aTIM99_NLF_INGAME_FISHTAKEN)))
			if tny.closeBanker and tny.svAcc.closeBanker then
				local function recursiveCall() 
					zo_callLater(function() 
						if GetInteractionType()==6 then
							if tny.svAcc.dismisBanker then ZO_SharedInteraction:CloseChatterAndDismissAssistant() end
							SCENE_MANAGER:Show('hud')
							recursiveCall()
						end
					end,200) 
				end
				recursiveCall()
			end
		end
	end
end
----------------------------------------------------------------------------------------------------
function tny.onOpenBank(event,bagId)
	if IsHouseBankBag(bagId) then return end
	tny.closeBanker=false
	
	for j=1,MAX_JOURNAL_QUESTS do
		if IsValidQuestIndex(j) then
			local questName,_,_,_,_,_,tracked,_,_,_,_=GetJournalQuestInfo(j)
			if questName==NLFeventQuests[2].qname then
			--if questName=="Mahlstrom-Arena" then --test outside of event
				--CHAT_SYSTEM:AddMessage(string.format("|c666666[NewLifeFestival]|r|c9B30FF > moving list to inventory...|r"))
				local bag=SHARED_INVENTORY:GenerateFullSlotData(nil,BAG_BANK,BAG_SUBSCRIBER_BANK)
				for i=1,#tny.GETFROMBANK do
					--d(tny.GETFROMBANK[i].link)
					tny.GETFROMBANK[i].bagId=0
					tny.GETFROMBANK[i].slotIdx=0
					for j,data in pairs(bag) do 
						if GetItemLinkItemId(GetItemLink(data.bagId,data.slotIndex))==tny.GETFROMBANK[i].id then
							if GetSlotStackSize(data.bagId,data.slotIndex)>=tny.GETFROMBANK[i].cnt then
								tny.GETFROMBANK[i].bagId=data.bagId
								tny.GETFROMBANK[i].slotIdx=data.slotIndex
								table.remove(bag,j)
								break
							end
						end
					end
				end
				onStoreInventory(0,BAG_BACKPACK,0,0)		
			end
		end
	end
end
----------------------------------------------------------------------------------------------------
function tny.onCloseBank()
	--EVENT_MANAGER:UnregisterForEvent("Tim99PreStoreBank",EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
	EVENT_MANAGER:UnregisterForEvent("Tim99NLFStoreInv",EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
end
----------------------------------------------------------------------------------------------------
function tny.onCurrencyUpdate(event,currencyType,currencyLocation,newAmount,oldAmount,reason)
	--d("onCurrencyUpdate")
	if reason==35 or reason==42 or reason==43 then return end --35=PLAYER_INIT,42=BANK_DEPOSIT,43=BANK_WITHDRAWAL
	if currencyType==CURT_EVENT_TICKETS then
		local label=WINDOW_MANAGER:GetControlByName("TIM99_NewYear_EventTickets")
		if label then
			label:SetText(string.format("|cFA58F4%s/12|r|t16:16:/esoui/art/currency/currency_eventticket.dds|t",tostring(newAmount)))
		end
		if not aTim99_Twink then
			local myIco=ZO_Currency_FormatPlatform(currencyType,(newAmount-oldAmount),ZO_CURRENCY_FORMAT_AMOUNT_ICON)
			CHAT_SYSTEM:AddMessage(string.format("|c666666[NLF] [%s]|r |cFA58F4%s: %s|r   |c4d4d4d(%s)|r",GetTimeString(),GetUnitName("player"),myIco,tostring(reason)))
		end
	end
end
----------------------------------------------------------------------------------------------------
function tny.onFastTravelInteraction(event,nodeIndex)
	if IsShiftKeyDown() then return end
	for journIdx=1,MAX_JOURNAL_QUESTS do
		if IsValidQuestIndex(journIdx) then
			local questName,_,activeStepText,_,activeStepTrackerOverrideText,completed,tracked,_,_,questType,_=GetJournalQuestInfo(journIdx)
			if questType==QUEST_TYPE_HOLIDAY_EVENT and tracked==true then
				if Startquest[questName] then	--Startquest
					local known,name,_,_,icon=GetFastTravelNodeInfo(89)
					if known and tny.svAcc.chatTravelInfo then CHAT_SYSTEM:AddMessage(string.format("|c9B30FF[NLF] port:|r%s%s",zo_iconFormat(icon,24,24),zo_strformat("<<1>>",name))) end
					FastTravelToNode(89)
					return
				end
				for j=1,#NLFeventQuests do
					if questName==NLFeventQuests[j].qname then
						for stepIdx=1,GetJournalQuestNumSteps(journIdx) do
							local stepText,_,_,trackerOverrideText,numConditions=GetJournalQuestStepInfo(journIdx,stepIdx)
							
							--if GetDisplayName()=="@tïm'99" then
							--	if stepText==activeStepText and trackerOverrideText==activeStepTrackerOverrideText then
							--		d("|c00ff00wäre gutgegangen|r")
							--	else
							--		d("|cff0000wäre schiefgegangen!!!|r")
							--	end
							--end
							
							local questText=(trackerOverrideText==nil or trackerOverrideText=="") and stepText or trackerOverrideText
							if tny.svAcc.debugLog then CHAT_SYSTEM:AddMessage(string.format("|c0000ff questText =|r %s",tostring(questText))) end
							local shrineArr=(j==10) and destOld or destOrg
							for k=1,#shrineArr do
								if string.match(questText,shrineArr[k].qstep) then
									if tny.svAcc.debugLog then CHAT_SYSTEM:AddMessage(string.format("ArrayNr[%s]  -  |c00ff00FastTravel to|r %s (k=%s)",tostring(j),shrineArr[k].travelIdx,tostring(k))) end
									local known,name,_,_,icon=GetFastTravelNodeInfo(shrineArr[k].travelIdx)
									if not known and tny.svAcc.chatTravelInfo then
										CHAT_SYSTEM:AddMessage(string.format("|c9B30FF[NLF] unknown:|r%s%s",zo_iconFormat(icon,24,24),zo_strformat("<<1>>",name)))
									else
										if tny.svAcc.chatTravelInfo then
											CHAT_SYSTEM:AddMessage(string.format("|c9B30FF[NLF] port:|r%s%s",zo_iconFormat(icon,24,24),zo_strformat("<<1>>",name)))
										end
										FastTravelToNode(shrineArr[k].travelIdx)
									end
									return
								end
							end
						end
						return
					end
				end
			end
		end
	end
end
----------------------------------------------------------------------------------------------------
function tny.initUI()
	--tim99_NewLifeFestival.fragment = ZO_FadeSceneFragment:New(TimNewYearUI, true, 0)
	--HUD_SCENE:AddFragment(tim99_NewLifeFestival.fragment)
    --HUD_UI_SCENE:AddFragment(tim99_NewLifeFestival.fragment)
	TimNewYearUI:ClearAnchors();
	TimNewYearUI:SetAnchor(tny.svAcc.anchor[1],TimNewYearUI.parent,tny.svAcc.anchor[2],tny.svAcc.anchor[3],tny.svAcc.anchor[4])
	TimNewYearUI:GetNamedChild("Header"):SetText(GetString(aTIM99_NLF_MENU_TITLE))
	local h = 0
	--questlabels
	for i = 1, #NLFeventQuests do
		local ctrl = WINDOW_MANAGER:CreateControl("TIM99_NewYearEvent_Quest"..i,TimNewYearUI,CT_BUTTON)
		ctrl:SetHeight(26)
		ctrl:SetAnchor(TOPLEFT,TimNewYearUIHeader,BOTTOMLEFT,10,(i-1)*ctrl:GetHeight()+8)
		ctrl:SetText(NLFeventQuests[i].qname)
		ctrl:SetFont("$(MEDIUM_FONT)|14|soft-shadow-thin")
		ctrl:SetVerticalAlignment(TEXT_ALIGN_CENTER)
		ctrl:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
		--ctrl:SetHandler('OnMouseDown',function(self,button) d(tostring(button)) end)	
		if NLFeventQuests[i].locations==0 then
			ctrl:SetMouseEnabled(false)
		else
			if NLFeventQuests[i].locations==1 then
				ctrl:SetMouseEnabled(true)
				ctrl:EnableMouseButton(1,true)
				ctrl:EnableMouseButton(2,false)
			elseif NLFeventQuests[i].locations==2 then
				ctrl:SetMouseEnabled(true)
				ctrl:EnableMouseButton(1,true)
				ctrl:EnableMouseButton(2,true)
			end
			ctrl:SetClickSound(SOUNDS.DIALOG_ACCEPT)
			ctrl:SetHandler("OnClicked",function(self,button) tny.portToNearestWayshrine(NLFeventQuests[i].fastTravel,button) end)
		end
		h = h + ctrl:GetHeight()
	end
--	--mead-mug
--	local button=WINDOW_MANAGER:CreateControl("TIM99_NewYear_Mug",TimNewYearUI,CT_BUTTON)
--	button:SetDimensions(36,36)
--	button:SetAnchor(TOPRIGHT,TimNewYearUI,TOPRIGHT,0,0)
--	button:SetNormalTexture("/esoui/art/icons/housing_gen_inc_mugwood001.dds")
--	button:SetClickSound(SOUNDS.TELVAR_GAINED)
--	button:SetHandler("OnMouseEnter",function(button) ZO_Tooltips_ShowTextTooltip(button,BOTTOM,GetString(aTIM99_NLF_INGAME_USEMUGNOW)) end)
--	button:SetHandler("OnMouseExit",function(button) ZO_Tooltips_HideTextTooltip() end)
--	button:SetHandler("OnClicked",function(...) tny.drinkAndVerify() end)
--	--mead-mug background
--	local button=WINDOW_MANAGER:CreateControl("TIM99_NewYear_Bg",TimNewYearUI,CT_BUTTON)
--	button:SetDimensions(110,100)
--	button:SetAnchor(TOPRIGHT,TimNewYearUI,TOPRIGHT,35,-33)
--	button:SetNormalTexture("/esoui/art/crafting/burst_gold.dds")
--	button:SetVerticalAlignment(TEXT_ALIGN_CENTER)
--	button:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
--	button:SetDrawLayer(0)
--	button:SetHidden(true)
	--port to breda -house
	local button=WINDOW_MANAGER:CreateControl("TIM99_NewYear_JumpToBreda1",TimNewYearUI,CT_BUTTON)
	button:SetDimensions(32,32)
	button:SetAnchor(TOPLEFT,TimNewYearUI,TOPLEFT,-4,-4)
	button:SetNormalTexture("/esoui/art/login/authentication_trusted_up.dds")
	button:SetPressedTexture("/esoui/art/login/authentication_trusted_down.dds")
	button:SetMouseOverTexture("/esoui/art/login/authentication_trusted_over.dds")
	button:SetClickSound(SOUNDS.DIALOG_ACCEPT)
	button:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	button:SetHandler("OnMouseEnter",function(button) ZO_Tooltips_ShowTextTooltip(button,BOTTOM,GetString(aTIM99_NLF_INGAME_JUMPBREDAHOUSE)) end)
	button:SetHandler("OnMouseExit",function(button) ZO_Tooltips_HideTextTooltip() end)
	button:SetHandler("OnClicked",function(...)	Tim99_PortToSnowballHouse() end)
	--port to breda -wayshrine
	local button=WINDOW_MANAGER:CreateControl("TIM99_NewYear_JumpToBreda2",TimNewYearUI,CT_BUTTON)
	button:SetDimensions(38,32)
	button:SetAnchor(TOPLEFT,TIM99_NewYear_JumpToBreda1,TOPRIGHT,-15,0)
	button:SetNormalTexture("/NewLifeFestival/icon/wayshrine_up.dds")
	button:SetPressedTexture("/NewLifeFestival/icon/wayshrine_down.dds")
	button:SetMouseOverTexture("/NewLifeFestival/icon/wayshrine_over.dds")
	button:SetClickSound(SOUNDS.DIALOG_ACCEPT)
	button:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	button:SetHandler("OnMouseEnter",function(button) ZO_Tooltips_ShowTextTooltip(button,BOTTOM,GetString(aTIM99_NLF_INGAME_JUMPBREDAWS)) end)
	button:SetHandler("OnMouseExit",function(button) ZO_Tooltips_HideTextTooltip() end)
	button:SetHandler("OnClicked",function(...)	FastTravelToNode(89) end)
	if tny.svAcc.showShrine==false then button:SetHidden(true) end
	--curent event tickets
	local label=WINDOW_MANAGER:CreateControl("TIM99_NewYear_EventTickets",TimNewYearUI,CT_LABEL)
	label:SetAnchor(BOTTOMRIGHT,TimNewYearUI, BOTTOMRIGHT,-5,-1)
	label:SetVerticalAlignment(TEXT_ALIGN_RIGHT)
	label:SetFont("$(MEDIUM_FONT)|14|soft-shadow-thin")
	label:SetColor(250/255,88/255,244/255,1)
	label:SetText(string.format("|cff99ff%s/12|r|t16:16:/esoui/art/currency/currency_eventticket.dds|t",tostring(GetCurrencyAmount(CURT_EVENT_TICKETS,CURRENCY_LOCATION_ACCOUNT))))
	if tny.svAcc.showTickets==false then label:SetHidden(true) end
	--main window
	TimNewYearUI:SetHeight(h+18+TimNewYearUIHeader:GetHeight())
	TimNewYearUI:SetAlpha(1)
	TimNewYearUI:SetHidden(tny.svAcc.isHidden)
end
----------------------------------------------------------------------------------------------------
function tny.onPlayerActivated()
	--just once at beginning
	if tny.firstCall==true then
		tny.firstCall=false
		--Load data (colors, icon)
		tny.refreshUI(true)
		--handle visibility
		SCENE_MANAGER:RegisterCallback("SceneStateChanged",tny.onSceneChangeAll)
		--Skip Questdialoges
		if tny.svAcc.skipDlg==true then
			EVENT_MANAGER:RegisterForEvent(tny.name,EVENT_CHATTER_BEGIN,tny.onChatterBegin)
		end
		--Fasttravel at wayshrine
		if tny.svAcc.enableFastWs==true then
			EVENT_MANAGER:RegisterForEvent(tny.name,EVENT_START_FAST_TRAVEL_INTERACTION,tny.onFastTravelInteraction)
		end
		--Ticket gain/lost
		EVENT_MANAGER:RegisterForEvent(tny.name,EVENT_CURRENCY_UPDATE,tny.onCurrencyUpdate)
		--When to refresh UI
		EVENT_MANAGER:RegisterForEvent(tny.name,EVENT_QUEST_COMPLETE,tny.onQuestComplete)
		EVENT_MANAGER:RegisterForEvent(tny.name,EVENT_QUEST_ADDED,tny.onQuestAdded)   
		EVENT_MANAGER:RegisterForEvent(tny.name,EVENT_QUEST_REMOVED,tny.refreshUI)
		EVENT_MANAGER:RegisterForEvent(tny.name,EVENT_QUEST_LIST_UPDATED,tny.refreshUI)
		EVENT_MANAGER:RegisterForEvent(tny.name,EVENT_ACHIEVEMENT_UPDATED,tny.refreshUI)
		FOCUSED_QUEST_TRACKER:RegisterCallback("QuestTrackerTrackingStateChanged",tny.refreshTrackedQuest)
		--Mark trash
		EVENT_MANAGER:RegisterForEvent(tny.name,EVENT_INVENTORY_SINGLE_SLOT_UPDATE,tny.onInventorySingleSlotUpdate)
			EVENT_MANAGER:AddFilterForEvent(tny.name,EVENT_INVENTORY_SINGLE_SLOT_UPDATE,REGISTER_FILTER_IS_NEW_ITEM,true)
			EVENT_MANAGER:AddFilterForEvent(tny.name,EVENT_INVENTORY_SINGLE_SLOT_UPDATE,REGISTER_FILTER_BAG_ID,BAG_BACKPACK)
			EVENT_MANAGER:AddFilterForEvent(tny.name,EVENT_INVENTORY_SINGLE_SLOT_UPDATE,REGISTER_FILTER_INVENTORY_UPDATE_REASON,INVENTORY_UPDATE_REASON_DEFAULT)
		--Move fish
		if tny.svAcc.getFish==true then
			EVENT_MANAGER:RegisterForEvent(tny.name,EVENT_OPEN_BANK,tny.onOpenBank)
			EVENT_MANAGER:RegisterForEvent(tny.name,EVENT_CLOSE_BANK,tny.onCloseBank)
		end
		--watch for XP buff but dont push it-just try once then fuck it
--		EVENT_MANAGER:RegisterForEvent(tny.name.."91449",EVENT_EFFECT_CHANGED,tny.onEffectChanged)
--			EVENT_MANAGER:AddFilterForEvent(tny.name.."91449",EVENT_EFFECT_CHANGED,REGISTER_FILTER_ABILITY_ID,91449)
--			EVENT_MANAGER:AddFilterForEvent(tny.name.."91449",EVENT_EFFECT_CHANGED,REGISTER_FILTER_UNIT_TAG_PREFIX, "player")
--			EVENT_MANAGER:AddFilterForEvent(tny.name.."91449",EVENT_EFFECT_CHANGED,REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE,COMBAT_UNIT_TYPE_PLAYER)
--		EVENT_MANAGER:RegisterForEvent(tny.name.."86075",EVENT_EFFECT_CHANGED,tny.onEffectChanged)
--			EVENT_MANAGER:AddFilterForEvent(tny.name.."86075",EVENT_EFFECT_CHANGED,REGISTER_FILTER_ABILITY_ID,86075)
--			EVENT_MANAGER:AddFilterForEvent(tny.name.."86075",EVENT_EFFECT_CHANGED,REGISTER_FILTER_UNIT_TAG_PREFIX, "player")
--			EVENT_MANAGER:AddFilterForEvent(tny.name.."86075",EVENT_EFFECT_CHANGED,REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE,COMBAT_UNIT_TYPE_PLAYER)
		--if me then always drink at first login, just to refresh (guess noone else really wants this lol)
--		local displayName=GetDisplayName()
--		if displayName=="@tïm'99" or displayName=="@dmin666" or displayName=="@bofh666" or displayName=="@wu666" then
--			if tny.svAcc.useMead then tny.drinkAndVerify() end
--		end
		--switch on "automatic quest tracking" - this addon makes no sense otherwise
		if tny.svAcc.autoTrackQ==true then
			if tostring(GetSetting(SETTING_TYPE_UI,UI_SETTING_AUTOMATIC_QUEST_TRACKING))~=tostring(1) then
				CHAT_SYSTEM:AddMessage(string.format("|c9B30FF[NLF]|r setting switched on: 'automatic quest tracking'"))
				SetSetting(SETTING_TYPE_UI,UI_SETTING_AUTOMATIC_QUEST_TRACKING,1)
			end
		end
	end
	--each loading screen
	if IsPlayerInAvAWorld() or IsInImperialCity() or IsActiveWorldBattleground() then
		tny.isOnAvaBreak=true
		TimNewYearUI:SetHidden(true)
	else
		local justReturnedFromAva=tny.isOnAvaBreak
		tny.isOnAvaBreak = false
		if justReturnedFromAva==true then
			if tny.svAcc.isHidden==false then
				TimNewYearUI:SetHidden(false)
				tny.refreshUI(true)
			end
			--if tny.svAcc.useMead==true and not tny.hasXpBuffEnabled() then tny.drinkAndVerify() end
		
		else
			--if buff run out during loading screen we never get the event 
			--if tny.svAcc.isHidden==false then tny.refreshXPBuffLabel() end
		end
	end
end
----------------------------------------------------------------------------------------------------
function tny.addonLoaded(event, addonName)
	if addonName~=tny.name then return end
	EVENT_MANAGER:UnregisterForEvent(tny.name,EVENT_ADD_ON_LOADED)

	--Leave right away, if event is not running (first and last day it shows all day, even if event not (yet/any more) running)
	--i'm totally fine with that to not need messing around with MEZ, UTC, CET, GMT, FML...)
	local startDate=os.time{year=tny.EVENT_START_YEAR, month=tny.EVENT_START_MONTH, day=tny.EVENT_START_DAY, hour=0, min=0, sec=0, false}
	local endsDate=os.time{year=tny.EVENT_END_YEAR, month=tny.EVENT_END_MONTH, day=tny.EVENT_END_DAY+1, hour=0, min=0, sec=0, false}
	--if not (os.time() > startDate and os.time() < endsDate) then TimNewYearUI:SetHidden(true) return end

	--SavedVariabes (Acc=Settings, Char=QuestCompletion)
	tny.svChr=ZO_SavedVars:NewCharacterNameSettings("NewLifeSettings",1,nil,tny.svDefChr,GetWorldName())
	tny.svAcc=ZO_SavedVars:NewAccountWide("NewLifeSettings",1,nil,tny.svDefAcc,GetWorldName())

	--Callback when loading screen completed
	EVENT_MANAGER:RegisterForEvent(tny.name,EVENT_PLAYER_ACTIVATED,tny.onPlayerActivated)
	
	--MLS
	local myLang = GetCVar("language.2")
	if NLFeventQuestsTranslate[myLang]==nil then myLang = 'en' end
	do
		for k,data in pairs(NLFeventQuests) do
			data.qname = NLFeventQuestsTranslate[myLang][k]
		end
	end
	for i = 1,#destOrg do
		if     myLang == "de" then destOrg[i].qstep = destOrg[i].qstepDE
		elseif myLang == "ru" then destOrg[i].qstep = destOrg[i].qstepRU
		elseif myLang == "fr" then destOrg[i].qstep = destOrg[i].qstepFR
		end
	end	
	if     myLang == "de" then destOld[1].qstep = destOld[1].qstepDE
	elseif myLang == "ru" then destOld[1].qstep = destOld[1].qstepRU
	elseif myLang == "fr" then destOld[1].qstep = destOld[1].qstepFR
	end
	destOld[2].qstep = zo_strformat("<<1>>",GetZoneNameById(381))  --Auridon
	destOld[3].qstep = zo_strformat("<<1>>",GetZoneNameById(382))  --ReapersMarch
	destOld[4].qstep = zo_strformat("<<1>>",GetZoneNameById(3))    --Glenumbra
	destOld[5].qstep = zo_strformat("<<1>>",GetZoneNameById(92))   --Bangkorai
	destOld[6].qstep = zo_strformat("<<1>>",GetZoneNameById(41))   --Stonefalls
	destOld[7].qstep = zo_strformat("<<1>>",GetZoneNameById(103))  --Rift

	--Initialisation
	tny.initUI()
	tny.initMenu()

	--Keybinds (PortToBreda, ToggleWindow)
	ZO_CreateStringId("SI_BINDING_NAME_TIMNEWLIFE2",string.format("|cEECA2A%s|r",GetString(aTIM99_NLF_KEYBIND_2)))
	ZO_CreateStringId("SI_BINDING_NAME_TIMNEWLIFE1",string.format("|cEECA2A%s|r",GetString(aTIM99_NLF_KEYBIND_1)))
	ZO_CreateStringId("SI_BINDING_NAME_TIMNEWLIFE3",string.format("|cEECA2A%s|r",GetString(aTIM99_NLF_KEYBIND_3)))

	--Dont show anything on reticle for some guys
	ZO_PreHook(RETICLE,"TryHandlingInteraction",function(_, interactionPossible)
		local NPCname=select(2,GetGameCameraInteractableActionInfo())
		return interactionPossible and ANNOYING_NPC[NPCname]
	end)

	--Disable interacting for some guys    INTERACTIVE_WHEEL_MANAGER 
	local orgStartInteraction = INTERACTIVE_WHEEL_MANAGER.StartInteraction
	INTERACTIVE_WHEEL_MANAGER.StartInteraction = function(...)
		--[true] prevents interaction (DONT start), otherwise the original fn
		local NPCname=select(2,GetGameCameraInteractableActionInfo())
		return ANNOYING_NPC[NPCname] or orgStartInteraction(...)
	end


	SLASH_COMMANDS['/nlf']=function()
		Tim99_ToggleNewLifeMainWindow()
	end
	
	--Settings, Features
	--[[
	SLASH_COMMANDS['/tnl']=function()
		CHAT_SYSTEM:AddMessage(string.format("|c666666[%s]|r |c9B30FF######  TimNewLife-Festival-Chatcommands:  ######|r",GetTimeString()))
		CHAT_SYSTEM:AddMessage("  |c9B30FF*|r |c999999/tquests|r     |c9B30FF-prints all your current quests|r")
		CHAT_SYSTEM:AddMessage("  |c9B30FF*|r |c999999/tshow|r")
		CHAT_SYSTEM:AddMessage("       |c9B30FF-|r |c999999/tshow hudall|r   |c9B30FF-visible window in cursor-mode AND game-mode|r")
		CHAT_SYSTEM:AddMessage("       |c9B30FF-|r |c999999/tshow hud|r      |c9B30FF-visible window in game-mode only|r")
		CHAT_SYSTEM:AddMessage("       |c9B30FF-|r |c999999/tshow hudui|r    |c9B30FF-visible window in cursor-mode only|r")
		CHAT_SYSTEM:AddMessage("       |c9B30FF-|r |c999999/tshow keybind|r  |c9B30FF-window mode is controlled by keybind|r")
		CHAT_SYSTEM:AddMessage(" |c9B30FF- - - - - - - - - - - - - - - - - - - - - - - - -|r ")
		CHAT_SYSTEM:AddMessage(" |c9B30FFCurrent settings (accountwide):|r ")
		CHAT_SYSTEM:AddMessage(string.format("|c9B30FF [1]|r    |c999999/tskip|r %s", tny.svAcc.skipDlg==true and "on" or "off"))
		CHAT_SYSTEM:AddMessage(string.format("|c9B30FF [2]|r    |c999999/tshow|r %s", tny.svAcc.shownBy))
		CHAT_SYSTEM:AddMessage("|c9B30FF------------------------------------------------------------|r")
	end
	--]]

	--Chat-Commands
	--[[
	SLASH_COMMANDS['/tskip']=function(n)
		if n=="off" or n=="on" then
			if n=="off" then 
				tny.svAcc.skipDlg = false
				EVENT_MANAGER:UnregisterForEvent(tny.name,EVENT_CHATTER_BEGIN)
				EVENT_MANAGER:UnregisterForEvent(tny.name,EVENT_CONVERSATION_UPDATED)
				EVENT_MANAGER:UnregisterForEvent(tny.name,EVENT_QUEST_OFFERED)
				EVENT_MANAGER:UnregisterForEvent(tny.name,EVENT_QUEST_COMPLETE_DIALOG)
				EVENT_MANAGER:UnregisterForEvent(tny.name,EVENT_CHATTER_END)
			elseif n=="on" then 
				tny.svAcc.skipDlg = true
				EVENT_MANAGER:RegisterForEvent(tny.name,EVENT_CHATTER_BEGIN,tny.onChatterBegin)
			end
			CHAT_SYSTEM:AddMessage(string.format("|c9B30FF-I- Skipping dialogues changed to:|r |c999999/tskip|r |c00ffff%s|r",tny.svAcc.skipDlg==true and "on" or "off"))
		else
			CHAT_SYSTEM:AddMessage(string.format("|c9B30FF/? Skipping dialogues is set to:|r |c999999/tskip|r %s|c9B30FF. Options are...|r",tny.svAcc.skipDlg==true and "on" or "off"))
			CHAT_SYSTEM:AddMessage("     |c9B30FF-|r |c999999/tskip off|r   |c9B30FF-dont skip any dialogues.|r")
			CHAT_SYSTEM:AddMessage("     |c9B30FF-|r |c999999/tskip on|r   |c9B30FF-skip as much dialogues as possible.|r")
		end
	end
	--]]

	--[[
	SLASH_COMMANDS['/tshow']=function(n)
		if n=="hudall" or n=="hud" or n=="hudui" or n=="keybind" then
			tny.svAcc.shownBy = n
			CHAT_SYSTEM:AddMessage(string.format("|c9B30FF-I- Current visibility changed to:|r |c999999/tshow|r |c00ffff%s|r",tny.svAcc.shownBy))
		else
			CHAT_SYSTEM:AddMessage(string.format("|c9B30FF/? Current visibility is set to:|r |c999999/tshow|r %s|c9B30FF. Options are...|r",tny.svAcc.shownBy))
			CHAT_SYSTEM:AddMessage("     |c9B30FF-|r |c999999/tshow hudall|r   |c9B30FF-for visible window in cursor-mode AND game-mode|r")
			CHAT_SYSTEM:AddMessage("     |c9B30FF-|r |c999999/tshow hud|r   |c9B30FF-for visible window in game-mode only|r")
			CHAT_SYSTEM:AddMessage("     |c9B30FF-|r |c999999/tshow hudui|r   |c9B30FF-for visible window in cursor-mode only|r")
			CHAT_SYSTEM:AddMessage("     |c9B30FF-|r |c999999/tshow keybind|r   |c9B30FF-window mode is controlled by keybind|r")
		end
	end
	--]]

	--[[
	SLASH_COMMANDS['/tquests']=function()
		local myNumJournalQuests=GetNumJournalQuests()
		local preQuest=0
		local myCol
		CHAT_SYSTEM:AddMessage(string.format(" |c9B30FFCurrent quests in journal [|r%s|c9B30FF]:|r",tostring(myNumJournalQuests)))
		for i=1,MAX_JOURNAL_QUESTS do
			if IsValidQuestIndex(i) then
				myCol=(i==preQuest+1) and "9B30FF" or "FF0000"
				CHAT_SYSTEM:AddMessage(string.format(" |c%s[%02s] =|r |c999999\"%s\"|r",myCol,tostring(i),tostring(GetJournalQuestName(i))))
			end
			preQuest=i
		end 
	end
	--]]

	--[[
	SLASH_COMMANDS['/tsteps']=function(questIdx)
		if tonumber(questIdx)==nil then d("|cff6666Para not a number->journalQuestIdx, do|r |c999999/tquests|r |cff6666to find it|r") return end
		questIdx=tonumber(questIdx)
		if (questIdx < 1) or (questIdx > MAX_JOURNAL_QUESTS) then d("|cff6666Para too small/big->journalQuestIdx, do|r |c999999/tquests|r |cff6666to find it|r") return end
		CHAT_SYSTEM:AddMessage("|c4da6ff**************************************************************|r")
		if GetJournalQuestIsComplete(questIdx) then d("|c9B30FFstrange: QuestIsComplete|r") end
		
		local questName,backgroundText,activeStepText,activeStepType,activeStepTrackerOverrideText,completed,tracked,questLevel,pushed,questType,instanceDisplayType=GetJournalQuestInfo(questIdx)
		local myHoliday=(tostring(questType)==tostring(QUEST_TYPE_HOLIDAY_EVENT)) and "HOLIDAY" or tostring(questType)
		CHAT_SYSTEM:AddMessage(string.format("|c9B30FFquestName|r[%s]|c9B30FF, type[%s]|r", questName,myHoliday))
		CHAT_SYSTEM:AddMessage(string.format("|c9B30FFactiveStepTxt=|r|c666666\"%s\"|r", tostring(activeStepText))) --string.sub(activeStepText,1,150)))
		
		local QuestNumSteps = GetJournalQuestNumSteps(questIdx)
		CHAT_SYSTEM:AddMessage(string.format("|c9B30FFNUM-STEPS=|r[ %s ]", QuestNumSteps))
		
		for stepIdx=1,QuestNumSteps do
			CHAT_SYSTEM:AddMessage(string.format("|c9B30FF------------------ STEP %s ------------------|r", stepIdx))
			local stepText,_,stepType,trackerOverrideText,QuestNumConditions=GetJournalQuestStepInfo(questIdx,stepIdx)
			CHAT_SYSTEM:AddMessage(string.format("|c9B30FFNUM-Conditions=|r[%s]|c9B30FF, stepTxt=|r|c666666\"%s...\"|r",QuestNumConditions,string.sub(stepText,1,55)))
			CHAT_SYSTEM:AddMessage(string.format("|c9B30FFtrackerOverrideText=|r[ %s ]", trackerOverrideText))
			
			for condIdx=1,QuestNumConditions do
				local txt,cur,maxn,_,isComplete,_,isVisible,condType=GetJournalQuestConditionInfo(questIdx,stepIdx,condIdx)
				CHAT_SYSTEM:AddMessage(string.format("|c9B30FF     Condition: |r%s|c9B30FF - Cur=|r%s|c9B30FF,  Max=|r%s|c9B30FF,  Txt=|r|c666666\"%s...\"|r",condIdx,cur,maxn,string.sub(txt,1,55)))
			end
		end
		CHAT_SYSTEM:AddMessage("|c4da6ff*****************************ENDE*****************************|r")
	end
	--]]
	
	--[[
	SLASH_COMMANDS['/tshowtable']=function()
		CHAT_SYSTEM:AddMessage("|c4da6ff*********INTERNAL***QUESTTABLE*********************************|r")
		for i, t in ipairs(NLFeventQuests) do
			CHAT_SYSTEM:AddMessage(string.format("[|c6666FF%02d|r] = { qname=|c666666'%s'|r, achie=|c6666FF%04d|r, fastTravel=|c6666FF%03d|r, locations=|c6666FF%d|r },",
				i, tostring(NLFeventQuests[i].qname), NLFeventQuests[i].achie, NLFeventQuests[i].fastTravel, NLFeventQuests[i].locations))
		end
		CHAT_SYSTEM:AddMessage("|c4da6ff**********************************************************|r")
	end
	--]]

	--[[
	SLASH_COMMANDS['/tdate']=function()
		local startDate=os.time{year=tny.EVENT_START_YEAR,month=tny.EVENT_START_MONTH,day=tny.EVENT_START_DAY,hour=0,min=0,sec=0,false}
		local endsDate=os.time{year=tny.EVENT_END_YEAR,month=tny.EVENT_END_MONTH,day=tny.EVENT_END_DAY+1,hour=0,min=0,sec=0,false}
		local m_now=os.time()
		CHAT_SYSTEM:AddMessage(string.format("|c9B30FFStart-Date: |r%s|c9B30FF  [%s]|r",GetNiceDateTime(startDate),startDate))
		CHAT_SYSTEM:AddMessage(string.format("|c9B30FFEnd - Date: |r%s|c9B30FF  [%s]|r",GetNiceDateTime(endsDate),endsDate))
		CHAT_SYSTEM:AddMessage(string.format("|c9B30FFNow(): |r%s|c9B30FF  [%s] >>|r %s",GetNiceDateTime(m_now),m_now,tostring(m_now>startDate and m_now<endsDate)))
	end
	--]]

end
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(tny.name, EVENT_ADD_ON_LOADED, tny.addonLoaded)
