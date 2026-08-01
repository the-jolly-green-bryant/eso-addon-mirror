PrideGuildhall = PrideGuildhall or {}
local PrideGuildhall = _G['PrideGuildhall']
local AddonName="PrideGuildhall"
local lang=GetCVar("language.2")


local Settings={
	Guilds={
		[723658]=true,	--Тигры
		[713166]=true,	--Львы
		
		},
	Logo=true,
	Label={en="Wellcome",ru="Wellcome"},
	LabelFont="ZoFontWinH4",
	Position={TOP,nil,TOP,40,5},	--/script local control=ZO_GuildHome_PrideGuildhall control:ClearAnchors() control:SetAnchor(TOP,nil,TOP,40,5)
	Vertical=false,
	ButtonSize=36,	--Max value: 100/[num of buttons] for vertical, 128/[num of buttons] for horisontal
	Space=2,
	Message=true,
	MessageText={en="Jump to ",ru="Перемещаемся в "},
}
local ButtonData={
[1]={
	tooltip={en="Main guildhall", ru="Гильдхолл Прайда"},
	house={"@Alex_Zi"},
	icon="/esoui/art/treeicons/gamepad/gp_tutorial_idexicon_ava.dds",
	},
[2]={
	tooltip={en="Crafting house", ru="Ремесленный дом Прайда"},
	house={"@falc_on81"},
	icon="esoui/art/treeicons/gamepad/gp_tutorial_idexicon_tradeskills.dds"
	},
}


