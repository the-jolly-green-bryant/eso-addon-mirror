local BB=BetterBuffs
BB.UI=BB.UI or {}
local UI=BB.UI
local WM=WINDOW_MANAGER
local C=BB.Constants

local function CreateLabel(parent,font,color)
    local label=WM:CreateControl(nil,parent,CT_LABEL)
    label:SetFont(font)
    label:SetColor(unpack(color or C.WHITE))
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    return label
end

local function Backdrop(parent)
    local bg=WM:CreateControl(nil,parent,CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0.02,0.025,0.05,0.42)
    bg:SetEdgeColor(0.8,0.62,0.18,0.85)
    bg:SetEdgeTexture("EsoUI/Art/Tooltips/UI-SliderBackdrop.dds",1,1,2)
    return bg
end

local function StateColor(percent, active)
    if not active then return unpack(C.DIM) end
    if percent >= 60 then return unpack(C.GREEN) end
    if percent >= 25 then return unpack(C.YELLOW) end
    return unpack(C.RED)
end

function UI:Initialize()
    self.states={}
    self.rows={BUFF={},DEBUFF={}}
    self.tiles={BUFF={},DEBUFF={}}
    self.preview={BUFF=nil,DEBUFF=nil}
    self.previewScene={BUFF=nil,DEBUFF=nil}
    self.previewGeneration={BUFF=0,DEBUFF=0}
    self.positionPreviewGeneration={BUFF=0,DEBUFF=0}
    self:CreateDashboard("BUFF","Better Buffs")
    self:CreateDashboard("DEBUFF","Better Debuffs")
    self:CreateSlayerMissAlert()
    self:ApplySettings("BUFF")
    self:ApplySettings("DEBUFF")
    self:RefreshAll(true)
end

function UI:CreateDashboard(effectType,titleText)
    local suffix=effectType=="BUFF" and "Buffs" or "Debuffs"
    local panel=WM:CreateTopLevelWindow("BetterBuffs"..suffix.."Dashboard")
    panel:SetDimensions(C.PANEL_WIDTH,100)
    panel:SetClampedToScreen(true)
    panel:SetMouseEnabled(false)
    panel:SetMovable(false)
    -- Let ESO's native scene manager own HUD/menu layering. Renderer visibility is
    -- expressed as a fragment hidden reason instead of fighting menu draw tiers.
    local fragment=ZO_HUDFadeSceneFragment:New(panel,nil,0)
    HUD_SCENE:AddFragment(fragment)
    HUD_UI_SCENE:AddFragment(fragment)
    fragment:SetHiddenForReason("BetterBuffsContent",true,0,0)
    local bg=Backdrop(panel)
    local title=CreateLabel(panel,"$(BOLD_FONT)|22|outline",C.GOLD)
    title:SetAnchor(TOPLEFT,panel,TOPLEFT,C.PANEL_PADDING,6)
    title:SetAnchor(TOPRIGHT,panel,TOPRIGHT,-C.PANEL_PADDING,6)
    title:SetText(titleText)
    local line=WM:CreateControl(nil,panel,CT_TEXTURE)
    line:SetColor(C.GOLD[1],C.GOLD[2],C.GOLD[3],0.7)
    line:SetDimensions(C.BAR_WIDTH,2)
    line:SetAnchor(TOPLEFT,panel,TOPLEFT,C.PANEL_PADDING,34)
    self[effectType=="BUFF" and "buffPanel" or "debuffPanel"]={control=panel,bg=bg,title=title,line=line,fragment=fragment}
end

function UI:GetPanel(effectType) return effectType=="BUFF" and self.buffPanel or self.debuffPanel end
function UI:GetSaved(effectType) return effectType=="BUFF" and BB.saved.ui.buffs or BB.saved.ui.debuffs end

