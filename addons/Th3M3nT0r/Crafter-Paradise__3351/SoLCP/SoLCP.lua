SoLCP = {
	name = "SoLCP",
	Guilds = {
		[713576] = true,	--Spirits of the Lake
		[633582] = true,	--BeamMeUp-Four
		[699342] = false,	--Reserved
		[713814] = false,	--Reserved
		[638134] = false,	--Reserved
		[669786] = false,	--Reserved
		},
	Label = "GUILDHALL",
	LabelFont = "ZoFontWinH4",
	Position={TOP,nil,TOP,40,5},
	ButtonSize=36,
	Space=2,
}

local ButtonData={

[1]={
	tooltip="Crafter Paradise",
	house={"@Araphorn83", 47},
	icon="/esoui/art/icons/housing_volcanoisland.dds",
	},

}

local function MakeButton(control,num)
	local w,space=SoLCP.ButtonSize,SoLCP.Space
	local data=ButtonData[num]
	local name="ZO_GuildHome_SOLGH_Button"..num
	local button=_G[name] or WINDOW_MANAGER:CreateControl(name, control, CT_TEXTURE)
	button:SetDimensions(w,w)
	button:ClearAnchors()
	local shift=(128-(w+space)*#ButtonData)/2
	button:SetAnchor(TOPLEFT,control,TOPLEFT,shift+(w+space)*(num-1),18)
	button:SetHidden(false)
	button:SetTexture(data.icon)
	button:SetColor(.6,.57,.46,1)
	button:SetMouseEnabled(true)
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
	button:SetHandler("OnMouseDown", function(self)
		if data.house then
			if data.house[2] then
				JumpToSpecificHouse(data.house[1],data.house[2])
				d(MRR.."Hip Hip Hooray We're On Our Way!|r")
			else
				JumpToHouse(data.house[1])
				d(MRR.."Hip Hip Hooray We're On Our Way!|r")
			end
		end
		self:SetColor(.6,.57,.46,1)
	end)
end

local function UI_Init()
	local control=ZO_GuildHome_SOLGH or WINDOW_MANAGER:CreateControl("ZO_GuildHome_SOLGH", ZO_GuildHome, CT_CONTROL)
	local pos=SoLCP.Position
	control:SetDimensions(128,64)
	control:ClearAnchors()
	control:SetAnchor(pos[1],ZO_GuildHome,pos[3],pos[4],pos[5])
	control:SetHidden(false)

	local label=ZO_GuildHome_Label or WINDOW_MANAGER:CreateControl("ZO_GuildHome_Label", control, CT_LABEL)
	label:SetDimensions(128,20)
	label:ClearAnchors()
	label:SetAnchor(TOPLEFT,control,TOPLEFT,0,0)
	label:SetFont(SoLCP.LabelFont)
	label:SetColor(.9,.9,.8,1)
	label:SetHorizontalAlignment(1)
	label:SetVerticalAlignment(0)
	label:SetText(SoLCP.Label)
	label:SetHidden(false)

	for num in pairs(ButtonData) do
		MakeButton(control,num)
	end
end

		--Textures
	lmb = '|t25:25:ESOUI/art/miscellaneous/icon_lmb.dds|t'
	rmb = '|t25:25:ESOUI/art/miscellaneous/icon_rmb.dds|t'
	dvd = '|t200:2:esoui/art/ava/ava_seigecontrols_divider.dds|t'
	CRN = '|t25:25:esoui/art/icons/guildranks/guild_indexicon_misc01_up.dds|t'
	menuGH = '|t25:25:esoui/art/journal/leaderboard_tabicon_home_up.dds|t'
	GDscl = '|t25:25:esoui/art/chatwindow/chat_friendsonline_up.dds|t'
	GDtrd = '|t25:25:esoui/art/tradinghouse/tradinghouse_sell_tabicon_up.dds|t'
	GDpvp = '|t25:25:esoui/art/hud/gamepad/gp_radialicon_duel_disabled.dds|t'
			--/esoui/art/hud/radialicon_duel_disabled.dds
	ADD = '|t25:25:esoui/art/progression/addpoints_up.dds|t'
	Discord = '|t25:25:esoui/art/help/help_tabicon_cs_disabled.dds|t'
	RUI = '|t25:25:esoui/art/ava/ava_keepstatus_icon_collectionrate.dds|t'
	GDB = '|t25:25:esoui/art/contacts/gamepad/gp_social_status_dnd.dds|t'
	QST = '|t25:25:esoui/art/help/help_tabicon_questassistance_up.dds|t'
	RCH = '|t25:25:esoui/art/tutorial/gamepad/gp_journalcheck.dds|t'
			--/esoui/art/hud/gamepad/gp_radialicon_accept_down.dds
	GT = '|t25:25:esoui/art/contacts/tabicon_friends_up.dds|t'
	WSr = '|t25:25:esoui/art/icons/poi/poi_wayshrine_complete.dds|t'
	WCity = '|t25:25:esoui/art/icons/poi/poi_city_complete.dds|t'
	GCN = '|t20:20:esoui/art/loot/icon_goldcoin_pressed.dds|t'
		--Name
	MRR = '|c5c73ed[|t25:25:esoui/art/icons/justice_stolen_mirror_001.dds|t]|r: |cb8dbdd'
	--|cb8dbdd
	--|c0de3fc
	
		--Location
	LocGrahtwood	=	'|cffdb58Grahtwood|r'
	LocStormhaven	=	'|c02729bStormhaven|r'
	LocDeshaan		=	'|cb2341fDeshaan|r'
			-----
	LocCraglorn		=	'|cbfbc99Craglorn|r'
	LocCHarbour		=	'|cbfbc99Coldharbour|r'
			-----
	LocVvardenfell	=	'|cb58e49Vvardenfell|r'
	LocSummerset	=	'|cb58e49Summerset|r'
	LocNortEls		=	'|cb58e49Northern Elsweyr|r'
	LocWestSky		=	'|cb58e49Western Skyrim|r'
	LocBlWood		=	'|cb58e49Blackwood|r'
	
		--City
	CityEldenRoot	=	'|cffdb58Elden Root|r'
	CityWayrest		=	'|c02729bWayrest|r'
	CityMournhold	=	'|cb2341fMournhold|r'
			-----
	CityBelkarth	=	'|cbfbc99Belkarth|r'
    CityHollowCity	=	'|cbfbc99Hollow City|r'
			-----
	CityVivec		=	'|cb58e49Vivec|r'
	CityAlinor		=	'|cb58e49Alinor|r'
	CityRimmen		=	'|cb58e49Rimmen|r'
	CitySolitude	=	'|cb58e49Solitude|r'
	CityLeyawiin	=	'|cb58e49Leyawiin|r'
	
	
	
function SoLCP:InitializeChatButton()
		--Tooltip
local function ShowTooltip(control)
		InitializeTooltip(InformationTooltip, control, TOPLEFT, 5, -10, BOTTOMRIGHT)
		InformationTooltip:AddLine(""..CRN.."|cBFBC99Spirits of the Lake aka [SoL]|r"..CRN.."")
		InformationTooltip:AddVerticalPadding(-15)
		InformationTooltip:AddLine(""..dvd.."")
		InformationTooltip:AddVerticalPadding(-10)
		InformationTooltip:AddLine(""..lmb.."|cBFBC99Menu|r"..rmb.."|cBFBC99Community|r")
    end  
local function HideTooltip(control)
		ClearTooltip(InformationTooltip)
    end
	
		--Меню
local function SOL_Menu(control, button)
	if button == 2 then

		local SubMenuSOL = {
				{label = ""..ADD.."Join ENG Guild", callback = function() ZO_LinkHandler_OnLinkClicked("|H1:guild:713576|hSpirits of the Lake|h", 1) end,},
				{label = "-", },
				{label = ""..Discord.."Discord", callback = function() RequestOpenUnsafeURL("https://discord.gg/KUUF5c8dpn") end,},
			}
		local SubMenuBM = {
				{label = ""..ADD.."Join ENG Guild", callback = function() ZO_LinkHandler_OnLinkClicked("|H1:guild:633582|hBeamMeUp-Four|h", 1) end,},
				{label = "-", },
				{label = ""..Discord.."Discord", callback = function() RequestOpenUnsafeURL("https://discord.gg/FRHd9wS74v") end,},
			}
		local SubMenuML = {
				{label = ""..ADD.."Join RU Guild", callback = function() ZO_LinkHandler_OnLinkClicked("|H1:guild:600784|hMirrorLand|h", 1) end,},
				{label = "-", },
				{label = ""..Discord.."Discord", callback = function() RequestOpenUnsafeURL("https://discord.gg/fwKtUFX") end,},
			}
		local SubMenuFG = {
				{label = ""..ADD.."Join GER Guild", callback = function() ZO_LinkHandler_OnLinkClicked("|H1:guild:405474|hFelsgold|h", 1) end,},
				{label = "-", },
				--{label = ""..Discord.."Discord", callback = function() RequestOpenUnsafeURL("https://discord.gg/KUUF5c8dpn") end,},
			}
		--local SubMenuR2 = {
				--{label = ""..ADD.."Join Guild", callback = function() ZO_LinkHandler_OnLinkClicked("|H1:guild:713576|hSpirits of the Lake|h", 1) end,},
				--{label = "-", },
				--{label = ""..Discord.."Discord", callback = function() RequestOpenUnsafeURL("https://discord.gg/KUUF5c8dpn") end,},
			--}
		--local SubMenuR3 = {
				--{label = ""..ADD.."Join Guild", callback = function() ZO_LinkHandler_OnLinkClicked("|H1:guild:713576|hSpirits of the Lake|h", 1) end,},
				--{label = "-", },
				--{label = ""..Discord.."Discord", callback = function() RequestOpenUnsafeURL("https://discord.gg/KUUF5c8dpn") end,},
			--}
			ClearMenu()
			AddCustomSubMenuItem(""..GDscl.."|cffe729Spirits of the Lake|r", SubMenuSOL)
			AddCustomSubMenuItem(""..GDscl.."|c11adf5BeamMeUp|r-|cffb33dFour|r", SubMenuBM)
			AddCustomSubMenuItem(""..GDscl.."|cb58e49MirrorLand|r", SubMenuML)
			AddCustomSubMenuItem(""..GDscl.."|cf5d549Felsgold|r", SubMenuFG)
			--AddCustomSubMenuItem(""..GDtrd.."Th3M3nT0r Home", SubMenuR2)
			--AddCustomSubMenuItem(""..GDtrd.."Th3M3nT0r Home", SubMenuR3)
			ShowMenu()
	elseif button == 1 then
		local entries = {
				
				{label = ""..menuGH.."|cf27107Flying Dutchman|r", callback = function() SoLCP:PortToHouse("@tïm'99", 60) end, },
				{label = "-", },
				{label = ""..menuGH.."|c4e9af2Snowy Mountains|r", callback = function() SoLCP:PortToHouse("@Lausebengel", 54) end, },
				{label = "-", },
				{label = ""..menuGH.."|cf2bf07Araphorn's Den|r", callback = function() SoLCP:PortToHouse("@Araphorn83", 71) end, },
				{label = "-", },
				{label = ""..menuGH.."|cb58e49Beach Resort|r", callback = function() SoLCP:PortToHouse("@Mirror_Cat", 40) end, },
				{label = "-", },
				{label = ""..menuGH.."|c67a9f5Fishing village|r", callback = function() SoLCP:PortToHouse("@Akay13", 40) end, },
				{label = "-", },	
				{label = ""..menuGH.."Hidden grotto", callback = function() SoLCP:PortToHouse("@Heynrich1976", 41) end, },
			--	{label = "-", },
			--	{label = ""..menuGH.."@Araphorn's Den", callback = function() SoLCP:PortToHouse("@Araphorn83", 71) end, },
			--	{label = "-", },
			--	{label = ""..menuGH.."@Araphorn's Den", callback = function() SoLCP:PortToHouse("@Araphorn83", 71) end, },
			--	{label = "-", },
			--	{label = ""..menuGH.."@Araphorn's Den", callback = function() SoLCP:PortToHouse("@Araphorn83", 71) end, },
			--	{label = "-", },
				
	        }
		local SOLGroupMenu = {
				{label = ""..CRN.."To the Crown", callback = function() d(MRR.."Flew to crown!|r") JumpToGroupLeader() end,},
				{label = ""..QST.."Share quests", callback = function() SoLCP.ShareAllDailies() end,},
				{label = "-", },
				{label = ""..GDB.."|c880000Leave group|r", callback = function() GroupLeave() end,},
			}
		local SOLGroupMenuGL = {
				{label = ""..RCH.."Ready check", callback = function() d(MRR.."ALL READY?!|r") ZO_SendReadyCheck() end, },
				{label = ""..QST.."Share quests", callback = function() SoLCP.ShareAllDailies() end,},
				{label = "-", },
				{label = ""..GDB.."|c880000Leave group|r", callback = function() GroupLeave() end,},
				{label = ""..GDB.."|c880000Group Disband|r", callback = function() GroupDisband() end, }, 
			}
		local SOLLocMenu = {
				{label = ""..WSr..""..LocGrahtwood.."", callback = function() 	SoLCP.Teleport(180) end, },		--Grahtwood
				{label = ""..WSr..""..LocStormhaven.."", callback = function() 	SoLCP.Teleport(4) end, },		--Стормхейвен
				{label = ""..WSr..""..LocDeshaan.."", callback = function() 	SoLCP.Teleport(10) end, },		--Deshaan
				{label = "-", },
				{label = ""..WSr..""..LocCraglorn.."", callback = function() 	SoLCP.Teleport(500) end, },		--Craglorn
				{label = ""..WSr..""..LocCHarbour.."", callback = function() 	SoLCP.Teleport(154) end, },		--Coldharbour
				{label = "-", }, 
				{label = ""..WSr..""..LocVvardenfell.."", callback = function() SoLCP.Teleport(467) end, },		--Vvardenfell
				{label = ""..WSr..""..LocSummerset.."", callback = function() 	SoLCP.Teleport(616) end, },		--Summerset
				{label = ""..WSr..""..LocNortEls.."", callback = function() 	SoLCP.Teleport(681) end, },		--Northern Elsweyr
				{label = ""..WSr..""..LocWestSky.."", callback = function() 	SoLCP.Teleport(743) end, },		--Western Skyrim
				{label = ""..WSr..""..LocBlWood.."", callback = function() 		SoLCP.Teleport(834) end, },		--BlackWood
			}
		local SOLCityMenu = {
				{label = ""..WCity..""..CityEldenRoot.."", callback = function() 	SoLCP.CityTeleport(214) end, },	--EldenRoot
				{label = ""..WCity..""..CityWayrest.."", callback = function() 	SoLCP.CityTeleport(56) end, },	--Wayrest
				{label = ""..WCity..""..CityMournhold.."", callback = function() 	SoLCP.CityTeleport(28) end, },	--Mournhold
				{label = "-", },                                                                                                                  
				{label = ""..WCity..""..CityBelkarth.."", callback = function() 	SoLCP.CityTeleport(220) end, },	--Belkarth
				{label = ""..WCity..""..CityHollowCity.."", callback = function() SoLCP.CityTeleport(131) end, }, 	--HollowCity
				{label = "-", },                                                                                                                  
				{label = ""..WCity..""..CityVivec.."", callback = function() 		SoLCP.CityTeleport(284) end, },	--Vivec
				{label = ""..WCity..""..CityAlinor.."", callback = function() 	SoLCP.CityTeleport(355) end, },	--Alinor
				{label = ""..WCity..""..CityRimmen.."", callback = function() 	SoLCP.CityTeleport(382) end, },	--Rimmen
				{label = ""..WCity..""..CitySolitude.."", callback = function() 	SoLCP.CityTeleport(421) end, },	--Solitude
				{label = ""..WCity..""..CityLeyawiin.."", callback = function() 	SoLCP.CityTeleport(458) end, },	--Leyawiin
			}
			ClearMenu()
			AddCustomMenuItem(""..menuGH.."Home", function() d(MRR.."Home, sweet home.|r") RequestJumpToHouse(GetHousingPrimaryHouse()) end)
			AddCustomMenuItem("-", function() end)
			AddCustomSubMenuItem(""..menuGH.."GuildHalls", entries)
			if (IsUnitGrouped("player")) then
				AddCustomMenuItem("-", function() end)
				if not (IsUnitGroupLeader("player")) then
					AddCustomSubMenuItem(""..GT.."Group.Menu", SOLGroupMenu)
				else
					AddCustomSubMenuItem(""..GT.."Group.Menu", SOLGroupMenuGL)
				end
			end
			AddCustomMenuItem("-", function() end)
			AddCustomSubMenuItem(""..WSr.."Location", SOLLocMenu)
			AddCustomSubMenuItem(""..WCity.."City |cffffff"..GetRecallCost(node).."|r"..GCN.."", SOLCityMenu)
			AddCustomMenuItem("-", function() end)
			AddCustomMenuItem(""..RUI.."ReloadUI", function() ReloadUI() end)
			ShowMenu()
		end
end

		--Open chat window button
	MLbtn =  WINDOW_MANAGER:CreateControl("MaxSOLGH", ZO_ChatWindow, CT_BUTTON)
    MLbtn:SetDimensions(23, 23)
    MLbtn:SetAnchor(TOPLEFT, ZO_ChatOptionsSectionLabel, TOPLEFT, 200, 13)
   	MLbtn:SetHandler("OnMouseEnter", function(control) ShowTooltip(control) end)
    MLbtn:SetHandler("OnMouseExit", function(control) HideTooltip(control) end)
	MLbtn:SetNormalTexture("SoLCP/imgs/ML.dds")
    MLbtn:SetPressedTexture("SoLCP/imgs/ML.dds")
    MLbtn:SetMouseOverTexture("SoLCP/imgs/ML.dds")
	MLbtn:SetHandler("OnMouseUp", function(control, button) SOL_Menu(control, button) end)
		
		--Closed chat windows button
	MLbtnMin =  WINDOW_MANAGER:CreateControl("MinSOLGH", ZO_ChatWindowMinBar, CT_BUTTON)
    MLbtnMin:SetDimensions(23, 23)
    MLbtnMin:SetAnchor(TOPLEFT, ZO_ChatWindowMinBar, nil, 0, 423)
    MLbtnMin:SetHandler("OnMouseEnter", function(control) ShowTooltip(control) end)
	MLbtnMin:SetHandler("OnMouseExit", function(control) HideTooltip(control) end)
    MLbtnMin:SetNormalTexture("SoLCP/imgs/ML.dds")
    MLbtnMin:SetPressedTexture("SoLCP/imgs/ML.dds")
    MLbtnMin:SetMouseOverTexture("SoLCP/imgs/ML.dds")
	MLbtnMin:SetHandler("OnMouseUp", function(control, button) SOL_Menu(control, button) end)
end

		--GH owners FIX
function SoLCP:PortToHouse(name, houseId)
    if (GetDisplayName() == name) then
        RequestJumpToHouse(houseId)
		 d(MRR.."Let me show you this paradise!|r")
    else
        JumpToSpecificHouse(name, houseId)
		 d(MRR.."Hip Hip Hooray We're On Our Way|r")
    end
end

--------------------------------------------------------------------------------
		--Additional function
--------------------------------------------------------------------------------
		
		--Banker conversation
local bankScene = SCENE_MANAGER:GetScene("bank")
    bankScene:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_SHOWN then
            SoLCP.selectDeposit()
        end
    end)
		
