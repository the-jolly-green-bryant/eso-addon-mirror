MirrorlandGuildHalls = {
	name = "MirrorlandGuildHalls",
	Guilds = {
		[600784] = true,	--MirrorLand
		[650690] = true,	--WonderLand
		[699342] = true,	--DreamLand
		[713814] = true,	--LostLand
		[532288] = true, 	--TronRu
		[632740] = true, 	--Riddle'Thar
		[761710] = true, 	--NGame
		},
	Label = "ГИЛЬДХОЛЛЫ",
	LabelFont = "ZoFontWinH4",
	Position={TOP,nil,TOP,40,5},
	ButtonSize=36,
	Space=2,
}

	--Текстуры
local lmb = '|t25:25:ESOUI/art/miscellaneous/icon_lmb.dds|t'
local rmb = '|t25:25:ESOUI/art/miscellaneous/icon_rmb.dds|t'
local dvd = '|t200:2:esoui/art/ava/ava_seigecontrols_divider.dds|t'
local CRN = '|t25:25:esoui/art/icons/guildranks/guild_indexicon_misc01_up.dds|t'
local menuGH = '|t25:25:esoui/art/journal/leaderboard_tabicon_home_up.dds|t'
local GDscl = '|t25:25:esoui/art/chatwindow/chat_friendsonline_up.dds|t'
local GDtrd = '|t25:25:esoui/art/tradinghouse/tradinghouse_sell_tabicon_up.dds|t'
local GDpvp = '|t25:25:esoui/art/hud/gamepad/gp_radialicon_duel_disabled.dds|t'
	--/esoui/art/hud/radialicon_duel_disabled.dds
local ADD = '|t25:25:esoui/art/progression/addpoints_up.dds|t'
local Discord = '|t25:25:esoui/art/help/help_tabicon_cs_disabled.dds|t'
local RUI = '|t25:25:esoui/art/ava/ava_keepstatus_icon_collectionrate.dds|t'
local SET = '|t25:25:esoui/art/chatwindow/chat_options_up.dds|t'
local GDB = '|t25:25:esoui/art/contacts/gamepad/gp_social_status_dnd.dds|t'
local QST = '|t25:25:esoui/art/help/help_tabicon_questassistance_up.dds|t'
local RCH = '|t25:25:esoui/art/tutorial/gamepad/gp_journalcheck.dds|t'
	--/esoui/art/hud/gamepad/gp_radialicon_accept_down.dds | tabicon_history_up.dds | help_tabicon_overview_up.dds
local GT = '|t25:25:esoui/art/contacts/tabicon_friends_up.dds|t'
local WSr = '|t25:25:esoui/art/icons/poi/poi_wayshrine_complete.dds|t'
local WCity = '|t25:25:esoui/art/icons/poi/poi_city_complete.dds|t'
local GCN = '|t20:20:esoui/art/loot/icon_goldcoin_pressed.dds|t'

local Web = '|t25:25:esoui/art/guild/tabicon_history_up.dds|t'
	--Имя
local MRR = '|c5c73ed[|t25:25:esoui/art/icons/justice_stolen_mirror_001.dds|t]|r: |cb8dbdd'
	--|cb8dbdd
	--|c0de3fc

	--Локации
local LocGrahtwood = '|cffdb58Гратвуд|r'
local LocStormhaven = '|c02729bСтормхейвен|r'
local LocDeshaan = '|cb2341fДешаан|r'
	-----
local LocCraglorn = '|cbfbc99Краглорн|r'
local LocCHarbour = '|cbfbc99Хладная Гавань|r'
	-----
local LocVvardenfell = '|cb58e49Вварденфелл|r'
local LocSummerset = '|cb58e49Саммерсет|r'
local LocNortEls = '|cb58e49Северный Эльсвейр|r'
local LocWestSky = '|cb58e49Западный Скайрим|r'
local LocBlWood = '|cb58e49Черный Лес|r'
local LocHIsle = '|cb58e49Высокий Остров|r'
	--Ивентовые
local LocNightMarket = '|cb163e0Ночной рынок|r'

	--Города
local CityEldenRoot = '|cffdb58Элден-Рут|r'
local CityWayrest = '|c02729bВэйрест|r'
local CityMournhold = '|cb2341fМорнхолд|r'
	-----
local CityBelkarth = '|cbfbc99Белкарт|r'
local CityHollowCity = '|cbfbc99Опустошенный город|r'
	-----
local CityVivec = '|cb58e49Вивек|r'
local CityAlinor = '|cb58e49Алинор|r'
local CityRimmen = '|cb58e49Риммен|r'
local CitySolitude = '|cb58e49Солитьюд|r'
local CityLeyawiin = '|cb58e49Лейавин|r'
local CityGonfalon = '|cb58e49Знаменная Гавань|r'

local bagSpaceIcon, bagSpaceLabel  -- runtime controls (forward decl)

		--Вывод флавор-сообщения в чат. Молчит, если категория заглушена
		--в «Тихом режиме» (settings["silent"..category], напр. silentGuildhalls).
