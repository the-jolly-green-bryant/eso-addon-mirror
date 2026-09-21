------------------------------------------------------------
-- RYTIC ACTION BAR v0.7 - follow ESO native action bar lifecycle
-- Classic two-row action bar for RyticTankTools.
------------------------------------------------------------
RyticTank = RyticTank or {}
RyticTank.ActionBar = RyticTank.ActionBar or {}
local A=RyticTank.ActionBar
local EM,WM=EVENT_MANAGER,WINDOW_MANAGER

local FIRST,LAST=3,7
local UPDATE_NAME="RyticActionBarUpdate"
local function now() return GetFrameTimeSeconds() end

local function defaults()
    RyticTank.saved=RyticTank.saved or {}
    RyticTank.saved.actionBar=RyticTank.saved.actionBar or {
        enabled=true, scale=0.85, x=12, y=-665, showKeys=true, unlocked=false
    }
    return RyticTank.saved.actionBar
end

local function slotId(slot,bar)
    local id=GetSlotBoundId(slot,bar)
    if GetSlotType(slot,bar)==ACTION_TYPE_CRAFTED_ABILITY and GetAbilityIdForCraftedAbilityId then
        id=GetAbilityIdForCraftedAbilityId(id)
    end
    return id or 0
end

-- Defensive buff warning.
local MAJOR_RESOLVE_EFFECT_ID=61694

local function hasMajorResolve()
    local n=GetNumBuffs and GetNumBuffs("player") or 0
    for i=1,n do
        local _,_,ending,_,_,_,_,_,_,_,abilityId=GetUnitBuffInfo("player",i)
        if abilityId==MAJOR_RESOLVE_EFFECT_ID and (not ending or ending==0 or ending>GetFrameTimeSeconds()) then
            return true
        end
    end
    return false
end

local function majorResolveRemaining()
    local now=GetFrameTimeSeconds()
    for i=1,GetNumBuffs("player") do
        local name,startTime,endTime,_,_,_,_,_,_,_,abilityId=GetUnitBuffInfo("player",i)
        if abilityId==61694 or (name and zo_strformat("<<z:1>>",name):find("major resolve",1,true)) then
            return math.max(0,(tonumber(endTime) or now)-now)
        end
    end
    return 0
end

A.resolveSlots={}

local function learnResolveSlot(slot,bar,id)
    -- Disabled: timer matching can falsely classify unrelated DPS skills.
    -- Resolve highlighting is only allowed for a slot already explicitly known
    -- during this session; no guessing from coincident effect durations.
    return
end

local function slotIsResolveSource(slot,bar,id)
    local key=tostring(bar)..":"..tostring(slot)
    return A.resolveSlots[key]==id
end

local function makeText(parent,font,anchor,rel,relpt,x,y)
    local l=WM:CreateControl(nil,parent,CT_LABEL)
    l:SetFont(font); l:SetAnchor(anchor,parent,relpt or anchor,x or 0,y or 0)
    l:SetDrawLayer(DL_OVERLAY); l:SetDrawTier(DT_HIGH)
    return l
end

