-- Templar Mastery v1.3.1 TEST
-- Author: WifeyRytic
-- LUA ONLY. NO XML.
-- v1.3.1 is the first v1.4 modernization test build.

TemplarMastery = {}
local TM = TemplarMastery

TM.name = "TemplarMastery"
TM.version = "1.4"

TM.MASTERY = {
    bastion   = 263585,
    devout    = 263586,
    bright    = 263587,
    judgment  = 263588,
    steadfast = 263589,
}

TM.ID = {
    illuminate      = 62800,
    judgmentProc    = 263660,
    holdTheLine     = 263619,
    steadfastProc   = 263643,
    sacredGround    = 31759,
    missionaryHeal  = 266178,
    missionaryUlt   = 267069,
}

TM.pretty = {
    bastion   = "BASTION OF LIGHT",
    devout    = "DEVOUT GUARDIAN",
    bright    = "BRIGHT HARBINGER",
    judgment  = "JUDGMENT'S BRAND",
    steadfast = "STEADFAST CANDESCENCE",
}

TM.ORDER = {"bastion","devout","bright","judgment","steadfast"}

TM.defaults = {
    enabled = true,
    hideOutOfCombat = false,
    locked = true,

    -- NEW standard: icon size and text size are independent.
    iconSize = 52,
    fontSize = 24,
    showIcons = true,
    showNames = true,

    textColor = {1.0,0.8235,0.2745,1},
    warningColor = {1,0.15,0.15,1},

    trackers = {
        bright=true,
        judgment=true,
        devout=true,
        steadfast=true,
        bastion=true,
    },

    positions = {
        bastion   = {x=0,y=-180},
        devout    = {x=0,y=-90},
        bright    = {x=0,y=0},
        judgment  = {x=0,y=90},
        steadfast = {x=0,y=180},
    },
}

TM.controls = {}
TM.fragments = {}
TM.selected = {}
TM.testUntil = {}
TM.registered = {}
TM.state = {
    brightEnd = 0,
    judgmentEnd = 0,
    devoutEnd = 0,
    bastionUntil = 0,
    bastionUltUntil = 0,
}

local function Now() return GetFrameTimeSeconds() end
local function Color(c) return c[1],c[2],c[3],c[4] end

function TM:IsInCombat()
    return IsUnitInCombat("player")
end

function TM:IsUnlockedPreview()
    return not self.sv.locked
end

-- Same HUD rule proven in Sorcerer/Arcanist:
-- addon controls may only show while ESO's HUD/HUD_UI scene is showing.
function TM:IsHUDShowing()
    if not HUD_SCENE or not HUD_UI_SCENE then return false end
    return HUD_SCENE:IsShowing() or HUD_UI_SCENE:IsShowing()
end

function TM:IsTesting(key)
    return (self.testUntil[key] or 0) > Now()
end

function TM:IsSelected(key)
    return self.selected[key] == true
end

function TM:IsTracked(key)
    return self.sv.enabled and self.sv.trackers[key] and self:IsSelected(key)
end

function TM:CanDisplayNormal()
    if not self.sv.enabled then return false end
    if not self:IsHUDShowing() then return false end
    if self.sv.hideOutOfCombat and not self:IsInCombat() then return false end
    return true
end

function TM:GetIcon(id)
    local tex = GetAbilityIcon(id)
    if tex and tex ~= "" then return tex end
    return "/esoui/art/icons/icon_missing.dds"
end