function MirrorlandGuildHalls:Say(category, msg)
	local s = self.settings
	if s and (s.silentAll or s["silent"..category]) then return end
	d(msg)
end

		--«Живая» подпись пункта меню (для стоимости отзыва, которая постоянно убывает):
		--пока меню открыто, раз в 2с перезаписываем текст строки index значением labelFunc().
		--Цена в игре меняется раз в секунду, поэтому чаще опрашивать смысла нет.
local LIVE_RECALL_UPDATE = "MLGH_LiveRecallCost"
function MirrorlandGuildHalls.StartLiveRecallCost(index, labelFunc)
	EVENT_MANAGER:UnregisterForUpdate(LIVE_RECALL_UPDATE)
	local entry = ZO_Menu.items and ZO_Menu.items[index]
	local ctrl = entry and (entry.item or entry)
	local label = ctrl and (ctrl.nameLabel or ctrl)
	if not label then return end
	EVENT_MANAGER:RegisterForUpdate(LIVE_RECALL_UPDATE, 2000, function()
		if ZO_Menu:IsHidden() then
			EVENT_MANAGER:UnregisterForUpdate(LIVE_RECALL_UPDATE)
			return
		end
		label:SetText(labelFunc())
	end)
end


	--Единый источник по гильдейским домам: кнопки, меню ЛКМ и слэш-команды строятся отсюда
local ButtonData={
[1]={
	tooltip="Вилла",
	house={"@SiameseCat", 62},
	slash="/вилла",
	icon={"MirrorlandGuildHalls/imgs/GH_buttons/ML_st.dds", "MirrorlandGuildHalls/imgs/GH_buttons/ML_act.dds"},
	},
[2]={
	tooltip="Остров",
	house={"@NataLiyaN", 62},
	slash="/остров",
	icon={"MirrorlandGuildHalls/imgs/GH_buttons/TRN_st.dds", "MirrorlandGuildHalls/imgs/GH_buttons/TRN_act.dds"},
	},
[3]={
	tooltip="Пляж",
	house={"@Mirror_Cat", 40},
	slash="/пляж",
	icon={"MirrorlandGuildHalls/imgs/GH_buttons/WL_st.dds", "MirrorlandGuildHalls/imgs/GH_buttons/WL_act.dds"},
	},
[4]={
	tooltip="Поместье",
	house={"@Lost.Seeker", 46},
	slash="/поместье",
	icon={"MirrorlandGuildHalls/imgs/GH_buttons/LL_st.dds", "MirrorlandGuildHalls/imgs/GH_buttons/LL_act.dds"},
	},
[5]={
	tooltip="Убежище",
	house={"@D'eca", 40},
	slash="/убежище",
	icon={"MirrorlandGuildHalls/imgs/GH_buttons/RT_st.dds", "MirrorlandGuildHalls/imgs/GH_buttons/RT_act.dds"},
	},
}

