local AddonName="ChatTabSelector"
local DisplayName="|c4B8BFEChat Tab Selector|r"
local AddonVersion=1.37
local PlayerAccName
local TimeZone
local CTS_Vars={}
local TargetZone
local WhisperChannel
local primaryHouse
local WorldContext_init,HousingContext_init,MapContext_init
local houseData={
	{name="Inn Room (15)",category=-1},
	{name=GetString(SI_LOCKQUALITY1).." (50)",category=.5},
	{name=GetString(SI_HOUSECATEGORYTYPE1).." (100)",category=1.5},
	{name=GetString(SI_HOUSECATEGORYTYPE2).." (200)",category=3.5},
	{name=GetString(SI_HOUSECATEGORYTYPE3).." (350)",category=6.5}
}
--local CTS_Zones={}
local Copy_Link="|c777777|Hignore:c_button:%d|h© |h|r"	--zo_iconFormat("", -10, 24).."|Hignore:c_button:%d|h. |h"..zo_iconFormat("/esoui/art/journal/journal_tabicon_cadwell_disabled.dds", 24, 24)
CTS	={
	GuildInfo={},
	Zones={},
	Guild_names={},
	}
local ZoneNames={
--[[
	["Alik'r Desert"]={},
	["Artaeum"]={},
	["Auridon"]={},
	["Bal Foyen"]={},
	["Bangkorai"]={},
	["Betnikh"]={},
	["Bleakrock Isle"]={},
	["Clockwork City"]={"Brass Fortress","Mechanical Fundament","Halls of Regulation","Everwound Wellspring","The Shadow Cleft"},
--		["Brass Fortress"]={},
	["Coldharbour"]={},
	["Craglorn"]={},
	["Deshaan"]={},
	["Eastmarch"]={},
	["Glenumbra"]={},
	["Gold Coast"]={},
	["Grahtwood"]={},
	["Greenshade"]={},
	["Hew's Bane"]={},
	["Khenarthi's Roost"]={},
	["Malabal Tor"]={},
	["Norg-Tzel"]={},
	["Reaper's March"]={},
	["Rivenspire"]={},
	["Shadowfen"]={},
	["Stonefalls"]={},
	["Stormhaven"]={},
	["Stros M'Kai"]={},
	["Summerset"]={},
	["Rift"]={},
	["Vvardenfell"]={},
	["Wrothgar"]={},
--]]
	}
local ZoneAlliance={
[1]=3,	--Glenumbra
[3]=3,	--Stormhaven
[4]=3,	--Rivenspire
[8]=2,	--Stonefalls
[9]=2,	--Deshaan
[10]=1,	--Malabal Tor
[13]=3,	--Bangkorai
[14]=2,	--Eastmach
[15]=2,	--Rift
[16]=3,	--Alikr
[17]=1,	--Greenshade
[18]=2,	--Shadowfen
[108]=2,	--Bleakrock Isle
[109]=2,	--Bal Foyen
[177]=1,	--Auridon
[178]=1,	--Reaper's March
[179]=1,	--Grahtwood
[303]=3,	--Stros M'Kai
[304]=3,	--Betnikh
[305]=1,	--Khenarthi's Roost
}
local AllianceColor={
[0]={.6,.57,.46,1},
[1]={.6,.6,.1,1},
[2]={.6,.1,.1,1},
[3]={.3,.3,.6,1}
}
local ZoneBlackList={
	[666]="Norg-Tzel",
	[0]="Tamriel",
	[0]="The Aurbis",
	[36]="Cyrodiil",
	[345]="Imperial City",
}
local ZoneChange={
--	[GetZoneNameByIndex(589)]=GetZoneNameByIndex(588),	--["Brass Fortress"]="Clockwork City"
	[GetZoneNameByIndex(744)]=GetZoneNameByIndex(743)..": Caverns",	--["Blackreach: Greymoor Caverns"]="Western Skyrim"
--	/script for i = 1, GetNumMaps() do local mapName,mapType,mapContentType,zoneId=GetMapInfo(i) d("["..zoneId.."] "..mapName) end
--	/script local index=GetCurrentMapZoneIndex() d(index.." "..GetZoneNameByIndex(index))
}
--	/script StartChatInput(GetMapName())
local Defaults={
	AutoChannel	=true,
	Channels	=7,
	Advanced	=true,
	TimeStamp	=false,
	Rank		=false,
	Alliance	=false,
	Level		=true,
	Class		=false,
	NameFormat	="@Accname",
	TabToChannel={"Zone","Party","Guild 1","Do nothing","Do nothing","Do nothing","Do nothing"},
	["Tamriel Traders Guild"]	="TTG",
	["Daggerfall Bandits"]		="Bandits",
	["Vanguard Bandits"]		="Vanguards",
	["Bandits Black Market"]	="BBM",
	["Daggerfall Traders Guild"]	="DTG",
	["The Traveling Merchant"]	="TTM",
	["Pact Veteran Trade"]		="PVT",
	Sounds	={
		[CHAT_CHANNEL_WHISPER]="Recipe_Learned",
		[CHAT_CHANNEL_PARTY]="No_Sound",
		},
	Alerts={},
	Teleporter=true,
	Remember=0,
	CopyText=false,
	Messages={},
	m_Index=0
	}
local CTS_Sounds={
	"No_Sound",
	"AllianceWarWindow_Open",
	"BG_CTF_FlagDropped_OwnTeam",
	"Quest_StepFailed",
	"Radial_Menu_Mouseover",
	"Dyeing_Undo_Changes",
	"Guild_Self_Joined",
	"Collectible_On_Cooldown",
	"Dyeing_Tool_Dye_Used",
	"Ability_NotEnoughStamina",
	"Enchanting_PotencyRune_Removed",
	"Champion_StarLocked",
	"Enchanting_AspectRune_Placed",
	"Book_Metal_Open",
	"Lockpicking_lockpick_contact",
	"Justice_GoldRemoved",
	"Guild_Self_Left",
	"Group_Open",
	"AlliancePoint_Transact",
	"Recipe_Learned",
	"Enchanting_EssenceRune_Placed",
	"Housing_PickupItem",
	"Provisioning_EntrySelected",
	"Lockpicking_start",
	"Note_Open",
	"Unlock_Value",
	"Housing_PlaceItem",
	"Retraiting_Start_Retrait",
	"PlayerMenu_EntryDisabled",
	"Tablet_Open",
	"Voice_Chat_Menu_Channel_Made_Active",
	}
local Guild_id_by_channel={
	[CHAT_CHANNEL_GUILD_1]		=1,
	[CHAT_CHANNEL_GUILD_2]		=2,
	[CHAT_CHANNEL_GUILD_3]		=3,
	[CHAT_CHANNEL_GUILD_4]		=4,
	[CHAT_CHANNEL_GUILD_5]		=5,
	[CHAT_CHANNEL_OFFICER_1]	=1,
	[CHAT_CHANNEL_OFFICER_2]	=2,
	[CHAT_CHANNEL_OFFICER_3]	=3,
	[CHAT_CHANNEL_OFFICER_4]	=4,
	[CHAT_CHANNEL_OFFICER_5]	=5,
	}
local Category_by_channel={
	[CHAT_CHANNEL_GUILD_1]=CHAT_CATEGORY_GUILD_1,
	[CHAT_CHANNEL_GUILD_2]=CHAT_CATEGORY_GUILD_2,
	[CHAT_CHANNEL_GUILD_3]=CHAT_CATEGORY_GUILD_3,
	[CHAT_CHANNEL_GUILD_4]=CHAT_CATEGORY_GUILD_4,
	[CHAT_CHANNEL_GUILD_5]=CHAT_CATEGORY_GUILD_5,
	[CHAT_CHANNEL_OFFICER_1]=CHAT_CATEGORY_OFFICER_1,
	[CHAT_CHANNEL_OFFICER_2]=CHAT_CATEGORY_OFFICER_2,
	[CHAT_CHANNEL_OFFICER_3]=CHAT_CATEGORY_OFFICER_3,
	[CHAT_CHANNEL_OFFICER_4]=CHAT_CATEGORY_OFFICER_4,
	[CHAT_CHANNEL_OFFICER_5]=CHAT_CATEGORY_OFFICER_5,
	[CHAT_CHANNEL_SAY]=CHAT_CATEGORY_SAY,
	[CHAT_CHANNEL_YELL]=CHAT_CATEGORY_YELL,
	[CHAT_CHANNEL_ZONE]=CHAT_CATEGORY_ZONE,
	[CHAT_CHANNEL_PARTY]=CHAT_CATEGORY_PARTY,
	[CHAT_CHANNEL_WHISPER_SENT]=CHAT_CATEGORY_WHISPER_OUTGOING,
	[CHAT_CHANNEL_WHISPER]=CHAT_CATEGORY_WHISPER_INCOMING,
	[CHAT_CHANNEL_EMOTE]=CHAT_CATEGORY_EMOTE,
	}
