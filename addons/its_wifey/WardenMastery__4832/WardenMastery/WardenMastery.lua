-- Warden Mastery v1.0
-- Author: WifeyRytic
-- Lua-only UI. No XML.

WardenMastery = {}
local WM = WardenMastery

WM.name = "WardenMastery"
WM.version = "1.0"

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

function WM:IsMenuOpen()
    if not SCENE_MANAGER or not SCENE_MANAGER.GetCurrentScene then
        return false
    end

    local scene = SCENE_MANAGER:GetCurrentScene()
    if not scene or not scene.GetName then
        return false
    end

    local name = scene:GetName()
    -- Only the normal gameplay HUD scenes are allowed to show trackers.
    -- Inventory, map, character, skills, group, settings, game menu, etc.
    -- all use other scenes and therefore hide every tracker.
    return name ~= "hud" and name ~= "hudui"
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
    if self:IsMenuOpen() then return false end
    if self.sv.hideOutOfCombat and not self:IsInCombat() then return false end
    return true
end

function WM:ApplyPosition(key)
    local control = self.controls[key]
    if not control then return end

    local p = self.sv.positions[key]
    control:ClearAnchors()
    control:SetAnchor(CENTER, GuiRoot, CENTER, p.x, p.y)
end

function WM:CreateTracker(key)
    local wm = WINDOW_MANAGER

    local control = wm:CreateTopLevelWindow("WardenMastery_" .. key)
    control:SetDimensions(760, 66)
    control:SetClampedToScreen(true)
    control:SetDrawTier(DT_HIGH)
    control:SetDrawLayer(DL_OVERLAY)
    control:SetHidden(true)

    local bg = wm:CreateControl(nil, control, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0,0,0,0.55)
    bg:SetEdgeColor(1,1,1,0.55)
    bg:SetEdgeTexture("",1,1,1)
    bg:SetHidden(true)
    control.bg = bg

    local icon = wm:CreateControl(nil, control, CT_TEXTURE)
    icon:SetDimensions(48,48)
    icon:SetAnchor(LEFT, control, LEFT, 8, 0)
    icon:SetTexture(self:GetIcon(self.MASTERY[key]))
    control.icon = icon

    local label = wm:CreateControl(nil, control, CT_LABEL)
    label:SetAnchor(LEFT, icon, RIGHT, 12, 0)
    label:SetAnchor(RIGHT, control, RIGHT, -8, 0)
    label:SetHeight(64)
    label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    control.label = label

    control:SetHandler("OnMoveStop", function(c)
        local cx = c:GetLeft() + c:GetWidth()/2
        local cy = c:GetTop() + c:GetHeight()/2
        WM.sv.positions[key].x = cx - GuiRoot:GetWidth()/2
        WM.sv.positions[key].y = cy - GuiRoot:GetHeight()/2
        WM:ApplyPosition(key)
    end)

    self.controls[key] = control
    self:ApplyPosition(key)

    -- HUD scene fragments make the tracker automatically disappear while
    -- inventory/map/character/settings/etc. scenes are open, and return on HUD.
    if ZO_HUDFadeSceneFragment and HUD_SCENE then
        local fragment = ZO_HUDFadeSceneFragment:New(control)
        self.fragments[key] = fragment
        HUD_SCENE:AddFragment(fragment)
        if HUD_UI_SCENE then
            HUD_UI_SCENE:AddFragment(fragment)
        end
    end
end

function WM:CreateUI()
    for _,key in ipairs(self.order) do
        self:CreateTracker(key)
    end
    self:ApplyFont()
    self:ApplyIcons()
    self:SetLocked(self.sv.locked)
end

function WM:ApplyFont()
    local font = string.format("$(BOLD_FONT)|%d|soft-shadow-thick", self.sv.fontSize)
    for _,control in pairs(self.controls) do
        control.label:SetFont(font)
    end
end

function WM:ApplyIcons()
    for _,control in pairs(self.controls) do
        control.icon:SetHidden(not self.sv.showIcons)
    end
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

function WM:SetDisplay(key, text, active, show)
    local control = self.controls[key]
    if not control then return end

    show = show
        and self.sv.enabled
        and self.sv.trackers[key]

    control:SetHidden(not show)
    if not show then return end

    control.label:SetText(text)

    local c = active and self.sv.activeColor or self.sv.inactiveColor
    control.label:SetColor(Color(c))
end