local function MakeButton(control,num)
	local w,space=MirrorlandGuildHalls.ButtonSize,MirrorlandGuildHalls.Space
	local data=ButtonData[num]
	local name="ZO_GuildHome_MLGH_Button"..num
	local button=_G[name] or WINDOW_MANAGER:CreateControl(name, control, CT_BUTTON)
	button:SetDimensions(w,w)
	button:ClearAnchors()
	local shift=(128-(w+space)*#ButtonData)/2
	button:SetAnchor(TOPLEFT,control,TOPLEFT,shift+(w+space)*(num-1),25)
	button:SetHidden(false)
	button:SetNormalTexture(data.icon[1])
	button:SetMouseOverTexture(data.icon[2])
	button:SetMouseEnabled(true)
	button:SetDrawTier(DT_MEDIUM)
	button:SetDrawLayer(DL_CONTROLS)
	button:SetHandler("OnMouseEnter", function(self)
		PlaySound(SOUNDS.BOOK_METAL_PAGE_TURN)
		if data.tooltip then
			local tooltip=data.tooltip
			ZO_Tooltips_ShowTextTooltip(self, BOTTOM, (type(tooltip)=="string" and tooltip or tooltip()))
		end
	end)
	button:SetHandler("OnMouseExit", function(self)
		if data.tooltip then ZO_Tooltips_HideTextTooltip() end
	end)
	button:SetHandler("OnMouseDown", function(self)
		if data.house then
			if (GetDisplayName() == data.house[1]) then
				RequestJumpToHouse(data.house[2])
				MirrorlandGuildHalls:Say("Guildhalls", MRR.."Да, давай осмотрим наши владения.|r")
			else
				JumpToSpecificHouse(data.house[1],data.house[2])
				MirrorlandGuildHalls:Say("Guildhalls", MRR.."Уиии! Летим в наш гильдейский дом!|r")
			end
		end
	end)
end

local function UI_Init()
	local control=ZO_GuildHome_MLGH or WINDOW_MANAGER:CreateControl("ZO_GuildHome_MLGH", ZO_GuildHome, CT_CONTROL)
	local pos=MirrorlandGuildHalls.Position
	control:SetDimensions(128,64)
	control:ClearAnchors()
	control:SetAnchor(pos[1],ZO_GuildHome,pos[3],pos[4],pos[5])
	control:SetHidden(false)

	local label=ZO_GuildHome_Label or WINDOW_MANAGER:CreateControl("ZO_GuildHome_Label", control, CT_LABEL)
	label:SetDimensions(128,20)
	label:ClearAnchors()
	label:SetAnchor(TOPLEFT,control,TOPLEFT,0,0)
	label:SetFont(MirrorlandGuildHalls.LabelFont)
	label:SetColor(.9,.9,.8,1)
	label:SetHorizontalAlignment(1)
	label:SetVerticalAlignment(0)
	label:SetText(MirrorlandGuildHalls.Label)
	label:SetHidden(false)

	for num = 1, #ButtonData do
		MakeButton(control,num)
	end
end

	
	
function MirrorlandGuildHalls:InitializeChatButton()
		--Тултип
local function ShowTooltip(control)
		InitializeTooltip(InformationTooltip, control, TOPLEFT, 5, -10, BOTTOMRIGHT)
		InformationTooltip:AddLine(""..CRN.."|cBFBC99MirrorLand Community|r"..CRN.."")
		InformationTooltip:AddVerticalPadding(-15)
		InformationTooltip:AddLine(""..dvd.."")
		InformationTooltip:AddVerticalPadding(-10)
		InformationTooltip:AddLine(""..lmb.."|cBFBC99Меню|r"..rmb.."|cBFBC99Сообщество|r")
    end  
local function HideTooltip(control)
		ClearTooltip(InformationTooltip)
    end
	
		--Меню
local function MLC_Menu(control, button)
	if button == 2 then
		local SubMenuML = {
				{label = ""..ADD.."Вступить", callback = function() ZO_LinkHandler_OnLinkClicked("|H1:guild:600784|hMirrorLand|h", 1) end,},
				{label = "-", },
				{label = ""..Discord.."Дискорд", callback = function() RequestOpenUnsafeURL("https://discord.gg/VuhvUBmHDB") end,},
			}
		local SubMenuWL = {
				{label = ""..ADD.."Вступить", callback = function() ZO_LinkHandler_OnLinkClicked("|H1:guild:650690|hWonderIand|h", 1) end,},
				{label = "-", },
				{label = ""..Discord.."Дискорд", callback = function() RequestOpenUnsafeURL("https://discord.gg/VuhvUBmHDB") end,},
			}
		local SubMenuDL = {
				{label = ""..ADD.."Вступить", callback = function() ZO_LinkHandler_OnLinkClicked("|H1:guild:699342|hDreamIand|h", 1) end,},
				{label = "-", },
				{label = ""..Discord.."Дискорд", callback = function() RequestOpenUnsafeURL("https://discord.gg/VuhvUBmHDB") end,},
			}
		local SubMenuLL = {
				{label = ""..ADD.."Вступить", callback = function() ZO_LinkHandler_OnLinkClicked("|H1:guild:713814|hLostLand|h", 1) end,},
				{label = "-", },
				{label = ""..Discord.."Дискорд", callback = function() RequestOpenUnsafeURL("https://discord.gg/VuhvUBmHDB") end,},
			}
		local SubMenuTRN = {
				{label = ""..ADD.."Вступить", callback = function() ZO_LinkHandler_OnLinkClicked("|H1:guild:532288|hTronRU|h", 1) end,},
				{label = "-", },
				{label = ""..Discord.."Дискорд", callback = function() RequestOpenUnsafeURL("https://discord.gg/RqMymF9") end,},
			}
		local SubMenuNG = {
				{label = ""..ADD.."Вступить", callback = function() ZO_LinkHandler_OnLinkClicked("|H1:guild:761710|hNGame|h", 1) end,},
				{label = "-", },
				{label = ""..Discord.."Дискорд", callback = function() RequestOpenUnsafeURL("https://discord.gg/dFEp6CG4bT") end,},
			}
		local SubMenuRT = {
				{label = ""..ADD.."Вступить", callback = function() ZO_LinkHandler_OnLinkClicked("|H1:guild:632740|hRiddle'Thar|h", 1) end,},
				{label = "-", },
				{label = ""..Discord.."Дискорд", callback = function() RequestOpenUnsafeURL("https://discord.gg/VuhvUBmHDB") end,},
			}
			ClearMenu()
			AddCustomMenuItem(""..Web.."Наш сайт", function() RequestOpenUnsafeURL("https://mlc-teso.ru/") end)
			AddCustomMenuItem("-", function() end)
			AddCustomSubMenuItem(""..GDscl.."MirrorLand", SubMenuML)
			AddCustomSubMenuItem(""..GDscl.."WonderLand", SubMenuWL)
			AddCustomSubMenuItem(""..GDscl.."DreamLand", SubMenuDL)
			AddCustomSubMenuItem(""..GDscl.."LostLand", SubMenuLL)
			AddCustomSubMenuItem(""..GDscl.."TronRu", SubMenuTRN)
			AddCustomSubMenuItem(""..GDscl.."NGame", SubMenuNG)
			AddCustomSubMenuItem(""..GDpvp.."Riddle'Thar", SubMenuRT)
			ShowMenu()
	elseif button == 1 then
		local entries = {}
			for _, h in ipairs(ButtonData) do
				table.insert(entries, {label = ""..menuGH..h.tooltip, callback = function() MirrorlandGuildHalls:PortToHouse(h.house[1], h.house[2]) end, })
				table.insert(entries, {label = "-", })
			end
		local MLCGroupMenu = {
				{label = ""..CRN.."К лидеру", callback = function() MirrorlandGuildHalls:Say("Group", MRR.."Полетели на коронку!|r") JumpToGroupLeader() end,},
				{label = ""..QST.."Поделиться заданиями", callback = function() MirrorlandGuildHalls.ShareAllDailies() end,},
				{label = "-", },
				{label = ""..GDB.."|c880000Выйти из группы|r", callback = function() GroupLeave() end,},
			}
		local MLCGroupMenuGL = {
				{label = ""..RCH.."Проверка готовности", callback = function() MirrorlandGuildHalls:Say("Group", MRR.."ВСЕ ГОТОВЫ?!|r") ZO_SendReadyCheck() end, },
				{label = ""..QST.."Поделиться заданиями", callback = function() MirrorlandGuildHalls.ShareAllDailies() end,},
				{label = "-", },
				{label = ""..GDB.."|c880000Выйти из группы|r", callback = function() GroupLeave() end,},
				{label = ""..GDB.."|c880000Распустить группу|r", callback = function() GroupDisband() end, }, 
			}
		local locZones = {
			{LocGrahtwood,181},{LocStormhaven,4},{LocDeshaan,10},"-",
			{LocCraglorn,501},{LocCHarbour,155},"-",
			{LocVvardenfell,468},{LocSummerset,617},{LocNortEls,682},{LocWestSky,744},{LocBlWood,835},{LocHIsle,884},
		}
		local zoneCounts = MirrorlandGuildHalls.CountPlayersByZone()
		local MLCLocMenu = {}
		for _, z in ipairs(locZones) do
			if z == "-" then
				MLCLocMenu[#MLCLocMenu+1] = {label = "-", }
			else
				local n = zoneCounts[z[2]] or 0
				local suffix = n > 0 and (" |cb8dbdd("..n..")|r") or ""
				MLCLocMenu[#MLCLocMenu+1] = {label = ""..WSr..""..z[1]..suffix, callback = function() MirrorlandGuildHalls.Teleport(z[2]) end, }
			end
		end
			--Ночной рынок: zoneId 1559, индекс динамический; пункт только пока ивент активен
		if IsAdventureZoneActive() then
			local nmIndex = GetZoneIndex(1559)
			local n = zoneCounts[nmIndex] or 0
			local suffix = n > 0 and (" |cb8dbdd("..n..")|r") or ""
			MLCLocMenu[#MLCLocMenu+1] = {label = "-", }
			MLCLocMenu[#MLCLocMenu+1] = {label = ""..WSr..""..LocNightMarket..suffix, callback = function() MirrorlandGuildHalls.Teleport(nmIndex) end, }
		end
		local MLCCityMenu = {
				{label = ""..WCity..""..CityEldenRoot.."", callback = function() 	MirrorlandGuildHalls.CityTeleport(214) end, },	--EldenRoot
				{label = ""..WCity..""..CityWayrest.."", callback = function() 		MirrorlandGuildHalls.CityTeleport(56) end, },	--Wayrest
				{label = ""..WCity..""..CityMournhold.."", callback = function() 	MirrorlandGuildHalls.CityTeleport(28) end, },	--Mournhold
				{label = "-", },                                                                                                                  
				{label = ""..WCity..""..CityBelkarth.."", callback = function() 	MirrorlandGuildHalls.CityTeleport(220) end, },	--Belkarth
				{label = ""..WCity..""..CityHollowCity.."", callback = function() 	MirrorlandGuildHalls.CityTeleport(131) end, }, 	--HollowCity
				{label = "-", },                                                                                                                  
				{label = ""..WCity..""..CityVivec.."", callback = function() 		MirrorlandGuildHalls.CityTeleport(284) end, },	--Vivec
				{label = ""..WCity..""..CityAlinor.."", callback = function() 		MirrorlandGuildHalls.CityTeleport(355) end, },	--Alinor
				{label = ""..WCity..""..CityRimmen.."", callback = function() 		MirrorlandGuildHalls.CityTeleport(382) end, },	--Rimmen
				{label = ""..WCity..""..CitySolitude.."", callback = function() 	MirrorlandGuildHalls.CityTeleport(421) end, },	--Solitude
				{label = ""..WCity..""..CityLeyawiin.."", callback = function() 	MirrorlandGuildHalls.CityTeleport(458) end, },	--Leyawiin
				{label = ""..WCity..""..CityGonfalon.."", callback = function() 	MirrorlandGuildHalls.CityTeleport(513) end, },	--Знаменная Гавань
			}
			ClearMenu()
			AddCustomMenuItem(""..menuGH.."Домой", function() MirrorlandGuildHalls:Say("Guildhalls", MRR.."Дом, милый дом.|r") RequestJumpToHouse(GetHousingPrimaryHouse()) end)
			AddCustomMenuItem("-", function() end)
			AddCustomSubMenuItem(""..menuGH.."Гильдхоллы", entries)
			if (IsUnitGrouped("player")) then
				AddCustomMenuItem("-", function() end)
				if not (IsUnitGroupLeader("player")) then
					AddCustomSubMenuItem(""..GT.."Груп.меню", MLCGroupMenu)
				else
					AddCustomSubMenuItem(""..GT.."Груп.меню", MLCGroupMenuGL)
				end
			end
			AddCustomMenuItem("-", function() end)
			AddCustomSubMenuItem(""..WSr.."Локации", MLCLocMenu)
			local function cityLabel() return ""..WCity.."Города |cffffff"..GetRecallCost().."|r"..GCN.."" end
			local cityIndex = AddCustomSubMenuItem(cityLabel(), MLCCityMenu)
			AddCustomMenuItem("-", function() end)
			AddCustomMenuItem(""..RUI.."ReloadUI", function() ReloadUI() end)
			AddCustomMenuItem(""..SET.."Настройки", function() LibAddonMenu2:OpenToPanel(MirrorlandGuildHalls.settingsPanel) end)
			ShowMenu()
			MirrorlandGuildHalls.StartLiveRecallCost(cityIndex, cityLabel)
		end
end

		--Кнопка развернутого чата
	local MLbtn =  WINDOW_MANAGER:CreateControl("MaxMLGH", ZO_ChatWindow, CT_BUTTON)
    MLbtn:SetDimensions(24, 24)
    MLbtn:SetAnchor(TOPLEFT, ZO_ChatOptionsSectionLabel, TOPLEFT, 200, 12)
   	MLbtn:SetHandler("OnMouseEnter", function(control) ShowTooltip(control) end)
    MLbtn:SetHandler("OnMouseExit", function(control) HideTooltip(control) end)
	MLbtn:SetNormalTexture("MirrorlandGuildHalls/imgs/ML_off.dds")
    MLbtn:SetPressedTexture("MirrorlandGuildHalls/imgs/ML_on.dds")
    MLbtn:SetMouseOverTexture("MirrorlandGuildHalls/imgs/ML_on.dds")
	MLbtn:SetHandler("OnMouseUp", function(control, button) MLC_Menu(control, button) end)
		
		--Кнопка свернутого чата
	local MLbtnMin =  WINDOW_MANAGER:CreateControl("MinMLGH", ZO_ChatWindowMinBar, CT_BUTTON)
    MLbtnMin:SetDimensions(24, 24)
    MLbtnMin:SetAnchor(TOPLEFT, ZO_ChatWindowMinBar, nil, 0, 423)
    MLbtnMin:SetHandler("OnMouseEnter", function(control) ShowTooltip(control) end)
	MLbtnMin:SetHandler("OnMouseExit", function(control) HideTooltip(control) end)
    MLbtnMin:SetNormalTexture("MirrorlandGuildHalls/imgs/ML_off.dds")
    MLbtnMin:SetPressedTexture("MirrorlandGuildHalls/imgs/ML_on.dds")
    MLbtnMin:SetMouseOverTexture("MirrorlandGuildHalls/imgs/ML_on.dds")
	MLbtnMin:SetHandler("OnMouseUp", function(control, button) MLC_Menu(control, button) end)
end

		--Фикс для хозяев ГХ
function MirrorlandGuildHalls:PortToHouse(name, houseId)
    if (GetDisplayName() == name) then
        RequestJumpToHouse(houseId)
		 MirrorlandGuildHalls:Say("Guildhalls", MRR.."Да, давай осмотрим наши владения.|r")
    else
        JumpToSpecificHouse(name, houseId)
		 MirrorlandGuildHalls:Say("Guildhalls", MRR.."Уиии! Летим в наш гильдейский дом!|r")
    end
end

--------------------------------------------------------------------------------
		--Доп. функционал
--------------------------------------------------------------------------------
		
		--Диалог с банком
local bankScene = SCENE_MANAGER:GetScene("bank")
    bankScene:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_SHOWN and MirrorlandGuildHalls.settings and MirrorlandGuildHalls.settings.bankDeposit then
            MirrorlandGuildHalls.selectDeposit()
        end
    end)
		
function MirrorlandGuildHalls.selectDeposit()
    ZO_MenuBar_SelectDescriptor(ZO_PlayerBankMenuBar, SI_BANK_DEPOSIT)
end

		--Индикатор свободного места в инвентаре
function MirrorlandGuildHalls.BagSpaceIndicator()
	if not (MirrorlandGuildHalls.settings and MirrorlandGuildHalls.settings.bagSpace) then return end
		bagSpaceIcon = CreateControl("BagSpaceIcon", ZO_MailInbox, CT_TEXTURE)
			bagSpaceIcon:SetDimensions(26,26)
			bagSpaceIcon:SetAnchor(LEFT, ZO_MailInboxUnread, LEFT, 5, 30)
			bagSpaceIcon:SetTexture("/esoui/art/icons/justice_stolen_pouch_001.dds")

		bagSpaceLabel = CreateControl("BagSpaceLabel", ZO_MailInbox, CT_LABEL)
			bagSpaceLabel:SetColor(1, 1, 1, 1)
			bagSpaceLabel:SetFont("ZoFontGameBold")
			bagSpaceLabel:SetText("")
			bagSpaceLabel:SetAnchor(LEFT, bagSpaceIcon, RIGHT, 7, 0)
			bagSpaceLabel:SetDimensions(80,25)
end

local function BagUpdateSpace(eventCode, mailId) 
	if not bagSpaceLabel then return end
	bagSpaceLabel:SetText(GetNumBagUsedSlots(1)..'/'..GetBagSize(1))
	if GetBagSize(1) ==	GetNumBagUsedSlots(1) then
		bagSpaceLabel:SetColor(1,0,0,1)
	elseif (GetBagSize(1)-GetNumBagUsedSlots(1)) <= 10 then
		bagSpaceLabel:SetColor(1,0.9,0,1)
	else
		bagSpaceLabel:SetColor(1, 1, 1, 1)
	end
end	
		--Удаление писем без подтверждений
--[[ZO_PreHook(MAIL_INBOX, "Delete", function( self )
	if (self.mailId and self:IsMailDeletable()) then
		local numAttachments, attachedMoney = GetMailAttachmentInfo(self.mailId)
		if (numAttachments == 0 and attachedMoney == 0) then
			local selectedMailNode = self.navigationTree:GetSelectedNode()
			if (selectedMailNode) then
				local nextOrPreviousNode = selectedMailNode:GetNextOrPreviousSiblingNode()
				if (nextOrPreviousNode) then
					self.selectMailIdOnRefresh = nextOrPreviousNode.data.mailId
				end
			end
			self:ConfirmDelete(self.mailId)
			return true
		end
	end
	return false
end)]]--

        --Подтверждение удаления предмета
ZO_PreHook("ZO_Dialogs_ShowPlatformDialog", function( ... )
	local name, data, textParams = ...
	if name == "CONFIRM_DESTROY_ITEM_PROMPT" and MirrorlandGuildHalls.settings and MirrorlandGuildHalls.settings.skipDestroyConfirm then
		ZO_Dialogs_ShowPlatformDialog("DESTROY_ITEM_PROMPT", nil, textParams)
		return true
	end
end)

		--Поделиться всеми дейликами
		--UPD 0.0.7 - шара ТОЛЬКО локальных
function MirrorlandGuildHalls.ShareAllDailies()
	local QZone=GetPlayerActiveZoneName()
	local quest_count = 0
    for i = 1, GetNumJournalQuests() do
		if GetJournalQuestRepeatType(i) == QUEST_REPEAT_DAILY and GetIsQuestSharable(i) then
			if string.find(GetJournalQuestLocationInfo(i), QZone) then
				ShareQuest(i)
				MirrorlandGuildHalls:Say("Quests", MRR.."Делюсь заданием: "..'"'..GetJournalQuestName(i)..'"'.."|r")
				quest_count=quest_count+1
			end
		end
end
    if quest_count==0 then
        MirrorlandGuildHalls:Say("Quests", MRR.."Ну вот, даже поделиться нечем!|r")
    end
    if quest_count>=1 then
        MirrorlandGuildHalls:Say("Quests", MRR.."Заданий роздано: "..quest_count.."|r")
    end
	StartChatInput("Заданий роздано: "..quest_count.."", CHAT_CHANNEL_PARTY)
end

		--Сделай приятно зеркальцу, создай группу!
local function OnGroupCreate(eventCode, memberCharacterName, memberDisplayName, isLocalPlayer)
    if not IsUnitGrouped("player") then return end
    if isLocalPlayer then
        local groupSize = GetGroupSize()
        if groupSize == 2 then
			if not (IsUnitGroupLeader("player")) then
				MirrorlandGuildHalls:Say("Group", MRR.."Правильно, в компании веселее!|r")
			else
				MirrorlandGuildHalls:Say("Group", MRR.."Правильно, в компании веселее! Ой, да ты еще и главный!|r")
			end
        end
    end
end

		--Сколько доступных для телепортации игроков (группа+друзья+гильдии) в каждой зоне.
		--Один проход, dedup по @имени; условия те же, что использует Teleport().
function MirrorlandGuildHalls.CountPlayersByZone()
	local counts, seen = {}, {}
	local me = GetUnitDisplayName("player")
		--Группа
	for p=1, GetGroupSize() do
		local tag = GetGroupUnitTagByIndex(p)
		local name = GetUnitDisplayName(tag)
		if name ~= me and not seen[name] and CanJumpToGroupMember(tag) then
			seen[name] = true
			local z = GetUnitZoneIndex(tag)
			counts[z] = (counts[z] or 0) + 1
		end
	end
		--Друзья
	for f=1, GetNumFriends() do
		local name, _, status = GetFriendInfo(f)
		local hasChar, _, _, _, _, _, _, zoneId = GetFriendCharacterInfo(f)
		if name ~= me and not seen[name] and status ~= PLAYER_STATUS_OFFLINE and hasChar then
			seen[name] = true
			local z = GetZoneIndex(zoneId)
			counts[z] = (counts[z] or 0) + 1
		end
	end
		--Гильдии
	for g=1, GetNumGuilds() do
		local guildId = GetGuildId(g)
		for m=1, GetNumGuildMembers(guildId) do
			local name, _, _, status = GetGuildMemberInfo(guildId, m)
			local hasChar, _, _, _, _, _, _, zoneId = GetGuildMemberCharacterInfo(guildId, m)
			if name ~= me and not seen[name] and status ~= PLAYER_STATUS_OFFLINE and hasChar then
				seen[name] = true
				local z = GetZoneIndex(zoneId)
				counts[z] = (counts[z] or 0) + 1
			end
		end
	end
	return counts
end

		--Телепорт в зоны (from DailyHelper)
function MirrorlandGuildHalls.Teleport(zone)
	local porting=false
	local zoneNames = {
		[181] = LocGrahtwood, [4] = LocStormhaven, [10] = LocDeshaan,
		[501] = LocCraglorn, [155] = LocCHarbour,
		[468] = LocVvardenfell, [617] = LocSummerset, [682] = LocNortEls,
		[744] = LocWestSky, [835] = LocBlWood, [884] = LocHIsle,
	}
	local MLCzoneName = zoneNames[zone] or zo_strformat("<<1>>", GetZoneNameByIndex(zone))
		--Проверка членов группы
	for p=1, GetGroupSize() do
		local pTag=GetGroupUnitTagByIndex(p)
		if GetUnitZoneIndex(pTag)==zone and CanJumpToGroupMember(pTag) and porting==false and GetUnitDisplayName(pTag)~=GetUnitDisplayName("player") then
			JumpToGroupMember(GetUnitName(pTag))
			MirrorlandGuildHalls:Say("TpOk", MRR.."|r|c0de3fc"..GetUnitDisplayName(pTag).."|r|cb8dbdd, а вы случайно не знаете, как нам выйти отсюда? Лишь бы куда-нибудь в|r "..MLCzoneName.."|cb8dbdd.|r")
			porting=true
			break
		end
	end
		--Проверка друзей
	if porting == false then
		for f=1, GetNumFriends() do
			local CharInfo = {}
			CharInfo.displayName, CharInfo.Note, CharInfo.status, CharInfo.secsSinceLogoff = GetFriendInfo(f)
			CharInfo.hasCharacter, CharInfo.characterName, CharInfo.zoneName, CharInfo.classType, CharInfo.alliance, CharInfo.level, CharInfo.championRank, CharInfo.zoneId = GetFriendCharacterInfo(f)
			if CharInfo.status~=PLAYER_STATUS_OFFLINE and GetZoneIndex(CharInfo.zoneId)==zone and porting==false and CharInfo.displayName~=GetUnitDisplayName("player") then
				JumpToFriend(CharInfo.displayName)
				MirrorlandGuildHalls:Say("TpOk", MRR.."|r|c0de3fc"..CharInfo.displayName.."|r|cb8dbdd, а вы случайно не знаете, как нам выйти отсюда? Лишь бы куда-нибудь в|r "..MLCzoneName.."|cb8dbdd.|r")
				porting=true
				break
			end
		end
	end
		--Проверка гильдий
	if porting == false then
		for g=1, GetNumGuilds() do
			for m=1, GetNumGuildMembers(GetGuildId(g)) do
				local CharInfo = {}
				CharInfo.displayName, CharInfo.Note, CharInfo.GuildMemberRankIndex, CharInfo.status, CharInfo.secsSinceLogoff = GetGuildMemberInfo(GetGuildId(g), m)
				CharInfo.hasCharacter, CharInfo.characterName, CharInfo.zoneName, CharInfo.classType, CharInfo.alliance, CharInfo.level, CharInfo.championRank, CharInfo.zoneId = GetGuildMemberCharacterInfo(GetGuildId(g), m)
				CharInfo.guildIndex = g
				if CharInfo.status~=PLAYER_STATUS_OFFLINE and GetZoneIndex(CharInfo.zoneId)==zone and porting==false and CharInfo.displayName~=GetUnitDisplayName("player") then
					JumpToGuildMember(CharInfo.displayName)
					MirrorlandGuildHalls:Say("TpOk", MRR.."|r|c0de3fc"..CharInfo.displayName.."|r|cb8dbdd, а вы случайно не знаете, как нам выйти отсюда? Лишь бы куда-нибудь в|r "..MLCzoneName.."|cb8dbdd.|r")
					porting=true
					break
				end
			end
		end
	end
		--Если никого нет
	if porting == false then MirrorlandGuildHalls:Say("TpFail", MRR.."Не настаиваю, но, возможно, тебе стоит задуматься о расширении круга общения...|r") end
end

		--Телепорт в города
function MirrorlandGuildHalls.CityTeleport(node)
	local cityNames = {
		[214] = CityEldenRoot, [56] = CityWayrest, [28] = CityMournhold,
		[220] = CityBelkarth, [131] = CityHollowCity,
		[284] = CityVivec, [355] = CityAlinor, [382] = CityRimmen,
		[421] = CitySolitude, [458] = CityLeyawiin, [513] = CityGonfalon,
	}
	if not HasCompletedFastTravelNodePOI(node) then
		MirrorlandGuildHalls:Say("TpFail", MRR.."Боюсь, что до этого святилища придётся топать ножками...|r")
		return
	end
	if cityNames[node] then
		FastTravelToNode(node)
		MirrorlandGuildHalls:Say("TpOk", MRR.."Ты знаешь, что такое безумие? Безумие - это платить|r |cffffff"..GetRecallCost(node).."|r"..GCN.." |cb8dbddза полёт в |r"..cityNames[node].."|cb8dbdd.|r")
	end
end

		--Initialize
local function HelloMessage()
	EVENT_MANAGER:UnregisterForEvent(MirrorlandGuildHalls.name, EVENT_PLAYER_ACTIVATED)
	CHAT_ROUTER:AddSystemMessage(MRR.."Эй, |c0de3fc"..GetUnitDisplayName("player").."|r|cb8dbdd, ты знаешь как долго мы с Королевой искали тебя?|r")
end

function MirrorlandGuildHalls:Initialize()
	self:InitializeSettings()
	self:InitializeChatButton()
	self:BagSpaceIndicator()
	SLASH_COMMANDS["/rl"] = function() ReloadUI() end
	SLASH_COMMANDS["/кд"] = function() ReloadUI() end
	SLASH_COMMANDS["/лидер"] = function() MirrorlandGuildHalls:Say("Group", MRR.."Полетели на коронку!|r") JumpToGroupLeader() end
	SLASH_COMMANDS["/leader"] = function() MirrorlandGuildHalls:Say("Group", MRR.."Полетели на коронку!|r") JumpToGroupLeader() end
	for _, h in ipairs(ButtonData) do
		SLASH_COMMANDS[h.slash] = function() MirrorlandGuildHalls:PortToHouse(h.house[1], h.house[2]) end
	end
	SLASH_COMMANDS["/h"] = function() MirrorlandGuildHalls:Say("Guildhalls", MRR.."Дом, милый дом.|r") RequestJumpToHouse(GetHousingPrimaryHouse()) end
	SLASH_COMMANDS["/д"] = function() MirrorlandGuildHalls:Say("Guildhalls", MRR.."Дом, милый дом.|r") RequestJumpToHouse(GetHousingPrimaryHouse()) end
	SLASH_COMMANDS["/дом"] = function() MirrorlandGuildHalls:Say("Guildhalls", MRR.."Дом, милый дом.|r") RequestJumpToHouse(GetHousingPrimaryHouse()) end
end 
    
function MirrorlandGuildHalls.OnAddOnLoaded(event, addon)
    if addon == MirrorlandGuildHalls.name then
		EVENT_MANAGER:UnregisterForEvent(MirrorlandGuildHalls.name, EVENT_ADD_ON_LOADED)
		EVENT_MANAGER:RegisterForEvent(MirrorlandGuildHalls.name, EVENT_GROUP_MEMBER_JOINED, OnGroupCreate)
		EVENT_MANAGER:RegisterForEvent(MirrorlandGuildHalls.name, EVENT_PLAYER_ACTIVATED, HelloMessage)
		EVENT_MANAGER:RegisterForEvent(MirrorlandGuildHalls.name, EVENT_MAIL_OPEN_MAILBOX, BagUpdateSpace)	
		EVENT_MANAGER:RegisterForEvent(MirrorlandGuildHalls.name, EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS, BagUpdateSpace)
		EVENT_MANAGER:RegisterForEvent(MirrorlandGuildHalls.name, EVENT_MAIL_SEND_SUCCESS, BagUpdateSpace)
        MirrorlandGuildHalls:Initialize()
		UI_Init()
		ZO_PreHookHandler(ZO_GuildHome,"OnEffectivelyShown",function()
			ZO_GuildHome_MLGH:SetHidden(not MirrorlandGuildHalls.Guilds[GUILD_SELECTOR.guildId])
		end)
		CALLBACK_MANAGER:RegisterCallback("OnGuildSelected",function()
			ZO_GuildHome_MLGH:SetHidden(not MirrorlandGuildHalls.Guilds[GUILD_SELECTOR.guildId])
		end)
    end
end

EVENT_MANAGER:RegisterForEvent(MirrorlandGuildHalls.name, EVENT_ADD_ON_LOADED, MirrorlandGuildHalls.OnAddOnLoaded)