local function makeSlot(parent,index)
    local c=WM:CreateControl(nil,parent,CT_BACKDROP)
    c:SetDimensions(50,50); c:SetCenterColor(.015,.02,.025,.88); c:SetEdgeColor(0,0,0,0)
    c.icon=WM:CreateControl(nil,c,CT_TEXTURE); c.icon:SetAnchorFill(); c.icon:SetTextureCoords(0.06,.94,0.06,.94)
    c.border=WM:CreateControl(nil,c,CT_BACKDROP)
    c.border:SetAnchor(TOPLEFT,c,TOPLEFT,1,1); c.border:SetAnchor(BOTTOMRIGHT,c,BOTTOMRIGHT,-1,-1)
    c.border:SetCenterColor(0,0,0,0); c.border:SetEdgeColor(1,1,1,1)
    c.border:SetEdgeTexture("",1,1,3,0)
    c.border:SetDrawLayer(DL_OVERLAY); c.border:SetMouseEnabled(false)
    c.resolveGlow=WM:CreateControl(nil,c,CT_BACKDROP)
    c.resolveGlow:SetAnchor(TOPLEFT,c,TOPLEFT,-4,-4)
    c.resolveGlow:SetAnchor(BOTTOMRIGHT,c,BOTTOMRIGHT,4,4)
    c.resolveGlow:SetCenterColor(0,0,0,0)
    c.resolveGlow:SetEdgeTexture("",1,1,5,0)
    c.resolveGlow:SetDrawLayer(DL_OVERLAY); c.resolveGlow:SetDrawTier(DT_HIGH)
    c.resolveGlow:SetMouseEnabled(false); c.resolveGlow:SetHidden(true)
    c.shade=WM:CreateControl(nil,c,CT_BACKDROP); c.shade:SetAnchorFill(); c.shade:SetCenterColor(0,0,0,0); c.shade:SetEdgeColor(0,0,0,0)
    c.timer=makeText(c,"ZoFontWinH3",CENTER,c,CENTER,0,0); c.timer:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    c.stack=makeText(c,"ZoFontGameBold",TOPRIGHT,c,TOPRIGHT,-3,2); c.stack:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    c.key=makeText(c,"ZoFontGameSmall",BOTTOM,c,BOTTOM,0,-1); c.key:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    c.index=index
    return c
end

-- Rytic replaces the visual action bar, but ESO's native controls still own
-- protected combat/keybind behavior. Hide the native artwork without disabling it.
local nativeHiddenControls={}
local function rememberAndHide(c,hidden)
    if not c then return end
    if hidden then
        if nativeHiddenControls[c]==nil then nativeHiddenControls[c]=c:GetAlpha() end
        c:SetAlpha(0)
    else
        c:SetAlpha(nativeHiddenControls[c] or 1)
        nativeHiddenControls[c]=nil
    end
end

local function setNativeBarHidden(hidden)
    -- Keep ZO_ActionBar1 itself alive: ESO's keybind/quickslot wheel logic depends on it.
    -- Hide the visual children while leaving the protected root enabled.
    if ZO_ActionBar1 then
        local n=ZO_ActionBar1:GetNumChildren()
        for i=1,n do
            local c=ZO_ActionBar1:GetChild(i)
            if c then rememberAndHide(c,hidden) end
        end
    end
    rememberAndHide(ZO_ActionBar1WeaponSwap,hidden)
    rememberAndHide(ZO_ActionBar1UltimateSlot,hidden)
    rememberAndHide(ZO_ActionBar1Quickslot,hidden)
end

-- Keep ESO's resurrection/death prompt away from the custom action bar.
-- The exact native control name varies by UI revision, so locate the visible
-- top-level death/revive UI by inspecting control names while the player is dead.
local rezMoved={}
local rezAlertBoxes={}

local function ensureRezAlertBox(root)
    if not root or rezAlertBoxes[root] then return end
    local box=WM:CreateControl(nil,root,CT_BACKDROP)
    box:SetAnchor(TOPLEFT,root,TOPLEFT,-14,-12)
    box:SetAnchor(BOTTOMRIGHT,root,BOTTOMRIGHT,14,12)
    box:SetCenterColor(0.12,0,0,0.16)
    box:SetEdgeTexture("",1,1,5,0)
    box:SetEdgeColor(1,0.02,0.02,1)
    box:SetDrawLayer(DL_BACKGROUND)
    box:SetDrawTier(DT_HIGH)
    box:SetDrawLevel(1)
    box:SetMouseEnabled(false)
    rezAlertBoxes[root]=box
end

local function nameLooksLikeRez(name)
    if not name or name=="" then return false end
    local n=string.lower(name)
    -- Death Recap is a separate ESO UI and must never be moved/covered.
    if n:find("recap",1,true) then return false end
    return n:find("resur",1,true)
        or n:find("revive",1,true)
        or n:find("death",1,true)
end

