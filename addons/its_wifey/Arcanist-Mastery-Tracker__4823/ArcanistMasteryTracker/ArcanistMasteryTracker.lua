local AMT = {}
local ADDON_NAME = "ArcanistMasteryTracker"

-- Public release v1.4.
AMT.version = "1.4"

-- Mastery / effect IDs proven by the existing v1.3 tracker.
local MAJOR_FORCE_ID = 61747
local INK_THRESHOLD = 100000
local ABYSSAL_EMERGENCE_ID = 263369
local CRUX_ID = 184220
local FATE_REALIGNED_BUFF_ID = 268372
local FATED_FORTUNE_EFFECT_ID = 194875
local MAJOR_VITALITY_ID = 61713
local FATEWOVEN_ARMOR_ID = 183648
local CRUXWEAVER_ARMOR_ID = 185908
local UNBREAKABLE_FATE_ID = 186477

local GIBBERING_SHIELD_ID = 183676
local GIBBERING_SHELTER_ID = 192380
local SANCTUM_ABYSSAL_SEA_ID = 192372
local BLOCK_MITIGATION_ADVANCED_STAT_ID = 7
local BLOCK_MITIGATION_CAP = 90

local MASTERIES = {
    ink      = { name="Ink-Scribe's Verve", skillId=263416, effectId=MAJOR_FORCE_ID, kind="ink" },
    abyssal  = { name="Abyssal Emergence", skillId=263316, effectId=ABYSSAL_EMERGENCE_ID, kind="timer" },
    fate     = { name="Fate Realigned", skillId=263398, effectId=FATE_REALIGNED_BUFF_ID, kind="timer" },
    unbound  = { name="Unbound Potential", skillId=263410, effectId=FATED_FORTUNE_EFFECT_ID, kind="timer" },
    erudite  = { name="Erudite's Rigor", skillId=263412, effectId=MAJOR_VITALITY_ID, kind="erudite" },
}
local ORDER = {"ink","abyssal","fate","unbound","erudite"}

local defaults = {
    enabled=true, hideOOC=true, locked=true,
    iconSize=52, textSize=18, showNames=true,
    x=40, y=180,
    textColor={1,1,1,1},
    masteryEnabled={ink=true,abyssal=true,fate=true,unbound=true,erudite=true},

    cruxEnabled=true, cruxX=220, cruxY=0, cruxSize=110, cruxTextSize=38,
    cruxTextColor={r=1,g=1,b=1,a=1}, cruxUnlocked=false, cruxHideOutOfCombat=true,

    gibberEnabled=true, gibberX=0, gibberY=200, gibberFontSize=32,
    gibberColor={r=.25,g=.85,b=1,a=1}, gibberUnlocked=false, showGibberTitle=true,

    blockEnabled=true, blockX=220, blockY=120, blockFontSize=30,
    blockColor={r=1,g=.85,b=.2,a=1}, blockCapColor={r=.3,g=1,b=.3,a=1},
    blockUnlocked=false, blockHideOutOfCombat=true,
}

local sv, inCombat=false
local selected, indices, controls = {}, {}, {}
local masteryFrame, cruxFrame, cruxTexture, cruxNumberLabel
local gibberFrame, gibberTitleLabel, gibberBar, gibberTimerLabel
local blockFrame, blockTitleLabel, blockValueLabel
local fragments = {}
local runningTotal, majorForceActive, majorForceEndTime = 0, false, 0
local active, endTime = {}, {}
local armorActive, armorEndTime = false, 0
local currentCrux = 0
local gibberActive, gibberEndTime = false, 0


local function IsHUDShowing()
    if not HUD_SCENE or not HUD_UI_SCENE then return false end
    return HUD_SCENE:IsShowing() or HUD_UI_SCENE:IsShowing()
end

local function IsTracked(key)
    return sv.enabled and sv.masteryEnabled[key] and selected[key]
end

local function SetInactive(key)
    local c=controls[key]; if not c then return end
    c.texture:SetDesaturation(1)
    c.texture:SetColor(.55,.55,.55,1)
    c.countdown:SetText("")
end

