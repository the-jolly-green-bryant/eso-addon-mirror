local DVDScreenSaver = {}
DVDScreenSaver.name = "DVDScreenSaver"

-- === Settings ===
local updateDelay = 10    -- ms between updates (~100 fps)

-- Table to track each bar's state
local bars = {}

-- Default settings
local defaultSettings = {
    lockHealth = false,
    lockMagicka = false,
    lockStamina = false,
    speedHealth = 2.5,
    speedMagicka = 2.5,
    speedStamina = 2.5,
}

local settings

-- Get screen dimensions
local function GetScreenBounds()
    return GuiRoot:GetWidth(), GuiRoot:GetHeight()
end

-- Move one bar
local function MoveBar(barData)
    if barData.locked then return end -- skip locked bars

    local bar = barData.control
    if not (bar and bar.GetLeft and bar.GetTop) then return end

    local x, y = bar:GetLeft(), bar:GetTop()
    local w, h = bar:GetWidth(), bar:GetHeight()
    local screenW, screenH = GetScreenBounds()

    local moveSpeed = barData.speed or 2.5

    -- Update position
    x = x + moveSpeed * barData.xDir
    y = y + moveSpeed * barData.yDir

    -- Check horizontal walls
    if x <= 0 then
        x = 0
        barData.xDir = 1
    elseif x + w >= screenW then
        x = screenW - w
        barData.xDir = -1
    end

    -- Check vertical walls
    if y <= 0 then
        y = 0
        barData.yDir = 1
    elseif y + h >= screenH then
        y = screenH - h
        barData.yDir = -1
    end

    -- Apply position
    bar:ClearAnchors()
    bar:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

-- Main loop: move all bars
local function MoveBars()
    for _, barData in ipairs(bars) do
        MoveBar(barData)
    end
end

-- Initialize resource bars
local function InitBars()
    bars = {}

    local function AddBar(control, lockSettingName, speedSettingName)
        if not control then return end
        local xDir = math.random(0,1) == 1 and 1 or -1
        local yDir = math.random(0,1) == 1 and 1 or -1
        table.insert(bars, { 
            control = control, 
            xDir = xDir, 
            yDir = yDir, 
            lockSettingName = lockSettingName,
            speedSettingName = speedSettingName,
            locked = settings[lockSettingName],
            speed = settings[speedSettingName]
        })
    end

    AddBar(ZO_PlayerAttributeHealth, "lockHealth", "speedHealth")
    AddBar(ZO_PlayerAttributeMagicka, "lockMagicka", "speedMagicka")
    AddBar(ZO_PlayerAttributeStamina, "lockStamina", "speedStamina")
end

-- Update bar lock and speed settings when settings change
local function UpdateBarSettings()
    for _, barData in ipairs(bars) do
        barData.locked = settings[barData.lockSettingName]
        barData.speed = settings[barData.speedSettingName]
    end
end

-- === Settings Menu ===
local function CreateSettingsMenu()
    if not LibAddonMenu2 then return end
    local panelData = {
        type = "panel",
        name = DVDScreenSaver.name,
        displayName = DVDScreenSaver.name,
        author = "Phamo 1000",
        version = "1.3.1",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsTable = {
        -- Lock checkboxes
        {
            type = "checkbox",
            name = "Lock Health",
            tooltip = "Prevents the Health bar from moving",
            getFunc = function() return settings.lockHealth end,
            setFunc = function(value) settings.lockHealth = value; UpdateBarSettings() end,
        },
        {
            type = "checkbox",
            name = "Lock Magicka",
            tooltip = "Prevents the Magicka bar from moving",
            getFunc = function() return settings.lockMagicka end,
            setFunc = function(value) settings.lockMagicka = value; UpdateBarSettings() end,
        },
        {
            type = "checkbox",
            name = "Lock Stamina",
            tooltip = "Prevents the Stamina bar from moving",
            getFunc = function() return settings.lockStamina end,
            setFunc = function(value) settings.lockStamina = value; UpdateBarSettings() end,
        },

        -- Speed sliders
        {
            type = "slider",
            name = "Health Movement Speed",
            min = 0.5,
            max = 10,
            step = 0.1,
            getFunc = function() return settings.speedHealth end,
            setFunc = function(value) settings.speedHealth = value; UpdateBarSettings() end,
        },
        {
            type = "slider",
            name = "Magicka Movement Speed",
            min = 0.5,
            max = 10,
            step = 0.1,
            getFunc = function() return settings.speedMagicka end,
            setFunc = function(value) settings.speedMagicka = value; UpdateBarSettings() end,
        },
        {
            type = "slider",
            name = "Stamina Movement Speed",
            min = 0.5,
            max = 10,
            step = 0.1,
            getFunc = function() return settings.speedStamina end,
            setFunc = function(value) settings.speedStamina = value; UpdateBarSettings() end,
        },
    }

    LibAddonMenu2:RegisterAddonPanel(DVDScreenSaver.name .. "_Panel", panelData)
    LibAddonMenu2:RegisterOptionControls(DVDScreenSaver.name .. "_Panel", optionsTable)
end

-- On addon load
function DVDScreenSaver.OnAddOnLoaded(_, addonName)
    if addonName ~= DVDScreenSaver.name then return end
    EVENT_MANAGER:UnregisterForEvent(DVDScreenSaver.name, EVENT_ADD_ON_LOADED)

    -- Initialize saved variables
    settings = ZO_SavedVars:NewAccountWide("DVDScreenSaverSavedVars", 1, nil, defaultSettings)

    math.randomseed(GetFrameTimeMilliseconds())

    InitBars()
    CreateSettingsMenu()
    EVENT_MANAGER:RegisterForUpdate(DVDScreenSaver.name .. "_MoveLoop", updateDelay, MoveBars)
end

EVENT_MANAGER:RegisterForEvent(DVDScreenSaver.name, EVENT_ADD_ON_LOADED, DVDScreenSaver.OnAddOnLoaded)
