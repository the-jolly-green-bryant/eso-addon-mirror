local addonName = "CustomizableBars"
local isLocked = true 
local isGlobalEdit = false
local GlobalFrame = nil
local lastHealth = 0
local SV

local MATH_PI_4 = 0.785398 

-----------------------------------------------------------
-- LOCALIZATION
-----------------------------------------------------------
local Strings = {
    Locked = "|cFF0000Locked|r",
    Unlocked = "|c00FF00Individual Edit (Wheel=Width, Shift+W=Height, Alt+W=Alpha, Ctrl+W=Font)|r",
    GlobalOn = "|c00FF00Global Edit Enabled (Drag to Move Group, Mouse Wheel to Scale)|r",
    GlobalOff = "|cFF0000Global Edit Disabled and Saved|r"
}

local function CheckLanguage()
    local am = GetAddOnManager()
    for i = 1, am:GetNumAddOns() do
        local name, _, _, _, enabled = am:GetAddOnInfo(i)
        if name == "EsoBR" and enabled then
            Strings.Locked = "|cFF0000Trancado|r"
            Strings.Unlocked = "|c00FF00Editando Individual (Wheel=Largura, Shift+W=Altura, Alt+W=Alpha, Ctrl+W=Fonte)|r"
            Strings.GlobalOn = "|c00FF00Edição Global Ativada (Arraste p/ Mover o Grupo, Roda do Mouse p/ Escalonar)|r"
            Strings.GlobalOff = "|cFF0000Edição Global Desativada e Salva|r"
            break
        end
    end
end

-----------------------------------------------------------
-- ULTIMATE CONFIG
-----------------------------------------------------------
local ULT_PULSE_MIN_ALPHA = 0.7
local ULT_PULSE_MAX_ALPHA = 0.9
local ULT_PULSE_TIME = 3.0

local SkillToBuffMap = {
    ["dragon blood"] = {"major fortitude", "major endurance"},
    ["green dragon blood"] = {"major fortitude", "major endurance"},
    ["coagulating blood"] = {"major fortitude", "major endurance"},
    ["elder dragon blood"] = {"major fortitude", "major endurance", "minor endurance"},
    ["spiked armor"] = {"major resolve"},
    ["hardened armor"] = {"major resolve"},
    ["volatile armor"] = {"major resolve"},
    ["molten weapons"] = {"major brutality", "major sorcery"},
    ["igneous weapons"] = {"major brutality", "major sorcery"},
    ["obsidian shield"] = {"major mending", "igneous shield"},
    ["inferno"] = {"major prophecy", "major savagery"},
    ["bound armor"] = {"minor resolve", "bound armaments"},
    ["lightning flood"] = {"major expedition"},
    ["critical surge"] = {"major brutality", "major sorcery"},
    ["hurricane"] = {"major resolve", "minor expedition"},
    ["dark exchange"] = {"minor prophecy", "minor Intellect"},
    ["grim focus"] = {"assassin's focus"},
    ["relentless focus"] = {"assassin's focus"},
    ["shadow cloak"] = {"major prophecy", "major savagery"},
    ["blur"] = {"major evasion"},
    ["mark target"] = {"major breach"},
    ["drain power"] = {"major brutality", "major sorcery"},
    ["restoring focus"] = {"major resolve", "minor fortitude", "minor endurance", "minor intellect"},
    ["channeled focus"] = {"major resolve", "minor fortitude", "minor endurance", "minor intellect"},
    ["sun shield"] = {"major mending"},
    ["spear shards"] = {"minor prophecy", "minor savagery"},
    ["radial sweep"] = {"major protection"},
    ["frost cloak"] = {"major resolve"},
    ["ice fortress"] = {"major resolve", "minor protection"},
    ["bull netch"] = {"major brutality", "major sorcery"},
    ["blue betty"] = {"major brutality", "major sorcery"},
    ["falcon's swiftness"] = {"major expedition", "major endurance"},
    ["beckoning armor"] = {"major resolve"},
    ["spirit guardian"] = {"minor protection"},
    ["cruxweaver armor"] = {"major resolve", "minor breach"},
    ["inspired scholarship"] = {"major prophecy", "major savagery"},
    ["vigor"] = {"resolute", "echoing vigor"},
    ["momentum"] = {"major brutality", "major sorcery", "forward momentum"},
    ["trap beast"] = {"minor force"},
    ["accelerate"] = {"minor force", "major expedition"},
    ["inner light"] = {"major prophecy", "major savagery"},
    ["caltrops"] = {"major breach"},
    ["weakness to elements"] = {"major breach"},
}

-----------------------------------------------------------
-- EDIT SYSTEM & COMMANDS
-----------------------------------------------------------
local function SnapToGrid(value)
    local gridSize = 10 
    return math.floor((value / gridSize) + 0.5) * gridSize
end

local function SaveControlChanges(control, bypassGrid, explicitX, explicitY, explicitW, explicitH)
    local name = control:GetName()
    local oldData = SV[name] or {}
    
    local snappedLeft = explicitX or control:GetLeft()
    local snappedTop = explicitY or control:GetTop()
    local w = explicitW or control:GetWidth()
    local h = explicitH or control:GetHeight()
    
    if not bypassGrid then
        snappedLeft = SnapToGrid(snappedLeft)
        snappedTop = SnapToGrid(snappedTop)
        control:ClearAnchors()
        control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, snappedLeft, snappedTop)
    end

    SV[name] = {
        l = snappedLeft,
        t = snappedTop,
        w = w,
        h = h,
        a = oldData.a or control:GetAlpha(),
        r = control.rotation or oldData.r or 0,
        fs = oldData.fs or 1
    }
