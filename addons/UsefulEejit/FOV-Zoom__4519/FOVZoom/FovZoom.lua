-- FovZoom
-- Keybind-based FOV zoom for both first and third person.
-- Bind "FOV Zoom" under Controls > FovZoom.
--
-- Writes to BOTH FOV channels simultaneously on every frame, so there is no
-- need to detect which camera mode is active (CAMERA_SETTING_DISTANCE stores
-- the saved 3P distance, not 0 in first person, making detection unreliable).
-- Each channel uses its own independently configurable zoom target.

FovZoom = {}
local addon = FovZoom

ZO_CreateStringId("SI_BINDING_NAME_FOVZOOM_ZOOM", "FOV Zoom")

addon.defaults = {
    zoomFovFirstPerson = 50,
    zoomFovThirdPerson = 50,
}

-- ============================================================
--  FOV helpers
--  Internal = display / 2.  UI range: internal 35-65 = display 70-130.
--  Sub-35 writes are accepted by the renderer even though readback clamps.
-- ============================================================
local FOV_INTERNAL_MAX = 65

local function ToInternal(displayDeg)
    local v = displayDeg / 2.0
    if v > FOV_INTERNAL_MAX then v = FOV_INTERNAL_MAX end
    return v
end

local function ReadFovInternal(fovSetting)
    local val = tonumber(GetSetting(SETTING_TYPE_CAMERA, fovSetting))
    if val and val > 0 then return val end
    return 50
end

local function WriteBothFov(fpInternal, tpInternal)
    for i = 1, 50 do
        SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_FIRST_PERSON_FIELD_OF_VIEW, tostring(fpInternal))
        SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_FIELD_OF_VIEW, tostring(tpInternal))
    end
end

-- ============================================================
--  Smoothing kill
-- ============================================================
local saved = {}

local function DisableSmoothing()
    saved.mouseSmoothing = GetCVar("MouseSmoothing")
    saved.camTransition  = GetCVar("CameraFramingTransitionEnabled")
    saved.gpuSmoothing   = GetCVar("GPUSmoothingFrames")
    saved.assassinCam    = GetCVar("AssassinationKillCamera")
    saved.camSmooth      = GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_SMOOTHING)
    SetCVar("MouseSmoothing",                 "0")
    SetCVar("CameraFramingTransitionEnabled",  "0")
    SetCVar("GPUSmoothingFrames",              "0")
    SetCVar("AssassinationKillCamera",         "0")
    SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_SMOOTHING, "0")
end

local function RestoreSmoothing()
    if saved.mouseSmoothing then SetCVar("MouseSmoothing",                saved.mouseSmoothing) end
    if saved.camTransition  then SetCVar("CameraFramingTransitionEnabled", saved.camTransition)  end
    if saved.gpuSmoothing   then SetCVar("GPUSmoothingFrames",             saved.gpuSmoothing)   end
    if saved.assassinCam    then SetCVar("AssassinationKillCamera",        saved.assassinCam)    end
    if saved.camSmooth      then SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_SMOOTHING, saved.camSmooth) end
    saved = {}
end

-- ============================================================
--  State
-- ============================================================
local sv          = nil
local isReady     = false
local zoomed      = false
local baseFovFP   = 50
local baseFovTP   = 50
local targetFovFP = 25
local targetFovTP = 25

local function OnUpdate()
    for i = 1, 5 do
        SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_FIRST_PERSON_FIELD_OF_VIEW, tostring(targetFovFP))
        SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_FIELD_OF_VIEW, tostring(targetFovTP))
    end
    if RETICLE then
        RETICLE.reticleOpenCloseTimeline:PlayForward()
    end
end

local function HookReticle()
    if not ZO_Reticle then return end
    SecurePostHook(ZO_Reticle, "OnUpdate", function(self, _)
        if zoomed then
            self.reticleOpenCloseTimeline:PlayForward()
        end
    end)
end

-- ============================================================
--  Keybind callbacks
-- ============================================================

