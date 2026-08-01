local LMP = LibMapPins
local GPTF = LibGamepadTooltipFilters
local AddonName="FishingMap"
local VisualName="Fishing Map"
local Localization={
	en={Lake="Lake",Foul="Foul",River="River",Salt="Salt",Oily="Oily",Mystic="Mystic",Running="Running",},
	ru={Lake="озерная вода",Foul="сточная вода",River="речная вода",Salt="морская вода",Oily="маслянистая вода",Mystic="мистическая вода",Running="речная вода",},
	de={Lake="Seewasser",Foul="Brackwasser",River="Flusswasser",Salt="Salzwasser",Oily="Ölwasser",Mystic="Mythenwasser",Running="Fließgewässer",},
	fr={Lake="Lac",Foul="Sale",River="Rivière",Salt="Mer",Oily="Huile",Mystic="Mystique",Running="courante",},
	br={Lake="Lake",Foul="Foul",River="River",Salt="Salt",Oily="Oily",Mystic="Mystic",Running="Running",},
	ua={
		--Lake="озерна вода",Foul="брудна вода",River="річкова вода",Salt="солона вода",Oily="масляниста вода",Mystic="містична вода",Running="проточна вода",
		Lake="Lake",Foul="Foul",River="River",Salt="Salt",Oily="Oily",Mystic="Mystic",Running="Running",},
	it={Lake="Lago",Foul="Acqua Sporca",River="Fiume",Salt="Mare",Oily="Oleosa",Mystic="Mistico",Running="Fluente",},
	es={Lake = "Lago", Foul = "Sucia", River = "Río", Salt = "Salada", Oily = "Aceitosa", Mystic = "Mística", Running = "Corriente",},
	zh={Lake="湖泊",Foul="脏水",River="河流",Salt="咸水",Oily="油污",Mystic="神秘",Running="Running",},
	}
local LocalizationFishingHole={	
	en={Salt="Saltwater Fishing Hole",Lake="Lake Fishing Hole",River="River Fishing Hole",Foul="Foul Fishing Hole",NewLife="New Life Fishing Hole",Oily="Oily Fishing Hole",Mystic="Mystic Fishing Hole",AbysFoul="Foul Abyssal Fishing Hole",},
	de={Salt="Fischgrund (Salzwasser)^m",Lake="Fischgrund (Seewasser)^m",River="Fischgrund (Flusswasser)^m",Foul="Fischgrund (Brackwasser)^m",NewLife="Neujahrsfest-Fischgrund^m",Oily="Fischgrund (Ölwasser)^m",Mystic="Fischgrund (Mythenwasser)^m",AbysFoul="abgründiger Fischgrund (Brackwasser)^m",},
	es={Salt="lugar de pesca de agua salada^m",Lake="lugar de pesca de lago^m",River="lugar de pesca de río^m",Foul="lugar de pesca de agua sucia^m",NewLife="lugar de pesca de la Nueva Vida^m",Oily="lugar de pesca aceitoso^m",Mystic="lugar de pesca místico^m",AbysFoul="lugar de pesca abisal de agua sucia^m",},
	fr={Salt="trou de pêche d'eau de mer^m",Lake="trou de pêche lacustre^m",River="trou de pêche de rivière^m",Foul="trou de pêche sale^m",NewLife="trou de pêche de la Nouvelle vie^m",Oily="trou de pêche huileux^m",Mystic="trou de pêche mystique^m",AbysFoul="trou de pêche sale abyssal",},
	jp={Salt="塩水の釣り穴",Lake="湖の釣り穴",River="川の釣り穴",Foul="汚水の釣り穴",NewLife="ニュー・ライフの釣り穴",Oily="油の釣り穴",Mystic="秘術の釣り穴",AbysFoul="深淵の汚水の釣り穴",},
	ru={Salt="Место для рыбалки на море",Lake="Место для рыбалки на озере",River="Место для рыбалки на реке",Foul="Место для рыбалки в сточной воде",NewLife="Место для рыбалки на Празднике Новой жизни",Oily="Место для рыбалки (маслянистая вода)",Mystic="Место для рыбалки (мистическая вода)",AbysFoul="Место для рыбалки в сточной воде (бездонное море)",},
	zh={Salt="咸水钓鱼点",Lake="湖泊钓鱼点",River="河流钓鱼点",Foul="脏水钓鱼点",NewLife="新生钓鱼点",Oily="油污钓鱼点",Mystic="神秘商人钓鱼点",AbysFoul="污秽深渊钓鱼点",},
}
local lang=GetCVar("language.2") if not Localization[lang] then lang="en" end
local function Loc(string)
	return Localization[lang][string] or Localization[lang]["en"] or string
end

local SavedVars, SavedGlobal
local DefaultVars = 
{	
	["AllFish"] = false,
    ["ForceShowFish"]={[1]=0,[2]=0,[3]=0,[4]=0,},
	["FishingMap_Nodes"]=true,
	["fishIconSelected"]={[1]=1,[2]=1,[3]=1,[4]=1,[5]=1,},
	["pinsize"] = 20,
	["useCharacterSettings"] = false,
	["newlife"] = false,
}
local DefaultGlobal = {
	["accountWideProfile"] = DefaultVars,
}

