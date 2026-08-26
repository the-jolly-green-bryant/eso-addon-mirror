CurvedHUD = CurvedHUD or {}
local CH = CurvedHUD
CH.name, CH.version, CH.updateName = "CurvedHUD", "0.6.9-test", "CurvedHUD_Update"
CH.defaults = {enabled=true,preview=false,showDefaultResources=true,buffVerticalOffset=0,useOutOfCombatOpacity=false,outOfCombatOpacity=.45,scale=1.0,spacing=235,verticalOffset=35,resourceGap=7,barWidth=48,fillAlpha=.85,frameAlpha=.48,backgroundAlpha=.24,shieldAlpha=.68,textAlpha=.95,timerFontSize=24,resourceValueFontSize=27,resourcePercentFontSize=20,majorBuffTracked="Major Resolve",insideTimerStyle="Thin",outsideTimerStyle="Thick",majorBuffColor="Purple",balanceEnabled=true,balanceSlot="bottomLeftInside",balanceColor="Orange",aegisEnabled=true,aegisSlot="topLeftOutside",aegisColor="Pale Blue",showRaw=true,showPercent=true,showMaximum=false,debug=true,layout="Parallel",staminaInside=true}
CH.characterKeys = {majorBuffTracked=true,majorBuffColor=true,balanceEnabled=true,balanceSlot=true,balanceColor=true,aegisEnabled=true,aegisSlot=true,aegisColor=true}
CH.characterDefaults = {majorBuffTracked="Major Resolve",majorBuffColor="Purple",balanceEnabled=true,balanceSlot="bottomLeftInside",balanceColor="Orange",aegisEnabled=true,aegisSlot="topLeftOutside",aegisColor="Pale Blue",initialized=false}
CH.majorBuffChoices = {"None","Major Resolve","Major Brutality","Major Sorcery","Major Savagery","Major Prophecy","Major Expedition","Major Protection","Major Evasion","Major Berserk","Major Force","Major Courage"}
CH.colorChoices = {"Purple","Orange","Pale Blue","Blue","Green","Red","Gold","White","Cyan","Pink"}
CH.colors = {Purple={.58,.24,.92},Orange={.88,.35,.18},["Pale Blue"]={.48,.82,1},Blue={.18,.48,1},Green={.18,.82,.30},Red={.92,.18,.18},Gold={1,.72,.15},White={1,1,1},Cyan={.15,.9,.9},Pink={1,.35,.68}}
CH.trackerSlots = {
    topLeftOutside={side="left",vertical="upper",inside=false}, topLeftInside={side="left",vertical="upper",inside=true},
    bottomLeftOutside={side="left",vertical="lower",inside=false}, bottomLeftInside={side="left",vertical="lower",inside=true},
    topRightInside={side="right",vertical="upper",inside=true}, topRightOutside={side="right",vertical="upper",inside=false},
    bottomRightInside={side="right",vertical="lower",inside=true}, bottomRightOutside={side="right",vertical="lower",inside=false},
}
CH.trackerSlotNames = {"Top Left - Outside","Top Left - Inside","Bottom Left - Outside","Bottom Left - Inside","Top Right - Inside","Top Right - Outside","Bottom Right - Inside","Bottom Right - Outside"}
CH.trackerSlotValues = {"topLeftOutside","topLeftInside","bottomLeftOutside","bottomLeftInside","topRightInside","topRightOutside","bottomRightInside","bottomRightOutside"}
function CH:NormalizeTrackerSlot(value,fallback)
    if self.trackerSlots[value] then return value end
    for index,name in ipairs(self.trackerSlotNames) do
        if value==name then return self.trackerSlotValues[index] end
    end
    return fallback
end
-- These IDs cover ESO's standardized base effects where confirmed. Name matching
-- remains the fallback because some sources expose their own ability ID while
-- retaining the localized standardized buff name.
local MAJOR_BUFF_IDS = {["Major Resolve"]=61694,["Major Brutality"]=61665,["Major Sorcery"]=61687,["Major Savagery"]=64568,["Major Prophecy"]=64570}
local WM = WINDOW_MANAGER
local HEALTH_POWER=_G["COMBAT_MECHANIC_FLAGS_HEALTH"] or POWERTYPE_HEALTH
local STAMINA_POWER=_G["COMBAT_MECHANIC_FLAGS_STAMINA"] or POWERTYPE_STAMINA
local MAGICKA_POWER=_G["COMBAT_MECHANIC_FLAGS_MAGICKA"] or POWERTYPE_MAGICKA
local MOUNT_POWER=_G["COMBAT_MECHANIC_FLAGS_MOUNT_STAMINA"] or POWERTYPE_MOUNT_STAMINA
local function clamp(v,lo,hi) return math.max(lo,math.min(hi,v or 0)) end

function CH:Log(message, always)
    local line=string.format("|c66CCFF[CurvedHUD]|r %s",tostring(message))
    if always or (self.sv and self.sv.debug) then if d then d(line) end end
end
function CH:Guard(label,fn)
    local ok,err=pcall(fn)
    if not ok then self:Log("ERROR in "..label..": "..tostring(err),true) end
    return ok
end
local function texture(parent,suffix,level,path,r,g,b,a)
    local c=WM:CreateControl(parent:GetName()..suffix,parent,CT_TEXTURE)
    c:SetDrawLayer(DL_BACKGROUND); c:SetDrawLevel(level); c:SetTexture(path); c:SetColor(r,g,b,a)
    return c
