local static_frame={TOPLEFT,TOPLEFT,0,0}
local theme_color,companionPetIndex=nil,0
local Attributes={[POWERTYPE_HEALTH]="health", [POWERTYPE_MAGICKA]="magicka", [POWERTYPE_STAMINA]="stamina",[POWERTYPE_ULTIMATE]="ultimate"}

function BCUI.Frames.Initialize()
  if BUI then
  	theme_color=BUI.Vars.Theme==6 and {1,204/255,248/255,1} or BUI.Vars.Theme==7 and BUI.Vars.AdvancedThemeColor or BUI.Vars.CustomEdgeColor
	Border=n and n or BUI.Vars.FramesBorder

	if (BCUI.Vars.ShowCompanionWhenSolo and not IsUnitGrouped('player')) or 
		 (BCUI.Vars.ShowCompanionWhenInGroup and IsUnitGrouped('player')) or
		 (BCUI.InSettingMenu or BUI.inMenu)
	then 
		BCUI.Frames.Companion_UI()
	elseif 
		BCUI_CompanionFrame then BCUI_CompanionFrame:SetHidden(true)		
		return
	end
	--BCUI.Frames.GetGroupData()
		BCUI.Frames:SetupGroup()
	
  	EVENT_MANAGER:UnregisterForUpdate("BCUI_CompanionFrame",BCUI.Frames.SafetyCheck)
  	EVENT_MANAGER:RegisterForUpdate("BCUI_CompanionFrame",5000,BCUI.Frames.SafetyCheck)  
  else  	
    pl("BUI not found")
  end
end

local function SortGroup(list)
	local sorted=false	
	if not sorted then
		if BCUI.Vars.CompanionSort==3 then	--By power
			table.sort(list,function(a,b) return a.power>b.power end)
		elseif BCUI.Vars.CompanionSort==4 then	--By level
			for i,data in pairs(list) do
				list[i].level=GetUnitLevel(data.tag)+GetUnitChampionPoints(data.tag)
			end
			table.sort(list,function(a,b) return a.level>b.level end)
			sorted=true
		elseif BCUI.Vars.CompanionSort==5 then	--By accname
			table.sort(list,function(a,b) return a.accname<b.accname end)
			sorted=true
		else	--Auto
			table.sort(list,function(a,b) return a.role>b.role end)			
			sorted=true
		end
	end
	local index=1
	for i,data in pairs(list) do		
		if data and data.tag then
			BCUI.Companions[i]={role=BCUI.Companions[data.tag].role,tag=data.tag}
			BCUI.Companions[data.tag].index=i
			BCUI.Companions[BCUI.Companions[data.tag].name].index=i
			index=i
		else
			BCUI.Companions[i]=nil
		end
	end	
	for i=index+1,6 do BCUI.Companions[i]=nil end	
end

function BCUI.Frames:UpdateAttribute(unitTag, powerType, powerValue, powerMax, powerEffectiveMax)
	--Translate the attribute
	local power=Attributes[powerType]
	local data
	--Companions
	data=BCUI.Companions[unitTag]	
	if not data then return end
	--If no value was passed, get new data
	if powerValue==nil then
		powerValue, powerMax, powerEffectiveMax=GetUnitPower(unitTag, powerType)
	end
	--Get the percentage
	local pct=math.max(math.floor((powerValue or 0)*100/powerMax+.5)/100,0)
	--Update the database object
	data[power]={current=powerValue,max=powerMax,pct=pct}
	--Update frames
	local shield=(data.shield and data.shield.current) or 0
	if BUI.init.Frames and powerType~=POWERTYPE_ULTIMATE then
		BCUI.Frames.Attribute(unitTag, power, powerValue, powerMax, pct, shield)		
	end
end

