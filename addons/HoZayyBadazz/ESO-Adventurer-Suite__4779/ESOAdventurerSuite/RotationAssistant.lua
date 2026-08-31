-- ESO Adventurer Suite
-- Combat Rotation Assistant
-- Safe UI-only combat guidance: it never casts abilities or sends input.

local EPC = ESOProgressionCoach
EPC.RotationAssistant = EPC.RotationAssistant or {}
local R = EPC.RotationAssistant
local WM = WINDOW_MANAGER

local function safe(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, a,b,c,d,e = pcall(fn, ...)
    if not ok then return fallback end
    if a == nil then return fallback end
    return a,b,c,d,e
end

local function now()
    return tonumber(safe(GetFrameTimeMilliseconds, 0)) or 0
end

local function lower(s) return string.lower(tostring(s or "")) end
local function contains(s, needle) return lower(s):find(lower(needle), 1, true) ~= nil end

function R:GetSlots()
    local firstBase = tonumber(ACTION_BAR_FIRST_NORMAL_SLOT_INDEX)
    local ultBase = tonumber(ACTION_BAR_ULTIMATE_SLOT_INDEX)
    local first = firstBase and (firstBase + 1) or 3
    local ult = ultBase and (ultBase + 1) or (first + 5)
    local slots = {}
    for i=0,4 do slots[#slots+1] = first+i end
    slots[#slots+1] = ult
    return slots
end

function R:GetCategory()
    return safe(GetActiveHotbarCategory, nil)
end

function R:GetBarAbilities()
    local cat = self:GetCategory()
    local out = {}
    for ordinal, slot in ipairs(self.slots) do
        local used = safe(IsSlotUsed, false, slot, cat) == true
        local name = safe(GetSlotName, "", slot, cat)
        local icon = safe(GetSlotTexture, "", slot, cat)
        local remain,duration,isGlobal = safe(GetSlotCooldownInfo, 0, slot, cat)
        local effect = safe(GetActionSlotEffectTimeRemaining, 0, slot, cat)
        out[#out+1] = {
            slot=slot, ordinal=ordinal, name=tostring(name or ""), icon=icon,
            used=used, remain=tonumber(remain) or 0, duration=tonumber(duration) or 0,
            global=isGlobal == true, effect=tonumber(effect) or 0,
            usable=safe(IsSlotUsable, true, slot, cat) ~= false,
        }
    end
    return out
end

function R:HasCrystalProc()
    if type(GetNumBuffs) ~= "function" or type(GetUnitBuffInfo) ~= "function" then return false end
    local count = tonumber(safe(GetNumBuffs, 0, "player")) or 0
    for i=1,count do
        local name = safe(GetUnitBuffInfo, "", "player", i)
        if contains(name, "crystal fragments") or contains(name, "crystal shard") then
            return true
        end
    end
    return false
end

function R:GetTargetHealth()
    if not safe(DoesUnitExist, false, "reticleover") then return 0 end
    local cur,max = safe(GetUnitPower, 0, "reticleover", POWERTYPE_HEALTH)
    cur,max = tonumber(cur) or 0, tonumber(max) or 0
    if max <= 0 then return 100 end
    return math.max(0, math.min(100, cur/max*100))
end

function R:IsSorc()
    local classId = tonumber(safe(GetUnitClassId, 0, "player")) or 0
    return classId == 2
end

function R:ScoreAbility(a, targetHP, proc)
    if not a.used or a.name == "" then return -1000, "Unavailable" end
    if not a.usable then return -500, "Not ready" end
    if a.remain > 0 and a.duration > 0 and not a.global then return -400, "Cooldown" end

    local n = lower(a.name)
    local score, reason = 10, "Use next"

    -- Proc is the highest-priority event.
    if proc and (contains(n,"crystal fragments") or contains(n,"crystal shard")) then
        return 1000, "PROC READY"
    end

    -- Sorcerer PvE priority. Timed effects get refreshed before the spammable.
    if self:IsSorc() then
        if contains(n,"daedric prey") or contains(n,"haunting curse") or contains(n,"daedric curse") then
            if a.effect <= 500 then return 900, "Debuff expired" end
            return 50, "Debuff active"
        end
        if contains(n,"unstable wall") or contains(n,"elemental blockade") or contains(n,"wall of elements") then
            if a.effect <= 500 then return 880, "Wall expired" end
            return 45, "Wall active"
        end
        if contains(n,"liquid lightning") or contains(n,"lightning flood") or contains(n,"lightning splash") then
            if a.effect <= 500 then return 870, "Ground DoT expired" end
            return 40, "Ground DoT active"
        end
        if contains(n,"hurricane") or contains(n,"boundless storm") or contains(n,"lightning form") then
            if a.effect <= 500 then return 850, "Buff expired" end
            return 35, "Buff active"
        end
        if contains(n,"critical surge") or contains(n,"power surge") then
            if a.effect <= 500 then return 840, "Buff expired" end
            return 30, "Buff active"
        end
        if contains(n,"volta") or contains(n,"twilight") or contains(n,"familiar") then
            if a.effect <= 500 then return 760, "Pet/buff needs attention" end
            return 25, "Pet active"
        end
        if contains(n,"storm atronach") or contains(n,"power overload") or contains(n,"overload") then
            local ultCurrent = tonumber((safe(GetUnitPower,0,"player",COMBAT_MECHANIC_FLAGS_ULTIMATE))) or 0
            -- GetSlotAbilityCost takes the action-bar slot and returns the
            -- actual cost of the slotted Ultimate. Do not use an arbitrary
            -- 2000/500 cap here: each Ultimate has its own cost.
            local ultCost = tonumber(safe(GetSlotAbilityCost,0,a.slot)) or 0
            if ultCost > 0 and ultCurrent >= ultCost and targetHP > 0 then
                return 820, string.format("Ultimate ready (%d%%)", math.min(100, math.floor((ultCurrent / ultCost) * 100 + 0.5)))
            end
            return 5, "Build ultimate"
        end
        if contains(n,"force pulse") or contains(n,"crushing shock") or contains(n,"force shock") then
            return 500, "Spammable"
        end
        if contains(n,"mage's wrath") or contains(n,"mages wrath") then
            if targetHP > 0 and targetHP <= 20 then return 780, "Execute" end
            return 20, "Execute"
        end
    end

    -- Generic fallback: prefer expiring effects, then usable abilities.
    if a.effect > 0 then score = score + math.min(300, a.effect/10) else score = score + 100 end
    return score, reason
end

function R:BuildRecommendations()
    local abilities = self:GetBarAbilities()
    local hp = self:GetTargetHealth()
    local proc = self:HasCrystalProc()
    local scored = {}
    for _,a in ipairs(abilities) do
        local score,reason = self:ScoreAbility(a,hp,proc)
        scored[#scored+1] = {a=a,score=score,reason=reason}
    end
    table.sort(scored,function(x,y) return x.score > y.score end)
    local result={}
    for i=1,math.min(3,#scored) do
        if scored[i].score > 0 then result[#result+1]=scored[i] end
    end
    return result, hp, proc
end

function R:CreateUI()
    if self.window then return end

    local s = EPC.saved or {}
    local baseW, baseH = 330, 112
    local w = tonumber(s.rotationAssistantWidth) or baseW
    local h = tonumber(s.rotationAssistantHeight) or baseH
    w = math.max(260, math.min(700, w))
    h = math.max(90, math.min(260, h))

    local window = WM:CreateTopLevelWindow("EAS_RotationAssistant")
    window:SetDimensions(w, h)
    if window.SetDimensionConstraints then
        window:SetDimensionConstraints(260, 90, 700, 260)
    end
    if window.SetResizeHandleSize then window:SetResizeHandleSize(20) end
    window:SetClampedToScreen(true)
    window:SetMouseEnabled(false)
    window:SetMovable(false)
    window:SetHidden(true)

    -- Match the other ESO Adventurer Suite HUD overlays:
    -- the common HUD layout button unlocks the frame for dragging/resizing.
    window:SetHandler("OnMoveStop", function(control)
        if EPC.saved then
            EPC.saved.rotationAssistantLeft = control:GetLeft()
            EPC.saved.rotationAssistantTop = control:GetTop()
        end
    end)

    window:SetHandler("OnResizeStart", function(control)
        self.resizing = true
        control:SetHandler("OnUpdate", function()
            self:UpdateScale()
        end)
    end)

    window:SetHandler("OnResizeStop", function(control)
        self.resizing = false
        control:SetHandler("OnUpdate", nil)
        local cw, ch = control:GetDimensions()
        cw = math.floor(math.max(260, math.min(700, tonumber(cw) or baseW)) + 0.5)
        ch = math.floor(math.max(90, math.min(260, tonumber(ch) or baseH)) + 0.5)
        control:SetDimensions(cw, ch)
        if EPC.saved then
            EPC.saved.rotationAssistantWidth = cw
            EPC.saved.rotationAssistantHeight = ch
        end
        self:UpdateScale()
    end)

    local canvas = WM:CreateControl("EAS_RotationAssistantCanvas", window, CT_CONTROL)
    canvas:SetDimensions(baseW, baseH)
    canvas:SetAnchor(CENTER, window, CENTER, 0, 0)
    self.canvas = canvas

    local bg=WM:CreateControl(nil,canvas,CT_BACKDROP)
    bg:SetAnchorFill(canvas)
    bg:SetCenterColor(0.015,0.018,0.028,0.94)
    bg:SetEdgeColor(0.95,0.68,0.20,0.9)
    bg:SetEdgeTexture(nil,1,1,1)

    local title=WM:CreateControl(nil,canvas,CT_LABEL)
    title:SetAnchor(TOPLEFT,canvas,TOPLEFT,10,6)
    title:SetDimensions(300,20)
    title:SetFont("$(BOLD_FONT)|16|soft-shadow-thick")
    title:SetColor(1,0.78,0.25,1)
    title:SetText("⚡ ROTATION ASSISTANT")

    local icon=WM:CreateControl(nil,canvas,CT_TEXTURE)
    icon:SetAnchor(TOPLEFT,canvas,TOPLEFT,10,30)
    icon:SetDimensions(58,58)

    local nextLabel=WM:CreateControl(nil,canvas,CT_LABEL)
    nextLabel:SetAnchor(TOPLEFT,canvas,TOPLEFT,78,31)
    nextLabel:SetDimensions(240,25)
    nextLabel:SetFont("$(BOLD_FONT)|21|soft-shadow-thick")
    nextLabel:SetColor(1,1,1,1)

    local reason=WM:CreateControl(nil,canvas,CT_LABEL)
    reason:SetAnchor(TOPLEFT,canvas,TOPLEFT,78,58)
    reason:SetDimensions(240,20)
    reason:SetFont("ZoFontGameSmall")
    reason:SetColor(0.95,0.80,0.35,1)

    local queue=WM:CreateControl(nil,canvas,CT_LABEL)
    queue:SetAnchor(TOPLEFT,canvas,TOPLEFT,78,79)
    queue:SetDimensions(240,20)
    queue:SetFont("ZoFontGameSmall")
    queue:SetColor(0.72,0.78,0.86,1)

    local hp=WM:CreateControl(nil,canvas,CT_LABEL)
    hp:SetAnchor(TOPRIGHT,canvas,TOPRIGHT,-8,7)
    hp:SetDimensions(70,18)
    hp:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    hp:SetFont("ZoFontGameSmall")
    hp:SetColor(0.80,0.90,1,1)

    self.window=window
    self.icon=icon
    self.nextLabel=nextLabel
    self.reason=reason
    self.queue=queue
    self.hp=hp

    local left=tonumber(EPC.saved.rotationAssistantLeft) or -1
    local top=tonumber(EPC.saved.rotationAssistantTop) or -1
    if left>=0 and top>=0 then
        window:SetAnchor(TOPLEFT,GuiRoot,TOPLEFT,left,top)
    else
        window:SetAnchor(TOPRIGHT,GuiRoot,TOPRIGHT,-35,240)
    end

    self:UpdateScale()
end

function R:UpdateScale()
    if not self.window or not self.canvas then return end
    local w,h = self.window:GetDimensions()
    local baseW,baseH = 330,112
    local scale = math.min((tonumber(w) or baseW)/baseW, (tonumber(h) or baseH)/baseH)
    scale = math.max(0.78, math.min(2.12, scale))
    self.canvas:SetScale(scale)
end

function R:Refresh()
    self:CreateUI()
    local enabled=EPC.saved and EPC.saved.rotationAssistantEnabled ~= false
    local combat=safe(IsUnitInCombat,false,"player")
    -- Only show while in combat, except while HUD layout mode is being used.
    local show=(enabled and combat) or self.layoutMode == true
    self.window:SetHidden(not show)
    if not show then return end

    local recs,hp,proc=self:BuildRecommendations()
    self.hp:SetText(hp > 0 and string.format("Target %.0f%%",hp) or "No target")
    if #recs==0 then
        self.icon:SetTexture("")
        self.nextLabel:SetText("NO ACTION")
        self.reason:SetText("Check your action bar")
        self.queue:SetText("")
        return
    end
    local first=recs[1]
    self.icon:SetTexture(first.a.icon or "")
    self.nextLabel:SetText(first.a.name)
    self.reason:SetText(first.reason)
    local q={}
    for i=2,#recs do q[#q+1]=recs[i].a.name end
    self.queue:SetText(#q>0 and ("Next: "..table.concat(q,"  →  ")) or "")
end

function R:SetLayoutMode(active)
    self.layoutMode = active == true
    if not self.window then self:CreateUI() end
    self.window:SetMouseEnabled(self.layoutMode)
    self.window:SetMovable(self.layoutMode)
    if self.window.SetResizeHandleSize then self.window:SetResizeHandleSize(self.layoutMode and 20 or 0) end
    self:Refresh()
end

function R:ResetPosition()
    if not self.window or not EPC.saved then return end
    EPC.saved.rotationAssistantLeft = -1
    EPC.saved.rotationAssistantTop = -1
    EPC.saved.rotationAssistantWidth = 330
    EPC.saved.rotationAssistantHeight = 112
    self.window:ClearAnchors()
    self.window:SetDimensions(330,112)
    self.window:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -35, 240)
    self:UpdateScale()
end

function R:Initialize()
    self.slots=self:GetSlots()
    self:CreateUI()
    local p=EPC.name.."_RotationAssistant"
    if EVENT_PLAYER_COMBAT_STATE then EVENT_MANAGER:RegisterForEvent(p.."_Combat",EVENT_PLAYER_COMBAT_STATE,function() self:Refresh() end) end
    if EVENT_ACTION_SLOT_UPDATED then EVENT_MANAGER:RegisterForEvent(p.."_Slot",EVENT_ACTION_SLOT_UPDATED,function() self:Refresh() end) end
    if EVENT_ACTIVE_WEAPON_PAIR_CHANGED then EVENT_MANAGER:RegisterForEvent(p.."_Bar",EVENT_ACTIVE_WEAPON_PAIR_CHANGED,function() self:Refresh() end) end
    if EVENT_PLAYER_ACTIVATED then EVENT_MANAGER:RegisterForEvent(p.."_Activated",EVENT_PLAYER_ACTIVATED,function() self:Refresh() end) end
    EVENT_MANAGER:RegisterForUpdate(p.."_Tick",100,function() self:Refresh() end)
    self:Refresh()
end

function R:SetEnabled(value)
    if EPC.saved then EPC.saved.rotationAssistantEnabled=value==true end
    self:Refresh()
end