local function MakeButton(control,num)
	local w,space=Settings.ButtonSize,Settings.Space
	local data=ButtonData[num]
	local name="ZO_GuildHome_PrideGuildhall_Button"..num
	local button=_G[name] or WINDOW_MANAGER:CreateControl(name, control, CT_TEXTURE)
	button:SetDimensions(w,w)
	button:ClearAnchors()
	if Settings.Vertical then
		button:SetAnchor(TOP,control,TOP,0,18+(w+space)*(num-1))
	else
		local shift=(128-(w+space)*#ButtonData)/2
		button:SetAnchor(TOPLEFT,control,TOPLEFT,shift+(w+space)*(num-1),18)
	end
	button:SetHidden(false)
	button:SetTexture(data.icon)
	button:SetColor(.6,.57,.46,1)
	button:SetMouseEnabled(true)
	button:SetHandler("OnMouseEnter", function(self)
		self:SetColor(.9,.9,.8,1)
		if data.tooltip then
			local tooltip=data.tooltip[lang] or data.tooltip.en
			ZO_Tooltips_ShowTextTooltip(self, BOTTOMRIGHT, (type(tooltip)=="string" and tooltip or tooltip()))
		end
	end)
	button:SetHandler("OnMouseExit", function(self)
		self:SetColor(.6,.57,.46,1)
		if data.tooltip then ZO_Tooltips_HideTextTooltip() end
	end)
	button:SetHandler("OnMouseDown", function(self)
		if Settings.Message and data.house then
			SCENE_MANAGER:SetInUIMode()
			local tooltip=data.tooltip[lang] or data.tooltip.en
			--ScreenMessage((Settings.MessageText[lang] or Settings.MessageText.en)..tooltip,8000)
			if data.house[2] then
				JumpToSpecificHouse(data.house[1],data.house[2])
			else
				JumpToHouse(data.house[1])
			end
		end
		self:SetColor(.6,.57,.46,1)
	end)
end

local function UI_Init()
	local control=ZO_GuildHome_PrideGuildhall or WINDOW_MANAGER:CreateControl("ZO_GuildHome_PrideGuildhall", ZO_GuildHome, CT_CONTROL)
	local pos=Settings.Position
	control:SetDimensions(128,64)
	control:ClearAnchors()
	control:SetAnchor(pos[1],ZO_GuildHome,pos[3],pos[4],pos[5])
	control:SetHidden(false)

	local label=ZO_GuildHome_Label or WINDOW_MANAGER:CreateControl("ZO_GuildHome_Label", control, CT_LABEL)
	label:SetDimensions(128,20)
	label:ClearAnchors()
	label:SetAnchor(TOPLEFT,control,TOPLEFT,0,0)
	label:SetFont(Settings.LabelFont)
	label:SetColor(.9,.9,.8,1)
	label:SetHorizontalAlignment(1)
	label:SetVerticalAlignment(0)
	label:SetText(Settings.Label[lang] or Settings.Label.en)
	label:SetHidden(false)
	if Settings.Logo then
		local texture=ZO_GuildHome_PrideLogo or WINDOW_MANAGER:CreateControl("ZO_GuildHome_PrideLogo", control, CT_TEXTURE)
		texture:SetDimensions(640,1024)
		texture:ClearAnchors()
		texture:SetAnchor(TOP,control,TOP,65,0)
		texture:SetTexture("/PrideGuildhall/Pride_logo.dds")
		texture:SetAlpha(.4)
		texture:SetHidden(false)
	end

	for num in pairs(ButtonData) do
		MakeButton(control,num)
	end
--	GUILD_HOME_SCENE:AddFragment(ZO_SimpleSceneFragment:New(control))
end

local function OnAddOnLoaded(_,addonName)
	if addonName~=AddonName then return end
	EVENT_MANAGER:UnregisterForEvent("PGH_Event", EVENT_ADD_ON_LOADED)
--	PGH_Vars=ZO_SavedVars:NewAccountWide("PGH_Settings", 3, nil, Defaults)
	ZO_PreHookHandler(ZO_GuildHome,"OnEffectivelyShown",function()
		ZO_GuildHome_PrideGuildhall:SetHidden(not Settings.Guilds[GUILD_SELECTOR.guildId])
	end)
--	ZO_PreHookHandler(ZO_GuildHome,'OnEffectivelyHidden',function() end)
	CALLBACK_MANAGER:RegisterCallback("OnGuildSelected",function()
		ZO_GuildHome_PrideGuildhall:SetHidden(not Settings.Guilds[GUILD_SELECTOR.guildId])
	end)
	UI_Init()
end

function PrideGuildhall_Initialize(eventCode, addOnName)
		
		--Текстуры
	lmb = '|t25:25:ESOUI/art/miscellaneous/icon_lmb.dds|t'
	rmb = '|t25:25:ESOUI/art/miscellaneous/icon_rmb.dds|t'
	dvd = '|t200:2:esoui/art/ava/ava_seigecontrols_divider.dds|t'
	CRN = '|t25:25:esoui/art/icons/guildranks/guild_indexicon_misc01_up.dds|t'
	menuGH = '|t25:25:esoui/art/journal/leaderboard_tabicon_home_up.dds|t'
	--menuGD = '|t25:25:esoui/art/contacts/tabicon_friends_up.dds|t'
	GDscl = '|t25:25:esoui/art/chatwindow/chat_friendsonline_up.dds|t'
	GDtrd = '|t25:25:esoui/art/tradinghouse/tradinghouse_sell_tabicon_up.dds|t'
	ADD = '|t25:25:esoui/art/progression/addpoints_up.dds|t'
	Discord = '|t25:25:esoui/art/help/help_tabicon_cs_disabled.dds|t'
	RUI = '|t25:25:esoui/art/ava/ava_keepstatus_icon_collectionrate.dds|t'


		--Тултип
local function ShowTooltip(control)
		InitializeTooltip(InformationTooltip, control, TOPLEFT, 5, -10, BOTTOMRIGHT)
		InformationTooltip:AddLine(""..CRN.."|cBFBC99PRIDE MENU|r"..CRN.."")
		InformationTooltip:AddVerticalPadding(-15)
		InformationTooltip:AddLine(""..dvd.."")
		InformationTooltip:AddVerticalPadding(-10)
		InformationTooltip:AddLine(""..lmb.."|cBFBC99Меню|r\n"..rmb.."|cBFBC99Мой дом|r")
    end  
local function HideTooltip(control)
		ClearTooltip(InformationTooltip)
    end
		
		--Меню
local function PGH_Menu(control, button)
	if button == 1 then
		local entries = {
				{label = ""..menuGH.."Гильдхолл Прайда", callback = function() JumpToHouse("@Alex_Zi") end,},
				{label = "-", },
				{label = ""..menuGH.."Ремесленный дом Прайда", callback = function() JumpToHouse("@falc_on81") end, },
            }
		--local SubMenuWW = {
			--	{label = ""..menuGH.."Ремесленный дом Прайда", callback = function() JumpToHouse("@falc_on81") end, },
				
		--	}	
			
		--local SubMenuRA = {
			--	{label = ""..ADD.."Приветствие каджита", callback = function() ZO_LinkHandler_OnLinkClicked("|H1:guild:649984|hWay to warm sands|h", 1) end,},
			--	{label = "-", },
			--	{label = ""..Discord.."Прощание каджита", callback = function() RequestOpenUnsafeURL("https://discord.gg/Xbrwg52") end,},
			--	{label = "-", },
			--	{label = ""..Discord.."Фразы М'айка", callback = function() RequestOpenUnsafeURL("https://discord.gg/Xbrwg52") end,},
			--}
		local SubMenuPGH = {
				{label = ""..ADD.."TIGER'S", callback = function() ZO_LinkHandler_OnLinkClicked("|H1:guild:723658|hPRIDE-of-Tigers|h", 1) end,},
				{label = "-", },
				{label = ""..ADD.."LION'S", callback = function() ZO_LinkHandler_OnLinkClicked("|H1:guild:713166|hPRIDE-of-Lions|h", 1) end,},
				{label = "-", },
				{label = ""..Discord.."Наш Discord", callback = function() RequestOpenUnsafeURL(" https://discord.gg/HAX8gtDd9s ") end,},
				{label = "-", },
				--{label = ""..Discord.."Набор", callback = function() RequestOpenUnsafeURL("https://discord.gg/Xbrwg52") end,},
				--{label = "-", },
				--{label = ""..Discord.."Ссылка Discord", callback = function() RequestOpenUnsafeURL("https://discord.gg/Xbrwg52") end,},
			}
			ClearMenu()
			AddCustomSubMenuItem(""..menuGH.."ТЕЛЕПОРТ", entries)
			AddCustomMenuItem("-", function() end)
			--AddCustomSubMenuItem(""..GDscl.."Ремесленный дом Прайда", SubMenuWW)
			--AddCustomMenuItem("-", function() end)
			--AddCustomSubMenuItem(""..GDscl.."Чат", SubMenuRA)
			--AddCustomMenuItem("-", function() end)
			AddCustomSubMenuItem(""..GDscl.."PRIDE Guild's", SubMenuPGH)
			AddCustomMenuItem("-", function() end)
			AddCustomMenuItem(""..RUI.."ReloadUI", function() ReloadUI() end)
			ShowMenu()
	elseif button == 2 then
		RequestJumpToHouse(GetHousingPrimaryHouse())
	end
end

	if (addOnName ~= "PrideGuildhall") then return end
		
		--Развернуть чат
	RWbtn =  WINDOW_MANAGER:CreateControl("MaxPGH", ZO_ChatWindow, CT_BUTTON)
    RWbtn:SetDimensions(20, 20)
    RWbtn:SetAnchor(TOPLEFT, ZO_ChatOptionsSectionLabel, TOPLEFT, 0, 233)
   	RWbtn:SetHandler("OnMouseEnter", function(control) ShowTooltip(control) end)
    RWbtn:SetHandler("OnMouseExit", function(control) HideTooltip(control) end)
	RWbtn:SetNormalTexture("PrideGuildhall/imgs/Pride_logo.dds")
    RWbtn:SetPressedTexture("PrideGuildhall/imgs/Pride_logo.dds")
    RWbtn:SetMouseOverTexture("PrideGuildhall/imgs/Pride_logo.dds")
	RWbtn:SetHandler("OnMouseUp", function(control, button) PGH_Menu(control, button) end)
		
		--Свернуть чат
	RWbtnMin =  WINDOW_MANAGER:CreateControl("MinPGH", ZO_ChatWindowMinBar, CT_BUTTON)
    RWbtnMin:SetDimensions(25, 25)
    RWbtnMin:SetAnchor(TOPLEFT, ZO_ChatWindowMinBar, nil, 0, 233)
    RWbtnMin:SetHandler("OnMouseEnter", function(control) ShowTooltip(control) end)
	RWbtnMin:SetHandler("OnMouseExit", function(control) HideTooltip(control) end)
    RWbtnMin:SetNormalTexture("PrideGuildhall/imgs/Pride_logo.dds")
    RWbtnMin:SetPressedTexture("PrideGuildhall/imgs/Pride_logo.dds")
    RWbtnMin:SetMouseOverTexture("PrideGuildhall/imgs/Pride_logo.dds")
	RWbtnMin:SetHandler("OnMouseUp", function(control, button) PGH_Menu(control, button) end)
end


EVENT_MANAGER:RegisterForEvent("PrideGuildhallLoaded", EVENT_ADD_ON_LOADED, function(...) 	PrideGuildhall_Initialize(...) 	end)
EVENT_MANAGER:RegisterForEvent("PGH_Event", EVENT_ADD_ON_LOADED, OnAddOnLoaded)