local function moveRezRoot(c)
    if not c or c==A.root then return end
    local root=c
    -- Move the highest useful named parent so the whole prompt (Revive / key /
    -- Here / Recap) travels together rather than moving one label.
    for _=1,6 do
        local p=root.GetParent and root:GetParent() or nil
        if not p or p==GuiRoot then break end
        local pn=p.GetName and p:GetName() or ""
        if pn and pn~="" and nameLooksLikeRez(pn) then root=p else break end
    end
    if not rezMoved[root] then
        rezMoved[root]=true
    end
    if root.SetDrawTier then root:SetDrawTier(DT_HIGH) end
    if root.SetDrawLayer then root:SetDrawLayer(DL_OVERLAY) end
    if root.SetDrawLevel then root:SetDrawLevel(100) end
    if root.ClearAnchors and root.SetAnchor then
        root:ClearAnchors()
        root:SetAnchor(CENTER,GuiRoot,CENTER,0,35)
    end
    ensureRezAlertBox(root)
end

local function scanRezControls(c,depth)
    if not c or depth>8 then return end
    local name=c.GetName and c:GetName() or ""
    if nameLooksLikeRez(name) and (not c.IsHidden or not c:IsHidden()) then
        moveRezRoot(c)
    end
    if c.GetNumChildren and c.GetChild then
        local n=c:GetNumChildren() or 0
        for i=1,n do scanRezControls(c:GetChild(i),depth+1) end
    end
end

local wasDead=false
local function keepRezAboveBar()
    -- Intentionally empty. ESO owns its native death/rez UI.
end


local function alertPulse()
    -- Smooth bright pulse, roughly twice per second.
    local t=GetFrameTimeSeconds()
    return .45 + .55 * ((math.sin(t * 7.5) + 1) * .5)
end


local function potionAlertActive()
    local sv=RyticTank and RyticTank.saved and RyticTank.saved.resources
    if not sv then return false end

    local getPct=RyticTank.Resources and RyticTank.Resources.GetPercent
    if type(getPct)~="function" then return false end

    local base=tonumber(sv.potionThreshold) or 30
    local hpLimit=tonumber(sv.potionHealthThreshold) or base
    local resourceLimit=tonumber(sv.potionResourceThreshold) or base

    return getPct(POWERTYPE_HEALTH)<=hpLimit
        or getPct(POWERTYPE_STAMINA)<=resourceLimit
        or getPct(POWERTYPE_MAGICKA)<=resourceLimit
end