local ChannelName={
	[CHAT_CHANNEL_SAY]=GetString(SI_CHAT_CHANNEL_NAME_SAY),
	[CHAT_CHANNEL_YELL]=GetString(SI_CHAT_CHANNEL_NAME_YELL),
	[CHAT_CHANNEL_ZONE]=GetString(SI_CHAT_CHANNEL_NAME_ZONE),
	[CHAT_CHANNEL_PARTY]=GetString(SI_CHAT_CHANNEL_NAME_PARTY),
	[CHAT_CHANNEL_WHISPER]=GetString(SI_CHAT_CHANNEL_NAME_WHISPER),
	[CHAT_CHANNEL_EMOTE]=GetString(SI_CHAT_CHANNEL_NAME_EMOTE),
	}
local ChannelsMenu={"Guild 1","Guild 2","Guild 3","Guild 4","Guild 5","Officer 1","Officer 2","Officer 3","Officer 4","Officer 5","Say","Party","Yell","Zone","Zone en","Zone fr","Zone de","Do nothing"}
local ChannelsValue={
	["Whisper"]		=CHAT_CHANNEL_WHISPER,
	["System"]		=CHAT_CHANNEL_SYSTEM,
	["Guild 1"]		=CHAT_CHANNEL_GUILD_1,
	["Guild 2"]		=CHAT_CHANNEL_GUILD_2,
	["Guild 3"]		=CHAT_CHANNEL_GUILD_3,
	["Guild 4"]		=CHAT_CHANNEL_GUILD_4,
	["Guild 5"]		=CHAT_CHANNEL_GUILD_5,
	["Officer 1"]	=CHAT_CHANNEL_OFFICER_1,
	["Officer 2"]	=CHAT_CHANNEL_OFFICER_2,
	["Officer 3"]	=CHAT_CHANNEL_OFFICER_3,
	["Officer 4"]	=CHAT_CHANNEL_OFFICER_4,
	["Officer 5"]	=CHAT_CHANNEL_OFFICER_5,
	["Say"]		=CHAT_CHANNEL_SAY,
	["Party"]		=CHAT_CHANNEL_PARTY,
	["Yell"]		=CHAT_CHANNEL_YELL,
	["Zone"]		=CHAT_CHANNEL_ZONE,
	["Zone en"]		=CHAT_CHANNEL_ZONE_LANGUAGE_1,
	["Zone fr"]		=CHAT_CHANNEL_ZONE_LANGUAGE_2,
	["Zone de"]		=CHAT_CHANNEL_ZONE_LANGUAGE_3,
	["Zone ru"]		=CHAT_CHANNEL_ZONE_LANGUAGE_4,
	["Monster"]		=CHAT_CHANNEL_MONSTER_SAY,
	["Do nothing"]	=-1
	}
local JumpResults={
	[SOCIAL_RESULT_CHARACTER_NOT_FOUND]=1,
	[SOCIAL_RESULT_NOT_GROUPED]=1,
	[SOCIAL_RESULT_CANT_JUMP_SELF]=1,
	[SOCIAL_RESULT_NO_LOCATION]=1,
	[SOCIAL_RESULT_NOT_SAME_GROUP]=1,
	[SOCIAL_RESULT_WRONG_ALLIANCE]=1,
	[SOCIAL_RESULT_NOT_IN_SAME_GROUP]=1,
	[SOCIAL_RESULT_CANT_JUMP_INVALID_TARGET]=1,
	[SOCIAL_RESULT_DESTINATION_FULL]=true,
	[SOCIAL_RESULT_NO_JUMP_IN_COMBAT]=true,
	[SOCIAL_RESULT_JUMPS_EXIT_DISABLED]=true,
	[SOCIAL_RESULT_NO_JUMP_CHAMPION_RANK]=true,
	[SOCIAL_RESULT_JUMP_ENTRY_DISABLED]=true,
	[SOCIAL_RESULT_NO_INTRA_CAMPAIGN_JUMPS_ALLOWED]=true,
	[SOCIAL_RESULT_BEING_ARRESTED]=true,
	}
local AttemptedToJump={}

--Functions
function string:split(delimiter)
	local result={}
	local from=1
	local delim_from,delim_to=string.find(self,delimiter,from)
	while delim_from do
		table.insert(result,string.sub(self,from,delim_from-1))
		from=delim_to+1
		delim_from,delim_to=string.find(self,delimiter,from)
	end
	table.insert(result,string.sub(self,from))
	return result
end

local function ColorString(r,g,b)
	local rgb={math.min(r,1)*255, math.min(g,1)*255, math.min(b,1)*255}
	local hexstring=""
	for _,value in pairs(rgb) do
		local hex=""
		while value>0 do
			local index=math.fmod(value,16)+1
			value=math.floor(value/16)
			hex=string.sub("0123456789ABCDEF",index,index)..hex
		end
		if(string.len(hex)==0) then hex="00" elseif(string.len(hex)==1) then hex="0"..hex end
		hexstring=hexstring..hex
	end
	return "|c"..hexstring
end

local function ScreenMessage(message,timer)
--	if CTS_Vars.Message then
		if BUI and BUI.OnScreen then
			BUI.OnScreen.Message[11]=nil
			BUI.OnScreen.Notification(11,message,nil,timer)
		else
			local messageParams=CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_MAJOR_TEXT)
			messageParams:SetText("|t42:42:/esoui/art/icons/mapkey/mapkey_wayshrine.dds|t "..message)
			CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
		end
--	end
end

local function CheckZoneName(name)
	if ZoneChange[name] then name=ZoneChange[name]
--	elseif name=="Elsweyr" then name="Northern Elsweyr"
	else name=string.gsub(name,"The ","")
--	else name=string.gsub(string.gsub(name,"The ",""),"Northern ","")
	end
	return name
end

local function GetCurrentZoneName()
	return CheckZoneName(GetZoneNameByIndex(GetCurrentMapZoneIndex()))
end

--[[	--Sound selection
local function UI_Sounds()
	local SoundNames={}
	local sid,vid=0,0
	for id,name in pairs(SOUNDS) do sid=sid+1
		SoundNames[sid]=name
	end
	local total=sid
	sid=0

	local window=WINDOW_MANAGER:CreateTopLevelWindow("CTS_UI_Main")
	window:SetDimensions(200, 30)
	window:ClearAnchors()
	window:SetAnchor(CENTER,GuiRoot,CENTER,0,0)
	window:SetHidden(false)

	local button=WINDOW_MANAGER:CreateControl("CTS_UI_Next", CTS_UI_Main, CT_BUTTON)
	button:SetDimensions(100,30)
	button:ClearAnchors()
	button:SetAnchor(RIGHT,CTS_UI_Main,CENTER,0,0)
	button:SetFont("ZoFontWinT1")
	button:SetNormalFontColor(.8,.8,.8,1)
	button:SetMouseOverFontColor(1,1,1,1)
	button:SetHorizontalAlignment(1)
	button:SetVerticalAlignment(1)
	button:SetText("Next")
	button:SetState(BSTATE_NORMAL)
	button:SetHidden(false)
	button:SetHandler("OnClicked", function()
		sid=sid+1
		d("["..sid.."/"..total.."] "..SoundNames[sid])
		PlaySound(SoundNames[sid])
		end)

	button=WINDOW_MANAGER:CreateControl("CTS_UI_Save", CTS_UI_Main, CT_BUTTON)
	button:SetDimensions(100,30)
	button:ClearAnchors()
	button:SetAnchor(LEFT,CTS_UI_Main,CENTER,0,0)
	button:SetFont("ZoFontWinT1")
	button:SetNormalFontColor(.8,.8,.8,1)
	button:SetMouseOverFontColor(1,1,1,1)
	button:SetHorizontalAlignment(1)
	button:SetVerticalAlignment(1)
	button:SetText("Save")
	button:SetState(BSTATE_NORMAL)
	button:SetHidden(false)
	button:SetHandler("OnClicked", function() vid=vid+1 CTS_Vars.Alerts[vid]=SoundNames[sid] end)
end
--]]

--Guild info
local function SetGuildMemberInfo(guildId,accName,memberId,rank,guildName)
	memberId=memberId or GetGuildMemberIndexFromDisplayName(guildId,accName)
	if not rank then _,_,rank=GetGuildMemberInfo(guildId, memberId) end
	local _,charName,zoneName,class,alliance,level,championRank,zoneId=GetGuildMemberCharacterInfo(guildId, memberId)
	rank=zo_iconFormat(GetGuildRankSmallIcon(GetGuildRankIconIndex(guildId, rank)), 24, 24)
	class=class and GetClassIcon(class) or "" class=type(class)=="string" and zo_iconFormat(class, 24, 24) or ""
	zoneName=CheckZoneName(zoneName)
	if	championRank>809 then	level="|cffff33[cp"..championRank.."]|r"
	elseif	championRank>159 then	level="|cff33ff[cp"..championRank.."]|r"
	elseif	championRank>0 then level="|c7f7fff[cp"..championRank.."]|r"
	else	level="|c33ff33["..level.."]|r" end

	if CTS.GuildInfo[accName]==nil then CTS.GuildInfo[accName]={} end
	CTS.GuildInfo[accName].name=charName
	CTS.GuildInfo[accName].level=level
	CTS.GuildInfo[accName].rank=rank
	CTS.GuildInfo[accName].alliance=alliance
	CTS.GuildInfo[accName].class=class
	CTS.GuildInfo[accName].zone=zoneName
