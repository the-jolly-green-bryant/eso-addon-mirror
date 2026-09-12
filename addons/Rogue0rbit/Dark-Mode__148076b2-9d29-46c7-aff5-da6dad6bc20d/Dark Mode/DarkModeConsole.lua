DarkModeConsole = DarkModeConsole or {}
local DMC = DarkModeConsole

DMC.name = "DarkModeConsole"
DMC.displayName = "Dark Mode Console"
DMC.version = "1.0.0"
DMC.savedVarsName = "DarkModeConsoleSV"
DMC.savedVarsVersion = 1

local ROLE_BORDER = DMC.ROLE_BORDER
local ROLE_BACKGROUND = DMC.ROLE_BACKGROUND
local TEXTURE_ROLES = DMC.TEXTURE_ROLES

local KIND_TEXTURE = 1
local KIND_BACKDROP = 2

local CONTROLS_PER_TICK = 600
local SWEEP_TICK_MS = 10
local SWEEP_COOLDOWN_MS = 1500

DMC.defaults =
{
    enabled = true,
    borderColor = { r = 0, g = 0, b = 0 },
    darkenBackgrounds = true,
    backgroundColor = { r = 0, g = 0, b = 0 },
}

local settings
local active = false
local initialized = false

local originals = setmetatable({}, { __mode = "k" })
local numTracked = 0

local roleCache = {}

local function GetRoleForTextureFile(rawFileName)
    if rawFileName == nil or rawFileName == "" then
        return nil
    end
    local role = roleCache[rawFileName]
    if role == nil then
        local normalized = string.lower(rawFileName)
        normalized = string.gsub(normalized, "\\", "/")
        role = TEXTURE_ROLES[normalized] or false
        roleCache[rawFileName] = role
    end
    if role then
        return role
    end
    return nil
end

local function ShouldApplyRole(role)
    if role == ROLE_BORDER then
        return true
    elseif role == ROLE_BACKGROUND then
        return settings.darkenBackgrounds
    end
    return false
end

local function GetColorForRole(role)
    if role == ROLE_BORDER then
        return settings.borderColor
    end
    return settings.backgroundColor
end

local function RestoreTexture(control, orig)
    control:SetDesaturation(orig.desat)
    control:SetColor(orig.r, orig.g, orig.b, orig.a)
    originals[control] = nil
    numTracked = numTracked - 1
end

local function ProcessTexture(control)
    local orig = originals[control]
    local role = GetRoleForTextureFile(control:GetTextureFileName())

    if role and ShouldApplyRole(role) then
        if not orig then
            local r, g, b, a = control:GetColor()
            orig = { kind = KIND_TEXTURE, r = r, g = g, b = b, a = a, desat = control:GetDesaturation() }
            originals[control] = orig
            numTracked = numTracked + 1
        end
        local color = GetColorForRole(role)
        control:SetDesaturation(1)
        control:SetColor(color.r, color.g, color.b, orig.a)
    elseif orig and orig.kind == KIND_TEXTURE then
        RestoreTexture(control, orig)
    end
end

local function RestoreBackdrop(control, orig)
    if orig.edgeApplied then
        control:SetEdgeColor(orig.er, orig.eg, orig.eb, orig.ea)
    end
    if orig.centerApplied then
        control:SetCenterColor(orig.cr, orig.cg, orig.cb, orig.ca)
    end
    originals[control] = nil
    numTracked = numTracked - 1
end

local function ProcessBackdrop(control)
    local orig = originals[control]
    local edgeRole = GetRoleForTextureFile(control:GetEdgeTextureFileName())
    local centerRole = GetRoleForTextureFile(control:GetCenterTextureFileName())
    local applyEdge = edgeRole and ShouldApplyRole(edgeRole)
    local applyCenter = centerRole and ShouldApplyRole(centerRole)

    if applyEdge or applyCenter then
        if not orig then
            local er, eg, eb, ea = control:GetEdgeColor()
            local cr, cg, cb, ca = control:GetCenterColor()
            orig =
            {
                kind = KIND_BACKDROP,
                er = er, eg = eg, eb = eb, ea = ea, edgeApplied = false,
                cr = cr, cg = cg, cb = cb, ca = ca, centerApplied = false,
            }
            originals[control] = orig
            numTracked = numTracked + 1
        end

        if applyEdge then
            local color = GetColorForRole(edgeRole)
            control:SetEdgeColor(color.r, color.g, color.b, orig.ea)
            orig.edgeApplied = true
        elseif orig.edgeApplied then
            control:SetEdgeColor(orig.er, orig.eg, orig.eb, orig.ea)
            orig.edgeApplied = false
        end

        if applyCenter then
            local color = GetColorForRole(centerRole)
            control:SetCenterColor(color.r, color.g, color.b, orig.ca)
            orig.centerApplied = true
        elseif orig.centerApplied then
            control:SetCenterColor(orig.cr, orig.cg, orig.cb, orig.ca)
            orig.centerApplied = false
        end
    elseif orig and orig.kind == KIND_BACKDROP then
        RestoreBackdrop(control, orig)
    end
