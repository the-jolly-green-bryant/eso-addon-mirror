-- Warden Mastery v1.0.1 TEST
-- Author: WifeyRytic
-- Lua-only UI. No XML.

WardenMastery = {}
local WM = WardenMastery

WM.name = "WardenMastery"
WM.version = "1.3"

-- Confirmed Warden Class Mastery passive ability IDs.
WM.MASTERY = {
    tundra   = 263519, -- Tundra's Maw
    wild     = 263520, -- Wild Adaptation
    glacial  = 263521, -- Glacial Obstinance
    green    = 263522, -- Green-Keeper's Hide
    bountiful= 263523, -- Bountiful Harvest
}

-- Confirmed mastery proc/effect IDs from PTS testing.
WM.ID = {
    tundraBrittle = 263825, -- Tundra's Maw Major Brittle application
    glacialBuff   = 267305, -- Glacial Obstinance 10s buff
    bountifulHero = 268257, -- Bountiful Harvest 3s Major Heroism application
}

-- ESO status-effect combat-event IDs.
-- These are tracked through EVENT_COMBAT_EVENT because several are not
-- reliably exposed as target buffs/debuffs by GetUnitBuffInfo.
WM.STATUS_BY_ID = {
    [18084]  = "Burning",
    [95136]  = "Chilled",
    [95134]  = "Concussed",
    [178118] = "Overcharged",
    [178123] = "Sundered",
    [21929]  = "Poisoned",
    [178127] = "Diseased",
    [148801] = "Hemorrhaging",
}

WM.pretty = {
    tundra    = "TUNDRA'S MAW",
    wild      = "WILD ADAPTATION",
    glacial   = "GLACIAL OBSTINANCE",
    green     = "GREEN-KEEPER'S HIDE",
    bountiful = "BOUNTIFUL HARVEST",
}

WM.order = {"tundra","wild","glacial","green","bountiful"}

WM.defaults = {
    enabled = true,
    hideOutOfCombat = false,
    locked = true,
    fontSize = 34,
    iconSize = 48,
    showIcons = true,

    inactiveColor = {1.00, 0.15, 0.15, 1},
    activeColor   = {0.15, 1.00, 0.25, 1},

    trackers = {
        tundra=true,
        wild=true,
        glacial=true,
        green=true,
        bountiful=true,
    },

    positions = {
        tundra    = {x=0,y=-160},
        wild      = {x=0,y=-80},
        glacial   = {x=0,y=0},
        green     = {x=0,y=80},
        bountiful = {x=0,y=160},
    },
}

WM.controls = {}
WM.fragments = {}
WM.selected = {}
WM.targets = {}
WM.nameToKey = {}

WM.state = {
    tundraEnd = 0,
    glacialEnd = 0,
    bountifulEnd = 0,
    wildTargetKey = nil,
    greenAttackerKey = nil,
}

local function Now()
    return GetFrameTimeSeconds()
end

local function Color(c)
    return c[1], c[2], c[3], c[4]
end

local function CleanName(name)
    if not name or name == "" then return "" end
    return zo_strformat(SI_UNIT_NAME, name)
end

local function NormalizedName(name)
    local n = CleanName(name)
    if n == "" then return "" end
    return zo_strlower(n)
end

local function IsEffectGainResult(result)
    return result == ACTION_RESULT_EFFECT_GAINED
        or result == ACTION_RESULT_EFFECT_GAINED_DURATION
        or result == ACTION_RESULT_EFFECT_UPDATED
end

local function IsEffectFadeResult(result)
    return result == ACTION_RESULT_EFFECT_FADED
end

local function IsIncomingDamageResult(result)
    return result == ACTION_RESULT_DAMAGE
        or result == ACTION_RESULT_CRITICAL_DAMAGE
        or result == ACTION_RESULT_DOT_TICK
        or result == ACTION_RESULT_DOT_TICK_CRITICAL
        or result == ACTION_RESULT_BLOCKED_DAMAGE
end

function WM:IsInCombat()
    return IsUnitInCombat("player")