function UI:CreateSlayerMissAlert()
    local control=WM:CreateTopLevelWindow("BetterBuffsSlayerMissAlert")
    control:SetDimensions(520,72)
    control:SetClampedToScreen(true)
    control:SetMouseEnabled(false)
    control:SetMovable(false)
    -- The alert is opt-in. Keep the actual control hidden at creation so adding
    -- its HUD fragment to an already-visible scene can never flash the message
    -- during login, ReloadUI, or character switching.
    control:SetHidden(true)
    local label=CreateLabel(control,"$(BOLD_FONT)|34|thick-outline",C.RED)
    label:SetAnchorFill()
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetText("YOU DID NOT GET SLAYER")
    local fragment=ZO_HUDFadeSceneFragment:New(control,nil,0)
    HUD_SCENE:AddFragment(fragment)
    HUD_UI_SCENE:AddFragment(fragment)
    fragment:SetHiddenForReason("BetterBuffsSlayerAlert",true,0,0)
    self.slayerAlert={control=control,label=label,fragment=fragment,generation=0,previewScene=nil}
    self:ApplySlayerAlertSettings()
end

function UI:GetSlayerAlertSaved() return BB.saved.ui.slayerMissAlert end

function UI:ApplySlayerAlertSettings()
    if not self.slayerAlert then return end
    local saved=self:GetSlayerAlertSaved()
    self.slayerAlert.control:ClearAnchors()
    self.slayerAlert.control:SetAnchor(CENTER,GuiRoot,CENTER,saved.offsetX or 0,saved.offsetY or -180)
    self.slayerAlert.control:SetScale(saved.scale or 1)
end

function UI:HideSlayerMissAlert()
    if not self.slayerAlert then return end
    self.slayerAlert.generation=(self.slayerAlert.generation or 0)+1
    self.slayerAlert.fragment:SetHiddenForReason("BetterBuffsSlayerAlert",true,0,0)
    self.slayerAlert.control:SetHidden(true)
    local scene=self.slayerAlert.previewScene
    self.slayerAlert.previewScene=nil
    if scene and scene~=HUD_SCENE and scene~=HUD_UI_SCENE then scene:RemoveFragment(self.slayerAlert.fragment) end
end

function UI:ShowSlayerMissAlert(preview)
    if not self.slayerAlert then return end
    local saved=self:GetSlayerAlertSaved()
    if not preview and saved.enabled ~= true then self:HideSlayerMissAlert(); return end
    self:ApplySlayerAlertSettings()
    self.slayerAlert.generation=(self.slayerAlert.generation or 0)+1
    local generation=self.slayerAlert.generation
    local previewScene=nil
    if preview then
        local currentScene=SCENE_MANAGER and SCENE_MANAGER:GetCurrentScene() or nil
        if currentScene and currentScene~=HUD_SCENE and currentScene~=HUD_UI_SCENE then
            currentScene:AddFragment(self.slayerAlert.fragment)
            previewScene=currentScene
            self.slayerAlert.previewScene=currentScene
        end
    end
    self.slayerAlert.control:SetHidden(false)
    self.slayerAlert.fragment:SetHiddenForReason("BetterBuffsSlayerAlert",false,0,0)
    zo_callLater(function()
        if not UI.slayerAlert or generation~=UI.slayerAlert.generation then return end
        UI.slayerAlert.fragment:SetHiddenForReason("BetterBuffsSlayerAlert",true,0,0)
        UI.slayerAlert.control:SetHidden(true)
        if previewScene then previewScene:RemoveFragment(UI.slayerAlert.fragment) end
        if UI.slayerAlert.previewScene==previewScene then UI.slayerAlert.previewScene=nil end
    end, tonumber(saved.durationMs) or 2500)
end

function UI:NudgeSlayerAlert(dx,dy)
    local saved=self:GetSlayerAlertSaved()
    saved.offsetX=zo_clamp((saved.offsetX or 0)+dx,-1600,1600)
    saved.offsetY=zo_clamp((saved.offsetY or -180)+dy,-900,900)
    self:ApplySlayerAlertSettings()
    self:ShowSlayerMissAlert(true)
end

function UI:ResetSlayerAlertPosition()
    local saved=self:GetSlayerAlertSaved()
    saved.offsetX=0; saved.offsetY=-180
    self:ApplySlayerAlertSettings()
    self:ShowSlayerMissAlert(true)
end