local function GetFMSettings()
	if SavedVars.useCharacterSettings then
		return SavedVars
	else
		return SavedGlobal.accountWideProfile
	end
end

--Data base
local PinManager
local cordsDump = ""
local UpdatingMapPin=false
local lastLoc = ""
local devMode=false

local FishIcon={
	[1]={--Foul
		"/esoui/art/icons/crafting_slaughterfish.dds",
		"/esoui/art/icons/crafting_fishing_caliginousbristleworm.dds",
		"/esoui/art/icons/crafting_fishing_illuminatedhalosaur.dds",
		},
	[2]={--River
		"/esoui/art/icons/crafting_fishing_river_betty.dds",	
		"/esoui/art/icons/crafting_fishing_salmon.dds",
		},
	[3]={--Lake
		"/esoui/art/icons/crafting_fishing_perch.dds",
		"/esoui/art/icons/crafting_fishing_shad.dds",
		},
	[4]={--Salt
		"/esoui/art/icons/crafting_fishing_merringar.dds",	
		"/esoui/art/icons/crafting_fishing_longfin.dds",		
		},
	[5]={--NewLife
		"/esoui/art/icons/achievement_newlifefestival_005.dds",	
		},
	}
local FishTypeToID = {
	Foul=1,
	River=2,
	Lake=3,
	Salt=4,
	Oily=1,--clockwork_base
	Mystic=4,--artaeum_base
	Running=2,--? no idea
	AbysFoul=1,
	NewLife=5,
}
local NumToFish={
    [1]="Foul",
	[2]="River",
	[3]="Lake",
	[4]="Salt",
}

local function FishNameToId(name)
	-- gets globalName
	local failed = true
	for globalName,locName in pairs(LocalizationFishingHole[lang]) do 
		if zo_strformat(SI_INTERACT_PROMPT_FORMAT_INTERACTABLE_NAME, locName) == name then
			name = globalName
			failed = false
			break
		end
	end	
	if failed then return "?" end
	return FishTypeToID[name]
end

