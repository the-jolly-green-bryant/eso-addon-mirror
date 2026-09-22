RyticRaidMode=RyticRaidMode or {}
local RM=RyticRaidMode
local EM=EVENT_MANAGER
local WM=WINDOW_MANAGER
RM.name="RyticRaidMode"
RM.version="0.3.1"

local defaults={
 autoPrompt=true, active=false, snapshot=nil, windowHidden=false,
 raidProfile={}, roleProfiles={HEALER={}}, classProfiles={}, zoneProfiles={},
}

-- User-requested baseline. Matching is deliberately fuzzy because ESO folder names
-- can differ from the display names shown in Minion/AddOn Manager.
local CORE_PATTERNS={
 "raidnotifier","raid notifier",
 "codescombatalerts","code's combat alerts","codes combat alerts",
 "autorecharge","auto recharge",
 "autoinvite","auto invite",
 "accountsettings","account settings",
 "bandits","banditsui",
 "bugcatcher",
 "codesextendedcombatalerts","code's extended combat alerts","codes extended combat alerts",
 "combatmetrics","combat metrics",
 "crutchalerts","crutch alerts",
 "hodorreflexes","hodor reflexes",
 "lootlog","loot log",
 "moremarkers","more markers",
 "ody",
 "ryticprofiler","rytic profiler",
 "ryticreloadui","rytic reload ui",
 "rytictankandraidtools","rytic tank and raid tools",
 "ryticidtool","rytic id tool",
 "votansminimap","votan's minimap","votans minimap",
 "wizardswardrobe","wizard's wardrobe","wizards wardrobe",
 "libcustomicons","lib custom icons",
 "libcustomnames","lib custom names",
}
local HEALER_PATTERNS={"wifey","healingmeter","healing meter"}
local DPS_PATTERNS={"combatmetronome","combat metronome"}
-- Trial-specific addon mapping. Multiple helpers may intentionally match one trial.
-- Values are fuzzy folder/display-name patterns; dependency closure is applied afterward.
local TRIAL_HELPERS={
 ["cloudrest"]={"howtocloudrest"},
 ["sunspire"]={"howtosunspire"},
 ["rockgrove"]={"rockgrovehelper","ucellrockgrovehelper","rockgrove helper"},
 ["sanitysedge"]={"sanitysedgehelper","sanity's edge helper","sanity edge helper"},
 ["osseincage"]={
   "osseincagehelper","ossein cage helper",
   "asquart","asquartosseincagehelper",
   "jppatch","jp patch for ossein cage helper",
 },
 ["asylumsanctorium"]={"vashelper","asylum","asylum helper"},
 ["dreadsailreef"]={"dreadsailreefhelper","dreadsail reef helper"},
 ["lucentcitadel"]={"lucentcitadelhelper","lucent citadel helper"},
}
local CLASS_NAMES={
 [1]="DRAGONKNIGHT",[2]="SORCERER",[3]="NIGHTBLADE",[4]="WARDEN",
 [5]="NECROMANCER",[6]="TEMPLAR",[117]="ARCANIST",
}
local CLASS_MASTERY_PATTERNS={
 DRAGONKNIGHT={"dragonknightmastery","dkmastery","dragonknight mastery","dk mastery"},
 SORCERER={"sorcerermastery","sorcerer mastery","sorcmastery","sorc mastery"},
 NIGHTBLADE={"nightblademastery","nightblade mastery","nbmastery","nb mastery"},
 WARDEN={"wardenmastery","warden mastery"},
 NECROMANCER={"necromancermastery","necromancer mastery","necromastery","necro mastery"},
 TEMPLAR={"templarmastery","templar mastery"},
 ARCANIST={"arcanistmastery","arcanist mastery","arcmastery","arc mastery"},
}

local function msg(x) d("|cFFAA00Rytic's Raid Manager:|r "..x) end
local function AM() return GetAddOnManager() end
local function norm(x)
 x=zo_strlower(x or "")
 x=x:gsub("|c%x%x%x%x%x%x",""):gsub("|r","")
 return x:gsub("[^%w]","")