function BCUI.Frames.Attribute(unitTag, attribute, powerValue, powerMax, pct, shieldValue)
	local frame,group,enabled=nil,false,false
	local ShowMax=BUI.Vars.FrameShowMax
	local pctLabel=(pct*100).."%"

	if BCUI.Companions[unitTag] then
		frame=BCUI.Companions[unitTag].frame
		if not frame then return end
		enabled	=true
		group=true
		ShowMax	=false
	else return end

	if enabled and BCUI.Vars.AutoHide and not BCUI.InSettingMenu and BUI.Player.alt==nil then
		if BUI.inCombat or BUI.Player.health.pct<.99 or BUI.Player.magicka.pct<.99 or BUI.Player.stamina.pct<.99 then
			if BCUI_CompanionFrame:GetAlpha()<.05 then
				BCUI.Frames.Fade(BCUI_CompanionFrame)
			end
		elseif not CompanionFrameFadeDelay and BCUI_CompanionFrame:GetAlpha()>.05 then
			PlayerFrameFadeDelay=true
			BUI.CallLater("Companion_FramesFade",1500,function()
				CompanionFrameFadeDelay=false
				if not(BUI.inCombat or BUI.Player.health.pct<.95 or BUI.Player.magicka.pct<.95 or BUI.Player.stamina.pct<.95) then
					BUI.Frames.Fade(BCUI_CompanionFrame,true)
				end
			end)
		end
	end

	if enabled then
		local short=powerValue>100000 or group
		local label=(short and BUI.DisplayNumber(powerValue/1000,1) or BUI.DisplayNumber(powerValue))
			..(ShowMax and "/"..(group and BUI.DisplayNumber(powerMax/1000) or (short and BUI.DisplayNumber(powerMax/1000,1) or BUI.DisplayNumber(powerMax))) or "")
		local dead=IsUnitDead(unitTag)

		if attribute=="health" then
			if not IsUnitOnline(unitTag) then
				label,pct,pctLabel,short=BUI.Loc("Offline"),0,"",false
			elseif dead or powerValue<0 then
				label,pct,pctLabel,short=BUI.Loc("Dead"),0,"",false
				if group then
					frame.dead:SetHidden(false)
					BUI.UI.Expires(frame.dead)
				end
			else
				local add_pct=unitTag=='reticleover' and not BUI.Vars.FramePercents
				label=label..(add_pct and " ("..pctLabel..")" or "")..(shieldValue>0 and "["..BUI.DisplayNumber(shieldValue/(short and 1000 or 1)).."]" or "")
				if group then frame.dead:SetHidden(true) end
			end
		end

		local control=frame[attribute]
		local w=(group and BCUI.Vars.CompanionWidth*BCUI_CompanionFrame.scale-4 or control.bg:GetWidth())		
		control.bar:SetWidth(pct*w)
		control.current:SetText(label..(short and "k" or ""))
		control.pct:SetText(pctLabel)
	end
end

function BCUI.Frames.GetGroupData()
	BCUI.Companions.members=GetGroupSize()
	local list={}
	companionPetIndex=0
	for i=1,BCUI.Companions.members do
		local unitTag	=GetGroupUnitTagByIndex(i)
		local companionTag = GetCompanionUnitTagByGroupUnitTag(unitTag)
		if (companionTag and string.match(companionTag, "companion") and DoesUnitExist(companionTag)) or (BCUI.InSettingMenu or BUI.inMenu) then
			local name		=string.gsub(GetUnitName(companionTag),"%^%w+","")
			local accname	=GetUnitDisplayName(unitTag)
			local role		="Companion"
			local marker	=3
			local class		=GetUnitClassId(unitTag)
			local icon		=BCUI.Vars.CompanionIcon			
			local shield  ={current=0,max=0,pct=100}

			if HasActiveCompanion() then BCUI.CompanionInfo.activeId=GetActiveCompanionDefId() end

			if( IsUnitDead(companionTag) or GetUnitPower(companionTag, POWERTYPE_HEALTH) > 0 or (BCUI.InSettingMenu or BUI.inMenu) ) then		
				companionPetIndex = companionPetIndex+1
				if accname then
					if not BCUI.Companions[accname] then BCUI.Companions[accname]={} end
					BCUI.Companions[accname].name=name
					BCUI.Companions[accname].role=role
					BCUI.Companions[accname].tag=unitTag
				end
				if name then					
					if not BCUI.Companions[name] then BCUI.Companions[name]={} end
					BCUI.Companions[name].accname=accname
					BCUI.Companions[name].role=role
					BCUI.Companions[name].index=companionPetIndex
					BCUI.Companions[name].tag=companionTag
				end
				BCUI.Companions[companionPetIndex]={role=role,marker=marker,tag=companionTag}
				if not BCUI.Companions[companionTag] then BCUI.Companions[companionTag]={} end
				BCUI.Companions[companionTag].icon=icon
				BCUI.Companions[companionTag].marker=icon
				BCUI.Companions[companionTag].name=name
				BCUI.Companions[companionTag].accname=accname
				BCUI.Companions[companionTag].role=role
				BCUI.Companions[companionTag].power=GetUnitPower(companionTag, POWERTYPE_HEALTH)
				BCUI.Companions[companionTag].index=companionPetIndex		
				BCUI.Companions[companionTag].shield=BCUI.Companions[companionTag].shield or shield	
				table.insert(list,{tag=companionTag,accname=accname,role=3,power=BCUI.Companions[companionTag].power or 0})
			end
		else
			BCUI.Companions[i]=nil			
		end
	end
	for i=companionPetIndex+1,6 do BCUI.Companions[i]=nil end	
	if #list>1 then SortGroup(list) end
	if BCUI.Vars.AddPetsToCompanionList then BCUI.Frames.GetPetData() end
end

