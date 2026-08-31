local BT=BetterTwins
BT.Settings=BT.Settings or {}

local function CalloutSaved()
    BT.sv.callout=BT.sv.callout or {scale=1.0,offsetX=0,offsetY=-165}
    return BT.sv.callout
end

local function UpdateCallout(key,value)
    CalloutSaved()[key]=value
    BT:ApplyCalloutLayout(); BT:ShowPreview()
end

local function Nudge(dx,dy)
    local saved=CalloutSaved()
    saved.offsetX=(saved.offsetX or 0)+dx
    saved.offsetY=(saved.offsetY or -165)+dy
    BT:ApplyCalloutLayout(); BT:ShowPreview()
end

function BT:CreateSettingsMenu()
    local LHAS=LibHarvensAddonSettings
    if not LHAS then return end
    local panel=LHAS:AddAddon(self.displayName,{allowRefresh=true})
    if not panel then return end

    local originalCleanUp=panel.CleanUp
    if originalCleanUp then
        panel.CleanUp=function(p,...)
            BT:HidePreview(); BT:CloseReport()
            return originalCleanUp(p,...)
        end
    end

    panel:AddSettings({
        {type=LHAS.ST_LABEL,label="|cFFD447BETTER TWINS|r\n|cFFD447A BMG Addon|r\n|cFFD447Created and maintained by @BMGXSANCHO|r\nVersion "..self.version},
        {type=LHAS.ST_SECTION,label="Encounter Features"},
        {type=LHAS.ST_CHECKBOX,label="Enable Better Twins",tooltip="Master switch for all Better Twins features.",getFunction=function() return BT.sv.enabled==true end,setFunction=function(v) BT.sv.enabled=v==true;if not v then BT:ResetFight() end end},
        {type=LHAS.ST_CHECKBOX,label="Phase 1 — Corner Assignments",tooltip="Enables the corner sequence system.",getFunction=function() return BT.sv.phaseOneEnabled==true end,setFunction=function(v) BT.sv.phaseOneEnabled=v==true end},
        {type=LHAS.ST_CHECKBOX,label="Split Phase — Dome & Bash",tooltip="Locks the first Twin hard-targeted while both bosses are present, shows a persistent dome readiness warning, and calls the confirmed bash event.",getFunction=function() return BT.sv.splitEnabled==true end,setFunction=function(v) BT.sv.splitEnabled=v==true;if not v then BT.state.lockedBoss=nil;BT.hud.root:SetHidden(true) end end},

        {type=LHAS.ST_SECTION,label="Split Callout Position and Size"},
        {type=LHAS.ST_LABEL,label="The preview appears for five seconds after each adjustment. Gameplay callouts only appear on the HUD."},
        {type=LHAS.ST_SLIDER,label="Callout Scale",min=60,max=160,step=5,unit="%",getFunction=function() return zo_round((CalloutSaved().scale or 1)*100) end,setFunction=function(v) UpdateCallout("scale",v/100) end},
        {type=LHAS.ST_SLIDER,label="Horizontal Position",min=-1000,max=1000,step=20,getFunction=function() return CalloutSaved().offsetX or 0 end,setFunction=function(v) UpdateCallout("offsetX",v) end},
        {type=LHAS.ST_SLIDER,label="Vertical Position",min=-600,max=600,step=20,getFunction=function() return CalloutSaved().offsetY or -165 end,setFunction=function(v) UpdateCallout("offsetY",v) end},
        {type=LHAS.ST_BUTTON,buttonText="Preview Dome Callout",clickHandler=function() BT:ShowPreview() end},
        {type=LHAS.ST_BUTTON,buttonText="Callout Up",clickHandler=function() Nudge(0,-20) end},
        {type=LHAS.ST_BUTTON,buttonText="Callout Down",clickHandler=function() Nudge(0,20) end},
        {type=LHAS.ST_BUTTON,buttonText="Callout Left",clickHandler=function() Nudge(-20,0) end},
        {type=LHAS.ST_BUTTON,buttonText="Callout Right",clickHandler=function() Nudge(20,0) end},
        {type=LHAS.ST_BUTTON,buttonText="Restore Callout Position and Size",clickHandler=function() BT.sv.callout={scale=1.0,offsetX=0,offsetY=-165};BT:ApplyCalloutLayout();BT:ShowPreview() end},

        {type=LHAS.ST_SECTION,label="Diagnostic Recorder"},
        {type=LHAS.ST_CHECKBOX,label="Arm Diagnostic Recorder",tooltip="Turn ON before the fight. Records the focused 30-second corner window and split-phase timing around each real Twin channel.",getFunction=function() return BT.sv.diagnosticArmed==true end,setFunction=function(v) BT.sv.diagnosticArmed=v==true;if not v then BT:StopRecording("recorder disarmed");BT:StopSplitDiagnostic("recorder disarmed") end end},
        {type=LHAS.ST_BUTTON,buttonText="Open Corner Diagnostic Report",clickHandler=function() BT:HidePreview();BT:OpenReport("corner") end},
        {type=LHAS.ST_BUTTON,buttonText="Open Split Timing Report",clickHandler=function() BT:HidePreview();BT:OpenReport("split") end},
        {type=LHAS.ST_BUTTON,buttonText="Clear Diagnostic Reports",clickHandler=function() BT.sv.diagnosticLines={};BT.sv.diagnosticPull=0;BT.sv.splitDiagnosticLines={};BT.sv.splitDiagnosticPull=0 end},
    })
end
