local NBM={}
local ADDON="NightbladeMastery"
NBM.version="1.1"

-- Update 50 Nightblade Class Mastery is SKILL_TYPE_CLASS, line 48.
-- IDs verified against ESOUI U50 documentation.
local LINE=48
local DATA={
 {key="nocturnal", name="Nocturnal Inspiration", skillId=263603, procId=263613, kind="flash", duration=1.25, status="+2 Ultimate"},
 {key="eye",       name="An Eye for Exploitation", skillId=263604, kind="unsupported", reason="Not tracked - ESO API does not expose this mastery reliably."},
 {key="above",     name="Above and Beyond", skillId=263605, kind="unsupported", reason="Not tracked - ESO API does not expose this mastery reliably."},
 {key="cutthroat", name="Cutthroat's Focus", skillId=263606, procId=263685, kind="timer", duration=20, status="Target debuff"},
 {key="spoils",    name="Share the Spoils", skillId=263607, procId=45146, kind="flash", duration=1.25, status="+4 Ultimate"},
}
local BYID={}
for _,d in ipairs(DATA) do if d.procId then BYID[d.procId]=d end end

local defaults={
 enabled=true, hideOOC=true, locked=true, iconSize=52, textSize=18,
 x=40,y=180,
 positions={
   nocturnal={x=0,y=0}, eye={x=0,y=86}, above={x=0,y=172},
   cutthroat={x=0,y=258}, spoils={x=0,y=344},
 },
 masteryEnabled={nocturnal=true,eye=true,above=true,cutthroat=true,spoils=true},
}
local sv,frame,fragment
local ctrls,selected,active,ends={}, {}, {}, {}
local inCombat=false

local function HUDShowing()
 if IsUnitDead("player") then return false end
 return HUD_SCENE and HUD_UI_SCENE and (HUD_SCENE:IsShowing() or HUD_UI_SCENE:IsShowing())
end
local function Gray(c)
 c.icon:SetDesaturation(1); c.icon:SetColor(.55,.55,.55,1); c.timer:SetText("")
end
local function Color(c)
 c.icon:SetDesaturation(0); c.icon:SetColor(1,1,1,1)
end

-- IMPORTANT v0.3: read the actual dedicated Nightblade Class Mastery line,
-- not every class line. "purchased" is the state used by the working mastery UI.
local function ScanMasteries()
 local changed=false
 for i,d in ipairs(DATA) do
   local name,texture,earnedRank,passive,ultimate,purchased=GetSkillAbilityInfo(SKILL_TYPE_CLASS,LINE,i)
   local isSelected=(purchased==true)
   if selected[d.key]~=isSelected then changed=true end
   selected[d.key]=isSelected
   if texture and texture~="" then
      ctrls[d.key].icon:SetTexture(texture)
   else
      local icon=GetAbilityIcon(d.skillId)
      if icon and icon~="" then ctrls[d.key].icon:SetTexture(icon) end
   end
 end
 if changed then NBM:Layout() end
end

local function ShouldShow(d)
 if not sv.enabled or not sv.masteryEnabled[d.key] then return false end
 if not sv.locked then return true end
 return selected[d.key]==true
end

function NBM:Visibility()
 if not HUDShowing() or not sv.enabled then frame:SetHidden(true); return end
 if sv.hideOOC and not inCombat and sv.locked then frame:SetHidden(true); return end
 local any=false
 for _,d in ipairs(DATA) do if ShouldShow(d) then any=true break end end
 frame:SetHidden(not any)
end

function NBM:Layout()
 local s=sv.iconSize
 local gap=math.max(8,math.floor(s*.15))
 local rowGap=math.max(7,math.floor(math.max(s,sv.textSize)*.14))
 local textW=math.max(390,sv.textSize*23)
 local nameH=math.max(22,math.ceil(sv.textSize*1.4))
 local statSize=math.max(12,sv.textSize-3)
 local statH=math.max(34,math.ceil(statSize*2.7))
 local blockH=nameH+2+statH
 local rowH=math.max(s,blockH)

 for i,d in ipairs(DATA) do
   local c=ctrls[d.key]
   c.row:SetHidden(not ShouldShow(d))
   c.row:SetDimensions(s+gap+textW,rowH)
   c.icon:SetDimensions(s,s); c.icon:ClearAnchors(); c.icon:SetAnchor(LEFT,c.row,LEFT,0,0)
   c.timer:SetDimensions(s,s); c.timer:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick",math.max(14,math.floor(s*.36))))
   c.name:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick",sv.textSize))
   c.name:ClearAnchors(); c.name:SetAnchor(TOPLEFT,c.icon,TOPRIGHT,gap,math.max(0,math.floor((rowH-blockH)/2)))
   c.name:SetDimensions(textW,nameH)
   c.status:SetFont(string.format("$(MEDIUM_FONT)|%d|soft-shadow-thick",statSize))
   c.status:ClearAnchors(); c.status:SetAnchor(TOPLEFT,c.name,BOTTOMLEFT,0,2); c.status:SetDimensions(textW,statH)

   c.row:ClearAnchors()
   local p=sv.positions[d.key]
   if p and p.moved then
      c.row:SetAnchor(TOPLEFT,GuiRoot,TOPLEFT,p.x,p.y)
   else
      -- Clean default preview: all five together at the tracker origin.
      c.row:SetAnchor(TOPLEFT,GuiRoot,TOPLEFT,sv.x,sv.y+(i-1)*(rowH+rowGap))
   end
   c.row:SetMovable(not sv.locked)
   c.row:SetMouseEnabled(not sv.locked)
 end

 frame:SetDimensions(1,1)
 NBM:Visibility()
