RNGHateCounter = {
    name = "RNG Hate Counter",
    version = "1.6.3",
    author = "@Complicative",
    totalCount = 0,
    differentCount = 0,
    worldName = GetWorldName(),
    accountName = GetDisplayName(),
}

RNGHateCounter.Settings = {}

RNGHateCounter.Default = {
    throttle = 5,
    throttle1 = 0,
    throttle2 = 0,
    throttle3 = 0,
    timeStamp = true,
    squirrel1 = nil,
    squirrel2 = nil,
    squirrel3 = nil,
    buttonHidden = false,
    buttonLabelHidden = false,
    buttonX = 100,
    buttonY = 100,
}

local debug = false
local function cStart(hex)
    return "|c" .. hex
end

local function cEnd()
    return "|r"
end

local function getTimeStamp()
    local timeStamp = ""
    if RNGHateCounter.Settings.timeStamp then
        timeStamp = cStart(888888) .. "[" .. os.date('%H:%M:%S') .. "] " .. cEnd()
    end
    return timeStamp
end

function RNGHateCounter.GetCount()
    local totalCount = 0
    local differentCount = 0
    for _, v in pairs(RNGHateCounterData[RNGHateCounter.worldName][RNGHateCounter.accountName]) do
        totalCount = totalCount + v
        differentCount = differentCount + 1
    end
    return totalCount, differentCount
end

-------------------------------------------------------------------------------------------------
-- OnPlayerCombatState  --
-------------------------------------------------------------------------------------------------
function RNGHateCounter.CombatCallbacks(_, result, isError, aName, aGraphic, aActionSlotType, sName, sType, tName, tType
    , hitValue, pType, dType, log, sUnitId, tUnitId, abilityId, overflow)
    --Target must be an NPC (tType == 0) or dummy (tType == 4 (could include more))
    --Target must be an NPC (tType == 0) or dummy (tType == 4 (could include more))
    --Target must be an NPC (tType == 0) or dummy (tType == 4 (could include more))
    if (result ~= 2262 and result ~= 2260) then return end
    if tName == "" then return end
    if tType ~= 0 and tType ~= 4 then return end

    --local player = zo_strformat("<<1>>", sName)
    local squirrel = zo_strformat("<<1>>", tName)
    --posts stuff if debug is on
    --[[ if debug then
        if (result == 2262 or result == 2260) then
            d(getTimeStamp() ..
                sName .. "(" .. sType .. ")" .. " did " .. result .. " to " .. tName .. "(" .. tType .. ")")
        end
    end ]]

    -- 2262 -> kill with exp
    -- 2260 -> kill without exp (critters/dummy)

    RNGHateCounter.totalCount = RNGHateCounter.totalCount + 1
    -- Check if mob has is the table already
    if (RNGHateCounterData[RNGHateCounter.worldName][RNGHateCounter.accountName][squirrel] ~= nil) then
        -- Increment value by 1
        RNGHateCounterData[RNGHateCounter.worldName][RNGHateCounter.accountName][squirrel] = RNGHateCounterData[
        RNGHateCounter.worldName][RNGHateCounter.accountName][squirrel] + 1
    else
        -- Set value to 1
        RNGHateCounterData[RNGHateCounter.worldName][RNGHateCounter.accountName][squirrel] = 1
        RNGHateCounter.differentCount = RNGHateCounter.differentCount + 1
    end
    -- If it's a tracked mob or everything is posted
    if (
            (string.lower(squirrel) == string.lower(RNGHateCounter.Settings.squirrel1) and
                RNGHateCounterData[RNGHateCounter.worldName][RNGHateCounter.accountName][squirrel] %
                RNGHateCounter.Settings.throttle1 == 0 and
                RNGHateCounter.Settings.throttle1 >= 0)
            or
            (string.lower(squirrel) == string.lower(RNGHateCounter.Settings.squirrel2) and
                RNGHateCounterData[RNGHateCounter.worldName][RNGHateCounter.accountName][squirrel] %
                RNGHateCounter.Settings.throttle2 == 0 and
                RNGHateCounter.Settings.throttle2 >= 0)
            or
            (string.lower(squirrel) == string.lower(RNGHateCounter.Settings.squirrel3) and
                RNGHateCounterData[RNGHateCounter.worldName][RNGHateCounter.accountName][squirrel] %
                RNGHateCounter.Settings.throttle3 == 0 and
                RNGHateCounter.Settings.throttle3 >= 0)
            or
            (
                RNGHateCounter.Settings.throttle >= 0 and
                RNGHateCounterData[RNGHateCounter.worldName][RNGHateCounter.accountName][squirrel] %
                RNGHateCounter.Settings.throttle == 0)
        )
    -- and throttle rule allows to post
    then
        -- post mob + killed amount
        CHAT_SYSTEM:AddMessage(getTimeStamp() .. cStart("FFFFFF") ..
            squirrel ..
            " (" ..
            ZO_CommaDelimitNumber(RNGHateCounterData[RNGHateCounter.worldName][RNGHateCounter.accountName][squirrel])
            .. ")" .. cEnd())
    end
    RNGHCUI.UpdateButton()
    --RNGHCButtonControlButtonLabel:SetText(RNGHateCounter.totalCount)