local FishingZones={
	[2]=471,--Glenumbra
	[4]=472,--Stormhaven
	[5]=473,--Rivenspire
	[9]=477,--Stonefalls
	[10]=478,--Deshaan
	[11]=486,--Malabal Tor
	[14]=475,--Bangkorai
	[15]=480,--Eastmarch
	[16]=481,--Rift
	[17]=474,--Alik'r Desert
	[18]=485,--Greenshade
	[19]=479,--Shadowfen
	[38]=489,--Cyrodiil
	[154]=490,--Coldhabour
	[178]=483,--Auridon
	[179]=487,--Reaper's March
	[180]=484,--Grahtwood
	[501]=916,--Carglorn
	[109]=493,--Bleakrock
	[305]=491,--Stros M'Kai
	[306]=491,--Betnikh
	[307]=492,--Khenarthi's Roost
	--DLC
	[347]=1186,--Imperial City
	[380]=1340,--Wrothgar
	[443]=1351,--Hew's Bane
	[449]=1431,--Gold Coast
	[468]=1882,--Vvardenfell
	[590]=2027,--Clockwork City
	[617]=2191,--Summerset
	[633]=2240,--Arteum
	[408]=2295,--Murkmire
	[682]=2412,--Northern Elsweyr
	[721]=2566,--Southern Elsweyr
	[744]=2655,--Greymoor: Western Skyrim
	[745]=2655,--Greymoor: Blackreach: Greymoor Caverns
	[784]=2861,--Markarth: The Reach
	[785]=2861,--Markarth: Blackreach: Arkthzand Cavern
	[835]=2981,--Blackwood
	[858]=3144,--Deadlands
	[884]=3269,--High Isle
	[931]=3500,--Firesong
	[960]=3636,--Necrom
	[959]=3636,--Apocrypha
	[983]=3948,--Gold Road
	[1034]=4404,--West/East Solstice
	--[1034]=4460,--East Solstice
	u48_overland_base_west=4404,
	u48_overland_base_east=4460,
}
local ZoneIndexToParentIndex={ 
[2]=2,[3]=3,[4]=4,[5]=5,[6]=6,[7]=7,[8]=8,[9]=9,[10]=10,[11]=11,[12]=12,[13]=13,[14]=14,[15]=15,[16]=16,[17]=17,[18]=18,[19]=19,[20]=20,[21]=21,[22]=22,[23]=23,[24]=24,[25]=25,[26]=26,[27]=27,[28]=28,[29]=29,[30]=30,[31]=31,[32]=32,[33]=33,[34]=34,[35]=35,[37]=37,[38]=38,[41]=41,[42]=42,[43]=43,[46]=46,[47]=47,[48]=48,[49]=49,[51]=51,[52]=10,[53]=19,[54]=19,[56]=56,[57]=57,[58]=58,[59]=59,[60]=2,[61]=2,[62]=5,[63]=14,[65]=14,[67]=19,[68]=19,[69]=19,[70]=19,[71]=19,[72]=17,[73]=17,[74]=17,[75]=9,[76]=9,[77]=9,
[78]=9,[81]=10,[82]=10,[84]=10,[85]=10,[86]=10,[87]=10,[88]=2,[89]=16,[91]=16,[92]=15,[93]=15,[94]=15,[95]=15,[96]=15,[97]=15,[98]=15,[99]=99,[100]=11,[101]=11,[102]=19,[103]=19,[104]=19,[105]=19,[106]=19,[107]=19,[109]=109,[110]=110,[111]=9,[112]=2,[113]=9,[114]=9,[115]=9,[116]=9,[117]=9,[118]=9,[119]=10,[120]=17,[121]=2,[122]=2,[123]=2,[124]=2,[125]=2,[126]=2,[127]=4,[128]=4,[129]=4,[130]=4,[131]=4,[132]=4,[133]=5,[134]=5,[135]=5,[136]=5,[137]=5,[138]=5,[139]=17,[140]=17,[141]=17,[142]=17,[143]=17,[144]=17,
[145]=14,[146]=14,[147]=147,[148]=14,[149]=14,[150]=14,[151]=15,[152]=152,[154]=154,[155]=15,[157]=15,[158]=15,[159]=15,[160]=15,[161]=15,[162]=15,[163]=154,[165]=154,[167]=154,[168]=154,[169]=154,[170]=154,[171]=154,[175]=11,[176]=11,[177]=178,[178]=178,[179]=682,[180]=180,[181]=181,[182]=9,[184]=178,[185]=180,[186]=178,[187]=178,[188]=178,[189]=178,[190]=178,[191]=178,[192]=178,[193]=178,[194]=178,[195]=178,[196]=178,[197]=16,[198]=16,[199]=16,[200]=10,[201]=10,[202]=10,[203]=10,[204]=10,[205]=10,[206]=11,
[207]=16,[208]=16,[209]=16,[210]=16,[211]=178,[212]=154,[213]=154,[214]=154,[215]=154,[216]=154,[217]=154,[218]=218,[220]=2,[222]=4,[223]=16,[225]=180,[226]=180,[229]=180,[230]=180,[231]=180,[232]=180,[233]=180,[234]=180,[235]=15,[236]=179,[238]=179,[239]=179,[240]=179,[241]=179,[242]=179,[243]=179,[245]=179,[246]=179,[247]=179,[248]=179,[249]=179,[250]=179,[251]=179,[252]=179,[253]=11,[254]=11,[255]=11,[256]=11,[257]=11,[258]=11,[259]=180,[260]=180,[261]=180,[262]=16,[263]=16,[264]=16,[265]=16,[266]=16,
[267]=178,[268]=179,[269]=9,[270]=38,[271]=38,[272]=38,[273]=38,[274]=38,[276]=38,[277]=38,[278]=38,[279]=38,[280]=38,[281]=38,[282]=38,[283]=38,[284]=38,[285]=468,[286]=468,[287]=468,[288]=38,[289]=289,[290]=290,[291]=291,[292]=292,[293]=468,[294]=408,[295]=408,[297]=38,[298]=179,[299]=299,[302]=38,[303]=38,[304]=38,[305]=305,[306]=306,[307]=307,[308]=306,[310]=178,[315]=18,[316]=18,[317]=180,[319]=18,[320]=18,[321]=18,[322]=18,[323]=18,[324]=154,[326]=18,[327]=16,[328]=18,[329]=179,[330]=179,[332]=332,
[333]=17,[336]=336,[337]=337,[338]=338,[339]=18,[340]=18,[341]=18,[342]=18,[343]=18,[344]=18,[347]=38,[350]=5,[354]=5,[355]=5,[357]=14,[358]=358,[359]=359,[364]=5,[366]=501,[367]=501,[368]=10,[369]=501,[370]=501,[371]=4,[372]=2,[373]=373,[374]=38,[376]=443,[378]=38,[379]=379,[380]=380,[381]=381,[382]=380,[383]=380,[384]=380,[385]=380,[386]=380,[387]=380,[388]=380,[389]=380,[390]=380,[391]=380,[392]=380,[393]=380,[394]=380,[395]=380,[396]=380,[397]=380,[398]=380,[399]=380,[400]=380,[401]=380,[402]=380,[403]=380,
[404]=404,[406]=380,[407]=407,[408]=408,[409]=9,[410]=178,[411]=180,[412]=18,[413]=11,[414]=179,[415]=501,[416]=4,[417]=2,[418]=14,[419]=5,[420]=17,[421]=9,[422]=15,[423]=19,[424]=10,[425]=16,[426]=426,[427]=427,[428]=449,[429]=449,[430]=430,[431]=449,[432]=432,[433]=433,[434]=19,[436]=380,[437]=744,[438]=438,[439]=178,[440]=306,[443]=443,[444]=443,[448]=443,[449]=449,[450]=449,[451]=449,[452]=449,[453]=449,[454]=449,[455]=449,[456]=449,[457]=449,[458]=449,[459]=459,[460]=449,[461]=449,[462]=462,[463]=463,
[464]=19,[465]=443,[466]=443,[467]=19,[468]=468,[501]=501,[502]=501,[503]=501,[504]=501,[505]=501,[506]=501,[507]=501,[508]=501,[509]=501,[510]=501,[511]=501,[512]=501,[513]=513,[514]=514,[515]=501,[516]=501,[517]=501,[518]=501,[519]=501,[520]=520,[521]=501,[522]=501,[523]=501,[524]=501,[525]=501,[526]=501,[527]=501,[528]=501,[530]=468,[531]=468,[532]=468,[533]=468,[534]=468,[535]=468,[536]=468,[537]=468,[538]=468,[539]=468,[540]=468,[541]=468,[542]=10,[543]=180,[544]=5,[545]=4,[546]=9,[547]=178,[548]=2,
[558]=468,[559]=468,[560]=468,[561]=468,[562]=468,[563]=468,[564]=468,[565]=468,[567]=468,[568]=468,[569]=468,[570]=468,[571]=468,[572]=468,[573]=468,[574]=468,[575]=468,[576]=468,[577]=468,[578]=468,[580]=468,[581]=468,[582]=468,[583]=468,[584]=468,[585]=501,[586]=586,[587]=468,[588]=588,[590]=590,[591]=590,[592]=590,[593]=590,[595]=590,[596]=590,[598]=590,[600]=590,[601]=590,[602]=590,[605]=468,[609]=590,[615]=14,[616]=4,[617]=617,[618]=178,[619]=617,[620]=617,[621]=617,[622]=633,[623]=617,[624]=624,[625]=617,
[626]=617,[627]=617,[629]=617,[631]=617,[632]=617,[633]=633,[635]=617,[636]=617,[638]=617,[641]=641,[642]=617,[643]=617,[644]=617,[646]=633,[651]=617,[652]=617,[654]=617,[655]=179,[656]=18,[663]=408,[664]=408,[666]=408,[668]=408,[669]=669,[670]=408,[671]=9,[672]=178,[673]=2,[674]=408,[676]=408,[677]=15,[678]=449,[679]=408,[680]=408,[682]=682,[683]=682,[684]=682,[685]=682,[686]=682,[687]=682,[688]=682,[689]=682,[690]=682,[698]=682,[703]=682,[704]=682,[711]=682,[713]=713,[714]=682,[715]=180,[716]=15,[721]=721,
[722]=721,[723]=721,[725]=721,[726]=726,[727]=721,[734]=721,[736]=721,[740]=380,[741]=14,[742]=682,[744]=744,[745]=745,[746]=746,[747]=744,[749]=744,[750]=745,[751]=744,[758]=744,[759]=744,[760]=744,[767]=744,[768]=745,[775]=744,[777]=745,[780]=780,[784]=784,[785]=785,[786]=784,[787]=787,[797]=745,[798]=744,[804]=784,[805]=449,[806]=10,[812]=835,[813]=835,[820]=835,[822]=835,[827]=835,[828]=835,[829]=835,[830]=835,[831]=831,[832]=835,[833]=833,[834]=835,[835]=835,[836]=4,[837]=837,[841]=2,[842]=835,[847]=835,
[848]=835,[852]=18,[854]=854,[855]=855,[856]=855,[857]=858,[858]=858,[860]=860,[861]=858,[862]=862,[864]=855,[865]=858,[866]=858,[867]=835,[868]=858,[869]=858,[870]=870,[871]=617,[872]=872,[873]=855,[877]=468,[878]=468,[879]=884,[880]=880,[882]=884,[883]=884,[884]=884,[885]=884,[886]=884,[887]=884,[888]=884,[889]=884,[890]=983,[891]=884,[892]=884,[893]=884,[894]=884,[895]=884,[896]=884,[897]=884,[898]=884,[899]=884,[900]=884,[901]=884,[902]=884,[903]=884,[904]=855,[905]=905,[906]=884,[907]=306,[909]=884,
[910]=884,[912]=884,[915]=931,[916]=931,[917]=931,[918]=931,[919]=919,[921]=931,[922]=931,[923]=931,[924]=931,[925]=931,[926]=884,[927]=931,[929]=931,[930]=884,[931]=931,[932]=931,[934]=931,[935]=9,[936]=16,[937]=937,[938]=179,[939]=959,[940]=959,[941]=959,[942]=960,[943]=960,[944]=959,[945]=959,[946]=959,[947]=959,[948]=960,[949]=960,[950]=960,[951]=960,[952]=960,[953]=960,[954]=960,[955]=959,[956]=959,[957]=959,[958]=960,[959]=959,[960]=960,[961]=960,[962]=959,[963]=959,[964]=959,[965]=959,[966]=960,[967]=960,
[968]=959,[969]=960,[970]=960,[971]=178,[974]=960,[975]=975,[976]=959,[977]=590,[979]=979,[980]=983,[981]=959,[982]=983,[983]=983,[984]=983,[985]=983,[986]=983,[987]=983,[988]=983,[989]=983,[993]=983,[994]=983,[995]=983,[996]=983,[997]=617,[998]=959,[999]=983,[1000]=983,[1002]=983,[1003]=99,[1004]=983,[1005]=983,[1006]=983,[1007]=983,[1009]=1009,[1010]=380,[1013]=959,[1014]=1014,[1015]=983,[1017]=408,[1018]=983,[1019]=884,[1020]=17,[1021]=884,[1023]=744,[1028]=983,[1029]=443,[1030]=617,[1031]=682,[1032]=1032,
[1034]=1034,[1035]=38,[1036]=5,[1037]=5,[1039]=1039,[1040]=1034,[1041]=1041,[1042]=1034,[1043]=1034,[1044]=1034,[1045]=1034,[1047]=1034,[1049]=1034,[1050]=1034,[1051]=1034,[1052]=1034,[1054]=1034,[1055]=1034,[1056]=1034,[1057]=1034,[1058]=1058,[1059]=1034,[1060]=1034,[1061]=1034,[1064]=1034,[1067]=1034,[1068]=1034,[1069]=1034,[1070]=1034,[1074]=501,
}
local FishingAchievements={[471]=true,[472]=true,[473]=true,[474]=true,[475]=true,[477]=true,[478]=true,[479]=true,[480]=true,[481]=true,[483]=true,[484]=true,[485]=true,[486]=true,[487]=true,[489]=true,[490]=true,[491]=true,[492]=true,[493]=true,[916]=true,[1186]=true,[1339]=true,[1340]=true,[1351]=true,[1431]=true,[1882]=true,[2191]=true,[2240]=true,[2295]=true,[2412]=true,[2566]=true,[2655]=true,[2861]=true,[2981]=true,[3144]=true,[3269]=true,[3500]=true,[3636]=true,[3948]=true,[4404]=true,[4460]=true}
local FishingBugFix={[473]={[3]="River"},[2027]={[8]="Oily"},[472]={[1]="Foul"}}--unsure if needed
local FishingPinData={name="FishingMap_Nodes",done=false,pin={},maxDistance=0.05,level=101,texture="/esoui/art/icons/achievements_indexicon_fishing_up.dds",k=1.25,}
local function GetFishingAchievement(subzone)
	if GetFMSettings().AllFish then return {[1]=true,[2]=true,[3]=true,[4]=true,[5]=true} end
	local id=FishingZones[subzone] or FishingZones[GetCurrentMapZoneIndex()] or FishingZones[ZoneIndexToParentIndex[GetCurrentMapZoneIndex()]]
	if id then
		local total={
			Foul=GetFMSettings().ForceShowFish[1],
			River=GetFMSettings().ForceShowFish[2],
			Lake=GetFMSettings().ForceShowFish[3],
			Salt=GetFMSettings().ForceShowFish[4],
			Oily=0,Mystic=0,Running=0}
		for i=1,GetAchievementNumCriteria(id) do
			local AchName,a,b=GetAchievementCriterion(id,i)
			if FishingBugFix[id] and FishingBugFix[id][i] then
				total[ FishingBugFix[id][i] ]=total[ FishingBugFix[id][i] ]+b-a
			else
				for water in pairs(total) do
					if string.match(AchName,"("..Loc(water)..")")~=nil then
						total[water]=total[water]+b-a
					end
				end
			end
		end
		total.Salt=total.Salt+total.Mystic total.Foul=total.Foul+total.Oily total.River=total.River+total.Running		
		return {[1]=total.Foul>0,[2]=total.River>0,[3]=total.Lake>0,[4]=total.Salt>0,[5]=GetFMSettings().newlife}
	end
	return false
