BOPOHCEBEPA = {
	name = "BOPOHCEBEPA",
	BOPOHCEBEPAGuildsList = {
		[741328] = true,	--TABEPHA BOPOH CEBEPA
		[750212] = true,	--TABEPHA BOPOHA CEBEPA
	},
}

local function MakeButton(control,num)
	local w,space=Label.buttonSize, Label.space
	local name="ZO_GuildHome_BCGH_Button"..num
	local button=_G[name] or WINDOW_MANAGER:CreateControl(name, control, CT_TEXTURE)
	button:SetDimensions(w,w)
	button:ClearAnchors()
	button:SetAnchor(TOPLEFT,control,TOPLEFT,shift+(w+space)*(num-1),18)
	button:SetHidden(false)
	button:SetTexture(data.icon)
	button:SetColor(.6,.57,.46,1)
	button:SetMouseEnabled(true)
	button:SetDrawTier(DT_MEDIUM)
	button:SetDrawLayer(DL_CONTROLS)
	button:SetHandler("OnMouseEnter", function(self)
		self:SetColor(.9,.9,.8,1)
		if data.tooltip then
			local tooltip=data.tooltip
			ZO_Tooltips_ShowTextTooltip(self, BOTTOMRIGHT, (type(tooltip)=="string" and tooltip or tooltip()))
		end
	end)
	button:SetHandler("OnMouseExit", function(self)
		self:SetColor(.6,.57,.46,1)
		if data.tooltip then ZO_Tooltips_HideTextTooltip() end
	end)
end

		--Текстуры / Textures 
	lmb = '|t25:25:ESOUI/art/miscellaneous/icon_lmb.dds|t'
	rmb = '|t25:25:ESOUI/art/miscellaneous/icon_rmb.dds|t'
	dvd = '|t200:2:esoui/art/ava/ava_seigecontrols_divider.dds|t'
	Mug= '|t25:25:esoui/art/icons/crafting_beer_002.dds|t'
	menuGH= '|t25:25:/esoui/art/tutorial/guildhistory_indexicon_alliancewar_up.dds|t'
	menuH = '|t25:25:/esoui/art/tutorial/guild-tabicon_home_up.dds|t'
	GDscl = '|t25:25:esoui/art/chatwindow/chat_friendsonline_up.dds|t'
	GDtrd = '|t25:25:/esoui/art/inventory/inventory_all_tabicon_mouseover.dds|t'
	Even = '|t25:25:/esoui/art/treeicons/achievements_indexicon_events_up.dds|t'
	Discord = '|t25:25:/esoui/art/tutorial/tabicon_friends_up.dds|t'
	RUI = '|t25:25:esoui/art/ava/ava_keepstatus_icon_collectionrate.dds|t'
	CI= '|t25:25:/esoui/art/tooltips/icon_bank.dds|t'
	SF = '|t25:25:/esoui/art/icons/heraldrycrests_misc_snowflake_01.dds|t'
	GH= '|t25:25:/esoui/art/icons/housing_targetdummy_frostatronach_01.dds|t'
	T= '|t25:25:/esoui/art/icons/crafting_beer_001.dds|t'
	B= '|t25:25:/esoui/art/icons/housing_veg_flr_romanticflower001.dds|t'
	P= '|t25:25:/esoui/art/icons/ava_siege_ui_008.dds|t'
	

-- |cBFBC99

function BOPOHCEBEPA:InitializeChatButton()
		--Тултип / Tooltip
local function ShowTooltip(control)
		InitializeTooltip(InformationTooltip, control, TOPLEFT, 5, -10, BOTTOMRIGHT)
		InformationTooltip:AddLine("|ce1d6aa BOPOH |r" ..Mug.. "|ce1d6aa CEBEPA|r")
		InformationTooltip:AddLine()
		InformationTooltip:AddVerticalPadding(-15)
		InformationTooltip:AddLine(""..dvd.."")
		InformationTooltip:AddVerticalPadding(-10)
		InformationTooltip:AddLine(""..lmb.."|ce1d6aa Меню|r"..rmb.."|ce1d6aa Полезная информация|r")
    end  
local function HideTooltip(control)
		ClearTooltip(InformationTooltip)
    end
local function HideTooltip(control)
		ClearTooltip(InformationTooltip)
    end
	
		--Меню
