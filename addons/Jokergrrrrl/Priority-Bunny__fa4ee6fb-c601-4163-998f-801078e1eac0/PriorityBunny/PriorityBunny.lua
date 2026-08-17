PriorityBunny = PriorityBunny or {}
local PB = PriorityBunny
PB.name="PriorityBunny"
PB.displayName="Priority Bunny"
PB.version="0.4.0"
PB.savedVariablesName="PriorityBunnySavedVariablesV4"
PB.savedVariablesVersion=1
PB.labelsByControl={}
PB.labelCounter=0
PB.timerStates={}
PB.alertTokens={}
PB.refreshPending=false
PB.firstNormalSlot=ACTION_BAR_FIRST_NORMAL_SLOT_INDEX+1
PB.lastNormalSlot=ACTION_BAR_ULTIMATE_SLOT_INDEX
PB.pollMS=100

local defaults={
 bar1={1,2,3,4,5},
 bar2={1,2,3,4,5},
 showInactiveBarNumbers=true,
 activeFontSize=26,
 inactiveFontSize=24,
 enableNowAlert=true,
 showNowBanner=true,
 alertScale=2.20,
 alertPulses=3,
 bannerDurationMS=1300,
}

local G={1.00,0.82,0.28,1.00}
local W={1.00,1.00,1.00,1.00}
local choices={"None","1","2","3","4","5"}
local values={0,1,2,3,4,5}

local function Chat(msg)
 d(string.format("|cFFD24APriority Bunny %s:|r %s",PB.version,tostring(msg)))
end

function PB:GetRelativeSlotIndex(slot) return slot-self.firstNormalSlot+1 end
function PB:GetBarKey(cat)
 if cat==HOTBAR_CATEGORY_PRIMARY then return "bar1" end
 if cat==HOTBAR_CATEGORY_BACKUP then return "bar2" end
end
function PB:GetPriorityTable(cat)
 local k=self:GetBarKey(cat)
 return k and self.savedVariables[k] or nil
end
function PB:GetPriorityForSlot(cat,slot)
 local t=self:GetPriorityTable(cat)
 if not t then return 0 end
 return tonumber(t[self:GetRelativeSlotIndex(slot)]) or 0
end
function PB:GetStateKey(cat,slot) return tostring(cat)..":"..tostring(slot) end

function PB:GetOrCreateLabel(slotControl)
 local label=self.labelsByControl[slotControl]
 if label then return label end
 self.labelCounter=self.labelCounter+1
 label=WINDOW_MANAGER:CreateControl("PriorityBunnyNumber"..self.labelCounter,slotControl,CT_LABEL)
 label:SetDimensions(44,44)
 label:SetAnchor(TOPLEFT,slotControl,TOPLEFT,-3,-5)
 label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
 label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
 label:SetColor(unpack(G))
 label:SetDrawTier(DT_HIGH)
 label:SetDrawLayer(DL_OVERLAY)
 label:SetDrawLevel(200)
 label:SetMouseEnabled(false)
 label:SetScale(1.0)
 label:SetHidden(true)
 self.labelsByControl[slotControl]=label
 return label
end

function PB:GetOrCreateNowBanner()
 if self.nowBanner then return self.nowBanner end
 local b=WINDOW_MANAGER:CreateTopLevelWindow("PriorityBunnyNowBanner")
 b:SetDimensions(620,110)
 b:SetAnchor(CENTER,GuiRoot,CENTER,0,165)
 b:SetDrawTier(DT_HIGH)
 b:SetDrawLayer(DL_OVERLAY)
 b:SetDrawLevel(500)
 b:SetMouseEnabled(false)
 b:SetHidden(true)
 local t=WINDOW_MANAGER:CreateControl("PriorityBunnyNowBannerText",b,CT_LABEL)
 t:SetAnchorFill(b)
 t:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
 t:SetVerticalAlignment(TEXT_ALIGN_CENTER)
 t:SetFont("$(BOLD_FONT)|42|thick-outline")
 t:SetColor(unpack(W))
 b.text=t
 self.nowBanner=b
 return b
end

function PB:ResetLabel(label)
 if not label then return end
 label:SetScale(1.0)
 label:SetColor(unpack(G))
end

function PB:ShowNowBanner(priority)
 if not self.savedVariables.showNowBanner then return end
 local b=self:GetOrCreateNowBanner()
 local token=(self.bannerToken or 0)+1
 self.bannerToken=token
 b.text:SetText(string.format("NOW!   PRIORITY %d",priority))
 b:SetHidden(false)
 zo_callLater(function()
   if self.bannerToken==token then b:SetHidden(true) end
 end,tonumber(self.savedVariables.bannerDurationMS) or 1300)