function SoLCP.selectDeposit()
    ZO_MenuBar_SelectDescriptor(ZO_PlayerBankMenuBar, SI_BANK_DEPOSIT)
end	

		--Bag Space
function SoLCP.BagSpaceIndicator()
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
	bagSpaceLabel:SetText(GetNumBagUsedSlots(1)..'/'..GetBagSize(1))
	if GetBagSize(1) ==	GetNumBagUsedSlots(1) then
		bagSpaceLabel:SetColor(1,0,0,1)
	elseif (GetBagSize(1)-GetNumBagUsedSlots(1)) <= 10 then
		bagSpaceLabel:SetColor(1,0.9,0,1)
	else
		bagSpaceLabel:SetColor(1, 1, 1, 1)
	end
end	
		--Delete mail without confirm
ZO_PreHook(MAIL_INBOX, "Delete", function( self )
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
end)

        --Delete confirmation
ZO_PreHook("ZO_Dialogs_ShowPlatformDialog", function( ... )
	local name, data, textParams = ...
	if name == "CONFIRM_DESTROY_ITEM_PROMPT" then
		ZO_Dialogs_ShowPlatformDialog("DESTROY_ITEM_PROMPT", nil, textParams)
		return true
	end
end)

		--Auto replacment in gungeaons
function SoLCP.FindReplacement(eventCode)
	AcceptActivityFindReplacementNotification()
	d(MRR.."OPS N00b leave! Heh not big deal... Looking for replacment.|r")