local function refreshQuickslot(btn)
    if not btn or not btn.icon then return end

    local icon=""
    local count=0
    local activeIndex = GetCurrentQuickslot and GetCurrentQuickslot() or nil

    if activeIndex then
        icon = GetSlotTexture(activeIndex, HOTBAR_CATEGORY_QUICKSLOT_WHEEL) or ""
        if icon=="" and GetSlotItemLink then
            local link=GetSlotItemLink(activeIndex,HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
            if link and link~="" and GetItemLinkIcon then icon=GetItemLinkIcon(link) or "" end
        end
        if GetSlotItemCount then count=GetSlotItemCount(activeIndex,HOTBAR_CATEGORY_QUICKSLOT_WHEEL) or 0 end
    end

    if icon~="" then
        btn.icon:SetTexture(icon)
        btn.icon:SetAlpha(1)
    else
        btn.icon:SetTexture("/esoui/art/actionbar/quickslotbg.dds")
        btn.icon:SetAlpha(.65)
    end
    if btn.count then
        btn.count:SetText(tostring(count))
        btn.count:SetHidden(false)
    end

    local remaining=0
    if GetSlotCooldownInfo and activeIndex then
        -- ESO returns remaining cooldown in milliseconds for the quickslot.
        local remain=select(1,GetSlotCooldownInfo(activeIndex,HOTBAR_CATEGORY_QUICKSLOT_WHEEL))
        remaining=tonumber(remain) or 0
    end

    local remainingSeconds=remaining/1000

    -- Ignore ESO's short global/action cooldown on the quickslot.
    -- Only treat a cooldown longer than 2 seconds as the actual potion cooldown.
    local potionCooldown = remainingSeconds>2 and remainingSeconds or 0

    if btn.timer then
        if potionCooldown>0 then
            btn.timer:SetText(potionCooldown<10 and string.format("%.1f",potionCooldown) or tostring(math.ceil(potionCooldown)))
        else
            btn.timer:SetText("")
        end
    end

    btn.icon:SetDesaturation(potionCooldown>0 and .55 or 0)
    btn.icon:SetAlpha(potionCooldown>0 and .60 or (icon~="" and 1 or .65))

    -- Dedicated top-layer potion alert. Nothing else in the action-bar refresh
    -- can overwrite this overlay.
    local alert=potionAlertActive()
    local p=alertPulse()

    -- Drive the normal visible quickslot frame directly.
    if btn.border then
        if alert then
            btn.border:SetEdgeColor(.72 + (.28*p), .02, 1, 1)
        else
            btn.border:SetEdgeColor(1,1,1,1)
        end
    end

    -- Keep the existing overlay as a second purple layer when present.
    if btn.potionAlertBorder then
        btn.potionAlertBorder:SetHidden(not alert)
        if alert then
            btn.potionAlertBorder:SetEdgeColor(.72 + (.28*p), .02, 1, 1)
        end
    end
    if btn.potionReadyGlow then
        btn.potionReadyGlow:SetHidden(not alert)
        if alert then
            btn.potionReadyGlow:SetEdgeColor(.72 + (.28*p), .02, 1, .55 + (.45*p))
        end
    end
end

function A.Create()
    if A.root then return end
    local sv=defaults()
    local root=WM:CreateTopLevelWindow("RyticActionBarRoot"); A.root=root
    -- ESOUI HUD fragment: automatically hide this HUD when menus open.
    local hudFragment=ZO_HUDFadeSceneFragment:New(root,nil,0)
    HUD_SCENE:AddFragment(hudFragment)
    HUD_UI_SCENE:AddFragment(hudFragment)
    A.hudFragment=hudFragment
    root:SetDimensions(430,112)
    root:ClearAnchors()
    if sv.left ~= nil and sv.top ~= nil then
        -- Absolute screen coordinates survive reloads regardless of anchor type.
        root:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sv.left, sv.top)
    else
        -- First-run fallback only. Once moved, left/top become authoritative.
        root:SetAnchor(BOTTOM, GuiRoot, BOTTOM, sv.x or 12, sv.y or -665)
    end
    root:SetScale(sv.scale or 0.85); root:SetMouseEnabled(true); root:SetMovable(true); root:SetClampedToScreen(true)
    root:SetHandler("OnMouseDown",function(self,button) if button==MOUSE_BUTTON_INDEX_LEFT and defaults().unlocked then self:StartMoving() end end)
    root:SetHandler("OnMouseUp",function(self,button)
        if button==MOUSE_BUTTON_INDEX_LEFT and defaults().unlocked then
            self:StopMovingOrResizing()
            local d=defaults()
            d.left=self:GetLeft()
            d.top=self:GetTop()
        end
    end)
    root:SetHandler("OnMoveStop",function(self)
        local d=defaults()
        d.left=self:GetLeft()
        d.top=self:GetTop()
    end)

    A.front={}; A.back={}
    for i=FIRST,LAST do
        local n=i-FIRST
        local f=makeSlot(root,i); f:SetAnchor(TOPLEFT,root,TOPLEFT,n*54,0); A.front[i]=f
        local b=makeSlot(root,i); b:SetAnchor(TOPLEFT,root,TOPLEFT,n*54,56); A.back[i]=b
    end

    -- Ultimate: deliberately larger and separated from the five normal skills.
    A.ult=makeSlot(root,8)
    A.ult:SetDimensions(66,66)
    A.ult:SetAnchor(LEFT,A.front[LAST],RIGHT,18,28)
    A.ult.border:SetEdgeTexture("",1,1,4,0)

    -- Second outer frame used only when the ultimate is ready.
    A.ult.readyGlow=WM:CreateControl(nil,A.ult,CT_BACKDROP)
    A.ult.readyGlow:SetAnchor(TOPLEFT,A.ult,TOPLEFT,-4,-4)
    A.ult.readyGlow:SetAnchor(BOTTOMRIGHT,A.ult,BOTTOMRIGHT,4,4)
    A.ult.readyGlow:SetCenterColor(0,0,0,0)
    A.ult.readyGlow:SetEdgeTexture("",1,1,5,0)
    A.ult.readyGlow:SetDrawLayer(DL_OVERLAY)
    A.ult.readyGlow:SetDrawTier(DT_HIGH)
    A.ult.readyGlow:SetMouseEnabled(false)
    A.ult.readyGlow:SetHidden(true)

    A.quick=makeSlot(root,9); A.quick:SetDimensions(48,48); A.quick:SetAnchor(RIGHT,A.front[FIRST],LEFT,-12,28)
    -- Equipped quickslot consumable quantity.
    A.quick.count=makeText(A.quick,"ZoFontWinH3",TOPRIGHT,A.quick,TOPRIGHT,-2,1)
    A.quick.count:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    A.quick.count:SetDrawLayer(DL_OVERLAY)
    A.quick.count:SetDrawTier(DT_HIGH)
    A.quick.count:SetText("0")
    A.quick.potionAlertBorder=WM:CreateControl(nil,A.quick,CT_BACKDROP)
    A.quick.potionAlertBorder:SetAnchor(TOPLEFT,A.quick,TOPLEFT,1,1)
    A.quick.potionAlertBorder:SetAnchor(BOTTOMRIGHT,A.quick,BOTTOMRIGHT,-1,-1)
    A.quick.potionAlertBorder:SetCenterColor(0,0,0,0)
    A.quick.potionAlertBorder:SetEdgeTexture("",1,1,4,0)
    A.quick.potionAlertBorder:SetDrawLayer(DL_OVERLAY)
    A.quick.potionAlertBorder:SetDrawTier(DT_HIGH)
    A.quick.potionAlertBorder:SetMouseEnabled(false)
    A.quick.potionAlertBorder:SetHidden(true)

    A.quick.potionReadyGlow=WM:CreateControl(nil,A.quick,CT_BACKDROP)
    A.quick.potionReadyGlow:SetAnchor(TOPLEFT,A.quick,TOPLEFT,-4,-4)
    A.quick.potionReadyGlow:SetAnchor(BOTTOMRIGHT,A.quick,BOTTOMRIGHT,4,4)
    A.quick.potionReadyGlow:SetCenterColor(0,0,0,0)
    A.quick.potionReadyGlow:SetEdgeTexture("",1,1,5,0)
    A.quick.potionReadyGlow:SetDrawLayer(DL_OVERLAY)
    A.quick.potionReadyGlow:SetDrawTier(DT_HIGH)
    A.quick.potionReadyGlow:SetMouseEnabled(false)
    A.quick.potionReadyGlow:SetHidden(true)

    A.quick:SetMouseEnabled(true)
    A.quick:SetHandler("OnMouseDown",function(_,button)
        if button==MOUSE_BUTTON_INDEX_LEFT and ZO_ActionBar_OnActionButtonDown then
            ZO_ActionBar_OnActionButtonDown(9)
        end
    end)
    A.quick:SetHandler("OnMouseUp",function(_,button)
        if button==MOUSE_BUTTON_INDEX_LEFT and ZO_ActionBar_OnActionButtonUp then
            ZO_ActionBar_OnActionButtonUp(9)
        end
    end)
    root:SetHidden(not sv.enabled)
    setNativeBarHidden(sv.enabled)
