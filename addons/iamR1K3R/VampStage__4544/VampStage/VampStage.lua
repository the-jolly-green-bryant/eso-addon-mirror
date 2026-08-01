-- VampStage
-- Three independent elements: skull, stage label, timer.
-- Each movable, scalable, and toggleable independently.

local VampStage = {}
VampStage.name = "VampStage"

local SKULL_TEXTURE = "VampStage/skull.dds"

local defaults = {
    locked = true,
    skull  = { show=true, scale=1.0, x=100, y=100 },
    stage  = { show=true, scale=1.0, x=280, y=100 },
    timer  = { show=true, scale=1.0, x=280, y=160 },
}

local frames     = {}
local fragments  = {}
local tickHandle = nil

local function GetFont(scale, size)
    return "EsoUI/Common/Fonts/TrajanPro-Regular.slug|"..math.floor(size*scale).."|soft-shadow-thick"
end

local function FormatTime(s)
    if s <= 0 then return "0:00:00" end
    local h   = math.floor(s / 3600)
    local m   = math.floor((s % 3600) / 60)
    local sec = math.floor(s % 60)
    return string.format("%d:%02d:%02d", h, m, sec)
end

local function ScanBuffs()
    -- Collect all vampire stage buffs and return the lowest stage found.
    -- (The ult adds a stage 5 buff, but the real stage is lower.)
    local bestStage, bestEndTime = 0, 0
    for i = 1, GetNumBuffs("player") do
        local name, _, endTime, stack = GetUnitBuffInfo("player", i)
        if name and name ~= "" then
            local low = name:lower()
            if low:find("vampire stage") or low:find("vampirism") or low:find("noxiphilic") then
                local stage = tonumber(name:match("%d+$"))
                if not stage and stack and stack >= 1 and stack <= 5 then
                    stage = stack
                end
                if stage and stage >= 1 and stage <= 5 then
                    if bestStage == 0 or stage < bestStage then
                        bestStage   = stage
                        bestEndTime = endTime or 0
                    end
                end
            end
        end
    end
    return bestStage, bestEndTime
end

local function PlaceFrame(f, x, y)
    f:ClearAnchors()
    f:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

local function SavePos(f, key)
    VampStage.sv[key].x = f:GetLeft()
    VampStage.sv[key].y = f:GetTop()
end

local function MakeFrame(name, w, h, key)
    local f = WINDOW_MANAGER:GetControlByName(name)
    if not f then
        f = WINDOW_MANAGER:CreateTopLevelWindow(name)
    end
    local sv = VampStage.sv[key]
    f:SetDimensions(w, h)
    PlaceFrame(f, sv.x, sv.y)
    f:SetClampedToScreen(false)
    -- Start hidden; ZO_HUDFadeSceneFragment and SetHiddenForReason manage visibility.
    f:SetHidden(true)
    f:SetHandler("OnMoveStop", function()
        SavePos(f, key)
    end)
    frames[key] = f
    return f
end

-- Forward-declared so UpdateDisplay can be called from ApplyLock and BuildFragments.
local UpdateDisplay

local function ApplyLock()
    local locked = VampStage.sv.locked
    for _, f in pairs(frames) do
        f:SetMovable(not locked)
        f:SetMouseEnabled(not locked)
    end
    -- When unlocked, add frames to HUD_UI_SCENE so the user can drag them in
    -- cursor mode. When locked, remove them so they hide when any menu opens.
    for _, frag in pairs(fragments) do
        if locked then
            HUD_UI_SCENE:RemoveFragment(frag)
        else
            HUD_UI_SCENE:AddFragment(frag)
        end
    end
end

local stageLabel, timerLabel, skullTexture

UpdateDisplay = function()
    if not VampStage.sv then return end
    local stage, endTime = ScanBuffs()
    local sv = VampStage.sv

    if stage > 0 then
        -- Stage label
        if stageLabel then
            stageLabel:SetText("Stage " .. stage)
            stageLabel:SetColor(0.85, 0.05, 0.05, 1)
        end
        if fragments.stage then
            fragments.stage:SetHiddenForReason("userPref", not sv.stage.show)
            fragments.stage:SetHiddenForReason("mortal",   false)
        end

        -- Timer
        if timerLabel then
            local now       = GetGameTimeSeconds()
            local remaining = (endTime or 0) - now
            if remaining > 0 then
                timerLabel:SetText(FormatTime(remaining))
                local frac = math.max(0, math.min(1, remaining / 3600))
                timerLabel:SetColor(0.9, 0.25 * frac, 0.25 * frac, 1)
            else
                timerLabel:SetText("")
            end
        end
        if fragments.timer then
            fragments.timer:SetHiddenForReason("userPref", not sv.timer.show)
            fragments.timer:SetHiddenForReason("mortal",   false)
        end

        -- Skull
        if fragments.skull then
            fragments.skull:SetHiddenForReason("userPref", not sv.skull.show)
            fragments.skull:SetHiddenForReason("mortal",   false)
        end
    else
        -- Mortal state
        if stageLabel then
            stageLabel:SetText("Mortal")
            stageLabel:SetColor(0.55, 0.55, 0.55, 0.75)
        end
        if fragments.stage then
            fragments.stage:SetHiddenForReason("userPref", not sv.stage.show)
            fragments.stage:SetHiddenForReason("mortal",   false)
        end
        if timerLabel then timerLabel:SetText("") end
        -- Always hide timer and skull when mortal, regardless of user preference.
        if fragments.timer then fragments.timer:SetHiddenForReason("mortal", true) end
        if fragments.skull then fragments.skull:SetHiddenForReason("mortal", true) end
    end
