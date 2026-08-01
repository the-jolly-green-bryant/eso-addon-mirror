local messages={}
local LastWipe,LastPowerValue=0,0
local ResultDamage={[ACTION_RESULT_DAMAGE]=true,[ACTION_RESULT_CRITICAL_DAMAGE]=true,[ACTION_RESULT_BLOCKED_DAMAGE]=true,[ACTION_RESULT_DOT_TICK]=true,[ACTION_RESULT_DOT_TICK_CRITICAL]=true,[ACTION_RESULT_DAMAGE_SHIELDED]=true}
local CallBackCompanion=false

local function OnGroupChanged(_,unitTag)	
	if BUI.init.Frames and BCUI.Vars.ShowCompanionWhenInGroup then
		BCUI.Frames.Companion_UI()
		BCUI.Frames:SetupGroup()
		for i=1, 4 do
			local frame=BCUI_CompanionFrame["companion"..i]
			frame.health.dps:SetText("")			
		end
	elseif IsUnitGrouped('player') then
		BCUI.Frames.Companion_UI()
		BCUI.Frames.GetGroupData()
	end
end

local function OnGroupLeave(_,characterName)
	local name=string.gsub(characterName,"%^%w+","")	--zo_strformat(SI_UNIT_NAME, characterName)
	if name==BUI.Player.name then
		BUI.Companions={}		
		--Clear group info		
		for i=1, 4 do
			local frame=BCUI_CompanionFrame["companion"..i]
			frame.health.dps:SetText("")			
		end		
	end
	--Group frame
	if BUI.init.Frames and (BCUI.Vars.ShowCompanionWhenSolo or BCUI.Vars.ShowCompanionWhenInGroup) then 
		BCUI.Frames.Companion_UI()
		BCUI.Frames:SetupGroup() 
	end	
end

local function CompanionAutoDismiss()
	local PvPzone=IsPlayerInAvAWorld() or IsActiveWorldBattleground()
	if not PvPzone then
		if BUI.IsTrialLobby() and HasActiveCompanion() then
			for i, data in pairs(BCUI.CompanionInfo) do
				if i~="activeId" and data.id==GetCompanionCollectibleId(GetActiveCompanionDefId()) then BCUI.Binds.DismissCompanion(data, 2500) CallBackCompanion=data return end
			end
		elseif CallBackCompanion and not BUI.IsPlayerInTrial() and not HasActiveCompanion() then
			--d(CallBackCompanion)
			BCUI.Binds.SummonCompanion(CallBackCompanion, 2500)
			CallBackCompanion=false			
		end
	end
end

local function OnActivated()	
	if BUI.init.Frames then
		if BCUI.Vars.ShowCompanionWhenSolo or BCUI.Vars.ShowCompanionWhenInGroup then BCUI.Frames:SetupGroup() end
	end	
	
	if BCUI.Vars.CompanionAutoDismiss then zo_callLater(function() CompanionAutoDismiss() end,2500) end
end

local function OnLoad()
	OnGroupChanged()
	--Flush messages
	for i=1, #messages do d(messages[i]) end messages={}

	OnActivated()
	--Switch to recurring event
	EVENT_MANAGER:UnregisterForEvent("BCUI_Event", EVENT_PLAYER_ACTIVATED)
	EVENT_MANAGER:RegisterForEvent("BCUI_Event", EVENT_PLAYER_ACTIVATED, OnActivated)
end

