BlackroseEscapePlan = BlackroseEscapePlan or {}
local BEP = BlackroseEscapePlan

BEP.name = "BlackroseEscapePlan"
BEP.version = "1.0.4"
BEP.zoneIdBlackrosePrison = 1082
BEP.sigilBlockDistanceSquared = 250000
BEP.sigilSuppressActive = false
BEP.markedUnits = {}
BEP.availableMarks = {
    [1] = true, [2] = true, [3] = true, [4] = true,
    [5] = true, [6] = true, [7] = true, [8] = true,
}
BEP.enemyMarkByUnitId = {}
BEP.markAssignmentDisabled = false


-- Enemy names keyed by Arena
-- BEP.enemiesByArena = {    
--         "imperial archer",
--         "imperial incinerator",
--         "imperial cleaver",
--         "imperial dread knight",
--         "battlemage ennodius",
--         "spider", 
--         "hoarvor", 
--         "crocodile", 
--         "beastmaster handler",
--         "river troll", 
--         "wamasu", 
--         "haj mota",
--         "tames-the-beast",
--         "infuser", 
--         "gargoyle", 
--         "bone colossus",
--         "lady minara",
--         "resurrected prisoner", 
--         "resurrected convict", 
--         "soul of void",
--         "vengeful revenant", 
--         "totem of stone", 
--         "drakeeh the unchained"
-- }


-- -- Enemy names keyed by Arena
BEP.enemiesByArena = {
    -- Arena 1 & 4
    ["1"] = {
        "imperial archer", "imperial cleaver", "imperial incinerator", "imperial dread knight", "battlemage ennodius"
    },
    -- Arena 2 & 4
    ["2"] = {
        "spider", "hoarvor", "crocodile", "beastmaster handler",
        "river troll", "wamasu", "haj mota", "tames-the-beast"
    },
    -- Arena 3 & 4
    ["3"] = {
        "infuser", "gargoyle", "bone colossus", "lady minara"
    }, 
    -- Arena 5
    ["4"] = {
        "resurrected prisoner", "resurrected convict", "soul of void",
        "vengeful revenant", "totem of stone", "drakeeh the unchained"
    },
}

BEP.allEnemies = {}

local function populateAllEnemies()
    -- Create a dictionary keyed by enemy name
    local enemySet = {}
    for _, arenaEnemies in pairs(BEP.enemiesByArena) do
        for _, enemyName in ipairs(arenaEnemies) do
            -- Lowercase keys if your tests lowercase enemyName
            enemySet[string.lower(enemyName)] = true
        end
    end
    BEP.allEnemies = enemySet
end

populateAllEnemies()

-- Sigil positions based on your original script (x,z world coords)
BEP.sigilPositions = {
    -- Stage 1
    {x=105503, z=68472},
    {x=103545, z=70273},
    {x=102270, z=68460},
    {x=103481, z=66399},
    -- Stage 2
    {x=90617,  z=64648},
    {x=90680,  z=61385},
    {x=88579,  z=63419},
    {x=92464,  z=63413},
    -- Stage 3
    {x=95695,  z=49335},
    {x=98946,  z=49484},
    {x=96982,  z=47314},
    {x=96895,  z=51214},
    -- Stage 4
    {x=108492, z=39068},
    {x=108615, z=35803},
    {x=106488, z=37808},
    {x=110357, z=37835},
    -- Boss
    {x=95937,  z=29143},
    {x=96564,  z=29130},
    {x=96665,  z=32326},
    {x=96026,  z=32322},
}

local availableMarkers = {
    TARGET_MARKER_TYPE_ONE,
    TARGET_MARKER_TYPE_FIVE,
    TARGET_MARKER_TYPE_TWO,
    TARGET_MARKER_TYPE_SEVEN,
    TARGET_MARKER_TYPE_SIX,
    TARGET_MARKER_TYPE_FOUR,
    TARGET_MARKER_TYPE_THREE,
    TARGET_MARKER_TYPE_EIGHT,
}

local usedMarkers = {}

-----------------------
-- Helper Functions --
-----------------------

-- Get current zone ID player is in
function BEP.IsInBlackrosePrison()
    local zoneId = GetZoneId(GetUnitZoneIndex("player"))
    return zoneId == BEP.zoneIdBlackrosePrison
end

-- Distance squared helper
local function DistSquared(x1, z1, x2, z2)
    return (x1 - x2)^2 + (z1 - z2)^2
end