end
local function label(parent,suffix,font)
    local c=WM:CreateControl(parent:GetName()..suffix,parent,CT_LABEL)
    c:SetFont(font or "ZoFontGamepad27"); c:SetHorizontalAlignment(TEXT_ALIGN_CENTER); c:SetVerticalAlignment(TEXT_ALIGN_CENTER); c:SetColor(1,1,1,1)
    return c
end

function CH:CreateBar(key,side,color)
    local b=WM:CreateControl("CurvedHUD_"..key,self.root,CT_CONTROL)
    b.key,b.side,b.color=key,side,color; b:SetDimensions(96,512)
    b.bg=texture(b,"_Background",0,"CurvedHUD/textures/arc_full.dds",.04,.04,.04,self.sv.backgroundAlpha); b.bg:SetAnchorFill(b)
    -- Resource-specific textures provide an ESO-style dark-to-bright gradient.
    -- White tint preserves the authored gradient while SetAlpha remains customizable.
    b.fill=texture(b,"_Fill",2,"CurvedHUD/textures/arc_"..key.."_gradient.dds",1,1,1,self.sv.fillAlpha); b.fill:SetAnchor(BOTTOMLEFT,b,BOTTOMLEFT)
    -- The holder uses the identical geometry as the fill so scaling cannot separate them.
    b.frame=texture(b,"_Frame",1,"CurvedHUD/textures/arc_full.dds",.38,.38,.38,self.sv.frameAlpha); b.frame:SetAnchorFill(b)
    -- Reversed after the first console render showed the arcs facing the wrong way.
    b.u1,b.u2=side=="left" and 1 or 0,side=="left" and 0 or 1
    b.bg:SetTextureCoords(b.u1,b.u2,0,1); b.frame:SetTextureCoords(b.u1,b.u2,0,1)
    b.rawLabel=label(b,"_RawLabel"); b.rawLabel:SetDimensions(190,34)
    b.percentLabel=label(b,"_PercentLabel","ZoFontGamepad20"); b.percentLabel:SetDimensions(110,28)
    self.bars[key]=b
end
function CH:SetTexturePercent(t,owner,pct)
    pct=clamp(pct,0,1)
    local w,h=owner:GetDimensions(); local shown=math.max(1,math.floor(h*pct))
    t:ClearAnchors(); t:SetDimensions(w,shown)
    if owner.segment=="trackerLower" then
        t:SetAnchor(BOTTOMLEFT,owner,BOTTOMLEFT); t:SetTextureCoords(owner.u1,owner.u2,1-(.42*pct),1)
    elseif owner.segment=="upper" then
        -- Keep the outside/top end filled; depletion advances toward it from the midpoint.
        t:SetAnchor(TOPLEFT,owner,TOPLEFT); t:SetTextureCoords(owner.u1,owner.u2,.5,.5+(.5*pct))
    elseif owner.segment=="lower" then
        -- Keep the outside/bottom end filled; depletion advances toward it from the midpoint.
        t:SetAnchor(BOTTOMLEFT,owner,BOTTOMLEFT); t:SetTextureCoords(owner.u1,owner.u2,.5-(.5*pct),.5)
    else
        t:SetAnchor(BOTTOMLEFT,owner,BOTTOMLEFT); t:SetTextureCoords(owner.u1,owner.u2,1-pct,1)
    end
    t:SetHidden(pct<=0)
end

function CH:SetBarSegment(b,segment)
    b.segment=segment
    if segment=="upper" then
        b.bg:SetTextureCoords(b.u1,b.u2,.5,1); b.frame:SetTextureCoords(b.u1,b.u2,.5,1)
    elseif segment=="lower" then
        b.bg:SetTextureCoords(b.u1,b.u2,0,.5); b.frame:SetTextureCoords(b.u1,b.u2,0,.5)
    else
        b.bg:SetTextureCoords(b.u1,b.u2,0,1); b.frame:SetTextureCoords(b.u1,b.u2,0,1)
    end
end
function CH:SetBarValue(b,current,maximum)
    maximum=math.max(1,maximum or 1); current=clamp(current or 0,0,maximum)
    local pct=current/maximum; self:SetTexturePercent(b.fill,b,pct)
    local raw=self.sv.showRaw and ZO_CommaDelimitNumber(current) or ""
    if self.sv.showMaximum then raw=raw..(raw~="" and " / " or "")..ZO_CommaDelimitNumber(maximum) end
    b.rawLabel:SetText(raw); b.rawLabel:SetHidden(raw=="")
    b.percentLabel:SetText(self.sv.showPercent and string.format("%d%%",math.floor(pct*100+.5)) or ""); b.percentLabel:SetHidden(not self.sv.showPercent)
end
function CH:CreateShield()
    local h=self.bars.health
    h.shield=texture(h,"_Shield",3,"CurvedHUD/textures/arc_full.dds",.72,.76,.82,self.sv.shieldAlpha); h.shield:SetAnchor(BOTTOMLEFT,h,BOTTOMLEFT)
    h.overcap=texture(h,"_Overcap",5,"CurvedHUD/textures/arc_frame.dds",1,1,1,.9); h.overcap:SetAnchorFill(h); h.overcap:SetTextureCoords(h.u1,h.u2,0,1); h.overcap:SetHidden(true)
