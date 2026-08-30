BetterTwins = BetterTwins or {}
local BT = BetterTwins
BT.name, BT.displayName, BT.version = "BetterTwins", "Better Twins", "0.0.01-dev1"

local ID = { CINDER=166693, NUMBING=166735, T_MULTI=166745, L_MULTI=166909 }
local bossFor = {[ID.CINDER]="Lylanar", [ID.NUMBING]="Turlassil"}
local defaults = {enabled=true, phaseOneEnabled=true, splitEnabled=true,
    diagnosticArmed=false, diagnosticLines={}, diagnosticPull=0,
    callout={scale=1.0,offsetX=0,offsetY=-165}}
BT.state = {
    Lylanar={interval=20,samples={}}, Turlassil={interval=20,samples={}},
    lockedBoss=nil, calloutUntil=0, recording=false, recordStart=0, recordStop=0,
    reportOpen=false, reportScene=nil, previewActive=false, previewScene=nil,
}

local function BossName(name)
    name = string.lower(zo_strformat("<<C:1>>", name or ""))
    if string.find(name,"lylanar",1,true) then return "Lylanar" end
    if string.find(name,"turlassil",1,true) then return "Turlassil" end
end

local function Short(name)
    name=zo_strformat("<<C:1>>",name or "")
    if name=="" then return "-" end
    return #name>15 and string.sub(name,1,15) or name
end

