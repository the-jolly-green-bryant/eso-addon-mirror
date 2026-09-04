BetterTwins = BetterTwins or {}
local BT = BetterTwins
BT.name, BT.displayName, BT.version = "BetterTwins", "Better Twins", "0.0.01-dev5"

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
local readinessDelay = { Lylanar=24000, Turlassil=26000 }
local teleportPositions = {
    {67459,36099,87622},{67472,36104,85190},{67525,36107,82685},{70195,36109,82646},
    {72222,36107,82731},{72327,36108,85255},{72030,36107,87354},{70016,36104,87631},
}
local defaults = {enabled=true, phaseOneEnabled=true, splitEnabled=true,
    diagnosticArmed=false, diagnosticLines={}, diagnosticPull=0,
    callout={scale=1.0,offsetX=0,offsetY=-165}}
BT.state = {
    Lylanar={}, Turlassil={},
    lockedBoss=nil, calloutUntil=0, recording=false, recordStart=0, recordStop=0,
    reportOpen=false, reportScene=nil, previewActive=false, previewScene=nil,
    throwCount=0,lastThrowAt=0,worldMarkers={},worldMarkersUntil=0,
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

-- Native SPACE_WORLD controls used only by the focused corner diagnostic.
-- Letters deliberately avoid implying team assignments before throw-to-position
-- mapping has been verified on console.
function BT:CreateWorldMarkers()
    if not SPACE_WORLD or not GuiRender3DPositionToWorldPosition or not Set3DRenderSpaceToCurrentCamera then
        self.worldMarkersAvailable=false
        return
    end
    local w=WINDOW_MANAGER
    local layer=w:CreateTopLevelWindow("BetterTwinsWorldMarkers")
    layer:SetAnchorFill(GuiRoot); layer:SetDrawTier(DT_LOW); layer:SetHidden(false)
    local camera=w:CreateControl("BetterTwinsWorldCamera",layer,CT_CONTROL)
    camera:Create3DRenderSpace()
    self.worldCamera=camera
    self.worldMarkersAvailable=true
    local originX,_,originZ=GuiRender3DPositionToWorldPosition(0,0,0)
    for i,pos in ipairs(teleportPositions) do
        local control=w:CreateControl("BetterTwinsWorldMarker"..i,layer,CT_CONTROL)
        control:SetDimensions(180,180); control:SetSpace(SPACE_WORLD)
        control:SetTransformNormalizedOriginPoint(.5,.5); control:SetTransformScale(.01)
        control:SetAnchor(CENTER,GuiRoot,CENTER)
        control:SetTransformOffset((pos[1]-originX)/100,(pos[2]+260)/100,(pos[3]-originZ)/100)
        local bg=w:CreateControl("$(parent)BG",control,CT_BACKDROP)
        bg:SetAnchor(CENTER,control,CENTER); bg:SetDimensions(118,118)
        -- Backdrop edge dimensions must both be powers of two on console.
        bg:SetCenterColor(.02,.03,.05,.82); bg:SetEdgeColor(1,.72,.08,1); bg:SetEdgeTexture("EsoUI/Art/Tooltips/Gamepad/gp_toolTip_edge.dds",8,2)
        local label=w:CreateControl("$(parent)Label",control,CT_LABEL)
        label:SetAnchor(CENTER,control,CENTER,0,4); label:SetDimensions(150,150)
        label:SetFont("ZoFontGamepadBold54"); label:SetHorizontalAlignment(TEXT_ALIGN_CENTER); label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        label:SetColor(1,.85,.18,1); label:SetText(string.char(64+i))
        control:SetHidden(true); self.state.worldMarkers[i]=control
    end
end

function BT:ShowWorldMarkers(duration)
    if not self.worldMarkersAvailable then return end
    self.state.worldMarkersUntil=GetGameTimeMilliseconds()+(duration or 25000)
    for _,control in ipairs(self.state.worldMarkers) do control:SetHidden(false) end
end

function BT:HideWorldMarkers()
    self.state.worldMarkersUntil=0
    for _,control in ipairs(self.state.worldMarkers) do control:SetHidden(true) end
end

function BT:UpdateWorldMarkers()
    if not self.worldMarkersAvailable or self.state.worldMarkersUntil==0 then return end
    if GetGameTimeMilliseconds()>=self.state.worldMarkersUntil then self:HideWorldMarkers(); return end
    Set3DRenderSpaceToCurrentCamera(self.worldCamera:GetName())
    local fX,fY,fZ=self.worldCamera:Get3DRenderSpaceForward()
    local pitch=zo_atan2(fY,zo_sqrt(fX*fX+fZ*fZ))
    local yaw=zo_atan2(fX,fZ)-math.pi
    for _,control in ipairs(self.state.worldMarkers) do control:SetTransformRotation(pitch,yaw,0) end
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
    self.hud.boss:SetText("LYLANAR"); self.hud.main:SetText("DOME READY"); self.hud.main:SetColor(1,.72,.08,1); self.hud.sub:SetText("ICE DOME • PREVIEW"); self.hud.root:SetHidden(false)
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
    if self.state.lockedBoss or not self.sv.enabled or not self.sv.splitEnabled or not IsUnitInCombat("player") or not self:BothTwinsPresent() then return end
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

function BT:StartRecording(abilityId,sourceName,targetId)
    local boss=abilityId==ID.L_MULTI and "Lylanar" or "Turlassil"
    if self.sv.phaseOneEnabled then self:Callout("CORNER SEQUENCE",boss,{1,.72,.08,1},2600); self.hud.sub:SetText("WATCH THROWS 1 - 4") end
    if not self.sv.diagnosticArmed then return end
    local now=GetGameTimeMilliseconds(); self.state.recording=true; self.state.recordStart=now; self.state.recordStop=now+30000
    self.state.throwCount=0; self.state.lastThrowAt=0; self:ShowWorldMarkers(25000)
    self.sv.diagnosticPull=(self.sv.diagnosticPull or 0)+1; self.sv.diagnosticLines={}
    self:AddLine(string.format("Better Twins %s | Capture %d",self.version,self.sv.diagnosticPull))
    self:AddLine(string.format("START +0.000 %s MultiLoc id=%d source=%s",boss,abilityId,Short(sourceName)))
    self:AddLine(self.worldMarkersAvailable and "Letters A-H are native test anchors, not team numbers." or "Native SPACE_WORLD anchors unavailable; event capture continued.")
    self:AddLine("TYPE  TIME     ID      ABILITY          RESULT   VALUE  SOURCE-ID  TARGET-ID")
    self:RecordThrow(abilityId,targetId)
    EVENT_MANAGER:RegisterForEvent(self.name.."Diagnostic",EVENT_COMBAT_EVENT,function(...) self:DiagnosticEvent(...) end)
end

function BT:StopRecording(reason)
    if not self.state.recording then return end
    self.state.recording=false; EVENT_MANAGER:UnregisterForEvent(self.name.."Diagnostic",EVENT_COMBAT_EVENT); self:HideWorldMarkers()
    self:AddLine(string.format("END +%.3f %s",(GetGameTimeMilliseconds()-self.state.recordStart)/1000,reason or "complete"))
end

function BT:UnitPositionLine(tag)
    if not DoesUnitExist(tag) then return tag.."=missing" end
    local unitId=GetUnitId and GetUnitId(tag) or 0
    if GetUnitRawWorldPosition then
        local zone,x,y,z=GetUnitRawWorldPosition(tag)
        return string.format("%s id=%s raw=%s,%s,%s,%s",tag,tostring(unitId or 0),tostring(zone or 0),tostring(x or 0),tostring(y or 0),tostring(z or 0))
    end
    local zone,x,y,z=GetUnitWorldPosition(tag)
    return string.format("%s id=%s world=%s,%s,%s,%s",tag,tostring(unitId or 0),tostring(zone or 0),tostring(x or 0),tostring(y or 0),tostring(z or 0))
end

function BT:RecordThrow(abilityId,targetId)
    local now=GetGameTimeMilliseconds()
    if now-self.state.lastThrowAt<700 or self.state.throwCount>=4 then return end
    self.state.lastThrowAt=now; self.state.throwCount=self.state.throwCount+1
    local elapsed=(now-self.state.recordStart)/1000
    local heading=GetPlayerCameraHeading and GetPlayerCameraHeading() or -1
    self:AddLine(string.format("--- THROW %d +%.3f id=%d target=%s camera=%.5f ---",self.state.throwCount,elapsed,abilityId,tostring(targetId or 0),heading))
    self:AddLine(self:UnitPositionLine("player"))
    for i=1,6 do
        local tag="boss"..i
        if DoesUnitExist(tag) and BossName(GetUnitName(tag)) then self:AddLine(self:UnitPositionLine(tag)) end
    end
    if DoesUnitExist("reticleover") then self:AddLine(self:UnitPositionLine("reticleover")) end
end

function BT:DiagnosticEvent(_,result,_,abilityName,_,_,sourceName,_,targetName,_,hitValue,_,_,_,sourceId,targetId,abilityId)
    if not self.state.recording then return end
    local elapsed=(GetGameTimeMilliseconds()-self.state.recordStart)/1000
    local candidate=diagnosticCandidates[abilityId]==true
    local earlyTwinEvent=elapsed<=15 and BossName(sourceName)~=nil
    if not candidate and not earlyTwinEvent then return end
    if (abilityId==ID.L_MULTI or abilityId==ID.T_MULTI) and (result==ACTION_RESULT_EFFECT_GAINED or result==ACTION_RESULT_BEGIN) then self:RecordThrow(abilityId,targetId) end
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
    s.readyAt=now+(readinessDelay[boss] or 26000)
    if self.state.lockedBoss==boss then self:Callout("BASH NOW",boss,{1,.2,.1,1},1800); self.hud.sub:SetText(boss=="Lylanar" and "ICE DOME" or "FIRE DOME") end
end

function BT:TrackedEvent(_,result,_,_,_,_,sourceName,_,_,_,_,_,_,_,_,targetId,abilityId)
    if not self.sv.enabled then return end
    if (abilityId==ID.CINDER or abilityId==ID.NUMBING) and (result==ACTION_RESULT_EFFECT_GAINED or result==ACTION_RESULT_BEGIN) then self:Interrupt(abilityId,sourceName)
    elseif (abilityId==ID.L_MULTI or abilityId==ID.T_MULTI) and (result==ACTION_RESULT_EFFECT_GAINED or result==ACTION_RESULT_BEGIN) and not self.state.recording then self:StartRecording(abilityId,sourceName,targetId) end
end

function BT:RefreshReport()
    local t=self.sv.diagnosticLines or {}
    self.report.title:SetText("BETTER TWINS — CORNER POSITION DIAGNOSTIC")
    local active=self.state.recording
    self.report.status:SetText(#t==0 and "No focused corner-position capture recorded." or string.format("%s • %d recorded lines",active and "RECORDING" or "CAPTURE COMPLETE",#t))
    local list=self.report.list
    list:Clear()
    if #t==0 then
        local emptyText="Arm Diagnostic Recorder before the fight. Recording and the A-H native test anchors begin automatically when MultiLoc starts."
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
    self:UpdateWorldMarkers()
    if self.state.recording and GetGameTimeMilliseconds()>=self.state.recordStop then self:StopRecording("30-second corner window complete") end
    -- The settings preview owns the HUD for its full five-second lifetime.
    if self.state.previewActive then return end
    if not self.sv.enabled or not self.sv.splitEnabled or not self:HudScene() then self.hud.root:SetHidden(true); return end
    local now=GetGameTimeMilliseconds(); if now<self.state.calloutUntil then return end
    local boss=self.state.lockedBoss; local s=boss and self.state[boss]
    if not s or not s.readyAt or now<s.readyAt then self.hud.root:SetHidden(true); return end
    self.hud.boss:SetText(string.upper(boss))
    self.hud.main:SetText("DOME READY")
    self.hud.main:SetColor(1,.72,.08,1)
    self.hud.sub:SetText((boss=="Lylanar" and "ICE DOME" or "FIRE DOME").." • GET READY")
    self.hud.root:SetHidden(false)
end

function BT:ResetFight()
    self:StopRecording("combat ended")
    self:HideWorldMarkers()
    for _,b in ipairs({"Lylanar","Turlassil"}) do local s=self.state[b]; s.readyAt=nil;s.last=nil;s.lastSignal=nil end
    self.state.lockedBoss=nil; self.state.calloutUntil=0; self.hud.root:SetHidden(true)
end

function BT:Initialize()
    self.sv=ZO_SavedVars:NewAccountWide("BetterTwinsSavedVariables",1,nil,defaults); self:CreateHUD(); self:CreateWorldMarkers(); self:CreateReport(); self:CreateSettingsMenu()
    self.sceneCallback=function(_,newState) if newState==SCENE_HIDING or newState==SCENE_HIDDEN then self:CloseReport() end end
    for key,id in pairs(ID) do local n=self.name.."Combat"..key; EVENT_MANAGER:RegisterForEvent(n,EVENT_COMBAT_EVENT,function(...) self:TrackedEvent(...) end); EVENT_MANAGER:AddFilterForEvent(n,EVENT_COMBAT_EVENT,REGISTER_FILTER_ABILITY_ID,id) end
    EVENT_MANAGER:RegisterForEvent(self.name.."Target",EVENT_RETICLE_TARGET_CHANGED,function() self:CaptureHardTarget() end)
    EVENT_MANAGER:RegisterForEvent(self.name.."CombatState",EVENT_PLAYER_COMBAT_STATE,function(_,active) if not active then self:ResetFight() end end)
    SCENE_MANAGER:RegisterCallback("SceneStateChanged",function() if not self:HudScene() then self.hud.root:SetHidden(true) end end)
    EVENT_MANAGER:RegisterForUpdate(self.name.."Update",100,function() self:Update() end)
end

local function Loaded(_,name) if name~=BT.name then return end EVENT_MANAGER:UnregisterForEvent(BT.name,EVENT_ADD_ON_LOADED); BT:Initialize() end
EVENT_MANAGER:RegisterForEvent(BT.name,EVENT_ADD_ON_LOADED,Loaded)