end

local function updateButton(btn,slot,bar,isActive)
    local id=slotId(slot,bar)
    if id==0 then
        btn.icon:SetTexture(""); btn.timer:SetText(""); btn.stack:SetText("")
        if btn.resolveGlow then btn.resolveGlow:SetHidden(true) end
        return
    end
    local icon=GetAbilityIcon(id)
    btn.icon:SetTexture(icon or "")
    -- Dim the skills on the weapon bar that is NOT currently equipped.
    -- This affects only the icon, not the white/blue/red border state.
    btn.icon:SetDesaturation(isActive and 0 or .72)
    btn.icon:SetAlpha(isActive and 1 or .42)

    local remain=0
    if GetActionSlotEffectTimeRemaining then
        remain=(GetActionSlotEffectTimeRemaining(slot,bar) or 0)/1000
    end

    learnResolveSlot(slot,bar,id)

    local r,g,b=1,1,1
    local resolveMissing=slotIsResolveSource(slot,bar,id) and not hasMajorResolve()
    if resolveMissing then
        local p=alertPulse()
        r,g,b=1, .04 + (.28*p), .04 + (.28*p)
        if btn.resolveGlow then
            btn.resolveGlow:SetHidden(false)
            btn.resolveGlow:SetEdgeColor(1,.02,.02,.55 + (.45*p))
        end
    elseif remain>0 then
        r,g,b=.08,.55,1
        if btn.resolveGlow then btn.resolveGlow:SetHidden(true) end
    else
        if btn.resolveGlow then btn.resolveGlow:SetHidden(true) end
    end
    if btn.border then btn.border:SetEdgeColor(r,g,b,1) else btn:SetEdgeColor(r,g,b,1) end
    if remain>0 then
        btn.timer:SetText(remain<10 and string.format("%.1f",remain) or tostring(math.ceil(remain)))
    else btn.timer:SetText("") end

    local stacks=0
    if GetActionSlotEffectStackCount then stacks=GetActionSlotEffectStackCount(slot,bar) or 0 end
    btn.stack:SetText(stacks>1 and tostring(stacks) or "")
    btn.key:SetText(defaults().showKeys and tostring(slot-FIRST+1) or "")