end

local function ResetBars()
    for k in pairs(SV) do
        SV[k] = nil
    end
    ReloadUI() 
end

local function UpdateTextScale(control)
    local name = control:GetName()
    local fs = (SV[name] and SV[name].fs) or 1

    if control.timer and control.timerRatio then
        control.timer:SetScale(control:GetWidth() * control.timerRatio * fs)
    end
    if control.ultPercent and control.ultRatio then
        control.ultPercent:SetScale(control:GetWidth() * control.ultRatio * fs)
    end
end

local UpdateBarFill 

local function OnMouseWheelAction(control, delta)
    if isLocked or isGlobalEdit then return end
    
    local name = control:GetName()
    if not SV[name] then 
        SV[name] = { 
            a = control:GetAlpha() or 1, 
            w = control:GetWidth(), 
            h = control:GetHeight(),
            r = control.rotation or 0,
            fs = 1
        }
    end

    local isShift = IsShiftKeyDown()
    local isControl = IsControlKeyDown()
    local isAlt = IsAltKeyDown()
    local step = (delta > 0) and 1 or -1
    
    if isControl and isShift then
        local currentRotation = SV[name].r or 0
        local rotationStep = MATH_PI_4 
        local newRotation = currentRotation + (step * rotationStep)
        
        control.rotation = newRotation
        SV[name].r = newRotation
        
        if control.icon then control.icon:SetTextureRotation(newRotation) end

    elseif isControl and not isShift and not isAlt then
        local currentFs = SV[name].fs or 1
        local newFs = currentFs + (step * 0.1)
        newFs = math.max(0.2, newFs) 
        SV[name].fs = newFs

    elseif isAlt then
        local currentAlpha = SV[name].a or control:GetAlpha()
        local newAlpha = currentAlpha + (step * 0.1)
        newAlpha = zo_clamp(newAlpha, 0.1, 1.0)
        newAlpha = math.floor(newAlpha * 10 + 0.5) / 10
        SV[name].a = newAlpha
        control:SetAlpha(newAlpha)

    else
        local isBar = control.fillTop ~= nil
        local isTracker = control.iconPool ~= nil 

        if isBar then
            if isShift then
                local h = control:GetHeight()
                control:SetHeight(math.max(4, h + (step * 2)))
            else
                local w = control:GetWidth()
                control:SetWidth(math.max(10, w + (step * 2)))
            end
            local newH = control:GetHeight()
            control.fillTop:SetHeight(newH / 2)
            control.fillBottom:SetHeight(newH / 2)
        elseif isTracker then
            if isShift then
                local h = control:GetHeight()
                control:SetHeight(math.max(16, h + (step * 2)))
            else
                local w = control:GetWidth()
                control:SetWidth(math.max(30, w + (step * 10)))
            end
        else
            local currentSize = control:GetWidth()
            local speedMultiplier = isShift and 4 or 2 
            local newSize = math.max(16, currentSize + (step * speedMultiplier))
            
            control:SetWidth(newSize)
            control:SetHeight(newSize)
        end
    end

    SaveControlChanges(control, false)

    if control.fillTop then
        UpdateBarFill(control, control.powerType)
    elseif not control.iconPool then
        UpdateTextScale(control)
    end
end

local function GetAllControlNames()
    local controls = {"NovaVida", "NovaMagicka", "NovaStamina", "NovaShield", "StaminaMontaria", "MBSL_Quickslot"}
    for i = 3, 8 do table.insert(controls, "MBSL_Slot"..i) end
    table.insert(controls, "PlayerBuffsUI")
    table.insert(controls, "TargetBuffsUI")
    return controls
end

local function ToggleLock()
    isLocked = not isLocked
    
    if isGlobalEdit and not isLocked then
        isGlobalEdit = false
        if GlobalFrame then GlobalFrame:SetHidden(true) end
    end

    local stateText = isLocked and Strings.Locked or Strings.Unlocked
    d("Customizable Bars: " .. stateText)

    local controls = GetAllControlNames()

    for _, name in ipairs(controls) do
        local ctrl = _G[name]
        if ctrl then
            ctrl:SetMovable(not isLocked)
            ctrl:SetMouseEnabled(not isLocked)
            if name == "StaminaMontaria" then ctrl:SetHidden(isLocked and not IsMounted()) end
            
            if ctrl.fillTop then UpdateBarFill(ctrl, ctrl.powerType) end
        end
    end
end

-----------------------------------------------------------
-- GLOBAL EDIT (/barrasall)
-----------------------------------------------------------
local function GetBoundingBox()
    local minX, minY = 999999, 999999
    local maxX, maxY = -999999, -999999
    for _, name in ipairs(GetAllControlNames()) do
        local s = SV[name]
        if s then
            if s.l < minX then minX = s.l end
            if s.t < minY then minY = s.t end
            if (s.l + s.w) > maxX then maxX = s.l + s.w end
            if (s.t + s.h) > maxY then maxY = s.t + s.h end
        end
    end
    if minX == 999999 then return 100, 100, 500, 200 end
    return minX - 10, minY - 10, (maxX - minX) + 20, (maxY - minY) + 20 