end

		--Share daily quests
		function SoLCP.ShareAllDailies()
	local QZone=GetPlayerActiveZoneName()
	local quest_count = 0
    for i = 1, GetNumJournalQuests() do
		if GetJournalQuestRepeatType(i) == QUEST_REPEAT_DAILY and GetIsQuestSharable(i) then
			if string.find(GetJournalQuestLocationInfo(i), QZone) then
				ShareQuest(i)
				d(MRR.."Sharing quests: "..'"'..GetJournalQuestName(i)..'"'.."|r")
				quest_count=quest_count+1
			end
		end
end
    if quest_count==0 then
        d(MRR.."Nothing to share LoL!|r")
    end
    if quest_count>=1 then
        d(MRR.."Quests shared: "..quest_count.."|r")
    end
	StartChatInput("Quests shared: "..quest_count.."", CHAT_CHANNEL_PARTY)
end

		--Group Create!
local function OnGroupCreate(eventCode, memberCharacterName, memberDisplayName, isLocalPlayer)
    if not IsUnitGrouped("player") then return end
    if isLocalPlayer then
        local groupSize = GetGroupSize()
        if groupSize == 2 then
			if not (IsUnitGroupLeader("player")) then
				d(MRR.."That's right, the company is more fun!|r")
			else
				d(MRR.."That's right, the company is more fun! WOW, you're the BOSS!|r")
			end
        end
    end