end
function CH:CreateMountBar()
    local b=WM:CreateControl("CurvedHUD_mount",self.root,CT_CONTROL); b:SetDimensions(24,512)
    b.key,b.side,b.segment="mount","right","full"; b.u1,b.u2=0,1
    b.bg=texture(b,"_Background",0,"CurvedHUD/textures/mount_stacked_outer.dds",.04,.04,.04,self.sv.backgroundAlpha); b.bg:SetAnchorFill(b)
    b.frame=texture(b,"_Frame",1,"CurvedHUD/textures/mount_stacked_outer_frame.dds",.38,.38,.38,self.sv.frameAlpha); b.frame:SetAnchorFill(b)
    b.fill=texture(b,"_Fill",2,"CurvedHUD/textures/mount_stacked_outer.dds",.42,.82,.34,self.sv.fillAlpha); b.fill:SetAnchor(BOTTOMLEFT,b,BOTTOMLEFT)
    b.bg:SetTextureCoords(b.u1,b.u2,0,1); b.frame:SetTextureCoords(b.u1,b.u2,0,1)
    b:SetHidden(true); self.mountBar=b
end
function CH:CreateTracker(key,slot,colorSetting,specialTexture)
    local t=WM:CreateControl("CurvedHUD_"..key,self.root,CT_CONTROL); t:SetDimensions(38,180); t.segment="full"
    t.key,t.slot,t.colorSetting,t.specialTexture=key,slot,colorSetting,specialTexture
    local info=self.trackerSlots[slot]; t.u1,t.u2=info.side=="left" and 1 or 0,info.side=="left" and 0 or 1
    local textureName=specialTexture=="balance" and "balance_lower" or "tracker_"..info.vertical
    t.frame=texture(t,"_Frame",1,"CurvedHUD/textures/"..textureName.."_frame.dds",.35,.35,.35,.7); t.frame:SetAnchorFill(t); t.frame:SetTextureCoords(t.u1,t.u2,0,1)
    t.fill=texture(t,"_Fill",2,"CurvedHUD/textures/"..textureName..".dds",1,1,1,.9); t.fill:SetAnchor(BOTTOMLEFT,t,BOTTOMLEFT)
    if key=="balance" then
        -- Balance intentionally nests over Health, so its curve must render above
        -- the Health fill rather than disappearing behind the sibling control.
        t.frame:SetDrawLayer(DL_CONTROLS); t.fill:SetDrawLayer(DL_CONTROLS)
    end
    t.icon=texture(t,"_Icon",3,"/esoui/art/icons/icon_missing.dds",1,1,1,1); t.icon:SetDimensions(38,38); t.icon:SetAnchor(TOP,t,BOTTOM,0,4)
    t.stackLabel=label(t.icon,"_StackLabel","ZoFontGamepadBold27"); t.stackLabel:SetAnchor(CENTER,t.icon,CENTER); t.stackLabel:SetDimensions(38,38); t.stackLabel:SetDrawLayer(DL_OVERLAY); t.stackLabel:SetHidden(true)
    t.timer=label(t,"_Timer","ZoFontGamepad20"); t.timer:SetDimensions(70,30); t.timer:SetAnchor(BOTTOM,t,TOP,0,-5)
    t.active,t.beginTime,t.endTime,t.duration=false,0,0,0; t:SetHidden(true); self.trackers[key]=t
end

function CH:ApplyTrackerAppearance(t)
    local info=self.trackerSlots[t.slot]; local style=info.inside and self.sv.insideTimerStyle or self.sv.outsideTimerStyle
    local base
    if t.specialTexture=="balance" and t.slot=="bottomLeftInside" and style=="Thin" then base="balance_lower"
    else base="tracker_"..info.vertical.."_"..(info.inside and "inside" or "outside").."_"..string.lower(style) end
    t.frame:SetTexture("CurvedHUD/textures/"..base.."_frame.dds"); t.fill:SetTexture("CurvedHUD/textures/"..base..".dds")
    t.u1,t.u2=info.side=="left" and 1 or 0,info.side=="left" and 0 or 1
    local color=self.colors[self.sv[t.colorSetting]] or self.colors.White
    t.fill:SetColor(color[1],color[2],color[3],self.sv.fillAlpha)
end

function CH:SyncBarLayers(b)
    local w,h=b:GetDimensions()
    for _,layer in ipairs({b.bg,b.frame,b.overcap}) do
        if layer then layer:ClearAnchors(); layer:SetAnchor(TOPLEFT,b,TOPLEFT); layer:SetDimensions(w,h) end
    end
end
function CH:SyncTrackerLayers(t)
    local w,h=t:GetDimensions()
    t.frame:ClearAnchors(); t.frame:SetAnchor(TOPLEFT,t,TOPLEFT); t.frame:SetDimensions(w,h); t.frame:SetTextureCoords(t.u1,t.u2,0,1)
end
function CH:SetMountTexture(kind)
    local b=self.mountBar; if not b then return end
    if b.textureKind==kind then return end
    b.textureKind=kind
    b.bg:SetTexture("CurvedHUD/textures/mount_"..kind..".dds")
    b.fill:SetTexture("CurvedHUD/textures/mount_"..kind..".dds")
    b.frame:SetTexture("CurvedHUD/textures/mount_"..kind.."_frame.dds")