end

local function ProcessControl(control)
    local controlType = control:GetType()
    if controlType == CT_TEXTURE then
        ProcessTexture(control)
    elseif controlType == CT_BACKDROP then
        ProcessBackdrop(control)
    end
end

local function ProcessSubtree(control, depth)
    ProcessControl(control)
    depth = depth or 0
    if depth > 12 then
        return
    end
    for i = 1, control:GetNumChildren() do
        local child = control:GetChild(i)
        if child then
            ProcessSubtree(child, depth + 1)
        end
    end
end

DMC.ProcessControl = ProcessControl
DMC.ProcessSubtree = ProcessSubtree

local SWEEP_UPDATE_NAME = DMC.name .. "_Sweep"
local sweepStack = {}
local sweepStackSize = 0
local sweepRunning = false
local sweepRequestedDuringRun = false
local lastSweepEndMs = 0
local pendingSweepCallId = nil

local StartSweep

local function StopSweep()
    if sweepRunning then
        EVENT_MANAGER:UnregisterForUpdate(SWEEP_UPDATE_NAME)
        sweepRunning = false
    end
    for i = sweepStackSize, 1, -1 do
        sweepStack[i] = nil
    end
    sweepStackSize = 0
end

local function SweepTick()
    if not active then
        StopSweep()
        return
    end

    local processed = 0
    while processed < CONTROLS_PER_TICK do
        if sweepStackSize == 0 then
            StopSweep()
            lastSweepEndMs = GetGameTimeMilliseconds()
            if sweepRequestedDuringRun then
                sweepRequestedDuringRun = false
                DMC.RequestSweep()
            end
            return
        end

        local control = sweepStack[sweepStackSize]
        sweepStack[sweepStackSize] = nil
        sweepStackSize = sweepStackSize - 1

        ProcessControl(control)

        for i = 1, control:GetNumChildren() do
            local child = control:GetChild(i)
            if child then
                sweepStackSize = sweepStackSize + 1
                sweepStack[sweepStackSize] = child
            end
        end
        processed = processed + 1
    end
end

local function SafeSweepTick()
    local ok, err = pcall(SweepTick)
    if not ok then
        StopSweep()
        lastSweepEndMs = GetGameTimeMilliseconds()
        d("[Dark Mode Console] sweep stopped: " .. tostring(err))
    end
end

StartSweep = function()
    if not active or sweepRunning then
        return
    end
    sweepStackSize = 1
    sweepStack[1] = GuiRoot
    sweepRunning = true
    EVENT_MANAGER:RegisterForUpdate(SWEEP_UPDATE_NAME, SWEEP_TICK_MS, SafeSweepTick)
end

function DMC.RequestSweep()
    if not active then
        return
    end
    if sweepRunning then
        sweepRequestedDuringRun = true
        return
    end
    if pendingSweepCallId then
        return
    end
    local elapsed = GetGameTimeMilliseconds() - lastSweepEndMs
    if elapsed >= SWEEP_COOLDOWN_MS then
        StartSweep()
    else
        pendingSweepCallId = zo_callLater(function()
            pendingSweepCallId = nil
            StartSweep()
        end, SWEEP_COOLDOWN_MS - elapsed)
    end
end

local function RestoreEverything()
    StopSweep()
    for control, orig in pairs(originals) do
        if orig.kind == KIND_TEXTURE then
            control:SetDesaturation(orig.desat)
            control:SetColor(orig.r, orig.g, orig.b, orig.a)
        else
            if orig.edgeApplied then
                control:SetEdgeColor(orig.er, orig.eg, orig.eb, orig.ea)
            end
            if orig.centerApplied then
                control:SetCenterColor(orig.cr, orig.cg, orig.cb, orig.ca)
            end
        end
        originals[control] = nil
    end
    numTracked = 0
end

