-- Templar Mastery v0.2 TEST
-- Author: WifeyRytic
-- LUA ONLY. NO XML.

TemplarMastery = {}
local TM = TemplarMastery

TM.name = "TemplarMastery"
TM.version = "1.2"

TM.MASTERY = {
    bastion   = 263585,
    devout    = 263586,
    bright    = 263587,
    judgment  = 263588,
    steadfast = 263589,
}

TM.ID = {
    illuminate      = 62800,
    judgmentProc    = 263660,
    holdTheLine     = 263619,
    steadfastProc   = 263643,
    sacredGround    = 31759,
    missionaryHeal  = 266178,
    missionaryUlt   = 267069,
}

TM.pretty = {
    bright    = "BRIGHT HARBINGER",
    judgment  = "JUDGMENT'S BRAND",
    devout    = "DEVOUT GUARDIAN",
    steadfast = "STEADFAST CANDESCENCE",
    bastion   = "BASTION OF LIGHT",
}

TM.defaults = {
    enabled = true,
    hideOutOfCombat = false,
    locked = true,
    fontSize = 36,
    showIcons = true,

    textColor = {1.0,0.8235,0.2745,1},
    warningColor = {1,0.15,0.15,1},

    trackers = {
        bright=true,
        judgment=true,
        devout=true,
        steadfast=true,
        bastion=true,
    },

    positions = {
        bastion   = {x=0,y=-180},
        devout    = {x=0,y=-90},
        bright    = {x=0,y=0},
        judgment  = {x=0,y=90},
        steadfast = {x=0,y=180},
    },
}

TM.controls = {}
TM.selected = {}
TM.testUntil = {}
TM.state = {
    brightEnd = 0,
    judgmentEnd = 0,
    devoutEnd = 0,
    bastionUntil = 0,
    bastionUltUntil = 0,
}

local function Now()
    return GetFrameTimeSeconds()
end

local function Color(c)
    return c[1],c[2],c[3],c[4]
end

function TM:IsInCombat()
    return IsUnitInCombat("player")
end

function TM:IsUnlockedPreview()
    return not self.sv.locked
end

function TM:IsTesting(key)
    return (self.testUntil[key] or 0) > Now()
end

function TM:CanDisplayNormal()
    if not self.sv.enabled then return false end
    if self.sv.hideOutOfCombat and not self:IsInCombat() then return false end
    return true
end

function TM:GetIcon(id)
    local tex = GetAbilityIcon(id)
    if tex and tex ~= "" then return tex end
    return "/esoui/art/icons/icon_missing.dds"
end

function TM:ApplyPosition(key)
    local c = self.controls[key]
    if not c then return end
    local p = self.sv.positions[key]
    c:ClearAnchors()
    c:SetAnchor(CENTER, GuiRoot, CENTER, p.x, p.y)
end

function TM:CreateTracker(key)
    local wm = WINDOW_MANAGER

    local c = wm:CreateTopLevelWindow("TM_" .. key)
    c:SetDimensions(900,70)
    c:SetClampedToScreen(true)
    c:SetDrawTier(DT_HIGH)
    c:SetDrawLayer(DL_OVERLAY)
    c:SetHidden(true)

    local bg = wm:CreateControl(nil,c,CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0,0,0,0.55)
    bg:SetEdgeColor(1,1,1,0.45)
    bg:SetEdgeTexture("",1,1,1)
    bg:SetHidden(true)
    c.bg = bg

    local icon = wm:CreateControl(nil,c,CT_TEXTURE)
    icon:SetDimensions(52,52)
    icon:SetAnchor(LEFT,c,LEFT,8,0)
    icon:SetTexture(self:GetIcon(self.MASTERY[key]))
    c.icon = icon

    local label = wm:CreateControl(nil,c,CT_LABEL)
    label:SetAnchor(LEFT,icon,RIGHT,12,0)
    label:SetAnchor(RIGHT,c,RIGHT,-8,0)
    label:SetHeight(68)
    label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    c.label = label

    c:SetHandler("OnMoveStop", function(control)
        local cx = control:GetLeft() + control:GetWidth()/2
        local cy = control:GetTop() + control:GetHeight()/2
        TM.sv.positions[key].x = cx - GuiRoot:GetWidth()/2
        TM.sv.positions[key].y = cy - GuiRoot:GetHeight()/2
    end)

    self.controls[key] = c
    self:ApplyPosition(key)