end

local function CreateGlobalFrame()
    local wm = WINDOW_MANAGER
    local frame = wm:CreateControl("CustomizableBarsGlobalFrame", GuiRoot, CT_TOPLEVELCONTROL)
    frame:SetDrawLayer(DL_OVERLAY)
    frame:SetDrawTier(DT_TOP)
    frame:SetMouseEnabled(true)
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    
    frame.bg = wm:CreateControl("CustomizableBarsGlobalFrameBG", frame, CT_BACKDROP)
    frame.bg:SetAnchorFill()
    frame.bg:SetCenterColor(0, 1, 0, 0.2)
    frame.bg:SetEdgeColor(0, 1, 0, 0.8)
    frame.bg:SetEdgeTexture("", 1, 1, 2)
    
    frame:SetHidden(true)
    frame.startX, frame.startY = 0, 0
    
    frame:SetHandler("OnMouseDown", function(self)
        self.startX = self:GetLeft()
        self.startY = self:GetTop()
    end)
    
    frame:SetHandler("OnMoveStop", function(self)
        local guiW, guiH = GuiRoot:GetDimensions()
        
        local minX, minY, maxX, maxY = 999999, 999999, -999999, -999999
        for _, name in ipairs(GetAllControlNames()) do
            local s = SV[name]
            if s then
                if s.l < minX then minX = s.l end
                if s.t < minY then minY = s.t end
                if (s.l + s.w) > maxX then maxX = s.l + s.w end
                if (s.t + s.h) > maxY then maxY = s.t + s.h end
            end
        end
        
        local rawDeltaX = self:GetLeft() - self.startX
        local rawDeltaY = self:GetTop() - self.startY
        
        local deltaX = math.max(-minX, math.min(rawDeltaX, guiW - maxX))
        local deltaY = math.max(-minY, math.min(rawDeltaY, guiH - maxY))
        
        for _, name in ipairs(GetAllControlNames()) do
            local ctrl = _G[name]
            local s = SV[name]
            if ctrl and s then
                local targetX = s.l + deltaX
                local targetY = s.t + deltaY
                
                ctrl:ClearAnchors()
                ctrl:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, targetX, targetY)
                SaveControlChanges(ctrl, true, targetX, targetY, s.w, s.h) 
            end
        end
        
        local bx, by, bw, bh = GetBoundingBox()
        self:ClearAnchors()
        self:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, bx, by)
    end)

    frame:SetHandler("OnMouseWheel", function(self, delta)
        local step = (delta > 0) and 1 or -1
        local scaleFactor = 1 + (step * 0.02) 
        
        local centerX = self:GetLeft() + (self:GetWidth() / 2)
        local centerY = self:GetTop() + (self:GetHeight() / 2)
        
        for _, name in ipairs(GetAllControlNames()) do
            local ctrl = _G[name]
            local s = SV[name]
            
            if ctrl and s then
                local relX = s.l - centerX
                local relY = s.t - centerY
                local newL = centerX + (relX * scaleFactor)
                local newT = centerY + (relY * scaleFactor)
                
                local newW = s.w * scaleFactor
                local newH = s.h * scaleFactor
                
                ctrl:ClearAnchors()
                ctrl:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, newL, newT)
                ctrl:SetDimensions(newW, newH)
                
                if ctrl.fillTop then
                    ctrl.fillTop:SetHeight(newH / 2)
                    ctrl.fillBottom:SetHeight(newH / 2)
                end
                
                SaveControlChanges(ctrl, true, newL, newT, newW, newH) 

                if ctrl.fillTop then
                    UpdateBarFill(ctrl, ctrl.powerType)
                elseif not ctrl.iconPool then
                    UpdateTextScale(ctrl)
                end
            end
        end
        
        local x, y, w, h = GetBoundingBox()
        self:ClearAnchors()
        self:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
        self:SetDimensions(w, h)
    end)

    return frame
end

local function ToggleGlobalLock()
    isGlobalEdit = not isGlobalEdit
    
    if not GlobalFrame then
        GlobalFrame = CreateGlobalFrame()
    end
    
    if isGlobalEdit then
        if not isLocked then ToggleLock() end 
        
        local x, y, w, h = GetBoundingBox()
        GlobalFrame:ClearAnchors()
        GlobalFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
        GlobalFrame:SetDimensions(w, h)
        GlobalFrame:SetHidden(false)
        
        if _G["StaminaMontaria"] then _G["StaminaMontaria"]:SetHidden(false) end
        
        d("Customizable Bars: " .. Strings.GlobalOn)
    else
        GlobalFrame:SetHidden(true)
        if _G["StaminaMontaria"] and not IsMounted() then _G["StaminaMontaria"]:SetHidden(true) end
        
        d("Customizable Bars: " .. Strings.GlobalOff)
    end

    for _, name in ipairs(GetAllControlNames()) do
        local ctrl = _G[name]
        if ctrl and ctrl.fillTop then UpdateBarFill(ctrl, ctrl.powerType) end
    end