end

function A.Update()
    if not defaults().enabled then
        setCustomBarVisible(false)
        setNativeBarHidden(false)
        return
    end

    if not A.root or A.root:IsHidden() then return end
    setNativeBarHidden(true)
    keepRezAboveBar()
    local active=GetActiveHotbarCategory()
    local frontCat=HOTBAR_CATEGORY_PRIMARY
    local backCat=HOTBAR_CATEGORY_BACKUP
    for i=FIRST,LAST do
        updateButton(A.front[i],i,frontCat,active==frontCat)
        updateButton(A.back[i],i,backCat,active==backCat)
    end

    -- Ultimate follows the active weapon bar.
    local ultId=slotId(8,active)
    if ultId~=0 then
        A.ult.icon:SetTexture(GetAbilityIcon(ultId) or "")
        local cur=GetUnitPower("player",POWERTYPE_ULTIMATE) or 0
        local cost=GetAbilityCost(ultId) or 0
        A.ult.timer:SetText(cost>0 and tostring(cur).."/"..tostring(cost) or tostring(cur))
        local ready=(cost>0 and cur>=cost)
        if A.ult.border then
            if ready then
                local p=alertPulse()
                A.ult.border:SetEdgeColor(1,.55 + (.45*p),.02,1)
            else
                A.ult.border:SetEdgeColor(1,1,1,1)
            end
        end
        if A.ult.readyGlow then
            A.ult.readyGlow:SetHidden(not ready)
            if ready then
                local p=alertPulse()
                A.ult.readyGlow:SetEdgeColor(1,.35 + (.65*p),.02,.70 + (.30*p))
            end
        end
        A.ult.key:SetText("R")
    end

    -- Current ESO quickslot wheel is hotbar category QUICKslot, slot 1.
    refreshQuickslot(A.quick)
end

function A.SetUnlocked(v)
    local sv=defaults()
    sv.unlocked=v and true or false
    if A.root then
        A.root:SetMovable(true)
        A.root:SetMouseEnabled(true)
    end
end
function A.SetScale(v) local sv=defaults(); sv.scale=tonumber(v) or 1; if A.root then A.root:SetScale(sv.scale) end end