-- Check if player is near any sigil location
function BEP.IsNearSigil()
    local _, px, _, pz = GetUnitWorldPosition("player")
    for _, pos in ipairs(BEP.sigilPositions) do
        if DistSquared(px, pz, pos.x, pos.z) < BEP.sigilBlockDistanceSquared then
            return true
        end
    end
    return false
end

-- Format time HH:MM:SS
local function GetTimeStamp()
    local h,m,s = GetGameTimeHoursMinutesSeconds()
    if not h or not m or not s then
        -- fallback to os.date, localization independent and always available
        return os.date("%H:%M:%S")
    end
    return string.format("%02d:%02d:%02d", h, m, s)
end


-- -- Print party chat message
-- function BEP.SendPartyChat(msg)
--     if IsUnitGrouped("player") then
--         d("[BlackroseEscapePlan] " .. msg) -- local debug
--         StartChatInput("/p " .. msg)
--         -- Send chat is not guaranteed with StartChatInput on all clients; alternative:
--         -- Use SendChatMessage if available:
--         SendChatMessage(msg, CHAT_CHANNEL_PARTY)
--     else
--         d("[BlackroseEscapePlan] Not in party: " .. msg)
--     end
-- end

-- Get enemy names for quick lookup set
function BEP.IsEnemyName(name)
    for _, ename in ipairs(BEP.allEnemies) do
        if ename == name then return true end
    end
    return false
end

-- Find next unused mark 1-8
function BEP.GetNextAvailableMark()
    for mark, available in pairs(BEP.availableMarks) do
        if available then
            return mark
        end
    end
    return nil
end

-- Assign mark on unitId
function BEP.AssignMark(unitId, mark)
    
    if not unitId or not mark then return end
    SetGroupMemberLeaderMarker(unitId, mark)
    BEP.availableMarks[mark] = false
    BEP.enemyMarkByUnitId[unitId] = mark
end

-- Clear mark on unitId
function BEP.ClearMark(unitId)
    if not unitId then return end
    local mark = BEP.enemyMarkByUnitId[unitId]
    if mark then
        ClearGroupMemberLeaderMarker(unitId)
        BEP.availableMarks[mark] = true
        BEP.enemyMarkByUnitId[unitId] = nil
    end
end

------------------------
-- EVENT HANDLERS ------
------------------------

local function GetUnusedMarker()
    -- Loop through 8 possible markers
    for i = 1, 8 do
        local index = i

        -- If not group leader, start from 5 to 8, then 1 to 4
        if not IsUnitGroupLeader("player") then
            index = i + 4
            if index > 8 then
                index = index - 8
            end
        end

        local marker = availableMarkers[index]
        -- If marker is not marked as used, return it immediately
        if marker and not usedMarkers[marker] then
            return marker
        end
    end

    -- No unused marker found, reset usedMarkers safely without reassigning the table reference
    for k in pairs(usedMarkers) do
        usedMarkers[k] = nil
    end

    -- Return a default marker depending on group leader status
    local fallbackMarker = IsUnitGroupLeader("player") and availableMarkers[1] or availableMarkers[1]
    return fallbackMarker
end

local function OnReticleChanged()
    -- Check if the target is valid
    if (not DoesUnitExist("reticleover")
        or IsUnitDead("reticleover")
        or GetUnitReaction("reticleover") ~= UNIT_REACTION_HOSTILE
        or GetUnitTargetMarkerType("reticleover") ~= TARGET_MARKER_TYPE_NONE) then
        return
    end

    local enemyName = string.lower(zo_strformat("<<1>>", GetUnitName("reticleover")))

    if not BEP.allEnemies then d("BEP.allEnemies nil") return end

    if BEP.allEnemies[enemyName] then
        local marker = GetUnusedMarker()
        if marker then
            usedMarkers[marker] = true
            AssignTargetMarkerToReticleTarget(marker)
        end
    end
end

-- Synergy ability changed hook for sigil block
local defaultSynergyHandler = nil
local function OnSynergyAbilityChanged(self)
    if BEP.IsInBlackrosePrison() then
        local _, px, _, pz = GetUnitWorldPosition("player")
        local inRange = BEP.IsNearSigil()

        -- Block picking sigil if in range
        if inRange then
            -- Suppress synergy ability usage by not calling default handler
            -- This effectively blocks synergy
            BEP.sigilSuppressActive = true
            -- Optional: Add visual or sound feedback here

            return -- DON'T call original handler
        end
    end

    if defaultSynergyHandler then
        return defaultSynergyHandler(self)
    end