function BCUI.Frames.GetCompanionData()
	local list={}
	companionPetIndex = 0
	if HasActiveCompanion() or (BCUI.InSettingMenu or BUI.inMenu) then
		BCUI.CompanionInfo.activeId=GetActiveCompanionDefId()
		local companionTag = 'companion'		
		local name		=zo_strformat(SI_COMPANION_NAME_FORMATTER, GetCompanionName(GetActiveCompanionDefId()))
		local accname	=GetUnitDisplayName('player')
		local role		="Companion"
		local marker	=3
		local class		=GetUnitClassId('player')
		local icon		=BCUI.Vars.CompanionIcon		
		local shield  ={current=0,max=0,pct=100}

		if( IsUnitDead(companionTag) or GetUnitPower(companionTag, POWERTYPE_HEALTH) > 0 or (BCUI.InSettingMenu or BUI.inMenu) ) then					
			companionPetIndex = 1
			if accname then
				if not BCUI.Companions[accname] then BCUI.Companions[accname]={} end
				BCUI.Companions[accname].name=name
				BCUI.Companions[accname].role=role
				BCUI.Companions[accname].tag=unitTag
			end
			if name then
				if not BCUI.Companions[name] then BCUI.Companions[name]={} end
				BCUI.Companions[name].accname=accname
				BCUI.Companions[name].role=role
				BCUI.Companions[name].index=companionPetIndex
				BCUI.Companions[name].tag=companionTag
			end
			BCUI.Companions[companionPetIndex]={role=role,marker=marker,tag=companionTag}
			if not BCUI.Companions[companionTag] then BCUI.Companions[companionTag]={} end
			BCUI.Companions[companionTag].icon=icon
			BCUI.Companions[companionTag].marker=icon
			BCUI.Companions[companionTag].name=name
			BCUI.Companions[companionTag].accname=accname
			BCUI.Companions[companionTag].role=role
			BCUI.Companions[companionTag].index=companionPetIndex
			BCUI.Companions[companionTag].leader=nil		
			BCUI.Companions[companionTag].shield=BCUI.Companions[companionTag].shield or shield	
			
			table.insert(list,{tag=companionTag,accname=accname,role=3,power=BCUI.Companions[companionTag].power or 0})			
		end
	end
	
	for i=companionPetIndex+1,6 do BCUI.Companions[i]=nil end
	if #list>1 then SortGroup(list) end	
	if BCUI.Vars.AddPetsToCompanionList then BCUI.Frames.GetPetData() end
end

local function IsPermPet(name)
	local permPets = {
			-- Familiar
			23304,
			-- Clannfear
			23319,
			-- Volatile Familiar
			23316,
			-- Winged Twilight
			24613,
			-- Twilight Tormentor
			24636,
			-- Twilight Matriarch
			24639,
			-- Feral Guardian
			85982,
			-- Eternal Guardian
			85986,
			-- Wild Guardian
			85990
		}

		for i=1, #permPets do 
			if string.match(GetAbilityName(permPets[i]),name)~=nil then return true end
		end

		return false
end

function BCUI.Frames.GetPetData()
	local list={}
	for i=1,7 do
		local petTag = 'playerpet'..i
		local name		=string.gsub(GetUnitName(petTag),"%^%w+","")
		local accname	=name --GetUnitDisplayName('player')
		local role		="Pet"
		local marker	=3
		local class		=GetUnitClassId('player')
		local icon		=BCUI.Vars.PetIcon
		local shield  ={current=0,max=0,pct=100}
		
		if( (IsUnitDead(petTag) or GetUnitPower(petTag, POWERTYPE_HEALTH) > 0)
		and	( BCUI.Vars.ShowAllPetsAbilites or IsPermPet(name) )
		) then
			companionPetIndex = companionPetIndex + 1
			if accname then
				if not BCUI.Companions[accname] then BCUI.Companions[accname]={} end
				BCUI.Companions[accname].name=name
				BCUI.Companions[accname].role=role
				BCUI.Companions[accname].tag=unitTag
			end
			if name then
				if not BCUI.Companions[name] then BCUI.Companions[name]={} end
				BCUI.Companions[name].accname=accname
				BCUI.Companions[name].role=role
				BCUI.Companions[name].index=companionPetIndex
				BCUI.Companions[name].tag=petTag
			end
			BCUI.Companions[companionPetIndex]={role=role,marker=marker,tag=petTag}
			if not BCUI.Companions[petTag] then BCUI.Companions[petTag]={} end
			BCUI.Companions[petTag].icon=icon
			BCUI.Companions[petTag].marker=icon
			BCUI.Companions[petTag].name=name
			BCUI.Companions[petTag].accname=accname
			BCUI.Companions[petTag].role=role
			BCUI.Companions[petTag].index=companionPetIndex
			BCUI.Companions[petTag].leader=nil			
			BCUI.Companions[petTag].shield=BCUI.Companions[petTag].shield or shield	
			
			table.insert(list,{tag=petTag,accname=accname,role=3,power=BCUI.Companions[petTag].power or 0})			
		end
	end
	for i=companionPetIndex+1,6 do BCUI.Companions[i]=nil end
	--if #list>1 then SortGroup(list) end	