local function BCC_Menu(control, button)
	if button == 2 then

		local SubMenuD = {
				{label = "-", },
				{label = ""..Discord.."|ce1d6aa Дискорд|r", callback = function() RequestOpenUnsafeURL("https://discord.gg/otets-traktira") end,},
				{label = "-", },
			}
			local SubMenuTC = {
				{label = "-", },
				{label = ""..GDtrd.."|ce1d6aa Tamriel Trade Center Сайт|r", callback = function() RequestOpenUnsafeURL("https://eu.tamrieltradecentre.com/pc/Trade") end,},
				{label = "-", },
			}

			local SubMenuEvents = {
				{label = "-", },
				{label = ""..Even.."|ce1d6aa События|r", callback = function() WeeklyEvents() end,},
				{label = "-", },
			}

			local Panel= {
				{label = "-", },
				{label = ""..CI.."|ce1d6aa Информация о валютах|r", callback = function() CharactersInformation() end,},
				{label = "-", },
			}

			ClearMenu()
			AddCustomSubMenuItem(""..Discord.."|ce1d6aa Дискорд|r", SubMenuD)
			AddCustomSubMenuItem(""..GDtrd.."|ce1d6aa Tamriel Trade Center|r", SubMenuTC)
			AddCustomSubMenuItem(""..Even.."|ce1d6aa События|r", SubMenuEvents)
			AddCustomSubMenuItem(""..CI.."|ce1d6aa Информация о валютах|r", Panel)
			ShowMenu()
		elseif button == 1 then
		local entries = {
				{label = ""..GH.."|ce1d6aa Гильдхолл|r", callback = function() BOPOHCEBEPA:PortToHouse("@falc_on81", 80, "Гильдхолл" ) end, },
				{label = "-", },
				{label = ""..B.."|ce1d6aa Бордель|r", callback = function() BOPOHCEBEPA:PortToHouse("@u0412087",91, "Бордель" ) end, },
				{label = "-", },
				{label = ""..T.."|ce1d6aa Таверна|r", callback = function() BOPOHCEBEPA:PortToHouse("@BOPOH.CEBEPA", 30,  "Таверна") end, },
            	{label = "-", },
				{label = ""..P.."|ce1d6aa Лагерь Пакта|r", callback = function() BOPOHCEBEPA:PortToHouse("@alekseyka", 61, "Лагерь Пакта") end, },
		}
			ClearMenu()
			AddCustomMenuItem(""..menuH.."|ce1d6aa Возвращаюсь домой|r", function() d(SF.."|c81ddff Ворон: \n |c70c54d -Ох какой замечательный дом! А давай посмотрим, не проходит ли в таверне конкурс? Для этого посети Discord. Карр-р!\n |r") RequestJumpToHouse(GetHousingPrimaryHouse()) end)
			AddCustomMenuItem("-", function() end)
			AddCustomSubMenuItem(""..menuGH.."|ce1d6aa Список Гильдхоллов|r", entries)
			AddCustomMenuItem("-", function() end)
			AddCustomMenuItem(""..RUI.."|ce1d6aa ReloadUI|r", function() ReloadUI() end)
			ShowMenu()
		end
end


function WeeklyEvents()
	d(SF.. "|c81ddff Ворон: \n |c81ddff -События Таверны на этой недели, больше информации в нашем Discord. Карр-р!\n \n|r".. GetGuildMotD("741328"))
end

--Информация о валютах/ Amount of currencies 
BM = '|t20:20:/esoui/art/icons/housing_bre_inc_coins002.dds|t'
CM = '|t20:20:/esoui/art/currency/currency_gold_64.dds|t'
AP= '|t20:20:/esoui/art/currency/alliancepoints_64.dds|t'
TS= '|t20:20:/esoui/art/currency/currency_telvar_64.dds|t'
ET= '|t20:20:/esoui/art/currency/icon_eventticket_loot.dds|t'
UK= '|t20:20:/esoui/art/icons/undaunted_gold_key_01.dds|t'
WV= '|t20:20:/esoui/art/currency/currency_writvoucher.dds|t'

