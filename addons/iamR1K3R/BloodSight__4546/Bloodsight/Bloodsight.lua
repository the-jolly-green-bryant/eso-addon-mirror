-- ============================================================================
-- Bloodsight
--
-- Hides overhead ally healthbars until a group member has been below a
-- configurable HP threshold for a configurable delay. When an ally is low,
-- an on-screen arrow rotates to point at the most-wounded teammate.
-- ============================================================================

local Bloodsight = {}
local BS = Bloodsight
BS.name    = "Bloodsight"
BS.version = "1.2.1"

-- ---------- Arrow styles ----------------------------------------------------
local ARROW_STYLES = {
    ["Simple"] = "Bloodsight/Simple.dds",
    ["Bloody"] = "Bloodsight/Bloody.dds",
    ["Ornate"] = "Bloodsight/Ornate.dds",
}
local ARROW_STYLE_ORDER = { "Simple", "Bloody", "Ornate" }
local DEFAULT_STYLE = "Simple"

-- ---------- Defaults --------------------------------------------------------
local DEFAULT_THRESHOLD   = 0.50
local DEFAULT_DELAY_MS    = 250
local DEFAULT_SIZE        = 96
local DEFAULT_DISTANCE_M  = 28
local ROTATION_REFRESH_MS = 50

-- ---------- Runtime state ---------------------------------------------------
local lowHpStartTime = {}
local lowHpUnits     = {}
local anyLow         = false
local addonEnabled   = true
local arrowControl   = nil

local UpdateArrowVisibility
local UpdateArrowRotation
local ApplyLockState
local ReevaluateAll

-- ---------- Small helpers ---------------------------------------------------
local function IsTrackedGroupMember(unitTag)
    if not unitTag then return false end
    if not ZO_Group_IsGroupUnitTag(unitTag) then return false end
    if AreUnitsEqual(unitTag, "player") then return false end
    return true
end

local function GetDistanceMeters(unitTag)
    local pz, px, py, ppz = GetUnitWorldPosition("player")
    local uz, ux, uy, upz = GetUnitWorldPosition(unitTag)
    if not pz or not uz then return nil end
    if pz ~= uz then return nil end
    if (ux == 0 and uy == 0 and upz == 0) then return nil end
    local dx = px - ux
    local dy = py - uy
    local dz = ppz - upz
    local cm = math.sqrt(dx * dx + dy * dy + dz * dz)
    return cm / 100
end

local function IsAliveAndInRange(unitTag)
    if IsUnitDeadOrReincarnating(unitTag) then return false end
    if IsUnitDead(unitTag) then return false end
    local maxM = (BS.sv and BS.sv.maxDistanceM) or DEFAULT_DISTANCE_M
    local dist = GetDistanceMeters(unitTag)
    if not dist then return true end
    if dist > maxM then return false end
    return true
end

local function GetHpPercent(unitTag)
    local c, m = GetUnitPower(unitTag, COMBAT_MECHANIC_FLAGS_HEALTH)
    if not m or m == 0 then return 1.0 end
    return c / m
end

local function CountLowUnits()
    local n = 0
    for _ in pairs(lowHpUnits) do n = n + 1 end
    return n
end

local function GetPriorityLowUnit()
    local best, bestPct = nil, 2.0
    for ut in pairs(lowHpUnits) do
        if DoesUnitExist(ut) and IsAliveAndInRange(ut) then
            local p = GetHpPercent(ut)
            if p < bestPct then
                bestPct = p
                best = ut
            end
        end
    end
    return best
end

-- ---------- Nameplate setting handling --------------------------------------
-- Toggles NAMEPLATE_TYPE_GROUP_MEMBER_HEALTHBARS between OFF_VALUE ("0")
-- when no ally is wounded and armedValue when one is.
--
-- armedValue is captured from the user's live setting on load so we restore
-- their preference when the addon is disabled or the session ends.

-- ESO's nameplate dropdown is 1-indexed. Valid values:
--   "1" = Never  "2" = Targeted  "3" = Injured
--   "4" = Injured or Targeted  "5" = Always
-- Writing "0" produces "do not translate" because no entry exists at index 0.
local VALID_NP_VALUES = { ["1"] = true, ["2"] = true, ["3"] = true, ["4"] = true, ["5"] = true }
local OFF_VALUE       = "1"  -- Never

local armedValue       = nil
local nameplateControl = false

local function ReadOverheadSetting()
    return GetSetting(SETTING_TYPE_NAMEPLATES,
                      NAMEPLATE_TYPE_GROUP_MEMBER_HEALTHBARS)