end

function BCUI.Frames:SetupGroup()	
	--Exit when in move mode
	if not BCUI.FramesLocked then return end

	--Using group frame
	if (BCUI.Vars.ShowCompanionWhenInGroup and IsUnitGrouped('player')) or (BCUI.Vars.ShowCompanionWhenSolo and (HasActiveCompanion() or GetUnitName('playerpet1')~='')) or (BCUI.InSettingMenu or BUI.inMenu) then
		if BCUI.Vars.ShowCompanionWhenInGroup or BCUI.Vars.ShowCompanionWhenSolo or (BCUI.InSettingMenu or BUI.inMenu) then
			ZO_UnitFramesGroups:SetHidden(true)
		else
			ZO_UnitFramesGroups:SetHidden(false)
			if BCUI_CompanionFrame then BCUI_CompanionFrame:SetHidden(true) end
			return
		end
	elseif not BUI.inMenu then
		if BCUI_CompanionFrame then BCUI_CompanionFrame:SetHidden(true) end
		return
	end
	if not BCUI_CompanionFrame then return end
	--Set scale
	local members=BCUI.Companions.members or 0
	local scale=members<=4 and BUI.Vars.SmallGroupScale/100 or 1
	if BCUI_CompanionFrame.scale~=scale then BCUI.Frames.Companion_UI(scale) end
	--Get group data
	if ((BCUI.Vars.ShowCompanionWhenSolo and (HasActiveCompanion() or GetUnitName('playerpet1')~='')) or (BCUI.InSettingMenu or BUI.inMenu)) and not IsUnitGrouped('player') then
		BCUI.Frames.GetCompanionData()		
	elseif (BCUI.Vars.ShowCompanionWhenInGroup and IsUnitGrouped('player')) or (BCUI.InSettingMenu or BUI.inMenu) then
		BCUI.Frames.GetGroupData()		
	end	
	--Iterate over members
	for i=1, 6 do
		local unitTag=BCUI.Companions[i] and BCUI.Companions[i].tag
		local frame=BCUI_CompanionFrame["companion"..i]
		--Only proceed for members which exist
		if unitTag then	--and DoesUnitExist(unitTag) then
			local isCompanion = "companion" == string.match(unitTag, "companion")
			local member=BCUI.Companions[unitTag]
			BCUI.Companions[unitTag].frame=frame
			--Name@AccountName
			local displayname=(member.leader and "|cFFFF22" or (BUI.Vars.SelfColor and member.name==BUI.Player.name) and "|c22FF22" or member.role=="Companion" and BCUI.Vars.CompanionNameColor and "|c00FFE8" or "")
			..(BCUI.Vars.CompanionNameFormat==2 and member.accname or BCUI.Vars.CompanionNameFormat==3 and member.name.."|cB0B0FF"..member.accname.."|r" or member.name).."|r"
			--Determine bar color
			local color=BUI.Vars.ColorRoles and BUI.Vars["Frame"..member.role.."Color"] or BUI.Vars.FrameHealthColor			
			--d(BCUI.Vars.FrameCompanionColor)
			if isCompanion then color=BCUI.Vars.FrameCompanionColor end
			--d(color)
			local pcolor=color[2]
			--Color bar by role
			frame.health.bar:SetColor(color[1],pcolor,color[3],1)
			frame.lead:SetHidden(not member.leader)
			--Populate nameplate
			local level		=BUI.Player:GetColoredLevel(unitTag)
			local label=(BCUI.Companions[unitTag].icon and zo_iconFormat(BCUI.Companions[unitTag].icon,BUI.Vars.FrameFontSize*1.2*BCUI_CompanionFrame.scale,BUI.Vars.FrameFontSize*1.2*BCUI_CompanionFrame.scale) or " ").." "..(BCUI.Vars.CompanionLevels and level.." " or "")..displayname
			frame.name:SetText(label)
			--Populate health data			
			BCUI.Frames:UpdateAttribute(unitTag, POWERTYPE_HEALTH, nil)
			--Change the bar color
			BUI.Frames:GroupRange(unitTag, nil)
			--Display the frame
			frame:SetHidden(false)
		--Otherwise hide the frame
		else
			frame:SetHidden(true)
		end
	end
	--Display custom frames
	BCUI_CompanionFrame:SetHidden(false)
end

