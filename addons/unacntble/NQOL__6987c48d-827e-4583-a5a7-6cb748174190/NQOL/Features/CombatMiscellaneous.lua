NQOL = NQOL or {}
NQOL.Features = NQOL.Features or {}

local CombatMiscellaneous = {}

local C = {
    CRUTCH_ADDON_NAME = "CrutchAlerts",
    LUCENT_CITADEL_ZONE_ID = 1478,
    ROTATION_OFFSET = 4,
}

local defaults = {
    combat = {
        miscellaneous = {
            lcCrutchMirrorsRotate = false,
        },
    },
}

local mirrorPositions = {
    OrphicNum1 = { number = 1, x = 149348, z = 85334 },
    OrphicNum2 = { number = 2, x = 151041, z = 86169 },
    OrphicNum3 = { number = 3, x = 151956, z = 87950 },
    OrphicNum4 = { number = 4, x = 151169, z = 89708 },
    OrphicNum5 = { number = 5, x = 149272, z = 90657 },
    OrphicNum6 = { number = 6, x = 147477, z = 89756 },
    OrphicNum7 = { number = 7, x = 146628, z = 87851 },
    OrphicNum8 = { number = 8, x = 147488, z = 86178 },
}

local savedVariables
local initialized = false
local crutchAlerts
local crutchHookInstalled = false
local originalTextures = setmetatable({}, { __mode = "k" })

local function GetSettings()
    local combat = NQOL.Settings.GetSection(savedVariables, defaults, "combat")
    if type(combat.miscellaneous) ~= "table" then
        combat.miscellaneous = {}
    end

    local settings = combat.miscellaneous
    NQOL.Settings.Boolean(settings, defaults.combat.miscellaneous, "lcCrutchMirrorsRotate")
    return settings
end

local function IsInLucentCitadel()
    if not GetUnitZoneIndex or not GetZoneId then
        return false
    end

    return GetZoneId(GetUnitZoneIndex("player")) == C.LUCENT_CITADEL_ZONE_ID
end

local function GetRotatedNumber(originalNumber)
    return ((originalNumber + C.ROTATION_OFFSET - 1) % 8) + 1
end

local function GetNumberTexture(number)
    return string.format("%s/assets/shape/diamond_red_%d.dds", C.CRUTCH_ADDON_NAME, number)
end

local function IsCompatibleCrutchAlerts(candidate)
    local drawing = type(candidate) == "table" and candidate.Drawing or nil
    return type(candidate) == "table"
        and type(candidate.EnableIcon) == "function"
        and type(drawing) == "table"
        and type(drawing.activeIcons) == "table"
end

local function ApplyMirrorIcon(mirror)
    if not mirror or not IsInLucentCitadel() or not IsCompatibleCrutchAlerts(crutchAlerts) then
        return
    end

    for _, icon in pairs(crutchAlerts.Drawing.activeIcons) do
        if icon.x == mirror.x and icon.z == mirror.z and type(icon.SetTexture) == "function" then
            originalTextures[icon] = originalTextures[icon] or icon.texture
            icon:SetTexture(GetNumberTexture(GetRotatedNumber(mirror.number)))
            return
        end
    end
end

local function ApplyMirrorIcons()
    if not IsInLucentCitadel() or not IsCompatibleCrutchAlerts(crutchAlerts) then
        return
    end

    for _, mirror in pairs(mirrorPositions) do
        ApplyMirrorIcon(mirror)
    end
end

local function RestoreMirrorIcons()
    for icon, texture in pairs(originalTextures) do
        if type(icon.SetTexture) == "function" then
            icon:SetTexture(texture)
        end
        originalTextures[icon] = nil
    end
end

local function InstallCrutchAlertsHook()
    if crutchHookInstalled or type(ZO_PostHook) ~= "function" then
        return
    end

    local candidate = _G and _G[C.CRUTCH_ADDON_NAME] or nil
    if not IsCompatibleCrutchAlerts(candidate) then
        return
    end

    crutchAlerts = candidate
    local originalEnableIcon = ZO_PostHook(crutchAlerts, "EnableIcon", function(iconName)
        if GetSettings().lcCrutchMirrorsRotate then
            ApplyMirrorIcon(mirrorPositions[iconName])
        end
    end)
    crutchHookInstalled = type(originalEnableIcon) == "function"
end

function CombatMiscellaneous.InitializeSavedVariables()
    savedVariables = NQOL.Settings.NewAccountWide(defaults)
    GetSettings()
end

function CombatMiscellaneous.Initialize()
    if initialized then
        return
    end

    initialized = true
    InstallCrutchAlertsHook()
    if GetSettings().lcCrutchMirrorsRotate then
        ApplyMirrorIcons()
    end
end

function CombatMiscellaneous.GetLCCrutchMirrorsRotate()
    return GetSettings().lcCrutchMirrorsRotate
end

function CombatMiscellaneous.GetLCCrutchMirrorsRotateDefault()
    return defaults.combat.miscellaneous.lcCrutchMirrorsRotate
end

function CombatMiscellaneous.IsCrutchAlertsAvailable()
    local candidate = crutchAlerts or (_G and _G[C.CRUTCH_ADDON_NAME] or nil)
    return IsCompatibleCrutchAlerts(candidate)
end

function CombatMiscellaneous.SetLCCrutchMirrorsRotate(value)
    local enabled = value == true
    GetSettings().lcCrutchMirrorsRotate = enabled
    if enabled then
        ApplyMirrorIcons()
    else
        RestoreMirrorIcons()
    end
end

function CombatMiscellaneous.GetLCCrutchMirrorsRotateLabel()
    return NQOL.L("features.combat_miscellaneous.lc_crutch_mirrors_rotate_label")
end

function CombatMiscellaneous.GetLCCrutchMirrorsRotateTooltip()
    return NQOL.L(
        "features.combat_miscellaneous.lc_crutch_mirrors_rotate_tooltip",
        GetZoneNameById(C.LUCENT_CITADEL_ZONE_ID)
    )
end

NQOL.Features.CombatMiscellaneous = CombatMiscellaneous