end

-------------------------------------------------------------------------------------------------
-- Setup Saved Variables  --
-------------------------------------------------------------------------------------------------

function RNGHateCounter.SetupSV()
    RNGHateCounter.Settings = ZO_SavedVars:NewAccountWide("RNGHateCounterSettings", 2, nil, RNGHateCounter.Default)

    if not RNGHateCounterData then                              --New Structer not yet initialized
        RNGHateCounter.db = ZO_SavedVars:NewAccountWide("RNGHateCounterDB", 1, nil,
            { ["IteratableSavedVars"] = {}, migrated = false }) --Get old Data

        --Copy data from original structure, to 2nd structure
        if not RNGHateCounter.db.migrated then --If 2nd generation stucture doesn't exist
            for k, v in pairs(getmetatable(RNGHateCounter.db)["__index"]) do
                if type(k) == "string" and type(v) == "number" and k ~= "version" then
                    RNGHateCounter.db.IteratableSavedVars[k] = v
                    RNGHateCounter.db[k] = nil
                end
            end
            RNGHateCounter.db.migrated = true
        end

        --Create 3rd generation structure
        RNGHateCounterData = {}
        if not RNGHateCounterData[RNGHateCounter.worldName] then
            RNGHateCounterData[RNGHateCounter.worldName] = {}
        end
        if not RNGHateCounterData[RNGHateCounter.worldName][RNGHateCounter.accountName] then
            RNGHateCounterData[RNGHateCounter.worldName][RNGHateCounter.accountName] = {}
        end

        --Copy from second generation
        for k, v in pairs(RNGHateCounterDB["Default"]) do
            if not RNGHateCounterData[RNGHateCounter.worldName][k] then
                RNGHateCounterData[RNGHateCounter.worldName][k] = {}
            end
            for i, w in pairs(RNGHateCounterDB["Default"][k]["$AccountWide"]["IteratableSavedVars"]) do
                RNGHateCounterData[RNGHateCounter.worldName][k][i] = w
            end
        end

        --Delete second generation
        RNGHateCounterDB = nil
    end
    if not RNGHateCounterData[RNGHateCounter.worldName] then
        RNGHateCounterData[RNGHateCounter.worldName] = {}
    end
    if not RNGHateCounterData[RNGHateCounter.worldName][RNGHateCounter.accountName] then
        RNGHateCounterData[RNGHateCounter.worldName][RNGHateCounter.accountName] = {}
    end
    --if not RNGHateCounterData[RNGHateCounter.worldName] then RNGHateCounterData[RNGHateCounter.worldName] = {} end
end

-------------------------------------------------------------------------------------------------
-- OnAddOnLoaded  --
-------------------------------------------------------------------------------------------------

function RNGHateCounter.OnAddOnLoaded(event, addonName)
    if addonName ~= RNGHateCounter.name then return end
    EVENT_MANAGER:UnregisterForEvent(RNGHateCounter.name, EVENT_ADD_ON_LOADED)
    RNGHateCounter.SetupSV()

    RNGHateCounter.totalCount, RNGHateCounter.differentCount = RNGHateCounter.GetCount()

    RNGHCUI.Init()
    RNGHCOptions.Init()
end

-------------------------------------------------------------------------------------------------
-- OnAddOnLoaded End --
-------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------
-- General events and commands --
-------------------------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(RNGHateCounter.name, EVENT_COMBAT_EVENT, RNGHateCounter.CombatCallbacks)
EVENT_MANAGER:RegisterForEvent(RNGHateCounter.name, EVENT_ADD_ON_LOADED, RNGHateCounter.OnAddOnLoaded)

function RNGHateCounter.MainSlashCommand(squirrel)
    if (squirrel) == [[]] then --open UI
        RNGHCUI.Update()
        RNGHCUI.SetHidden(RNGHCUI.mainFragment, not
            RNGHCMainWindow:IsHidden())
    else --Output killcount of args
        local count = 0
        for k, v in pairs(RNGHateCounterData[RNGHateCounter.worldName][RNGHateCounter.accountName]) do
            if string.lower(k) == string.lower(squirrel) then
                count = v    --get kill amount
                squirrel = k --get proper Capitalisation
            end
        end
        -- Posts kills of <squirrel> var if existing


        CHAT_SYSTEM:AddMessage(getTimeStamp() .. cStart("FFFFFF") ..
            "You have killed " ..
            cStart("00BB00") ..
            zo_strformat("<<2>>" .. cEnd() .. cStart("FFFFFF") .. " <<m:1>>", squirrel, ZO_CommaDelimitNumber(count)) ..
            cEnd())
    end
end

SLASH_COMMANDS["/killcount"] = function(squirrel)
    RNGHateCounter.MainSlashCommand(squirrel)
end

SLASH_COMMANDS["/rnghatecounter"] = function(squirrel)
    RNGHateCounter.MainSlashCommand(squirrel)
end