function BCUI.Frames:Shield(unitTag, shieldValue, shieldPct, healthValue, healthMax)
	local frame,update,group	
	frame=BCUI.Companions[unitTag].frame
	update=(BCUI.Vars.ShowCompanionWhenInGroup or BCUI.Vars.ShowCompanionWhenSolo)
	group=true
	--Update custom frames
	if update and frame then
		local width=math.min(shieldPct,1)*(frame.width-4)
		frame.shield:SetWidth(width)
		frame.shield:SetHidden(shieldValue<=0)
			--Update bar labels
		local short=group or healthValue>100000
		local label=(short and BUI.DisplayNumber(healthValue/1000,1) or BUI.DisplayNumber(healthValue))
			..(BUI.Vars.FrameShowMax and "/"..(short and BUI.DisplayNumber(healthMax/1000,1) or BUI.DisplayNumber(healthMax)) or "")
			..(shieldValue>0 and "["..BUI.DisplayNumber(shieldValue/(short and 1000 or 1)).."]" or "")
			..(short and "k" or "")
		frame.health.current:SetText(label)
	end
end

function BCUI.Frames:UpdateShield(unitTag, value, maxValue)
	local data,isGroup
	if BCUI.Companions[unitTag] then
		data=BCUI.Companions[unitTag]
		isGroup=true
	else return end
	if not data or not data["health"] then return end
	if not value then
		value,maxValue=GetUnitAttributeVisualizerEffectInfo(unitTag,ATTRIBUTE_VISUAL_POWER_SHIELDING,STAT_MITIGATION,ATTRIBUTE_HEALTH,POWERTYPE_HEALTH) or 0
	end
	if value==data.shield.current then return end
	local pct=value/data.health.max
	data.shield={["current"]=value, ["max"]=maxValue, ["pct"]=pct}
	--Update frames
	if BUI.init.Frames then
		if BCUI.Vars.ShowCompanionWhenInGroup or BCUI.Vars.ShowCompanionWhenSolo then BCUI.Frames:Shield(unitTag,value,pct,data.health.current,data.health.max) end
	end
end

local function Companion_ShowTooltip(control)
	if BCUI.Companions[control.index] then
		local unitTag=BCUI.Companions[control.index].tag
		if unitTag then
			local isPlayerCompanion = GetCompanionUnitTagByGroupUnitTag(GetLocalPlayerGroupUnitTag()) == unitTag or "companion" == unitTag
			local level, currentXpInLevel, totalXpInLevel, isMaxLevel = ZO_COMPANION_MANAGER:GetLevelInfo()
			local pct=math.floor((currentXpInLevel/totalXpInLevel)*100)
			local name=BCUI.Companions[unitTag].name
			local rapport, maxrapport=GetActiveCompanionRapport(),GetMaximumRapport()
			local rappct=math.floor((rapport/maxrapport)*100)
			local rapportText = GetActiveCompanionRapportLevelDescription(GetActiveCompanionRapportLevel())
--			local extras
--			if name == BCUI.CompanionInfo.bastian.name then extras=BCUI.CompanionInfo.bastian.tooltipExtra end
--			if name == BCUI.CompanionInfo.mirri.name then extras=BCUI.CompanionInfo.mirri.tooltipExtra end

			if not isPlayerCompanion then
				level = GetUnitLevel(unitTag)
				currentXpInLevel = GetUnitXP(unitTag)
				totalXpInLevel = '?'
				pct='?'
			end

			InitializeTooltip(InformationTooltip, control, BOTTOM, 0, -16)
			InformationTooltip:AddLine(name,'$(BOLD_FONT)'..'|22',1,1,1)
			local text=BCUI.Loc("CompanionTooltipLevel")..': |cFFFFFF'..level..'|r'
			text=text..'\n'..BCUI.Loc("CompanionTooltipExperience")..': |cFFFFFF'..currentXpInLevel..'/'..totalXpInLevel..' ('..pct..'%)|r'
			if rapport and isPlayerCompanion then text=text..'\n'..BCUI.Loc("CompanionTooltipRapport")..': |cFFFFFF'..rapport..'/'..maxrapport..' ('..rappct..'%)\n'..rapportText..'|r' end
--			if extras and extras~="" and isPlayerCompanion then text=text..'\n\n'..extras end
			SetTooltipText(InformationTooltip, text)
		end
	end
end

function BCUI.Frames.LockFrames()	
	_G["BUI_SettingsWindow"]:SetHidden(false)
end