end

local function CaptureArmedValue()
    local current = ReadOverheadSetting()

    if not VALID_NP_VALUES[current] then
        ResetSettingToDefault(SETTING_TYPE_NAMEPLATES,
                              NAMEPLATE_TYPE_GROUP_MEMBER_HEALTHBARS)
        current = ReadOverheadSetting()
    end

    if VALID_NP_VALUES[current] and current ~= OFF_VALUE then
        armedValue = current
        nameplateControl = true
    elseif current == OFF_VALUE then
        if BS.sv and BS.sv.lastArmedValue
           and VALID_NP_VALUES[BS.sv.lastArmedValue]
           and BS.sv.lastArmedValue ~= OFF_VALUE then
            armedValue = BS.sv.lastArmedValue
        else
            armedValue = "3"   -- default to Injured
        end
        nameplateControl = true
    else
        nameplateControl = false
    end

    if BS.sv and armedValue then
        BS.sv.lastArmedValue = armedValue
    end
end

local lastWritten = nil
local function WriteOverheadSetting(value)
    if IsConsoleUI() then return end
    if not nameplateControl then return end
    if not VALID_NP_VALUES[value] then return end
    if value == lastWritten then return end
    lastWritten = value
    SetSetting(SETTING_TYPE_NAMEPLATES,
               NAMEPLATE_TYPE_GROUP_MEMBER_HEALTHBARS,
               value)
end

local function ApplyOverheadBars(show)
    if show then
        WriteOverheadSetting(armedValue)
    else
        WriteOverheadSetting(OFF_VALUE)
    end
end

-- Verifies the live ESO setting matches what the addon expects and reapplies
-- it if something else changed it (zone load, other addon, etc.).
local function SyncOverheadSetting()
    if not nameplateControl then return end
    local expected = anyLow and armedValue or OFF_VALUE
    if not expected then return end
    if ReadOverheadSetting() ~= expected then
        lastWritten = nil   -- bust the cache so WriteOverheadSetting fires
        WriteOverheadSetting(expected)
    end
end

local function CountTrackableLowUnits()
    local n = 0
    for ut in pairs(lowHpUnits) do
        if DoesUnitExist(ut) and IsAliveAndInRange(ut) then
            n = n + 1
        end
    end
    return n
end

local function RefreshGlobalState()
    local shouldShow = (CountTrackableLowUnits() > 0)
    if shouldShow ~= anyLow then
        anyLow = shouldShow
        ApplyOverheadBars(shouldShow)
        UpdateArrowVisibility()
    end
end

-- ---------- Core HP evaluation ---------------------------------------------
local function EvaluateUnit(unitTag, now)
    if not IsTrackedGroupMember(unitTag) or not DoesUnitExist(unitTag)
       or not IsAliveAndInRange(unitTag) then
        lowHpStartTime[unitTag] = nil
        lowHpUnits[unitTag]     = nil
        return
    end
    local pct = GetHpPercent(unitTag)
    if pct < BS.sv.threshold then
        if not lowHpStartTime[unitTag] then
            lowHpStartTime[unitTag] = now
        end
        if (now - lowHpStartTime[unitTag]) >= BS.sv.delayMs then
            lowHpUnits[unitTag] = true
        end
    else
        lowHpStartTime[unitTag] = nil
        lowHpUnits[unitTag]     = nil
    end
end

ReevaluateAll = function()
    local now = GetGameTimeMilliseconds()
    local seen = {}
    local size = GetGroupSize()
    for i = 1, size do
        local ut = GetGroupUnitTagByIndex(i)
        if ut then
            seen[ut] = true
            if IsTrackedGroupMember(ut) then
                EvaluateUnit(ut, now)
            else
                lowHpStartTime[ut] = nil
                lowHpUnits[ut]     = nil
            end
        end
    end
    for ut in pairs(lowHpStartTime) do
        if not seen[ut] then lowHpStartTime[ut] = nil end
    end
    for ut in pairs(lowHpUnits) do
        if not seen[ut] then lowHpUnits[ut] = nil end
    end
    RefreshGlobalState()
end

-- ---------- Arrow control ---------------------------------------------------
local function ApplyPosition()
    if not BS.container then return end
    BS.container:ClearAnchors()
    BS.container:SetAnchor(CENTER, GuiRoot, CENTER,
                           BS.sv.arrowX or 0, BS.sv.arrowY or 0)
end