end

local function BuildSkull()
    local sv   = VampStage.sv.skull
    local size = math.floor(128 * sv.scale)
    local f    = MakeFrame("VampStageSkull", size, size, "skull")

    skullTexture = WINDOW_MANAGER:GetControlByName("VampStageSkullTex")
    if not skullTexture then
        skullTexture = WINDOW_MANAGER:CreateControl("VampStageSkullTex", f, CT_TEXTURE)
    end
    skullTexture:SetTexture(SKULL_TEXTURE)
    skullTexture:SetDimensions(size, size)
    skullTexture:ClearAnchors()
    skullTexture:SetAnchor(TOPLEFT, f, TOPLEFT, 0, 0)
    skullTexture:SetDrawLayer(DL_CONTROLS)
end

local function BuildStage()
    local sv = VampStage.sv.stage
    local f  = MakeFrame("VampStageStageFrame",
                    math.floor(120 * sv.scale),
                    math.floor(30  * sv.scale), "stage")

    stageLabel = WINDOW_MANAGER:GetControlByName("VampStageStageLabel")
    if not stageLabel then
        stageLabel = WINDOW_MANAGER:CreateControl("VampStageStageLabel", f, CT_LABEL)
    end
    stageLabel:ClearAnchors()
    stageLabel:SetAnchor(CENTER, f, CENTER, 0, 0)
    stageLabel:SetFont(GetFont(sv.scale, 22))
    stageLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    stageLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    stageLabel:SetResizeToFitDescendents(false)
end

local function BuildTimer()
    local sv = VampStage.sv.timer
    local fw = math.floor(160 * sv.scale)
    local fh = math.floor(24  * sv.scale)
    local f  = MakeFrame("VampStageTimerFrame", fw, fh, "timer")

    timerLabel = WINDOW_MANAGER:GetControlByName("VampStageTimerLabel")
    if not timerLabel then
        timerLabel = WINDOW_MANAGER:CreateControl("VampStageTimerLabel", f, CT_LABEL)
    end
    timerLabel:ClearAnchors()
    timerLabel:SetAnchor(TOPLEFT, f, TOPLEFT, 0, 0)
    timerLabel:SetDimensions(fw, fh)
    timerLabel:SetFont(GetFont(sv.scale, 16))
    timerLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    timerLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
end

local function BuildAll()
    BuildSkull()
    BuildStage()
    BuildTimer()
end

-- ZO_HUDFadeSceneFragment (unlike ZO_SimpleSceneFragment) supports
-- SetHiddenForReason. That method stores hide reasons on the fragment itself,
-- so the frame stays hidden even when the scene becomes active. This prevents
-- the one-frame flash that ZO_SimpleSceneFragment causes when transitioning.
local function BuildFragments()
    for key, f in pairs(frames) do
        if not fragments[key] then
            fragments[key] = ZO_HUDFadeSceneFragment:New(f)
        end
        HUD_SCENE:AddFragment(fragments[key])
    end
end

local function StopTick()
    if tickHandle then zo_removeCallLater(tickHandle) tickHandle = nil end
end

local function StartTick()
    StopTick()
    local function Tick()
        UpdateDisplay()
        tickHandle = zo_callLater(Tick, 1000)
    end
    tickHandle = zo_callLater(Tick, 1000)
end