end

-----------------------------------------------------------
-- ATTRIBUTE LOGIC
-----------------------------------------------------------
local function GetCurrentShield(unitTag)
    local shield = GetUnitAttributeVisualizerEffectInfo(unitTag, ATTRIBUTE_VISUAL_POWER_SHIELDING, STAT_MITIGATION, ATTRIBUTE_HEALTH, COMBAT_MECHANIC_FLAGS_HEALTH)
    return shield or 0
end

local function FlashHealthBar()
    local bar = _G["NovaVida"]
    if not bar then return end
    bar.fillBottom:SetCenterColor(1, 1, 1, 1)
    bar.fillTop:SetCenterColor(1, 1, 1, 1)
    zo_callLater(function() 
        bar.fillBottom:SetCenterColor(unpack(bar.colorMain))
        bar.fillTop:SetCenterColor(unpack(bar.colorLight))
    end, 100)
end

UpdateBarFill = function(bar, attr, eventCur, eventMax)
    if not bar or not bar.fillTop then return end
    local cur, max = 0, 1
    local barName = bar:GetName()
    local savedData = SV[barName]
    
    if attr == "SHIELD" then
        cur = GetCurrentShield("player")
        local _, _, effMax = GetUnitPower("player", POWERTYPE_HEALTH)
        max = (effMax and effMax > 0) and effMax or 1
        bar:SetHidden(false)
    else
        if eventCur and eventMax then
            cur = eventCur
            max = eventMax
        else
            local current, _, effMax = GetUnitPower("player", attr)
            cur = current
            max = effMax
        end
        if max == 0 or max == nil then max = 1 end
    end
    
    local isEditing = not isLocked or isGlobalEdit
    if isEditing then 
        cur = max 
        if attr == POWERTYPE_MOUNT_STAMINA then bar:SetHidden(false) end
    end

    bar:SetAlpha(savedData and savedData.a or 1)
    
    if attr == POWERTYPE_HEALTH then
        if cur < lastHealth and not isEditing then FlashHealthBar() end
        lastHealth = cur
    end
    
    if max > 0 then
        local pct = math.max(0, math.min(1, cur / max))
        local barWidth = bar:GetWidth()
        local newWidth = barWidth * pct
        bar.fillTop:SetWidth(newWidth)
        bar.fillBottom:SetWidth(newWidth)
    end
end

-----------------------------------------------------------
-- SKILLS & QUICKSLOT TRACKING
-----------------------------------------------------------
local function GetBuffDuration(slotId)
    local abilityId = GetSlotBoundId(slotId)
    if abilityId == 0 then return 0 end
    local slotName = GetAbilityName(abilityId):lower()
    local slotIcon = GetSlotTexture(slotId):lower()
    local mappedBuffs = SkillToBuffMap[slotName]
    
    local function CheckMatch(effectName, effectIcon, effectId)
        effectName, effectIcon = effectName:lower(), effectIcon:lower()
        if effectId == abilityId or effectIcon == slotIcon then return true end
        if mappedBuffs then
            for _, targetName in ipairs(mappedBuffs) do 
                if effectName == targetName:lower() then return true end 
            end
        end
        return effectName:find(slotName) or slotName:find(effectName)
    end

    local unitsToScan = {"player", "reticleover"}
    if GetGroupSize() > 0 then 
        for i = 1, GetGroupSize() do table.insert(unitsToScan, "group"..i) end 
    end

    local maxRemain = 0
    for _, unitTag in ipairs(unitsToScan) do
        for i = 1, GetNumBuffs(unitTag) do
            local bName, _, bFinish, _, _, bIcon, _, _, _, _, bId = GetUnitBuffInfo(unitTag, i)
            local remain = bFinish - GetFrameTimeSeconds()
            if remain > 0 and CheckMatch(bName, bIcon, bId) then 
                if remain > maxRemain then maxRemain = remain end 
            end
        end
    end
    return maxRemain
end