end

		--Guests counting
function SoLCP.GotGuests(eventCode, newPopulation)
	local GCount = newPopulation-1
	local prevPop = CurHPop or 0
	CurHPop = newPopulation
	
	if 0 == newPopulation then
		return
	end
	
	if (GetCurrentHouseOwner()==GetUnitDisplayName("player")) and newPopulation > 0 then
		if newPopulation > prevPop then
			d(MRR.."Who are you m8? Guests in House: "..GCount..".|r")
		else
			d(MRR.."Hope you back soon m8! Guests in House: "..GCount..".|r")
		end
	end 
end

		--Teleport (from DailyHelper)
function SoLCP.Teleport(zone)
	local porting=false
	local SOLzoneIndex = zone
	local SOLzoneName
				-----ALLIANCES-----
	if SOLzoneIndex == 180 then
		SOLzoneName = LocGrahtwood
	elseif SOLzoneIndex == 4 then
		SOLzoneName = LocStormhaven
	elseif SOLzoneIndex == 10 then
		SOLzoneName = LocDeshaan
				-----NEUTRALS-----
	elseif SOLzoneIndex == 500 then
		SOLzoneName = LocCraglorn
	elseif SOLzoneIndex == 154 then
		SOLzoneName = LocCHarbour
				-----LEADS-----
	elseif SOLzoneIndex == 467 then
		SOLzoneName = LocVvardenfell
	elseif SOLzoneIndex == 616 then
		SOLzoneName = LocSummerset
	elseif SOLzoneIndex == 681 then
		SOLzoneName = LocNortEls
	elseif SOLzoneIndex == 743 then
		SOLzoneName = LocWestSky
	elseif SOLzoneIndex == 834 then
		SOLzoneName = LocBlWood
	end
		--TO Group check
	for p=1, GetGroupSize() do
		local pTag=GetGroupUnitTagByIndex(p)
		if GetUnitZoneIndex(pTag)==zone and CanJumpToGroupMember(pTag) and porting==false and GetUnitDisplayName(pTag)~=GetUnitDisplayName("player") then
			JumpToGroupMember(GetUnitName(pTag))
			d(MRR.."|r|c0de3fc"..GetUnitDisplayName(pTag).."|r|cb8dbdd, do you happen to know how we can get out of here? Just somewhere in|r "..SOLzoneName.."|cb8dbdd.|r")
			porting=true
			break
		end
	end
		--TP Friends check
	if porting == false then
		for f=1, GetNumFriends() do
			local CharInfo = {}
			CharInfo.displayName, CharInfo.Note, CharInfo.status, CharInfo.secsSinceLogoff = GetFriendInfo(f)
			CharInfo.hasCharacter, CharInfo.characterName, CharInfo.zoneName, CharInfo.classType, CharInfo.alliance, CharInfo.level, CharInfo.championRank, CharInfo.zoneId = GetFriendCharacterInfo(f)
			if CharInfo.status~=PLAYER_STATUS_OFFLINE and GetZoneIndex(CharInfo.zoneId)==zone and porting==false and CharInfo.displayName~=GetUnitDisplayName("player") then
				JumpToFriend(CharInfo.displayName)
				d(MRR.."|r|c0de3fc"..CharInfo.displayName.."|r|cb8dbdd, do you happen to know how we can get out of here? Just somewhere in|r "..SOLzoneName.."|cb8dbdd.|r")
				porting=true
				break
			end
		end
	end
		--TP Guild Check
	if porting == false then
		for g=1, GetNumGuilds() do
			for m=1, GetNumGuildMembers(GetGuildId(g)) do
				local CharInfo = {}
				CharInfo.displayName, CharInfo.Note, CharInfo.GuildMemberRankIndex, CharInfo.status, CharInfo.secsSinceLogoff = GetGuildMemberInfo(GetGuildId(g), m)
				CharInfo.hasCharacter, CharInfo.characterName, CharInfo.zoneName, CharInfo.classType, CharInfo.alliance, CharInfo.level, CharInfo.championRank, CharInfo.zoneId = GetGuildMemberCharacterInfo(GetGuildId(g), m)
				CharInfo.guildIndex = g
				if CharInfo.status~=PLAYER_STATUS_OFFLINE and GetZoneIndex(CharInfo.zoneId)==zone and porting==false and CharInfo.displayName~=GetUnitDisplayName("player") then
					JumpToGuildMember(CharInfo.displayName)
					d(MRR.."|r|c0de3fc"..CharInfo.displayName.."|r|cb8dbdd, do you happen to know how we can get out of here? Just somewhere in|r "..SOLzoneName.."|cb8dbdd.|r")
					porting=true
					break
				end
			end
		end
	end
		--No one here
	if porting == false then d(MRR.."I don't insist, but maybe you should think about expanding your social circle....|r") end