local function SetActive(key)
    local c=controls[key]; if not c then return end
    c.texture:SetDesaturation(0)
    c.texture:SetColor(1,1,1,1)
end

local function AddHUDFragment(control)
    local fragment=ZO_HUDFadeSceneFragment:New(control,nil,0)
    HUD_SCENE:AddFragment(fragment)
    HUD_UI_SCENE:AddFragment(fragment)
    fragments[#fragments+1]=fragment
end

local function SaveMasteryPosition()
    local l,t=masteryFrame:GetLeft(),masteryFrame:GetTop()
    local rl,rt=GuiRoot:GetLeft(),GuiRoot:GetTop()
    if l and t and rl and rt then sv.x=l-rl; sv.y=t-rt end
end

local function RefreshMasteryVisibility()
    if not IsHUDShowing() then masteryFrame:SetHidden(true); return end
    if not sv.enabled then masteryFrame:SetHidden(true); return end
    local any=false
    for _,key in ipairs(ORDER) do
        if IsTracked(key) then any=true break end
    end
    if not any then masteryFrame:SetHidden(true); return end
    if sv.hideOOC and not inCombat and sv.locked then masteryFrame:SetHidden(true) else masteryFrame:SetHidden(false) end
end

local function LayoutMasteries()
    local size=sv.iconSize
    local rowGap=math.max(6,math.floor(math.max(size,sv.textSize)*.12))
    local nameGap=math.max(8,math.floor(size*.15))
    local nameWidth=math.max(220,sv.textSize*14)
    local nameHeight=math.max(20,math.ceil(sv.textSize*1.35))
    local statusSize=math.max(12,sv.textSize-3)
    local statusHeight=math.max(18,math.ceil(statusSize*1.35))
    local textBlockHeight=nameHeight+1+statusHeight
    local rowHeight=math.max(size,textBlockHeight)
    local visible=0

    for _,key in ipairs(ORDER) do
        local c=controls[key]
        local show=IsTracked(key)
        c.row:SetHidden(not show)
        if show then
            c.row:ClearAnchors()
            c.row:SetAnchor(TOPLEFT,masteryFrame,TOPLEFT,0,visible*(rowHeight+rowGap))
            c.row:SetDimensions(size+nameGap+nameWidth,rowHeight)
            c.texture:SetDimensions(size,size)
            c.texture:ClearAnchors()
            c.texture:SetAnchor(LEFT,c.row,LEFT,0,0)
            c.countdown:SetDimensions(size,size)
            c.countdown:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick",math.max(14,math.floor(size*.36))))
            c.name:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick",sv.textSize))
            c.status:SetFont(string.format("$(MEDIUM_FONT)|%d|soft-shadow-thick",statusSize))
            c.name:ClearAnchors()
            c.name:SetAnchor(TOPLEFT,c.texture,TOPRIGHT,nameGap,math.max(0,math.floor((rowHeight-textBlockHeight)/2)))
            c.name:SetDimensions(nameWidth,nameHeight)
            c.status:ClearAnchors(); c.status:SetAnchor(TOPLEFT,c.name,BOTTOMLEFT,0,1)
            c.status:SetDimensions(nameWidth,statusHeight)
            visible=visible+1
        end
    end
    local totalHeight=visible>0 and (visible*rowHeight+math.max(0,visible-1)*rowGap) or size
    masteryFrame:SetDimensions(size+nameGap+nameWidth,totalHeight)
    RefreshMasteryVisibility()
end

local function ApplyTextColor()
    local c=sv.textColor
    for _,key in ipairs(ORDER) do
        controls[key].name:SetColor(c[1],c[2],c[3],c[4])
        controls[key].status:SetColor(c[1],c[2],c[3],c[4])
        controls[key].countdown:SetColor(c[1],c[2],c[3],c[4])
    end
end

local function FindMasteryIndices()
    indices={}
    local wanted={}
    for key,data in pairs(MASTERIES) do wanted[data.skillId]=key end
    for line=1,GetNumSkillLines(SKILL_TYPE_CLASS) do
        for ability=1,GetNumSkillAbilities(SKILL_TYPE_CLASS,line) do
            local id=GetSkillAbilityId(SKILL_TYPE_CLASS,line,ability,false)
            local key=wanted[id]
            if key then indices[key]={line=line,ability=ability} end
        end
    end
end

local function ScanSelectedMasteries()
    local changed=false
    for _,key in ipairs(ORDER) do
        local old=selected[key]
        local idx=indices[key]
        local purchased=false
        if idx then
            local _,_,_,_,_,isPurchased=GetSkillAbilityInfo(SKILL_TYPE_CLASS,idx.line,idx.ability)
            purchased=isPurchased == true
        end
        selected[key]=purchased
        if old~=purchased then changed=true end
        if not purchased then active[key]=false; endTime[key]=0; SetInactive(key) end
    end
    if changed then
        AMT:RefreshEventRegistration()
        LayoutMasteries()
    end
end

local function UpdateMasteryDisplay()
    local now=GetFrameTimeSeconds()
    for _,key in ipairs(ORDER) do
        local c=controls[key]
        if IsTracked(key) then
            c.name:SetHidden(not sv.showNames)
            if key=="ink" then
                if majorForceActive then
                    local rem=majorForceEndTime-now
                    if rem<=0 then majorForceActive=false; SetInactive(key); c.status:SetText(string.format("%d / %d",math.min(runningTotal,INK_THRESHOLD),INK_THRESHOLD))
                    else SetActive(key); c.countdown:SetText(tostring(math.ceil(rem))); c.status:SetText("Major Force active") end
                else
                    SetInactive(key)
                    if runningTotal>=INK_THRESHOLD then c.status:SetText("100,000 / 100,000 - PROC READY")
                    else c.status:SetText(string.format("%d / %d",math.min(runningTotal,INK_THRESHOLD),INK_THRESHOLD)) end
                end
            elseif key=="erudite" then
                if active[key] then
                    local rem=(endTime[key] or 0)-now
                    if rem<=0 then active[key]=false; SetInactive(key) else SetActive(key); c.countdown:SetText(tostring(math.ceil(rem))) end
                else SetInactive(key) end
                if armorActive then
                    local ar=armorEndTime-now
                    if ar>0 then c.status:SetText(string.format("Armor %.1fs",ar)) else armorActive=false; c.status:SetText("Armor down") end
                else c.status:SetText("Armor down") end
            else
                if active[key] then
                    local rem=(endTime[key] or 0)-now
                    if rem<=0 then active[key]=false; SetInactive(key); c.status:SetText("Inactive")
                    else SetActive(key); c.countdown:SetText(tostring(math.ceil(rem))); c.status:SetText("Active") end
                else SetInactive(key); c.status:SetText("Inactive") end
            end
        end
    end
    RefreshMasteryVisibility()
end

local HEAL_RESULTS={
    ACTION_RESULT_HEAL, ACTION_RESULT_CRITICAL_HEAL,
    ACTION_RESULT_HOT_TICK, ACTION_RESULT_HOT_TICK_CRITICAL,
}
local function OnInkHeal(_,_,_,_,_,_,_,_,_,_,hitValue,_,_,_,_,_,_,overflow)
    if not inCombat or not IsTracked("ink") then return end
    local raw=(tonumber(hitValue) or 0)+(tonumber(overflow) or 0)
    if raw>0 then runningTotal=runningTotal+raw end
end

function AMT:RegisterInkEvents()
    for i,result in ipairs(HEAL_RESULTS) do
        local n=ADDON_NAME.."_InkHeal"..i
        EVENT_MANAGER:RegisterForEvent(n,EVENT_COMBAT_EVENT,OnInkHeal)
        EVENT_MANAGER:AddFilterForEvent(n,EVENT_COMBAT_EVENT,
            REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE,COMBAT_UNIT_TYPE_PLAYER,
            REGISTER_FILTER_COMBAT_RESULT,result)
    end
end
function AMT:UnregisterInkEvents()
    for i=1,#HEAL_RESULTS do EVENT_MANAGER:UnregisterForEvent(ADDON_NAME.."_InkHeal"..i,EVENT_COMBAT_EVENT) end
end

local function EffectHandler(key)
    return function(_,changeType,_,_,_,beginT,endT,_,_,_,_,_,_,_,_,_,abilityId,sourceType)
        if changeType==EFFECT_RESULT_GAINED or changeType==EFFECT_RESULT_UPDATED or changeType==EFFECT_RESULT_FULL_REFRESH then
            if key=="ink" then majorForceActive=true; majorForceEndTime=endT; runningTotal=0
            elseif key=="erudite" then active[key]=true; endTime[key]=endT
            else active[key]=true; endTime[key]=endT end
        elseif changeType==EFFECT_RESULT_FADED then
            if key=="ink" then majorForceActive=false
            else active[key]=false; endTime[key]=0 end
        end
    end
end

local function RegisterEffect(name,id,handler,sourceOnly)
    EVENT_MANAGER:RegisterForEvent(name,EVENT_EFFECT_CHANGED,handler)
    EVENT_MANAGER:AddFilterForEvent(name,EVENT_EFFECT_CHANGED,REGISTER_FILTER_ABILITY_ID,id,REGISTER_FILTER_UNIT_TAG,"player")
    if sourceOnly then
        EVENT_MANAGER:AddFilterForEvent(name,EVENT_EFFECT_CHANGED,REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE,COMBAT_UNIT_TYPE_PLAYER)
    end
end

function AMT:RefreshEventRegistration()
    self:UnregisterInkEvents()
    for _,key in ipairs(ORDER) do EVENT_MANAGER:UnregisterForEvent(ADDON_NAME.."_Mastery_"..key,EVENT_EFFECT_CHANGED) end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME.."_Armor1",EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME.."_Armor2",EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME.."_Armor3",EVENT_EFFECT_CHANGED)

    if IsTracked("ink") then
        self:RegisterInkEvents()
        RegisterEffect(ADDON_NAME.."_Mastery_ink",MAJOR_FORCE_ID,EffectHandler("ink"),true)
    end
    for _,key in ipairs({"abyssal","fate","unbound","erudite"}) do
        if IsTracked(key) then RegisterEffect(ADDON_NAME.."_Mastery_"..key,MASTERIES[key].effectId,EffectHandler(key),true) end
    end
    if IsTracked("erudite") then
        local function armor(_,changeType,_,_,_,_,e)
            if changeType==EFFECT_RESULT_GAINED or changeType==EFFECT_RESULT_UPDATED or changeType==EFFECT_RESULT_FULL_REFRESH then armorActive=true; armorEndTime=e
            elseif changeType==EFFECT_RESULT_FADED then armorActive=false; armorEndTime=0 end
        end
        RegisterEffect(ADDON_NAME.."_Armor1",FATEWOVEN_ARMOR_ID,armor,true)
        RegisterEffect(ADDON_NAME.."_Armor2",CRUXWEAVER_ARMOR_ID,armor,true)
        RegisterEffect(ADDON_NAME.."_Armor3",UNBREAKABLE_FATE_ID,armor,true)
    end