function UI:AttachPanelToCurrentSettingsScene(effectType)
    local panel=self:GetPanel(effectType)
    local currentScene=SCENE_MANAGER and SCENE_MANAGER:GetCurrentScene() or nil
    local previousScene=self.previewScene[effectType]
    if previousScene and previousScene~=currentScene and previousScene~=HUD_SCENE and previousScene~=HUD_UI_SCENE then
        previousScene:RemoveFragment(panel.fragment)
        self.previewScene[effectType]=nil
    end
    if currentScene and currentScene~=HUD_SCENE and currentScene~=HUD_UI_SCENE and self.previewScene[effectType]~=currentScene then
        currentScene:AddFragment(panel.fragment)
        self.previewScene[effectType]=currentScene
    end
end

function UI:HidePositioningPreview(effectType)
    self.positionPreviewGeneration[effectType]=(self.positionPreviewGeneration[effectType] or 0)+1
    if self.preview[effectType] then return end
    local panel=self:GetPanel(effectType)
    local scene=self.previewScene[effectType]
    self.previewScene[effectType]=nil
    if scene and scene~=HUD_SCENE and scene~=HUD_UI_SCENE then scene:RemoveFragment(panel.fragment) end
    self:RefreshPanel(effectType,true)
end

function UI:HideAllPositioningPreviews()
    self:HidePositioningPreview("BUFF")
    self:HidePositioningPreview("DEBUFF")
end

function UI:ShowForPositioning(effectType,durationMs)
    local other=effectType=="BUFF" and "DEBUFF" or "BUFF"
    self:HidePositioningPreview(other)
    self.positionPreviewGeneration[effectType]=(self.positionPreviewGeneration[effectType] or 0)+1
    local generation=self.positionPreviewGeneration[effectType]
    self:AttachPanelToCurrentSettingsScene(effectType)
    self:RefreshPanel(effectType,true)

    -- A positive duration is used by one-shot positioning actions. A nil/zero
    -- duration means the settings page owns visibility until another section is
    -- selected or the Better Buffs settings panel is closed.
    local timeout=tonumber(durationMs) or 0
    if timeout>0 then
        zo_callLater(function()
            if generation~=UI.positionPreviewGeneration[effectType] or UI.preview[effectType] then return end
            UI:HidePositioningPreview(effectType)
        end,timeout)
    end
end

function UI:ApplySettings(effectType)
    local panel=self:GetPanel(effectType)
    local saved=self:GetSaved(effectType)
    panel.control:ClearAnchors()
    panel.control:SetAnchor(CENTER,GuiRoot,CENTER,saved.offsetX or 0,saved.offsetY or 0)
    panel.control:SetScale(saved.scale or 1)
    panel.control:SetMovable(false)
    panel.control:SetMouseEnabled(false)
    panel.bg:SetCenterColor(0.02,0.025,0.05,zo_clamp(saved.opacity or 0.42,0.05,0.95))
    self:RefreshPanel(effectType,true)
end

function UI:Nudge(effectType,dx,dy)
    self:ShowForPositioning(effectType,20000)
    local saved=self:GetSaved(effectType)
    saved.offsetX=zo_clamp((saved.offsetX or 0)+dx,-1600,1600)
    saved.offsetY=zo_clamp((saved.offsetY or 0)+dy,-900,900)
    self:ApplySettings(effectType)
end

function UI:ResetPosition(effectType)
    self:ShowForPositioning(effectType,20000)
    local saved=self:GetSaved(effectType)
    if effectType=="BUFF" then saved.offsetX=-330; saved.offsetY=-80 else saved.offsetX=330; saved.offsetY=-80 end
    self:ApplySettings(effectType)
end