end
function CH:SetResourceTexture(b,kind)
    if not b or b.key=="health" or b.textureKind==kind then return end
    b.textureKind=kind
    if kind=="standard" then
        b.bg:SetTexture("CurvedHUD/textures/arc_full.dds")
        b.frame:SetTexture("CurvedHUD/textures/arc_full.dds")
        b.fill:SetTexture("CurvedHUD/textures/arc_"..b.key.."_gradient.dds")
    else
        b.bg:SetTexture("CurvedHUD/textures/arc_resource_"..kind..".dds")
        b.frame:SetTexture("CurvedHUD/textures/arc_resource_"..kind..".dds")
        b.fill:SetTexture("CurvedHUD/textures/arc_"..b.key.."_"..kind.."_gradient.dds")
    end
end

function CH:ApplyTrackerSlot(t,h,inner,outer,width,scale)
    local info=self.trackerSlots[t.slot]; if not info then return end
    local style=info.inside and self.sv.insideTimerStyle or self.sv.outsideTimerStyle
    local legacyBalance=t.key=="balance" and t.slot=="bottomLeftInside"
    local legacyAegis=t.key=="aegis" and t.slot=="topLeftOutside"
    local trackerWidth
    if info.inside then trackerWidth=style=="Thick" and 52 or 38
    elseif style=="Thin" then trackerWidth=52
    else trackerWidth=42 end
    local trackerHeight=info.inside and 145 or 180
    t:SetDimensions(trackerWidth*scale,trackerHeight*scale); t:ClearAnchors()

    local innerNudge=style=="Thick" and 5 or 0
    -- Counter-shift the wider outer-Thin control so its midpoint remains
    -- stable while the far endpoint gains the missing horizontal sweep.
    local outerNudge=style=="Thick" and 5 or 22
    if t.key=="resolve" then t:SetAnchor(BOTTOMRIGHT,h,BOTTOMLEFT,(40+outerNudge)*scale,-42*scale)
    elseif legacyBalance then t:SetAnchor(BOTTOMLEFT,h,BOTTOMRIGHT,(-46+innerNudge)*scale,-62*scale)
    elseif legacyAegis then t:SetAnchor(TOPRIGHT,h,TOPLEFT,(40+outerNudge)*scale,42*scale)
    elseif info.side=="left" then
        local x=info.inside and (-46+innerNudge) or (40+outerNudge)
        local y=info.inside and 62 or 42
        if info.vertical=="upper" then t:SetAnchor(info.inside and TOPLEFT or TOPRIGHT,h,info.inside and TOPRIGHT or TOPLEFT,x*scale,y*scale)
        else t:SetAnchor(info.inside and BOTTOMLEFT or BOTTOMRIGHT,h,info.inside and BOTTOMRIGHT or BOTTOMLEFT,x*scale,-y*scale) end
    else
        -- Parallel uses radial inner/outer resource references. In Stacked,
        -- ESO's anchored controls render `outer` on the visual upper half and
        -- `inner` on the visual lower half, so map by the rendered quadrant;
        -- otherwise the named upper/lower slots appear exchanged.
        local ref
        if self.sv.layout=="Stacked" then ref=info.vertical=="upper" and outer or inner
        else ref=info.inside and inner or outer end
        local lowerParallelNudge=(self.sv.layout=="Parallel" and info.vertical=="lower") and 5 or 0
        local rightOuterNudge=style=="Thick" and 10 or 22
        local x=info.inside and (4-innerNudge+lowerParallelNudge) or (-4-rightOuterNudge-lowerParallelNudge)
        if info.vertical=="upper" then t:SetAnchor(info.inside and TOPRIGHT or TOPLEFT,ref,info.inside and TOPLEFT or TOPRIGHT,x*scale,42*scale)
        else t:SetAnchor(info.inside and BOTTOMRIGHT or BOTTOMLEFT,ref,info.inside and BOTTOMLEFT or BOTTOMRIGHT,x*scale,-42*scale) end
    end

    self:ApplyTrackerAppearance(t); self:SyncTrackerLayers(t)
    t.timer:SetScale(scale); t.icon:SetScale(scale)
    -- Icons move radially away from their timer endpoint: toward screen center
    -- for inside slots and away from center for outside slots.
    local iconX
    if info.vertical=="upper" then
        if info.side=="left" then iconX=info.inside and 40 or -58
        else iconX=info.inside and -40 or 58 end
    elseif info.side=="left" then iconX=info.inside and 48 or -42
    else iconX=info.inside and -48 or 42 end
    t.icon:ClearAnchors(); t.icon:SetAnchor(TOP,t,BOTTOM,iconX*scale,(legacyAegis and -58 or -40)*scale)
    t.timer:SetFont(string.format("$(GAMEPAD_MEDIUM_FONT)|%d|soft-shadow-thick",math.floor(self.sv.timerFontSize or 24)))
    t.timer:ClearAnchors(); t.timer:SetAnchor(BOTTOM,t.icon,TOP,0,-2*scale)
end

