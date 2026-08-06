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

function UI:Initialize()
    self.states={}
    self.rows={BUFF={},DEBUFF={}}
    self:CreateDashboard("BUFF","Better Buffs")
    self:CreateDashboard("DEBUFF","Better Debuffs")
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
    local bg=Backdrop(panel)
    local title=CreateLabel(panel,"$(BOLD_FONT)|22|outline",C.GOLD)
    title:SetAnchor(TOPLEFT,panel,TOPLEFT,C.PANEL_PADDING,6)
    title:SetAnchor(TOPRIGHT,panel,TOPRIGHT,-C.PANEL_PADDING,6)
    title:SetText(titleText)
    local line=WM:CreateControl(nil,panel,CT_TEXTURE)
    line:SetColor(C.GOLD[1],C.GOLD[2],C.GOLD[3],0.7)
    line:SetDimensions(C.BAR_WIDTH,2)
    line:SetAnchor(TOPLEFT,panel,TOPLEFT,C.PANEL_PADDING,34)
    self[effectType=="BUFF" and "buffPanel" or "debuffPanel"]={control=panel,bg=bg,title=title,line=line}
end

function UI:GetPanel(effectType) return effectType=="BUFF" and self.buffPanel or self.debuffPanel end
function UI:GetSaved(effectType) return effectType=="BUFF" and BB.saved.ui.buffs or BB.saved.ui.debuffs end

function UI:ApplySettings(effectType)
    local panel=self:GetPanel(effectType)
    local saved=self:GetSaved(effectType)
    panel.control:ClearAnchors()
    panel.control:SetAnchor(CENTER,GuiRoot,CENTER,saved.offsetX or 0,saved.offsetY or 0)
    panel.control:SetScale(saved.scale or 1)
    panel.control:SetMovable(false)
    panel.control:SetMouseEnabled(false)
    panel.bg:SetCenterColor(0.02,0.025,0.05,zo_clamp(saved.opacity or 0.42,0.1,0.9))
end

function UI:SavePosition(effectType)
    local panel=self:GetPanel(effectType).control
    local saved=self:GetSaved(effectType)
    local centerX,centerY=panel:GetCenter()
    local rootX,rootY=GuiRoot:GetCenter()
    if centerX and rootX then saved.offsetX=zo_round(centerX-rootX); saved.offsetY=zo_round(centerY-rootY) end
end

function UI:Nudge(effectType,dx,dy)
    local saved=self:GetSaved(effectType)
    saved.offsetX=zo_clamp((saved.offsetX or 0)+dx,-1600,1600)
    saved.offsetY=zo_clamp((saved.offsetY or 0)+dy,-900,900)
    self:ApplySettings(effectType)
end
function UI:ResetPosition(effectType)
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
    row.detail=CreateLabel(row.control,"$(BOLD_FONT)|17|thick-outline",{0.92,0.92,0.92,1})
    row.detail:SetAnchor(TOPLEFT,row.control,TOPLEFT,0,22)
    row.detail:SetAnchor(TOPRIGHT,row.control,TOPRIGHT,0,22)
    row.detail:SetHeight(18)
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

function UI:UpdateEffect(definition,state)
    self.states[definition.key]=state
end
function UI:ClearEffect(key)
    self.states[key]=nil
    for _,rows in pairs(self.rows) do if rows[key] then rows[key].control:SetHidden(true) end end
end

function UI:SetBarColor(row,percent,active)
    local r,g,b=0.88,0.12,0.10
    if active and percent>=60 then r,g,b=0.25,0.90,0.25 elseif active and percent>=25 then r,g,b=1,0.72,0.08 end
    row.bar:SetColor(r,g,b,0.96); row.status:SetColor(r,g,b,1)
end

function UI:RefreshPanel(effectType)
    local panel=self:GetPanel(effectType)
    local saved=self:GetSaved(effectType)
    if not BB.saved.enabled or saved.enabled==false then panel.control:SetHidden(true); return end
    local y=42; local count=0
    local definitions=effectType=="BUFF" and BB.Registry.buffs or BB.Registry.debuffs
    for _,definition in ipairs(definitions) do
        local row=self:EnsureRow(definition)
        if BB:IsEffectEnabled(definition.key) then
            local state=self.states[definition.key] or {active=false,remaining=0,percent=0,covered=0,target=BB:GetGroupTargetCount(),missingPlayers={}}
            row.control:ClearAnchors(); row.control:SetAnchor(TOPLEFT,panel.control,TOPLEFT,C.PANEL_PADDING,y); row.control:SetHidden(false)
            local detail=""
            if effectType=="BUFF" then
                if definition.coverage then detail="PLAYERS  "..tostring(state.covered or 0).."/"..tostring(state.target or BB:GetGroupTargetCount()) end
                if definition.showMissingPlayers and state.missingPlayers and #state.missingPlayers>0 then detail="MISSING: "..table.concat(state.missingPlayers,"  ") end
            else
                detail=state.targetName and state.targetName~="" and ("TARGET: "..tostring(state.targetName)) or "NO ACTIVE TARGET"
            end
            row.detail:SetText(detail)
            if effectType=="BUFF" then
                if definition.showMissingPlayers and state.missingPlayers and #state.missingPlayers>0 then
                    row.detail:SetColor(1.00,0.30,0.25,1)
                elseif definition.coverage then
                    row.detail:SetColor(0.35,0.88,1.00,1)
                else
                    row.detail:SetColor(0.82,0.82,0.82,1)
                end
            elseif state.targetName and state.targetName~="" then
                row.detail:SetColor(1.00,0.76,0.20,1)
            else
                row.detail:SetColor(0.72,0.72,0.72,1)
            end
            if definition.timer then row.status:SetText((state.remaining or 0)>0 and string.format("%.1fs",state.remaining) or "DOWN")
            elseif definition.coverage then row.status:SetText(tostring(state.covered or 0).."/"..tostring(state.target or 0)) else row.status:SetText(state.active and "ACTIVE" or "DOWN") end
            local percent=definition.timer and (state.percent or 0) or ((state.target or 0)>0 and ((state.covered or 0)/(state.target or 1))*100 or 0)
            row.bar:SetDimensions(math.max(1,C.BAR_WIDTH*zo_clamp(percent,0,100)/100),C.BAR_HEIGHT)
            self:SetBarColor(row,percent,state.active)
            y=y+C.ROW_HEIGHT; count=count+1
        else row.control:SetHidden(true) end
    end
    if count==0 then panel.control:SetHidden(true); return end
    panel.control:SetDimensions(C.PANEL_WIDTH,y+8)
    panel.control:SetHidden(false)
end

function UI:RefreshAll(force)
    self:RefreshPanel("BUFF"); self:RefreshPanel("DEBUFF")
end

function UI:Preview(effectType)
    local definitions=effectType=="BUFF" and BB.Registry.buffs or BB.Registry.debuffs
    local shown=0
    for _,definition in ipairs(definitions) do
        if BB:IsEffectEnabled(definition.key) and shown<4 then
            shown=shown+1
            self.states[definition.key]={active=true,remaining=15-shown*2,percent=85-shown*12,covered=math.max(1,BB:GetGroupTargetCount()-shown),target=BB:GetGroupTargetCount(),targetName=effectType=="DEBUFF" and "Trial Target" or nil,missingPlayers={"@example"}}
        end
    end
    self:RefreshPanel(effectType)
    zo_callLater(function()
        for _,definition in ipairs(definitions) do self.states[definition.key]=nil end
        self:RefreshPanel(effectType)
    end,5000)
end