local function Median(t)
    if #t==0 then return nil end
    local c={}; for i=1,#t do c[i]=t[i] end; table.sort(c)
    local m=math.floor((#c+1)/2)
    return #c%2==1 and c[m] or (c[m]+c[m+1])/2
end

-- Not every named ActionResult constant is exported on every console API.
-- Never use a possibly nil global directly as a table key during file load.
local resultNames = {}
local function AddResultName(result, name)
    if result ~= nil then resultNames[result] = name end
end
AddResultName(ACTION_RESULT_BEGIN, "BEGIN")
AddResultName(ACTION_RESULT_EFFECT_GAINED, "GAIN")
AddResultName(ACTION_RESULT_EFFECT_GAINED_DURATION, "GAIN_DUR")
AddResultName(ACTION_RESULT_EFFECT_FADED, "FADE")
AddResultName(ACTION_RESULT_DAMAGE, "DAMAGE")
AddResultName(ACTION_RESULT_HIT, "HIT")

function BT:CreateHUD()
    local w=WINDOW_MANAGER
    local root=w:CreateTopLevelWindow("BetterTwinsHUD")
    root:SetDimensions(900,190); root:SetHidden(true)
    local boss=w:CreateControl("$(parent)Boss",root,CT_LABEL)
    boss:SetAnchor(TOP,root,TOP); boss:SetFont("ZoFontGamepadBold34"); boss:SetHorizontalAlignment(TEXT_ALIGN_CENTER); boss:SetDimensions(900,42)
    local main=w:CreateControl("$(parent)Main",root,CT_LABEL)
    main:SetAnchor(TOP,boss,BOTTOM,0,4); main:SetFont("ZoFontGamepadBold54"); main:SetHorizontalAlignment(TEXT_ALIGN_CENTER); main:SetDimensions(900,76)
    local sub=w:CreateControl("$(parent)Sub",root,CT_LABEL)
    sub:SetAnchor(TOP,main,BOTTOM); sub:SetFont("ZoFontGamepadBold27"); sub:SetHorizontalAlignment(TEXT_ALIGN_CENTER); sub:SetDimensions(900,40)
    self.hud={root=root,boss=boss,main=main,sub=sub}
    self.hudFragment=ZO_HUDFadeSceneFragment:New(root,nil,0)
    HUD_SCENE:AddFragment(self.hudFragment); HUD_UI_SCENE:AddFragment(self.hudFragment)
    self:ApplyCalloutLayout()
end

function BT:ApplyCalloutLayout()
    if not self.hud or not self.sv then return end
    local saved=self.sv.callout or defaults.callout
    self.hud.root:ClearAnchors()
    self.hud.root:SetAnchor(CENTER,GuiRoot,CENTER,saved.offsetX or 0,saved.offsetY or -165)
    self.hud.root:SetScale(zo_clamp(saved.scale or 1,0.60,1.60))
end

function BT:AttachPreview()
    local current=SCENE_MANAGER and SCENE_MANAGER:GetCurrentScene() or nil
    local previous=self.state.previewScene
    if previous and previous~=current and previous~=HUD_SCENE and previous~=HUD_UI_SCENE then previous:RemoveFragment(self.hudFragment) end
    self.state.previewScene=nil
    if current and current~=HUD_SCENE and current~=HUD_UI_SCENE then current:AddFragment(self.hudFragment); self.state.previewScene=current end
end

function BT:ShowPreview()
    self.state.previewActive=true; self:AttachPreview(); self:ApplyCalloutLayout()
    self.hud.boss:SetText("LYLANAR"); self.hud.main:SetText("GRAB DOME NOW"); self.hud.main:SetColor(1,.72,.08,1); self.hud.sub:SetText("ICE DOME • PREVIEW"); self.hud.root:SetHidden(false)
    EVENT_MANAGER:UnregisterForUpdate(self.name.."PreviewTimeout")
    EVENT_MANAGER:RegisterForUpdate(self.name.."PreviewTimeout",5000,function() EVENT_MANAGER:UnregisterForUpdate(self.name.."PreviewTimeout"); self:HidePreview() end)
end

function BT:HidePreview()
    self.state.previewActive=false; EVENT_MANAGER:UnregisterForUpdate(self.name.."PreviewTimeout")
    local scene=self.state.previewScene; self.state.previewScene=nil
    if scene and scene~=HUD_SCENE and scene~=HUD_UI_SCENE then scene:RemoveFragment(self.hudFragment) end
    self.hud.root:SetHidden(true)
end

function BT:CreateReport()
    local w=WINDOW_MANAGER
    local root=w:CreateTopLevelWindow("BetterTwinsDiagnosticReport")
    root:SetDimensions(1180,760); root:SetAnchor(CENTER,GuiRoot,CENTER); root:SetDrawTier(DT_HIGH); root:SetDrawLayer(DL_OVERLAY); root:SetHidden(true)
    local bg=w:CreateControl("$(parent)BG",root,CT_BACKDROP); bg:SetAnchorFill(); bg:SetCenterColor(.025,.035,.055,.97); bg:SetEdgeColor(.79,.5,.09,1); bg:SetEdgeTexture("EsoUI/Art/Tooltips/Gamepad/gp_toolTip_edge.dds",16,4)
    local title=w:CreateControl("$(parent)Title",root,CT_LABEL); title:SetAnchor(TOPLEFT,root,TOPLEFT,36,24); title:SetFont("ZoFontGamepadBold34"); title:SetColor(1,.72,.12,1); title:SetText("BETTER TWINS — CORNER DIAGNOSTIC"); title:SetDimensions(1100,44)
    local status=w:CreateControl("$(parent)Status",root,CT_LABEL); status:SetAnchor(TOPLEFT,title,BOTTOMLEFT,0,4); status:SetFont("ZoFontGamepad27"); status:SetDimensions(1100,36)
    local scroll=w:CreateControlFromVirtual("$(parent)Scroll",root,"ZO_ScrollContainer"); scroll:SetAnchor(TOPLEFT,status,BOTTOMLEFT,0,18); scroll:SetDimensions(1100,570)
    local child=scroll:GetNamedChild("ScrollChild")
    local label=w:CreateControl("$(parent)Text",child,CT_LABEL); label:SetAnchor(TOPLEFT,child,TOPLEFT); label:SetFont("ZoFontGamepad22"); label:SetColor(.94,.96,1,1); label:SetWidth(1060)
    local foot=w:CreateControl("$(parent)Footer",root,CT_LABEL); foot:SetAnchor(BOTTOMLEFT,root,BOTTOMLEFT,36,-22); foot:SetFont("ZoFontGamepad22"); foot:SetText("Right stick: Scroll  •  |cFFD700Circle: Close|r"); foot:SetDimensions(1100,32)
    self.report={root=root,status=status,scroll=scroll,child=child,label=label}
    self.reportKeys={alignment=KEYBIND_STRIP_ALIGN_LEFT,{name=GetString(SI_DIALOG_CLOSE),keybind="UI_SHORTCUT_NEGATIVE",callback=function() self:CloseReport() end}}
end

function BT:HudScene()
    if self.state.reportOpen then return false end
    if self.state.previewActive then return true end
    local s=SCENE_MANAGER and SCENE_MANAGER:GetCurrentScene()
    if not s then return true end
    local n=s:GetName(); return n=="hud" or n=="hudui"
end

function BT:BothTwinsPresent()
    local foundL,foundT=false,false
    for i=1,6 do
        local tag="boss"..i
        if DoesUnitExist(tag) then local boss=BossName(GetUnitName(tag)); foundL=foundL or boss=="Lylanar"; foundT=foundT or boss=="Turlassil" end
    end
    return foundL and foundT
end

function BT:CaptureHardTarget()
    if self.state.lockedBoss or not self.sv.splitEnabled or not IsUnitInCombat("player") or not self:BothTwinsPresent() then return end
    if DoesUnitExist("reticleover") and IsUnitAttackable("reticleover") then
        local boss=BossName(GetUnitName("reticleover"))
        if boss then self.state.lockedBoss=boss end
    end
end

function BT:Callout(text,boss,color,duration)
    if not self:HudScene() then return end
    self.state.calloutUntil=GetGameTimeMilliseconds()+(duration or 1700)
    self.hud.boss:SetText(string.upper(boss or "TWINS")); self.hud.main:SetText(text); self.hud.main:SetColor(unpack(color)); self.hud.sub:SetText(""); self.hud.root:SetHidden(false)
end

function BT:AddLine(text)
    local t=self.sv.diagnosticLines; t[#t+1]=text
    if #t>180 then table.remove(t,1) end
end

function BT:StartRecording(abilityId,sourceName)
    local boss=abilityId==ID.L_MULTI and "Lylanar" or "Turlassil"
    if self.sv.phaseOneEnabled then self:Callout("CORNER SEQUENCE",boss,{1,.72,.08,1},2600); self.hud.sub:SetText("WATCH THROWS 1 - 4") end
    if not self.sv.diagnosticArmed or not self.sv.phaseOneEnabled then return end
    local now=GetGameTimeMilliseconds(); self.state.recording=true; self.state.recordStart=now; self.state.recordStop=now+30000
    self.sv.diagnosticPull=(self.sv.diagnosticPull or 0)+1; self.sv.diagnosticLines={}
    self:AddLine(string.format("Better Twins %s | Capture %d",self.version,self.sv.diagnosticPull))
    self:AddLine(string.format("START +0.000 %s MultiLoc id=%d source=%s",boss,abilityId,Short(sourceName)))
    self:AddLine("TIME     ID      RESULT    VALUE  SOURCE          TARGET          SRC-ID      TGT-ID      ABILITY")
    EVENT_MANAGER:RegisterForEvent(self.name.."Diagnostic",EVENT_COMBAT_EVENT,function(...) self:DiagnosticEvent(...) end)
end

function BT:StopRecording(reason)
    if not self.state.recording then return end
    self.state.recording=false; EVENT_MANAGER:UnregisterForEvent(self.name.."Diagnostic",EVENT_COMBAT_EVENT)
    self:AddLine(string.format("END +%.3f %s",(GetGameTimeMilliseconds()-self.state.recordStart)/1000,reason or "complete"))
end

function BT:DiagnosticEvent(_,result,_,abilityName,_,_,sourceName,_,targetName,_,hitValue,_,_,_,sourceId,targetId,abilityId)
    if not self.state.recording then return end
    if not BossName(sourceName) and (abilityId<166100 or abilityId>177400) then return end
    self:AddLine(string.format("+%06.3f %-7d %-9s %-6d %-15s %-15s %-11s %-11s %s",
        (GetGameTimeMilliseconds()-self.state.recordStart)/1000,abilityId,resultNames[result] or tostring(result),hitValue or 0,Short(sourceName),Short(targetName),tostring(sourceId or 0),tostring(targetId or 0),Short(abilityName)))
end

function BT:Interrupt(abilityId,sourceName)
    if not self.sv.splitEnabled then return end
    local boss=bossFor[abilityId] or BossName(sourceName); if not boss then return end
    local now=GetGameTimeMilliseconds()/1000; local s=self.state[boss]
    if s.last and now-s.last>8 and now-s.last<40 then s.samples[#s.samples+1]=now-s.last; if #s.samples>5 then table.remove(s.samples,1) end; s.interval=Median(s.samples) or s.interval end
    s.last=now; s.next=now+s.interval
    if self.state.lockedBoss==boss then self:Callout("BASH NOW",boss,{1,.2,.1,1},1800); self.hud.sub:SetText(boss=="Lylanar" and "ICE DOME" or "FIRE DOME") end
end

function BT:TrackedEvent(_,result,_,_,_,_,sourceName,_,_,_,_,_,_,_,_,_,abilityId)
    if not self.sv.enabled then return end
    if (abilityId==ID.CINDER or abilityId==ID.NUMBING) and (result==ACTION_RESULT_EFFECT_GAINED or result==ACTION_RESULT_BEGIN) then self:Interrupt(abilityId,sourceName)
    elseif (abilityId==ID.L_MULTI or abilityId==ID.T_MULTI) and (result==ACTION_RESULT_EFFECT_GAINED or result==ACTION_RESULT_BEGIN) and not self.state.recording then self:StartRecording(abilityId,sourceName) end
end

function BT:RefreshReport()
    local t=self.sv.diagnosticLines or {}
    self.report.status:SetText(#t==0 and "No corner-phase capture recorded." or string.format("%s • %d recorded lines",self.state.recording and "RECORDING" or "CAPTURE COMPLETE",#t))
    self.report.label:SetText(#t==0 and "Arm Diagnostic Recorder before the fight. Recording begins automatically when MultiLoc starts." or table.concat(t,"\n"))
    local h=math.max(550,self.report.label:GetTextHeight()+20); self.report.label:SetHeight(h); self.report.child:SetHeight(h); ZO_Scroll_ResetToTop(self.report.scroll)
end

function BT:OpenReport()
    if self.state.reportOpen then return end
    self:RefreshReport(); self.state.reportOpen=true; self.hud.root:SetHidden(true); self.report.root:SetHidden(false); KEYBIND_STRIP:AddKeybindButtonGroup(self.reportKeys)
    local s=SCENE_MANAGER and SCENE_MANAGER:GetCurrentScene(); self.state.reportScene=s; if s then s:RegisterCallback("StateChange",self.sceneCallback) end
end

function BT:CloseReport()
    if not self.state.reportOpen then return end
    self.state.reportOpen=false; self.report.root:SetHidden(true); KEYBIND_STRIP:RemoveKeybindButtonGroup(self.reportKeys)
    local s=self.state.reportScene; if s then s:UnregisterCallback("StateChange",self.sceneCallback) end; self.state.reportScene=nil
end

function BT:Update()
    self:CaptureHardTarget()
    if self.state.recording and GetGameTimeMilliseconds()>=self.state.recordStop then self:StopRecording("30-second corner window complete") end
    if not self.sv.enabled or not self.sv.splitEnabled or not self:HudScene() then self.hud.root:SetHidden(true); return end
    local now=GetGameTimeMilliseconds(); if now<self.state.calloutUntil then return end
    local boss=self.state.lockedBoss; local s=boss and self.state[boss]
    if not s or not s.next then self.hud.root:SetHidden(true); return end
    local left=s.next-now/1000
    if left<=1 then self:Callout("GRAB DOME NOW",boss,{1,.72,.08,1},1000); s.next=nil
    elseif left<=5 then self.hud.boss:SetText(string.upper(boss)); self.hud.main:SetText(string.format("DOME IN %.1f",left)); self.hud.main:SetColor(1,.72,.08,1); self.hud.sub:SetText(boss=="Lylanar" and "ICE DOME" or "FIRE DOME"); self.hud.root:SetHidden(false)
    else self.hud.root:SetHidden(true) end
end

function BT:ResetFight()
    self:StopRecording("combat ended")
    for _,b in ipairs({"Lylanar","Turlassil"}) do local s=self.state[b]; s.next=nil;s.last=nil;s.samples={};s.interval=20 end
    self.state.lockedBoss=nil; self.state.calloutUntil=0; self.hud.root:SetHidden(true)
end

function BT:Initialize()
    self.sv=ZO_SavedVars:NewAccountWide("BetterTwinsSavedVariables",1,nil,defaults); self:CreateHUD(); self:CreateReport(); self:CreateSettingsMenu()
    self.sceneCallback=function(_,newState) if newState==SCENE_HIDING or newState==SCENE_HIDDEN then self:CloseReport() end end
    for key,id in pairs(ID) do local n=self.name.."Combat"..key; EVENT_MANAGER:RegisterForEvent(n,EVENT_COMBAT_EVENT,function(...) self:TrackedEvent(...) end); EVENT_MANAGER:AddFilterForEvent(n,EVENT_COMBAT_EVENT,REGISTER_FILTER_ABILITY_ID,id) end
    EVENT_MANAGER:RegisterForEvent(self.name.."Target",EVENT_RETICLE_TARGET_CHANGED,function() self:CaptureHardTarget() end)
    EVENT_MANAGER:RegisterForEvent(self.name.."CombatState",EVENT_PLAYER_COMBAT_STATE,function(_,active) if not active then self:ResetFight() end end)
    SCENE_MANAGER:RegisterCallback("SceneStateChanged",function() if not self:HudScene() then self.hud.root:SetHidden(true) end end)
    EVENT_MANAGER:RegisterForUpdate(self.name.."Update",100,function() self:Update() end)
end

local function Loaded(_,name) if name~=BT.name then return end EVENT_MANAGER:UnregisterForEvent(BT.name,EVENT_ADD_ON_LOADED); BT:Initialize() end
EVENT_MANAGER:RegisterForEvent(BT.name,EVENT_ADD_ON_LOADED,Loaded)