function CH:ApplyLayout()
    if not self.root then return end
    local sv=self.sv; local scale=clamp(sv.scale,.5,1.5)
    -- Scale dimensions and offsets explicitly. Root transforms caused texture layers to
    -- round independently on console and visibly separate above scale 1.
    self.root:SetScale(1); self.root:ClearAnchors(); self.root:SetAnchor(CENTER,GuiRoot,CENTER,0,sv.verticalOffset)
    local h,s,m=self.bars.health,self.bars.stamina,self.bars.magicka; local width=clamp(sv.barWidth,24,80)*scale
    local balanceSlot=self:NormalizeTrackerSlot(sv.balanceSlot,"bottomLeftInside")
    local aegisSlot=self:NormalizeTrackerSlot(sv.aegisSlot,"topLeftOutside")
    if balanceSlot~=sv.balanceSlot then sv.balanceSlot=balanceSlot end
    if aegisSlot~=sv.aegisSlot then sv.aegisSlot=aegisSlot end
    self.trackers.balance.slot=balanceSlot
    self.trackers.aegis.slot=aegisSlot
    h:SetDimensions(width,512*scale); h:ClearAnchors(); h:SetAnchor(CENTER,self.root,CENTER,-sv.spacing*scale,0)
    local inner,outer=sv.staminaInside and s or m,sv.staminaInside and m or s
    if sv.layout=="Stacked" then
        inner:SetDimensions(width,252*scale); outer:SetDimensions(width,252*scale)
        inner:ClearAnchors(); inner:SetAnchor(TOP,self.root,CENTER,sv.spacing*scale,-4*scale); outer:ClearAnchors(); outer:SetAnchor(BOTTOM,self.root,CENTER,sv.spacing*scale,4*scale)
        self:SetBarSegment(inner,"upper"); self:SetBarSegment(outer,"lower")
        self:SetResourceTexture(inner,"standard"); self:SetResourceTexture(outer,"standard")
        local mount=self.mountBar; mount:SetDimensions(width,252*scale)
        mount:ClearAnchors(); mount:SetAnchor(CENTER,s,CENTER,width*.22,0)
        self:SetMountTexture("stacked_outer"); self:SetBarSegment(mount,s.segment)
    else
        local narrow=math.max(20*scale,math.floor(width*.62)); inner:SetDimensions(narrow,512*scale); outer:SetDimensions(narrow,512*scale)
        inner:ClearAnchors(); inner:SetAnchor(CENTER,self.root,CENTER,sv.spacing*scale,0); outer:ClearAnchors(); outer:SetAnchor(CENTER,inner,CENTER,math.max(4*scale,math.floor(narrow*.28))+sv.resourceGap*scale,0)
        self:SetBarSegment(inner,"full"); self:SetBarSegment(outer,"full")
        self:SetResourceTexture(inner,"inner"); self:SetResourceTexture(outer,"outer")
        local mount=self.mountBar; mount:SetDimensions(narrow,512*scale)
        mount:ClearAnchors()
        if sv.staminaInside then
            mount:SetAnchor(CENTER,s,CENTER,-11*scale,0); self:SetMountTexture("parallel_inner")
        else
            mount:SetAnchor(CENTER,s,CENTER,11*scale,0); self:SetMountTexture("parallel_outer")
        end
        self:SetBarSegment(mount,"full")
    end
    self:SyncBarLayers(h); self:SyncBarLayers(s); self:SyncBarLayers(m); self:SyncBarLayers(self.mountBar)
    -- Independent controls keep raw values aligned above percentages on every bar.
    for _,b in pairs(self.bars) do
        b.rawLabel:SetFont(string.format("$(GAMEPAD_MEDIUM_FONT)|%d|soft-shadow-thick",math.floor(sv.resourceValueFontSize or 27)))
        b.percentLabel:SetFont(string.format("$(GAMEPAD_MEDIUM_FONT)|%d|soft-shadow-thick",math.floor(sv.resourcePercentFontSize or 20)))
        b.rawLabel:SetScale(scale); b.percentLabel:SetScale(scale)
    end
    h.rawLabel:ClearAnchors(); h.rawLabel:SetAnchor(CENTER,h,CENTER,0,-20*scale)
    h.percentLabel:ClearAnchors(); h.percentLabel:SetAnchor(CENTER,h,CENTER,0,16*scale)
    s.rawLabel:ClearAnchors(); s.rawLabel:SetAnchor(CENTER,s,CENTER,8*scale,-54*scale); s.percentLabel:ClearAnchors(); s.percentLabel:SetAnchor(CENTER,s,CENTER,8*scale,-24*scale)
    m.rawLabel:ClearAnchors(); m.rawLabel:SetAnchor(CENTER,m,CENTER,8*scale,24*scale); m.percentLabel:ClearAnchors(); m.percentLabel:SetAnchor(CENTER,m,CENTER,8*scale,54*scale)
    for _,t in pairs(self.trackers) do self:ApplyTrackerSlot(t,h,inner,outer,width,scale) end
    for _,b in pairs(self.bars) do b.bg:SetAlpha(sv.backgroundAlpha); b.fill:SetAlpha(sv.fillAlpha); b.frame:SetAlpha(sv.frameAlpha); b.rawLabel:SetAlpha(sv.textAlpha); b.percentLabel:SetAlpha(sv.textAlpha) end
    self.mountBar.bg:SetAlpha(sv.backgroundAlpha); self.mountBar.fill:SetAlpha(sv.fillAlpha); self.mountBar.frame:SetAlpha(sv.frameAlpha)
    for _,t in pairs(self.trackers) do t.fill:SetAlpha(sv.fillAlpha); t.frame:SetAlpha(sv.frameAlpha); t.timer:SetAlpha(sv.textAlpha); t.icon:SetAlpha(sv.textAlpha) end
    h.shield:SetAlpha(sv.shieldAlpha); self:UpdateDefaultUI(true); self:UpdateCombatOpacity(); self:UpdateVisibility(); self:UpdateResources(); self:RefreshMajorBuff()