local function ReapplyTracked()
    local tracked = {}
    for control in pairs(originals) do
        tracked[#tracked + 1] = control
    end
    for i = 1, #tracked do
        ProcessControl(tracked[i])
    end
end

local function ShouldBeActive()
    return initialized and settings.enabled and IsInGamepadPreferredMode()
end

local function UpdateActiveState()
    local shouldBeActive = ShouldBeActive()
    if shouldBeActive == active then
        return
    end
    active = shouldBeActive
    if active then
        StartSweep()
    else
        RestoreEverything()
    end
end

function DMC.Reapply()
    if not active then
        return
    end
    ReapplyTracked()
    DMC.RequestSweep()
end

function DMC.GetSettings()
    return settings
end

function DMC.IsEnabled()
    return settings and settings.enabled or false
end

function DMC.SetEnabled(enabled)
    settings.enabled = enabled and true or false
    UpdateActiveState()
end

function DMC.GetBorderColor()
    local c = settings.borderColor
    return c.r, c.g, c.b, 1
end

function DMC.SetBorderColor(r, g, b)
    settings.borderColor = { r = r, g = g, b = b }
    DMC.Reapply()
end

function DMC.GetBackgroundColor()
    local c = settings.backgroundColor
    return c.r, c.g, c.b, 1
end

function DMC.SetBackgroundColor(r, g, b)
    settings.backgroundColor = { r = r, g = g, b = b }
    DMC.Reapply()
end

function DMC.GetDarkenBackgrounds()
    return settings.darkenBackgrounds
end

function DMC.SetDarkenBackgrounds(darken)
    settings.darkenBackgrounds = darken and true or false
    DMC.Reapply()
end

function DMC.ResetToDefaults()
    local defaults = DMC.defaults
    settings.enabled = defaults.enabled
    settings.borderColor = ZO_ShallowTableCopy(defaults.borderColor)
    settings.backgroundColor = ZO_ShallowTableCopy(defaults.backgroundColor)
    settings.darkenBackgrounds = defaults.darkenBackgrounds
    UpdateActiveState()
    DMC.Reapply()
end

function DMC.GetNumTrackedControls()
    return numTracked
end

local function PostHook(objectTable, functionName, hookFunction)
    if SecurePostHook then
        SecurePostHook(objectTable, functionName, hookFunction)
    else
        ZO_PostHook(objectTable, functionName, hookFunction)
    end
end

local function InstallHooks()
    local originalCreateControlFromVirtual = CreateControlFromVirtual
    CreateControlFromVirtual = function(...)
        local control = originalCreateControlFromVirtual(...)
        if active and control then
            ProcessSubtree(control)
        end
        return control
    end

    PostHook(_G, "ApplyTemplateToControl", function(control)
        if active and control then
            ProcessSubtree(control)
        end
    end)

    if ZO_BuffDebuffStyleObject and ZO_BuffDebuffStyleObject.SetupIcon then
        PostHook(ZO_BuffDebuffStyleObject, "SetupIcon", function(styleObject, buffDebuffControl)
            if active and buffDebuffControl then
                local frame = buffDebuffControl:GetNamedChild("Frame")
                if frame then
                    ProcessTexture(frame)
                end
            end
        end)
    end

    if SCENE_MANAGER and SCENE_MANAGER.RegisterCallback then
        SCENE_MANAGER:RegisterCallback("SceneStateChanged", function(scene, oldState, newState)
            if newState == SCENE_SHOWING then
                DMC.RequestSweep()
            end
        end)
    end

    EVENT_MANAGER:RegisterForEvent(DMC.name, EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, function()
        UpdateActiveState()
        DMC.RequestSweep()
    end)

    EVENT_MANAGER:RegisterForEvent(DMC.name, EVENT_PLAYER_ACTIVATED, function()
        UpdateActiveState()
        DMC.RequestSweep()
    end)
end

local function OnSlashCommand(args)
    args = string.lower(zo_strtrim(args or ""))
    if args == "" or args == "toggle" then
        DMC.SetEnabled(not DMC.IsEnabled())
        d(string.format("[Dark Mode Console] %s", DMC.IsEnabled() and "enabled" or "disabled"))
    elseif args == "on" then
        DMC.SetEnabled(true)
        d("[Dark Mode Console] enabled")
    elseif args == "off" then
        DMC.SetEnabled(false)
        d("[Dark Mode Console] disabled")
    elseif args == "sweep" then
        DMC.RequestSweep()
        d("[Dark Mode Console] sweep requested")
    elseif args == "reset" then
        DMC.ResetToDefaults()
        d("[Dark Mode Console] settings reset to defaults")
    elseif args == "status" then
        d(string.format("[Dark Mode Console] v%s | enabled: %s | active: %s | gamepad mode: %s | recoloured controls: %d",
            DMC.version, tostring(DMC.IsEnabled()), tostring(active), tostring(IsInGamepadPreferredMode()), numTracked))
    else
        d("[Dark Mode Console] /darkmode [toggle|on|off|sweep|reset|status]")
    end
end

local function Initialize()
    settings = ZO_SavedVars:NewAccountWide(DMC.savedVarsName, DMC.savedVarsVersion, nil, DMC.defaults)
    initialized = true

    InstallHooks()

    SLASH_COMMANDS["/darkmode"] = OnSlashCommand
    SLASH_COMMANDS["/darkmodeconsole"] = OnSlashCommand

    UpdateActiveState()

    CALLBACK_MANAGER:FireCallbacks("DarkModeConsole_Initialized", DMC)
end

EVENT_MANAGER:RegisterForEvent(DMC.name .. "_Load", EVENT_ADD_ON_LOADED, function(eventCode, addonName)
    if addonName ~= DMC.name then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(DMC.name .. "_Load", EVENT_ADD_ON_LOADED)
    Initialize()
end)