local function UpdateSkillStatus(control, slotId)
    local iconPath = GetSlotTexture(slotId)
    control.icon:SetTexture(iconPath)
    local durationLeft = GetBuffDuration(slotId)
    
    local savedData = SV[control:GetName()]
    local baseAlpha = (savedData and savedData.a) or 1
    local isEditing = not isLocked or isGlobalEdit

    if isEditing then
        control:SetAlpha(baseAlpha)
        control.timer:SetHidden(false)
        control.timer:SetText("9.9")
        control.timer:SetColor(1, 1, 1, 1)

        if slotId == 8 and control.ultPercent then
            control.ultPercent:SetText("100%")
            control.ultPercent:SetColor(1, 0.8, 0, 1)
            control.ultPercent:SetHidden(false)
        end
    else
        local isUltReady = false
        if slotId == 8 then
            local curU = GetUnitPower("player", POWERTYPE_ULTIMATE)
            local cost = GetSlotAbilityCost(slotId)
            local ultPct = (cost > 0) and (curU / cost) or 0
            isUltReady = ultPct >= 1

            if control.ultPercent then
                local ultText = isUltReady and "100%" or string.format("%d%%", math.floor(ultPct * 100))
                control.ultPercent:SetText(ultText)
                if isUltReady then 
                    control.ultPercent:SetColor(1, 0.8, 0, 1) 
                else 
                    control.ultPercent:SetColor(1, 1, 1, 1) 
                end
                
                control.ultPercent:SetHidden(durationLeft > 0)
            end
        end

        if durationLeft > 0 then
            control:SetAlpha(baseAlpha)
            control.timer:SetHidden(false)
            control.timer:SetText(durationLeft < 5 and string.format("%.1f", durationLeft) or string.format("%d", math.floor(durationLeft + 0.5)))
        else
            control.timer:SetHidden(true)
            
            if slotId == 8 and isUltReady then
                local cycle = (GetFrameTimeSeconds() % ULT_PULSE_TIME) / ULT_PULSE_TIME
                local pulse = (math.sin(cycle * math.pi * 2) + 1) / 2
                local newAlpha = ULT_PULSE_MIN_ALPHA + ((ULT_PULSE_MAX_ALPHA - ULT_PULSE_MIN_ALPHA) * pulse)
                control:SetAlpha(newAlpha)
            else
                control:SetAlpha(baseAlpha * 0.4)
            end
        end
    end

    local remainCD, durationCD = GetSlotCooldownInfo(slotId)
    control.cd:SetHidden(not (durationCD > 0 and remainCD > 0))
    if durationCD > 0 and remainCD > 0 then 
        control.cd:StartCooldown(remainCD, durationCD, CD_TYPE_VERTICAL, CD_TIME_TYPE_TIME_REMAINING, false) 
    end
end