end
function CH:UpdateCombatOpacity(inCombat)
    if not self.root or not self.sv then return end
    if inCombat~=nil then self.inCombat=inCombat
    elseif IsUnitInCombat then self.inCombat=IsUnitInCombat("player") end
    local alpha=1
    if self.sv.useOutOfCombatOpacity and not self.sv.preview and not self.inCombat then alpha=clamp(self.sv.outOfCombatOpacity,.05,1) end
    self.root:SetAlpha(alpha)
end

function CH:UpdateDefaultUI(force)
    if not self.sv then return end
    local show=self.sv.showDefaultResources~=false
    local playerFrame=_G["ZO_PlayerAttribute"]
    if playerFrame then
        -- Reassert only the user's hidden choice; otherwise let ESO retain its own
        -- contextual visibility rules for combat, menus, death, and interaction modes.
        if not show then playerFrame:SetHidden(true)
        elseif force or self.defaultResourcesShown==false then playerFrame:SetHidden(false) end
    end

    -- ZOS anchors the self-buff row 40 px above the stock player resource frame.
    -- When that frame is hidden, move the row into its vacated space.
    local buffTop=_G["ZO_BuffDebuffTopLevel"]
    local buffContainer=_G["ZO_BuffDebuffTopLevelSelfContainer"] or (buffTop and buffTop:GetNamedChild("SelfContainer"))
    if buffContainer and (force or self.defaultResourcesShown~=show) then
        buffContainer:ClearAnchors()
        buffContainer:SetAnchor(CENTER,playerFrame or GuiRoot,playerFrame and TOP or BOTTOM,0,show and -40 or (tonumber(self.sv.buffVerticalOffset) or 0))
    end
    self.defaultResourcesShown=show
end
function CH:UpdateVisibility(state)
    if state~=nil then self.hudVisible=state~=SCENE_HIDDEN end
    if self.root then self.root:SetHidden(not(self.sv and self.sv.enabled and (self.sv.preview or self.hudVisible~=false))) end
end
function CH:GetPowerValues(powerType)
    local current,maximum,effective=GetUnitPower("player",powerType)
    if (maximum or 0)>1 then return current,maximum end
    -- Console builds can expose a pool before the type lookup is initialized.
    for i=0,10 do
        local ok,pType,pCurrent,pMax,pEffective=pcall(GetUnitPowerInfo,"player",i)
        if ok and pType==powerType and (pMax or 0)>1 then return pCurrent,pMax end
    end
    return current or 0,maximum or 0
end
function CH:UpdateResources()
    if not self.root or not self.sv.enabled then return end
    local v=self.power
    if self.sv.preview then v={health={32400,40000},stamina={18700,32000},magicka={21100,32500}}
    else
        local hc,hm=self:GetPowerValues(HEALTH_POWER); local sc,sm=self:GetPowerValues(STAMINA_POWER); local mc,mm=self:GetPowerValues(MAGICKA_POWER)
        if hm<=1 then
            local ok,statMax=pcall(GetPlayerStat,STAT_HEALTH_MAX,STAT_BONUS_OPTION_APPLY_BONUS)
            if ok then hm=statMax or 0 end
        end
        if hm and hm>0 then v.health={hc,hm} end; if sm and sm>0 then v.stamina={sc,sm} end; if mm and mm>0 then v.magicka={mc,mm} end
    end
    self:SetBarValue(self.bars.health,v.health[1],v.health[2]); self:SetBarValue(self.bars.stamina,v.stamina[1],v.stamina[2]); self:SetBarValue(self.bars.magicka,v.magicka[1],v.magicka[2])
    local shield=self.sv.preview and 14000 or self:GetShieldValue()
    self:SetTexturePercent(self.bars.health.shield,self.bars.health,shield/math.max(1,v.health[2]))
    local healthValid=(v.health[2] or 0)>1
    local over=healthValid and shield>v.health[2]
    self.bars.health.overcap:SetHidden(not over)
    if over then self.bars.health.overcap:SetAlpha(.45+.55*math.abs(math.sin(GetGameTimeMilliseconds()/350))) end

    local mounted=self.sv.preview or (IsMounted and IsMounted())
    local mountCurrent,mountMax=0,0
    if mounted and MOUNT_POWER then mountCurrent,mountMax=self:GetPowerValues(MOUNT_POWER) end
    if self.sv.preview then mountCurrent,mountMax=72,100 end
    self.mountBar:SetHidden(not mounted or (mountMax or 0)<=1)
    if mounted and (mountMax or 0)>1 then self:SetTexturePercent(self.mountBar.fill,self.mountBar,mountCurrent/mountMax) end
end
function CH:GetShieldValue()
    if GetUnitAttributeVisualizerEffectInfo then
        local ok,value=pcall(GetUnitAttributeVisualizerEffectInfo,"player",ATTRIBUTE_VISUAL_POWER_SHIELDING,STAT_MITIGATION,ATTRIBUTE_HEALTH,HEALTH_POWER)
        if ok then
            self.shieldValue=math.max(0,tonumber(value) or 0)
            return self.shieldValue
        end
    end
    return math.max(0,self.shieldValue or 0)
