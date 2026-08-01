local AddonName="BanditsGuildhall"
local lang=GetCVar("language.2")
local Settings={
	Guilds={
		[34703]=true,	--Daggerfall Bandits
		[682246]=true,	--Bandits Clan
		[702600]=true,	--Bandits Lair
		[672070]=true,	--Bandits Force
		[726298]=true,	--Bandits Black Market
		[787442]=true,	--Bandits Elite
		[733236]=true,	--Bandits Shadow
		},
	Logo=true,
	Label={en="Guildhalls",ru="Гильдхоллы"},
	LabelFont="ZoFontWinH4",
	Position={TOP,nil,TOP,40,5},	--/script local control=ZO_GuildHome_BanditsGuildhall control:ClearAnchors() control:SetAnchor(TOP,nil,TOP,40,5)
	Vertical=false,
	ButtonSize=36,	--Max value: 100/[num of buttons] for vertical, 128/[num of buttons] for horisontal
	Space=2,
	Message=true,
	MessageText={en="Jump to ",ru="Перемещаемся в "},
}
local ButtonData={
[1]={
	tooltip={en="Main guildhall", ru="Аттестационный дом"},
	house={"@Elis.Dark-Wings",71},
	icon="/esoui/art/treeicons/gamepad/gp_tutorial_idexicon_ava.dds",
	},
[2]={
	tooltip={en="Crafting house", ru="Ремесленный дом"},
	house={"@Drowned_God",76},
	icon="esoui/art/treeicons/gamepad/gp_tutorial_idexicon_tradeskills.dds"
	},
[3]={
	tooltip={en="Fighting club arena", ru="Арена Бойцовского клуба"},
	house={"@Elis.Dark-Wings",66},
	icon="esoui/art/treeicons/gamepad/gp_tutorial_idexicon_magicweaponsarmor.dds"
	},
}

local function ScreenMessage(message,delay)
	if BUI and BUI.OnScreen then
		BUI.OnScreen.Message[11]=nil
		BUI.OnScreen.Notification(11,message,(not delay and SOUNDS.BOOK_ACQUIRED or nil),delay)
	else
		local messageParams=CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_MAJOR_TEXT, SOUNDS.BOOK_ACQUIRED)
		messageParams:SetText("|t42:42:/esoui/art/icons/mapkey/mapkey_wayshrine.dds|t "..message)
		CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
	end
end

local function MakeButton(control,num)
	local w,space=Settings.ButtonSize,Settings.Space
	local data=ButtonData[num]
	local name="ZO_GuildHome_BanditsGuildhall_Button"..num
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
			ScreenMessage((Settings.MessageText[lang] or Settings.MessageText.en)..tooltip,8000)
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
	local control=ZO_GuildHome_BanditsGuildhall or WINDOW_MANAGER:CreateControl("ZO_GuildHome_BanditsGuildhall", ZO_GuildHome, CT_CONTROL)
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
		local texture=ZO_GuildHome_BanditsLogo or WINDOW_MANAGER:CreateControl("ZO_GuildHome_BanditsLogo", control, CT_TEXTURE)
		texture:SetDimensions(64,64)
		texture:ClearAnchors()
		texture:SetAnchor(TOP,control,TOP,0,0)
		texture:SetTexture("/BanditsGuildhall/Bandits_logo.dds")
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
	EVENT_MANAGER:UnregisterForEvent("BGH_Event", EVENT_ADD_ON_LOADED)
--	BGH_Vars=ZO_SavedVars:NewAccountWide("BGH_Settings", 3, nil, Defaults)
	ZO_PreHookHandler(ZO_GuildHome,"OnEffectivelyShown",function()
		ZO_GuildHome_BanditsGuildhall:SetHidden(not Settings.Guilds[GUILD_SELECTOR.guildId])
	end)
--	ZO_PreHookHandler(ZO_GuildHome,'OnEffectivelyHidden',function() end)
	CALLBACK_MANAGER:RegisterCallback("OnGuildSelected",function()
		ZO_GuildHome_BanditsGuildhall:SetHidden(not Settings.Guilds[GUILD_SELECTOR.guildId])
	end)
	UI_Init()
end

EVENT_MANAGER:RegisterForEvent("BGH_Event", EVENT_ADD_ON_LOADED, OnAddOnLoaded)