function FovZoom.OnZoomDown()
    if not isReady or zoomed then return end

    baseFovFP   = ReadFovInternal(CAMERA_SETTING_FIRST_PERSON_FIELD_OF_VIEW)
    baseFovTP   = ReadFovInternal(CAMERA_SETTING_THIRD_PERSON_FIELD_OF_VIEW)
    targetFovFP = ToInternal(sv.zoomFovFirstPerson)
    targetFovTP = ToInternal(sv.zoomFovThirdPerson)

    local fpWillZoom = targetFovFP < baseFovFP
    local tpWillZoom = targetFovTP < baseFovTP

    if not fpWillZoom and not tpWillZoom then
        CHAT_SYSTEM:AddMessage(
            "|cFFAAAAFovZoom|r: zoom targets are not less than your current FOVs. "
            .. "Lower the zoom targets in the settings panel."
        )
        return
    end

    -- Don't disturb a channel that doesn't need to zoom
    if not fpWillZoom then targetFovFP = baseFovFP end
    if not tpWillZoom then targetFovTP = baseFovTP end

    zoomed = true
    DisableSmoothing()
    WriteBothFov(targetFovFP, targetFovTP)
    EVENT_MANAGER:RegisterForUpdate("FovZoomHold", 0, OnUpdate)
end

function FovZoom.OnZoomUp()
    if not isReady or not zoomed then return end
    zoomed = false
    EVENT_MANAGER:UnregisterForUpdate("FovZoomHold")
    WriteBothFov(baseFovFP, baseFovTP)
    RestoreSmoothing()
    if RETICLE then
        RETICLE.reticleOpenCloseTimeline:PlayBackward()
    end
end

-- ============================================================
--  LibAddonMenu-2.0 settings panel
-- ============================================================
local function BuildSettingsPanel()
    local LAM2 = LibAddonMenu2
    if not LAM2 then return end

    LAM2:RegisterAddonPanel("FovZoom_Options", {
        type                = "panel",
        name                = "FOV Zoom",
        displayName         = "|cAAFFAAFOV Zoom|r",
        author              = "UsefulEejit",
        version             = "1.0",
        registerForDefaults = true,
    })

    LAM2:RegisterOptionControls("FovZoom_Options", {
        {
            type = "description",
            text = "Hold 'FOV Zoom' (bind under Controls > FovZoom) to zoom in; release to restore. "
                .. "Both channels are written simultaneously so switching perspective mid-hold works. "
                .. "Lower zoom FOV = more zoomed in.",
        },
        {
            type    = "slider",
            name    = "First Person Zoom FOV",
            tooltip = "Target display FOV when zoomed in first person. Lower = more zoomed in. Default: 50.",
            min     = 10,
            max     = 128,
            step    = 2,
            default = addon.defaults.zoomFovFirstPerson,
            getFunc = function() return sv.zoomFovFirstPerson end,
            setFunc = function(val) sv.zoomFovFirstPerson = val end,
        },
        {
            type    = "slider",
            name    = "Third Person Zoom FOV",
            tooltip = "Target display FOV when zoomed in third person. Lower = more zoomed in. Default: 50.",
            min     = 10,
            max     = 128,
            step    = 2,
            default = addon.defaults.zoomFovThirdPerson,
            getFunc = function() return sv.zoomFovThirdPerson end,
            setFunc = function(val) sv.zoomFovThirdPerson = val end,
        },
    })
end

-- ============================================================
--  Initialisation
-- ============================================================
local function OnAddonLoaded(_, addonName)
    if addonName ~= "FovZoom" then return end
    EVENT_MANAGER:UnregisterForEvent("FovZoom", EVENT_ADD_ON_LOADED)

    addon.savedVars = ZO_SavedVars:New("FovZoom_SavedVars", 15, nil, addon.defaults)
    sv = addon.savedVars

    isReady = true
    BuildSettingsPanel()
    HookReticle()

    zo_callLater(function()
        local fpFov = ReadFovInternal(CAMERA_SETTING_FIRST_PERSON_FIELD_OF_VIEW)
        local tpFov = ReadFovInternal(CAMERA_SETTING_THIRD_PERSON_FIELD_OF_VIEW)
        CHAT_SYSTEM:AddMessage(
            "|cAAFFAAFovZoom|r loaded.  "
            .. "1P base: " .. tostring(fpFov * 2) .. "°  "
            .. "3P base: " .. tostring(tpFov * 2) .. "°  "
            .. "1P zoom: " .. tostring(sv.zoomFovFirstPerson) .. "°  "
            .. "3P zoom: " .. tostring(sv.zoomFovThirdPerson) .. "°"
        )
    end, 2000)
end

EVENT_MANAGER:RegisterForEvent("FovZoom", EVENT_ADD_ON_LOADED, OnAddonLoaded)