end

function TM:CreateUI()
    for _,key in ipairs({"bastion","devout","bright","judgment","steadfast"}) do
        self:CreateTracker(key)
    end
    self:ApplyFont()
    self:ApplyIcons()
    self:SetLocked(self.sv.locked)
end

function TM:ApplyFont()
    local f = string.format("$(BOLD_FONT)|%d|soft-shadow-thick", self.sv.fontSize)
    for _,c in pairs(self.controls) do
        c.label:SetFont(f)
    end
end

function TM:ApplyIcons()
    for _,c in pairs(self.controls) do
        c.icon:SetHidden(not self.sv.showIcons)
    end
end

function TM:SetLocked(v)
    self.sv.locked = v

    for _,c in pairs(self.controls) do
        c:SetMouseEnabled(not v)
        c:SetMovable(not v)
        c.bg:SetHidden(v)
    end

    -- NEW v0.2:
    -- Unlocking automatically shows ALL five trackers as previews,
    -- so they can be moved without entering combat or proccing anything.
    self:Update()
end

function TM:ResetPositions()
    for key,p in pairs(self.defaults.positions) do
        self.sv.positions[key].x = p.x
        self.sv.positions[key].y = p.y
        self:ApplyPosition(key)
    end
end

function TM:HideAll()
    for _,c in pairs(self.controls) do
        c:SetHidden(true)
    end
end

function TM:ShowPreview(key, seconds)
    self.testUntil[key] = Now() + (seconds or 4)
    self:Update()
end

function TM:SetDisplay(key,text,show,warn,force)
    local c = self.controls[key]
    if not c then return end

    if force then
        show = self.sv.enabled and self.sv.trackers[key]
    else
        show = show and self.sv.trackers[key] and self:CanDisplayNormal()
    end

    c:SetHidden(not show)

    if show then
        c.label:SetText(text)
        c.label:SetColor(Color(warn and self.sv.warningColor or self.sv.textColor))
    end
end

-- Only purchased/selected mastery passives may activate a tracker.
function TM:ScanSelectedMasteries()
    local old = self.selected or {}
    local found = {}

    if not GetNumSkillTypes or not GetNumSkillLines or not GetNumSkillAbilities then
        return false
    end

    for st = 1, GetNumSkillTypes() do
        for sl = 1, GetNumSkillLines(st) do
            local count = GetNumSkillAbilities(st,sl)

            for ai = 1, count do
                local okId,id = pcall(GetSkillAbilityId,st,sl,ai,false)
                local okInfo,name,icon,earnedRank,passive,ultimate,purchased =
                    pcall(GetSkillAbilityInfo,st,sl,ai)

                if okId and okInfo and purchased and id then
                    for key,mid in pairs(self.MASTERY) do
                        if id == mid then
                            found[key] = true
                        end
                    end
                end
            end
        end
    end

    local changed = false

    for key in pairs(self.MASTERY) do
        if (old[key] == true) ~= (found[key] == true) then
            changed = true
            break
        end
    end

    self.selected = found

    if changed then
        -- Clear state belonging to masteries that are no longer selected.
        if not found.bright then
            self.state.brightEnd = 0
        end

        if not found.judgment then
            self.state.judgmentEnd = 0
        end

        if not found.devout then
            self.state.devoutEnd = 0
        end

        if not found.bastion then
            self.state.bastionUntil = 0
            self.state.bastionUltUntil = 0
        end

        -- Steadfast is state-driven, so it needs no timer reset.
        self:Update()
    end

    return changed
end

function TM:IsSelected(key)
    return self.selected[key] == true
end