local function GetCurrentTexturePath()
    local style = BS.sv and BS.sv.arrowStyle or DEFAULT_STYLE
    local path = ARROW_STYLES[style]
    if not path then
        path = ARROW_STYLES[DEFAULT_STYLE]
    end
    return path
end

local function ApplyTexture()
    if not arrowControl then return end
    arrowControl:SetTexture(GetCurrentTexturePath())
end

local function ApplySize()
    if not arrowControl then return end
    local s = BS.sv.size or DEFAULT_SIZE
    arrowControl:SetDimensions(s, s)
    if BS.container then
        BS.container:SetDimensions(s, s)
    end
end

UpdateArrowVisibility = function()
    if not BS.container then return end
    if not addonEnabled then
        BS.container:SetHidden(true)
        return
    end
    if BS.sv.locked then
        BS.container:SetHidden(not anyLow)
    else
        BS.container:SetHidden(false)
    end
end

UpdateArrowRotation = function()
    if not arrowControl or not BS.container or BS.container:IsHidden() then return end

    if not BS.sv.locked then
        arrowControl:SetTextureRotation(0, 0.5, 0.5)
        return
    end

    local target = GetPriorityLowUnit()
    if not target then
        arrowControl:SetTextureRotation(0, 0.5, 0.5)
        return
    end

    local px, py = GetMapPlayerPosition("player")
    local tx, ty = GetMapPlayerPosition(target)
    if not px or not tx then return end
    local dx = tx - px
    local dy = ty - py
    if dx == 0 and dy == 0 then return end

    local bearing    = math.atan2(-dx, -dy)
    local camHeading = GetPlayerCameraHeading() or 0
    local baseAngle  = bearing - camHeading

    local sw, sh = GuiRoot:GetDimensions()
    local ax = BS.sv.arrowX or 0
    local ay = BS.sv.arrowY or 0
    local R = math.min(sw, sh) * 0.5
    local tsx = R * math.sin(baseAngle)
    local tsy = -R * math.cos(baseAngle)
    local vx = tsx - ax
    local vy = tsy - ay
    local relAngle = baseAngle
    if vx ~= 0 or vy ~= 0 then
        relAngle = math.atan2(vx, -vy)
    end

    arrowControl:SetTextureRotation(relAngle, 0.5, 0.5)
end

local function CreateArrowControl()
    local wm = WINDOW_MANAGER

    local container = wm:CreateTopLevelWindow(BS.name .. "_ArrowFrame")
    container:SetClampedToScreen(true)
    container:SetMouseEnabled(false)
    container:SetMovable(false)
    container:SetHandler("OnMoveStop", function()
        if not arrowControl then return end
        local cx, cy = container:GetCenter()
        local sw, sh = GuiRoot:GetDimensions()
        BS.sv.arrowX = cx - sw / 2
        BS.sv.arrowY = cy - sh / 2
    end)

    local bg = wm:CreateControl(BS.name .. "_ArrowBG", container, CT_TEXTURE)
    bg:SetAnchor(TOPLEFT, container, TOPLEFT, 0, 0)
    bg:SetAnchor(BOTTOMRIGHT, container, BOTTOMRIGHT, 0, 0)
    bg:SetColor(1, 0, 0, 0.3)
    bg:SetTexture("EsoUI/Art/Miscellaneous/white.dds")
    bg:SetHidden(true)
    BS.debugBg = bg

    arrowControl = wm:CreateControl(BS.name .. "_Arrow", container, CT_TEXTURE)
    arrowControl:SetAnchor(CENTER, container, CENTER, 0, 0)
    arrowControl:SetDrawLayer(DL_OVERLAY)
    arrowControl:SetDrawLevel(10)

    BS.container = container
    ApplyTexture()
    ApplySize()
    ApplyPosition()
end

ApplyLockState = function()
    if not BS.container then return end
    local locked = BS.sv.locked
    BS.container:SetMovable(not locked)
    BS.container:SetMouseEnabled(not locked)
    UpdateArrowVisibility()
    UpdateArrowRotation()
end

-- ---------- Event handlers --------------------------------------------------
local function OnPowerUpdate(_, unitTag, _)
    if not addonEnabled then return end
    if not IsTrackedGroupMember(unitTag) then return end

    local now = GetGameTimeMilliseconds()
    EvaluateUnit(unitTag, now)
    RefreshGlobalState()

    local uname = BS.name .. "_D_" .. unitTag
    EVENT_MANAGER:UnregisterForUpdate(uname)
    EVENT_MANAGER:RegisterForUpdate(uname, BS.sv.delayMs + 20, function()
        EVENT_MANAGER:UnregisterForUpdate(uname)
        EvaluateUnit(unitTag, GetGameTimeMilliseconds())
        RefreshGlobalState()
    end)