end
local function addonData(i)
 local m=AM()
 local name,title,author,desc,enabled,state,outdated,isLibrary=m:GetAddOnInfo(i)
 return {index=i,name=name,title=title or name,enabled=enabled,state=state,isLibrary=isLibrary}
end
local function allAddons()
 local t={}
 local m=AM()
 for i=1,m:GetNumAddOns() do t[#t+1]=addonData(i) end
 return t
end
local function matches(a,patterns)
 local n,t=norm(a.name),norm(a.title)
 for _,p in ipairs(patterns) do
  local q=norm(p)
  if q~="" and (n:find(q,1,true) or t:find(q,1,true)) then return true end
 end
 return false
end
local function findIndexByName(name)
 for _,a in ipairs(allAddons()) do if a.name==name then return a.index end end
end
local function setEnabledByName(name,on)
 local i=findIndexByName(name)
 if i then AM():SetAddOnEnabled(i,on); return true end
 return false
end
local function snapshot()
 local t={}
 for _,a in ipairs(allAddons()) do t[a.name]=a.enabled==true end
 RM.saved.snapshot=t
end

-- Required dependency closure using ESO's live AddOnManager dependency API.
local function addDependencies(profile)
 local m=AM()
 local changed=true
 while changed do
  changed=false
  for name,on in pairs(profile) do
   if on then
    local idx=findIndexByName(name)
    if idx then
     local n=m:GetAddOnNumDependencies(idx)
     for j=1,n do
      local depName,exists=m:GetAddOnDependencyInfo(idx,j)
      if exists and depName and not profile[depName] then
       profile[depName]=true; changed=true
      end
     end
    end
   end
  end
 end
end

local function addMatches(profile,patterns)
 for _,a in ipairs(allAddons()) do if matches(a,patterns) then profile[a.name]=true end end
end

local function currentRole()
 local role=GetSelectedLFGRole and GetSelectedLFGRole() or nil
 if role==LFG_ROLE_HEAL then return "HEALER" end
 if role==LFG_ROLE_TANK then return "TANK" end
 if role==LFG_ROLE_DPS then return "DPS" end
 return "UNKNOWN"
end
local function currentClass()
 local id=GetUnitClassId and GetUnitClassId("player") or 0
 return CLASS_NAMES[id] or tostring(id)
end
local function currentZoneName()
 return GetUnitZone and GetUnitZone("player") or ""
end

local function buildSmartProfile()
 local p={}
 p[RM.name]=true
 addMatches(p,CORE_PATTERNS)

 -- Anything the user explicitly saved into the Raid Profile remains core.
 for n,v in pairs(RM.saved.raidProfile or {}) do if v then p[n]=true end end

 local role=currentRole()
 if role=="HEALER" then addMatches(p,HEALER_PATTERNS) end
 if role=="DPS" then addMatches(p,DPS_PATTERNS) end
 for n,v in pairs((RM.saved.roleProfiles or {})[role] or {}) do if v then p[n]=true end end

 local class=currentClass()
 -- Automatically include only the current character's installed Mastery tracker.
 local classPatterns=CLASS_MASTERY_PATTERNS[class]
 if classPatterns then addMatches(p,classPatterns) end
 -- Preserve support for any user-added class-specific entries.
 for n,v in pairs((RM.saved.classProfiles or {})[class] or {}) do if v then p[n]=true end end

 -- Current-trial helper layer. Supports HowTo*, *Helper, vAS/Asylum,
 -- and multiple simultaneous helpers for the same trial (notably Ossein Cage).
 local z=norm(currentZoneName())
 for zoneKey,patterns in pairs(TRIAL_HELPERS) do
  if z:find(norm(zoneKey),1,true) then
   addMatches(p,patterns)
  end
 end
 for zone,zt in pairs(RM.saved.zoneProfiles or {}) do
  if z==norm(zone) then for n,v in pairs(zt) do if v then p[n]=true end end end
 end

 addDependencies(p)
 return p
end

local function saveCurrentAsRaidProfile()
 local p={}
 for _,a in ipairs(allAddons()) do
  if a.enabled and a.name~=RM.name then p[a.name]=true end
 end
 RM.saved.raidProfile=p
 msg("Current enabled addons saved as the Raid Profile.")
 RM.Refresh()
end

local function applyRaid()
 if RM.saved.active then msg("Raid Mode is already active."); return end
 snapshot()
 local p=buildSmartProfile()
 for _,a in ipairs(allAddons()) do AM():SetAddOnEnabled(a.index,p[a.name]==true) end
 setEnabledByName(RM.name,true)
 RM.saved.active=true
 msg("Raid Mode applied. Reloading UI...")
 zo_callLater(function() ReloadUI("ingame") end,350)
end

local function restore()
 local s=RM.saved.snapshot
 if type(s)~="table" then msg("No pre-raid addon snapshot is saved."); return end
 for _,a in ipairs(allAddons()) do
  if s[a.name]~=nil then AM():SetAddOnEnabled(a.index,s[a.name]) end
 end
 setEnabledByName(RM.name,true)
 RM.saved.active=false
 RM.saved.snapshot=nil
 msg("Previous addon state restored. Reloading UI...")
 zo_callLater(function() ReloadUI("ingame") end,350)
end

local function inGroupInstance()
 if IsPlayerInRaid and IsPlayerInRaid() then return true end
 if IsUnitInDungeon then local ok,v=pcall(IsUnitInDungeon,"player"); if ok and v then return true end end
 return false
end

local function prompt(entering)
 local body=entering and
  "Group instance detected.\n\nLoad the smart Raid profile for this character, role and instance?" or
  "Raid Mode is active and you left the instance.\n\nRestore your exact pre-raid addon setup?"
 ZO_Dialogs_ShowDialog("RYTIC_RAID_MODE_PROMPT",{entering=entering},{mainTextParams={body}})
end
local function zoneCheck()
 if not RM.saved.autoPrompt then return end
 local inside=inGroupInstance()
 if inside and not RM.saved.active then zo_callLater(function() prompt(true) end,1400)
 elseif not inside and RM.saved.active then zo_callLater(function() prompt(false) end,1400) end
end

local function dependencyNames(a)
 local m=AM()
 local deps={}
 local n=m:GetAddOnNumDependencies(a.index)
 for j=1,n do
  local depName,exists=m:GetAddOnDependencyInfo(a.index,j)
  if depName then deps[#deps+1]=(exists and depName or (depName.." [MISSING]")) end
 end
 table.sort(deps)
 return deps
end

local function reverseDependencies()
 local usedBy={}
 local m=AM()
 -- Scan EVERY installed entry, enabled or disabled, so occasional-use addons
 -- still protect the libraries they declare as dependencies.
 for _,a in ipairs(allAddons()) do
  local n=m:GetAddOnNumDependencies(a.index)
  for j=1,n do
   local depName,exists=m:GetAddOnDependencyInfo(a.index,j)
   if depName and exists then
    usedBy[depName]=usedBy[depName] or {}
    table.insert(usedBy[depName],a.name)
   end
  end
 end
 for _,users in pairs(usedBy) do table.sort(users) end
 return usedBy
end

local function printAddonInventory()
 local smart=buildSmartProfile()
 local addons=allAddons()
 local usedBy=reverseDependencies()
 table.sort(addons,function(a,b) return zo_strlower(a.title or a.name)<zo_strlower(b.title or b.name) end)

 local orphanCount=0
 for _,a in ipairs(addons) do
  if a.isLibrary and #(usedBy[a.name] or {})==0 then orphanCount=orphanCount+1 end
 end

 d(" ")
 d("|cFFAA00===== RYTIC'S RAID MANAGER : INSTALLED ADDON INVENTORY =====|r")
 d(string.format("|cFFFFFFInstalled: %d   Smart Raid Stack: %d   Possible Orphans: %d|r",
   #addons,(function() local n=0 for _,v in pairs(smart) do if v then n=n+1 end end return n end)(),orphanCount))
 d("|cAAAAAAFormat: STATE | TYPE | RAID STATUS | NAME | deps | USED BY|r")

 for _,a in ipairs(addons) do
  local state=a.enabled and "|c66FF66ON|r" or "|cFF6666OFF|r"
  local typ=a.isLibrary and "LIB" or "ADDON"
  local raid
  if a.name==RM.name or matches(a,CORE_PATTERNS) then raid="CORE"
  elseif smart[a.name] then raid="DEPENDENCY/SMART"
  else raid="NOT RAID"
  end
  local deps=dependencyNames(a)
  local depText=#deps>0 and table.concat(deps,", ") or "-"
  local users=usedBy[a.name] or {}
  local usedText=#users>0 and table.concat(users,", ") or "-"
  local orphan=(a.isLibrary and #users==0) and " | |cFF4444POSSIBLE ORPHAN|r" or ""
  d(string.format("%s | %s | %s | %s [%s] | deps: %s | USED BY: %s%s",
      state,typ,raid,a.title or a.name,a.name,depText,usedText,orphan))
 end
 d("|cFFAA00===== END ADDON INVENTORY =====|r")
 d("|cAAAAAAPOSSIBLE ORPHAN = no installed addon (ON or OFF) declares that library as a dependency.|r")
end

-- Compact control window
local function button(parent,text,x,y,w,cb)
 local b=WM:CreateControlFromVirtual(nil,parent,"ZO_DefaultButton")
 b:SetDimensions(w or 150,28); b:SetAnchor(TOPLEFT,parent,TOPLEFT,x,y); b:SetText(text); b:SetHandler("OnClicked",cb)
 return b
end
local function makeUI()
 local w=WM:CreateTopLevelWindow("RyticRaidModeWindow")
 RM.win=w; w:SetDimensions(650,255); w:SetAnchor(CENTER,GuiRoot,CENTER,0,0)
 w:SetMovable(true); w:SetMouseEnabled(true); w:SetClampedToScreen(true)

 -- ESOUI fragment rules: scene work is deferred until PLAYER_ACTIVATED.
 -- Zero delay follows the HUD fragment guidance and avoids fade-delay issues.
 RM.hudFragment=ZO_HUDFadeSceneFragment:New(w,nil,0)
 RM.hudFragment:RegisterCallback("StateChange",function(_,newState)
  if newState==SCENE_FRAGMENT_SHOWN then
   if RM.saved.windowHidden then w:SetHidden(true) end
   RM.Refresh()
  elseif newState==SCENE_FRAGMENT_HIDDEN then
   -- HUD scene lifecycle owns menu visibility.
  end
 end)
 RM.fragmentAttached=false

 local bg=WM:CreateControl(nil,w,CT_BACKDROP); bg:SetAnchorFill()
 bg:SetCenterColor(0.03,0.03,0.03,0.94); bg:SetEdgeColor(0.65,0.45,0.05,1)
 bg:SetEdgeTexture("",1,1,1)
 local title=WM:CreateControl(nil,w,CT_LABEL); title:SetFont("ZoFontWinH2")
 title:SetText("Rytic's Raid Manager  v"..RM.version); title:SetAnchor(TOPLEFT,w,TOPLEFT,15,12)
 RM.status=WM:CreateControl(nil,w,CT_LABEL); RM.status:SetFont("ZoFontGame")
 RM.status:SetDimensions(620,80); RM.status:SetAnchor(TOPLEFT,w,TOPLEFT,15,52)
 button(w,"SAVE CURRENT AS RAID",15,145,180,saveCurrentAsRaidProfile)
 button(w,"RAID MODE",205,145,105,applyRaid)
 button(w,"RESTORE",320,145,105,restore)
 button(w,"HIDE",435,145,105,function()
  RM.saved.windowHidden=true
  if RM.hudFragment and RM.fragmentAttached then
   HUD_SCENE:RemoveFragment(RM.hudFragment)
   HUD_UI_SCENE:RemoveFragment(RM.hudFragment)
   RM.fragmentAttached=false
  end
  w:SetHidden(true)
 end)
 button(w,"AUTO PROMPT",15,188,140,function() RM.saved.autoPrompt=not RM.saved.autoPrompt; RM.Refresh() end)
 button(w,"PRINT PROFILE",165,188,140,function()
  local p=buildSmartProfile(); msg("Smart profile:")
  local names={}; for n,v in pairs(p) do if v then names[#names+1]=n end end
  table.sort(names); for _,n in ipairs(names) do d("  "..n) end
 end)
 button(w,"LIST ALL ADDONS",315,188,150,printAddonInventory)
end
function RM.Refresh()
 if not RM.status then return end
 local p=buildSmartProfile(); local n=0; for _,v in pairs(p) do if v then n=n+1 end end
 RM.status:SetText(string.format("State: %s\nClass: %s    Role: %s\nZone: %s\nSmart Raid stack: %d addons/libraries    Auto Prompt: %s",
  RM.saved.active and "RAID MODE" or "NORMAL",currentClass(),currentRole(),currentZoneName(),n,RM.saved.autoPrompt and "ON" or "OFF"))
end

local function attachHudFragment()
 if not RM.hudFragment or RM.fragmentAttached then return end
 HUD_SCENE:AddFragment(RM.hudFragment)
 HUD_UI_SCENE:AddFragment(RM.hudFragment)
 RM.fragmentAttached=true
end

local function slash(arg)
 arg=zo_strlower((arg or ""):gsub("^%s+",""):gsub("%s+$",""))
 if arg=="show" then
  RM.saved.windowHidden=false
  attachHudFragment()
  RM.Refresh()
 elseif arg=="hide" then
  RM.saved.windowHidden=true
  if RM.hudFragment and RM.fragmentAttached then
   HUD_SCENE:RemoveFragment(RM.hudFragment)
   HUD_UI_SCENE:RemoveFragment(RM.hudFragment)
   RM.fragmentAttached=false
  end
  if RM.win then RM.win:SetHidden(true) end
 elseif arg=="raid" then applyRaid()
 elseif arg=="restore" then restore()
 elseif arg=="save" then saveCurrentAsRaidProfile()
 elseif arg=="auto on" then RM.saved.autoPrompt=true; RM.Refresh(); msg("Auto Prompt ON.")
 elseif arg=="auto off" then RM.saved.autoPrompt=false; RM.Refresh(); msg("Auto Prompt OFF.")
 elseif arg=="profile" then
  local p=buildSmartProfile(); local names={}; for n,v in pairs(p) do if v then names[#names+1]=n end end
  table.sort(names); msg("Smart profile:"); for _,n in ipairs(names) do d("  "..n) end
 elseif arg=="addons" then printAddonInventory()
 else msg("/rrm show | hide | save | raid | restore | profile | addons | auto on/off") end
end

local function loaded(_,name)
 if name~=RM.name then return end
 EM:UnregisterForEvent(RM.name,EVENT_ADD_ON_LOADED)
 RM.saved=ZO_SavedVars:NewAccountWide("RyticRaidModeSavedVariables",2,GetWorldName(),defaults)
 ZO_Dialogs_RegisterCustomDialog("RYTIC_RAID_MODE_PROMPT",{
  canQueue=true,title={text="Rytic's Raid Manager"},mainText={text="<<1>>"},
  buttons={
   [1]={text=SI_DIALOG_ACCEPT,callback=function(d) if d.data.entering then applyRaid() else restore() end end},
   [2]={text=SI_DIALOG_CANCEL},
  },
 })
 SLASH_COMMANDS["/rrm"]=slash

 -- SCENE_MANAGER/HUD scenes are not assumed ready during EVENT_ADD_ON_LOADED.
 -- Create and attach the UI fragment only after EVENT_PLAYER_ACTIVATED.
 EM:RegisterForEvent("RyticRaidModePlayerActivated",EVENT_PLAYER_ACTIVATED,function()
  if not RM.win then
   makeUI()
   if not RM.saved.windowHidden then
    attachHudFragment()
   else
    RM.win:SetHidden(true)
   end
   RM.Refresh()
   msg("loaded. /rrm show")
  else
   RM.Refresh()
  end
  zoneCheck()
 end)
end
EM:RegisterForEvent(RM.name,EVENT_ADD_ON_LOADED,loaded)