function TM:AddHUDFragment(control)
    local fragment = ZO_HUDFadeSceneFragment:New(control,nil,0)
    HUD_SCENE:AddFragment(fragment)
    HUD_UI_SCENE:AddFragment(fragment)
    self.fragments[#self.fragments+1] = fragment
end

function TM:ApplyPosition(key)
    local c = self.controls[key]
    if not c then return end
    local p = self.sv.positions[key]
    local size = self.sv.iconSize or self.defaults.iconSize
    local rowHeight = c:GetHeight() > 0 and c:GetHeight() or size
    c:ClearAnchors()
    -- Saved position is the ICON center, not the changing control center.
    -- This keeps the tracker where the user placed it when text/icon size changes.
    c:SetAnchor(TOPLEFT,GuiRoot,CENTER,p.x-(size/2),p.y-(rowHeight/2))
end

function TM:SetInactive(key)
    local c=self.controls[key]
    if not c then return end
    c.icon:SetDesaturation(1)
    c.icon:SetColor(.55,.55,.55,1)
    c.countdown:SetText("")
end

function TM:SetActive(key)
    local c=self.controls[key]
    if not c then return end
    c.icon:SetDesaturation(0)
    c.icon:SetColor(1,1,1,1)
end

function TM:ApplyLayout()
    local size = self.sv.iconSize
    local textSize = self.sv.fontSize
    local statusSize = math.max(12,textSize-4)
    local nameHeight = math.max(20,math.ceil(textSize*1.35))
    local statusHeight = math.max(18,math.ceil(statusSize*1.35))
    -- Normal display is one line (mastery name). Status is reserved for PREVIEW/TEST/+2 ULTIMATE.
    local rowHeight = math.max(size,nameHeight)
    local gap = math.max(8,math.floor(size*.15))
    local nameWidth = math.max(260,textSize*15)

    for _,key in ipairs(self.ORDER) do
        local c=self.controls[key]
        c:SetDimensions(size+gap+nameWidth,rowHeight)

        c.icon:ClearAnchors()
        c.icon:SetAnchor(LEFT,c,LEFT,0,0)
        c.icon:SetDimensions(size,size)
        c.icon:SetHidden(not self.sv.showIcons)

        c.countdown:SetDimensions(size,size)
        c.countdown:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick",math.max(14,math.floor(size*.36))))

        c.name:ClearAnchors()
        if self.sv.showIcons then
            c.name:SetAnchor(LEFT,c.icon,RIGHT,gap,0)
        else
            c.name:SetAnchor(LEFT,c,LEFT,0,0)
        end
        c.name:SetDimensions(nameWidth,nameHeight)
        c.name:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick",textSize))
        c.name:SetHidden(not self.sv.showNames)

        c.status:ClearAnchors()
        c.status:SetAnchor(TOPLEFT,c.name,BOTTOMLEFT,0,1)
        c.status:SetDimensions(nameWidth,statusHeight)
        c.status:SetFont(string.format("$(MEDIUM_FONT)|%d|soft-shadow-thick",statusSize))

        -- Re-anchor after dimensions change so icon center never drifts.
        self:ApplyPosition(key)
    end
end

function TM:ApplyColors()
    for _,c in pairs(self.controls) do
        c.name:SetColor(Color(self.sv.textColor))
        c.status:SetColor(Color(self.sv.textColor))
        c.countdown:SetColor(Color(self.sv.textColor))
    end
end

function TM:CreateTracker(key)
    local wm=WINDOW_MANAGER
    local c=wm:CreateTopLevelWindow("TM_"..key)
    c:SetClampedToScreen(true)
    c:SetDrawTier(DT_HIGH)
    c:SetDrawLayer(DL_OVERLAY)
    c:SetHidden(true)

    local bg=wm:CreateControl(nil,c,CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0,0,0,.55)
    bg:SetEdgeColor(1,1,1,.45)
    bg:SetEdgeTexture("",1,1,1)
    bg:SetHidden(true)
    c.bg=bg

    local icon=wm:CreateControl(nil,c,CT_TEXTURE)
    icon:SetTexture(self:GetIcon(self.MASTERY[key]))
    c.icon=icon

    local countdown=wm:CreateControl(nil,c,CT_LABEL)
    countdown:SetAnchor(CENTER,icon,CENTER,0,0)
    countdown:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    countdown:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    c.countdown=countdown

    local name=wm:CreateControl(nil,c,CT_LABEL)
    name:SetText(self.pretty[key])
    name:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    name:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    c.name=name

    local status=wm:CreateControl(nil,c,CT_LABEL)
    status:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    status:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    c.status=status

    c:SetHandler("OnMoveStop",function(control)
        local cx=control.icon:GetLeft()+control.icon:GetWidth()/2
        local cy=control.icon:GetTop()+control.icon:GetHeight()/2
        TM.sv.positions[key].x=cx-GuiRoot:GetWidth()/2
        TM.sv.positions[key].y=cy-GuiRoot:GetHeight()/2
    end)

    self.controls[key]=c
    self:ApplyPosition(key)
    self:AddHUDFragment(c)
    self:SetInactive(key)
end

function TM:CreateUI()
    for _,key in ipairs(self.ORDER) do self:CreateTracker(key) end
    self:ApplyLayout()
    self:ApplyColors()
    self:SetLocked(self.sv.locked)
end

function TM:SetLocked(v)
    self.sv.locked=v
    for _,c in pairs(self.controls) do
        c:SetMouseEnabled(not v)
        c:SetMovable(not v)
        c.bg:SetHidden(v)
    end
    self:Update()
end

function TM:ResetPositions()
    for key,p in pairs(self.defaults.positions) do
        self.sv.positions[key].x=p.x
        self.sv.positions[key].y=p.y
        self:ApplyPosition(key)
    end
end

function TM:HideAll()
    for _,c in pairs(self.controls) do c:SetHidden(true) end
end

function TM:ShowPreview(key,seconds)
    self.testUntil[key]=Now()+(seconds or 4)
    self:Update()
end


-- Keep locked/normal trackers from visually colliding when icons are enlarged.
-- Saved positions never change here: we only apply temporary display offsets,
-- preserving the center of the user's placed group. Unlock mode is untouched.
function TM:ApplyVisibleIconSpacing()
    if not self.sv.locked or self:IsUnlockedPreview() then return end

    local visible={}
    for _,key in ipairs(self.ORDER) do
        local c=self.controls[key]
        if c and not c:IsHidden() then
            visible[#visible+1]={key=key,y=self.sv.positions[key].y}
        end
    end
    if #visible < 2 then
        if #visible == 1 then self:ApplyPosition(visible[1].key) end
        return
    end

    table.sort(visible,function(a,b) return a.y < b.y end)
    local minSep=(self.sv.iconSize or self.defaults.iconSize)+4

    -- Start from the saved centers, then push only enough to remove overlap.
    local ys={}
    for i,v in ipairs(visible) do ys[i]=v.y end
    for i=2,#ys do
        if ys[i]-ys[i-1] < minSep then ys[i]=ys[i-1]+minSep end
    end

    -- Recenter the adjusted set on the original saved group's center.
    local oldCenter=(visible[1].y+visible[#visible].y)/2
    local newCenter=(ys[1]+ys[#ys])/2
    local shift=oldCenter-newCenter

    local size=self.sv.iconSize or self.defaults.iconSize
    for i,v in ipairs(visible) do
        local c=self.controls[v.key]
        local rowHeight=c:GetHeight()>0 and c:GetHeight() or size
        c:ClearAnchors()
        c:SetAnchor(TOPLEFT,GuiRoot,CENTER,
            self.sv.positions[v.key].x-(size/2),
            (ys[i]+shift)-(rowHeight/2))
    end
end

function TM:SetDisplay(key,show,active,status,countdown,warn,force)
    local c=self.controls[key]
    if not c then return end

    if force then
        show=self.sv.enabled and self.sv.trackers[key] and self:IsHUDShowing()
    else
        show=show and self.sv.trackers[key] and self:CanDisplayNormal()
    end

    c:SetHidden(not show)
    if not show then return end

    if active then self:SetActive(key) else self:SetInactive(key) end

    c.name:SetText(self.pretty[key])
    local statusText=status or ""
    c.status:SetText(statusText)
    c.status:SetHidden((not self.sv.showNames) or statusText=="")
    c.countdown:SetText(countdown or "")

    local tc=warn and self.sv.warningColor or self.sv.textColor
    c.name:SetColor(Color(tc))
    c.status:SetColor(Color(tc))
    c.countdown:SetColor(Color(tc))
end

-- Preserve the v1.3 selected-mastery scan behavior.
function TM:ScanSelectedMasteries()
    local old=self.selected or {}
    local found={}

    if not GetNumSkillTypes or not GetNumSkillLines or not GetNumSkillAbilities then return false end

    for st=1,GetNumSkillTypes() do
        for sl=1,GetNumSkillLines(st) do
            for ai=1,GetNumSkillAbilities(st,sl) do
                local okId,id=pcall(GetSkillAbilityId,st,sl,ai,false)
                local okInfo,name,icon,earnedRank,passive,ultimate,purchased=pcall(GetSkillAbilityInfo,st,sl,ai)
                if okId and okInfo and purchased and id then
                    for key,mid in pairs(self.MASTERY) do
                        if id==mid then found[key]=true end
                    end
                end
            end
        end
    end

    local changed=false
    for key in pairs(self.MASTERY) do
        if (old[key]==true)~=(found[key]==true) then changed=true break end
    end
    self.selected=found

    if changed then
        if not found.bright then self.state.brightEnd=0 end
        if not found.judgment then self.state.judgmentEnd=0 end
        if not found.devout then self.state.devoutEnd=0 end
        if not found.bastion then self.state.bastionUntil=0; self.state.bastionUltUntil=0 end
        self:RefreshTrackingEvents()
        self:Update()
    end
    return changed
end

-- Preserve v1.3's Live-safe Bright Harbinger scan.
function TM:GetBrightHarbingerEnd()
    if not self:IsSelected("bright") then return 0 end
    if not GetNumBuffs or not GetUnitBuffInfo then return 0 end

    local now=Now()
    local masteryName=string.lower(GetAbilityName(self.MASTERY.bright) or "Bright Harbinger")
    for i=1,(GetNumBuffs("player") or 0) do
        local buffName,beginTime,endTime,buffSlot,stackCount,iconFilename,
              buffType,effectType,abilityType,statusEffectType,abilityId=GetUnitBuffInfo("player",i)
        local nameMatch=buffName and string.lower(buffName)==masteryName
        local idMatch=abilityId==self.MASTERY.bright or abilityId==self.ID.illuminate
        if nameMatch or idMatch then
            if endTime and endTime>now then return endTime end
            return now+.25
        end
    end
    return 0
end

function TM:OnEffectChanged(eventCode,changeType,effectSlot,effectName,unitTag,
                            beginTime,endTime,stackCount,iconName,buffType,effectType,
                            abilityType,statusEffectType,unitName,unitId,abilityId,sourceType)
    local now=Now()

    if abilityId==self.ID.illuminate and self:IsTracked("bright") then
        if changeType==EFFECT_RESULT_GAINED or changeType==EFFECT_RESULT_UPDATED or changeType==EFFECT_RESULT_FULL_REFRESH then
            self.state.brightEnd=(endTime and endTime>now) and endTime or (now+20)
        elseif changeType==EFFECT_RESULT_FADED then
            self.state.brightEnd=0
        end

    elseif abilityId==self.ID.holdTheLine and self:IsTracked("devout") then
        if changeType==EFFECT_RESULT_GAINED or changeType==EFFECT_RESULT_UPDATED or changeType==EFFECT_RESULT_FULL_REFRESH then
            if self.state.devoutEnd<=now+.05 then self.state.devoutEnd=now+6 end
        elseif changeType==EFFECT_RESULT_FADED then
            self.state.devoutEnd=0
        end
    end
end

function TM:OnCombatEvent(eventCode,result,isError,abilityName,abilityGraphic,
                          abilityActionSlotType,sourceName,sourceType,targetName,targetType,
                          hitValue,powerType,damageType,log,sourceUnitId,targetUnitId,
                          abilityId,overflow)
    local now=Now()

    if abilityId==self.ID.judgmentProc and self:IsTracked("judgment") then
        self.state.judgmentEnd=now+3.1

    elseif abilityId==self.ID.holdTheLine and self:IsTracked("devout") then
        if self.state.devoutEnd<=now+.05 then self.state.devoutEnd=now+6 end

    elseif abilityId==self.ID.missionaryHeal and self:IsTracked("bastion") then
        self.state.bastionUntil=now+1.25

    elseif abilityId==self.ID.missionaryUlt and self:IsTracked("bastion") then
        self.state.bastionUntil=now+1.25
        self.state.bastionUltUntil=now+.35
    end
end

function TM:IsSteadfastActuallyActive()
    if not self:IsTracked("steadfast") then return false end
    if not IsBlockActive or not IsPlayerMoving then return false end
    return IsBlockActive() and not IsPlayerMoving()
end

function TM:Update()
    if not self.sv.enabled or not self:IsHUDShowing() then
        self:HideAll()
        return
    end

    local now=Now()

    -- Keep the existing unlock behavior: all five previews appear and remain movable.
    if self:IsUnlockedPreview() then
        for _,key in ipairs(self.ORDER) do
            self:SetDisplay(key,true,true,"PREVIEW","",false,true)
        end
        return
    end

    -- Individual test buttons remain exactly as a feature.
    for _,key in ipairs(self.ORDER) do
        if self:IsTesting(key) then
            self:SetDisplay(key,true,true,"TEST","",false,true)
        end
    end

    -- NEW visual standard: selected masteries remain visible gray while inactive.
    -- Bright Harbinger
    if not self:IsTesting("bright") then
        if self:IsTracked("bright") then
            local liveEnd=self:GetBrightHarbingerEnd()
            if liveEnd>now then self.state.brightEnd=liveEnd
            elseif self.state.brightEnd<=now then self.state.brightEnd=0 end
            local rem=self.state.brightEnd-now
            if rem>0 then
                self:SetDisplay("bright",true,true,"",tostring(math.ceil(rem)),rem<=2)
            else
                self:SetDisplay("bright",true,false,"","",false)
            end
        else
            self:SetDisplay("bright",false,false)
        end
    end

    -- Judgment's Brand
    if not self:IsTesting("judgment") then
        if self:IsTracked("judgment") then
            local rem=self.state.judgmentEnd-now
            if rem>0 then
                self:SetDisplay("judgment",true,true,"",tostring(math.ceil(rem)),rem<=1)
            else
                self:SetDisplay("judgment",true,false,"","",false)
            end
        else
            self:SetDisplay("judgment",false,false)
        end
    end

    -- Devout Guardian
    if not self:IsTesting("devout") then
        if self:IsTracked("devout") then
            local rem=self.state.devoutEnd-now
            if rem>0 then
                self:SetDisplay("devout",true,true,"",tostring(math.ceil(rem)),rem<=1)
            else
                self:SetDisplay("devout",true,false,"","",false)
            end
        else
            self:SetDisplay("devout",false,false)
        end
    end

    -- Steadfast Candescence
    if not self:IsTesting("steadfast") then
        if self:IsTracked("steadfast") then
            if self:IsSteadfastActuallyActive() then
                self:SetDisplay("steadfast",true,true,"","",false)
            else
                self:SetDisplay("steadfast",true,false,"","",false)
            end
        else
            self:SetDisplay("steadfast",false,false)
        end
    end

    -- Bastion of Light
    if not self:IsTesting("bastion") then
        if self:IsTracked("bastion") then
            if now<self.state.bastionUntil then
                local status=(now<self.state.bastionUltUntil) and "+2 ULTIMATE" or ""
                self:SetDisplay("bastion",true,true,status,"",false)
            else
                self:SetDisplay("bastion",true,false,"","",false)
            end
        else
            self:SetDisplay("bastion",false,false)
        end
    end

    self:ApplyVisibleIconSpacing()
end

local function Unreg(name,event)
    EVENT_MANAGER:UnregisterForEvent(name,event)
end

function TM:RegisterEffect(tag,id)
    local n=self.name.."_E_"..tag
    EVENT_MANAGER:RegisterForEvent(n,EVENT_EFFECT_CHANGED,function(...) TM:OnEffectChanged(...) end)
    EVENT_MANAGER:AddFilterForEvent(n,EVENT_EFFECT_CHANGED,
        REGISTER_FILTER_ABILITY_ID,id,
        REGISTER_FILTER_UNIT_TAG,"player",
        REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE,COMBAT_UNIT_TYPE_PLAYER)
    self.registered[n]=EVENT_EFFECT_CHANGED
end

function TM:RegisterCombat(tag,id)
    local n=self.name.."_C_"..tag
    EVENT_MANAGER:RegisterForEvent(n,EVENT_COMBAT_EVENT,function(...) TM:OnCombatEvent(...) end)
    EVENT_MANAGER:AddFilterForEvent(n,EVENT_COMBAT_EVENT,
        REGISTER_FILTER_ABILITY_ID,id,
        REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE,COMBAT_UNIT_TYPE_PLAYER)
    self.registered[n]=EVENT_COMBAT_EVENT
end

-- Baertram/ESOUI performance rule:
-- only listen for mastery events while that mastery is selected + enabled.
function TM:RefreshTrackingEvents()
    for n,event in pairs(self.registered) do
        Unreg(n,event)
    end
    self.registered={}

    if self:IsTracked("bright") then
        self:RegisterEffect("Illuminate",self.ID.illuminate)
        self:RegisterEffect("BrightHarbinger",self.MASTERY.bright)
    end

    if self:IsTracked("devout") then
        self:RegisterEffect("HoldTheLine",self.ID.holdTheLine)
        self:RegisterCombat("HoldTheLine",self.ID.holdTheLine)
    end

    if self:IsTracked("judgment") then
        self:RegisterCombat("Judgment",self.ID.judgmentProc)
    end

    if self:IsTracked("bastion") then
        self:RegisterCombat("MissionaryHeal",self.ID.missionaryHeal)
        self:RegisterCombat("MissionaryUlt",self.ID.missionaryUlt)
    end
    -- Steadfast intentionally remains state-driven, not combat-event driven.
end

function TM:RegisterTracking()
    self:RefreshTrackingEvents()

    EVENT_MANAGER:RegisterForUpdate(self.name.."_Update",50,function() TM:Update() end)
    EVENT_MANAGER:RegisterForUpdate(self.name.."_MasteryRescan",500,function() TM:ScanSelectedMasteries() end)

    EVENT_MANAGER:RegisterForEvent(self.name.."_Activated",EVENT_PLAYER_ACTIVATED,function()
        zo_callLater(function() TM:ScanSelectedMasteries(); TM:Update() end,500)
    end)

    if EVENT_SKILL_POINTS_CHANGED then
        EVENT_MANAGER:RegisterForEvent(self.name.."_SkillPoints",EVENT_SKILL_POINTS_CHANGED,function()
            zo_callLater(function() TM:ScanSelectedMasteries() end,250)
        end)
    end
end

function TM:CreateSettings()
    local LAM=LibAddonMenu2
    if not LAM then return end

    LAM:RegisterAddonPanel(self.name.."Options",{
        type="panel",
        name="Templar Mastery",
        displayName="Templar Mastery |cFFD246♥|r",
        author="WifeyRytic",
        version=self.version,
        registerForRefresh=true,
        registerForDefaults=true,
    })

    local opts={
        {
            type="checkbox",name="ENABLE ADDON — FULL KILL SWITCH",
            tooltip="Turns ALL Templar Mastery tracking on or off.",
            getFunc=function() return TM.sv.enabled end,
            setFunc=function(v)
                TM.sv.enabled=v
                TM:RefreshTrackingEvents()
                if not v then TM:HideAll() else TM:Update() end
            end,
            default=self.defaults.enabled,width="full",
        },
        {
            type="checkbox",name="Hide Out of Combat",
            getFunc=function() return TM.sv.hideOutOfCombat end,
            setFunc=function(v) TM.sv.hideOutOfCombat=v; TM:Update() end,
            default=self.defaults.hideOutOfCombat,
        },
        {
            type="checkbox",name="Lock Position",
            tooltip="Turn OFF to unlock. ALL five trackers will appear as previews so you can move them.",
            getFunc=function() return TM.sv.locked end,
            setFunc=function(v) TM:SetLocked(v) end,
            default=self.defaults.locked,
        },
        {type="button",name="Reset Positions",func=function() TM:ResetPositions() end},
        {
            type="slider",name="Icon Size",min=28,max=100,step=1,
            getFunc=function() return TM.sv.iconSize end,
            setFunc=function(v) TM.sv.iconSize=v; TM:ApplyLayout() end,
            default=self.defaults.iconSize,
        },
        {
            type="slider",name="Mastery Text Size",
            tooltip="Changes mastery name/status text without changing the icon size.",
            min=12,max=40,step=1,
            getFunc=function() return TM.sv.fontSize end,
            setFunc=function(v) TM.sv.fontSize=v; TM:ApplyLayout() end,
            default=self.defaults.fontSize,
        },
        {
            type="colorpicker",name="Text Color",
            getFunc=function() return Color(TM.sv.textColor) end,
            setFunc=function(r,g,b,a) TM.sv.textColor={r,g,b,a}; TM:ApplyColors() end,
            default={r=1.0,g=0.8235,b=0.2745,a=1},
        },
        {
            type="colorpicker",name="Warning Color",
            getFunc=function() return Color(TM.sv.warningColor) end,
            setFunc=function(r,g,b,a) TM.sv.warningColor={r,g,b,a} end,
            default={r=1,g=0.15,b=0.15,a=1},
        },
        {
            type="checkbox",name="Show Mastery Icons",
            getFunc=function() return TM.sv.showIcons end,
            setFunc=function(v) TM.sv.showIcons=v; TM:ApplyLayout() end,
            default=self.defaults.showIcons,
        },
        {
            type="checkbox",name="Show Mastery Names",
            getFunc=function() return TM.sv.showNames end,
            setFunc=function(v) TM.sv.showNames=v; TM:ApplyLayout() end,
            default=self.defaults.showNames,
        },

        -- USER REQUEST: leave this section and all five Test buttons.
        {type="header",name="Individual Mastery Trackers"},
    }

    local names={
        bastion="Bastion of Light",
        devout="Devout Guardian",
        bright="Bright Harbinger",
        judgment="Judgment's Brand",
        steadfast="Steadfast Candescence",
    }

    for _,key in ipairs(self.ORDER) do
        local k=key
        table.insert(opts,{
            type="checkbox",name=names[k],
            getFunc=function() return TM.sv.trackers[k] end,
            setFunc=function(v)
                TM.sv.trackers[k]=v
                if not v then TM.controls[k]:SetHidden(true) end
                TM:RefreshTrackingEvents()
                TM:Update()
            end,
            default=true,width="half",
        })
        table.insert(opts,{
            type="button",name="Test "..names[k],
            tooltip="Shows this tracker for 4 seconds. No mastery selection or combat required.",
            func=function() TM:ShowPreview(k,4) end,
            width="half",
        })
    end

    LAM:RegisterOptionControls(self.name.."Options",opts)
end

function TM:RegisterSlash()
    SLASH_COMMANDS["/tm"]=function(t)
        t=string.lower(t or "")
        if t=="on" then
            TM.sv.enabled=true; TM:RefreshTrackingEvents(); TM:Update()
            d("|cFFD700Templar Mastery|r ON")
        elseif t=="off" then
            TM.sv.enabled=false; TM:RefreshTrackingEvents(); TM:HideAll()
            d("|cFFD700Templar Mastery|r OFF")
        elseif t=="unlock" then
            TM:SetLocked(false); d("|cFFD700Templar Mastery|r UNLOCKED — previews shown")
        elseif t=="lock" then
            TM:SetLocked(true); d("|cFFD700Templar Mastery|r LOCKED")
        elseif t=="reset" then
            TM:ResetPositions(); d("|cFFD700Templar Mastery|r positions reset")
        elseif t=="scan" then
            TM:ScanSelectedMasteries()
            local a={}
            for k in pairs(TM.selected) do table.insert(a,k) end
            table.sort(a)
            d("|cFFD700Templar Mastery selected:|r "..(#a>0 and table.concat(a,", ") or "NONE DETECTED"))
        elseif t=="test bright" then TM:ShowPreview("bright",4)
        elseif t=="test judgment" then TM:ShowPreview("judgment",4)
        elseif t=="test devout" then TM:ShowPreview("devout",4)
        elseif t=="test steadfast" then TM:ShowPreview("steadfast",4)
        elseif t=="test bastion" then TM:ShowPreview("bastion",4)
        else
            d("|cFFD700Templar Mastery:|r /tm on, off, unlock, lock, reset, scan")
            d("|cFFD700Tests:|r /tm test bright | judgment | devout | steadfast | bastion")
        end
    end
end

function TM:Initialize()
    self.sv=ZO_SavedVars:NewAccountWide("TemplarMasterySavedVariables",1,nil,self.defaults)

    -- v1.3 migration: old builds had fontSize but no independent iconSize/showNames.
    if self.sv.iconSize==nil then self.sv.iconSize=self.defaults.iconSize end
    if self.sv.showNames==nil then self.sv.showNames=true end
    -- Keep existing users' text reasonable in the new two-line icon layout.
    if self.sv.fontSize and self.sv.fontSize>40 then self.sv.fontSize=40 end

    -- v1.3.2: convert saved tracker centers to saved icon centers once.
    if not self.sv.positionIsIconCenter then
        local size=self.sv.iconSize or self.defaults.iconSize
        local textSize=self.sv.fontSize or self.defaults.fontSize
        local gap=math.max(8,math.floor(size*.15))
        local nameWidth=math.max(260,textSize*15)
        local oldWidth=size+gap+nameWidth
        -- Old control was CENTER anchored; icon sat at its left edge.
        local iconOffset=-(oldWidth/2)+(size/2)
        for _,key in ipairs(self.ORDER) do
            if self.sv.positions[key] then self.sv.positions[key].x=self.sv.positions[key].x+iconOffset end
        end
        self.sv.positionIsIconCenter=true
    end

    self:CreateUI()
    self:ScanSelectedMasteries()
    self:CreateSettings()
    self:RegisterTracking()
    self:RegisterSlash()

    zo_callLater(function() TM:ScanSelectedMasteries(); TM:Update() end,1000)
    d("|cFFD700Templar Mastery ♥ v1.3.1 TEST loaded.|r")
end

local function Loaded(eventCode,addonName)
    if addonName~=TM.name then return end
    EVENT_MANAGER:UnregisterForEvent(TM.name,EVENT_ADD_ON_LOADED)
    TM:Initialize()
end

EVENT_MANAGER:RegisterForEvent(TM.name,EVENT_ADD_ON_LOADED,Loaded)