end
function CH:OnShieldVisual(eventCode,unitTag,visualType,statType,attributeType,powerType,oldOrValue,newOrMax)
    if unitTag~="player" or visualType~=ATTRIBUTE_VISUAL_POWER_SHIELDING then return end
    if attributeType and attributeType~=ATTRIBUTE_HEALTH then return end
    if eventCode==EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED then self.shieldValue=0
    elseif eventCode==EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED then self.shieldValue=math.max(0,tonumber(newOrMax) or 0)
    else self.shieldValue=math.max(0,tonumber(oldOrValue) or 0) end
    self:UpdateResources()
end
function CH:UpdateTrackers()
    local now=GetGameTimeSeconds()
    for _,t in pairs(self.trackers) do
        local enabled=t.key~="balance" and t.key~="aegis" or self.sv[t.key.."Enabled"]~=false
        local active,pct,remaining=t.active and enabled,0,0
        if self.sv.preview and enabled then active,pct,remaining=true,.62,12.4
        elseif active then
            remaining=math.max(0,t.endTime-now); pct=remaining/math.max(.01,t.duration or 0)
            if remaining>0 then pct=math.max(.035,pct) else t.active,active=false,false end
        end
        t:SetHidden(not active)
        if active then
            self:SetTexturePercent(t.fill,t,pct); t.timer:SetText(string.format("%.1f",remaining))
            local stacks=tonumber(t.stackCount) or 0; t.stackLabel:SetText(tostring(stacks)); t.stackLabel:SetHidden(stacks<=0)
        else t.stackLabel:SetHidden(true) end
    end
end
function CH:MajorBuffMatches(effectName,abilityId)
    local selected=self.sv.majorBuffTracked or "Major Resolve"; if selected=="None" then return false end
    local knownId=MAJOR_BUFF_IDS[selected]
    if knownId and abilityId==knownId then return true end
    local localized=knownId and GetAbilityName and GetAbilityName(knownId) or nil
    return effectName==selected or (localized and localized~="" and effectName==localized)
end
function CH:RefreshMajorBuff()
    local t=self.trackers and self.trackers.resolve; if not t then return end
    t.active,t.stackCount=false,0
    if self.sv.preview or self.sv.majorBuffTracked=="None" or not GetNumBuffs or not GetUnitBuffInfo then return end
    for index=1,GetNumBuffs("player") do
        local name,beginTime,endTime,_,stackCount,iconName,_,_,_,_,abilityId=GetUnitBuffInfo("player",index)
        if self:MajorBuffMatches(name,abilityId) then
            t.active,t.beginTime,t.endTime,t.duration,t.stackCount=true,beginTime or 0,endTime or 0,math.max(.01,(endTime or 0)-(beginTime or 0)),stackCount or 0
            if iconName and iconName~="" then t.icon:SetTexture(iconName) end
            break
        end
    end
end
function CH:OnEffectChanged(changeType,effectName,unitTag,beginTime,endTime,stackCount,iconName,abilityId)
    if unitTag~="player" then return end
    local t
    if self:MajorBuffMatches(effectName,abilityId) then t=self.trackers.resolve
    elseif abilityId==48136 or abilityId==48131 or abilityId==48141 then t=self.trackers.balance
    elseif abilityId==24163 then t=self.trackers.aegis
    else
        local lowerName=string.lower(effectName or ""); local duration=(endTime or 0)-(beginTime or 0)
        if duration>0 and duration<30 and (string.find(lowerName,"bound aegis",1,true) or string.find(lowerName,"bound armor",1,true)) then t=self.trackers.aegis end
    end
    if not t then return end
    local wasActive=t.active
    t.active=changeType~=EFFECT_RESULT_FADED and (endTime or 0)>GetGameTimeSeconds(); t.beginTime,t.endTime=beginTime or 0,endTime or 0
    t.stackCount=stackCount or 0
    local reportedDuration=(endTime or 0)-(beginTime or 0)
    if t.active and (not wasActive or (reportedDuration>0 and reportedDuration<3600)) then t.duration=reportedDuration end
    if iconName and iconName~="" then t.icon:SetTexture(iconName) end; self:UpdateTrackers()
end

function CH:CreateHUD()
    self.root=WM:CreateTopLevelWindow("CurvedHUD_Root"); self.root:SetDimensions(900,600); self.root:SetMouseEnabled(false); self.root:SetClampedToScreen(false); self.root:SetDrawTier(DT_HIGH)
    self.bars,self.trackers={},{}; self:CreateBar("health","left",{.85,.1,.1}); self:CreateBar("stamina","right",{.15,.78,.22}); self:CreateBar("magicka","right",{.12,.42,.95})
    self:CreateShield(); self:CreateMountBar(); self:CreateTracker("resolve","bottomLeftOutside","majorBuffColor"); self:CreateTracker("balance","bottomLeftInside","balanceColor","balance"); self:CreateTracker("aegis","topLeftOutside","aegisColor"); self:ApplyLayout()