local function UpdateQuickslotStatus(control)
    local quickslot = GetCurrentQuickslot()
    local savedData = SV[control:GetName()]
    local baseAlpha = (savedData and savedData.a) or 1
    local isEditing = not isLocked or isGlobalEdit

    if control.count then
        if isEditing then
            control.count:SetText("99")
            control.count:SetHidden(false)
        else
            local itemCount = GetSlotItemCount(quickslot, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
            if itemCount and itemCount > 0 then
                control.count:SetText(tostring(itemCount))
                control.count:SetHidden(false)
            else
                control.count:SetHidden(true)
            end
        end
    end

    if not quickslot or quickslot == 0 then
        control.icon:SetTexture("/esoui/art/icons/icon_missing.dds")
        if isEditing then
            control:SetAlpha(baseAlpha)
            control.timer:SetHidden(false)
            control.timer:SetText("9.9")
        else
            control:SetAlpha(baseAlpha * 0.4) 
            control.timer:SetHidden(true)
        end
        control.cd:SetHidden(true)
        return
    end

    local texture = GetSlotTexture(quickslot, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
    if texture and texture ~= "" then
        control.icon:SetTexture(texture)
    end

    if isEditing then
        control:SetAlpha(baseAlpha)
        control.timer:SetHidden(false)
        control.timer:SetText("9.9")
        control.timer:SetColor(1, 1, 1, 1)
    else
        local remain, duration = GetSlotCooldownInfo(quickslot, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)

        if remain and remain > 0 then
            control:SetAlpha(baseAlpha * 0.4) 
            control.cd:SetHidden(false)
            control.cd:StartCooldown(remain, duration, CD_TYPE_VERTICAL, CD_TIME_TYPE_TIME_REMAINING, false)
            
            local seconds = remain / 1000
            control.timer:SetHidden(false)
            control.timer:SetText(seconds > 10 and string.format("%d", seconds) or string.format("%.1f", seconds))

            if seconds < 3 then
                control.timer:SetColor(1, 0, 0, 1)
            else
                control.timer:SetColor(1, 1, 1, 1)
            end
        else
            control:SetAlpha(baseAlpha) 
            control.timer:SetText("")
            control.timer:SetHidden(true)
            control.cd:SetHidden(true)
        end
    end
end

-----------------------------------------------------------
-- INITIALIZATION & UI
-----------------------------------------------------------
local function SetupCommonHandlers(control)
    control:SetHandler("OnMoveStop", function(self) SaveControlChanges(self, false) end)
    control:SetHandler("OnMouseWheel", function(self, delta) OnMouseWheelAction(self, delta) end)
end

-----------------------------------------------------------
-- BUFFS & DEBUFFS TRACKER
-----------------------------------------------------------
local MAX_TRACKER_BUFFS = 20

local function CreateBuffTrackerUI(trackerName, defaultPos)
    local wm = WINDOW_MANAGER
    local frame = wm:CreateControl(trackerName, GuiRoot, CT_TOPLEVELCONTROL)
    frame:SetDrawLayer(DL_OVERLAY) 
    frame:SetDrawTier(DT_TOP)
    frame:SetClampedToScreen(true)
    frame:SetMouseEnabled(not isLocked) 
    frame:SetMovable(not isLocked)

    frame.bg = wm:CreateControl(trackerName.."BG", frame, CT_BACKDROP)
    frame.bg:SetAnchorFill()
    frame.bg:SetCenterColor(0, 1, 0, 0)
    frame.bg:SetEdgeColor(0, 1, 0, 0)

    if not SV[trackerName] then SV[trackerName] = defaultPos end
    local s = SV[trackerName]
    frame:ClearAnchors()
    frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, s.l, s.t)
    frame:SetDimensions(s.w, s.h)

    SetupCommonHandlers(frame)

    frame.iconPool = {}
    for i = 1, MAX_TRACKER_BUFFS do
        local iconName = trackerName .. "Icon" .. i
        local iconCtrl = wm:CreateControl(iconName, frame, CT_CONTROL)
        
        local tex = wm:CreateControl(iconName.."Tex", iconCtrl, CT_TEXTURE)
        tex:SetAnchorFill()
        iconCtrl.texture = tex

        local border = wm:CreateControl(iconName.."Border", iconCtrl, CT_BACKDROP)
        border:SetAnchorFill()
        border:SetCenterColor(0,0,0,0)
        border:SetEdgeTexture("", 1, 1, 2)
        iconCtrl.border = border

        local timer = wm:CreateControl(iconName.."Timer", iconCtrl, CT_LABEL)
        timer:SetAnchor(BOTTOM, iconCtrl, BOTTOM, 0, 2)
        timer:SetFont("ZoFontWinH5")
        timer:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        iconCtrl.timer = timer

        iconCtrl:SetHidden(true)
        table.insert(frame.iconPool, iconCtrl)
    end

    return frame
end

local function UpdateBuffTracker(frame, unitTag)
    if not frame then return end
    
    local iconSize = frame:GetHeight() 
    local padding = 4                  
    local isEditing = not isLocked or isGlobalEdit
    local savedData = SV[frame:GetName()]
    local baseAlpha = (savedData and savedData.a) or 1
    
    frame:SetAlpha(baseAlpha)

    local activeEffects = {}
    
    for i = 1, GetNumBuffs(unitTag) do
        local bName, _, bFinish, _, stackCount, bIcon, _, effectType = GetUnitBuffInfo(unitTag, i)
        local remain = bFinish - GetFrameTimeSeconds()
        
        if bIcon and bIcon ~= "" and (remain > 0 or bFinish == 0) then
            table.insert(activeEffects, {
                icon = bIcon,
                remain = remain,
                finish = bFinish,
                isDebuff = (effectType == BUFF_EFFECT_TYPE_DEBUFF)
            })
        end
    end

    if isEditing then
        frame.bg:SetCenterColor(0, 1, 0, 0.3) 
        frame.bg:SetEdgeColor(0, 1, 0, 0.8)
        if #activeEffects == 0 then
            local fitCount = math.floor(frame:GetWidth() / (iconSize + padding))
            for i = 1, math.max(1, fitCount) do
                table.insert(activeEffects, {
                    icon = "/esoui/art/icons/icon_missing.dds",
                    remain = 9.9, finish = 10, isDebuff = (i % 2 == 0) 
                })
            end
        end
    else
        frame.bg:SetCenterColor(0, 0, 0, 0)
        frame.bg:SetEdgeColor(0, 0, 0, 0)
    end

    for i, iconCtrl in ipairs(frame.iconPool) do
        local effect = activeEffects[i]
        
        local currentX = (i - 1) * (iconSize + padding)
        local canFit = currentX + iconSize <= frame:GetWidth()

        if effect and canFit then
            iconCtrl:SetHidden(false)
            iconCtrl:SetDimensions(iconSize, iconSize)
            iconCtrl:ClearAnchors()
            iconCtrl:SetAnchor(LEFT, frame, LEFT, currentX, 0)

            iconCtrl.texture:SetTexture(effect.icon)
            
            if effect.isDebuff then
                iconCtrl.border:SetEdgeColor(1, 0, 0, 1) 
            else
                iconCtrl.border:SetEdgeColor(0, 1, 0, 1) 
            end

            if effect.finish == 0 then
                iconCtrl.timer:SetText("")
            else
                iconCtrl.timer:SetText(effect.remain > 10 and string.format("%d", effect.remain) or string.format("%.1f", effect.remain))
            end
        else
            iconCtrl:SetHidden(true)
        end
    end
end

local function CreateIconBtn(slotId, name, defaultPos)
    local wm = WINDOW_MANAGER
    local btn = _G[name] or wm:CreateControl(name, GuiRoot, CT_TOPLEVELCONTROL)
    btn:SetDrawLayer(DL_OVERLAY) btn:SetDrawTier(DT_TOP)
    btn:SetClampedToScreen(true)
    btn:SetMouseEnabled(not isLocked) btn:SetMovable(not isLocked)
    
    btn.icon = btn.icon or wm:CreateControl(name.."Icon", btn, CT_TEXTURE)
    btn.icon:SetAnchorFill()
    btn.cd = btn.cd or wm:CreateControl(name.."CD", btn, CT_COOLDOWN)
    btn.cd:SetAnchorFill()
    btn.cd:SetFillColor(0, 0, 0, 0.6)
    btn.timer = btn.timer or wm:CreateControl(name.."Timer", btn, CT_LABEL)
    btn.timer:SetAnchor(CENTER, btn, CENTER, 0, 0)
    btn.timer:SetFont("ZoFontWinH1")

    local defaultScale = (name == "MBSL_Quickslot") and 1.2 or 1.5
    btn.timerRatio = defaultScale / defaultPos.w

    if slotId == 8 then
        btn.ultPercent = btn.ultPercent or wm:CreateControl(name.."UltPct", btn, CT_LABEL)
        btn.ultPercent:SetAnchor(CENTER, btn, CENTER, 0, 0)
        btn.ultPercent:SetFont("ZoFontWinH4")
        btn.ultRatio = 1.5 / defaultPos.w
    end

    if name == "MBSL_Quickslot" then
        btn.count = btn.count or wm:CreateControl(name.."Count", btn, CT_LABEL)
        btn.count:SetAnchor(BOTTOMRIGHT, btn, BOTTOMRIGHT, 2, -2) 
        btn.count:SetFont("ZoFontWinH5") 
        btn.count:SetColor(1, 1, 1, 1)
        btn.count:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    end

    if not SV[name] then SV[name] = defaultPos end
    local s = SV[name]
    btn:ClearAnchors()
    btn:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, s.l, s.t)
    btn:SetDimensions(s.w, s.h)
    btn:SetAlpha(s.a or 1)
    btn.rotation = s.r or 0
    btn.icon:SetTextureRotation(btn.rotation)

    SetupCommonHandlers(btn)
    UpdateTextScale(btn) 