local function setCustomBarVisible(show)
    if A.root then
        A.root:SetHidden(not show)
        A.root:SetMouseEnabled(show)
        A.root:SetAlpha(show and 1 or 0)
    end
    -- Defensive hide/show for child controls in case another UI handler changed
    -- their visibility independently of the root.
    local groups={A.front,A.back}
    for _,g in ipairs(groups) do
        if g then
            for _,c in pairs(g) do
                if c and c.SetHidden then c:SetHidden(not show) end
            end
        end
    end
    if A.quick and A.quick.SetHidden then A.quick:SetHidden(not show) end
    if A.ultimate and A.ultimate.SetHidden then A.ultimate:SetHidden(not show) end
    if A.ult and A.ult.SetHidden then A.ult:SetHidden(not show) end
    if A.ultimateButton and A.ultimateButton.SetHidden then A.ultimateButton:SetHidden(not show) end
    if A.ultButton and A.ultButton.SetHidden then A.ultButton:SetHidden(not show) end
end

local function hookNativeActionBarLifecycle()
    if A._nativeLifecycleHooked or not ZO_ActionBar1 then return end
    A._nativeLifecycleHooked=true

    -- Follow ESO's EFFECTIVE visibility, not IsUnitDead().  This catches the
    -- actual action-bar lifecycle used by ESO during death/rez and scene changes.
    ZO_PreHookHandler(ZO_ActionBar1,"OnEffectivelyHidden",function()
        if defaults().enabled then
            setCustomBarVisible(false)
        end
    end)

    ZO_PreHookHandler(ZO_ActionBar1,"OnEffectivelyShown",function()
        if defaults().enabled then
            setCustomBarVisible(true)
            setNativeBarHidden(true)
            if A.quick then refreshQuickslot(A.quick) end
        end
    end)
end

local function registerRuntime()
    hookNativeActionBarLifecycle()
    EM:RegisterForUpdate(UPDATE_NAME,100,A.Update)
    if EVENT_ACTIVE_QUICKSLOT_CHANGED then
        EM:RegisterForEvent("RyticActionBarActiveQuickslot",EVENT_ACTIVE_QUICKSLOT_CHANGED,function()
            if A.quick then refreshQuickslot(A.quick) end
        end)
    end
    if EVENT_HOTBAR_SLOT_UPDATED then
        EM:RegisterForEvent("RyticActionBarQuickslot",EVENT_HOTBAR_SLOT_UPDATED,function(_,slot,hotbarCategory)
            if hotbarCategory==HOTBAR_CATEGORY_QUICKSLOT_WHEEL and A.quick then refreshQuickslot(A.quick) end
        end)
    end
end

local function unregisterRuntime()
    EM:UnregisterForUpdate(UPDATE_NAME)
    EM:UnregisterForEvent("RyticActionBarActiveQuickslot",EVENT_ACTIVE_QUICKSLOT_CHANGED)
    EM:UnregisterForEvent("RyticActionBarQuickslot",EVENT_HOTBAR_SLOT_UPDATED)
end

function A.SetEnabled(enabled)
    local sv=defaults()
    sv.enabled=enabled and true or false

    if sv.enabled then
        setCustomBarVisible(true)
        setNativeBarHidden(true)
        unregisterRuntime()
        registerRuntime()
        A.Update()
    else
        unregisterRuntime()
        wasDead=false
        setCustomBarVisible(false)
        -- Restore the native ESO action bar and stop touching it while disabled.
        setNativeBarHidden(false)
    end
end

function A.Toggle()
    local sv=defaults(); A.SetEnabled(not sv.enabled)
    d("|c49BFFFRyticActionBar:|r "..(sv.enabled and "ON" or "OFF"))
end

function A.Initialize()
    A.Create()
    SLASH_COMMANDS["/ryticbar"]=A.Toggle

    -- A.Create establishes initial visibility. Runtime callbacks only exist
    -- while the custom bar is actually enabled.
    unregisterRuntime()
    if defaults().enabled then
        registerRuntime()
        A.Update()
    else
        setNativeBarHidden(false)
        setCustomBarVisible(false)
    end
end


EM:RegisterForEvent("RyticActionBarBootstrap",EVENT_ADD_ON_LOADED,function(_,addonName)
    if addonName~="RyticTankTools" then return end
    EM:UnregisterForEvent("RyticActionBarBootstrap",EVENT_ADD_ON_LOADED)
    A.Initialize()
end)