end

function WM:IsHUDShowing()
    if IsUnitDead("player") then return false end
    if not HUD_SCENE or not HUD_UI_SCENE then return false end
    return HUD_SCENE:IsShowing() or HUD_UI_SCENE:IsShowing()
end

function WM:GetIcon(abilityId)
    local texture = GetAbilityIcon(abilityId)
    if texture and texture ~= "" then
        return texture
    end
    return "/esoui/art/icons/icon_missing.dds"
end

function WM:IsSelected(key)
    return self.selected[key] == true
end

function WM:CanDisplayNormal()
    if not self.sv.enabled then return false end
    if not self:IsHUDShowing() then return false end
    if self.sv.hideOutOfCombat and not self:IsInCombat() then return false end
    return true
end

function WM:ApplyPosition(key)
    local control = self.controls[key]
    if not control then return end
    local p = self.sv.positions[key]
    local size = self.sv.iconSize or self.defaults.iconSize
    local rowHeight = control:GetHeight() > 0 and control:GetHeight() or size
    control:ClearAnchors()
    -- Saved position is the icon center, so resizing never changes placement.
    control:SetAnchor(TOPLEFT, GuiRoot, CENTER, p.x-(size/2), p.y-(rowHeight/2))
end

function WM:AddHUDFragment(control)
    if not ZO_HUDFadeSceneFragment or not HUD_SCENE or not HUD_UI_SCENE then return end
    local fragment = ZO_HUDFadeSceneFragment:New(control, nil, 0)
    self.fragments[#self.fragments+1] = fragment
    HUD_SCENE:AddFragment(fragment)
    HUD_UI_SCENE:AddFragment(fragment)
end

function WM:SetIconState(key, active)
    local control = self.controls[key]
    if not control then return end
    control.icon:SetDesaturation(active and 0 or 1)
    if active then
        control.icon:SetColor(1,1,1,1)
    else
        control.icon:SetColor(.55,.55,.55,1)
    end
end

function WM:CreateTracker(key)
    local wm = WINDOW_MANAGER
    local control = wm:CreateTopLevelWindow("WardenMastery_" .. key)
    control:SetClampedToScreen(true)
    control:SetHidden(true)

    local bg = wm:CreateControl(nil, control, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0,0,0,0.55)
    bg:SetEdgeColor(1,1,1,0.55)
    bg:SetEdgeTexture("",1,1,1)
    bg:SetHidden(true)
    control.bg = bg

    local icon = wm:CreateControl(nil, control, CT_TEXTURE)
    icon:SetTexture(self:GetIcon(self.MASTERY[key]))
    control.icon = icon

    local countdown = wm:CreateControl(nil, control, CT_LABEL)
    countdown:SetAnchor(CENTER, icon, CENTER, 0, 0)
    countdown:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    countdown:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    control.countdown = countdown

    local label = wm:CreateControl(nil, control, CT_LABEL)
    label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    control.label = label

    control:SetHandler("OnMoveStop", function(c)
        local cx = c.icon:GetLeft() + c.icon:GetWidth()/2
        local cy = c.icon:GetTop() + c.icon:GetHeight()/2
        WM.sv.positions[key].x = cx - GuiRoot:GetWidth()/2
        WM.sv.positions[key].y = cy - GuiRoot:GetHeight()/2
        WM:ApplyPosition(key)
    end)

    self.controls[key] = control
    self:ApplyPosition(key)
    self:AddHUDFragment(control)
    self:SetIconState(key, false)
end

function WM:CreateUI()
    for _,key in ipairs(self.order) do self:CreateTracker(key) end
    self:ApplyLayout()
    self:SetLocked(self.sv.locked)
end

function WM:ApplyLayout()
    local size = self.sv.iconSize or self.defaults.iconSize
    local textSize = self.sv.fontSize or self.defaults.fontSize
    local gap = math.max(8, math.floor(size*.15))
    local textHeight = math.max(24, math.ceil(textSize*1.45))
    local rowHeight = math.max(size, textHeight)
    local textWidth = math.max(360, textSize*19)
    local font = string.format("$(BOLD_FONT)|%d|soft-shadow-thick", textSize)
    local countdownFont = string.format("$(BOLD_FONT)|%d|soft-shadow-thick", math.max(14,math.floor(size*.36)))

    for _,key in ipairs(self.order) do
        local control = self.controls[key]
        control:SetDimensions(size + gap + textWidth, rowHeight)
        control.icon:ClearAnchors()
        control.icon:SetAnchor(LEFT, control, LEFT, 0, 0)
        control.icon:SetDimensions(size,size)
        control.icon:SetHidden(not self.sv.showIcons)
        control.countdown:SetDimensions(size,size)
        control.countdown:SetFont(countdownFont)
        control.countdown:SetColor(1,1,1,1)
        control.label:ClearAnchors()
        if self.sv.showIcons then
            control.label:SetAnchor(LEFT, control.icon, RIGHT, gap, 0)
        else
            control.label:SetAnchor(LEFT, control, LEFT, 0, 0)
        end
        control.label:SetDimensions(textWidth,textHeight)
        control.label:SetFont(font)
        control.label:SetColor(1,1,1,1)
        self:ApplyPosition(key)
    end
end

function WM:ApplyFont()
    self:ApplyLayout()
end

function WM:ApplyIcons()
    self:ApplyLayout()
end

function WM:SetLocked(locked)
    self.sv.locked = locked

    for _,control in pairs(self.controls) do
        control:SetMouseEnabled(not locked)
        control:SetMovable(not locked)
        control.bg:SetHidden(locked)
    end

    self:Update()
end

function WM:ResetPositions()
    for key,p in pairs(self.defaults.positions) do
        self.sv.positions[key].x = p.x
        self.sv.positions[key].y = p.y
        self:ApplyPosition(key)
    end
end

function WM:HideAll()
    for _,control in pairs(self.controls) do
        control:SetHidden(true)
    end
end

function WM:SetDisplay(key, text, active, show, countdown)
    local control = self.controls[key]
    if not control then return end
    show = show and self.sv.enabled and self.sv.trackers[key]
    control:SetHidden(not show)
    if not show then return end
    control.label:SetText(text or self.pretty[key])
    control.countdown:SetText(countdown or "")
    self:SetIconState(key, active)
end

function WM:GetPreviewText(key)
    if key == "wild" then return self.pretty.wild .. " — +999", true end
    if key == "green" then return self.pretty.green .. " — 9%", true end
    return self.pretty[key], true
end

function WM:ApplyVisibleIconSpacing()
    if not self.sv.locked then return end
    local visible = {}
    for _,key in ipairs(self.order) do
        local c = self.controls[key]
        if c and not c:IsHidden() then
            visible[#visible+1] = {key=key, y=self.sv.positions[key].y}
        end
    end
    if #visible < 2 then
        if #visible == 1 then self:ApplyPosition(visible[1].key) end
        return
    end
    table.sort(visible, function(a,b) return a.y < b.y end)
    local minSep = math.max(self.sv.iconSize or self.defaults.iconSize,
                            math.ceil((self.sv.fontSize or self.defaults.fontSize)*1.45)) + 4
    local ys = {}
    for i,v in ipairs(visible) do ys[i]=v.y end
    for i=2,#ys do
        if ys[i]-ys[i-1] < minSep then ys[i]=ys[i-1]+minSep end
    end
    local oldCenter=(visible[1].y+visible[#visible].y)/2
    local newCenter=(ys[1]+ys[#ys])/2
    local shift=oldCenter-newCenter
    local size=self.sv.iconSize or self.defaults.iconSize
    for i,v in ipairs(visible) do
        local c=self.controls[v.key]
        local rowHeight=c:GetHeight()>0 and c:GetHeight() or size
        c:ClearAnchors()
        c:SetAnchor(TOPLEFT,GuiRoot,CENTER,
            self.sv.positions[v.key].x-(size/2),
            (ys[i]+shift)-(rowHeight/2))
    end
end

-- Selected mastery scan.
-- The game can swap Class Mastery choices without a skill-point event,
-- so this is intentionally polled every 500 ms.
function WM:ScanSelectedMasteries()
    local previous = self.selected or {}
    local found = {}

    if not GetNumSkillTypes or not GetNumSkillLines or not GetNumSkillAbilities then
        return false
    end

    for skillType = 1, GetNumSkillTypes() do
        for skillLineIndex = 1, GetNumSkillLines(skillType) do
            local abilityCount = GetNumSkillAbilities(skillType, skillLineIndex)

            for abilityIndex = 1, abilityCount do
                local okId, abilityId = pcall(
                    GetSkillAbilityId,
                    skillType,
                    skillLineIndex,
                    abilityIndex,
                    false
                )

                local okInfo, abilityName, icon, earnedRank, passive, ultimate, purchased =
                    pcall(
                        GetSkillAbilityInfo,
                        skillType,
                        skillLineIndex,
                        abilityIndex
                    )

                if okId and okInfo and purchased and abilityId then
                    for key,masteryId in pairs(self.MASTERY) do
                        if abilityId == masteryId then
                            found[key] = true
                        end
                    end
                end
            end
        end
    end

    local changed = false
    for key in pairs(self.MASTERY) do
        if (previous[key] == true) ~= (found[key] == true) then
            changed = true
            break
        end
    end

    self.selected = found

    if changed then
        if not found.tundra then
            self.state.tundraEnd = 0
        end
        if not found.wild then
            self.state.wildTargetKey = nil
        end
        if not found.glacial then
            self.state.glacialEnd = 0
        end
        if not found.green then
            self.state.greenAttackerKey = nil
        end
        if not found.bountiful then
            self.state.bountifulEnd = 0
        end

        self:RefreshTrackingEvents()
        self:Update()
    end

    return changed
end

-- Resolve the same combat target whether one event has a unit ID and another
-- only has a name. This keeps status buckets stable through ordinary combat.
function WM:GetTargetBucket(unitId, unitName)
    local clean = CleanName(unitName)
    local normalized = NormalizedName(unitName)

    local idKey = nil
    if unitId and unitId ~= 0 then
        idKey = "id:" .. tostring(unitId)
    end

    local nameKey = normalized ~= "" and ("name:" .. normalized) or nil
    local mappedKey = normalized ~= "" and self.nameToKey[normalized] or nil

    local key = idKey or mappedKey or nameKey
    if not key then return nil,nil end

    -- If an earlier name-only bucket exists and we now have a real unit ID,
    -- promote that bucket instead of losing its tracked statuses.
    if idKey and not self.targets[idKey] then
        local oldKey = mappedKey or nameKey
        if oldKey and self.targets[oldKey] then
            self.targets[idKey] = self.targets[oldKey]
            if oldKey ~= idKey then
                self.targets[oldKey] = nil
            end
        end
    end

    key = idKey or mappedKey or nameKey

    if not self.targets[key] then
        self.targets[key] = {
            name = clean,
            statuses = {},
        }
    end

    local bucket = self.targets[key]
    if clean ~= "" then
        bucket.name = clean
    end

    if normalized ~= "" then
        self.nameToKey[normalized] = key
    end

    return key,bucket
end

function WM:MarkStatus(bucket, statusName, durationMs, abilityId)
    local now = Now()
    local duration = tonumber(durationMs) or 0

    -- This is the exact behavior proven by the Wild Adaptation test build:
    -- use ESO's supplied duration when present; otherwise keep instantaneous
    -- status applications alive briefly so the mastery window is represented.
    local expires
    if duration > 50 and duration < 60000 then
        expires = now + duration/1000
    else
        expires = now + 0.75
    end

    local old = bucket.statuses[statusName]
    if not old or expires > (old.expires or 0) then
        bucket.statuses[statusName] = {
            expires = expires,
            abilityId = abilityId,
        }
    end
end

function WM:PruneAndCount(key)
    local bucket = key and self.targets[key]
    if not bucket then return 0 end

    local now = Now()
    local count = 0

    for statusName,data in pairs(bucket.statuses) do
        if not data.expires or data.expires <= now then
            bucket.statuses[statusName] = nil
        else
            count = count + 1
        end
    end

    return math.min(count, 5)
end

-- Outgoing status events power Wild Adaptation and also populate the status
-- buckets Green-Keeper's Hide consults for the enemy currently attacking us.
function WM:OnStatusCombatEvent(eventCode, result, isError, abilityName, abilityGraphic,
    abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue,
    powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)

    local statusName = self.STATUS_BY_ID[abilityId]
    if not statusName then return end

    local targetClean = CleanName(targetName)
    if targetClean == "" then return end

    local key,bucket = self:GetTargetBucket(targetUnitId, targetClean)
    if not key then return end

    if IsEffectFadeResult(result) then
        bucket.statuses[statusName] = nil
    elseif IsEffectGainResult(result) then
        self:MarkStatus(bucket, statusName, hitValue, abilityId)

        -- A genuine status application establishes the combat target for Wild.
        -- Merely moving the reticle never changes this.
        if self:IsSelected("wild") then
            self.state.wildTargetKey = key
        end
    end
end

-- Incoming damage establishes the attacker Green-Keeper's Hide should represent.
function WM:OnIncomingCombatEvent(eventCode, result, isError, abilityName, abilityGraphic,
    abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue,
    powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)

    if not self:IsSelected("green") then return end
    if not IsIncomingDamageResult(result) then return end

    local sourceClean = CleanName(sourceName)
    if sourceClean == "" then return end

    local key = self:GetTargetBucket(sourceUnitId, sourceClean)
    if key then
        self.state.greenAttackerKey = key
    end
end

function WM:OnTundraCombatEvent(eventCode, result, isError, abilityName, abilityGraphic,
    abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue,
    powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)

    if not self:IsSelected("tundra") then return end
    if abilityId ~= self.ID.tundraBrittle then return end

    if IsEffectGainResult(result) then
        local duration = tonumber(hitValue) or 0
        if duration > 50 and duration < 10000 then
            self.state.tundraEnd = Now() + duration/1000
        else
            self.state.tundraEnd = Now() + 2.0
        end
    end
end

function WM:OnBountifulCombatEvent(eventCode, result, isError, abilityName, abilityGraphic,
    abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue,
    powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)

    if not self:IsSelected("bountiful") then return end
    if abilityId ~= self.ID.bountifulHero then return end

    if IsEffectGainResult(result) then
        local duration = tonumber(hitValue) or 0
        if duration > 50 and duration < 10000 then
            self.state.bountifulEnd = Now() + duration/1000
        else
            self.state.bountifulEnd = Now() + 3.0
        end
    end
end

function WM:OnGlacialEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag,
    beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType,
    statusEffectType, unitName, unitId, abilityId, sourceType)

    if abilityId ~= self.ID.glacialBuff then return end
    if unitTag ~= "player" then return end
    if not self:IsSelected("glacial") then return end

    if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
        local now = Now()
        self.state.glacialEnd = (endTime and endTime > now) and endTime or (now + 10.0)
    elseif changeType == EFFECT_RESULT_FADED then
        self.state.glacialEnd = 0
    end
end

function WM:OnCombatState(eventCode, inCombat)
    if not inCombat then
        self.targets = {}
        self.nameToKey = {}
        self.state.wildTargetKey = nil
        self.state.greenAttackerKey = nil
        self.state.tundraEnd = 0
    end
    self:Update()
end

function WM:Update()
    if not self.sv or not self.controls.tundra then return end
    if not self.sv.enabled or not self:IsHUDShowing() then self:HideAll(); return end

    if not self.sv.locked then
        for _,key in ipairs(self.order) do
            local text,active = self:GetPreviewText(key)
            self:SetDisplay(key, text, active, true, (key=="glacial" and "10") or (key=="bountiful" and "3") or "")
        end
        return
    end

    local canShow = self:CanDisplayNormal()
    local now = Now()

    if self:IsSelected("tundra") then
        local active = self.state.tundraEnd > now
        self:SetDisplay("tundra", self.pretty.tundra, active, canShow, "")
    else self:SetDisplay("tundra", "", false, false) end

    if self:IsSelected("wild") then
        local count = self:PruneAndCount(self.state.wildTargetKey)
        local bonus = count * 333
        local active = count > 0
        local text = active and string.format("%s — +%d", self.pretty.wild, bonus) or self.pretty.wild
        self:SetDisplay("wild", text, active, canShow, "")
    else self:SetDisplay("wild", "", false, false) end

    if self:IsSelected("glacial") then
        local remaining = math.max(0, self.state.glacialEnd - now)
        local active = remaining > 0
        self:SetDisplay("glacial", self.pretty.glacial, active, canShow, active and tostring(math.ceil(remaining)) or "")
    else self:SetDisplay("glacial", "", false, false) end

    if self:IsSelected("green") then
        local count = self:PruneAndCount(self.state.greenAttackerKey)
        local reduction = count * 3
        local active = count > 0
        local text = active and string.format("%s — %d%%", self.pretty.green, reduction) or self.pretty.green
        self:SetDisplay("green", text, active, canShow, "")
    else self:SetDisplay("green", "", false, false) end

    if self:IsSelected("bountiful") then
        local remaining = math.max(0, self.state.bountifulEnd - now)
        local active = remaining > 0
        self:SetDisplay("bountiful", self.pretty.bountiful, active, canShow, active and tostring(math.ceil(remaining)) or "")
    else self:SetDisplay("bountiful", "", false, false) end

    self:ApplyVisibleIconSpacing()
end

local function UnregisterTrackingEvent(name, eventCode)
    EVENT_MANAGER:UnregisterForEvent(name, eventCode)
end

local function RegisterCombatByAbility(tag, abilityId, callback, sourcePlayer)
    local eventName = WM.name .. "_" .. tag
    EVENT_MANAGER:RegisterForEvent(eventName, EVENT_COMBAT_EVENT, callback)
    EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, abilityId)
    if sourcePlayer then
        EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT,
            REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
    end
end

function WM:IsTracked(key)
    return self.sv and self.sv.enabled and self.sv.trackers[key] and self:IsSelected(key)
end

function WM:RefreshTrackingEvents()
    if not self.sv then return end
    -- Production rule: mastery combat/effect listeners exist only while needed.
    for abilityId in pairs(self.STATUS_BY_ID) do
        UnregisterTrackingEvent(self.name.."_Status_"..tostring(abilityId), EVENT_COMBAT_EVENT)
    end
    UnregisterTrackingEvent(self.name.."_Tundra", EVENT_COMBAT_EVENT)
    UnregisterTrackingEvent(self.name.."_Bountiful", EVENT_COMBAT_EVENT)
    UnregisterTrackingEvent(self.name.."_Incoming", EVENT_COMBAT_EVENT)
    UnregisterTrackingEvent(self.name.."_Glacial", EVENT_EFFECT_CHANGED)

    if not self.sv.enabled then return end

    if self:IsTracked("wild") or self:IsTracked("green") then
        for abilityId in pairs(self.STATUS_BY_ID) do
            local id=abilityId
            RegisterCombatByAbility("Status_"..tostring(id), id,
                function(...) WM:OnStatusCombatEvent(...) end, true)
        end
    end
    if self:IsTracked("tundra") then
        RegisterCombatByAbility("Tundra", self.ID.tundraBrittle,
            function(...) WM:OnTundraCombatEvent(...) end, true)
    end
    if self:IsTracked("bountiful") then
        RegisterCombatByAbility("Bountiful", self.ID.bountifulHero,
            function(...) WM:OnBountifulCombatEvent(...) end, true)
    end
    if self:IsTracked("green") then
        local incomingEvent=self.name.."_Incoming"
        EVENT_MANAGER:RegisterForEvent(incomingEvent, EVENT_COMBAT_EVENT,
            function(...) WM:OnIncomingCombatEvent(...) end)
        EVENT_MANAGER:AddFilterForEvent(incomingEvent, EVENT_COMBAT_EVENT,
            REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
    end
    if self:IsTracked("glacial") then
        local glacialEvent=self.name.."_Glacial"
        EVENT_MANAGER:RegisterForEvent(glacialEvent, EVENT_EFFECT_CHANGED,
            function(...) WM:OnGlacialEffectChanged(...) end)
        EVENT_MANAGER:AddFilterForEvent(glacialEvent, EVENT_EFFECT_CHANGED,
            REGISTER_FILTER_ABILITY_ID, self.ID.glacialBuff)
        EVENT_MANAGER:AddFilterForEvent(glacialEvent, EVENT_EFFECT_CHANGED,
            REGISTER_FILTER_UNIT_TAG, "player")
    end
end

function WM:RegisterTracking()
    EVENT_MANAGER:RegisterForEvent(self.name.."_CombatState", EVENT_PLAYER_COMBAT_STATE,
        function(...) WM:OnCombatState(...) end)
    EVENT_MANAGER:RegisterForUpdate(self.name.."_Update",100,function() WM:Update() end)
    EVENT_MANAGER:RegisterForUpdate(self.name.."_MasteryRescan",500,function() WM:ScanSelectedMasteries() end)
    EVENT_MANAGER:RegisterForEvent(self.name.."_Activated",EVENT_PLAYER_ACTIVATED,function()
        zo_callLater(function() WM:ScanSelectedMasteries(); WM:RefreshTrackingEvents() end,500)
    end)
    if EVENT_SKILL_POINTS_CHANGED then
        EVENT_MANAGER:RegisterForEvent(self.name.."_SkillPoints",EVENT_SKILL_POINTS_CHANGED,function()
            zo_callLater(function() WM:ScanSelectedMasteries(); WM:RefreshTrackingEvents() end,250)
        end)
    end
    self:RefreshTrackingEvents()
end

function WM:CreateSettings()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local panelName = self.name .. "Options"

    LAM:RegisterAddonPanel(panelName, {
        type = "panel",
        name = "Warden Mastery",
        displayName = "Warden Mastery",
        author = "WifeyRytic",
        version = self.version,
        slashCommand = "/wmsettings",
        registerForRefresh = true,
        registerForDefaults = true,
    })

    local options = {
        {
            type="checkbox",
            name="ENABLE ADDON — FULL KILL SWITCH",
            tooltip="Turns all Warden Mastery tracking on or off.",
            getFunc=function() return WM.sv.enabled end,
            setFunc=function(v)
                WM.sv.enabled = v
                WM:RefreshTrackingEvents()
                if v then WM:Update() else WM:HideAll() end
            end,
            default=self.defaults.enabled,
            width="full",
        },
        {
            type="checkbox",
            name="Hide Out of Combat",
            getFunc=function() return WM.sv.hideOutOfCombat end,
            setFunc=function(v)
                WM.sv.hideOutOfCombat = v
                WM:Update()
            end,
            default=self.defaults.hideOutOfCombat,
        },
        {
            type="checkbox",
            name="Lock Position",
            tooltip="Turn OFF to unlock. Enabled trackers appear as previews so they can be moved.",
            getFunc=function() return WM.sv.locked end,
            setFunc=function(v) WM:SetLocked(v) end,
            default=self.defaults.locked,
        },
        {
            type="button",
            name="Reset Positions",
            func=function() WM:ResetPositions(); WM:Update() end,
        },
        {
            type="slider",
            name="Mastery Text Size",
            min=12,
            max=40,
            step=1,
            getFunc=function() return WM.sv.fontSize end,
            setFunc=function(v)
                WM.sv.fontSize = v
                WM:ApplyLayout()
                WM:Update()
            end,
            default=self.defaults.fontSize,
        },
        {
            type="slider",
            name="Icon Size",
            min=28,
            max=100,
            step=1,
            getFunc=function() return WM.sv.iconSize end,
            setFunc=function(v)
                WM.sv.iconSize = v
                WM:ApplyLayout()
                WM:Update()
            end,
            default=self.defaults.iconSize,
        },
        {
            type="checkbox",
            name="Show Mastery Icons",
            tooltip="Uses ESO's actual Class Mastery ability icons.",
            getFunc=function() return WM.sv.showIcons end,
            setFunc=function(v)
                WM.sv.showIcons = v
                WM:ApplyLayout()
                WM:Update()
            end,
            default=self.defaults.showIcons,
        },

        {type="header", name="Individual Mastery Trackers"},
    }

    local names = {
        tundra="Tundra's Maw",
        wild="Wild Adaptation",
        glacial="Glacial Obstinance",
        green="Green-Keeper's Hide",
        bountiful="Bountiful Harvest",
    }

    for _,key in ipairs(self.order) do
        local k = key
        table.insert(options, {
            type="checkbox",
            name=names[k],
            getFunc=function() return WM.sv.trackers[k] end,
            setFunc=function(v)
                WM.sv.trackers[k] = v
                if not v and WM.controls[k] then
                    WM.controls[k]:SetHidden(true)
                end
                WM:RefreshTrackingEvents()
                WM:Update()
            end,
            default=true,
            width="full",
        })
    end

    LAM:RegisterOptionControls(panelName, options)
end

function WM:RegisterSlashCommands()
    local function ShowSelected()
        self:ScanSelectedMasteries()
        local list = {}
        for _,key in ipairs(self.order) do
            if self:IsSelected(key) then
                table.insert(list, self.pretty[key])
            end
        end
        d("|c66FF99Warden Mastery selected:|r " .. (#list > 0 and table.concat(list, ", ") or "NONE"))
    end

    local function Slash(text)
        text = zo_strlower(zo_strtrim(text or ""))

        if text == "on" then
            WM.sv.enabled = true
            WM:RefreshTrackingEvents()
            WM:Update()
            d("|c66FF99Warden Mastery|r ON")
        elseif text == "off" then
            WM.sv.enabled = false
            WM:RefreshTrackingEvents()
            WM:HideAll()
            d("|c66FF99Warden Mastery|r OFF")
        elseif text == "unlock" then
            WM:SetLocked(false)
            d("|c66FF99Warden Mastery|r UNLOCKED")
        elseif text == "lock" then
            WM:SetLocked(true)
            d("|c66FF99Warden Mastery|r LOCKED")
        elseif text == "reset" then
            WM:ResetPositions()
            WM:Update()
            d("|c66FF99Warden Mastery|r positions reset")
        elseif text == "scan" then
            ShowSelected()
        else
            d("|c66FF99Warden Mastery:|r /wm on | off | unlock | lock | reset | scan")
        end
    end

    SLASH_COMMANDS["/wm"] = Slash
    SLASH_COMMANDS["/wardenmastery"] = Slash
end

function WM:Initialize()
    self.sv = ZO_SavedVars:NewAccountWide(
        "WardenMasterySavedVariables",
        1,
        nil,
        self.defaults
    )

    self.sv.iconSize = self.sv.iconSize or self.defaults.iconSize
    self.sv.fontSize = zo_clamp(self.sv.fontSize or self.defaults.fontSize, 12, 40)

    self:CreateUI()
    self:ScanSelectedMasteries()
    self:CreateSettings()
    self:RegisterTracking()
    self:RegisterSlashCommands()

    zo_callLater(function()
        WM:ScanSelectedMasteries()
        WM:Update()
    end, 750)

    d("|c66FF99Warden Mastery v1.0.1 TEST loaded.|r")
end

local function OnAddonLoaded(eventCode, addonName)
    if addonName ~= WM.name then return end
    EVENT_MANAGER:UnregisterForEvent(WM.name, EVENT_ADD_ON_LOADED)
    WM:Initialize()
end

EVENT_MANAGER:RegisterForEvent(WM.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