end

		--Teleport to cities
function SoLCP.CityTeleport(node)
	local SOLnodeID = node
	if HasCompletedFastTravelNodePOI(node) then 
				-----ALLIANCES-----
		if SOLnodeID == 214 then
			FastTravelToNode(214)
			d(MRR.."Do you know what madness is? Madness is to pay|r |cffffff"..GetRecallCost(node).."|r"..GCN.." |cb8dbddfor a flight to |r"..CityEldenRoot	.."|cb8dbdd.|r") --214
		elseif SOLnodeID == 56 then                                                                                                                             
			FastTravelToNode(56)                                                                                                                                
			d(MRR.."Do you know what madness is? Madness is to pay|r |cffffff"..GetRecallCost(node).."|r"..GCN.." |cb8dbddfor a flight to |r"..CityWayrest		.."|cb8dbdd.|r") --56
		elseif SOLnodeID == 28 then                                                                                                                             
			FastTravelToNode(28)                                                                                                                                
			d(MRR.."Do you know what madness is? Madness is to pay|r |cffffff"..GetRecallCost(node).."|r"..GCN.." |cb8dbddfor a flight to |r"..CityMournhold	.."|cb8dbdd.|r") --28
				-----NEUTRALS-----                                                                                                                              
		elseif SOLnodeID == 220 then                                                                                                                            
			FastTravelToNode(220)                                                                                                                               
			d(MRR.."Do you know what madness is? Madness is to pay|r |cffffff"..GetRecallCost(node).."|r"..GCN.." |cb8dbddfor a flight to |r"..CityBelkarth		.."|cb8dbdd.|r")
		elseif SOLnodeID == 131 then                                                                                                                            
			FastTravelToNode(131)                                                                                                                               
			d(MRR.."Do you know what madness is? Madness is to pay|r |cffffff"..GetRecallCost(node).."|r"..GCN.." |cb8dbddfor a flight to |r"..CityHollowCity	.."|cb8dbdd.|r")
				-----LEADS-----                                                                                                                                 
		elseif SOLnodeID == 284 then                                                                                                                            
			FastTravelToNode(284)                                                                                                                               
			d(MRR.."Do you know what madness is? Madness is to pay|r |cffffff"..GetRecallCost(node).."|r"..GCN.." |cb8dbddfor a flight to |r"..CityVivec		.."|cb8dbdd.|r")
		elseif SOLnodeID == 355 then                                                                                                                            
			FastTravelToNode(355)                                                                                                                               
			d(MRR.."Do you know what madness is? Madness is to pay|r |cffffff"..GetRecallCost(node).."|r"..GCN.." |cb8dbddfor a flight to |r"..CityAlinor		.."|cb8dbdd.|r")
		elseif SOLnodeID == 382 then                                                                                                                            
			FastTravelToNode(382)                                                                                                                               
			d(MRR.."Do you know what madness is? Madness is to pay|r |cffffff"..GetRecallCost(node).."|r"..GCN.." |cb8dbddfor a flight to |r"..CityRimmen		.."|cb8dbdd.|r")
		elseif SOLnodeID == 421 then                                                                                                                            
			FastTravelToNode(421)                                                                                                                               
			d(MRR.."Do you know what madness is? Madness is to pay|r |cffffff"..GetRecallCost(node).."|r"..GCN.." |cb8dbddfor a flight to |r"..CitySolitude		.."|cb8dbdd.|r")
		elseif SOLnodeID == 458 then                                                                                                                            
			FastTravelToNode(458)                                                                                                                               
			d(MRR.."Do you know what madness is? Madness is to pay|r |cffffff"..GetRecallCost(node).."|r"..GCN.." |cb8dbddfor a flight to |r"..CityLeyawiin		.."|cb8dbdd.|r")
		end
	--don't have the wayshrine
	elseif not HasCompletedFastTravelNodePOI(node) then 
		d(MRR.."I'm afraid to reach this sanctuary you have to go on your own feet...|r") 
	end
