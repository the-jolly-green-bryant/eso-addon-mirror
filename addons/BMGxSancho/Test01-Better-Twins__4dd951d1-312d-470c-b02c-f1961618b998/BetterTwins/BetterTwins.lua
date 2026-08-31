BetterTwins = BetterTwins or {}
local BT = BetterTwins
BT.name, BT.displayName, BT.version = "BetterTwins", "Better Twins", "0.0.01-dev2"

local ID = { CINDER=166693, NUMBING=166735, T_MULTI=166745, L_MULTI=166909 }
local bossFor = {[ID.CINDER]="Lylanar", [ID.NUMBING]="Turlassil"}
local diagnosticCandidates = {
    [166745]=true,[166766]=true,[166776]=true,[166777]=true,[166778]=true,
    [166803]=true,[166804]=true,[166830]=true,[166880]=true,[166886]=true,
    [166887]=true,[166897]=true,[166898]=true,[166899]=true,[166900]=true,
    [166909]=true,[166910]=true,[166911]=true,[166912]=true,[166913]=true,
    [166914]=true,[166915]=true,[168200]=true,[168228]=true,[168229]=true,
    [168246]=true,[169406]=true,[169420]=true,
}
local splitTimingCandidates = {
    [166693]=true,[166694]=true,[166695]=true,[166701]=true,[166734]=true,
    [166735]=true,[166736]=true,[166737]=true,[166741]=true,[166742]=true,
    [166816]=true,[166817]=true,[166818]=true,[166819]=true,[166892]=true,
    [166893]=true,[166959]=true,[166960]=true,[166961]=true,[166962]=true,
    [166963]=true,[166983]=true,[168166]=true,[168167]=true,[168168]=true,
    [168169]=true,[168170]=true,[168171]=true,[168172]=true,[168173]=true,
    [168174]=true,[168175]=true,[168176]=true,[168177]=true,[168178]=true,
    [168181]=true,[168184]=true,[168200]=true,[168228]=true,[168229]=true,
    [168230]=true,[168236]=true,[168237]=true,[168246]=true,[168248]=true,
    [168250]=true,[168251]=true,[168252]=true,[168253]=true,[168254]=true,
    [168255]=true,[168256]=true,[168257]=true,[168258]=true,[168259]=true,
    [168260]=true,[168261]=true,[168262]=true,[168263]=true,[168264]=true,
    [168269]=true,[168271]=true,[168591]=true,[168600]=true,[168603]=true,
    [168604]=true,[168605]=true,[168606]=true,[169406]=true,[169420]=true,
    [176859]=true,[176860]=true,[176862]=true,[176863]=true,[176864]=true,
    [176865]=true,[176866]=true,[176867]=true,[176868]=true,[176869]=true,
    [177298]=true,[177300]=true,
}
local defaults = {enabled=true, phaseOneEnabled=true, splitEnabled=true,
    diagnosticArmed=false, diagnosticLines={}, diagnosticPull=0,
    splitDiagnosticLines={},splitDiagnosticPull=0,
    callout={scale=1.0,offsetX=0,offsetY=-165}}