--ATTRIBUTE EVENTS
local function OnPowerUpdate(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
	if BCUI.Companions and string.match(unitTag, "companion") then
		--Health
		if (powerType==POWERTYPE_HEALTH) then
			if BUI.init.Frames then
				BCUI.Frames:UpdateAttribute(unitTag, powerType, powerValue, powerMax, powerEffectiveMax)
			end
		end
	end
end

local function OnVisualAdded(eventCode, unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue, sequenceId)
--	d(GetUnitName(unitTag)..": Event="..unitAttributeVisual.." Stat="..statType.." Attribute="..attributeType.." Power="..powerType.." Sequence="..sequenceId)
	if not BUI.init.Frames then return end
	if BCUI.Companions and BCUI.Companions[unitTag] then
		if powerType==POWERTYPE_HEALTH then
			if unitAttributeVisual==ATTRIBUTE_VISUAL_POWER_SHIELDING then
				BCUI.Frames:UpdateShield(unitTag, (sequenceId==0 and value or 0), maxValue)
			elseif unitAttributeVisual==ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER or unitAttributeVisual==ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER then
				BUI.Frames:GroupRegen(unitTag,unitAttributeVisual,powerType,(sequenceId==0 and 2000 or 0))
				if unitAttributeVisual==ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER then
					BUI.Frames:AttributeVisual(unitTag,unitAttributeVisual,sequenceId==0)
				end
			elseif statType==3 and unitAttributeVisual==ATTRIBUTE_VISUAL_DECREASED_STAT then
				BUI.Frames:AttributeVisual(unitTag,unitAttributeVisual,sequenceId==0)
			end
		end		
	end
end

local function OnVisualUpdate(eventCode, unitTag, unitAttributeVisual, statType, attributeType, powerType, oldValue, newValue, oldMaxValue, newMaxValue)
	if not BUI.init.Frames then return end	
	--Damage Shields
	if powerType==POWERTYPE_HEALTH and unitAttributeVisual==ATTRIBUTE_VISUAL_POWER_SHIELDING then
		BCUI.Frames:UpdateShield(unitTag, newValue, newMaxValue)
	end
end

function BCUI.RegisterEvents()
	EVENT_MANAGER:RegisterForEvent("BCUI_Event", EVENT_PLAYER_ACTIVATED,			OnLoad)
	EVENT_MANAGER:RegisterForEvent("BCUI_Event", EVENT_GROUP_MEMBER_JOINED,			OnGroupChanged)
	EVENT_MANAGER:RegisterForEvent("BCUI_Event", EVENT_UNIT_CREATED,				OnGroupChanged)
	EVENT_MANAGER:RegisterForEvent("BCUI_Event", EVENT_GROUP_MEMBER_LEFT,			OnGroupLeave)
	--Attribute Events
	EVENT_MANAGER:RegisterForEvent("BCUI_Event", EVENT_POWER_UPDATE,				OnPowerUpdate)
	EVENT_MANAGER:RegisterForEvent("BCUI_Event", EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED,	OnVisualAdded)
	EVENT_MANAGER:RegisterForEvent("BCUI_Event", EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED,	OnVisualUpdate)
	EVENT_MANAGER:RegisterForEvent("BCUI_Event", EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED,	OnVisualAdded)
end

local function TargetReactionUpdate()
  if BCUI_CompanionFrame then
    local color

    if BUI.Target.Invul then
      color = ReactionColor["INVULNERABLE"]
    else
      local reaction = GetUnitReaction('reticleover')
      color          = (reaction == 1 or reaction == 3) and BUI.Vars.FrameHealthColor or ReactionColor[reaction]
    end
    BCUI.Target.color = color
    BCUI_CompanionFrame.health.bar:SetColor(unpack(color))
  end
end

local step    = 10;
local current = 100;
local function TargetFrameAnimate()
  	local powerMax   = 100000
  	local percent    = current / 100
  	local powerValue = powerMax * percent
	if IsUnitGrouped('player') then
	  	for i=1,BCUI.Companions.members do
			local unitTag	=GetGroupUnitTagByIndex(i)
			local companionTag = GetCompanionUnitTagByGroupUnitTag(unitTag)
			if companionTag and string.match(companionTag, "companion") then
				BCUI.Frames:UpdateAttribute(companionTag, POWERTYPE_HEALTH, powerValue, powerMax, percent)  
				for i=1,6 do
					BCUI.Frames:UpdateAttribute('playerpet'..i, POWERTYPE_HEALTH, powerValue+(10000*i), powerMax+(10000*i), percent)
				end
				if current - step >= 0 then
				    current = current - step
				else
				    current = 100;
				    BUI.Frames.TargetReactionUpdate()
				end
			end
		end
	else
		BCUI.Frames:UpdateAttribute('companion', POWERTYPE_HEALTH, powerValue, powerMax, percent)
		for i=1,6 do
			BCUI.Frames:UpdateAttribute('playerpet'..i, POWERTYPE_HEALTH, powerValue+(10000*i), powerMax+(10000*i), percent)
		end
		if current - step >= 0 then
		    current = current - step
		else
		    current = 100;
		    BUI.Frames.TargetReactionUpdate()
		end		
	end
end

function BCUI.MoveFrames()
	_G["BUI_SettingsWindow"]:SetHidden(true)
	SCENE_MANAGER:ShowBaseScene()
  BCUI.InSettingMenu=true  
  BCUI.FramesLocked=false
  BCUI.Frames.Companion_UI()
  BCUI.Frames:SetupGroup()
end

function BCUI.EventShowBUIMenu()
	BUI.Menu.Open()
  BUI.inMenu=true
  BCUI.InSettingMenu=true
  BCUI.FramesLocked=true
  BCUI.Frames.Companion_UI()
  BCUI.Frames:SetupGroup()
end

function BCUI.TargetFrameShowPreview()
  BCUI.InSettingMenu=true  
  BCUI.Frames.Companion_UI()
  BCUI.Frames:SetupGroup()
  EVENT_MANAGER:UnregisterForUpdate("TargetFramePreviewAnimate")
  EVENT_MANAGER:RegisterForUpdate("TargetFramePreviewAnimate", 500, TargetFrameAnimate)  
  EVENT_MANAGER:UnregisterForUpdate("BCUI_CompanionFrame",BCUI.Frames.SafetyCheck)  
end

function BCUI.TargetFrameHidePreview()
  BCUI.InSettingMenu=false
  BCUI.Frames.Companion_UI()  
  BCUI.Frames:SetupGroup()
  EVENT_MANAGER:UnregisterForUpdate("TargetFramePreviewAnimate")
  EVENT_MANAGER:RegisterForUpdate("BCUI_CompanionFrame",5000,BCUI.Frames.SafetyCheck)
end