end

local function CreateAttrBar(name, colorMain, colorLight, attr, defaultPos)
    local wm = WINDOW_MANAGER
    local bar = _G[name] or wm:CreateControl(name, GuiRoot, CT_TOPLEVELCONTROL)
    bar:SetDrawLayer(DL_OVERLAY) bar:SetDrawTier(DT_TOP)
    bar:SetClampedToScreen(true)
    bar:SetMouseEnabled(not isLocked) bar:SetMovable(not isLocked)
    
    bar.colorMain, bar.colorLight = colorMain, colorLight
    bar.powerType = attr 
    bar.bg = bar.bg or wm:CreateControl(name.."BG", bar, CT_BACKDROP)
    bar.bg:SetAnchorFill()
    bar.bg:SetCenterColor(0, 0, 0, 0.4)
    bar.bg:SetEdgeColor(0, 0, 0, 0)
    
    bar.fillBottom = bar.fillBottom or wm:CreateControl(name.."FillBottom", bar, CT_BACKDROP)
    bar.fillBottom:SetAnchor(BOTTOMLEFT, bar, BOTTOMLEFT, 0, 0)
    bar.fillBottom:SetCenterColor(unpack(colorMain))
    bar.fillBottom:SetEdgeColor(0,0,0,0)
    
    bar.fillTop = bar.fillTop or wm:CreateControl(name.."FillTop", bar, CT_BACKDROP)
    bar.fillTop:SetAnchor(TOPLEFT, bar, TOPLEFT, 0, 0)
    bar.fillTop:SetCenterColor(unpack(colorLight))
    bar.fillTop:SetEdgeColor(0,0,0,0)

    if not SV[name] then SV[name] = defaultPos end
    local s = SV[name]
    bar:ClearAnchors()
    bar:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, s.l, s.t)
    bar:SetDimensions(s.w, s.h)
    bar.fillTop:SetHeight(s.h / 2)
    bar.fillBottom:SetHeight(s.h / 2)
    bar:SetAlpha(s.a or 1)

    SetupCommonHandlers(bar)

    if attr == "SHIELD" then
        bar:RegisterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, function(_, unit) if unit == "player" then UpdateBarFill(bar, "SHIELD") end end)
        bar:RegisterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, function(_, unit) if unit == "player" then UpdateBarFill(bar, "SHIELD") end end)
        bar:RegisterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, function(_, unit) if unit == "player" then UpdateBarFill(bar, "SHIELD") end end)
    else
        bar:RegisterForEvent(EVENT_POWER_UPDATE, function(_, unit, _, pType, powerPool, powerPoolMax, powerEffectiveMax) 
            if unit == "player" and pType == attr then 
                UpdateBarFill(bar, attr, powerPool, powerEffectiveMax) 
            end 
        end)
    end
    
    if attr == POWERTYPE_MOUNT_STAMINA then
        bar:SetHidden(not IsMounted() and isLocked and not isGlobalEdit)
        bar:RegisterForEvent(EVENT_MOUNTED_STATE_CHANGED, function(_, mounted) 
            if isLocked and not isGlobalEdit then bar:SetHidden(not mounted) end 
        end)
    end

    UpdateBarFill(bar, attr)
end