-- Live-safe Bright Harbinger detection:
-- ESO can expose the active Bright buff differently from the Illuminate event.
-- Scan the player's actual buffs and accept either the mastery ID, Illuminate ID,
-- or the actual Bright Harbinger buff name.
function TM:GetBrightHarbingerEnd()
    if not self:IsSelected("bright") then return 0 end
    if not GetNumBuffs or not GetUnitBuffInfo then return 0 end

    local now = Now()
    local masteryName = GetAbilityName(self.MASTERY.bright) or "Bright Harbinger"
    masteryName = string.lower(masteryName)

    local count = GetNumBuffs("player") or 0
    for i = 1, count do
        local buffName, beginTime, endTime, buffSlot, stackCount, iconFilename,
              buffType, effectType, abilityType, statusEffectType, abilityId =
              GetUnitBuffInfo("player", i)

        local nameMatch = buffName and string.lower(buffName) == masteryName
        local idMatch = abilityId == self.MASTERY.bright or abilityId == self.ID.illuminate

        if nameMatch or idMatch then
            if endTime and endTime > now then
                return endTime
            end
            -- If ESO does not provide an ending timestamp, keep it visibly active
            -- and let the next scan decide when it disappears.
            return now + 0.25
        end
    end

    return 0
end

function TM:OnEffectChanged(eventCode,changeType,effectSlot,effectName,unitTag,
                            beginTime,endTime,stackCount,iconName,buffType,effectType,
                            abilityType,statusEffectType,unitName,unitId,abilityId,sourceType)
    if unitTag ~= "player" then return end

    local now = Now()

    -- BRIGHT HARBINGER
    if abilityId == self.ID.illuminate and self:IsSelected("bright") then
        if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
            self.state.brightEnd = (endTime and endTime > now) and endTime or (now + 20)
        elseif changeType == EFFECT_RESULT_FADED then
            self.state.brightEnd = 0
        end

    -- DEVOUT GUARDIAN
    -- v0.2 CHANGE:
    -- Hold the Line is "6 sec, up to once every 6 sec."
    -- ESO sends little UPDATED/reapply events during that period.
    -- Those are ignored until the current clean 6-second cycle is finished.
    elseif abilityId == self.ID.holdTheLine and self:IsSelected("devout") then
        if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
            if self.state.devoutEnd <= now + 0.05 then
                self.state.devoutEnd = now + 6.0
            end
        elseif changeType == EFFECT_RESULT_FADED then
            self.state.devoutEnd = 0
        end
    end
end

function TM:OnCombatEvent(eventCode,result,isError,abilityName,abilityGraphic,
                          abilityActionSlotType,sourceName,sourceType,targetName,targetType,
                          hitValue,powerType,damageType,log,sourceUnitId,targetUnitId,
                          abilityId,overflow)

    local now = Now()

    if abilityId == self.ID.judgmentProc and self:IsSelected("judgment") then
        self.state.judgmentEnd = now + 3.1

    elseif abilityId == self.ID.holdTheLine and self:IsSelected("devout") then
        -- Same clean 6-second rule as EFFECT_CHANGED.
        if self.state.devoutEnd <= now + 0.05 then
            self.state.devoutEnd = now + 6.0
        end

    elseif abilityId == self.ID.missionaryHeal and self:IsSelected("bastion") then
        self.state.bastionUntil = now + 1.25

    elseif abilityId == self.ID.missionaryUlt and self:IsSelected("bastion") then
        self.state.bastionUntil = now + 1.25

        -- v0.2 CHANGE:
        -- +2 Ultimate is only a QUICK flash now, instead of sitting there.
        self.state.bastionUltUntil = now + 0.35
    end
end

function TM:IsSteadfastActuallyActive()
    if not self:IsSelected("steadfast") then return false end
    if not IsBlockActive or not IsPlayerMoving then return false end

    -- Steadfast bonus condition:
    -- bracing/block held + stationary.
    return IsBlockActive() and not IsPlayerMoving()
end