end

-- Crux utility
local function ScanCurrentCrux()
    currentCrux=0
    for i=1,GetNumBuffs("player") do
        local _,_,_,_,stacks,_,_,_,_,_,id=GetUnitBuffInfo("player",i)
        if id==CRUX_ID then currentCrux=stacks or 0 break end
    end
end
local function UpdateCrux()
    if not IsHUDShowing() then cruxFrame:SetHidden(true); return end
    if not sv.cruxEnabled or (sv.cruxHideOutOfCombat and not inCombat and not sv.cruxUnlocked) then cruxFrame:SetHidden(true); return end
    cruxFrame:SetHidden(false); cruxNumberLabel:SetText(tostring(currentCrux))
end

local function UpdateGibber()
    if not IsHUDShowing() then gibberFrame:SetHidden(true); return end
    if not sv.gibberEnabled then gibberFrame:SetHidden(true); return end
    if not sv.gibberUnlocked and not gibberActive then gibberFrame:SetHidden(true); return end
    gibberFrame:SetHidden(false)
    gibberTitleLabel:SetHidden(not sv.showGibberTitle)
    local rem=gibberEndTime-GetFrameTimeSeconds()
    if gibberActive and rem>0 then gibberBar:SetValue(math.min(10,rem)); gibberTimerLabel:SetText(rem<=5 and tostring(math.ceil(rem)) or string.format("%.1fs",rem))
    else gibberActive=false; gibberBar:SetValue(10); gibberTimerLabel:SetText("10.0s") end