function BCUI.Frames.Companion_UI(s)	--UI init
	s=s or BCUI_CompanionFrame and BCUI_CompanionFrame.scale or 1	
	local col=BUI.Vars.RaidColumnSize
	local groupSize=GetGroupSize()	
	local ch,cm,cs,cw=BUI.Vars.FrameHealthColor,BUI.Vars.FrameMagickaColor,BUI.Vars.FrameStaminaColor,BUI.Vars.FrameShieldColor
	local w,h=BCUI.Vars.CompanionWidth*s,BCUI.Vars.CompanionHeight*s
	local hs=h-(BUI.Vars.StatShare and 8-1 or 0)*s
	local fs=math.min(BCUI.Vars.CompanionFontSize,hs*.8)*s
	local t=GetFormattedTime()
	local BUIComp=BUI.Vars.RaidCompact
	local comp=BCUI.Vars.CompanionCompact
	local split=BCUI.Vars.CompanionSplit
	local indent=0
	--Create the companion frame container
	local raidPanel=_G["BUI_RaidFrame"]
	local CompanionFramePos=static_frame
	local BanditsUI=_G["BanditsUI"]
	if not IsUnitGrouped('player') then
		raidPanel=BanditsUI
		CompanionFramePos={TOPLEFT,TOPLEFT,50,160}		
	end
	
	local companion	=BUI.UI.Control("BCUI_CompanionFrame",			raidPanel,	{w,(h+((BUIComp and comp) and 0 or fs+3))*col},	CompanionFramePos,	false)
	companion.backdrop	=BUI.UI.Backdrop("BCUI_CompanionFrame_Bg",		companion,		"inherit",		{CENTER,CENTER,0,0},	{0,0,0,0.4}, {0,0,0,1}, nil, true)
	companion.label		=BUI.UI.Label(	"BCUI_CompanionFrame_Label",	companion.backdrop,		"inherit",		{CENTER,TOP,0,0},	BUI.UI.Font("standard",20,true), nil, {1,1}, BCUI.Loc("GF_Label"), false)

	companion:SetAlpha(BUI.Vars.FrameOpacityOut/100)
	companion:SetDrawTier(DT_HIGH)
	--companion:SetMovable(true)
	companion.scale=s

	if ((BCUI.InSettingMenu or BUI.inMenu) and not BCUI.FramesLocked) then
		companion:SetMovable(true)
		companion:SetMouseEnabled(true)
		companion.backdrop	=BUI.UI.Backdrop("BCUI_CompanionFrame_Bg",		companion,		"inherit",		{CENTER,CENTER,0,0},	{0,0,0,.9}, {0.4,0.4,0.4,.9}, nil, false)
		local name=companion:GetName()
		local width=companion:GetWidth()
		local height=companion:GetHeight()
		companion:ClearAnchors() 
		companion:SetAnchor(BCUI.Vars.BCUI_CompanionFrame[1],BanditsUI,BCUI.Vars.BCUI_CompanionFrame[2],BCUI.Vars.BCUI_CompanionFrame[3],BCUI.Vars.BCUI_CompanionFrame[4])
		companion.line_top	=BUI.UI.Line(name.."_Line_top",	companion,	{width+600,0},	{TOPLEFT,TOPLEFT,-300,0},	{.8,.8,.8,.3},1.8, false)
		companion.line_bot	=BUI.UI.Line(name.."_Line_bot",	companion,	{width+600,0},	{TOPLEFT,BOTTOMLEFT,-300,0},	{.8,.8,.8,.3},1.8, false)
		companion.line_left	=BUI.UI.Line(name.."_Line_left",	companion,	{0,height+600},	{TOPLEFT,TOPLEFT,0,-300},	{.8,.8,.8,.3},1.8, false)
		companion.line_right	=BUI.UI.Line(name.."_Line_right",	companion,	{0,height+600},	{TOPLEFT,TOPRIGHT,0,-300},	{.8,.8,.8,.3},1.8, false)
		companion.line_hor	=BUI.UI.Line(name.."_Line_hor",	companion,	{width+200,0},	{TOPLEFT,LEFT,-100,0},		{.8,.8,.8,.3},1.8, false)
		companion.line_vert	=BUI.UI.Line(name.."_Line_vert",	companion,	{0,height+200},	{TOPLEFT,TOP,0,-100},		{.8,.8,.8,.3},1.8, false)		
		companion:SetHandler("OnMouseUp", function(self)
	    local isValidAnchor, anchor, relativeTo, relativePoint, offx, offy, AnchorConstrains = BCUI_CompanionFrame:GetAnchor()
	    BCUI.Vars.BCUI_CompanionFrame={anchor,relativePoint,offx,offy}
	    --BUI.Menu:SaveAnchor(self)
		end)

		local function OnLayerChange(eventCode, layerIndex, activeLayerIndex)
			if layerIndex<=4 and activeLayerIndex>2 then
			--Unregister events
				BCUI.TargetFrameHidePreview()
				BCUI.EventShowBUIMenu()				
				if BUI.Vars.BCUI_CompanionFrame then BUI.Vars["BCUI_CompanionFrame"] = nil end
				--EVENT_MANAGER:UnregisterForEvent("BCUI_Event", EVENT_ACTION_LAYER_POPPED)
				EVENT_MANAGER:UnregisterForEvent("BCUI_Event", EVENT_ACTION_LAYER_PUSHED)				
			end
		end

		--EVENT_MANAGER:RegisterForEvent("BCUI_Event", EVENT_ACTION_LAYER_POPPED	,OnLayerChange)
		EVENT_MANAGER:RegisterForEvent("BCUI_Event", EVENT_ACTION_LAYER_PUSHED	,OnLayerChange)
	else
		companion:SetMovable(false)
		if companion.framelock then companion.framelock:SetHidden(true) end
		if companion.line_top then companion.line_top:SetHidden(true) end
		if companion.line_bot then companion.line_bot:SetHidden(true) end
		if companion.line_left then companion.line_left:SetHidden(true) end
		if companion.line_right then companion.line_right:SetHidden(true) end
		if companion.line_hor then companion.line_hor:SetHidden(true) end
		if companion.line_vert then companion.line_vert:SetHidden(true) end
		--EVENT_MANAGER:UnregisterForEvent("BCUI_Event", EVENT_ACTION_LAYER_POPPED)
		EVENT_MANAGER:UnregisterForEvent("BCUI_Event", EVENT_ACTION_LAYER_PUSHED)
	end

	if (BCUI.Vars.ShowCompanionWhenSolo and not IsUnitGrouped('player') and BCUI.Vars.DetachFrameSolo) or 
		 (BCUI.Vars.ShowCompanionWhenInGroup and IsUnitGrouped('player') and BCUI.Vars.DetachFrameGroup) then		 		
		companion:SetParent(BanditsUI)
		companion:ClearAnchors() 
		companion:SetAnchor(BCUI.Vars.BCUI_CompanionFrame[1],BanditsUI,BCUI.Vars.BCUI_CompanionFrame[2],BCUI.Vars.BCUI_CompanionFrame[3],BCUI.Vars.BCUI_CompanionFrame[4])
	end

	local anchor={TOPLEFT,BOTTOMLEFT,0,(h+(comp and 0 or fs+3))*-(col-groupSize),companion}	
	if not IsUnitGrouped('player') then 
		anchor={TOPLEFT,LEFT,0,0,companion}
	elseif (BCUI.Vars.ShowCompanionWhenInGroup and BCUI.Vars.DetachFrameGroup) then		 		
		anchor={CENTER,TOPLEFT,(w/2),h,companion}
	end
	--Iterate over possible members
	for i=1, 6 do	
	local member	=BUI.UI.Control("BCUI_CompanionFrame"..i,		companion,		{w,h+(comp and 0 or fs+3)},	anchor,			true)