--	CTS_Zones[zoneName]=zoneId
	if guildName then
		if CTS.GuildInfo[accName].guild~=nil then CTS.GuildInfo[accName].guild[guildId]=guildName else CTS.GuildInfo[accName].guild={[guildId]=guildName} end
	else
		CTS.GuildInfo[accName].guild={}
		for i=1,GetNumGuilds() do
			if GetGuildMemberIndexFromDisplayName(i,accName) then
				CTS.GuildInfo[accName].guild[i]=GetGuildName(i)
			end
		end
	end
	if CTS.Zones[zoneName]~=nil and accName~=PlayerAccName then
		table.insert(CTS.Zones[zoneName],accName)
	end
end

local function ScanGuildInfo(channel,PlayerID)
	local _guild,_guilds
	if channel and Guild_id_by_channel[channel] then
		_guild=Guild_id_by_channel[channel] _guilds=Guild_id_by_channel[channel]
	else
		_guild=1 _guilds=GetNumGuilds()
		CTS.Zones={}
		for _,data in pairs(ZoneNames) do CTS.Zones[data.mapName]={} end
	end
	for i=_guild,_guilds do
		local guildId=GetGuildId(i)
		local guildName=GetGuildName(guildId)
		CTS.Guild_names[i]=guildName
		for memberId=1, GetNumGuildMembers(guildId) do
			local accName,_,rank,status=GetGuildMemberInfo(guildId, memberId)
			if status~=PLAYER_STATUS_OFFLINE then
				SetGuildMemberInfo(guildId,accName,memberId,rank,guildName)
			end
			if accName==PlayerID then return end
		end
	end
end

--Teleporter
local function JumpToZone()
	if CTS.Zones[TargetZone] and #CTS.Zones[TargetZone]>0 then
		ScreenMessage("Jump to "..TargetZone,8000)
		for _,accName in pairs(CTS.Zones[TargetZone]) do
			if not AttemptedToJump[accName] then
				AttemptedToJump[accName]=true
				EndInteraction(INTERACTION_FAST_TRAVEL)
				JumpToGuildMember(accName)
				return
			end
		end
	end
	ScreenMessage("Jump to "..TargetZone.." is |cEE2222failed|r ")
	TargetZone=nil
	AttemptedToJump={}
--	SetFrameLocalPlayerInGameCamera(false)
end

local function AttemptToJump(zone)
	if CTS.Zones[zone] and #CTS.Zones[zone]>0 then
--		SCENE_MANAGER:SetInUIMode(false)
		AttemptedToJump={}
		TargetZone=zone
--		SetFrameLocalPlayerInGameCamera(true) SetFrameLocalPlayerTarget(0.5, 0.65)
		PlaySound(SOUNDS.MAP_LOCATION_CLICKED)
		SCENE_MANAGER:ShowBaseScene()
		JumpToZone()
	end
end

local function UI_MapContext(parent)
	local playersData=CTS.Zones[parent.mapName]
	if not playersData or #playersData==0 then return end
	local panel=parent:GetParent()
	local w,h=320,20+20*#playersData
	local ui=CTS_Teleporter_MapContext or WINDOW_MANAGER:CreateControl("CTS_Teleporter_MapContext", panel, CT_CONTROL)
	ui:SetDimensions(w,h)
	ui:ClearAnchors()
	ui:SetAnchor(TOPLEFT,panel,TOPRIGHT,5,20*(parent.index-1))
	ui:SetHidden(false)
	panel.context=ui

	if not MapContext_init then
		ui:SetHandler("OnHide", function(self) for i=1,self:GetNumChildren() do self:GetChild(i):SetHidden(true) end end)
		ui.bg=WINDOW_MANAGER:CreateControl("CTS_Teleporter_MapContext_Bg", ui, CT_BACKDROP)
		ui.bg:ClearAnchors()
		ui.bg:SetAnchor(TOPLEFT,ui,TOPLEFT,0,0)
		ui.bg:SetAnchor(BOTTOMRIGHT,ui,BOTTOMRIGHT,0,0)
		ui.bg:SetCenterColor(0,0,0,1)
		ui.bg:SetEdgeColor(1,1,1,1)
		ui.bg:SetEdgeTexture("esoui/art/tooltips/ui-border.dds",128,16,16)	--esoui/art/interaction/conversationborder.dds
		ui.bg:SetDrawLayer(0)

		ui.select=WINDOW_MANAGER:CreateControl("CTS_Teleporter_MapContext_Select", ui, CT_BACKDROP)
		ui.select:SetDimensions(w-10,18)
		ui.select:ClearAnchors()
		ui.select:SetAnchor(TOPLEFT,ui,TOPLEFT,0,0)
		ui.select:SetCenterColor(1,1,1,.3)
		ui.select:SetEdgeColor(1,1,1,0)
		ui.select:SetHidden(true)
		ui.select:SetDrawLayer(1)
	end
	ui.bg:SetHidden(false)

	for i,accName in pairs (playersData) do
		local label=_G["CTS_Teleporter_MapContext_N"..i]
		local level=_G["CTS_Teleporter_MapContext_L"..i]
		local guild=_G["CTS_Teleporter_MapContext_G"..i]
		if not label then

			label=WINDOW_MANAGER:CreateControl("CTS_Teleporter_MapContext_N"..i, ui, CT_LABEL)
			label:SetDimensions(140,16)
			label:ClearAnchors()
			label:SetAnchor(TOPLEFT,ui,TOPLEFT,70,10+20*(i-1))
			label:SetFont("ZoFontWinH5")
			label:SetHorizontalAlignment(0)
			label:SetVerticalAlignment(0)
			label:SetMouseEnabled(true)
			label:SetHandler("OnMouseEnter", function(self)
				self:SetColor(self.color[1]+.2,self.color[2]+.2,self.color[3]+.2,1)
				ui.select:ClearAnchors()
				ui.select:SetAnchor(TOPLEFT,self,TOPLEFT,-65,2)
				ui.select:SetHidden(false)
			end)
			label:SetHandler("OnMouseExit", function(self)
				self:SetColor(unpack(self.color))
				ui.select:SetHidden(true)
			end)
			label:SetHandler("OnMouseDown", function(self)
				panel:SetHidden(true)
--				SCENE_MANAGER:SetInUIMode(false)
				ScreenMessage("Jump to "..self.accName,8000)
				JumpToGuildMember(self.accName)
			end)

			level=WINDOW_MANAGER:CreateControl("CTS_Teleporter_MapContext_L"..i, label, CT_LABEL)
			level:SetDimensions(60,16)
			level:ClearAnchors()
			level:SetAnchor(TOPLEFT,ui,TOPLEFT,10,10+20*(i-1))
			level:SetFont("ZoFontWinH5")
			level:SetHorizontalAlignment(0)
			level:SetVerticalAlignment(0)
			level:SetAlpha(.6)

			guild=WINDOW_MANAGER:CreateControl("CTS_Teleporter_MapContext_G"..i, label, CT_LABEL)
			guild:SetDimensions(100,16)
			guild:ClearAnchors()
			guild:SetAnchor(TOPLEFT,ui,TOPLEFT,210,10+20*(i-1))
			guild:SetFont("ZoFontWinH5")
			guild:SetHorizontalAlignment(0)
			guild:SetVerticalAlignment(0)
			guild:SetColor(AllianceColor[0][1],AllianceColor[0][2],AllianceColor[0][3],.8)
		end
		local data=CTS.GuildInfo[accName] or {}
		label.color=AllianceColor[data.alliance or 0]
		label:SetColor(unpack(label.color))
		label.accName=accName
		label:SetText(accName)
		label:SetHidden(false)
		level:SetText(data.level or "")
		local guildNames=""
		if data.guild then
			for _,name in pairs(data.guild) do
				if CTS_Vars[name] then name=CTS_Vars[name] end
				guildNames=guildNames..(guildNames=="" and "" or "/")..name
			end
		end
		guild:SetText(guildNames)
	end
	MapContext_init=true
	return ui
end