end

local function GetBlockMitigationPercent()
    local _,_,pct=GetAdvancedStatValue(BLOCK_MITIGATION_ADVANCED_STAT_ID)
    return tonumber(pct) or 0
end
local function UpdateBlock()
    if not IsHUDShowing() then blockFrame:SetHidden(true); return end
    if not sv.blockEnabled or (sv.blockHideOutOfCombat and not inCombat and not sv.blockUnlocked) then blockFrame:SetHidden(true); return end
    blockFrame:SetHidden(false)
    local pct=math.floor(GetBlockMitigationPercent()+.5)
    if pct>=BLOCK_MITIGATION_CAP then
        blockValueLabel:SetText(string.format("%d%% - CAPPED",pct)); local c=sv.blockCapColor; blockValueLabel:SetColor(c.r,c.g,c.b,c.a)
    else
        blockValueLabel:SetText(string.format("%d%% / %d%%",pct,BLOCK_MITIGATION_CAP)); local c=sv.blockColor; blockValueLabel:SetColor(c.r,c.g,c.b,c.a)
    end
end

local function SaveCentered(frame,xk,yk)
    local x,y=frame:GetCenter(); local rx,ry=GuiRoot:GetCenter()
    if x and y and rx and ry then sv[xk]=x-rx; sv[yk]=y-ry end