local function OnAddonLoaded(evt, addonName)
    if addonName ~= VampStage.name then return end
    -- Unregister immediately; this event only needs to fire once for VampStage.
    EVENT_MANAGER:UnregisterForEvent(VampStage.name, EVENT_ADD_ON_LOADED)

    -- Pass GetWorldName() as the 5th arg so NA, EU, and PTS each get their
    -- own saved variable block and do not overwrite each other.
    -- Version bumped to 8 because the storage key structure changed.
    VampStage.sv = ZO_SavedVars:NewAccountWide("VampStage_SavedVars", 8, nil, defaults, GetWorldName())

    BuildAll()
    BuildFragments()
    ApplyLock()
    UpdateDisplay()
    StartTick()

    EVENT_MANAGER:RegisterForEvent(VampStage.name, EVENT_PLAYER_DEACTIVATING, function()
        for key, f in pairs(frames) do
            SavePos(f, key)
        end
    end)

    EVENT_MANAGER:RegisterForEvent(VampStage.name, EVENT_EFFECT_CHANGED, function()
        zo_callLater(UpdateDisplay, 300)
    end)
    EVENT_MANAGER:RegisterForEvent(VampStage.name, EVENT_PLAYER_ACTIVATED, UpdateDisplay)

    SLASH_COMMANDS["/vamplock"] = function()
        VampStage.sv.locked = not VampStage.sv.locked
        ApplyLock()
        d("[VampStage] "..(VampStage.sv.locked and "Locked." or "Unlocked - drag each element freely."))
    end

    SLASH_COMMANDS["/vampdebug"] = function()
        d("[VampStage] scanning all buffs:")
        for i = 1, GetNumBuffs("player") do
            local name, _, endTime, stack = GetUnitBuffInfo("player", i)
            if name and name ~= "" then
                local low = name:lower()
                if low:find("vampire") or low:find("vampir") or low:find("noxiphilic") then
                    d(string.format("  HIT [%d] name=%s stack=%s parsed=%s",
                        i, name, tostring(stack), tostring(tonumber(name:match("%d+$")))))
                end
            end
        end
        local stage, endTime = ScanBuffs()
        local now = GetGameTimeSeconds()
        d(string.format("[VampStage] final: stage=%d remaining=%.0fs", stage, (endTime or 0)-now))
    end

    if LibAddonMenu2 then
        local LAM = LibAddonMenu2
        LAM:RegisterAddonPanel("VampStagePanel", {
            type        = "panel",
            name        = "VampStage",
            displayName = "VampStage",
            author      = "@R1K3R",
            version     = "1.4",
        })

        local function RebuildOption(key, buildFn)
            return function(v)
                VampStage.sv[key].scale = v
                buildFn()
                ApplyLock()
                UpdateDisplay()
            end
        end

        LAM:RegisterOptionControls("VampStagePanel", {
            { type="header", name="Position" },
            {
                type    = "checkbox",
                name    = "Lock All Positions",
                tooltip = "Uncheck to drag each element. Use /vamplock to toggle.",
                getFunc = function() return VampStage.sv.locked end,
                setFunc = function(v) VampStage.sv.locked = v ApplyLock() end,
                default = defaults.locked,
            },
            {
                type = "button",
                name = "Reset All Positions",
                func = function()
                    for k, d in pairs(defaults) do
                        if type(d) == "table" and d.x then
                            VampStage.sv[k].x = d.x
                            VampStage.sv[k].y = d.y
                        end
                    end
                    BuildAll()
                    ApplyLock()
                    UpdateDisplay()
                end,
            },
            { type="header", name="Skull Icon" },
            {
                type    = "checkbox",
                name    = "Show Skull",
                getFunc = function() return VampStage.sv.skull.show end,
                setFunc = function(v) VampStage.sv.skull.show = v UpdateDisplay() end,
                default = defaults.skull.show,
            },
            {
                type     = "slider",
                name     = "Skull Scale",
                min      = 0.5, max = 5.0, step = 0.1, decimals = 1,
                getFunc  = function() return VampStage.sv.skull.scale end,
                setFunc  = RebuildOption("skull", BuildSkull),
                default  = defaults.skull.scale,
            },
            { type="header", name="Stage Label" },
            {
                type    = "checkbox",
                name    = "Show Stage",
                getFunc = function() return VampStage.sv.stage.show end,
                setFunc = function(v) VampStage.sv.stage.show = v UpdateDisplay() end,
                default = defaults.stage.show,
            },
            {
                type     = "slider",
                name     = "Stage Scale",
                min      = 0.5, max = 5.0, step = 0.1, decimals = 1,
                getFunc  = function() return VampStage.sv.stage.scale end,
                setFunc  = RebuildOption("stage", BuildStage),
                default  = defaults.stage.scale,
            },
            { type="header", name="Timer" },
            {
                type    = "checkbox",
                name    = "Show Timer",
                getFunc = function() return VampStage.sv.timer.show end,
                setFunc = function(v) VampStage.sv.timer.show = v UpdateDisplay() end,
                default = defaults.timer.show,
            },
            {
                type     = "slider",
                name     = "Timer Scale",
                min      = 0.5, max = 5.0, step = 0.1, decimals = 1,
                getFunc  = function() return VampStage.sv.timer.scale end,
                setFunc  = RebuildOption("timer", BuildTimer),
                default  = defaults.timer.scale,
            },
        })
    end
end

EVENT_MANAGER:RegisterForEvent(VampStage.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
