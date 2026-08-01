KyzderpsDerps = KyzderpsDerps or {}
KyzderpsDerps.Integrations = KyzderpsDerps.Integrations or {}
local Integrations = KyzderpsDerps.Integrations
Integrations.name = KyzderpsDerps.name .. "Integrations"

---------------------------------------------------------------------
-- RAAAAAINBOW
---------------------------------------------------------------------
local function DisplayWarning(msg)
    local chatWarning = "|cFF0000W" ..
                        "|cFF7F00A" ..
                        "|cFFFF00R" ..
                        "|c00FF00N" ..
                        "|c0000FFI" ..
                        "|c2E2B5FN" ..
                        "|c8B00FFG" ..
                        "|cFF00FF: " .. msg .. "|r"
    CHAT_ROUTER:AddSystemMessage(chatWarning)
end

---------------------------------------------------------------------
-- Check specific zones
---------------------------------------------------------------------
local zoneToAddons = {
    [1082] = {
        {name = "BRHelper", author = "andy.s", enabled = function() return BRHelper ~= nil end, option = "checkBRHelper"},
    },
    [1000] = {
        {name = "Asylum Sanctorium Status Panel", author = "code65536", enabled = function() return AsylumNotifier ~= nil end, option = "checkAsylumStatusPanel"},
        {name = "Asylum Tracker", author = "init3", enabled = function() return AsylumTracker ~= nil end, option = "checkAsylumTracker"},
    },
    [1263] = {
        {name = "Qcell's Rockgrove Helper", author = "Qcell", enabled = function() return QRH ~= nil end, option = "checkQcellRockgroveHelper"},
        {name = "ExoYs Rockgroover", author = "ExoY", enabled = function() return Rockgroover ~= nil end, option = "checkExoysRockgroover"},
    },
    [1344] = {
        {name = "Qcell's Dreadsail Reef Helper", author = "Qcell", enabled = function() return QDRH ~= nil end, option = "checkQcellDreadsailReefHelper"},
    },
    [1427] = {
        {name = "Sanity's Edge Helper", author = "Wondernuts", enabled = function() return SEH ~= nil end, option = "checkSanitysEdgeHelper"},
    },
    [1051] = {
        {name = "HowToCloudrest", author = "Floliroy", enabled = function() return HowToCloudrest ~= nil end, option = "checkHowToCloudrest"},
    },
    [1121] = {
        {name = "HowToSunspire", author = "Floliroy", enabled = function() return HowToSunspire ~= nil end, option = "checkHowToSunspire"},
    },
    [1436] = {
        {name = "Infinite Archive Helper", author = "andy.s", enabled = function() return IAHelper ~= nil end, option = "checkIAHelper"},
    },
}

local function OnPlayerActivated()
    local zoneId = GetZoneId(GetUnitZoneIndex("player"))

    local requiredAddons = zoneToAddons[zoneId]
    if (not requiredAddons) then return end

    for _, addon in ipairs(requiredAddons) do
        if (not addon.enabled() and KyzderpsDerps.savedOptions.integrations[addon.option]) then
            DisplayWarning(string.format("%s is not enabled!", addon.name))
        end
    end
end

---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
function Integrations.Initialize()
    KyzderpsDerps:dbg("    Initializing EnabledAddons module...")

    EVENT_MANAGER:RegisterForEvent(Integrations.name .. "Activated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end

---------------------------------------------------------------------
-- Settings /script d(KyzderpsDerps.Integrations.zoneToAddons)
---------------------------------------------------------------------
function Integrations.GetSettings()
    local settings = {}

    for zoneId, requiredAddons in pairs(zoneToAddons) do
        local zoneName = GetZoneNameById(zoneId)
        for _, addon in ipairs(requiredAddons) do
            table.insert(settings, {
                type = "checkbox",
                name = string.format("Check %s by %s", addon.name, addon.author),
                tooltip = string.format("When entering %s, display a warning if %s is not enabled", zoneName, addon.name),
                default = false,
                getFunc = function() return KyzderpsDerps.savedOptions.integrations[addon.option] end,
                setFunc = function(value)
                    KyzderpsDerps.savedOptions.integrations[addon.option] = value
                end,
                width = "full",
            })
        end
    end

    return settings
end