local function UI_WorldContext(parent)
	local w,h=180,20+20*#ZoneNames
	local ui=CTS_Teleporter_WorldContext
	local current=GetCurrentZoneName()
	if not WorldContext_init then
		local panel=parent:GetParent()
		ui=WINDOW_MANAGER:CreateControl("CTS_Teleporter_WorldContext", panel, CT_CONTROL)
		ui:SetDimensions(w,h)
		ui:ClearAnchors()
		ui:SetAnchor(BOTTOMLEFT,panel,BOTTOMRIGHT,10,0)
		ui:SetHandler("OnHide", function(self) if self.context then self.context:SetHidden(true) end end)

		ui.bg=WINDOW_MANAGER:CreateControl("CTS_Teleporter_WorldContext_Bg", ui, CT_BACKDROP)
		ui.bg:ClearAnchors()
		ui.bg:SetAnchor(TOPLEFT,ui,TOPLEFT,0,0)
		ui.bg:SetAnchor(BOTTOMRIGHT,ui,BOTTOMRIGHT,0,0)
		ui.bg:SetCenterColor(0,0,0,1)
		ui.bg:SetEdgeColor(1,1,1,1)
		ui.bg:SetEdgeTexture("esoui/art/tooltips/ui-border.dds",128,16,16)	--esoui/art/interaction/conversationborder.dds
		ui.bg:SetDrawLayer(0)

		ui.select=WINDOW_MANAGER:CreateControl("CTS_Teleporter_WorldContext_Select", ui, CT_BACKDROP)
		ui.select:SetDimensions(w-10,18)
		ui.select:ClearAnchors()
		ui.select:SetAnchor(TOPLEFT,ui,TOPLEFT,0,0)
		ui.select:SetCenterColor(1,1,1,.3)
		ui.select:SetEdgeColor(1,1,1,0)
		ui.select:SetDrawLayer(1)
	end
	ui:SetHidden(false)

	for i,data in pairs (ZoneNames) do
		local label=_G["CTS_Teleporter_WorldContext_N"..i]
		local count=_G["CTS_Teleporter_WorldContext_C"..i]
		if not WorldContext_init then
			label=WINDOW_MANAGER:CreateControl("CTS_Teleporter_WorldContext_N"..i, ui, CT_LABEL)
			label:SetDimensions(w-52,16)
			label:ClearAnchors()
			label:SetAnchor(TOPLEFT,ui,TOPLEFT,10,10+20*(i-1))
			label:SetFont("ZoFontWinH5")
			label:SetHorizontalAlignment(0)
			label:SetVerticalAlignment(0)
			label:SetMouseEnabled(true)
			label:SetText(data.mapName)
			label.mapName=data.mapName
			label.color=AllianceColor[ZoneAlliance[data.zoneId] or 0]
			label.index=i
			label:SetColor(unpack(label.color))
			label:SetHandler("OnMouseEnter", function(self)
--				if current==self.mapName then self:SetColor(AllianceColor[4][1]+.2,AllianceColor[4][2]+.2,AllianceColor[4][3]+.2,1) else self:SetColor(self.color[1]+.2,self.color[2]+.2,self.color[3]+.2,1) end
				self:SetColor(self.color[1]+.2,self.color[2]+.2,self.color[3]+.2,1)
				ui.select:ClearAnchors()
				ui.select:SetAnchor(TOPLEFT,self,TOPLEFT,-5,2)
				ui.select:SetHidden(false)
				if ui.context then ui.context:SetHidden(true) end
				UI_MapContext(self)
			end)
			label:SetHandler("OnMouseExit", function(self)
--				if current==self.mapName then self:SetColor(unpack(AllianceColor[4])) else self:SetColor(unpack(self.color)) end
				self:SetColor(unpack(self.color))
--				ui.select:SetHidden(true)
			end)
			label:SetHandler("OnMouseDown", function(self) self:GetParent():SetHidden(true) AttemptToJump(self.mapName) end)

			count=WINDOW_MANAGER:CreateControl("CTS_Teleporter_WorldContext_C"..i, ui, CT_LABEL)
			count:SetDimensions(32,16)
			count:ClearAnchors()
			count:SetAnchor(TOPRIGHT,ui,TOPRIGHT,-10,10+20*(i-1))
			count:SetFont("ZoFontWinH5")
			count:SetColor(.6,.57,.46,1)
			count:SetHorizontalAlignment(2)
			count:SetVerticalAlignment(0)
		end
		local players=CTS.Zones[data.mapName] and #CTS.Zones[data.mapName]>0 and tostring(#CTS.Zones[data.mapName]) or "|cCC22220|r"
		count:SetText(players)
		label:SetText((current==data.mapName and "> " or "")..data.mapName)
--		if current==data.mapName then label:SetColor(unpack(AllianceColor[4])) else label:SetColor(unpack(label.color)) end
	end
	ui.select:SetHidden(true)
	WorldContext_init=true
	return ui
end

local function HouseDataUpdate()
	if #houseData<=5 then
		if #WORLD_MAP_HOUSES_DATA.houseMapData==0 then WORLD_MAP_HOUSES_DATA:RefreshHouseList() end
		for i,data in pairs(WORLD_MAP_HOUSES_DATA.houseMapData) do
			if data.unlocked then
--				d("["..GetHouseCategoryType(data.houseId).."] "..data.houseName.." ("..data.foundInZoneName..")")
				table.insert(houseData,{id=data.houseId, category=math.floor(GetHouseFurnishingPlacementLimit(data.houseId)/50), name=data.houseName, zone=data.foundInZoneName})
			end
		end
		if #houseData>0 then table.sort(houseData,function(a,b) return a.category<b.category end) end
	end
end

local function UI_HousingContext(parent)
	HouseDataUpdate()
	local w,h=330+20,20+20*#houseData
	local lastCategory=0
	local ui=CTS_Teleporter_HousingContext
	if not HousingContext_init then
		local panel=parent:GetParent()
		ui=WINDOW_MANAGER:CreateControl("CTS_Teleporter_HousingContext", panel, CT_CONTROL)
		ui:SetDimensions(w,h)
		ui:ClearAnchors()
		ui:SetAnchor(BOTTOMLEFT,panel,BOTTOMRIGHT,10,0)

		ui.bg=WINDOW_MANAGER:CreateControl("CTS_Teleporter_HousingContext_Bg", ui, CT_BACKDROP)
		ui.bg:ClearAnchors()
		ui.bg:SetAnchor(TOPLEFT,ui,TOPLEFT,0,0)
		ui.bg:SetAnchor(BOTTOMRIGHT,ui,BOTTOMRIGHT,0,0)
		ui.bg:SetCenterColor(0,0,0,1)
		ui.bg:SetEdgeColor(1,1,1,1)
		ui.bg:SetEdgeTexture("esoui/art/tooltips/ui-border.dds",128,16,16)	--esoui/art/interaction/conversationborder.dds
		ui.bg:SetDrawLayer(0)

		ui.select=WINDOW_MANAGER:CreateControl("CTS_Teleporter_HousingContext_Select", ui, CT_BACKDROP)
		ui.select:SetDimensions(w-10,18)
		ui.select:ClearAnchors()
		ui.select:SetAnchor(TOPLEFT,ui,TOPLEFT,0,0)
		ui.select:SetCenterColor(1,1,1,.3)
		ui.select:SetEdgeColor(1,1,1,0)
		ui.select:SetHidden(true)
		ui.select:SetDrawLayer(1)
	end
	ui:SetHidden(false)

	for i,data in pairs (houseData) do
		local label=_G["CTS_Teleporter_HousingContext_N"..i]
		local count=_G["CTS_Teleporter_HousingContext_C"..i]
		if not HousingContext_init then
			label=WINDOW_MANAGER:CreateControl("CTS_Teleporter_HousingContext_N"..i, ui, CT_LABEL)
			label:SetDimensions(210,16)
			label:ClearAnchors()
			label:SetAnchor(TOPLEFT,ui,TOPLEFT,10,10+20*(i-1))
			label:SetFont("ZoFontWinH5")
			label:SetHorizontalAlignment(0)
			label:SetVerticalAlignment(0)
			if data.id then
				label:SetText(data.name)
				label.color=data.id==primaryHouse and {.8,.8,.2,1} or {.6,.57,.46,1}
				label.hcolor=data.id==primaryHouse and {.9,.9,.6,1} or {.9,.9,.8,1}
				label:SetColor(unpack(label.color))
				label.id=data.id
				label.name=data.name
				label:SetMouseEnabled(true)
				label:SetHandler("OnMouseEnter", function(self)
					self:SetColor(unpack(self.hcolor))
					ui.select:ClearAnchors()
					ui.select:SetAnchor(TOPLEFT,self,TOPLEFT,-5,2)
					ui.select:SetHidden(false)
				end)
				label:SetHandler("OnMouseExit", function(self)
					self:SetColor(unpack(self.color))
					ui.select:SetHidden(true)
				end)
				label:SetHandler("OnMouseDown", function(self)
					self:GetParent():SetHidden(true)
--					SCENE_MANAGER:SetInUIMode(false)
					ScreenMessage("Jump to "..self.name,8000)
					RequestJumpToHouse(self.id)
				end)

				local zoneId=GetZoneIndex(GetHouseFoundInZoneId(data.id))-1
				local color=AllianceColor[ZoneAlliance[zoneId] or 0]
				count=WINDOW_MANAGER:CreateControl("CTS_Teleporter_HousingContext_C"..i, ui, CT_LABEL)
				count:SetDimensions(120,16)
				count:ClearAnchors()
				count:SetAnchor(TOPRIGHT,ui,TOPRIGHT,-10,10+20*(i-1))
				count:SetFont("ZoFontWinH5")
				count:SetColor(color[1],color[2],color[3],.8)
				count:SetHorizontalAlignment(0)
				count:SetVerticalAlignment(0)
				count:SetText(data.zone)
			else
				label:SetText("  "..data.name)
				label:SetColor(.8,.8,.7,1)
			end
		end
	end
	HousingContext_init=true
	return ui
end