function WM:GetPreviewText(key)
    if key == "tundra" then
        return self.pretty.tundra .. " — ACTIVE", true
    elseif key == "wild" then
        return self.pretty.wild .. " — +999", true
    elseif key == "glacial" then
        return self.pretty.glacial .. " — 10.0", true
    elseif key == "green" then
        return self.pretty.green .. " — 9%", true
    elseif key == "bountiful" then
        return self.pretty.bountiful .. " — 3.0", true
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

    if not self.sv.enabled then
        self:HideAll()
        return
    end

    if self:IsMenuOpen() then
        self:HideAll()
        return
    end

    -- Unlock mode intentionally previews enabled trackers without requiring
    -- combat or mastery selection, so the user can place all five.
    if not self.sv.locked then
        for _,key in ipairs(self.order) do
            local text,active = self:GetPreviewText(key)
            self:SetDisplay(key, text, active, true)
        end
        return
    end

    local canShow = self:CanDisplayNormal()
    local now = Now()

    -- Tundra's Maw: red inactive / green active. No countdown.
    if self:IsSelected("tundra") then
        local active = self.state.tundraEnd > now
        local text = self.pretty.tundra .. (active and " — ACTIVE" or " — INACTIVE")
        self:SetDisplay("tundra", text, active, canShow)
    else
        self:SetDisplay("tundra", "", false, false)
    end

    -- Wild Adaptation: status count on the actual combat target, not reticle.
    if self:IsSelected("wild") then
        local count = self:PruneAndCount(self.state.wildTargetKey)
        local bonus = count * 333
        local active = count > 0
        local text = active
            and string.format("%s — +%d", self.pretty.wild, bonus)
            or (self.pretty.wild .. " — INACTIVE")
        self:SetDisplay("wild", text, active, canShow)
    else
        self:SetDisplay("wild", "", false, false)
    end

    -- Glacial Obstinance: actual 10-second mastery buff countdown.
    if self:IsSelected("glacial") then
        local remaining = math.max(0, self.state.glacialEnd - now)
        local active = remaining > 0
        local text = active
            and string.format("%s — %.1f", self.pretty.glacial, remaining)
            or (self.pretty.glacial .. " — DOWN")
        self:SetDisplay("glacial", text, active, canShow)
    else
        self:SetDisplay("glacial", "", false, false)
    end

    -- Green-Keeper's Hide: statuses on the enemy currently attacking the player.
    if self:IsSelected("green") then
        local count = self:PruneAndCount(self.state.greenAttackerKey)
        local reduction = count * 3
        local active = count > 0
        local text = string.format("%s — %d%%", self.pretty.green, reduction)
        self:SetDisplay("green", text, active, canShow)
    else
        self:SetDisplay("green", "", false, false)
    end

    -- Bountiful Harvest: mastery-specific 3-second Major Heroism window.
    if self:IsSelected("bountiful") then
        local remaining = math.max(0, self.state.bountifulEnd - now)
        local active = remaining > 0
        local text = active
            and string.format("%s — %.1f", self.pretty.bountiful, remaining)
            or (self.pretty.bountiful .. " — DOWN")
        self:SetDisplay("bountiful", text, active, canShow)
    else
        self:SetDisplay("bountiful", "", false, false)
    end
end

local function RegisterCombatByAbility(tag, abilityId, callback)
    local eventName = WM.name .. "_" .. tag

    EVENT_MANAGER:RegisterForEvent(
        eventName,
        EVENT_COMBAT_EVENT,
        callback
    )

    EVENT_MANAGER:AddFilterForEvent(
        eventName,
        EVENT_COMBAT_EVENT,
        REGISTER_FILTER_ABILITY_ID,
        abilityId
    )

    EVENT_MANAGER:AddFilterForEvent(
        eventName,
        EVENT_COMBAT_EVENT,
        REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE,
        COMBAT_UNIT_TYPE_PLAYER
    )
end