function UI:EnsureRow(definition)
    local rows=self.rows[definition.effectType]
    if rows[definition.key] then return rows[definition.key] end
    local panel=self:GetPanel(definition.effectType).control
    local row={control=WM:CreateControl(nil,panel,CT_CONTROL)}
    row.control:SetDimensions(C.BAR_WIDTH,C.ROW_HEIGHT)
    row.name=CreateLabel(row.control,"$(BOLD_FONT)|17|outline",C.WHITE)
    row.name:SetAnchor(TOPLEFT,row.control,TOPLEFT,0,0)
    row.name:SetDimensions(235,24)
    row.name:SetText(definition.name)
    row.status=CreateLabel(row.control,"$(BOLD_FONT)|16|outline",C.WHITE)
    row.status:SetAnchor(TOPRIGHT,row.control,TOPRIGHT,0,0)
    row.status:SetDimensions(90,24)
    row.status:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    row.detail=CreateLabel(row.control,"$(BOLD_FONT)|16|thick-outline",{0.92,0.92,0.92,1})
    row.detail:SetAnchor(TOPLEFT,row.control,TOPLEFT,0,23)
    row.detail:SetAnchor(TOPRIGHT,row.control,TOPRIGHT,0,23)
    row.detail:SetHeight(19)
    row.barBg=WM:CreateControl(nil,row.control,CT_TEXTURE)
    row.barBg:SetColor(0.14,0.14,0.17,0.85)
    row.barBg:SetDimensions(C.BAR_WIDTH,C.BAR_HEIGHT)
    row.barBg:SetAnchor(BOTTOMLEFT,row.control,BOTTOMLEFT,0,-1)
    row.bar=WM:CreateControl(nil,row.control,CT_TEXTURE)
    row.bar:SetDimensions(1,C.BAR_HEIGHT)
    row.bar:SetAnchor(BOTTOMLEFT,row.control,BOTTOMLEFT,0,-1)
    rows[definition.key]=row
    return row
end

function UI:EnsureTile(definition)
    local tiles=self.tiles[definition.effectType]
    if tiles[definition.key] then return tiles[definition.key] end
    local panel=self:GetPanel(definition.effectType).control
    local tile={control=WM:CreateControl(nil,panel,CT_CONTROL), lastAvailability=nil}
    tile.control:SetDimensions(C.COMPACT_TILE_SIZE,C.COMPACT_TILE_SIZE)
    tile.bg=Backdrop(tile.control)
    tile.bg:SetCenterColor(0.015,0.02,0.035,0.70)
    tile.bg:SetEdgeColor(0.35,0.35,0.42,0.85)
    tile.icon=WM:CreateControl(nil,tile.control,CT_TEXTURE)
    tile.icon:SetDimensions(C.COMPACT_TILE_SIZE-14,C.COMPACT_TILE_SIZE-14)
    tile.icon:SetAnchor(CENTER,tile.control,CENTER,0,0)
    tile.countdown=CreateLabel(tile.control,"$(BOLD_FONT)|20|thick-outline",C.WHITE)
    tile.countdown:SetAnchor(CENTER,tile.control,CENTER,0,0)
    tile.countdown:SetDimensions(C.COMPACT_TILE_SIZE-10,28)
    tile.countdown:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    tile.coverage=CreateLabel(tile.control,"$(BOLD_FONT)|12|thick-outline",C.WHITE)
    tile.coverage:SetAnchor(BOTTOMRIGHT,tile.control,BOTTOMRIGHT,-2,-1)
    tile.coverage:SetDimensions(36,16)
    tile.coverage:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    tile.stack=CreateLabel(tile.control,"$(BOLD_FONT)|12|thick-outline",C.GOLD)
    tile.stack:SetAnchor(TOPRIGHT,tile.control,TOPRIGHT,-2,1)
    tile.stack:SetDimensions(24,16)
    tile.stack:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    tile.ring={}
    local radius=(C.COMPACT_TILE_SIZE/2)-2
    for i=1,C.COMPACT_RING_SEGMENTS do
        local dot=WM:CreateControl(nil,tile.control,CT_TEXTURE)
        dot:SetDimensions(C.COMPACT_RING_DOT_SIZE,C.COMPACT_RING_DOT_SIZE)
        local angle=((i-1)/C.COMPACT_RING_SEGMENTS)*(math.pi*2)-(math.pi/2)
        dot:SetAnchor(CENTER,tile.control,CENTER,math.cos(angle)*radius,math.sin(angle)*radius)
        dot:SetColor(unpack(C.GREEN))
        tile.ring[i]=dot
    end
    tiles[definition.key]=tile
    return tile
end

