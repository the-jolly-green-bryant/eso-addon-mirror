local KD = KyzderpsDerps
KD.MoreMarkers = {
    name = KD.name .. "MoreMarkers",
}
local MM = KD.MoreMarkers


---------------------------------------------------------------------
---------------------------------------------------------------------
local function IsOax()
    local _, powerMax = GetUnitPower("boss1", COMBAT_MECHANIC_FLAGS_HEALTH)
    if (powerMax == 125745480 or powerMax == 62872740 or powerMax == 19086236) then
        return true
    end
    return false
end

local function CheckBoss()
    local zoneId = GetZoneId(GetUnitZoneIndex("player"))
    if (zoneId ~= 1263) then return end -- Rockgrove only

    if (IsOax()) then
        M0RMarkers.loadProfile("Preset: vRG Oax Safe Zones")
    else
        M0RMarkers.unloadEverything()
    end
end


---------------------------------------------------------------------
---------------------------------------------------------------------
local function GetUnitNameIfExists(unitTag)
    if (DoesUnitExist(unitTag)) then
        return GetUnitName(unitTag)
    end
end

local prevBosses = ""
local function OnBossesChanged()
    local bossHash = ""

    for i = 1, BOSS_RANK_ITERATION_END do
        local name = GetUnitNameIfExists("boss" .. tostring(i))
        if (name and name ~= "") then
            bossHash = bossHash .. name
        end
    end

    -- Only trigger off bosses truly changing (sometimes the event fires for no apparent reason?)
    if (bossHash ~= prevBosses and (bossHash == "" or prevBosses == "")) then
        prevBosses = bossHash
        CheckBoss()
    end
end


---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
function MM.Initialize()
    if (not M0RMarkers or not M0RMarkers.loadProfile or not M0RMarkers.unloadEverything) then return end
    KD:dbg("    Initializing More Markers integrations...")

    local hookMM = KD.savedOptions.integrations.mmOax
    EVENT_MANAGER:UnregisterForEvent(MM.name .. "BossChanged", EVENT_BOSSES_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(MM.name .. "PlayerActivated", EVENT_PLAYER_ACTIVATED)
    if (hookMM) then
        EVENT_MANAGER:RegisterForEvent(MM.name .. "BossChanged", EVENT_BOSSES_CHANGED, OnBossesChanged)
        EVENT_MANAGER:RegisterForEvent(MM.name .. "BossChanged", EVENT_PLAYER_ACTIVATED, function() zo_callLater(CheckBoss, 500) end) -- hacky delay to happen after mm because lazy
    end
end

---------------------------------------------------------------------
-- Settings
---------------------------------------------------------------------
function MM.GetSettings()
    return {
        {
            type = "checkbox",
            name = "Only use Oax Safe Zone in RG",
            tooltip = "Loads only the \"Preset: vRG Oax Safe Zones\" preset when you are at Oaxiltso, otherwise loads no profiles in the rest of Rockgrove. Just because seeing the circles through the floor at Bahsei bothers me",
            default = false,
            getFunc = function() return KyzderpsDerps.savedOptions.integrations.mmOax end,
            setFunc = function(value)
                KyzderpsDerps.savedOptions.integrations.mmOax = value
                MM.Initialize()
            end,
            width = "full",
        },
    }
end