BT.state = {
    Lylanar={}, Turlassil={},
    lockedBoss=nil, calloutUntil=0, recording=false, recordStart=0, recordStop=0,
    reportOpen=false, reportScene=nil, reportMode="corner", previewActive=false, previewScene=nil,
    splitDiagnosticActive=false,splitDiagnosticStart=0,splitBuffer={},splitPostUntil=0,splitLastSnapshot=0,
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
    self.hud.boss:SetText("LYLANAR"); self.hud.main:SetText("DOME SOON"); self.hud.main:SetColor(1,.72,.08,1); self.hud.sub:SetText("GET READY • PREVIEW"); self.hud.root:SetHidden(false)
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
    local listControl=w:CreateControlFromVirtual("$(parent)List",root,"ZO_VerticalParametricScrollListTemplate")
    listControl:SetAnchor(TOPLEFT,status,BOTTOMLEFT,0,18); listControl:SetDimensions(1100,570)
    local list=ZO_GamepadVerticalParametricScrollList:New(listControl)
    list:AddDataTemplate("ZO_GamepadMenuEntryTemplate",ZO_SharedGamepadEntry_OnSetup,ZO_GamepadMenuEntryTemplateParametricListFunction)
    list:SetAlignToScreenCenter(false)
    local foot=w:CreateControl("$(parent)Footer",root,CT_LABEL); foot:SetAnchor(BOTTOMLEFT,root,BOTTOMLEFT,36,-22); foot:SetFont("ZoFontGamepad22"); foot:SetText("Right stick / D-pad: Scroll  •  |cFFD700Circle: Close|r"); foot:SetDimensions(1100,32)
    self.report={root=root,title=title,status=status,list=list}
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
    local t=self.sv.diagnosticLines
    if #t>=300 then return end
    t[#t+1]=text
end

function BT:StartRecording(abilityId,sourceName)
    local boss=abilityId==ID.L_MULTI and "Lylanar" or "Turlassil"
    if self.sv.phaseOneEnabled then self:Callout("CORNER SEQUENCE",boss,{1,.72,.08,1},2600); self.hud.sub:SetText("WATCH THROWS 1 - 4") end
    if not self.sv.diagnosticArmed or not self.sv.phaseOneEnabled then return end
    local now=GetGameTimeMilliseconds(); self.state.recording=true; self.state.recordStart=now; self.state.recordStop=now+30000
    self.sv.diagnosticPull=(self.sv.diagnosticPull or 0)+1; self.sv.diagnosticLines={}
    self:AddLine(string.format("Better Twins %s | Capture %d",self.version,self.sv.diagnosticPull))
    self:AddLine(string.format("START +0.000 %s MultiLoc id=%d source=%s",boss,abilityId,Short(sourceName)))
    self:AddLine("TYPE  TIME     ID      ABILITY          RESULT   VALUE  SOURCE-ID  TARGET-ID")
    EVENT_MANAGER:RegisterForEvent(self.name.."Diagnostic",EVENT_COMBAT_EVENT,function(...) self:DiagnosticEvent(...) end)
end

function BT:StopRecording(reason)
    if not self.state.recording then return end
    self.state.recording=false; EVENT_MANAGER:UnregisterForEvent(self.name.."Diagnostic",EVENT_COMBAT_EVENT)
    self:AddLine(string.format("END +%.3f %s",(GetGameTimeMilliseconds()-self.state.recordStart)/1000,reason or "complete"))
end

function BT:AddSplitLine(text)
    local t=self.sv.splitDiagnosticLines
    if #t>=600 then return end
    t[#t+1]=text
end

function BT:StartSplitDiagnostic()
    if self.state.splitDiagnosticActive or not self.sv.diagnosticArmed or not self.state.lockedBoss or not self:BothTwinsPresent() then return end
    local now=GetGameTimeMilliseconds()
    self.state.splitDiagnosticActive=true
    self.state.splitDiagnosticStart=now
    self.state.splitBuffer={}
    self.state.splitPostUntil=0
    self.state.splitLastSnapshot=0
    self.sv.splitDiagnosticPull=(self.sv.splitDiagnosticPull or 0)+1
    self.sv.splitDiagnosticLines={}
    self:AddSplitLine(string.format("Better Twins %s | Split Capture %d",self.version,self.sv.splitDiagnosticPull))
    self:AddSplitLine(string.format("START +0.000 hard target=%s",self.state.lockedBoss))
    self:AddSplitLine("TYPE  TIME     ID      ABILITY          RESULT   VALUE  SOURCE-ID  TARGET-ID")
    EVENT_MANAGER:RegisterForEvent(self.name.."SplitDiagnostic",EVENT_COMBAT_EVENT,function(...) self:SplitDiagnosticEvent(...) end)
end

function BT:StopSplitDiagnostic(reason)
    if not self.state.splitDiagnosticActive then return end
    self.state.splitDiagnosticActive=false
    EVENT_MANAGER:UnregisterForEvent(self.name.."SplitDiagnostic",EVENT_COMBAT_EVENT)
    self:AddSplitLine(string.format("END +%.3f %s",(GetGameTimeMilliseconds()-self.state.splitDiagnosticStart)/1000,reason or "complete"))
end

function BT:SplitDiagnosticEvent(_,result,_,abilityName,_,_,sourceName,_,_,_,hitValue,_,_,_,sourceId,targetId,abilityId)
    if not self.state.splitDiagnosticActive then return end
    local twinSource=BossName(sourceName)~=nil
    if not splitTimingCandidates[abilityId] and not twinSource then return end
    local now=GetGameTimeMilliseconds()
    local elapsed=(now-self.state.splitDiagnosticStart)/1000
    local line=string.format("+%06.2f  %d  %-15s %-8s v%-6d S%s T%s",
        elapsed,abilityId,Short(abilityName),resultNames[result] or tostring(result),hitValue or 0,tostring(sourceId or 0),tostring(targetId or 0))
    local buffer=self.state.splitBuffer
    buffer[#buffer+1]={time=now,text=line}
    while buffer[1] and now-buffer[1].time>12000 do table.remove(buffer,1) end
    if now<=self.state.splitPostUntil then self:AddSplitLine("POST "..line) end
    local actual=(abilityId==ID.CINDER or abilityId==ID.NUMBING) and (result==ACTION_RESULT_EFFECT_GAINED or result==ACTION_RESULT_BEGIN)
    if actual and now-self.state.splitLastSnapshot>750 then
        self.state.splitLastSnapshot=now
        self.state.splitPostUntil=now+2000
        self:AddSplitLine(string.format("--- CHANNEL %s id=%d hard target=%s ---",bossFor[abilityId] or "Twin",abilityId,self.state.lockedBoss or "none"))
        for i=1,#buffer do self:AddSplitLine("PRE  "..buffer[i].text) end
    end
end

function BT:DiagnosticEvent(_,result,_,abilityName,_,_,sourceName,_,targetName,_,hitValue,_,_,_,sourceId,targetId,abilityId)
    if not self.state.recording then return end
    local elapsed=(GetGameTimeMilliseconds()-self.state.recordStart)/1000
    local candidate=diagnosticCandidates[abilityId]==true
    local earlyTwinEvent=elapsed<=15 and BossName(sourceName)~=nil
    if not candidate and not earlyTwinEvent then return end
    self:AddLine(string.format("%s +%05.2f  %d  %-15s %-8s v%-6d S%s T%s",
        candidate and "CAND" or "TWIN",elapsed,abilityId,Short(abilityName),resultNames[result] or tostring(result),hitValue or 0,tostring(sourceId or 0),tostring(targetId or 0)))
end

function BT:Interrupt(abilityId,sourceName)
    if not self.sv.splitEnabled then return end
    local boss=bossFor[abilityId] or BossName(sourceName); if not boss then return end
    local now=GetGameTimeMilliseconds(); local s=self.state[boss]
    if s.lastSignal and now-s.lastSignal<750 then return end
    s.lastSignal=now
    s.last=now
    -- Queueing can delay the next channel by several seconds. Until the diagnostic
    -- identifies a real precursor, this is only a readiness threshold, not a timer.
    s.readyAt=now+18000
    if self.state.lockedBoss==boss then self:Callout("BASH NOW",boss,{1,.2,.1,1},1800); self.hud.sub:SetText(boss=="Lylanar" and "ICE DOME" or "FIRE DOME") end
end

function BT:TrackedEvent(_,result,_,_,_,_,sourceName,_,_,_,_,_,_,_,_,_,abilityId)
    if not self.sv.enabled then return end
    if (abilityId==ID.CINDER or abilityId==ID.NUMBING) and (result==ACTION_RESULT_EFFECT_GAINED or result==ACTION_RESULT_BEGIN) then self:Interrupt(abilityId,sourceName)
    elseif (abilityId==ID.L_MULTI or abilityId==ID.T_MULTI) and (result==ACTION_RESULT_EFFECT_GAINED or result==ACTION_RESULT_BEGIN) and not self.state.recording then self:StartRecording(abilityId,sourceName) end
end

function BT:RefreshReport()
    local split=self.state.reportMode=="split"
    local t=split and (self.sv.splitDiagnosticLines or {}) or (self.sv.diagnosticLines or {})
    self.report.title:SetText(split and "BETTER TWINS — SPLIT TIMING DIAGNOSTIC" or "BETTER TWINS — CORNER DIAGNOSTIC")
    local active=split and self.state.splitDiagnosticActive or (not split and self.state.recording)
    self.report.status:SetText(#t==0 and (split and "No split-phase timing capture recorded." or "No corner-phase capture recorded.") or string.format("%s • %d recorded lines",active and "RECORDING" or "CAPTURE COMPLETE",#t))
    local list=self.report.list
    list:Clear()
    if #t==0 then
        local emptyText=split and "Arm Diagnostic Recorder before the fight and hard-target your assigned Twin during split phase." or "Arm Diagnostic Recorder before the fight. Corner recording begins automatically when MultiLoc starts."
        local entry=ZO_GamepadEntryData:New(emptyText)
        entry:SetFontScaleOnSelection(false)
        list:AddEntry("ZO_GamepadMenuEntryTemplate",entry)
    else
        for i=1,#t do
            local entry=ZO_GamepadEntryData:New(t[i])
            entry:SetFontScaleOnSelection(false)
            list:AddEntry("ZO_GamepadMenuEntryTemplate",entry)
        end
    end
    list:Commit(true)
    list:SetSelectedIndex(1,true,true)
end

function BT:OpenReport(mode)
    if self.state.reportOpen then return end
    self.state.reportMode=mode=="split" and "split" or "corner"
    self:RefreshReport(); self.state.reportOpen=true; self.hud.root:SetHidden(true); self.report.root:SetHidden(false); self.report.list:Activate(); self.report.list:SetDirectionalInputEnabled(true); KEYBIND_STRIP:AddKeybindButtonGroup(self.reportKeys)
    local s=SCENE_MANAGER and SCENE_MANAGER:GetCurrentScene(); self.state.reportScene=s; if s then s:RegisterCallback("StateChange",self.sceneCallback) end
end

function BT:CloseReport()
    if not self.state.reportOpen then return end
    self.state.reportOpen=false; self.report.list:SetDirectionalInputEnabled(false); self.report.list:Deactivate(); self.report.root:SetHidden(true); KEYBIND_STRIP:RemoveKeybindButtonGroup(self.reportKeys)
    local s=self.state.reportScene; if s then s:UnregisterCallback("StateChange",self.sceneCallback) end; self.state.reportScene=nil
end

function BT:Update()
    self:CaptureHardTarget()
    if self.state.recording and GetGameTimeMilliseconds()>=self.state.recordStop then self:StopRecording("30-second corner window complete") end
    if self.sv.enabled and self.sv.diagnosticArmed and self.state.lockedBoss and self:BothTwinsPresent() then
        self:StartSplitDiagnostic()
    elseif self.state.splitDiagnosticActive and (not self.sv.enabled or not self.sv.diagnosticArmed) then
        self:StopSplitDiagnostic("recorder stopped")
    end
    -- The settings preview owns the HUD for its full five-second lifetime.
    if self.state.previewActive then return end
    if not self.sv.enabled or not self.sv.splitEnabled or not self:HudScene() then self.hud.root:SetHidden(true); return end
    local now=GetGameTimeMilliseconds(); if now<self.state.calloutUntil then return end
    local boss=self.state.lockedBoss; local s=boss and self.state[boss]
    if not s or not s.readyAt or now<s.readyAt then self.hud.root:SetHidden(true); return end
    self.hud.boss:SetText(string.upper(boss))
    self.hud.main:SetText("DOME SOON")
    self.hud.main:SetColor(1,.72,.08,1)
    self.hud.sub:SetText((boss=="Lylanar" and "ICE DOME" or "FIRE DOME").." • GET READY")
    self.hud.root:SetHidden(false)
end

function BT:ResetFight()
    self:StopRecording("combat ended")
    self:StopSplitDiagnostic("combat ended")
    for _,b in ipairs({"Lylanar","Turlassil"}) do local s=self.state[b]; s.readyAt=nil;s.last=nil;s.lastSignal=nil end
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