end

function PB:PulseLabel(label)
 if not label or label:IsControlHidden() then return end
 local token=(self.alertTokens[label] or 0)+1
 self.alertTokens[label]=token
 local pulses=math.max(1,tonumber(self.savedVariables.alertPulses) or 3)
 local scale=math.max(1.5,tonumber(self.savedVariables.alertScale) or 2.20)
 self:ResetLabel(label)
 for i=1,pulses do
  local growAt=(i-1)*320
  local settleAt=growAt+185
  zo_callLater(function()
   if self.alertTokens[label]~=token then return end
   label:SetScale(scale); label:SetColor(unpack(W))
  end,growAt)
  zo_callLater(function()
   if self.alertTokens[label]~=token then return end
   label:SetScale(1.0); label:SetColor(unpack(G))
  end,settleAt)
 end
end

function PB:TriggerNow(cat,slot)
 if not self.savedVariables.enableNowAlert then return end
 local p=self:GetPriorityForSlot(cat,slot)
 if p<=0 then return end
 local button=ZO_ActionBar_GetButton(slot,cat)
 if not button or not button.slot then return end
 self:PulseLabel(self:GetOrCreateLabel(button.slot))
 self:ShowNowBanner(p)
end

function PB:RefreshCategory(cat)
 local priorities=self:GetPriorityTable(cat)
 if not priorities then return end
 local inactive=(cat~=GetActiveHotbarCategory())
 local fs=inactive and self.savedVariables.inactiveFontSize or self.savedVariables.activeFontSize
 for slot=self.firstNormalSlot,self.lastNormalSlot do
  local button=ZO_ActionBar_GetButton(slot,cat)
  if button and button.slot then
   local label=self:GetOrCreateLabel(button.slot)
   local p=tonumber(priorities[self:GetRelativeSlotIndex(slot)]) or 0
   local slotType=GetSlotType(slot,cat)
   local show=p>0 and slotType~=ACTION_TYPE_NOTHING and (not inactive or self.savedVariables.showInactiveBarNumbers)
   label:SetFont(string.format("$(BOLD_FONT)|%d|thick-outline",fs))
   label:SetText(show and tostring(p) or "")
   label:SetHidden(not show)
   if not show then self:ResetLabel(label) end
  end
 end
end
function PB:RefreshAll()
 self:RefreshCategory(HOTBAR_CATEGORY_PRIMARY)
 self:RefreshCategory(HOTBAR_CATEGORY_BACKUP)
end
function PB:QueueRefresh(delay)
 if self.refreshPending then return end
 self.refreshPending=true
 zo_callLater(function()
  self.refreshPending=false
  self:RefreshAll()
 end,delay or 50)
end

function PB:PollEffectTimers()
 for _,cat in ipairs({HOTBAR_CATEGORY_PRIMARY,HOTBAR_CATEGORY_BACKUP}) do
  for slot=self.firstNormalSlot,self.lastNormalSlot do
   local key=self:GetStateKey(cat,slot)
   local remaining=GetActionSlotEffectTimeRemaining(slot,cat) or 0
   local running=remaining>0
   if self.timerStates[key]==true and not running then self:TriggerNow(cat,slot) end
   self.timerStates[key]=running
  end
 end
end
function PB:ResetTimerMemory()
 self.timerStates={}
 self:PollEffectTimers()
end
function PB:StartWatcher()
 EVENT_MANAGER:UnregisterForUpdate(self.name.."_TimerPoll")
 EVENT_MANAGER:RegisterForUpdate(self.name.."_TimerPoll",self.pollMS,function() self:PollEffectTimers() end)
end

function PB:MakePriorityOption(key,i,label)
 return {
  type="dropdown",
  name=string.format("%s - Slot %d",label,i),
  tooltip=string.format("Priority number shown on %s slot %d. Choose None to hide it.",label,i),
  choices=choices, choicesValues=values,
  getFunc=function() return self.savedVariables[key][i] or 0 end,
  setFunc=function(v) self.savedVariables[key][i]=tonumber(v) or 0; self:QueueRefresh(0) end,
  default=defaults[key][i], width="full",
 }
end