function CharactersInformation()
	d(SF.. "|c81ddff Ворон: \n |c81ddff -Давай-ка посмотрим твои сбережения. Карр-р!|r")
	d( "|ce1d6aa У вас с собой  |r"..CM.. " ".. valueColor(format_number(GetCurrentMoney()), "cFFD700" ).. "|ce1d6aa   золотых монет|r")
	d("|ce1d6aa У вас в банке  |r"..BM.. " "..  valueColor(format_number(GetBankedCurrencyAmount(CURT_MONEY)),"cFFD700" ).. "|ce1d6aa  золотых монет|r")
	d("|ce1d6aa У вас с собой  |r" ..AP.. " "..  valueColor(format_number(GetCarriedCurrencyAmount(CURT_ALLIANCE_POINTS)),"c04f619").."|ce1d6aa  очков альянса|r")
	d("|ce1d6aa У вас в банке  |r"..AP.. " "..  valueColor(format_number(GetBankedCurrencyAmount(CURT_ALLIANCE_POINTS)), "c04f619")..  "|ce1d6aa  очков альянса|r")
	d( "|ce1d6aa  У вас с собой  |r"..TS.. " "..  valueColor(format_number(GetCarriedCurrencyAmount(CURT_TELVAR_STONES)), "c1E90FF").. "|ce1d6aa   камней Тель-Вара|r")
	d("|ce1d6aa У вас в банке  |r"..TS.. " "..  valueColor(format_number(GetBankedTelvarStones()),"c1E90FF" ).. "|ce1d6aa  камней Тель-Вара|r")
	d(eventTicketsColor())
	d("|ce1d6aa У вас с собой  |r"..UK.. " "..valueColor(GetCurrencyAmount(CURT_UNDAUNTED_KEYS, CURRENCY_LOCATION_ACCOUNT),"cB8860B").. "|ce1d6aa  клучей Неустрашимых |r")
	d( "|ce1d6aa У вас с собой  |r"..WV.. " ".. valueColor(GetCarriedCurrencyAmount(CURT_WRIT_VOUCHERS),"cFFA500").. "|ce1d6aa  ремесленных расписок|r")
	d( "|ce1d6aa У вас в банке  |r"..WV.. " ".. valueColor(GetBankedCurrencyAmount(CURT_WRIT_VOUCHERS),"cFFA500").. "|ce1d6aa  ремесленных расписок|r")
end

function eventTicketsColor()
	if (GetCurrencyAmount(CURT_EVENT_TICKETS, CURRENCY_LOCATION_ACCOUNT) == 12) then
		return  "|ce1d6aa У вас на аккаунте |r"..ET.. " "..  valueColor(GetCurrencyAmount(CURT_EVENT_TICKETS, CURRENCY_LOCATION_ACCOUNT),"cB22222").."|cB22222/12|r".."|ce1d6aa  вы больше не сможете получать билеты событий пока не истратите имеющиеся|r"
	else 
		return   "|ce1d6aa  У вас на аккаунте  |r"..ET.. " "..  valueColor(GetCurrencyAmount(CURT_EVENT_TICKETS, CURRENCY_LOCATION_ACCOUNT),"cFFC0CB").. "|cFFC0CB /12|r".."|ce1d6aa  билетов событий|r"
	end
end


function format_number(amount)
	local newNum = amount
	while true do  
	  newNum, k = string.gsub(newNum, "^(-?%d+)(%d%d%d)", '%1,%2')
	  if (k==0) then
		break
	  end
	end
	return newNum
  end

  function valueColor(amount, color)
	return "|".. color.. amount.. "|r"
  end



		--Кнопка развернутого чата / Button for open chat window
	BCbtn =  WINDOW_MANAGER:CreateControl("MaxBCGH", ZO_ChatWindow, CT_BUTTON)
    BCbtn:SetDimensions(23, 23)
    BCbtn:SetAnchor(TOPLEFT, ZO_ChatOptionsSectionLabel, TOPLEFT, 200, 13)
   	BCbtn:SetHandler("OnMouseEnter", function(control) ShowTooltip(control) end)
    BCbtn:SetHandler("OnMouseExit", function(control) HideTooltip(control) end)
	BCbtn:SetNormalTexture("BOPOHCEBEPA/imgs/B.dds")
    BCbtn:SetPressedTexture("BOPOHCEBEPA/imgs/B.dds")
    BCbtn:SetMouseOverTexture("BOPOHCEBEPA/imgs/B.dds")
	BCbtn:SetHandler("OnMouseUp", function(control, button) BCC_Menu(control, button) end)
		
		--Кнопка свернутого чата / Button for closed chat window
	BCbtnMin =  WINDOW_MANAGER:CreateControl("MinBCGH", ZO_ChatWindowMinBar, CT_BUTTON)
    BCbtnMin:SetDimensions(23, 23)
    BCbtnMin:SetAnchor(TOPLEFT, ZO_ChatWindowMinBar, nil, 0, 423)
    BCbtnMin:SetHandler("OnMouseEnter", function(control) ShowTooltip(control) end)
	BCbtnMin:SetHandler("OnMouseExit", function(control) HideTooltip(control) end)
    BCbtnMin:SetNormalTexture("BOPOHCEBEPA/imgs/B.dds")
    BCbtnMin:SetPressedTexture("BOPOHCEBEPA/imgs/B.dds")
    BCbtnMin:SetMouseOverTexture("BOPOHCEBEPA/imgs/B.dds")
	BCbtnMin:SetHandler("OnMouseUp", function(control, button) BCC_Menu(control, button) end)