function TM:Update()
    if not self.sv.enabled then
        self:HideAll()
        return
    end

    local now = Now()

    -- UNLOCK PREVIEW OVERRIDES EVERYTHING.
    if self:IsUnlockedPreview() then
        self:SetDisplay("bright",    "BRIGHT HARBINGER — PREVIEW", true, false, true)
        self:SetDisplay("judgment",  "JUDGMENT'S BRAND — PREVIEW", true, false, true)
        self:SetDisplay("devout",    "DEVOUT GUARDIAN — PREVIEW", true, false, true)
        self:SetDisplay("steadfast", "STEADFAST CANDESCENCE — PREVIEW", true, false, true)
        self:SetDisplay("bastion",   "BASTION OF LIGHT — PREVIEW", true, false, true)
        return
    end

    -- Individual TEST BUTTON preview.
    for _,key in ipairs({"bastion","devout","bright","judgment","steadfast"}) do
        if self:IsTesting(key) then
            self:SetDisplay(key, self.pretty[key] .. " — TEST", true, false, true)
        end
    end

    -- BRIGHT HARBINGER
    if not self:IsTesting("bright") then
        -- Prefer the player's actual active buff on Live.
        local liveBrightEnd = self:GetBrightHarbingerEnd()
        if liveBrightEnd > now then
            self.state.brightEnd = liveBrightEnd
        elseif self.state.brightEnd <= now then
            self.state.brightEnd = 0
        end

        local b = self.state.brightEnd - now

        if self:IsSelected("bright") and b > 0 then
            self:SetDisplay(
                "bright",
                string.format("BRIGHT HARBINGER  %.1f", b),
                true,
                b <= 2
            )
        else
            self:SetDisplay("bright","",false,false)
        end
    end

    -- JUDGMENT'S BRAND
    if not self:IsTesting("judgment") then
        if self:IsSelected("judgment") then
            local j = self.state.judgmentEnd - now

            if j > 0 then
                self:SetDisplay(
                    "judgment",
                    string.format("JUDGMENT'S BRAND  %.1f", j),
                    true,
                    j <= 1
                )
            elseif self:IsInCombat() then
                self:SetDisplay("judgment","JUDGMENT'S BRAND — DOWN",true,true)
            else
                self:SetDisplay("judgment","",false,false)
            end
        else
            self:SetDisplay("judgment","",false,false)
        end
    end

    -- DEVOUT GUARDIAN
    if not self:IsTesting("devout") then
        local d = self.state.devoutEnd - now

        if self:IsSelected("devout") and d > 0 then
            self:SetDisplay(
                "devout",
                string.format("DEVOUT GUARDIAN — HOLD THE LINE  %.1f", d),
                true,
                d <= 1
            )
        else
            self:SetDisplay("devout","",false,false)
        end
    end

    -- STEADFAST CANDESCENCE
    -- v0.2 CHANGE:
    -- No fake proc timer and NO mitigation numbers.
    -- It is simply ON while blocking AND stationary; hidden otherwise.
    if not self:IsTesting("steadfast") then
        if self:IsSteadfastActuallyActive() then
            self:SetDisplay(
                "steadfast",
                "STEADFAST CANDESCENCE — ACTIVE",
                true,
                false
            )
        else
            self:SetDisplay("steadfast","",false,false)
        end
    end

    -- BASTION OF LIGHT
    if not self:IsTesting("bastion") then
        if self:IsSelected("bastion") and now < self.state.bastionUntil then
            if now < self.state.bastionUltUntil then
                self:SetDisplay("bastion","BASTION OF LIGHT — +2 ULTIMATE",true,false)
            else
                self:SetDisplay("bastion","BASTION OF LIGHT — ACTIVE",true,false)
            end
        else
            self:SetDisplay("bastion","",false,false)
        end
    end
end

local function RegEffect(tag,id)
    local n = TM.name .. "_E_" .. tag

    EVENT_MANAGER:RegisterForEvent(
        n,
        EVENT_EFFECT_CHANGED,
        function(...) TM:OnEffectChanged(...) end
    )

    EVENT_MANAGER:AddFilterForEvent(
        n,
        EVENT_EFFECT_CHANGED,
        REGISTER_FILTER_ABILITY_ID,
        id
    )
end

local function RegCombat(tag,id)
    local n = TM.name .. "_C_" .. tag

    EVENT_MANAGER:RegisterForEvent(
        n,
        EVENT_COMBAT_EVENT,
        function(...) TM:OnCombatEvent(...) end
    )

    EVENT_MANAGER:AddFilterForEvent(
        n,
        EVENT_COMBAT_EVENT,
        REGISTER_FILTER_ABILITY_ID,
        id
    )