--	member.bg		=BUI.UI.Backdrop("BCUI_CompanionFrame"..i.."_Bg",	member,	{w-6*s+fs*1.2,h-2*s},		{TOPLEFT,TOPLEFT,-fs*1.2+2*s,0},{.3,.3,.2,.7}, {0,0,0,0}, nil, not comp) member.bg:SetDrawLayer(0)
	member.width=w
	member.index=i
	member:SetMouseEnabled(true)
	--member:SetHandler("OnMouseUp", Companion_OnMouseUp)
	member:SetHandler("OnMouseEnter", Companion_ShowTooltip)
	member:SetHandler("OnMouseExit", function()ClearTooltip(InformationTooltip)end)
	--Health Bar
	local health	=BUI.UI.Backdrop("BCUI_CompanionFrame"..i.."_Health",	member,	{w,hs},		{TOPLEFT,TOPLEFT,0,(comp and 0 or fs)},{0,0,0,0}, {1,1,1,1}, nil, false)
	health:SetDrawLayer(0) health:SetEdgeTexture(BUI.progress[BUI.Vars.Theme],32,4,4) health:SetEdgeColor(unpack(theme_color))
	health.bg		=BUI.UI.Backdrop("BCUI_CompanionFrame"..i.."_HealthBg",health,	{w-6*s,hs-6*s},	{TOPLEFT,TOPLEFT,3*s,3*s},	{0,0,0,1}, {0,0,0,0}, nil, false)
	health.bg:SetDrawLayer(0)
	health.bar		=BUI.UI.Statusbar("BCUI_CompanionFrame"..i.."_Bar",	health,	{w-4*s,hs-4*s},	{LEFT,LEFT,2*s,0},		ch, BUI.Textures[BUI.Vars.FramesTexture], false)
	health.bar:SetDrawLayer(1)
	member.shield	=BUI.UI.Backdrop(	"BCUI_CompanionFrame"..i.."_Shield",health,	{w,hs-4*s},		{RIGHT,RIGHT,-2*s,0},	{cw[1],cw[2],cw[3],.5}, {0,0,0,0}, nil, true)
	member.shield:SetDrawLayer(2)	--member.shield:SetEdgeTexture("",2,2,2)
	health.current	=BUI.UI.Label(	"BCUI_CompanionFrame"..i.."_Current",health,	{w*2/3,hs},		(comp and {RIGHT,RIGHT,-fs*1.3,0} or {LEFT,LEFT,8,0}),		BUI.UI.Font(BUI.Vars.FrameFont1,fs,true), nil, {comp and 2 or 0,1}, '0.0k', false)
	health.current:SetDrawLayer(3)
	health.pct		=BUI.UI.Label(	"BCUI_CompanionFrame"..i.."_Pct",	health,	{w*1/3,hs},		{RIGHT,RIGHT,-8*s,2*s},	BUI.UI.Font(BUI.Vars.FrameFont2,fs,true), nil, {2,1}, 'Pct%', true)
	health.pct:SetDrawLayer(3)
	health.hot		=BUI.UI.Texture(	"BCUI_CompanionFrame"..i.."_HoT",	health,	{hs*3/2,hs*3/4},	{LEFT,CENTER,-w/6,0},	'/BanditsUserInterface/textures/regen_sm.dds', true)
	health.hot:SetDrawLayer(3)
	health.dot		=BUI.UI.Texture(	"BCUI_CompanionFrame"..i.."_DoT",	health,	{hs*3/2,hs*3/4},	{RIGHT,CENTER,w/6,0},	'/BanditsUserInterface/textures/regen_sm.dds', true) health.dot:SetTextureRotation(math.pi)
	health.dot:SetDrawLayer(3)
	health.dps		=BUI.UI.Label(	"BCUI_CompanionFrame"..i.."_DPS",	health,	{w*2/3,hs},		{RIGHT,RIGHT,-8*s,0},	BUI.UI.Font(BUI.Vars.FrameFont1,fs,true), nil, {2,1}, '', false)
	health.dps:SetDrawLayer(3) member.dps=0 member.time=0
	member.health=health
	--Nameplate
	member.name		=BUI.UI.Label(	"BCUI_CompanionFrame"..i.."_Name",	health,	{w-(comp and fs*1.2+w/3.6 or fs*1.2),fs*1.3},		(comp and {LEFT,LEFT,2*s,0} or {BOTTOMLEFT,TOPLEFT,2*s,fs*.1}),	BUI.UI.Font(BUI.Vars.FrameFont1,fs,true), nil, {0,1}, "Member "..i, false)
	member.name:SetDrawLayer(3)
	member.lead		=BUI.UI.Texture(	"BCUI_CompanionFrame"..i.."_Lead",	health,	{fs*1.2,fs*.9},	(comp and {RIGHT,RIGHT,-3,-fs*.1} or {BOTTOMRIGHT,TOPRIGHT,0,-fs*.1}),	"/esoui/art/tutorial/gamepad/gp_playermenu_icon_store.dds",i~=1,nil,{0,1,0,.8}) member.lead:SetColor(1,1,.09)
	member.lead:SetDrawLayer(2)	
	--Status
	member.dead	=BUI.UI.Texture(	"BCUI_CompanionFrame"..i.."_Dead",		health,	{hs*1.3,hs*1.3},	{RIGHT,LEFT,0,0,member.resist},	'/esoui/art/icons/mapkey/mapkey_groupboss.dds', true)
	member.dead:SetDrawLayer(3)
	companion["companion"..i]=member
	local space=(split>1 and i%split==0) and hs or 0
	anchor=(i%col==0) and {TOPLEFT,TOPRIGHT,5*s+indent,0,_G["BCUI_CompanionFrame"..(i)]} or {TOP,BOTTOM,0,space-2*s,member}	
	end

  BCUI_CompanionFrame:SetAlpha(BCUI.Vars.AutoHide and 0 or BUI.Vars.FrameOpacityOut/100)