local function Teleporter_init()
	ZO_CreateStringId("SI_BINDING_NAME_JUMP_WAYSHRINE", "Jump to wayshrine")
	ZO_CreateStringId("SI_BINDING_NAME_JUMP_HOME", "Jump to primary residence")
	ZO_CreateStringId("SI_BINDING_NAME_JUMP_FRIEND", "Visit friends residence")
	ZO_CreateStringId("SI_BINDING_NAME_JUMP_GUILDHALL", "Visit guild hall")
	primaryHouse=GetHousingPrimaryHouse()
	EVENT_MANAGER:RegisterForEvent("CTS_Event", EVENT_HOUSING_PRIMARY_RESIDENCE_SET, function(_,houseID) primaryHouse=houseID end)

	SLASH_COMMANDS["/home"] = CTS_JumpToHome
	SLASH_COMMANDS["/friendhome"] = CTS_JumpToFriend
	SLASH_COMMANDS["/fh"] = CTS_JumpToFriend
	SLASH_COMMANDS["/guildhall"] = CTS_JumpToGuildhall
	SLASH_COMMANDS["/gh"] = CTS_JumpToGuildhall
	SLASH_COMMANDS["/tp"]=function(loc) TargetZone=loc JumpToZone() end

	if BUI and BUI.PanelAdd then
	BUI.PanelAdd(
	{
		{--Wayshrine
		icon='/esoui/art/tutorial/poi_wayshrine_complete.dds',
		context=UI_WorldContext,
--[[
		tooltip=function()
--			ScanGuildInfo()
			local zone=GetCurrentZoneName()
			local players=CTS.Zones[zone] and (#CTS.Zones[zone]==0 and "|cCC22220|r" or tostring(#CTS.Zones[zone])) or "|cCC2222locked|r"
			return "Teleport to current zone wayshrine ("..tostring(zone)..")\nPlayers: "..players
		end,
--]]
		func=CTS_JumpToWayshrine,
		enabled=function()
			ScanGuildInfo()
			local zone=GetCurrentZoneName()
			return CTS.Zones[zone] and #CTS.Zones[zone]>0
		end,
		var="Teleporter"
		},
		{--Home
		icon='/esoui/art/campaign/campaignbrowser_homecampaign.dds',
		context=UI_HousingContext,
		func=CTS_JumpToHome,
--		tooltip="Teleport to primary residence",
		var="Teleporter"
		},
		{--Friend
		icon="/esoui/art/campaign/campaignbrowser_friends.dds",
		func=function()CTS_JumpToFriend()end,
		tooltip=function()return "Visit friends residence\n"..(CTS_Vars.Friend and "owned by "..tostring(CTS_Vars.Friend) or "need to set owner") end,
		var="Teleporter"
		},
		{--Guildhall
		icon="/esoui/art/treeicons/gamepad/gp_tutorial_idexicon_ava.dds",
		func=function()CTS_JumpToGuildhall()end,
		tooltip=function()return "Visit guild hall\n"..(CTS_Vars.Guild and "owned by "..tostring(CTS_Vars.Guild) or "need to set owner") end,
		var="Teleporter"
		}
	}
	)
	end

	for i=1,ZO_WorldMapLocationsListContents:GetNumChildren() do
		control=ZO_WorldMapLocationsListContents:GetChild(i):GetChild(1)	--_G["ZO_WorldMapLocationsList1Row"..i.."Location"]
		if control then
			control:SetHandler("OnMouseEnter", function(self)
				ScanGuildInfo()
				local location=CheckZoneName(self:GetText())
--				d(location..": "..(CTS.Zones[location] and #CTS.Zones[location] or "|cCC2222locked|r"))
				local players=CTS.Zones[location]~=nil and (#CTS.Zones[location]==0 and "|cCC22220|r" or tostring(#CTS.Zones[location])) or "|cCC2222locked|r"
				ZO_Tooltips_ShowTextTooltip(self, BTOTTOMLEFT, "Players: "..players..((CTS.Zones[location] and #CTS.Zones[location]>0) and "\nRight click to jump" or ""))
			end)
			control:SetHandler("OnMouseExit", function(self) ZO_Tooltips_HideTextTooltip(self) end)
		end
	end
	ZO_PreHook("ZO_WorldMapLocationRowLocation_OnMouseUp", function(self, button, upInside)
		if(upInside and button==MOUSE_BUTTON_INDEX_RIGHT) then
			local zone=CheckZoneName(self:GetText())
			AttemptToJump(zone)
		end
	end)
--	/script for i,data in pairs(WORLD_MAP_LOCATIONS.data.mapData) do d(data.locationName) end

	EVENT_MANAGER:RegisterForEvent("CTS_Event", EVENT_ZONE_UPDATE, function() AttemptedToJump={} TargetZone=nil end)
	EVENT_MANAGER:RegisterForEvent("CTS_Event", EVENT_SOCIAL_ERROR, function(eventCode, error)
--		d(error)
		if TargetZone then
			if JumpResults[error] then
				if JumpResults[error]==1 then
					JumpToZone()
				else
					ScreenMessage("|Jump to "..TargetZone.." is |cEE2222failed|r")
					TargetZone=nil
--					SetFrameLocalPlayerInGameCamera(false)
				end
			end
		end
	end)
	WORLD_MAP_SCENE:RegisterCallback("StateChange", function(oldState, newState) if newState==SCENE_SHOWN and WORLD_MAP_INFO then WORLD_MAP_INFO:SelectTab(SI_MAP_INFO_MODE_LOCATIONS) end end)
end

--Chat
local function FormatMessage(channel,Name,text,accName,timeStamp,m_Index)
	if Guild_id_by_channel[channel] then ScanGuildInfo(channel,accName) end
	local stamp,guild,name,rank,alliance,level,class,copy="","","","","","","",""
	local channel_name=ChannelName[channel] and ChannelName[channel]..": " or ""
	local guildinfo=CTS.GuildInfo[accName]
		--NameFormat
	if CTS_Vars.NameFormat=="Name" then
		name=zo_strformat(SI_UNIT_NAME,guildinfo and guildinfo.name or Name)
	elseif CTS_Vars.NameFormat=="Name@Accname" then
		name=zo_strformat(SI_UNIT_NAME,guildinfo and guildinfo.name or Name)..accName
	else name=accName end
	name=string.format("|H0:character:%s|h%s|h", accName, name)

		--Table links
	local key=string.sub(text,1,10)
	if key=="Group DPS:" or key=="Group deat" then
		local result=PostTable(text,channel)
		if result then text=result end
	end

	if guildinfo then
		--Guild
		guild=Guild_id_by_channel[channel] and CTS.Guild_names[ Guild_id_by_channel[channel] ] or false
		if guild then
			if CTS_Vars[guild] then guild=CTS_Vars[guild].." " end
		else
			guild=""
			if accName~=PlayerAccName then
				for _,name in pairs(guildinfo.guild) do
					if CTS_Vars[name] then name=CTS_Vars[name] end
					guild=guild..(guild=="" and "" or "/")..name
				end
				guild=guild.." "
			end
		end
		--Rank
		if CTS_Vars.Rank then rank=tostring(guildinfo.rank) end
		--Alliance
		if guildinfo.alliance then
			if CTS_Vars.Alliance then
				alliance=GetAllianceBannerIcon(guildinfo.alliance)
				alliance=alliance and zo_iconFormat(alliance, 24, 24) or ""
			end
			if CTS_Vars.AllianceColor then
				name=ColorString(AllianceColor[guildinfo.alliance][1]+.2,AllianceColor[guildinfo.alliance][2]+.2,AllianceColor[guildinfo.alliance][3]+.2)..name.."|r"
			end
		end
		--Class
		if CTS_Vars.Class then class=tostring(guildinfo.class) end
		--Level
		if CTS_Vars.Level then level=tostring(guildinfo.level) if class=="" then level=level.." " end end
	end
		--TimeStamp
	if CTS_Vars.TimeStamp then
--		stamp=string.sub(timeStamp,1,string.len(stamp)-3)
		stamp=FormatTimeSeconds(timeStamp+TimeZone*60*60,TIME_FORMAT_STYLE_CLOCK_TIME,TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR)
		stamp="|cBBBBBB"..stamp.."|r "
	end
		--CopyText
	if m_Index then copy=Copy_Link:format(m_Index) end
		--Web link
	text=text:gsub("(%*%*%*%*%*%*%*)","http://"):gsub("http[%a]*://%**(%S+)","|c4444DD|Hignore:web_link:%1|h%1|h|r")

	return copy..stamp..channel_name..guild..alliance..rank..class..level..name..": "..text
end

local function PostMessages()
	local timeStamp=GetTimeStamp()
	for i=CTS_Vars.Remember-1,0,-1 do
		local index=CTS_Vars.m_Index-i if index<1 then index=50+index end
		local data=CTS_Vars.Messages[index]
		if data and (data.timeStamp or 0)>timeStamp-3600 then
			local category=Category_by_channel[data.channel] or CHAT_CATEGORY_SYSTEM
			local message=FormatMessage(data.channel,data.name,data.message,data.accName,data.timeStamp,index)
			CHAT_SYSTEM.primaryContainer:AddEventMessageToContainer(message,category)
--[[
			local color=ColorString(GetChatCategoryColor(category))
			--TimeStamp
			if CTS_Vars.TimeStamp then stamp=FormatTimeSeconds(CTS_Vars.Messages[index].timeStamp+TimeZone*60*60,TIME_FORMAT_STYLE_CLOCK_TIME,TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR) stamp="|cBBBBBB"..stamp..":|r " end
			--NameFormat
			local name=""
			if CTS_Vars.Messages[index].accName then
				local guildinfo=CTS.GuildInfo[CTS_Vars.Messages[index].accName]
				if CTS_Vars.NameFormat=="Name" then
					if guildinfo then name=zo_strformat(SI_UNIT_NAME,guildinfo.name)
					else name=zo_strformat(SI_UNIT_NAME,CTS_Vars.Messages[index].name) end
				elseif CTS_Vars.NameFormat=="Name@Accname" then
					if guildinfo then name=zo_strformat(SI_UNIT_NAME,guildinfo.name)..CTS_Vars.Messages[index].accName
					else name=zo_strformat(SI_UNIT_NAME,CTS_Vars.Messages[index].name)..CTS_Vars.Messages[index].accName end
				else name=CTS_Vars.Messages[index].accName end
				name=string.format("|H0:character:%s|h%s|h", CTS_Vars.Messages[index].accName, name)
			end
			d((CTS_Vars.CopyText and Copy_Link:format(index) or "")..stamp..color..(CTS_Vars.Messages[index].guild and CTS_Vars.Messages[index].guild or "")..name..": "..tostring(CTS_Vars.Messages[index].message).."|r")
--]]
		end
	end
end

local function PostTable(text,channel)
	local s1,s2=string.find(text,": ",9)
	if s1 then
		local out=string.sub(text,s2+1,-1):split(", ")
		local i=1
		zo_callLater(function()
			for _,t in ipairs(out) do
				if t and t~="" and t~=" " then
					if string.sub(t,1,1)=="@" then t=i..". "..t i=i+1 end
					CHAT_SYSTEM.primaryContainer:AddEventMessageToContainer(t, Category_by_channel[channel] or CHAT_CATEGORY_SYSTEM)
				end
			end
		end,1)
		return string.sub(text,1,s1)
	end
end

local function OnChatMessage(_,channel,Name,text,_,accName)
	if not accName or accName=="" then return end
	if CTS_Vars.Sounds[channel] then PlaySound(CTS_Vars.Sounds[channel]) end
	local timeStamp=GetTimeStamp()
		--Remember messages
	local m_Index=nil
	if CTS_Vars.Remember>0 or CTS_Vars.CopyText then
		CTS_Vars.m_Index=CTS_Vars.m_Index+1 if CTS_Vars.m_Index>50 then CTS_Vars.m_Index=1 end
		CTS_Vars.Messages[CTS_Vars.m_Index]={name=Name,accName=accName,message=text,channel=channel,guild=guild,timeStamp=timeStamp}
		m_Index=CTS_Vars.m_Index
	end
	local messageText=FormatMessage(channel,Name,text,accName,timeStamp,m_Index)
--	return messageText
--	CHAT_ROUTER:FireCallbacks("FormattedChatMessage", messageText, Category_by_channel[channel] or CHAT_CATEGORY_SYSTEM, channel, accName)	--Unsecure
	CHAT_SYSTEM.primaryContainer:AddEventMessageToContainer(messageText, Category_by_channel[channel] or CHAT_CATEGORY_SYSTEM)
end

local function LinkHandler(link, button, control, color, linkType, param)
	if linkType=="c_button" then
		param=tonumber(param)
		if CTS_Vars.Messages[param] then
			StartChatInput(CTS_Vars.Messages[param].message)
		end
		return true
	elseif linkType=="web_link" then
		RequestOpenUnsafeURL("http://"..param)
		return true
	end
end

--Initialization
local function Menu_Init()
	local BanditsMenu=BUI and BUI.InternalMenu
	if not BanditsMenu and not LibAddonMenu2 then return end
	local MenuOptions={
		{type="header",	name="Advanced chat"},
		{type="description",	text="This section disables default chat format and allows you to customise it"},
--		{type="button",	name="Reload UI",func=function() ReloadUI() end},
		{type="checkbox",	name="Enable advanced chat",	param="Advanced",		warning="This option needs to reload UI"},
		{type="checkbox",	name="Show rank icon",		param="Rank",		condition="Advanced"},
		{type="checkbox",	name="Show alliance icon",	param="Alliance",		condition="Advanced"},
		{type="checkbox",	name="Show alliance color",	param="AllianceColor",	condition="Advanced"},
		{type="checkbox",	name="Show class icon",		param="Class",		condition="Advanced"},
		{type="checkbox",	name="Show player level",	param="Level",		condition="Advanced"},
		{type="checkbox",	name="Enable time stamp",	param="TimeStamp",	condition="Advanced"},
		{type="slider",	name="Remember messages",	param="Remember",		condition="Advanced",	max=50},
		{type="checkbox",	name="Enable text copy",	param="CopyText",		condition="Advanced"},
		{type="dropdown",	name="Name format",		param="NameFormat",	choices={"@Accname","Name","Name@Accname"},condition="Advanced"},
		{type="header",	name="Chat tab channels"},
		{type="checkbox",	name="Enable auto channel",	param="AutoChannel",	tooltip="Use preselected channels for each tab"},
		{type="dropdown",	name="Tab channel",		param="TabToChannel",	choices=ChannelsMenu,dup={1,2,3,4,5,6,7},condition="AutoChannel"},
		{type="header",	name="Guild names",condition="Advanced"},
		{type="description",	text="Here you can change names of your guilds in chat",condition="Advanced"},
		{type="editbox",	name=CTS.Guild_names,			param=CTS.Guild_names,	dup={1,2,3,4,5},condition="Advanced",},
		{type="header",	name="Channel Sounds",condition="Advanced"},
		{type="description",	text="Here you can select sound for some messages",condition="Advanced"},
		{type="dropdown",	name=ChannelName,			param="Sounds",		choices=CTS_Sounds,dup={CHAT_CHANNEL_WHISPER,CHAT_CHANNEL_PARTY},condition="Advanced",func=function(value)PlaySound(value)end},
		{type="header",	name="Misc"},
		{type="checkbox",	name="Teleporter",		param="Teleporter",	warning="This option needs to reload UI",tooltip="Adds to locations list option to free teleportation to selected zone."},
		}
	local Panel={
		type="panel",
		name=BanditsMenu and "17. |t32:32:/esoui/art/mainmenu/menubar_notifications_up.dds|tChat: Advanced" or DisplayName,
		displayName=DisplayName,
		author="|c4B8BFEHoft|r",
		version=tostring(AddonVersion),
		}
	local Options,i,var={},0,0
	for _,option in pairs(MenuOptions) do
		if not option.condition or CTS_Vars[option.condition] then
		for _,dup in pairs(option.dup and option.dup or {1}) do
			if not option.dup or (option.dup and (type(option.param)~="table" or (type(option.param)=="table" and option.param[dup]))) then
			i=i+1;Options[i]={}
			Options[i].type			=option.type
			if option.name then
				Options[i].name		=(option.icon and "|t32:32:"..option.icon.."|t " or "")..
								(option.dup and (type(option.name)=="table" and dup.." "..option.name[dup] or dup.." "..option.name) or option.name)
			end
			if option.tooltip then
				Options[i].tooltip	=option.tooltip
			end
			if option.text then
				Options[i].text		=option.text
			end
			if option.warning then
				Options[i].warning	=option.warning
			end
			if option.type=="slider" then
				Options[i].min		=0
				Options[i].max		=option.max and option.max or 10
				Options[i].step		=1
			end
			if option.choices then
				Options[i].choices	=option.choices
			end
			if option.func then
				Options[i].func		=option.func
			end
			if option.width then
				Options[i].width		=option.width
			end
			if option.param then
				Options[i].getFunc	=function()
					local var
					if option.dup then
						if type(option.param)=="table" then var=CTS_Vars[ option.param[dup] ]
						else var=CTS_Vars[option.param][dup] end
					else var=CTS_Vars[option.param] end
					return var
					end
				Options[i].setFunc	=function(value,text)
					if BanditsMenu and option.type=="dropdown" then value=text end
					if option.dup then
						if type(option.param)=="table" then CTS_Vars[ option.param[dup] ]=value
						else CTS_Vars[option.param][dup]=value end
					else
						CTS_Vars[option.param]=value
					end
					if option.func then local function func(value) option.func(value) end func(value) end
					end
				if option.dup then
					if type(option.param)=="table" then var=Defaults[ option.param[dup] ]
					else var=Defaults[option.param][dup] end
				else var=Defaults[option.param] end
				Options[i].default	=var
			end
			end
		end
		end
	end
	if BanditsMenu then
		BUI.Menu.RegisterPanel("CTS_Menu",Panel)
		BUI.Menu.RegisterOptions("CTS_Menu", Options)

	else
		LibAddonMenu2:RegisterAddonPanel("CTS_Menu",Panel)
		LibAddonMenu2:RegisterOptionControls("CTS_Menu", Options)
	end
end

local function PreHook_Init()
	ZO_PreHook(CHAT_SYSTEM, "StartTextEntry", function(ctrl, text, channel, target, showVirtualKeyboard)
--		channel=CHAT_SYSTEM.currentChannel
--		if channel==CHAT_CHANNEL_WHISPER and CTS_Vars.Whisper and target~=nil then
--			CHAT_SYSTEM:SetChannel(channel,target)
		if CTS_Vars.AutoChannel then
			local container=CHAT_SYSTEM.primaryContainer
			if not container then return end
			if not ZO_ChatWindowTextEntryEditBox or ZO_ChatWindowTextEntryEditBox:GetText()~="" then return end
			if string.match(CHAT_SYSTEM.textEntry.channelLabel:GetText(), "%w+")==WhisperChannel then return end
			local index=container.currentBuffer:GetParent().tab.index
			channel=ChannelsValue[ CTS_Vars.TabToChannel[index] ]
			if channel==-1 then return end
			CHAT_SYSTEM:SetChannel(channel)
		end
	end)
end

local function MailBox_Init()
	--Mail text copy
	if CTS_Vars.CopyText then
		local button=WINDOW_MANAGER:CreateControl("ZO_MailInboxMessageCopy", ZO_MailInboxMessage, CT_BUTTON)
		button:SetDimensions(24,24)
		button:ClearAnchors()
		button:SetAnchor(RIGHT,ZO_MailInboxMessageFromLabel,LEFT,0,0)
		button:SetState(BSTATE_NORMAL)
		button:SetFont("ZoFontGame")
		button:SetNormalFontColor(.46,.46,.46,1)
		button:SetPressedFontColor(1,1,1,1)
		button:SetMouseOverFontColor(.6,.6,.6,1)
		button:SetText("©")
		button:SetHandler("OnClicked", function()
			StartChatInput(tostring(ZO_MailInboxMessageFrom:GetText())..": "..tostring(ZO_MailInboxMessageBody:GetText()))
		end)
	end
	--TextBox
	ZO_MailSendBody:ClearAnchors()
	ZO_MailSendBody:SetAnchor(TOPLEFT,ZO_MailSendSubject,BOTTOMLEFT,0,38)
	ZO_MailSendBody:SetAnchor(BOTTOMRIGHT,ZO_MailSendSubject,BOTTOMRIGHT,0,340)
	--Color picker
	local texture=WINDOW_MANAGER:CreateControl("ZO_MailSendColorPicker", ZO_MailSend, CT_BUTTON)
	texture:SetDimensions(32,32)
	texture:ClearAnchors()
	texture:SetAnchor(TOPLEFT,ZO_MailSendSubject,BOTTOMLEFT,0,3)
	texture:SetState(BSTATE_NORMAL)
	texture:SetNormalTexture("/esoui/art/tutorial/dyes_tabicon_dye_up.dds")
	texture:SetHandler("OnClicked", function()
		PlaySound("Click")
		COLOR_PICKER:Show(function(r,g,b)
			local text=ZO_MailSendBodyField:GetText()
			ZO_MailSendBodyField:SetText(text..ColorString(r,g,b).."Text|r")
		end,.9,.2,.2,nil,"CTS_ColorPicker")
	end)

	local control=WINDOW_MANAGER:CreateControlFromVirtual("ZO_MailSendSymbol", ZO_MailSend, "ZO_ComboBox")
	control:SetDimensions(29, 28)
	control:ClearAnchors()
	control:SetAnchor(TOPLEFT,ZO_MailSendSubject,BOTTOMLEFT,40,5)
	local comboBox = control.m_comboBox
	comboBox:SetSortsItems(false)
	comboBox:ClearItems()
	local Symbols={"←","→","∞","©","®","♀","♂"}
	for i, v in pairs(Symbols) do
		local entry=ZO_ComboBox:CreateItemEntry(v, function()
			local text=ZO_MailSendBodyField:GetText()
			ZO_MailSendBodyField:SetText(text..Symbols[i])
		end)
		entry.id=i
		comboBox:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)
	end
	comboBox:SelectItemByIndex(1, true)
	comboBox:SetFont("ZoFontGame")

	--Packet send mail
	if #CTS.Guild_names==0 then return end
	local SendToGuildId,SendingInProgress,GuildMemebersTotal,GuildMemeberCurrent,MailText,MailSubject,accName,SendToRank,SendToRankCompare,LastSend=GetGuildId(1),false,0,0,nil,"",nil,11,1,0
	ZO_CreateStringId("SI_KEYBIND_STRIP_GUILD_SEND_START","Send to guild")
	ZO_CreateStringId("SI_KEYBIND_STRIP_GUILD_SEND_STOP","Stop sending")

	local control=WINDOW_MANAGER:CreateControlFromVirtual("ZO_MailSendGuild", ZO_MailSend, "ZO_ComboBox")
	control:SetDimensions(ZO_MailSendTo:GetWidth()/3*2, 28)
	control:ClearAnchors()
	control:SetAnchor(BOTTOMRIGHT,ZO_MailSendTo,TOPRIGHT,0,-5)
	local comboBox = control.m_comboBox
	comboBox:SetSortsItems(false)
	comboBox:ClearItems()
	for i, v in pairs(CTS.Guild_names) do
		local entry=ZO_ComboBox:CreateItemEntry(v, function() SendToGuildId=GetGuildId(i) end)
		entry.id=GetGuildId(i)
		comboBox:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)
	end
	comboBox:SelectItemByIndex(1, true)
	comboBox:SetFont("ZoFontGame")

	local control=WINDOW_MANAGER:CreateControlFromVirtual("ZO_MailSendRank", ZO_MailSend, "ZO_ComboBox")
	control:SetDimensions(ZO_MailSendTo:GetWidth()/6*2, 28)
	control:ClearAnchors()
	control:SetAnchor(BOTTOMRIGHT,ZO_MailSendGuild,TOPRIGHT,0,-3)
	local comboBox = control.m_comboBox
	comboBox:SetSortsItems(false)
	comboBox:ClearItems()
	for i, v in pairs({1,2,3,4,5,6,7,8,9,10,"All"}) do
		local entry=ZO_ComboBox:CreateItemEntry(v, function() SendToRank=i end)
		entry.id=i
		comboBox:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)
	end
	comboBox:SelectItemByIndex(11, true)
	comboBox:SetFont("ZoFontGame")

	local control=WINDOW_MANAGER:CreateControlFromVirtual("ZO_MailSendRankCompare", ZO_MailSend, "ZO_ComboBox")
	control:SetDimensions(40, 28)
	control:ClearAnchors()
	control:SetAnchor(RIGHT,ZO_MailSendRank,LEFT,-3,0)
	local comboBox = control.m_comboBox
	comboBox:SetSortsItems(false)
	comboBox:ClearItems()
	for i, v in pairs({"=",">=","<="}) do
		local entry=ZO_ComboBox:CreateItemEntry(v, function() SendToRankCompare=i end)
		entry.id=i
		comboBox:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)
	end
	comboBox:SelectItemByIndex(1, true)
	comboBox:SetFont("ZoFontGame")

	local label=WINDOW_MANAGER:CreateControl("ZO_MailSendRankLabel", ZO_MailSend, CT_LABEL)
	label:SetDimensions(ZO_MailSendTo:GetWidth()/6*2, 28)
	label:ClearAnchors()
	label:SetAnchor(BOTTOMLEFT,ZO_MailSendGuild,TOPLEFT,0,-3)
	label:SetFont("ZoFontGameBold")
	label:SetColor(.8,.8,.6,1)
	label:SetHorizontalAlignment(0)
	label:SetVerticalAlignment(1)
	label:SetText("Rank:")

	local function ChangeLabel()
		local control=KEYBIND_STRIP.keybinds["UI_SHORTCUT_TERTIARY"]
		if control then
			control=control:GetChild(1)
			if control:GetType()==CT_LABEL then
				control:SetText(SendingInProgress and GetString(SI_KEYBIND_STRIP_GUILD_SEND_STOP) or GetString(SI_KEYBIND_STRIP_GUILD_SEND_START))
			end
		end
		ZO_MailSendGuild:SetHidden(SendingInProgress)
		ZO_MailSendRank:SetHidden(SendingInProgress)
		ZO_MailSendRankLabel:SetHidden(SendingInProgress)
		ZO_MailSendRankCompare:SetHidden(SendingInProgress)
	end

	local function Message(reason)
		local count="|cBBBBBB"..GuildMemeberCurrent.."/"..GuildMemebersTotal.."|r |cBB3333"
		if reason==MAIL_SEND_RESULT_FAIL_INVALID_NAME or reason==MAIL_SEND_RESULT_RECIPIENT_NOT_FOUND then
			d(count..GetString(SI_SENDMAILRESULT2).." |c6666FF"..accName.."|r")
		elseif reason==MAIL_SEND_RESULT_FAIL_BLANK_MAIL then
			d("Mail is blank")
			SendingInProgress=false
		elseif reason==MAIL_SEND_RESULT_NOT_ENOUGH_MONEY then
			d(GetString(SI_SENDMAILRESULT5)) SendingInProgress=false
		elseif reason==MAIL_SEND_RESULT_FAIL_MAILBOX_FULL then
			d(count..GetString(SI_SENDMAILRESULT3).." |c6666FF"..accName.."|r")
		elseif reason==MAIL_SEND_RESULT_FAIL_IGNORED then 
			d(count..GetString(SI_SENDMAILRESULT4).." |c6666FF"..accName.."|r")
		elseif reason==MAIL_SEND_RESULT_FAIL_DB_ERROR or reason==MAIL_SEND_RESULT_FAIL_IN_PROGRESS then
			d(count..GetString(SI_SENDMAILRESULT1).."|r")
		end
	end

	local function RankCompare(rank)
		if SendToRank==11 then
			return true
		elseif SendToRankCompare==1 then
			if rank==SendToRank then return true end
		elseif SendToRankCompare==2 then
			if rank>=SendToRank then return true end
		elseif SendToRankCompare==3 then
			if rank<=SendToRank then return true end
		end
		return false
	end

	local function SendToGuildMember()
		GuildMemeberCurrent=GuildMemeberCurrent+1
		if not SendingInProgress or GuildMemeberCurrent>GuildMemebersTotal then
			SendingInProgress=false
			ChangeLabel()
			EVENT_MANAGER:UnregisterForEvent("CTS_Event", EVENT_MAIL_SEND_FAILED)
			EVENT_MANAGER:UnregisterForEvent("CTS_Event", EVENT_MAIL_SEND_SUCCESS)
			EVENT_MANAGER:UnregisterForUpdate("CTS_SafetyCheck")
			d("Done")
			return
		end
		accName,_,rank=GetGuildMemberInfo(SendToGuildId, GuildMemeberCurrent)
		if accName==PlayerAccName or not RankCompare(rank) then
			SendToGuildMember()
		else
--			d(GuildMemeberCurrent.."/"..GuildMemebersTotal.." Sending to "..accName)
			RequestOpenMailbox()
			SendMail(accName,MailSubject,MailText)
		end
		LastSend=GetGameTimeSeconds()
--		zo_callLater(SendToGuildMember,1000)
	end

	local function SendToGuild()
		local id=GetGuildMemberIndexFromDisplayName(SendToGuildId,PlayerAccName)
		local _,_,rank=GetGuildMemberInfo(SendToGuildId, id)
		if rank>3 then
			ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK, "Have no permissions")
			return
		end
		MailText=ZO_MailSendBodyField:GetText()
		if not SendingInProgress and (not MailText or MailText=="") then
			ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK, "Mail is blank")
			return
		end
		SendingInProgress=not SendingInProgress
		GuildMemebersTotal=GetNumGuildMembers(SendToGuildId)
		GuildMemeberCurrent=0
		MailSubject=ZO_MailSendSubjectField:GetText()
		ChangeLabel()
		EVENT_MANAGER:RegisterForEvent("CTS_Event", EVENT_MAIL_SEND_FAILED, function(_,reason)
			Message(reason)
			zo_callLater(SendToGuildMember,200)
		end)
		EVENT_MANAGER:RegisterForEvent("CTS_Event", EVENT_MAIL_SEND_SUCCESS, function()
			d("|cBBBBBB"..GuildMemeberCurrent.."/"..GuildMemebersTotal.."|r Mail was sent to |c6666FF"..accName.."|r")
			zo_callLater(SendToGuildMember,900)
		end)
		EVENT_MANAGER:RegisterForUpdate("CTS_SafetyCheck", 2500, function() if LastSend+5<GetGameTimeSeconds() then SendToGuildMember() end end)
		SendToGuildMember()
	end

	Button_GuildSend={
		alignment=KEYBIND_STRIP_ALIGN_LEFT,
		{
			name=GetString(SI_KEYBIND_STRIP_GUILD_SEND_START),
			keybind="UI_SHORTCUT_TERTIARY",
			enabled=function()return true end,
			visible=function()return true end,
			order=100,
			callback=SendToGuild,
		},
	}
	BACKPACK_MAIL_LAYOUT_FRAGMENT:RegisterCallback("StateChange", function(oldState, newState)
		if newState==SCENE_SHOWN then
			KEYBIND_STRIP:AddKeybindButtonGroup(Button_GuildSend)
			ChangeLabel()
		elseif newState==SCENE_HIDING then
			KEYBIND_STRIP:RemoveKeybindButtonGroup(Button_GuildSend)
		end
	end )
end

local function OnActivated()
	EVENT_MANAGER:UnregisterForEvent("CTS_Event", EVENT_PLAYER_ACTIVATED)
	PreHook_Init()
	ScanGuildInfo()
	Menu_Init()
	MailBox_Init()
	local function ChatReadyCheck()
		if CHAT_SYSTEM.primaryContainer then
			if CTS_Vars.Advanced then
				if CTS_Vars.Remember>0 then PostMessages() end
--				ZO_ChatSystem_AddEventHandler(EVENT_CHAT_MESSAGE_CHANNEL, OnChatMessage)
				EVENT_MANAGER:UnregisterForEvent("ChatRouter", EVENT_CHAT_MESSAGE_CHANNEL)
				EVENT_MANAGER:RegisterForEvent("CTS_Event", EVENT_CHAT_MESSAGE_CHANNEL, OnChatMessage)
			end
		else
			zo_callLater(ChatReadyCheck,500)
		end
	end
	ChatReadyCheck()
end

local function OnAddOnLoaded(eventCode, addonName)
	if addonName~=AddonName then return end
	EVENT_MANAGER:UnregisterForEvent("CTS_Event", EVENT_ADD_ON_LOADED)
	CTS_Vars=ZO_SavedVars:NewAccountWide("CTS_Settings", 3, nil, Defaults)
--	CTS_Zones=ZO_SavedVars:NewAccountWide("CTS_Zones", 1, nil, {})
	WhisperChannel=GetString(SI_CHAT_CHANNEL_NAME_WHISPER)
	EVENT_MANAGER:RegisterForEvent("CTS_Event", EVENT_PLAYER_ACTIVATED, OnActivated)

	if CTS_Vars.Advanced then
		EVENT_MANAGER:RegisterForEvent("CTS_Event",EVENT_GUILD_MEMBER_PLAYER_STATUS_CHANGED, function(_,guildId,displayName,_,newStatus)
			if newStatus==PLAYER_STATUS_OFFLINE then
				CTS.GuildInfo[displayName]=nil
			else
				SetGuildMemberInfo(guildId,displayName)
			end
		end)
		LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_CLICKED_EVENT, LinkHandler)
		LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, LinkHandler)
	end