end

function TM:RegisterTracking()
    RegEffect("Illuminate",self.ID.illuminate)
    RegEffect("BrightHarbinger",self.MASTERY.bright)
    RegEffect("HoldTheLine",self.ID.holdTheLine)

    RegCombat("Judgment",self.ID.judgmentProc)
    RegCombat("HoldTheLine",self.ID.holdTheLine)
    RegCombat("MissionaryHeal",self.ID.missionaryHeal)
    RegCombat("MissionaryUlt",self.ID.missionaryUlt)

    -- Steadfast is deliberately NOT driven by 263643 anymore.
    -- Update() checks actual block-held + movement state instead.

    EVENT_MANAGER:RegisterForUpdate(
        self.name .. "_Update",
        50,
        function() TM:Update() end
    )

    -- v0.2.2:
    -- Class Mastery choices can be swapped without spending/refunding a skill point,
    -- so EVENT_SKILL_POINTS_CHANGED is not reliable for detecting the swap.
    -- Poll the purchased mastery passives at a very light interval instead.
    -- This removes the need for /tm scan or /reloadui after changing masteries.
    EVENT_MANAGER:RegisterForUpdate(
        self.name .. "_MasteryRescan",
        500,
        function() TM:ScanSelectedMasteries() end
    )

    EVENT_MANAGER:RegisterForEvent(
        self.name .. "_Activated",
        EVENT_PLAYER_ACTIVATED,
        function()
            zo_callLater(function() TM:ScanSelectedMasteries() end,500)
        end
    )

    if EVENT_SKILL_POINTS_CHANGED then
        EVENT_MANAGER:RegisterForEvent(
            self.name .. "_SkillPoints",
            EVENT_SKILL_POINTS_CHANGED,
            function()
                zo_callLater(function() TM:ScanSelectedMasteries() end,250)
            end
        )
    end
end

function TM:CreateSettings()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local panel = {
        type="panel",
        name="Templar Mastery",
        displayName="Templar Mastery |cFFD246♥|r",
        author="WifeyRytic",
        version=self.version,
        registerForRefresh=true,
        registerForDefaults=true,
    }

    LAM:RegisterAddonPanel(self.name .. "Options",panel)

    local opts = {
        {
            type="checkbox",
            name="ENABLE ADDON — FULL KILL SWITCH",
            tooltip="Turns ALL Templar Mastery tracking on or off.",
            getFunc=function() return TM.sv.enabled end,
            setFunc=function(v)
                TM.sv.enabled=v
                if not v then TM:HideAll() else TM:Update() end
            end,
            default=self.defaults.enabled,
            width="full",
        },
        {
            type="checkbox",
            name="Hide Out of Combat",
            getFunc=function() return TM.sv.hideOutOfCombat end,
            setFunc=function(v) TM.sv.hideOutOfCombat=v end,
            default=self.defaults.hideOutOfCombat,
        },
        {
            type="checkbox",
            name="Lock Position",
            tooltip="Turn OFF to unlock. ALL five trackers will appear as previews so you can move them.",
            getFunc=function() return TM.sv.locked end,
            setFunc=function(v) TM:SetLocked(v) end,
            default=self.defaults.locked,
        },
        {
            type="button",
            name="Reset Positions",
            func=function() TM:ResetPositions() end,
        },
        {
            type="slider",
            name="Text Size",
            min=18,max=80,step=1,
            getFunc=function() return TM.sv.fontSize end,
            setFunc=function(v)
                TM.sv.fontSize=v
                TM:ApplyFont()
            end,
            default=self.defaults.fontSize,
        },
        {
            type="colorpicker",
            name="Text Color",
            getFunc=function() return Color(TM.sv.textColor) end,
            setFunc=function(r,g,b,a) TM.sv.textColor={r,g,b,a} end,
            default={r=1.0,g=0.8235,b=0.2745,a=1},
        },
        {
            type="colorpicker",
            name="Warning Color",
            getFunc=function() return Color(TM.sv.warningColor) end,
            setFunc=function(r,g,b,a) TM.sv.warningColor={r,g,b,a} end,
            default={r=1,g=0.15,b=0.15,a=1},
        },
        {
            type="checkbox",
            name="Show Mastery Icons",
            tooltip="Uses ESO's actual mastery icon beside the tracker.",
            getFunc=function() return TM.sv.showIcons end,
            setFunc=function(v)
                TM.sv.showIcons=v
                TM:ApplyIcons()
            end,
            default=self.defaults.showIcons,
        },

        {type="header",name="Individual Mastery Trackers"},
    }

    local names = {
        bright="Bright Harbinger",
        judgment="Judgment's Brand",
        devout="Devout Guardian",
        steadfast="Steadfast Candescence",
        bastion="Bastion of Light",
    }

    for _,key in ipairs({"bastion","devout","bright","judgment","steadfast"}) do
        local k=key

        table.insert(opts,{
            type="checkbox",
            name=names[k],
            getFunc=function() return TM.sv.trackers[k] end,
            setFunc=function(v)
                TM.sv.trackers[k]=v
                if not v then TM.controls[k]:SetHidden(true) end
                TM:Update()
            end,
            default=true,
            width="half",
        })

        -- NEW v0.2: test button for every tracker.
        table.insert(opts,{
            type="button",
            name="Test " .. names[k],
            tooltip="Shows this tracker for 4 seconds. No mastery selection or combat required.",
            func=function() TM:ShowPreview(k,4) end,
            width="half",
        })
    end

    LAM:RegisterOptionControls(self.name .. "Options",opts)