end

function BCUI.Frames.Fade(frame, hide)
	if not frame or BUI.move or BUI.inMenu then return end
	if hide then
		if frame.fade==nil then
			local animation, timeline=CreateSimpleAnimation(ANIMATION_ALPHA,frame,0)
			animation:SetAlphaValues(BUI.Vars.FrameOpacityOut/100,0)
			animation:SetEasingFunction(ZO_EaseOutQuadratic)
			animation:SetDuration((frame==BUI_CurvedTarget or frame==BUI_TargetFrame) and 500 or 1000)
			timeline:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT,1)
			frame.fade=timeline
		end
		if not(frame:GetAlpha()<.05 or frame.fade:IsPlaying()) then frame.fade:PlayFromStart() end
	else
		if frame.fade and frame.fade:IsPlaying() then frame.fade:Stop() end
		frame:SetAlpha(BUI.inCombat and BUI.Vars.FrameOpacityIn/100 or BUI.Vars.FrameOpacityOut/100)
		frame:SetHidden(false)
	end
end

function BCUI.Frames.SafetyCheck()
	--Companion frames	
	if BCUI.Vars.ShowCompanionWhenSolo or BCUI.Vars.ShowCompanionWhenInGroup then
		if BUI.inMenu then BCUI.Frames.Companion_UI() end
		if IsUnitGrouped('player') or HasActiveCompanion() or (BCUI.InSettingMenu or BUI.inMenu) or GetUnitName('playerpet1')~='' then BCUI.Frames:SetupGroup() elseif not BUI.inMenu and not BUI.move then BCUI_CompanionFrame:SetHidden(true) end
	end	
end