end

local function OnGroupChanged()
    zo_callLater(function()
        if addonEnabled then ReevaluateAll() end
    end, 200)
end

-- ---------- Enable / disable ------------------------------------------------
local function EnableAddon()
    addonEnabled = true
    anyLow = false
    lastWritten = nil   -- force a clean write on the next ApplyOverheadBars call
    ApplyOverheadBars(false)
    ReevaluateAll()
    UpdateArrowVisibility()
end

local function DisableAddon()
    addonEnabled = false
    WriteOverheadSetting(armedValue)
    lowHpStartTime = {}
    lowHpUnits     = {}
    anyLow = false
    UpdateArrowVisibility()
end

-- ---------- LibAddonMenu settings panel ------------------------------------
local function BuildMenu()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local panelData = {
        type         = "panel",
        name         = "Bloodsight",
        displayName  = "Bloodsight",
        author       = "@R1K3R",
        version      = BS.version,
        slashCommand = "/bsmenu",
        registerForRefresh = true,
    }
    LAM:RegisterAddonPanel(BS.name .. "_LAM", panelData)

    local options = {
        { type = "header", name = "Arrow" },
        {
            type    = "dropdown",
            name    = "Arrow style",
            tooltip = "Pick which bundled arrow texture to use.",
            choices = ARROW_STYLE_ORDER,
            getFunc = function() return BS.sv.arrowStyle or DEFAULT_STYLE end,
            setFunc = function(v) BS.sv.arrowStyle = v; ApplyTexture() end,
        },
        {
            type    = "checkbox",
            name    = "Lock arrow",
            tooltip = "When unlocked, the arrow is always visible and draggable. When locked, it only shows and rotates when an ally is low on health.",
            getFunc = function() return BS.sv.locked end,
            setFunc = function(v) BS.sv.locked = v; ApplyLockState() end,
        },
        {
            type    = "slider",
            name    = "Arrow size (px)",
            min     = 32, max = 256, step = 4, decimals = 0,
            getFunc = function() return BS.sv.size end,
            setFunc = function(v) BS.sv.size = v; ApplySize() end,
        },
        {
            type    = "button",
            name    = "Center arrow",
            tooltip = "Move the arrow back to the middle of the screen.",
            func    = function()
                BS.sv.arrowX = 0
                BS.sv.arrowY = 0
                ApplyPosition()
            end,
        },

        { type = "header", name = "Sensitivity" },
        {
            type    = "slider",
            name    = "Health threshold (%)",
            tooltip = "An ally must drop below this percent of max health for the bar and arrow to activate.",
            min     = 10, max = 90, step = 5, decimals = 0,
            getFunc = function() return math.floor(BS.sv.threshold * 100 + 0.5) end,
            setFunc = function(v) BS.sv.threshold = v / 100; ReevaluateAll() end,
        },
        {
            type    = "slider",
            name    = "Activation delay (ms)",
            tooltip = "An ally must stay below the threshold for this many milliseconds before the bar and arrow activate.",
            min     = 0, max = 2000, step = 25, decimals = 0,
            getFunc = function() return BS.sv.delayMs end,
            setFunc = function(v) BS.sv.delayMs = v end,
        },
        {
            type    = "slider",
            name    = "Maximum distance (m)",
            tooltip = "Only track allies within this many meters. Dead allies and those in a different zone are always ignored.",
            min     = 5, max = 100, step = 1, decimals = 0,
            getFunc = function() return BS.sv.maxDistanceM or DEFAULT_DISTANCE_M end,
            setFunc = function(v) BS.sv.maxDistanceM = v; ReevaluateAll() end,
        },

        { type = "header", name = "General" },
        {
            type    = "checkbox",
            name    = "Addon enabled",
            getFunc = function() return addonEnabled end,
            setFunc = function(v)
                if v then EnableAddon() else DisableAddon() end
            end,
        },
    }
    LAM:RegisterOptionControls(BS.name .. "_LAM", options)
end