end
function CH:RegisterEvents()
    EVENT_MANAGER:RegisterForEvent(self.name,EVENT_POWER_UPDATE,function(_,unitTag,_,powerType,current,maximum,effectiveMaximum)
        if unitTag~="player" then return end
        local key=powerType==HEALTH_POWER and "health" or powerType==STAMINA_POWER and "stamina" or powerType==MAGICKA_POWER and "magicka"
        local usableMax=(maximum or 0)>1 and maximum or (effectiveMaximum or 0)
        if key and usableMax>1 then self.power[key]={current,usableMax}; self:Guard("power event",function() self:UpdateResources() end) end
    end); EVENT_MANAGER:AddFilterForEvent(self.name,EVENT_POWER_UPDATE,REGISTER_FILTER_UNIT_TAG,"player")
    EVENT_MANAGER:RegisterForEvent(self.name.."Effects",EVENT_EFFECT_CHANGED,function(_,changeType,_,effectName,unitTag,beginTime,endTime,stackCount,iconName,_,_,_,_,_,_,abilityId)
        self:Guard("effect event",function() self:OnEffectChanged(changeType,effectName,unitTag,beginTime,endTime,stackCount,iconName,abilityId) end)
    end); EVENT_MANAGER:AddFilterForEvent(self.name.."Effects",EVENT_EFFECT_CHANGED,REGISTER_FILTER_UNIT_TAG,"player")
    EVENT_MANAGER:RegisterForEvent(self.name.."Activated",EVENT_PLAYER_ACTIVATED,function() self:Guard("player activation",function() self:ApplyLayout() end) end)
    EVENT_MANAGER:RegisterForEvent(self.name.."Combat",EVENT_PLAYER_COMBAT_STATE,function(_,inCombat) self:Guard("combat opacity",function() self:UpdateCombatOpacity(inCombat) end) end)
    local shieldCallback=function(eventCode,unitTag,visualType,statType,attributeType,powerType,value1,value2)
        self:Guard("shield event",function() self:OnShieldVisual(eventCode,unitTag,visualType,statType,attributeType,powerType,value1,value2) end)
    end
    EVENT_MANAGER:RegisterForEvent(self.name.."ShieldAdded",EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED,shieldCallback)
    EVENT_MANAGER:RegisterForEvent(self.name.."ShieldUpdated",EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED,shieldCallback)
    EVENT_MANAGER:RegisterForEvent(self.name.."ShieldRemoved",EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED,shieldCallback)
    local callback=function(_,state) self:UpdateVisibility(state) end
    SCENE_MANAGER:GetScene("hud"):RegisterCallback("StateChange",callback); SCENE_MANAGER:GetScene("hudui"):RegisterCallback("StateChange",callback)
    EVENT_MANAGER:RegisterForUpdate(self.updateName,100,function() self:Guard("periodic update",function() self:UpdateResources(); self:UpdateTrackers(); self:UpdateDefaultUI(false) end) end)
end
function CH:Initialize()
    self.globalSV=ZO_SavedVars:NewAccountWide("CurvedHUD_SavedVariables",1,nil,self.defaults)
    self.characterSV=ZO_SavedVars:New("CurvedHUD_CharacterSavedVariables",1,nil,self.characterDefaults)
    -- Preserve the user's existing account-wide tracker choices once when a
    -- character first adopts the new character-specific tracker profile.
    if not self.characterSV.initialized then
        for key in pairs(self.characterKeys) do
            if self.globalSV[key]~=nil then self.characterSV[key]=self.globalSV[key] end
        end
        self.characterSV.initialized=true
    end
    -- Existing code and both settings providers can continue using CH.sv. The
    -- proxy routes only tracker choices to this character; geometry, sizing,
    -- opacity, fonts, and layout remain account-wide.
    self.sv=setmetatable({}, {
        __index=function(_,key) if self.characterKeys[key] then return self.characterSV[key] end return self.globalSV[key] end,
        __newindex=function(_,key,value) if self.characterKeys[key] then self.characterSV[key]=value else self.globalSV[key]=value end end,
    })
    self.power={health={0,0},stamina={0,0},magicka={0,0}}; self.shieldValue=0; self.hudVisible=true
    self:Guard("HUD creation",function() self:CreateHUD() end); self:Guard("settings registration",function() if self.RegisterSettings then self:RegisterSettings() end end); self:Guard("event registration",function() self:RegisterEvents() end)
    SLASH_COMMANDS["/curvedhud"]=function(arg)
        arg=string.lower(arg or "")
        if arg=="preview" then self.sv.preview=not self.sv.preview; self:ApplyLayout()
        elseif arg=="debug" then self.sv.debug=not self.sv.debug; self:Log("Debug "..(self.sv.debug and "enabled" or "disabled"),true)
        elseif arg=="status" then
            local hc,hm,he=GetUnitPower("player",HEALTH_POWER)
            self:Log(string.format("Health API: type=%s current=%s max=%s effective=%s cached=%s/%s shield=%s",tostring(HEALTH_POWER),tostring(hc),tostring(hm),tostring(he),tostring(self.power.health[1]),tostring(self.power.health[2]),tostring(self.shieldValue)),true)
        else self:Log("Loaded "..self.version..". Commands: /curvedhud preview, /curvedhud debug, /curvedhud status",true) end
    end
    self:Log("Loaded "..self.version.."; HUD, shield, and trackers created",true)
end
local function loaded(_,addonName)
    if addonName~=CH.name then return end; EVENT_MANAGER:UnregisterForEvent(CH.name,EVENT_ADD_ON_LOADED); CH:Guard("initialization",function() CH:Initialize() end)
end
EVENT_MANAGER:RegisterForEvent(CH.name,EVENT_ADD_ON_LOADED,loaded)