end

function TM:RegisterSlash()
    SLASH_COMMANDS["/tm"] = function(t)
        t = string.lower(t or "")

        if t=="on" then
            TM.sv.enabled=true
            TM:Update()
            d("|cFFD700Templar Mastery|r ON")

        elseif t=="off" then
            TM.sv.enabled=false
            TM:HideAll()
            d("|cFFD700Templar Mastery|r OFF")

        elseif t=="unlock" then
            TM:SetLocked(false)
            d("|cFFD700Templar Mastery|r UNLOCKED — previews shown")

        elseif t=="lock" then
            TM:SetLocked(true)
            d("|cFFD700Templar Mastery|r LOCKED")

        elseif t=="reset" then
            TM:ResetPositions()
            d("|cFFD700Templar Mastery|r positions reset")

        elseif t=="scan" then
            TM:ScanSelectedMasteries()
            local a={}
            for k in pairs(TM.selected) do table.insert(a,k) end
            table.sort(a)
            d("|cFFD700Templar Mastery selected:|r " .. (#a>0 and table.concat(a,", ") or "NONE DETECTED"))

        elseif t=="test bright" then TM:ShowPreview("bright",4)
        elseif t=="test judgment" then TM:ShowPreview("judgment",4)
        elseif t=="test devout" then TM:ShowPreview("devout",4)
        elseif t=="test steadfast" then TM:ShowPreview("steadfast",4)
        elseif t=="test bastion" then TM:ShowPreview("bastion",4)

        else
            d("|cFFD700Templar Mastery:|r /tm on, off, unlock, lock, reset, scan")
            d("|cFFD700Tests:|r /tm test bright | judgment | devout | steadfast | bastion")
        end
    end
end

function TM:Initialize()
    self.sv = ZO_SavedVars:NewAccountWide(
        "TemplarMasterySavedVariables",
        1,
        nil,
        self.defaults
    )

    self:CreateUI()
    self:ScanSelectedMasteries()
    self:CreateSettings()
    self:RegisterTracking()
    self:RegisterSlash()

    zo_callLater(function()
        TM:ScanSelectedMasteries()
    end,1000)

    d("|cFFD700Templar Mastery ♥ v1.2 loaded.|r Type /tm scan")
end

local function Loaded(eventCode,addonName)
    if addonName ~= TM.name then return end
    EVENT_MANAGER:UnregisterForEvent(TM.name,EVENT_ADD_ON_LOADED)
    TM:Initialize()
end

EVENT_MANAGER:RegisterForEvent(TM.name,EVENT_ADD_ON_LOADED,Loaded)