function WM:RegisterTracking()
    if SCENE_MANAGER and SCENE_MANAGER.RegisterCallback then
        SCENE_MANAGER:RegisterCallback("CurrentSceneChanged", function()
            WM:Update()
        end)
    end

    -- One filtered registration per status effect. This avoids receiving the
    -- entire combat-event firehose and follows ESOUI event-filter guidance.
    for abilityId in pairs(self.STATUS_BY_ID) do
        local id = abilityId
        RegisterCombatByAbility(
            "Status_" .. tostring(id),
            id,
            function(...) WM:OnStatusCombatEvent(...) end
        )
    end

    RegisterCombatByAbility(
        "Tundra",
        self.ID.tundraBrittle,
        function(...) WM:OnTundraCombatEvent(...) end
    )

    RegisterCombatByAbility(
        "Bountiful",
        self.ID.bountifulHero,
        function(...) WM:OnBountifulCombatEvent(...) end
    )

    -- Incoming damage for Green-Keeper. Engine-side target filter keeps this
    -- limited to combat events whose target is the local player.
    local incomingEvent = self.name .. "_Incoming"
    EVENT_MANAGER:RegisterForEvent(
        incomingEvent,
        EVENT_COMBAT_EVENT,
        function(...) WM:OnIncomingCombatEvent(...) end
    )
    EVENT_MANAGER:AddFilterForEvent(
        incomingEvent,
        EVENT_COMBAT_EVENT,
        REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE,
        COMBAT_UNIT_TYPE_PLAYER
    )

    local glacialEvent = self.name .. "_Glacial"
    EVENT_MANAGER:RegisterForEvent(
        glacialEvent,
        EVENT_EFFECT_CHANGED,
        function(...) WM:OnGlacialEffectChanged(...) end
    )
    EVENT_MANAGER:AddFilterForEvent(
        glacialEvent,
        EVENT_EFFECT_CHANGED,
        REGISTER_FILTER_ABILITY_ID,
        self.ID.glacialBuff
    )

    EVENT_MANAGER:RegisterForEvent(
        self.name .. "_CombatState",
        EVENT_PLAYER_COMBAT_STATE,
        function(...) WM:OnCombatState(...) end
    )

    EVENT_MANAGER:RegisterForUpdate(
        self.name .. "_Update",
        100,
        function() WM:Update() end
    )

    EVENT_MANAGER:RegisterForUpdate(
        self.name .. "_MasteryRescan",
        500,
        function() WM:ScanSelectedMasteries() end
    )

    EVENT_MANAGER:RegisterForEvent(
        self.name .. "_Activated",
        EVENT_PLAYER_ACTIVATED,
        function()
            zo_callLater(function()
                WM:ScanSelectedMasteries()
            end, 500)
        end
    )

    if EVENT_SKILL_POINTS_CHANGED then
        EVENT_MANAGER:RegisterForEvent(
            self.name .. "_SkillPoints",
            EVENT_SKILL_POINTS_CHANGED,
            function()
                zo_callLater(function()
                    WM:ScanSelectedMasteries()
                end, 250)
            end
        )
    end
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
            name="Text Size",
            min=18,
            max=80,
            step=1,
            getFunc=function() return WM.sv.fontSize end,
            setFunc=function(v)
                WM.sv.fontSize = v
                WM:ApplyFont()
            end,
            default=self.defaults.fontSize,
        },
        {
            type="colorpicker",
            name="Inactive Color",
            tooltip="Used when a selected mastery is down/inactive or at 0%.",
            getFunc=function() return Color(WM.sv.inactiveColor) end,
            setFunc=function(r,g,b,a)
                WM.sv.inactiveColor = {r,g,b,a}
                WM:Update()
            end,
            default={r=1.00,g=0.15,b=0.15,a=1},
        },
        {
            type="colorpicker",
            name="Active Color",
            tooltip="Used when a selected mastery is active.",
            getFunc=function() return Color(WM.sv.activeColor) end,
            setFunc=function(r,g,b,a)
                WM.sv.activeColor = {r,g,b,a}
                WM:Update()
            end,
            default={r=0.15,g=1.00,b=0.25,a=1},
        },
        {
            type="checkbox",
            name="Show Mastery Icons",
            tooltip="Uses ESO's actual Class Mastery ability icons.",
            getFunc=function() return WM.sv.showIcons end,
            setFunc=function(v)
                WM.sv.showIcons = v
                WM:ApplyIcons()
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
            WM:Update()
            d("|c66FF99Warden Mastery|r ON")
        elseif text == "off" then
            WM.sv.enabled = false
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

    self:CreateUI()
    self:ScanSelectedMasteries()
    self:CreateSettings()
    self:RegisterTracking()
    self:RegisterSlashCommands()

    zo_callLater(function()
        WM:ScanSelectedMasteries()
        WM:Update()
    end, 750)

    d("|c66FF99Warden Mastery v1.0 loaded.|r")
end

local function OnAddonLoaded(eventCode, addonName)
    if addonName ~= WM.name then return end
    EVENT_MANAGER:UnregisterForEvent(WM.name, EVENT_ADD_ON_LOADED)
    WM:Initialize()
end

EVENT_MANAGER:RegisterForEvent(WM.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