local function OnLoaded(event, name)
    if name ~= addonName then return end

    EVENT_MANAGER:UnregisterForEvent(addonName, EVENT_ADD_ON_LOADED)

    SV = ZO_SavedVars:NewAccountWide("CustomizableBarsVars", 1, GetWorldName(), {})

    CheckLanguage()
    
    SLASH_COMMANDS["/barras"] = ToggleLock
    SLASH_COMMANDS["/barrasreset"] = ResetBars 
    SLASH_COMMANDS["/barrasall"] = ToggleGlobalLock

    local function Hide(c) if c then c:SetHidden(true) c:SetAlpha(0) end end
    
    Hide(ZO_PlayerAttributeHealth) 
    Hide(ZO_PlayerAttributeMagicka) 
    Hide(ZO_PlayerAttributeStamina)
    Hide(ZO_PlayerAttributeMountStamina)
    
    if ZO_ActionBar1 then ZO_ActionBar1:SetAlpha(0) end

    CreateAttrBar("NovaVida", {0.35, 0, 0, 1}, {0.9, 0, 0, 1}, POWERTYPE_HEALTH, {["w"] = 430.4961547852, ["h"] = 6.3775634766, ["fs"] = 1, ["r"] = 0, ["l"] = 72.5866203308, ["a"] = 0.7, ["t"] = 1046.8382568359})
    CreateAttrBar("NovaMagicka", {0, 0.05, 0.4, 1}, {0, 0.4, 1, 1}, POWERTYPE_MAGICKA, {["w"] = 273.6256713867, ["h"] = 6.3775634766, ["fs"] = 1, ["r"] = 0, ["l"] = 72.5866203308, ["a"] = 0.6, ["t"] = 1054.0760498047})
    CreateAttrBar("NovaStamina", {0.5, 0.4, 0, 1}, {0.98, 0.93, 0.25, 1}, POWERTYPE_STAMINA, {["w"] = 149.8764953613, ["h"] = 6.2310791016, ["fs"] = 1, ["r"] = 0, ["l"] = 347.6297874451, ["a"] = 0.5, ["t"] = 1054.0760498047})
    CreateAttrBar("NovaShield", {0, 0.6, 0.6, 1}, {0, 1, 1, 1}, "SHIELD", {["w"] = 433.1859741211, ["h"] = 6.3778076172, ["fs"] = 1, ["r"] = 0, ["l"] = 72.5866203308, ["a"] = 0.7, ["t"] = 1039.6002197266})
    CreateAttrBar("StaminaMontaria", {0.4, 0.2, 0, 1}, {1, 0.6, 0, 1}, POWERTYPE_MOUNT_STAMINA, {["w"] = 149.8764953613, ["h"] = 6.3774414062, ["fs"] = 1, ["r"] = 0, ["l"] = 347.6297874451, ["a"] = 0.5, ["t"] = 1061.3144531250})

    local cfgSkills = {
        ["MBSL_Slot8"]     = {["w"] = 47.8329238892, ["h"] = 47.8327636719, ["fs"] = 0.9, ["r"] = 0.785398, ["l"] = 10, ["a"] = 1, ["t"] = 1011.8568115234}, 
        ["MBSL_Slot3"]     = {["w"] = 25.5109176636, ["h"] = 25.5108032227, ["fs"] = 0.5, ["r"] = 0.785398, ["l"] = 73.7772178650, ["a"] = 1, ["t"] = 1003.8847045898},
        ["MBSL_Slot4"]     = {["w"] = 25.5109329224, ["h"] = 25.5107421875, ["fs"] = 0.5, ["r"] = 0.785398, ["l"] = 97.6936607361, ["a"] = 1, ["t"] = 979.9683227539},
        ["MBSL_Slot5"]     = {["w"] = 25.5109100342, ["h"] = 25.5108032227, ["fs"] = 0.5, ["r"] = 0.785398, ["l"] = 121.6101341248, ["a"] = 1, ["t"] = 1003.8847045898},
        ["MBSL_Slot6"]     = {["w"] = 25.5108795166, ["h"] = 25.5107421875, ["fs"] = 0.5, ["r"] = 0.785398, ["l"] = 145.5265617371, ["a"] = 1, ["t"] = 979.9683227539},
        ["MBSL_Slot7"]     = {["w"] = 25.5109100342, ["h"] = 25.5108032227, ["fs"] = 0.6, ["r"] = 0.785398, ["l"] = 169.4430351257, ["a"] = 1, ["t"] = 1003.8847045898},
        ["MBSL_Quickslot"] = {["w"] = 30.4995422363, ["h"] = 30.4996337891, ["fs"] = 0.8, ["r"] = 0, ["l"] = 509.7406272888, ["a"] = 0.8, ["t"] = 1037.9775390625}, 
    }

    for i = 3, 8 do 
        CreateIconBtn(i, "MBSL_Slot"..i, cfgSkills["MBSL_Slot"..i]) 
    end
    CreateIconBtn("Quickslot", "MBSL_Quickslot", cfgSkills["MBSL_Quickslot"])

    CreateBuffTrackerUI("PlayerBuffsUI", {["w"] = 419.8025512695, ["h"] = 24.6091918945, ["fs"] = 1, ["r"] = 0, ["l"] = 212.9834556580, ["a"] = 0.6, ["t"] = 1009.0255737305})
    CreateBuffTrackerUI("TargetBuffsUI", {["w"] = 361.8985595703, ["h"] = 23.1617431641, ["fs"] = 1, ["r"] = 0, ["l"] = 550.2930564880, ["a"] = 1, ["t"] = 1046.8382568359})

    EVENT_MANAGER:RegisterForUpdate(addonName, 100, function()
        for i = 3, 8 do
            local btn = _G["MBSL_Slot"..i]
            if btn then UpdateSkillStatus(btn, i) end
        end
        
        local quickBtn = _G["MBSL_Quickslot"]
        if quickBtn then UpdateQuickslotStatus(quickBtn) end

        UpdateBuffTracker(_G["PlayerBuffsUI"], "player")
        UpdateBuffTracker(_G["TargetBuffsUI"], "reticleover") 
    end)
end

EVENT_MANAGER:RegisterForEvent(addonName, EVENT_ADD_ON_LOADED, OnLoaded)