end

		--Фикс для хозяев ГХ / Fix for GuildHall Owners
function BOPOHCEBEPA:PortToHouse(name, houseId, houseName)
	if(houseId == GetHousingPrimaryHouse()) then
		d(SF.."|c81ddff Ворон: \n |cff00ca -Ох какой замечательный дом! А давай посмотрим, не проходит ли в таверне конкурс? Для этого посети Discord. Карр-р!|r")
	    RequestJumpToHouse(houseId)
	elseif (houseName == "Гильдхолл") then
		JumpToSpecificHouse(name, houseId)
		zo_callLater(function() d(SF.."|c81ddff Ворон: \n |c4d78ab -Если надо потренироваться,восстановить силы,подлатать снаряжение или создать его для будущих битв: Добро пожаловать в Гильдхолл, Кар-р!|r") end, 10000)
	elseif (houseName == "Бордель") then
		JumpToSpecificHouse(name, houseId)
		zo_callLater(function()  d(SF.."|c81ddff Ворон: \n |cce342b -Хочешь уединится, воплотить в жизнь фантазии или поучаствовать в жарких мероприятиях: Добро пожаловать в Бордель, Кар-р!|r") end, 10000)
	elseif (houseName == "Таверна") then
		JumpToSpecificHouse(name, houseId)
		zo_callLater(function() d(SF.."|c81ddff Ворон: \n |cf08924  -Любишь выпить кружку эля в шумной компании, за партией в карты, и поучаствовать в азартных конкурсах: Добро пожаловать в Трактир, Кар-р!|r") end, 10000)
	elseif (houseName == "Лагерь Пакта") then
		JumpToSpecificHouse(name, houseId)
		 d(SF.."|c81ddff Ворон: \n |cdadada -Кровь кипит и жаждет битвы, хочешь славы, победить и альянс свой защитить, участвовать в боевом празднике: Добро пожаловать в 'Лагерь Пакта', Кар-р!|r")
		
    end
end

		--Initialize
local function HelloMessage()
	EVENT_MANAGER:UnregisterForEvent(BOPOHCEBEPA.name, EVENT_PLAYER_ACTIVATED)
	CHAT_ROUTER:AddSystemMessage(SF.."|c81ddff Ворон: \n |c81ddff -И вновь приветствую в Тамриэле! Ты уже смотрел события недели в Таверне Ворон Севера? Кар-р!|r")
end

function BOPOHCEBEPA:Initialize()
	self:InitializeChatButton()
	SLASH_COMMANDS["/rl"] = function() ReloadUI() end
	SLASH_COMMANDS["/гильдхолл"] = function() BOPOHCEBEPA:PortToHouse("@falc_on81",80, "Гильдхолл" ) end
	SLASH_COMMANDS["/бордель"] = function() BOPOHCEBEPA:PortToHouse("@u0412087",91, "Бордель" ) end
	SLASH_COMMANDS["/таверна"] = function() BOPOHCEBEPA:PortToHouse("@BOPOH.CEBEPA", 30, "Таверна" ) end
	SLASH_COMMANDS["/лагерьпакта"] = function() BOPOHCEBEPA:PortToHouse("@alekseyka", 61, "Лагерь Пакта" ) end
	SLASH_COMMANDS["/h"] = function() d(SF.."Добро пожаловать домой.|r") RequestJumpToHouse(GetHousingPrimaryHouse()) end
end 


function BOPOHCEBEPA.OnAddOnLoaded(event, addon)
    if addon == BOPOHCEBEPA.name then
		EVENT_MANAGER:UnregisterForEvent(BOPOHCEBEPA.name, EVENT_ADD_ON_LOADED)
		EVENT_MANAGER:RegisterForEvent(BOPOHCEBEPA.name, EVENT_PLAYER_ACTIVATED, HelloMessage)
        BOPOHCEBEPA:Initialize()
    end
end

EVENT_MANAGER:RegisterForEvent(BOPOHCEBEPA.name, EVENT_ADD_ON_LOADED, BOPOHCEBEPA.OnAddOnLoaded)