end

		--Initialize
local function HelloMessage()
	EVENT_MANAGER:UnregisterForEvent(SoLCP.name, EVENT_PLAYER_ACTIVATED)
	CHAT_ROUTER:AddSystemMessage(MRR.."Hey! Welcome to Crafter Paradise! Free Guild House AddOn!|r")
end

function SoLCP:Initialize()
	self:InitializeChatButton()
	self:BagSpaceIndicator()
	SLASH_COMMANDS["/rl"] = function() ReloadUI() end
	SLASH_COMMANDS["/leader"] = function() d(MRR.."Following CROWN!|r") JumpToGroupLeader() end
	--SLASH_COMMANDS["/villa"] = function() SoLCP:PortToHouse("@AniriMur", 70) end
	--SLASH_COMMANDS["/beach"] = function() SoLCP:PortToHouse("@AniriMur", 70) end
	--SLASH_COMMANDS["/estate"] = function() SoLCP:PortToHouse("@AniriMur", 70) end
	SLASH_COMMANDS["/h"] = function() d(MRR.."Home, sweet home.|r") RequestJumpToHouse(GetHousingPrimaryHouse()) end
end 
    
function SoLCP.OnAddOnLoaded(event, addon)
    if addon == SoLCP.name then
		--EVENT_MANAGER:RegisterForEvent(SoLCP.name, EVENT_GROUPING_TOOLS_FIND_REPLACEMENT_NOTIFICATION_NEW, SoLCP.FindReplacement)
		--EVENT_MANAGER:UnregisterForEvent(SoLCP.name, EVENT_ADD_ON_LOADED)
		EVENT_MANAGER:RegisterForEvent(SoLCP.name, EVENT_GROUP_MEMBER_JOINED, OnGroupCreate)
		EVENT_MANAGER:RegisterForEvent(SoLCP.name, EVENT_PLAYER_ACTIVATED, HelloMessage)
		EVENT_MANAGER:RegisterForEvent(SoLCP.name, EVENT_HOUSING_POPULATION_CHANGED, SoLCP.GotGuests)
		EVENT_MANAGER:RegisterForEvent(SoLCP.name, EVENT_MAIL_OPEN_MAILBOX, BagUpdateSpace)	
		EVENT_MANAGER:RegisterForEvent(SoLCP.name, EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS, BagUpdateSpace)
		EVENT_MANAGER:RegisterForEvent(SoLCP.name, EVENT_MAIL_SEND_SUCCESS, BagUpdateSpace)
        SoLCP:Initialize()
    end
	ZO_PreHookHandler(ZO_GuildHome,"OnEffectivelyShown",function()
		ZO_GuildHome_SOLGH:SetHidden(not SoLCP.Guilds[GUILD_SELECTOR.guildId])
	end)
	CALLBACK_MANAGER:RegisterCallback("OnGuildSelected",function()
		ZO_GuildHome_SOLGH:SetHidden(not SoLCP.Guilds[GUILD_SELECTOR.guildId])
	end)
	UI_Init()
end

--Auto Bank




EVENT_MANAGER:RegisterForEvent(SoLCP.name, EVENT_ADD_ON_LOADED, SoLCP.OnAddOnLoaded)