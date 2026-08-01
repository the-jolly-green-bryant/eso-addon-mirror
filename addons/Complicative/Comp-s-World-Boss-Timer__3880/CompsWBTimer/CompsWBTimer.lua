CompsWBTimer = {
    name = "CompsWBTimer",
    version = "1.0.2",
    author = "@Complicative",
    debug = false,
}

CompsWBTimerBossTimes = {}

CompsWBTimerBlackList = {
    --Geysers
    "Ruella Many-Claws",
    "Churug of the Abyss",
    "Sheefar of the Depths",
    "Girawell the Erratic",
    "Muustikar Wave-Eater",
    "Reefhammer",
    "Darkstorm the Alluring",
    "Eejoba the Radiant",
    "Tidewrack",
    "Vsskalvor",
    --Vents
    "Flame Hound Alpha",
    "Ashen Spriggan",
    "Fire Behemoth",
    "Molten Destroyer",
    "Fissure Goliath",
    --Mirrormoor Mosaic
    "Shrakkaher",
    "Rrarrvok",
    "Krrazzak"
}

local LAM2 = LibAddonMenu2
local mainFragment = ZO_SimpleSceneFragment:New(CompsWBTimerTLC)

CompsWBTimer.Settings = {}

CompsWBTimer.Default = {
    OffsetX = 100,
    OffsetY = 200,
    TimeoutDuration = 8,
}



local function cStart(hex) return "|c" .. hex end --returns colour start for a string

local function cEnd() return "|r" end             --return colour end string

local function colorText(text, hex)
    return cStart(hex) .. text .. cEnd()
end

local function formatTime(sec)
    return string.format("%02d:%02d", math.floor(sec / 60), (sec % 60))
end

local function GetCurrentZoneId()
    --returns Id of the zone the player is in right now
    return GetZoneId(GetUnitZoneIndex("player"))
end

local function tableContains(t, elem)
    for k, v in pairs(t) do
        if v == elem then return true end
    end
    return false
end

local function sortedTable(t)
    local tab = {}
    for k, v in pairs(CompsWBTimerBossTimes) do
        table.insert(tab, k)
    end
    table.sort(tab, function(a, b) return CompsWBTimerBossTimes[a] < CompsWBTimerBossTimes[b] end)
    return tab
end

function CompsWBTimer.updateTimer()
    local output = ""
    for k, v in ipairs(sortedTable(CompsWBTimerBossTimes)) do
        if CompsWBTimerBossTimes[v] - os.time() < -CompsWBTimer.Settings.TimeoutDuration then
            CompsWBTimerBossTimes[v] = nil
            break
        end
        local bossLine = ""
        if CompsWBTimerBossTimes[v] - os.time() > 0 then
            bossLine = formatTime(CompsWBTimerBossTimes[v] - os.time()) .. " " .. v .. "\n"
            if CompsWBTimerBossTimes[v] - os.time() < 60 then
                bossLine = colorText(bossLine, "FFAA00")
            end
        else
            bossLine = "-" ..
                formatTime(math.abs(CompsWBTimerBossTimes[v] - os.time())) .. " " .. v .. " is about to spawn!" .. "\n"
            bossLine = colorText(bossLine, "FF0000")
        end


        output = output .. bossLine
    end

    if not next(CompsWBTimerBossTimes) then
        EVENT_MANAGER:UnregisterForUpdate(CompsWBTimer.name .. "Boss Tracker")
    end
    CompsWBTimerTLCLabel:SetText(output)
end

function CompsWBTimer.savePosition()
    CompsWBTimer.Settings.OffsetX = CompsWBTimerTLC:GetLeft()
    CompsWBTimer.Settings.OffsetY = CompsWBTimerTLC:GetTop()
end