-- ---------- Slash commands --------------------------------------------------
local function HandleSlash(arg)
    local s = (arg or ""):lower()
    local parts = {}
    for word in s:gmatch("%S+") do table.insert(parts, word) end
    local cmd = parts[1] or ""

    if cmd == "" or cmd == "menu" then
        if LibAddonMenu2 then
            LibAddonMenu2:OpenToPanel(_G[BS.name .. "_LAM"])
        end
    elseif cmd == "lock" then
        BS.sv.locked = true; ApplyLockState()
    elseif cmd == "unlock" then
        BS.sv.locked = false; ApplyLockState()
    elseif cmd == "on" then
        EnableAddon()
    elseif cmd == "off" then
        DisableAddon()
    elseif cmd == "status" then
        d("[Bloodsight] enabled=" .. tostring(addonEnabled)
          .. " threshold=" .. tostring(math.floor(BS.sv.threshold * 100 + 0.5)) .. "%"
          .. " delayMs=" .. tostring(BS.sv.delayMs)
          .. " maxDist=" .. tostring(BS.sv.maxDistanceM) .. "m"
          .. " locked=" .. tostring(BS.sv.locked))
        d("  armed=" .. tostring(armedValue)
          .. " bars=" .. tostring(anyLow and "shown" or "hidden")
          .. " live=" .. tostring(ReadOverheadSetting())
          .. " control=" .. tostring(nameplateControl)
          .. " (1=Never 2=Targeted 3=Injured 4=InjuredOrTargeted 5=Always)")
    else
        d("[Bloodsight] /bs menu | lock | unlock | on | off | status")
    end
end

-- ---------- Init ------------------------------------------------------------
local function Initialize()
    BS.sv = ZO_SavedVars:NewAccountWide("BloodsightSV", 1, GetWorldName(), {
        threshold       = DEFAULT_THRESHOLD,
        delayMs         = DEFAULT_DELAY_MS,
        locked          = true,
        size            = DEFAULT_SIZE,
        arrowStyle      = DEFAULT_STYLE,
        arrowX          = 0,
        arrowY          = 0,
        maxDistanceM    = DEFAULT_DISTANCE_M,
        lastArmedValue  = nil,
    })

    BS.sv.texturePath    = nil
    BS.sv.rotationOffset = nil
    BS.sv.rotationDir    = nil
    BS.sv.parallax       = nil
    BS.sv.rangeLimit     = nil
    BS.sv.armedValue     = nil
    if BS.sv.lastArmedValue and not VALID_NP_VALUES[BS.sv.lastArmedValue] then
        BS.sv.lastArmedValue = nil
    end
    if not ARROW_STYLES[BS.sv.arrowStyle or ""] then
        BS.sv.arrowStyle = DEFAULT_STYLE
    end

    CaptureArmedValue()

    CreateArrowControl()
    ApplyLockState()

    EVENT_MANAGER:RegisterForEvent(BS.name, EVENT_POWER_UPDATE, OnPowerUpdate)
    EVENT_MANAGER:AddFilterForEvent(BS.name, EVENT_POWER_UPDATE,
        REGISTER_FILTER_POWER_TYPE, COMBAT_MECHANIC_FLAGS_HEALTH)

    EVENT_MANAGER:RegisterForEvent(BS.name, EVENT_GROUP_UPDATE,        OnGroupChanged)
    EVENT_MANAGER:RegisterForEvent(BS.name, EVENT_GROUP_MEMBER_JOINED, OnGroupChanged)
    EVENT_MANAGER:RegisterForEvent(BS.name, EVENT_GROUP_MEMBER_LEFT,   OnGroupChanged)

    EVENT_MANAGER:RegisterForEvent(BS.name, EVENT_PLAYER_ACTIVATED, function()
        if addonEnabled then EnableAddon() end
    end)

    EVENT_MANAGER:RegisterForEvent(BS.name, EVENT_PLAYER_DEACTIVATED, function()
        WriteOverheadSetting(armedValue)
    end)

    EVENT_MANAGER:RegisterForUpdate(BS.name .. "_Rot",
        ROTATION_REFRESH_MS, UpdateArrowRotation)

    -- Periodic re-check: re-evaluates group HP state and also verifies that
    -- the live ESO nameplate setting matches what the addon expects. This
    -- corrects any external reset (zone load, another addon, etc.) within
    -- one tick rather than waiting for the next state-change event.
    EVENT_MANAGER:RegisterForUpdate(BS.name .. "_Reeval", 500, function()
        if addonEnabled then
            SyncOverheadSetting()
            ReevaluateAll()
        end
    end)

    BuildMenu()
    SLASH_COMMANDS["/bs"] = HandleSlash
    EnableAddon()
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= BS.name then return end
    EVENT_MANAGER:UnregisterForEvent(BS.name, EVENT_ADD_ON_LOADED)
    Initialize()
end

EVENT_MANAGER:RegisterForEvent(BS.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