end
local function Position(frame,x,y) frame:ClearAnchors(); frame:SetAnchor(CENTER,GuiRoot,CENTER,x,y) end
local function Unlock(frame,v) frame:SetMouseEnabled(v); frame:SetMovable(v) end

local function CreateUI()
    local wm=WINDOW_MANAGER
    masteryFrame=wm:CreateTopLevelWindow(ADDON_NAME.."MasteryFrame")
    masteryFrame:SetClampedToScreen(true); masteryFrame:SetMovable(true)
    masteryFrame:SetAnchor(TOPLEFT,GuiRoot,TOPLEFT,sv.x,sv.y)
    masteryFrame:SetHandler("OnMoveStop",SaveMasteryPosition)
    Unlock(masteryFrame,not sv.locked)

    for _,key in ipairs(ORDER) do
        local d=MASTERIES[key]
        local row=wm:CreateControl(ADDON_NAME.."Row_"..key,masteryFrame,CT_CONTROL)
        local tex=wm:CreateControl(ADDON_NAME.."Icon_"..key,row,CT_TEXTURE)
        tex:SetAnchor(LEFT,row,LEFT,0,0); tex:SetTexture(GetAbilityIcon(d.skillId))
        local cd=wm:CreateControl(ADDON_NAME.."Countdown_"..key,row,CT_LABEL)
        cd:SetAnchor(CENTER,tex,CENTER,0,0); cd:SetHorizontalAlignment(TEXT_ALIGN_CENTER); cd:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        local name=wm:CreateControl(ADDON_NAME.."Name_"..key,row,CT_LABEL)
        name:SetText(d.name); name:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        local status=wm:CreateControl(ADDON_NAME.."Status_"..key,row,CT_LABEL)
        status:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        controls[key]={row=row,texture=tex,countdown=cd,name=name,status=status}
        SetInactive(key)
    end
    LayoutMasteries(); ApplyTextColor(); AddHUDFragment(masteryFrame)

    cruxFrame=wm:CreateTopLevelWindow(ADDON_NAME.."CruxFrame"); cruxFrame:SetClampedToScreen(true)
    cruxFrame:SetDimensions(sv.cruxSize,sv.cruxSize); Position(cruxFrame,sv.cruxX,sv.cruxY)
    cruxFrame:SetHandler("OnMoveStop",function() SaveCentered(cruxFrame,"cruxX","cruxY") end); Unlock(cruxFrame,sv.cruxUnlocked)
    cruxTexture=wm:CreateControl(ADDON_NAME.."CruxTexture",cruxFrame,CT_TEXTURE); cruxTexture:SetAnchorFill(cruxFrame)
    cruxTexture:SetTexture("/art/fx/texture/arcanist_tank4_runicglowlines.dds")
    cruxNumberLabel=wm:CreateControl(ADDON_NAME.."CruxNumber",cruxFrame,CT_LABEL); cruxNumberLabel:SetAnchorFill(cruxFrame)
    cruxNumberLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER); cruxNumberLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    cruxNumberLabel:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick",sv.cruxTextSize))
    local cc=sv.cruxTextColor; cruxNumberLabel:SetColor(cc.r,cc.g,cc.b,cc.a); AddHUDFragment(cruxFrame)

    gibberFrame=wm:CreateTopLevelWindow(ADDON_NAME.."GibberFrame"); gibberFrame:SetDimensions(420,125); Position(gibberFrame,sv.gibberX,sv.gibberY)
    gibberFrame:SetHandler("OnMoveStop",function() SaveCentered(gibberFrame,"gibberX","gibberY") end); Unlock(gibberFrame,sv.gibberUnlocked)
    gibberTitleLabel=wm:CreateControl(ADDON_NAME.."GibberTitle",gibberFrame,CT_LABEL); gibberTitleLabel:SetAnchor(TOP,gibberFrame,TOP,0,0); gibberTitleLabel:SetText("GIBBERING SHIELD")
    gibberTitleLabel:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick",sv.gibberFontSize))
    gibberBar=wm:CreateControl(ADDON_NAME.."GibberBar",gibberFrame,CT_STATUSBAR); gibberBar:SetDimensions(300,18); gibberBar:SetAnchor(TOP,gibberTitleLabel,BOTTOM,0,8); gibberBar:SetMinMax(0,10); gibberBar:SetValue(10)
    gibberTimerLabel=wm:CreateControl(ADDON_NAME.."GibberTimer",gibberFrame,CT_LABEL); gibberTimerLabel:SetAnchor(TOP,gibberBar,BOTTOM,0,5)
    gibberTimerLabel:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick",sv.gibberFontSize)); local gc=sv.gibberColor; gibberTimerLabel:SetColor(gc.r,gc.g,gc.b,gc.a); AddHUDFragment(gibberFrame)

    blockFrame=wm:CreateTopLevelWindow(ADDON_NAME.."BlockFrame"); blockFrame:SetDimensions(420,105); Position(blockFrame,sv.blockX,sv.blockY)
    blockFrame:SetHandler("OnMoveStop",function() SaveCentered(blockFrame,"blockX","blockY") end); Unlock(blockFrame,sv.blockUnlocked)
    blockTitleLabel=wm:CreateControl(ADDON_NAME.."BlockTitle",blockFrame,CT_LABEL); blockTitleLabel:SetAnchor(TOP,blockFrame,TOP,0,0); blockTitleLabel:SetText("BLOCK MITIGATION")
    blockTitleLabel:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick",sv.blockFontSize))
    blockValueLabel=wm:CreateControl(ADDON_NAME.."BlockValue",blockFrame,CT_LABEL); blockValueLabel:SetAnchor(TOP,blockTitleLabel,BOTTOM,0,6)
    blockValueLabel:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick",sv.blockFontSize)); AddHUDFragment(blockFrame)