end

local function Trigger(d)
 if not sv.enabled or not sv.masteryEnabled[d.key] then return end
 -- If ESO fires the proven mastery event, accept it. Do not block the proc
 -- behind selection detection; this was the v0.1/v0.2 failure point.
 active[d.key]=true
 ends[d.key]=GetFrameTimeSeconds()+d.duration
 Color(ctrls[d.key])
end

-- v0.3 mirrors the WORKING Snitch strategy:
-- ONE broad EVENT_COMBAT_EVENT listener, no engine filters.
-- We inspect the proven ability IDs inside Lua.
local function CombatEvent(_,result,isError,abilityName,abilityGraphic,abilityActionSlotType,
 sourceName,sourceType,targetName,targetType,hitValue,powerType,damageType,log,
 sourceUnitId,targetUnitId,abilityId,overflow)

 if not sv.enabled then return end
 local d=BYID[abilityId]
 if not d then return end

 if d.key=="spoils" then
   if powerType==POWERTYPE_ULTIMATE and tonumber(hitValue)==4 then Trigger(d) end
 elseif d.key=="cutthroat" then
   if result==ACTION_RESULT_EFFECT_GAINED or result==ACTION_RESULT_EFFECT_GAINED_DURATION then Trigger(d) end
 elseif d.key=="nocturnal" then
   if result==ACTION_RESULT_POWER_ENERGIZE and hitValue==2 and powerType==POWERTYPE_ULTIMATE then
     Trigger(d)
   end
 end
end

local function Update()
 if not HUDShowing() then frame:SetHidden(true); return end
 local now=GetFrameTimeSeconds()
 for _,d in ipairs(DATA) do
   local c=ctrls[d.key]
   if d.kind=="unsupported" then
      Gray(c); c.status:SetText(d.reason)
   elseif active[d.key] then
      local rem=(ends[d.key] or 0)-now
      if rem<=0 then active[d.key]=false; ends[d.key]=0; Gray(c); c.status:SetText("")
      else
        Color(c); c.status:SetText(d.status or "")
        c.timer:SetText(d.kind=="timer" and tostring(math.ceil(rem)) or "")
      end
   else
      Gray(c); c.status:SetText("")
   end
 end
 NBM:Visibility()
end

local function CreateUI()
 local wm=WINDOW_MANAGER
 frame=wm:CreateTopLevelWindow(ADDON.."Frame")
 frame:SetClampedToScreen(false); frame:SetAnchor(TOPLEFT,GuiRoot,TOPLEFT,sv.x,sv.y)
 frame:SetMovable(false); frame:SetMouseEnabled(false)

 for i,d in ipairs(DATA) do
   local row=wm:CreateControl(ADDON.."Row"..i,frame,CT_CONTROL)
   local icon=wm:CreateControl(ADDON.."Icon"..i,row,CT_TEXTURE)
   local name=wm:CreateControl(ADDON.."Name"..i,row,CT_LABEL); name:SetText(d.name)
   local status=wm:CreateControl(ADDON.."Status"..i,row,CT_LABEL)
   local timer=wm:CreateControl(ADDON.."Timer"..i,row,CT_LABEL)
   timer:SetAnchor(CENTER,icon,CENTER); timer:SetHorizontalAlignment(TEXT_ALIGN_CENTER); timer:SetVerticalAlignment(TEXT_ALIGN_CENTER)
   row:SetClampedToScreen(true)
   row:SetHandler("OnMoveStop",function()
     local p=sv.positions[d.key]
     p.x=row:GetLeft()-GuiRoot:GetLeft()
     p.y=row:GetTop()-GuiRoot:GetTop()
     p.moved=true
   end)
   ctrls[d.key]={row=row,icon=icon,name=name,status=status,timer=timer}
   Gray(ctrls[d.key])
 end

 fragment=ZO_HUDFadeSceneFragment:New(frame,nil,0)
 HUD_SCENE:AddFragment(fragment); HUD_UI_SCENE:AddFragment(fragment)
 ScanMasteries()
 NBM:Layout()