function UI:UpdateEffect(definition,state)
    self.states[definition.key]=state
end

function UI:ClearEffect(key)
    self.states[key]=nil
    for _,rows in pairs(self.rows) do if rows[key] then rows[key].control:SetHidden(true) end end
    for _,tiles in pairs(self.tiles) do if tiles[key] then tiles[key].control:SetHidden(true) end end
end

function UI:GetState(definition)
    local preview=self.preview[definition.effectType]
    if preview and preview[definition.key] then return preview[definition.key] end
    local defaultAvailability = definition.showReady and not definition.readyRequiresObservedProvider and "READY" or "INACTIVE"
    return self.states[definition.key] or {active=false,availability=defaultAvailability,remaining=0,percent=0,covered=0,target=definition.effectType=="BUFF" and BB:GetGroupTargetCount() or 0,missingPlayers={},activePlayers={},stackCount=0,ready=0,locked=0,icon=BB.Registry:GetIcon(definition)}
end

function UI:GetDefinitions(effectType)
    local source=effectType=="BUFF" and BB.Registry.buffs or BB.Registry.debuffs
    local result={}
    for _,definition in ipairs(source) do if BB:IsEffectRelevant(definition.key) then result[#result+1]=definition end end
    local saved=self:GetSaved(effectType)
    local order=saved.sortOrder or "PRIORITY"
    if saved.compactLayout=="CRESCENT" and order=="TIME" then order="PRIORITY" end
    table.sort(result,function(a,b)
        if order=="ALPHABETICAL" then return a.name < b.name end
        if order=="TIME" then
            local ar=(self:GetState(a).remaining or 0); local br=(self:GetState(b).remaining or 0)
            if ar==br then return a.name < b.name end
            return ar < br
        end
        local ap=a.displayPriority or 100; local bp=b.displayPriority or 100
        if ap==bp then return a.name < b.name end
        return ap < bp
    end)
    return result
end

function UI:SetBarColor(row,percent,active)
    local r,g,b,a=StateColor(percent,active)
    row.bar:SetColor(r,g,b,0.96); row.status:SetColor(r,g,b,1)
end

function UI:RefreshDetailed(effectType)
    local panel=self:GetPanel(effectType)
    local y=42; local count=0
    for _,definition in ipairs(self:GetDefinitions(effectType)) do
        local row=self:EnsureRow(definition)
        local state=self:GetState(definition)
        row.control:ClearAnchors(); row.control:SetAnchor(TOPLEFT,panel.control,TOPLEFT,C.PANEL_PADDING,y); row.control:SetHidden(false)
        local detail=""
        if effectType=="BUFF" then
            if definition.intelligenceMode=="RECIPIENT_COOLDOWN" then
                detail="READY  "..tostring(state.ready or 0).."/"..tostring(state.target or 0).."   LOCKED  "..tostring(state.locked or 0)
            elseif definition.recipientDisplay=="ACTIVE" and state.activePlayers and #state.activePlayers>0 then
                local chunks={}
                for i=1,#state.activePlayers,3 do
                    local line={}
                    for j=i,math.min(i+2,#state.activePlayers) do line[#line+1]=state.activePlayers[j] end
                    chunks[#chunks+1]=(i==1 and "ACTIVE: " or "        ")..table.concat(line,"  ")
                end
                detail=table.concat(chunks,"\n")
            elseif definition.coverage then
                detail="PLAYERS  "..tostring(state.covered or 0).."/"..tostring(state.target or BB:GetGroupTargetCount())
            end
            if definition.showMissingPlayers and state.missingPlayers and #state.missingPlayers>0 then detail="MISSING: "..table.concat(state.missingPlayers,"  ") end
        else
            detail=state.targetName and state.targetName~="" and ("TARGET: "..tostring(state.targetName)) or "NO ACTIVE TARGET"
        end
        row.detail:SetText(detail)
        local rowHeight=C.ROW_HEIGHT
        if definition.recipientDisplay=="ACTIVE" and state.activePlayers and #state.activePlayers>3 then
            rowHeight=C.ROW_HEIGHT + (math.ceil(#state.activePlayers/3)-1)*17
        end
        row.control:SetDimensions(C.BAR_WIDTH,rowHeight)
        row.detail:SetHeight(math.max(19,rowHeight-37))
        if effectType=="BUFF" then
            if definition.showMissingPlayers and state.missingPlayers and #state.missingPlayers>0 then row.detail:SetColor(1.00,0.30,0.25,1)
            elseif definition.recipientDisplay=="ACTIVE" then row.detail:SetColor(0.35,1.00,0.60,1)
            elseif definition.coverage then row.detail:SetColor(0.35,0.88,1.00,1)
            else row.detail:SetColor(0.82,0.82,0.82,1) end
        elseif state.targetName and state.targetName~="" then row.detail:SetColor(1.00,0.76,0.20,1)
        else row.detail:SetColor(0.72,0.72,0.72,1) end

        if definition.intelligenceMode=="RECIPIENT_COOLDOWN" then
            row.status:SetText(state.availability=="READY" and "READY" or ((state.remaining or 0)>0 and string.format("%.0fs",state.remaining) or state.availability))
        elseif definition.timer then row.status:SetText((state.remaining or 0)>0 and string.format("%.1fs",state.remaining) or "DOWN")
        elseif definition.coverage then row.status:SetText(tostring(state.covered or 0).."/"..tostring(state.target or 0))
        else row.status:SetText(state.active and "ACTIVE" or "DOWN") end
        local percent=definition.timer and (state.percent or 0) or ((state.target or 0)>0 and ((state.covered or 0)/(state.target or 1))*100 or 0)
        if definition.intelligenceMode=="RECIPIENT_COOLDOWN" then percent=state.percent or 0 end
        row.bar:SetDimensions(math.max(1,C.BAR_WIDTH*zo_clamp(percent,0,100)/100),C.BAR_HEIGHT)
        self:SetBarColor(row,percent,state.active or state.availability=="COOLDOWN")
        y=y+rowHeight; count=count+1
    end
    for key,row in pairs(self.rows[effectType]) do if not BB:IsEffectRelevant(key) then row.control:SetHidden(true) end end
    panel.control:SetDimensions(C.PANEL_WIDTH,math.max(50,y+8))
    return count
end

function UI:UpdateTile(definition,tile,state,tileSize)
    tile.control:SetDimensions(tileSize,tileSize)
    tile.icon:SetDimensions(math.max(22,tileSize-14),math.max(22,tileSize-14))
    tile.icon:SetTexture(state.icon or BB.Registry:GetIcon(definition))
    if tile.icon.SetDesaturation then tile.icon:SetDesaturation((state.availability=="COOLDOWN" or state.availability=="INACTIVE") and 1 or 0) end
    local radius=(tileSize/2)-2
    for i,dot in ipairs(tile.ring) do
        local angle=((i-1)/C.COMPACT_RING_SEGMENTS)*(math.pi*2)-(math.pi/2)
        dot:ClearAnchors(); dot:SetAnchor(CENTER,tile.control,CENTER,math.cos(angle)*radius,math.sin(angle)*radius)
    end
    local percent=state.percent or 0
    local visible=math.ceil(zo_clamp(percent,0,100)/100*C.COMPACT_RING_SEGMENTS)
    local r,g,b,a=StateColor(percent,state.active or state.availability=="COOLDOWN")
    if state.availability=="READY" then r,g,b,a=unpack(C.READY_GOLD); visible=C.COMPACT_RING_SEGMENTS end
    for i,dot in ipairs(tile.ring) do dot:SetHidden(i>visible and state.availability~="READY"); dot:SetColor(r,g,b,a or 1) end

    if state.availability=="READY" then
        tile.countdown:SetText("READY")
        tile.countdown:SetFont("$(BOLD_FONT)|13|thick-outline")
        tile.bg:SetEdgeColor(unpack(C.READY_GOLD))
        if tile.lastAvailability~="READY" and BB.saved.advanced.readyAnimation~=false then
            tile.bg:SetCenterColor(0.24,0.18,0.02,0.92)
            zo_callLater(function() if tile.lastAvailability=="READY" then tile.bg:SetCenterColor(0.015,0.02,0.035,0.70) end end,C.READY_PULSE_MS)
        end
    elseif state.availability=="PARTIAL" then
        tile.countdown:SetFont("$(BOLD_FONT)|20|thick-outline")
        tile.countdown:SetText((state.remaining or 0)>0 and tostring(math.ceil(state.remaining)) or "")
        tile.bg:SetEdgeColor(unpack(C.YELLOW))
    elseif state.availability=="COOLDOWN" then
        tile.countdown:SetFont("$(BOLD_FONT)|20|thick-outline")
        tile.countdown:SetText((state.remaining or 0)>0 and tostring(math.ceil(state.remaining)) or "")
        tile.bg:SetEdgeColor(0.35,0.35,0.42,0.90)
    elseif state.active then
        tile.countdown:SetFont("$(BOLD_FONT)|20|thick-outline")
        tile.countdown:SetText(definition.timer and (state.remaining or 0)>0 and tostring(math.ceil(state.remaining)) or "")
        tile.bg:SetEdgeColor(r,g,b,0.95)
    else
        tile.countdown:SetText("")
        tile.bg:SetEdgeColor(0.28,0.28,0.34,0.70)
    end
    tile.lastAvailability=state.availability
    local badgeValue=state.covered or 0
    if definition.intelligenceMode=="RECIPIENT_COOLDOWN" then badgeValue=state.ready or 0 end
    tile.coverage:SetText(definition.showCoverage and state.target and state.target>0 and (tostring(badgeValue).."/"..tostring(state.target)) or "")
    tile.stack:SetText(definition.showStacks and (state.stackCount or 0)>0 and tostring(state.stackCount) or "")
end

function UI:LayoutCompact(effectType,definitions)
    local panel=self:GetPanel(effectType)
    local saved=self:GetSaved(effectType)
    local size=zo_clamp(tonumber(saved.tileSize) or C.COMPACT_TILE_SIZE,42,90)
    local spacing=zo_clamp(tonumber(saved.tileSpacing) or C.COMPACT_TILE_SPACING,0,30)
    local layout=saved.compactLayout or "GRID"
    local n=#definitions
    local width,height=size,size
    if layout=="GRID" then
        local perRow=zo_clamp(tonumber(saved.iconsPerRow) or 4,1,8)
        local cols=math.min(n,perRow); local rows=math.max(1,math.ceil(n/perRow))
        width=math.max(size,cols*size+math.max(0,cols-1)*spacing)
        height=math.max(size,rows*size+math.max(0,rows-1)*spacing)
        for i,definition in ipairs(definitions) do
            local tile=self:EnsureTile(definition); local col=(i-1)%perRow; local row=math.floor((i-1)/perRow)
            tile.control:ClearAnchors(); tile.control:SetAnchor(TOPLEFT,panel.control,TOPLEFT,col*(size+spacing),row*(size+spacing)); tile.control:SetHidden(false)
            self:UpdateTile(definition,tile,self:GetState(definition),size)
        end
    elseif layout=="COLUMN" then
        height=math.max(size,n*size+math.max(0,n-1)*spacing)
        for i,definition in ipairs(definitions) do
            local tile=self:EnsureTile(definition)
            tile.control:ClearAnchors(); tile.control:SetAnchor(TOPLEFT,panel.control,TOPLEFT,0,(i-1)*(size+spacing)); tile.control:SetHidden(false)
            self:UpdateTile(definition,tile,self:GetState(definition),size)
        end
    else
        local depth=zo_clamp(tonumber(saved.curveDepth) or 54,0,140)
        local spread=zo_clamp(tonumber(saved.verticalSpread) or 66,30,120)
        width=size+depth
        height=math.max(size, n>1 and ((n-1)*spread+size) or size)
        local side=saved.crescentSide or (effectType=="BUFF" and "LEFT" or "RIGHT")
        local sign=side=="LEFT" and -1 or 1
        local baseX=side=="LEFT" and depth or 0
        for i,definition in ipairs(definitions) do
            local tile=self:EnsureTile(definition)
            local t=n<=1 and 0 or (((i-1)/(n-1))*2-1)
            local x=baseX + sign*(depth*(t*t))
            local y=(i-1)*spread
            tile.control:ClearAnchors(); tile.control:SetAnchor(TOPLEFT,panel.control,TOPLEFT,x,y); tile.control:SetHidden(false)
            self:UpdateTile(definition,tile,self:GetState(definition),size)
        end
    end
    for key,tile in pairs(self.tiles[effectType]) do if not BB:IsEffectRelevant(key) then tile.control:SetHidden(true) end end
    panel.control:SetDimensions(math.max(1,width),math.max(1,height))
    return n
end

function UI:RefreshPanel(effectType,force)
    local panel=self:GetPanel(effectType)
    local saved=self:GetSaved(effectType)
    if not BB.saved.enabled or saved.enabled==false then
        panel.fragment:SetHiddenForReason("BetterBuffsContent",true,0,0)
        return
    end
    local compact=(saved.style or "DETAILED")=="COMPACT"
    panel.bg:SetHidden(compact)
    panel.title:SetHidden(compact)
    panel.line:SetHidden(compact)
    for _,row in pairs(self.rows[effectType]) do row.control:SetHidden(true) end
    for _,tile in pairs(self.tiles[effectType]) do tile.control:SetHidden(true) end
    local definitions=self:GetDefinitions(effectType)
    local count=compact and self:LayoutCompact(effectType,definitions) or self:RefreshDetailed(effectType)
    panel.fragment:SetHiddenForReason("BetterBuffsContent",count==0,0,0)
end

function UI:RefreshAll(force)
    self:RefreshPanel("BUFF",force); self:RefreshPanel("DEBUFF",force)
end

function UI:BuildPreview(effectType)
    local preview={}; local definitions=effectType=="BUFF" and BB.Registry.buffs or BB.Registry.debuffs
    local shown=0
    local samples={"ACTIVE","COOLDOWN","READY","ACTIVE","ACTIVE","INACTIVE"}
    for _,definition in ipairs(definitions) do
        if BB:IsEffectRelevant(definition.key) and shown<8 then
            shown=shown+1
            local availability=samples[((shown-1)%#samples)+1]
            if definition.intelligenceMode~="RECIPIENT_COOLDOWN" and availability=="COOLDOWN" then availability="ACTIVE" end
            if not definition.showReady and availability=="READY" then availability="ACTIVE" end
            preview[definition.key]={
                active=availability=="ACTIVE",availability=availability,remaining=math.max(1,18-shown*2),percent=math.max(8,95-shown*9),
                covered=math.max(0,math.min(BB:GetGroupTargetCount(),BB:GetGroupTargetCount()-shown+2)),target=definition.coverageCap or BB:GetGroupTargetCount(),
                targetName=effectType=="DEBUFF" and "Trial Target" or nil,missingPlayers={"@example"},
                activePlayers=definition.recipientDisplay=="ACTIVE" and {"@player1","@player2","@player3","@player4","@player5","@player6"} or {"@player1","@player2","@player3"},
                stackCount=definition.showStacks and 3 or 0,ready=4,locked=8,icon=BB.Registry:GetIcon(definition),
            }
        end
    end
    return preview
end

function UI:Preview(effectType)
    local panel=self:GetPanel(effectType)
    self.previewGeneration[effectType]=(self.previewGeneration[effectType] or 0)+1
    local generation=self.previewGeneration[effectType]
    self.preview[effectType]=self:BuildPreview(effectType)

    -- Preview temporarily attaches the existing HUD fragment to the current
    -- settings scene. Positioning uses the same ownership path without cloning UI.
    self:AttachPanelToCurrentSettingsScene(effectType)

    self:RefreshPanel(effectType,true)
    zo_callLater(function()
        if generation~=UI.previewGeneration[effectType] then return end
        UI.preview[effectType]=nil
        local scene=UI.previewScene[effectType]
        UI.previewScene[effectType]=nil
        if scene and scene~=HUD_SCENE and scene~=HUD_UI_SCENE then scene:RemoveFragment(panel.fragment) end
        UI:RefreshPanel(effectType,true)
    end,10000)
end