end

local function RegisterUtilityEvents()
    RegisterEffect(ADDON_NAME.."_Crux",CRUX_ID,function(_,changeType,_,_,_,_,_,stacks)
        if changeType==EFFECT_RESULT_GAINED or changeType==EFFECT_RESULT_UPDATED or changeType==EFFECT_RESULT_FULL_REFRESH then currentCrux=stacks or 0
        elseif changeType==EFFECT_RESULT_FADED then currentCrux=0 end
    end,true)
    for i,id in ipairs({GIBBERING_SHIELD_ID,GIBBERING_SHELTER_ID,SANCTUM_ABYSSAL_SEA_ID}) do
        RegisterEffect(ADDON_NAME.."_Gibber"..i,id,function(_,changeType,_,_,_,_,e)
            if changeType==EFFECT_RESULT_GAINED or changeType==EFFECT_RESULT_UPDATED or changeType==EFFECT_RESULT_FULL_REFRESH then gibberActive=true; gibberEndTime=e
            elseif changeType==EFFECT_RESULT_FADED then gibberActive=false; gibberEndTime=0 end
        end,true)
    end
end

local function CreateSettings()
    if not LibAddonMenu2 then return end
    local LAM=LibAddonMenu2
    LAM:RegisterAddonPanel(ADDON_NAME.."Options",{type="panel",name="Arcanist Mastery Tracker",displayName="Arcanist Mastery Tracker",author="WifeyRytic",version=AMT.version,registerForRefresh=true,registerForDefaults=true})
    local opts={
        {type="header",name="Mastery Tracker"},
        {type="checkbox",name="Enable Mastery Tracker",getFunc=function() return sv.enabled end,setFunc=function(v) sv.enabled=v AMT:RefreshEventRegistration(); LayoutMasteries() end,default=defaults.enabled},
        {type="checkbox",name="Hide Masteries Out of Combat",getFunc=function() return sv.hideOOC end,setFunc=function(v) sv.hideOOC=v RefreshMasteryVisibility() end,default=defaults.hideOOC},
        {type="checkbox",name="Lock Mastery Tracker",getFunc=function() return sv.locked end,setFunc=function(v) sv.locked=v Unlock(masteryFrame,not v); RefreshMasteryVisibility() end,default=defaults.locked},
        {type="checkbox",name="Show Mastery Names",getFunc=function() return sv.showNames end,setFunc=function(v) sv.showNames=v LayoutMasteries() end,default=defaults.showNames},
        {type="slider",name="Icon Size",min=28,max=100,step=1,getFunc=function() return sv.iconSize end,setFunc=function(v) sv.iconSize=v LayoutMasteries() end,default=defaults.iconSize},
        {type="slider",name="Mastery Text Size",tooltip="Changes the mastery name/status text without changing the icon size.",min=12,max=40,step=1,getFunc=function() return sv.textSize end,setFunc=function(v) sv.textSize=v LayoutMasteries() end,default=defaults.textSize},
        {type="colorpicker",name="Mastery Text Color",getFunc=function() return unpack(sv.textColor) end,setFunc=function(r,g,b,a) sv.textColor={r,g,b,a}; ApplyTextColor() end,default={r=1,g=1,b=1,a=1}},
    }
    for _,key in ipairs(ORDER) do
        opts[#opts+1]={type="checkbox",name=MASTERIES[key].name,getFunc=function() return sv.masteryEnabled[key] end,setFunc=function(v) sv.masteryEnabled[key]=v AMT:RefreshEventRegistration(); LayoutMasteries() end,default=true}
    end
    opts[#opts+1]={type="button",name="Reset Mastery Position",func=function() sv.x=defaults.x; sv.y=defaults.y; masteryFrame:ClearAnchors(); masteryFrame:SetAnchor(TOPLEFT,GuiRoot,TOPLEFT,sv.x,sv.y) end}
    opts[#opts+1]={type="header",name="Crux Counter"}
    opts[#opts+1]={type="checkbox",name="Enable Crux Counter",getFunc=function() return sv.cruxEnabled end,setFunc=function(v) sv.cruxEnabled=v UpdateCrux() end,default=true}
    opts[#opts+1]={type="checkbox",name="Unlock Crux Counter",getFunc=function() return sv.cruxUnlocked end,setFunc=function(v) sv.cruxUnlocked=v Unlock(cruxFrame,v); UpdateCrux() end,default=false}
    opts[#opts+1]={type="checkbox",name="Hide Crux Out of Combat",getFunc=function() return sv.cruxHideOutOfCombat end,setFunc=function(v) sv.cruxHideOutOfCombat=v UpdateCrux() end,default=true}
    opts[#opts+1]={type="slider",name="Crux Counter Size",min=50,max=200,step=1,getFunc=function() return sv.cruxSize end,setFunc=function(v) sv.cruxSize=v; cruxFrame:SetDimensions(v,v) end,default=110}
    opts[#opts+1]={type="slider",name="Crux Number Size",min=20,max=80,step=1,getFunc=function() return sv.cruxTextSize end,setFunc=function(v) sv.cruxTextSize=v; cruxNumberLabel:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick",v)) end,default=38}
    opts[#opts+1]={type="header",name="Gibbering Shield"}
    opts[#opts+1]={type="checkbox",name="Enable Gibbering Shield",getFunc=function() return sv.gibberEnabled end,setFunc=function(v) sv.gibberEnabled=v UpdateGibber() end,default=true}
    opts[#opts+1]={type="checkbox",name="Unlock Gibbering Shield",getFunc=function() return sv.gibberUnlocked end,setFunc=function(v) sv.gibberUnlocked=v Unlock(gibberFrame,v); UpdateGibber() end,default=false}
    opts[#opts+1]={type="header",name="Block Mitigation"}
    opts[#opts+1]={type="checkbox",name="Enable Block Mitigation",getFunc=function() return sv.blockEnabled end,setFunc=function(v) sv.blockEnabled=v UpdateBlock() end,default=true}
    opts[#opts+1]={type="checkbox",name="Unlock Block Mitigation",getFunc=function() return sv.blockUnlocked end,setFunc=function(v) sv.blockUnlocked=v Unlock(blockFrame,v); UpdateBlock() end,default=false}
    opts[#opts+1]={type="checkbox",name="Hide Block Out of Combat",getFunc=function() return sv.blockHideOutOfCombat end,setFunc=function(v) sv.blockHideOutOfCombat=v UpdateBlock() end,default=true}
    LAM:RegisterOptionControls(ADDON_NAME.."Options",opts)
end

local function OnCombatState(_,state)
    inCombat=state
    if state then runningTotal=0 else
        runningTotal=0; majorForceActive=false
        for _,key in ipairs(ORDER) do active[key]=false; endTime[key]=0; SetInactive(key) end
    end
    UpdateMasteryDisplay(); UpdateCrux(); UpdateGibber(); UpdateBlock()
end

local function OnPlayerActivated()
    inCombat=IsUnitInCombat("player")
    FindMasteryIndices(); ScanSelectedMasteries(); ScanCurrentCrux()
    UpdateMasteryDisplay(); UpdateCrux(); UpdateGibber(); UpdateBlock()
end

local nextScan=0
local function OnUpdate()
    local now=GetFrameTimeSeconds()
    if now>=nextScan then nextScan=now+.5; ScanSelectedMasteries() end
    UpdateMasteryDisplay(); UpdateCrux(); UpdateGibber(); UpdateBlock()
end

local function OnLoaded(_,addonName)
    if addonName~=ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME,EVENT_ADD_ON_LOADED)
    sv=ZO_SavedVars:NewAccountWide("ArcanistMasteryTrackerSavedVariables",2,nil,defaults)
    -- Migration safety for users coming from v1.3.
    if not sv.masteryEnabled then sv.masteryEnabled={ink=true,abyssal=true,fate=true,unbound=true,erudite=true} end
    if not sv.textColor or sv.textColor.r then sv.textColor={1,1,1,1} end
    inCombat=IsUnitInCombat("player")
    CreateUI(); FindMasteryIndices(); ScanSelectedMasteries(); ScanCurrentCrux()
    RegisterUtilityEvents(); AMT:RefreshEventRegistration(); CreateSettings()
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME.."_CombatState",EVENT_PLAYER_COMBAT_STATE,OnCombatState)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME.."_Activated",EVENT_PLAYER_ACTIVATED,OnPlayerActivated)
    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME.."_Update",100,OnUpdate)
    UpdateMasteryDisplay(); UpdateCrux(); UpdateGibber(); UpdateBlock()
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME,EVENT_ADD_ON_LOADED,OnLoaded)