--	UI_Sounds()

	if CTS_Vars.Teleporter then
		for i = 1, GetNumMaps() do
			local mapName,mapType,mapContentType,zoneId=GetMapInfo(i)
			mapName=CheckZoneName(mapName)	--ZO_CachedStrFormat(SI_ZONE_NAME, mapName)
			if not ZoneBlackList[zoneId] then table.insert(ZoneNames,{mapName=mapName,zoneId=zoneId}) end
		end
		table.sort(ZoneNames, function(a,b) return a.mapName<b.mapName end)
		CTS.ZoneNames=ZoneNames
		zo_callLater(Teleporter_init, 2500)
	end
	PlayerAccName=GetUnitDisplayName('player')
	TimeZone=24-tonumber(string.sub(FormatTimeSeconds(GetTimeStamp()-GetSecondsSinceMidnight(),TIME_FORMAT_STYLE_CLOCK_TIME,TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR),1,2))
	for i=1,CTS_Vars.Channels do ZO_CreateStringId("SI_BINDING_NAME_SELECT_TAB_"..i, "Select chat tab "..i) end
end
--	/script for i = 1, GetNumMaps() do local mapName,mapType,mapContentType,zoneId=GetMapInfo(i) d("["..zoneId.."] "..mapName) end
--Global functions
function CTS_SelectChatTab(index)
	if type(index)~="number" then return end
	local container=CHAT_SYSTEM.primaryContainer if not container then return end