function CompsWBTimer.UnitDeathCallback(event, uTag, isDead)
    if not isDead then return end
    if not uTag or uTag == "" then return end
    if GetCurrentZoneDungeonDifficulty() ~= 0 then return end                     --Prevents Dungeons, Trials and IA
    if not string.find(uTag, "boss") then return end
    if tableContains(CompsWBTimerBlackList, GetUnitName("boss1")) then return end --Prevents blacklist (geysers, vents)

    local respawnTime = 300
    if GetCurrentZoneId() == 1133 then respawnTime = 600 end --SE WB Cat

    for i = 1, 6 do
        --return if not all existing bosses are dead
        if GetUnitName("boss" .. tostring(i)) and GetUnitName("boss" .. tostring(i)) ~= "" and not IsUnitDead("boss" .. tostring(i)) then return end
    end

    CompsWBTimer.AddTimer(GetUnitName("boss1"), respawnTime)
end

function CompsWBTimer.ManualAdd(name)
    local respawnTime = 300
    if GetCurrentZoneId() == 1133 then respawnTime = 570 end --Aegis boss in SE has 09:30 respawn time

    if name == "" then
        local bossesAmount = 0
        for k, v in pairs(CompsWBTimerBossTimes) do bossesAmount = bossesAmount + 1 end

        name = "Boss" .. tostring(bossesAmount + 1)
    end

    CompsWBTimer.AddTimer(name, respawnTime)
end

function CompsWBTimer.AddTimer(name, respawnTime)
    CompsWBTimerBossTimes[name] = os.time() +
        respawnTime                                                                                     --adds the timer entry
    EVENT_MANAGER:RegisterForUpdate(CompsWBTimer.name .. "Boss Tracker", 500, CompsWBTimer.updateTimer) --Starts timer
end

function CompsWBTimer.SettingsInit()
    local panelData = {
        type = "panel",
        name = "Comp's WB Timer",
        author = 'Complicative',
        version = CompsWBTimer.version,
        website = "https://www.esoui.com/downloads/author-68201.html"
    }

    LAM2:RegisterAddonPanel("CompsWBTimerOptions", panelData)

    local optionsData = {}
    optionsData[#optionsData + 1] = {
        type = "slider",
        name = "Timeout Duration",
        tooltip = "How long to keep a boss in the list after the timer ran out (Default: 8 seconds)",
        getFunc = function() return CompsWBTimer.Settings.TimeoutDuration end,
        setFunc = function(value) CompsWBTimer.Settings.TimeoutDuration = value end,
        min = 0,
        max = 15,
        step = 1,
    }
    LAM2:RegisterOptionControls("CompsWBTimerOptions", optionsData)
end

function CompsWBTimer.OnAddOnLoaded(event, addonName) --initialize the addon
    if addonName ~= CompsWBTimer.name then return end
    EVENT_MANAGER:UnregisterForEvent(CompsWBTimer.name, EVENT_ADD_ON_LOADED)

    HUD_SCENE:AddFragment(mainFragment)
    HUD_UI_SCENE:AddFragment(mainFragment)

    CompsWBTimer.Settings = ZO_SavedVars:NewAccountWide(CompsWBTimer.name .. "Settings", 1, nil, CompsWBTimer.Default)

    CompsWBTimer.SettingsInit()

    CompsWBTimerTLC:ClearAnchors()
    CompsWBTimerTLC:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, CompsWBTimer.Settings.OffsetX,
        CompsWBTimer.Settings.OffsetY)

    EVENT_MANAGER:RegisterForEvent(CompsWBTimer.name, EVENT_UNIT_DEATH_STATE_CHANGED, CompsWBTimer.UnitDeathCallback)
end

EVENT_MANAGER:RegisterForEvent(CompsWBTimer.name, EVENT_ADD_ON_LOADED, CompsWBTimer.OnAddOnLoaded)

ZO_CreateStringId("SI_BINDING_NAME_COMPS_WB_TIMER_MANUAL_BOSS",
    "Add boss timer manually")

SLASH_COMMANDS["/wbtimer"] = function(args)
    CompsWBTimer.ManualAdd(args)
end