end

local currentLoadingCoroutine = nil
local currentLoadingMap = ""

-- Helper to stop any existing loading process
local function AbortPinLoading()
    EVENT_MANAGER:UnregisterForUpdate(AddonName .. "_PinLoader")
    currentLoadingCoroutine = nil
end
-- Cheap to Run Create Pin that does only what I need
local function customCreatePin(pinType, pinTag, xLoc, yLoc)
    local pin, pinKey = PinManager:AcquireObject()
    pin:SetData(pinType, pinTag)
    pin:SetOriginalPosition(xLoc, yLoc)
    pin:SetLocation(xLoc, yLoc)
        
    local customPinData = PinManager.customPins[pinType]
    if customPinData then
        PinManager:MapPinLookupToPinKey(customPinData.pinTypeString, pinType, pinTag, pinKey)
    end
end
--Callbacks
local function MapPinAddCallback()
    if GetMapType() > MAPTYPE_ZONE or not PinManager:IsCustomPinEnabled(FishingPinData.id) then return end
    local subzone = GetMapTileTexture():match("[^\\/]+$"):lower():gsub("%.dds$", ""):gsub("_[0-9]+$", "")
    -- check if were adding pins, if same map exit, othewise stop loading old pins so we can add new
    if currentLoadingCoroutine ~= nil then
        if currentLoadingMap == subzone then return end
        AbortPinLoading()
    end
    currentLoadingMap = subzone

	local workQueue = {}
    local subzonesToProcess = {}

	--Add the map we want target 
    if subzone == "u48_overland_base" then
        table.insert(subzonesToProcess, "u48_overland_base_east")
        table.insert(subzonesToProcess, "u48_overland_base_west")
    else
        table.insert(subzonesToProcess, subzone)
    end

	-- Process's Subzones
	-- Get data from FishingMap_Nodes and checks if we need to show the data
	-- Add data(pins) to workQueue so we have 1 big table to process
    for _, name in ipairs(subzonesToProcess) do
        local mapData = FishingMapNodes[name]
        local achStatus = GetFishingAchievement(name)
        if mapData and achStatus then
			for i = 1, #mapData do
				local pinData = mapData[i]
				if achStatus[pinData[3]] then
					workQueue[#workQueue+1] = pinData
				end
			end
        end
    end
	local pinIndex = 1
	local frameBudget = 0.005

    currentLoadingCoroutine = function()
        local startTime = GetGameTimeSeconds()
        while pinIndex <= #workQueue do
			local pinData = workQueue[pinIndex]
			FishingPinData.texture = FishIcon[pinData[3]][GetFMSettings().fishIconSelected[pinData[3]]]
			customCreatePin(FishingPinData.id, {[1]=pinData[3]}, pinData[1], pinData[2])
			pinIndex = pinIndex + 1
			if pinIndex % 10 == 0 then
				if (GetGameTimeSeconds() - startTime) > frameBudget then
					return
				end
			end
		end
        AbortPinLoading()
    end

    -- Start Coroutine
    EVENT_MANAGER:RegisterForUpdate(AddonName .. "_PinLoader", 0, function()
        if currentLoadingCoroutine then
            currentLoadingCoroutine()
        else
            AbortPinLoading()
        end
    end)
end

local function GetToolTipText()
return zo_iconFormat(FishIcon[1][GetFMSettings().fishIconSelected[1]],35,35).." "..Loc("Foul").."\n"
	 ..zo_iconFormat(FishIcon[2][GetFMSettings().fishIconSelected[2]],35,35).." "..Loc("River").."\n"
	 ..zo_iconFormat(FishIcon[3][GetFMSettings().fishIconSelected[3]],35,35).." "..Loc("Lake").."\n"
	 ..zo_iconFormat(FishIcon[4][GetFMSettings().fishIconSelected[4]],35,35).." "..Loc("Salt").."\n"
	 ..zo_iconFormat(FishIcon[5][GetFMSettings().fishIconSelected[5]],35,35).." "..Loc("NewLife")
end
local function updatePinSize(n)
	GetFMSettings().pinsize=n
	if ZO_MapPin.PIN_DATA[FishingPinData.id] and FishingPinData.k then ZO_MapPin.PIN_DATA[FishingPinData.id].size=n*FishingPinData.k end
	PinManager:RefreshCustomPins(FishingPinData.id)
end

local PinTooltipCreator={
	tooltip=1,
	creator=function(pin)
		local _, pinTag=pin:GetPinTypeAndTag()
		local name,icon
		icon=FishIcon[pinTag[1]][GetFMSettings().fishIconSelected[pinTag[1]]]
		name="X: "..pin.normalizedX.." Y: "..pin.normalizedY.." ID: "..pinTag[1]
		if IsInGamepadPreferredMode() or IsConsoleUI() then
			ZO_MapLocationTooltip_Gamepad:LayoutIconStringLine(ZO_MapLocationTooltip_Gamepad.tooltip, icon, zo_strformat("<<1>>", name), ZO_MapLocationTooltip_Gamepad.tooltip:GetStyle("mapLocationTooltipWayshrineHeader"))
		else
			InformationTooltip:AddLine(zo_strformat("<<1>> <<2>>",zo_iconFormat(icon,24,24), name), "ZoFontGameOutline", ZO_SELECTED_TEXT:UnpackRGB())
		end
	end
}

local function SettingsMenu()
	local LHAS = LibHarvensAddonSettings
	if LHAS == nil then return end
   local options = {
        allowDefaults = false, 
        allowRefresh = true, 
       -- defaultsFunction = function() 
        --    CHAT_ROUTER:AddSystemMessage("Fishing Map settign have been reset to Default")
       -- end,
    }
    local settings = LHAS:AddAddon(VisualName,options)
    if not settings then return end
	
	settings:AddSetting({
        type = LHAS.ST_LABEL,
        label = "Go To \n Map -> Options -> Filters \n To Turn On & Off",
    })

	--Slider to Adjust Pin Size
    settings:AddSetting({
        type = LHAS.ST_SLIDER,
        label = "Pin Size \n Small <- -> Large",
		tooltip = "Default: "..DefaultVars.pinsize,
		default = DefaultVars.pinsize, 
        setFunction = function(value)
           updatePinSize(value)
        end,
        getFunction = function()
            return GetFMSettings().pinsize
        end,
        min = 16,
        max = 40,
        step = 1
    })	
	local section = {
        type = LHAS.ST_SECTION,
        label = "Icon Change",
    }
    settings:AddSetting(section)
	for i = 1, 4 do	
		settings:AddSetting({
			type = LHAS.ST_ICONPICKER,
			label = Loc(NumToFish[i]),
			items = FishIcon[i],		
			getFunction = function()
				return GetFMSettings().fishIconSelected[i]
			end,
			setFunction = function(combobox, index, item)
				GetFMSettings().fishIconSelected[i]=index
				PinManager:RefreshCustomPins(FishingPinData.id)
			end,
			default = DefaultVars.fishIconSelected[i],
		})
	end
	settings:AddSetting({
        type = LHAS.ST_SECTION,
        label = "Force Show Fish",
    })
	settings:AddSetting({
        type = LHAS.ST_CHECKBOX,
        label = "Show All Fish", 
		tooltip = "When Off will only show fish you need to collect.",
		default = DefaultVars.AllFish, 
        setFunction = function(value)
           GetFMSettings().AllFish = value
		   PinManager:RefreshCustomPins(FishingPinData.id)
        end,
        getFunction = function()
            return GetFMSettings().AllFish
        end,
    })
	
	for i = 1, 4 do
		local function boolToNumber(bool)
			 if bool then return 1 else return 0 end
		end
		settings:AddSetting({
			type = LHAS.ST_CHECKBOX,
			label = "Force Show "..Loc(NumToFish[i]), 
			tooltip = "Turn on when you want to see the fish on the map even if you have it done",
			default = false, 
			setFunction = function(value)	
			   GetFMSettings().ForceShowFish[i] = boolToNumber(value)
			   PinManager:RefreshCustomPins(FishingPinData.id)
			end,
			getFunction = function()
				return GetFMSettings().ForceShowFish[i]==1
			end,
			disable = function() return GetFMSettings().AllFish end,
		})
	end
	settings:AddSetting({
			type = LHAS.ST_CHECKBOX,
			label = "Show "..LocalizationFishingHole[lang].NewLife, 
			default = DefaultVars.newlife, 
			setFunction = function(value)	
			   GetFMSettings().newlife = value
			   PinManager:RefreshCustomPins(FishingPinData.id)
			end,
			getFunction = function()
				return GetFMSettings().newlife
			end,
	})
	settings:AddSetting({
        type = LHAS.ST_SECTION,
        label = "Logging / Report",
    })
	
	settings:AddSetting({
        type = LHAS.ST_LABEL,
        label = "Found a Missing Fishing Hole? \nStand in the Middle of it \n and type '/fmloc 1' in chat to Log it.",
    })

	settings:AddSetting({
            type = LHAS.ST_BUTTON,
            label = "Submit Logged",
            tooltip = "Open link then click submit \n Type '/fmclear' in chat to clear logged holes",
            buttonText = "Open URL",
            clickHandler = function(control, button)
                RequestOpenUnsafeURL("https://docs.google.com/forms/d/e/1FAIpQLSczE1-xzjbFgRrXSMdMBxZuQgM2eGnBUpiOFvqB8Hve-MfEfA/viewform?usp=pp_url&entry.550722213=" ..cordsDump.."},")
            end,
        })
	
	settings:AddSetting({
        type = LHAS.ST_BUTTON,
        label = "Submit Feedback / Request",
		tooltip = "link to a form where you can leave feedback or even leave a request",
		buttonText = "Open URL",
		clickHandler = function(control, button)
			RequestOpenUnsafeURL("https://docs.google.com/forms/d/e/1FAIpQLScYWtcIJmjn0ZUrjsvpB5rwA5AlsLvasHUIcKqzIYcogo9vjQ/viewform?usp=pp_url&entry.550722213="..VisualName)
		end,
	})
	
end

local function SetUpSlashCommands()
	SLASH_COMMANDS["/fmpinsize"]=function(n)	
		n=tonumber(n)		
		if n and n>=16 and n<=40 then
			updatePinSize(n)
		else
			CHAT_ROUTER:AddSystemMessage("/fmpinsize {Number} \n Number = 16 to 40")
		end
	end
	
	SLASH_COMMANDS["/fmclear"]=function()
		cordsDump = ""
		lastLoc = ""
		CHAT_ROUTER:AddSystemMessage("logged fishingSpots cleared")
	end
	--saves the cord it given by "/fmloc #" and "/fmwploc #"
	local function logCords(n,subzone,cords)
		if n == "?" then 
			CHAT_ROUTER:AddSystemMessage("No Fishing hole detected")
			return
		end
		if lastLoc ~= subzone then
			if lastLoc ~= "" then cordsDump = cordsDump .. "},"end
			cordsDump = cordsDump.. subzone .. "={"
			lastLoc = subzone				
		end
		cordsDump = cordsDump .. "{"..cords..","..n.."},"		
		CHAT_ROUTER:AddSystemMessage("Logged")
	end
	local function SolsticeCheck(x,y)
		local pointA = {["x"]=.466,["y"]=.270}
		local pointB = {["x"]=.666,["y"]=.793}
		local dire = (x-pointA.x)*(pointB.y-pointA.y)-(y-pointA.y)*(pointB.x-pointA.x)
		if dire<0 then return "u48_overland_base_west" else return "u48_overland_base_east" end
	end
	local function getFishingHoleInfo(x,y)
		local subzone = GetMapTileTexture():match("[^\\/]+$"):lower():gsub("%.dds$", ""):gsub("_[0-9]+$", "")		
		local xStr = string.gsub(math.floor(x*1000)/1000, "^0%.", ".")
		local yStr = string.gsub(math.floor(y*1000)/1000, "^0%.", ".")
		local cords = xStr..","..yStr
		if subzone == "u48_overland_base" then subzone = SolsticeCheck(xStr,yStr) end
	return subzone, cords
	end
	SLASH_COMMANDS["/fmloc"]=function(n)
		local action, interactableName = GetGameCameraInteractableActionInfo()
		interactableName = FishNameToId(interactableName)
		local x,y=GetMapPlayerPosition("player")
	    local subzone, cords = getFishingHoleInfo(x,y)
		CHAT_ROUTER:AddSystemMessage(subzone .. "={{"..cords..","..interactableName.."}},")
		n=tonumber(n)	
		if n then
			logCords(interactableName,subzone,cords)
		end
	end
		
	SLASH_COMMANDS["/fmwploc"]=function(n)
		local x, y = GetMapPlayerWaypoint()
		local subzone, cords = getFishingHoleInfo(x,y)
		if not n then n="" end
		CHAT_ROUTER:AddSystemMessage(subzone .. "={{" .. cords .. ","..n.."},}")
		n=tonumber(n)	
		if n and n>=1 and n<=4 then
			logCords(n,subzone,cords)
		end
	end
	SLASH_COMMANDS["/fmnewlife"]=function(n)
		GetFMSettings().newlife = not GetFMSettings().newlife
		 PinManager:RefreshCustomPins(FishingPinData.id)
		
	end
	SLASH_COMMANDS["/fmsubmit"]=function()
		RequestOpenUnsafeURL("https://docs.google.com/forms/d/e/1FAIpQLSczE1-xzjbFgRrXSMdMBxZuQgM2eGnBUpiOFvqB8Hve-MfEfA/viewform?usp=pp_url&entry.550722213=" ..cordsDump.."},")
	end
	SLASH_COMMANDS["/fmreport"]=function()
		RequestOpenUnsafeURL("https://docs.google.com/forms/d/e/1FAIpQLScYWtcIJmjn0ZUrjsvpB5rwA5AlsLvasHUIcKqzIYcogo9vjQ/viewform?usp=pp_url&entry.550722213="..VisualName)
	end
	SLASH_COMMANDS["/fmdev"]=function(n)
		if devMode==false then
			ZO_MapPin.TOOLTIP_CREATORS[FishingPinData.id]=PinTooltipCreator
			devMode = true
		end
	end
end

local function OnAchievementUpdate(achievementId,link)
	local function RefreshPins(name)
		EVENT_MANAGER:RegisterForUpdate("CallLater_"..name, 1000,
		function()
			EVENT_MANAGER:UnregisterForUpdate("CallLater_"..name)
			PinManager:RefreshCustomPins(name)
		end)
	end
	if FishingAchievements[achievementId] and GetFMSettings().FishingMap_Nodes then
		RefreshPins(FishingPinData.id)
	end
end
local function RegisterEvents()
	EVENT_MANAGER:RegisterForEvent(AddonName,EVENT_ACHIEVEMENT_UPDATED,function(_,achievementId,link) OnAchievementUpdate(achievementId)end)
	EVENT_MANAGER:RegisterForEvent(AddonName,EVENT_ACHIEVEMENT_AWARDED,function(_,_,_,achievementId,link) OnAchievementUpdate(achievementId)end)
end

local function OnLoad(eventCode,addonName)
	if addonName ~= AddonName then return end
	EVENT_MANAGER:UnregisterForEvent(AddonName,EVENT_ADD_ON_LOADED)
	local serverName = GetWorldName()
	SavedGlobal = ZO_SavedVars:NewAccountWide("FishingMapSavedVariables", 1, serverName, DefaultGlobal)
	SavedVars = ZO_SavedVars:NewCharacterIdSettings("FishingMapSavedVariables",1, serverName, SavedGlobal.accountWideProfile) 	
	PinManager=ZO_WorldMap_GetPinManager()
	SettingsMenu()
	RegisterEvents()
	
	FishingPinData.size = FishingPinData.size or GetFMSettings().pinsize*FishingPinData.k
	FishingPinData.id = LMP:AddPinType(FishingPinData.name,function() MapPinAddCallback() end,nil,FishingPinData)
	--pin filter--
	local icon = zo_iconFormat(FishingPinData.def_texture or FishingPinData.texture or "", 24, 24)
    local label = icon .. " Fishing Holes"
	LMP:AddPinFilter(FishingPinData.id, label, false, GetFMSettings())	
	
	if GPTF then GPTF:AddTooltip(FishingPinData.id,GetToolTipText()) end	
	SetUpSlashCommands()
	
end
EVENT_MANAGER:RegisterForEvent(AddonName,EVENT_ADD_ON_LOADED,OnLoad)