--	if container.currentBuffer:GetParent().tab.index==index or index<1 or index>#container.windows then return end
	if index<1 or index>#container.windows then return end
	if container.windows[index].tab==nil then return end
	container.tabGroup:SetClickedButton(container.windows[index].tab)
	if CHAT_SYSTEM:IsMinimized() then CHAT_SYSTEM:Maximize() end
	local container=CHAT_SYSTEM.primaryContainer
	if not container then return end
	local index=container.currentBuffer:GetParent().tab.index
	channel=ChannelsValue[ CTS_Vars.TabToChannel[index] ]
	if channel==-1 then return end
	CHAT_SYSTEM:SetChannel(channel)
end

function CTS_JumpToWayshrine()
	TargetZone=GetCurrentZoneName()
	ScanGuildInfo()
	AttemptToJump(TargetZone)
end

function CTS_JumpToFriend(Owner)
	if (Owner and Owner~="") then
		CTS_Vars.Friend=Owner
		d("Teleporter: Saved! Now you can just use /friendhome or /fh to jump")
	end
	if (CTS_Vars.Friend~=nil) then
		ScreenMessage("Traveling to home owned by "..CTS_Vars.Friend,8000)
		JumpToHouse(CTS_Vars.Friend)
	else d("Teleporter: First need to enter /friendhome @FriendName")end
end

function CTS_JumpToGuildhall(Owner)
	if (Owner and Owner~="") then
		CTS_Vars.Guild=Owner
		d("Teleporter: Saved! Now you can just use /guildhall or /gh to jump")
	end
	if (CTS_Vars.Guild~=nil) then
		ScreenMessage("Traveling to guild hall ("..CTS_Vars.Guild..")",8000)
		JumpToHouse(CTS_Vars.Guild)
	else d("Teleporter: First need to enter /guildhall @HallOwner")end
end

function CTS_JumpToHome(command)
	if (command == "help" or command=="?") then
		d("Teleporter slash command options:")
		d("/home - teleport to your primary house")
		d("/friendhome or /fh [@accname] - teleport to your friends house")
		d("/guildhall or /gh [@accname]- teleport to your guild hall")
	else
		ScreenMessage("Traveling to home",8000)
		RequestJumpToHouse(primaryHouse)
	end
end

EVENT_MANAGER:RegisterForEvent("CTS_Event", EVENT_ADD_ON_LOADED, OnAddOnLoaded)