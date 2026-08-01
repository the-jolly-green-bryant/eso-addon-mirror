-- AutoLootKey addon
-- Author: Goemaat
-- Public Domain
--[[
    This addon toggles the game setting for autoloot when you have the shift key held down.
    So if you have autoloot enabled, hold down the shift key when looting to bring up 
    the loot dialog.  If you have autoloot disabled, hold the shift key down when looting
    to automatically loot.
--]]

ALK = {}

ALK.name = "AutoLootKey"
ALK.version = "0.1"
ALK.initialized = false
ALK.defaults = {} -- no settings, planning for the future

function ALK.Initialize(eventCode, addOnName)
    -- Only initialize our own addon
    if (ALK.name ~= addOnName) then return end

    -- get the game setting value
    ALK.gameSetting = GetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT)
    ALK.oldSetting = ALK.gameSetting
    ALK.initialized = true
    ALK.shiftDown = false
    ALK.updateCount = 0 -- debugging
    ALK.changeCount = 0 -- debugging
    ALK.actualCount = 0 -- debugging

    -- Load the saved variables
    ALK.vars = ZO_SavedVars:NewAccountWide("ALK_SavedVariables", 1, nil, ALK.defaults)

    -- Invoke config menu set-up
    -- ALK.CreateConfigMenu()
    d("AutoLootKey: Initialized")
end -- ALK.Initialise


EVENT_MANAGER:RegisterForEvent("AutoLootKey", EVENT_ADD_ON_LOADED, ALK.Initialize)


-- SLASH COMMAND FUNCTIONALITY
-- Typing /alk as a command will activate this function. Primarily used for testing.
function ALK_slash(extra)
    d("ALK_slash - extra is:")
    d(extra)
    d("ALK_slash - values are:")
    d({ update = ALK.updateCount, change = ALK.changeCount, actual = ALK.actualCount })
end -- AIslash
 
SLASH_COMMANDS["/alk"] = ALK_slash

function ALK.OnUpdate()
    -- Bail if we haven't completed the initialisation routine yet.
    if (not ALK.initialized) then return end

    ALK.updateCount = ALK.updateCount + 1

    -- check if shift key is pressed
    local currentShiftDown = IsShiftKeyDown()
    if currentShiftDown ~= ALK.shiftDown then
        ALK.shiftDown = currentShiftDown
        ALK.changeCount = ALK.changeCount + 1

        local currentSetting = GetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT)
        SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT, 1 - currentSetting)
        ALK.actualCount = ALK.actualCount + 1

--[[ old way
        local newSetting = ALK.gameSetting
        if currentShiftDown then newSetting = 1 - newSetting end

        if (newSetting ~= ALK.oldSetting) then
            -- change setting
            --d({autoloot = newSetting})
            SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT, newSetting)
            ALK.oldSetting = newSetting

            ALK.actualCount = ALK.actualCount + 1
        end
--]]
    end
end -- ALK.OnUpdate

-- EOF