end

-- Player activated event to register updates if needed
local function OnPlayerActivated(eventCode)
    if BEP.IsInBlackrosePrison() then
        d(string.format("[BEP] Blackrose Escape Plan activated. Version: %s", BEP.version))
    end
end

----------------------
-- SavedVars & Options --
----------------------

local function GetDefaults()
    return {
        -- UI toggle defaults
        MarkAssignmentEnabled = true,
        SigilBlockingEnabled = true,
        -- Legacy/unused but kept for compatibility
        markAssignmentDisabled = false,
    }
end

function BEP.LoadSettings()
    BEP.savedVars = ZO_SavedVars:NewAccountWide("BEP_SavedVariables", 1, nil, GetDefaults())
    -- Initialize runtime flags from saved variables
    BEP.MarkAssignmentEnabled = BEP.savedVars.MarkAssignmentEnabled
    BEP.SigilBlockingEnabled = BEP.savedVars.SigilBlockingEnabled
    BEP.markAssignmentDisabled = BEP.savedVars.markAssignmentDisabled
end

-- Create Options Menu
local function SetupOptionsMenu()
    local LAM = LibAddonMenu2 -- Assuming LibAddonMenu2 library is installed

    if not LAM then
        d("[BEP] LibAddonMenu2 not found; options menu disabled")
        return
    end

    local panelData = {
        type = "panel",
        name = "Blackrose Escape Plan",
        author = "Brossin",
        version = BEP.version,
        slashCommand = "/bep",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsData = { 
    {
        type = "checkbox",
        name = "Mark Priority Targets",
        tooltip = "When enabled, auto assigns priority marks on enemies in Blackrose Prison (still in development).",
        getFunc = function() return BEP.MarkAssignmentEnabled end,
        setFunc = function(value)
            BEP.MarkAssignmentEnabled = value
            BEP.savedVars.MarkAssignmentEnabled = value
            if value then
                d("[BEP] Priority mark assignment enabled.")
            else
                d("[BEP] Priority mark assignment disabled.")
            end
        end,
        disabled = function() return false end, -- refresh choices here
        width = "full",
        default = true,
    },
    {
        type = "checkbox",
        name = "Enable Sigil Suppression",
        tooltip = "When enabled, blocks sigil interaction in Blackrose Prison.",
        getFunc = function() return BEP.SigilBlockingEnabled end,
        setFunc = function(value)
            BEP.SigilBlockingEnabled = value
            BEP.savedVars.SigilBlockingEnabled = value
            if value then
                d("[BEP] Sigil blocking enabled.")
            else
                d("[BEP] Sigil blocking disabled.")
            end
        end,
        disabled = function() return false end,
        width = "full",
        default = true,
    }
}


    LAM:RegisterAddonPanel(BEP.name .. "Options", panelData)
    LAM:RegisterOptionControls(BEP.name .. "Options", optionsData)
end

-----------------------
-- Initialization -----
-----------------------

function BEP.Initialize()
    BEP.LoadSettings()

    -- Hook synergy ability changed
    if SYNERGY and SYNERGY.OnSynergyAbilityChanged then
        defaultSynergyHandler = SYNERGY.OnSynergyAbilityChanged
        SYNERGY.OnSynergyAbilityChanged = OnSynergyAbilityChanged
    else
        d("[BEP] WARNING: SYNERGY missing; synergy blocking will not work")
    end

    if BEP.SigilBlockingEnabled then
    -- Register events
    EVENT_MANAGER:RegisterForEvent(BEP.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    end


    -- Setup options (if LibAddonMenu2 installed)
    if LibAddonMenu2 then
        SetupOptionsMenu()
    else
        d("[BEP] LibAddonMenu2 is not loaded, options menu will not appear.")
    end


    if BEP.MarkAssignmentEnabled then
        -- Register listener
        EVENT_MANAGER:RegisterForEvent(BEP.name, EVENT_RETICLE_TARGET_CHANGED, OnReticleChanged)
    end
    
end

function BEP.UnregisterBlackroseEscapePlan()
    EVENT_MANAGER:UnregisterForEvent(BEP.name, EVENT_RETICLE_TARGET_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(BEP.name, EVENT_PLAYER_ACTIVATED)
end

EVENT_MANAGER:RegisterForEvent(BEP.name .. "_OnLoad", EVENT_ADD_ON_LOADED, function(event, addonName)
    if addonName == BEP.name then
        BEP.Initialize()
    end
end)