end

local function Settings()
 if not LibAddonMenu2 then return end
 local L=LibAddonMenu2; local panel=ADDON.."Options"
 L:RegisterAddonPanel(panel,{type="panel",name="Nightblade Mastery",displayName="Nightblade Mastery",author="WifeyRytic",version=NBM.version,registerForRefresh=true,registerForDefaults=true})
 local o={
  {type="header",name="Mastery Tracker"},
  {type="checkbox",name="Enable Mastery Tracker",getFunc=function() return sv.enabled end,setFunc=function(v) sv.enabled=v NBM:Layout() end,default=true},
  {type="checkbox",name="Hide Masteries Out of Combat",getFunc=function() return sv.hideOOC end,setFunc=function(v) sv.hideOOC=v NBM:Visibility() end,default=true},
  {type="checkbox",name="Lock Mastery Tracker",tooltip="Locked: only selected Class Masteries are shown. Unlocked: previews all five for positioning.",
   getFunc=function() return sv.locked end,setFunc=function(v) sv.locked=v ScanMasteries(); NBM:Layout() end,default=true},
  {type="slider",name="Icon Size",min=28,max=100,step=1,getFunc=function() return sv.iconSize end,setFunc=function(v) sv.iconSize=v NBM:Layout() end,default=52},
  {type="slider",name="Mastery Text Size",min=12,max=40,step=1,getFunc=function() return sv.textSize end,setFunc=function(v) sv.textSize=v NBM:Layout() end,default=18},
  {type="header",name="Individual Masteries"},
 }
 for _,d0 in ipairs(DATA) do
   local d=d0
   o[#o+1]={type="checkbox",name=d.name,tooltip=d.reason,getFunc=function() return sv.masteryEnabled[d.key] end,
     setFunc=function(v) sv.masteryEnabled[d.key]=v NBM:Layout() end,default=true}
 end
 o[#o+1]={type="description",title="API-limited masteries",
   text="An Eye for Exploitation and Above and Beyond remain gray with an explanation because ESO does not expose reliable addon data for their effects. No values are estimated or faked."}
 o[#o+1]={type="button",name="Reset Mastery Positions",func=function()
   for _,d in ipairs(DATA) do
     sv.positions[d.key]={x=0,y=0,moved=false}
   end
   NBM:Layout()
 end}
 L:RegisterOptionControls(panel,o)
end

local function CombatState(_,state)
 inCombat=state
 if not state then
   for _,d in ipairs(DATA) do if d.kind~="unsupported" then active[d.key]=false; ends[d.key]=0; Gray(ctrls[d.key]) end end
 end
 Update()
end

local function Activated()
 inCombat=IsUnitInCombat("player"); ScanMasteries(); Update()
end

local function Loaded(_,name)
 if name~=ADDON then return end
 EVENT_MANAGER:UnregisterForEvent(ADDON,EVENT_ADD_ON_LOADED)
 sv=ZO_SavedVars:NewAccountWide("NightbladeMasterySavedVariables",1,nil,defaults,GetWorldName())
 if not sv.masteryEnabled then sv.masteryEnabled=ZO_DeepTableCopy(defaults.masteryEnabled) end
 if not sv.positions then sv.positions=ZO_DeepTableCopy(defaults.positions) end
 for _,d in ipairs(DATA) do
   if not sv.positions[d.key] then sv.positions[d.key]=ZO_DeepTableCopy(defaults.positions[d.key]) end
 end
 inCombat=IsUnitInCombat("player")
 CreateUI(); Settings()

 EVENT_MANAGER:RegisterForEvent(ADDON.."_CombatEvent",EVENT_COMBAT_EVENT,CombatEvent)
 EVENT_MANAGER:RegisterForEvent(ADDON.."_CombatState",EVENT_PLAYER_COMBAT_STATE,CombatState)
 EVENT_MANAGER:RegisterForEvent(ADDON.."_Activated",EVENT_PLAYER_ACTIVATED,Activated)
 EVENT_MANAGER:RegisterForUpdate(ADDON.."_Scan",500,function() ScanMasteries() end)
 EVENT_MANAGER:RegisterForUpdate(ADDON.."_Update",100,Update)

 d("|cB56BFFNightblade Mastery Tracker v1.0 loaded.|r")
 Update()
end
EVENT_MANAGER:RegisterForEvent(ADDON,EVENT_ADD_ON_LOADED,Loaded)