function PB:RegisterSettings()
 local LAM=LibAddonMenu2
 if not LAM then Chat("LibAddonMenu-2.0 is missing."); return end
 LAM:RegisterAddonPanel("PriorityBunnyOptionsV4",{
  type="panel",name=self.displayName,displayName="|cFFD24APriority Bunny|r",
  author="Savannah & Virgil",version=self.version,
  registerForRefresh=true,registerForDefaults=true,
 })
 local options={
  {type="description",text="|cFFFFFFYOU ARE RUNNING PRIORITY BUNNY 0.4.0|r\n\nBAR 1 and BAR 2 are configured separately. NOW ALERT can pulse the number and show a large HUD banner.",width="full"},
  {type="header",name="BAR 1",width="full"},
 }
 for i=1,5 do table.insert(options,self:MakePriorityOption("bar1",i,"Bar 1")) end
 table.insert(options,{type="header",name="BAR 2",width="full"})
 for i=1,5 do table.insert(options,self:MakePriorityOption("bar2",i,"Bar 2")) end
 table.insert(options,{type="header",name="NOW ALERT",width="full"})
 table.insert(options,{
  type="checkbox",name="Enable NOW alert",
  tooltip="Pulse the priority number when ESO reports its action-slot effect timer has expired.",
  getFunc=function() return self.savedVariables.enableNowAlert end,
  setFunc=function(v) self.savedVariables.enableNowAlert=v end,
  default=defaults.enableNowAlert,width="full",
 })
 table.insert(options,{
  type="checkbox",name="Show large NOW banner",
  tooltip="Shows a large NOW! PRIORITY # message near the center of the HUD.",
  getFunc=function() return self.savedVariables.showNowBanner end,
  setFunc=function(v) self.savedVariables.showNowBanner=v end,
  default=defaults.showNowBanner,width="full",
 })
 table.insert(options,{
  type="checkbox",name="Show numbers on inactive bar",
  tooltip="Keep priority numbers visible on the smaller inactive/back bar row.",
  getFunc=function() return self.savedVariables.showInactiveBarNumbers end,
  setFunc=function(v) self.savedVariables.showInactiveBarNumbers=v; self:QueueRefresh(0) end,
  default=defaults.showInactiveBarNumbers,width="full",
 })
 table.insert(options,{
  type="button",name="TEST NOW ALERT",
  tooltip="Immediately displays the NOW banner so you can verify 0.4.0 is loaded.",
  func=function() self:ShowNowBanner(1) end,width="full",
 })
 LAM:RegisterOptionControls("PriorityBunnyOptionsV4",options)
end

function PB:RegisterEvents()
 EVENT_MANAGER:RegisterForEvent(self.name,EVENT_PLAYER_ACTIVATED,function()
  self:ResetTimerMemory(); self:QueueRefresh(150)
 end)
 EVENT_MANAGER:RegisterForEvent(self.name,EVENT_HOTBAR_SLOT_UPDATED,function() self:QueueRefresh(50) end)
 EVENT_MANAGER:RegisterForEvent(self.name,EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED,function()
  self:ResetTimerMemory(); self:QueueRefresh(100)
 end)
 EVENT_MANAGER:RegisterForEvent(self.name,EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED,function()
  self:ResetTimerMemory(); self:QueueRefresh(100)
 end)
 EVENT_MANAGER:RegisterForEvent(self.name,EVENT_ACTION_SLOT_STATE_UPDATED,function(_,slot)
  if slot and slot>=self.firstNormalSlot and slot<=self.lastNormalSlot then self:QueueRefresh(0) end
 end)
 EVENT_MANAGER:RegisterForEvent(self.name,EVENT_ACTION_UPDATE_COOLDOWNS,function() self:PollEffectTimers() end)
 EVENT_MANAGER:RegisterForEvent(self.name,EVENT_GAMEPAD_PREFERRED_MODE_CHANGED,function() self:QueueRefresh(100) end)
end

function PB:Initialize()
 self.savedVariables=ZO_SavedVars:NewCharacterIdSettings(self.savedVariablesName,self.savedVariablesVersion,nil,defaults)
 self:RegisterSettings()
 self:RegisterEvents()
 self:StartWatcher()
 self:ResetTimerMemory()
 self:QueueRefresh(200)
 Chat("Loaded. Settings should clearly say PRIORITY BUNNY 0.4.0 and BAR 1 / BAR 2.")
end

local function OnAddOnLoaded(_,addonName)
 if addonName~=PB.name then return end
 EVENT_MANAGER:UnregisterForEvent(PB.name,EVENT_ADD_ON_LOADED)
 PB:Initialize()
end
EVENT_MANAGER:RegisterForEvent(PB.name,EVENT_ADD_ON_LOADED,OnAddOnLoaded)
