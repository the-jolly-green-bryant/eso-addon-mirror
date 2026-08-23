local NWAimCam = {}
NWAimCam.name = "NWAimCam"
NWAimCam.version = "1.5"

local isAiming = false
local savedDistance = "130"
local aimTimer = 0
local debugMode = false

-- Base Weapon Ability IDs
local WEAPON_IDS = {
    BOW = { 16691 },
    DESTRUCTION = { 15383, 16261, 18396 }, -- Inferno, Ice, Lightning
    RESTORATION = { 16212 }
}

-- Default account-wide settings
local defaultSettings = {
    enabled = true,
    enableBow = true,
    enableDestruction = true,
    enableRestoration = true,
    aimDistance = "0",
    maxFOV = 130,
    hOffset = 34,
    failsafeTime = 1.25,
    customSkills = {}, -- Table structure: [abilityId] = "Custom Name"
}

local tempSkillInput = ""
local tempNameInput = ""

-- Centralized camera reset routine
local function ResetCamera()
    if isAiming then
        SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE, savedDistance)
        isAiming = false
        EVENT_MANAGER:UnregisterForUpdate(NWAimCam.name .. "Update")
    end
end

-- Timer logic for failsafe auto zoom out
function NWAimCam.OnUpdate()
    aimTimer = aimTimer + 50
    if aimTimer > (NWAimCam.savedVars.failsafeTime * 1000) then
        ResetCamera()
    end
end

-- Triggered strictly when a heavy attack or registered ability starts
function NWAimCam.OnCombatEventBegin(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
    if not isAiming then
        savedDistance = GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE)
        SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE, NWAimCam.savedVars.aimDistance)
        isAiming = true
        aimTimer = 0
        EVENT_MANAGER:RegisterForUpdate(NWAimCam.name .. "Update", 50, NWAimCam.OnUpdate)
    else
        aimTimer = 0
    end
end

-- Table for fast ability validation on combat events
local registeredAbilityLookup = {}

-- Triggered when an unrelated combat action occurs to smoothly release camera zoom
function NWAimCam.OnCombatEventEnd(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
    if isAiming then
        if not registeredAbilityLookup[abilityId] then
            ResetCamera()
        end
    end
end

-- Registers combat event filters strictly for active categories and custom skills
function NWAimCam.RegisterEvents()
    NWAimCam.UnregisterEvents()

    if not NWAimCam.savedVars.enabled then return end

    registeredAbilityLookup = {}
    local defaultWeaponAbilities = {}
    local customAbilities = {}

    if NWAimCam.savedVars.enableBow then
        for _, id in ipairs(WEAPON_IDS.BOW) do
            table.insert(defaultWeaponAbilities, id)
            registeredAbilityLookup[id] = true
        end
    end

    if NWAimCam.savedVars.enableDestruction then
        for _, id in ipairs(WEAPON_IDS.DESTRUCTION) do
            table.insert(defaultWeaponAbilities, id)
            registeredAbilityLookup[id] = true
        end
    end

    if NWAimCam.savedVars.enableRestoration then
        for _, id in ipairs(WEAPON_IDS.RESTORATION) do
            table.insert(defaultWeaponAbilities, id)
            registeredAbilityLookup[id] = true
        end
    end

    if NWAimCam.savedVars.customSkills then
        for id, _ in pairs(NWAimCam.savedVars.customSkills) do
            local numId = tonumber(id)
            if numId then
                table.insert(customAbilities, numId)
                registeredAbilityLookup[numId] = true
            end
        end
    end

    -- Register default heavy attacks with ACTION_RESULT_BEGIN
    for _, abilityId in ipairs(defaultWeaponAbilities) do
        local eventName = NWAimCam.name .. "Begin_" .. tostring(abilityId)
        EVENT_MANAGER:RegisterForEvent(eventName, EVENT_COMBAT_EVENT, NWAimCam.OnCombatEventBegin)
        EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
        EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_ACTION_RESULT, ACTION_RESULT_BEGIN)
        EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, abilityId)
    end

    -- Register custom skills without action_result filter to catch instant and ground casts
    for _, abilityId in ipairs(customAbilities) do
        local eventName = NWAimCam.name .. "CustomBegin_" .. tostring(abilityId)
        EVENT_MANAGER:RegisterForEvent(eventName, EVENT_COMBAT_EVENT, NWAimCam.OnCombatEventBegin)
        EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
        EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, abilityId)
    end

    if (#defaultWeaponAbilities > 0) or (#customAbilities > 0) then
        EVENT_MANAGER:RegisterForEvent(NWAimCam.name .. "End", EVENT_COMBAT_EVENT, NWAimCam.OnCombatEventEnd)
        EVENT_MANAGER:AddFilterForEvent(NWAimCam.name .. "End", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
    end
end

-- Unregisters all combat events from engine to eliminate performance footprint
function NWAimCam.UnregisterEvents()
    for _, category in pairs(WEAPON_IDS) do
        for _, id in ipairs(category) do
            EVENT_MANAGER:UnregisterForEvent(NWAimCam.name .. "Begin_" .. tostring(id), EVENT_COMBAT_EVENT)
        end
    end
    if NWAimCam.savedVars and NWAimCam.savedVars.customSkills then
        for id, _ in pairs(NWAimCam.savedVars.customSkills) do
            EVENT_MANAGER:UnregisterForEvent(NWAimCam.name .. "CustomBegin_" .. tostring(id), EVENT_COMBAT_EVENT)
        end
    end
    EVENT_MANAGER:UnregisterForEvent(NWAimCam.name .. "End", EVENT_COMBAT_EVENT)
    ResetCamera()
end

-- Debug combat listener to print only clean skill name and ID into chat
function NWAimCam.OnDebugCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
    if abilityName and abilityName ~= "" and abilityId and abilityId > 0 then
        d("[NWAimCam Skill Finder] Skill: " .. tostring(abilityName) .. " | ID: " .. tostring(abilityId))
    end
end

-- Toggles live combat event inspection mode
local function ToggleSkillCodeFinder()
    debugMode = not debugMode
    if debugMode then
        EVENT_MANAGER:RegisterForEvent(NWAimCam.name .. "SkillFinder", EVENT_COMBAT_EVENT, NWAimCam.OnDebugCombatEvent)
        EVENT_MANAGER:AddFilterForEvent(NWAimCam.name .. "SkillFinder", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
        d("|c00FF00[NWAimCam]|r Skill Code Finder is now |c00FF00ENABLED|r. Cast any skill or heavy attack to see its ID.")
    else
        EVENT_MANAGER:UnregisterForEvent(NWAimCam.name .. "SkillFinder", EVENT_COMBAT_EVENT)
        d("|c00FF00[NWAimCam]|r Skill Code Finder is now |cFF0000DISABLED|r.")
    end
end

SLASH_COMMANDS["/nwcamskillcode"] = ToggleSkillCodeFinder

-- LibAddonMenu settings panel creation
local function CreateSettingsMenu()
    local LAM = LibAddonMenu2
    
    local panelData = {
        type = "panel",
        name = "NW Aim Camera",
        displayName = "NW Action Aim",
        author = "Natosz",
        version = NWAimCam.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }
    LAM:RegisterAddonPanel("NWAimCamOptions", panelData)

    -- Dynamic list for individual custom skills management
    local customSkillsControls = {}
    local hasCustom = false

    if NWAimCam.savedVars and NWAimCam.savedVars.customSkills then
        for id, name in pairs(NWAimCam.savedVars.customSkills) do
            hasCustom = true
            local currentId = tonumber(id)
            local currentName = tostring(name)
            table.insert(customSkillsControls, {
                type = "button",
                name = string.format("Delete: %s (%d)", currentName, currentId),
                tooltip = "Click to remove this skill and reload the interface.",
                func = function()
                    NWAimCam.savedVars.customSkills[currentId] = nil
                    ReloadUI()
                end,
                width = "half",
            })
        end
    end

    if not hasCustom then
        table.insert(customSkillsControls, {
            type = "description",
            text = "|c808080No custom skills registered yet.|r",
        })
    end
    
    local optionsData = {
        {
            type = "header",
            name = "General Settings",
        },
        {
            type = "checkbox",
            name = "Enable Action Aim",
            tooltip = "Turns the camera magic on or off.",
            getFunc = function() return NWAimCam.savedVars.enabled end,
            setFunc = function(value) 
                NWAimCam.savedVars.enabled = value 
                NWAimCam.RegisterEvents()
            end,
            default = defaultSettings.enabled,
        },
        {
            type = "header",
            name = "Weapon Triggers",
        },
        {
            type = "checkbox",
            name = "Bows",
            tooltip = "Enable action aim zoom when drawing a Bow.",
            getFunc = function() return NWAimCam.savedVars.enableBow end,
            setFunc = function(value) 
                NWAimCam.savedVars.enableBow = value 
                NWAimCam.RegisterEvents()
            end,
            disabled = function() return not NWAimCam.savedVars.enabled end,
            default = defaultSettings.enableBow,
        },
        {
            type = "checkbox",
            name = "Destruction Staves",
            tooltip = "Enable action aim zoom for Inferno, Ice, and Lightning Staves.",
            getFunc = function() return NWAimCam.savedVars.enableDestruction end,
            setFunc = function(value) 
                NWAimCam.savedVars.enableDestruction = value 
                NWAimCam.RegisterEvents()
            end,
            disabled = function() return not NWAimCam.savedVars.enabled end,
            default = defaultSettings.enableDestruction,
        },
        {
            type = "checkbox",
            name = "Restoration Staves",
            tooltip = "Enable action aim zoom for Restoration Staves.",
            getFunc = function() return NWAimCam.savedVars.enableRestoration end,
            setFunc = function(value) 
                NWAimCam.savedVars.enableRestoration = value 
                NWAimCam.RegisterEvents()
            end,
            disabled = function() return not NWAimCam.savedVars.enabled end,
            default = defaultSettings.enableRestoration,
        },
        {
            type = "header",
            name = "Custom Skills & Abilities",
        },
        {
            type = "description",
            title = "How Custom Skills Work",
            text = "1. Click 'Toggle Skill Code Finder Mode' or type /nwcamskillcode in chat.\n" ..
                   "2. Cast your desired skill to inspect its clean Ability ID in chat.\n" ..
                   "3. Enter the ID number and an optional custom name below.\n" ..
                   "4. Click 'Add Skill' to save and reload the UI.",
        },
        {
            type = "button",
            name = "Toggle Skill Code Finder Mode",
            tooltip = "Turns the live chat skill ID listener ON or OFF.",
            func = function()
                ToggleSkillCodeFinder()
            end,
            width = "half",
        },
        {
            type = "editbox",
            name = "Skill Code (Ability ID)",
            tooltip = "Enter the numeric Ability ID.",
            getFunc = function() return tempSkillInput end,
            setFunc = function(value) tempSkillInput = value end,
            isMultiline = false,
        },
        {
            type = "editbox",
            name = "Skill Custom Name (Optional)",
            tooltip = "Enter a friendly name for this skill, or leave blank to auto-detect.",
            getFunc = function() return tempNameInput end,
            setFunc = function(value) tempNameInput = value end,
            isMultiline = false,
        },
        {
            type = "button",
            name = "Add Skill",
            tooltip = "Saves this Skill permanently and reloads the UI to register native engine filters.",
            func = function()
                local id = tonumber(tempSkillInput)
                if id and id > 0 then
                    local name = tempNameInput
                    if not name or name == "" then
                        name = GetAbilityName(id)
                    end
                    if not name or name == "" then
                        name = "Custom Skill " .. tostring(id)
                    end
                    NWAimCam.savedVars.customSkills[id] = name
                    tempSkillInput = ""
                    tempNameInput = ""
                    ReloadUI()
                end
            end,
            width = "half",
        },
        {
            type = "submenu",
            name = "Manage Saved Custom Skills",
            tooltip = "View and individually delete registered custom skills.",
            controls = customSkillsControls,
        },
        {
            type = "header",
            name = "Camera Customization",
        },
        {
            type = "dropdown",
            name = "Zoom Style",
            tooltip = "First Person: Look through character eyes.\nShoulder Aim: Close over-the-shoulder view.",
            choices = {"First Person", "Shoulder Aim"},
            choicesValues = {"0", "1.5"},
            getFunc = function() return NWAimCam.savedVars.aimDistance end,
            setFunc = function(value) NWAimCam.savedVars.aimDistance = value end,
            default = defaultSettings.aimDistance,
        },
        {
            type = "slider",
            name = "Maximum Field of View (FOV)",
            tooltip = "Adjust normal 3rd person FOV directly from here.",
            min = 70,
            max = 130,
            step = 1,
            getFunc = function() return NWAimCam.savedVars.maxFOV end,
            setFunc = function(value) 
                NWAimCam.savedVars.maxFOV = value 
                SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_FIELD_OF_VIEW, tostring(value))
            end,
            default = defaultSettings.maxFOV,
        },
        {
            type = "slider",
            name = "Horizontal Offset",
            tooltip = "Camera offset (34 is ideal for over the shoulder).",
            min = -50,
            max = 50,
            step = 1,
            getFunc = function() return NWAimCam.savedVars.hOffset end,
            setFunc = function(value) 
                NWAimCam.savedVars.hOffset = value 
                SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_HORIZONTAL_OFFSET, tostring(value))
            end,
            default = defaultSettings.hOffset,
        },
        {
            type = "slider",
            name = "Zoom Immersion Control (Seconds)",
            tooltip = "Adjust the zoom out timing. Ideal default for Bow; adjust if playing with slower or channeled staves.",
            min = 0.50,
            max = 3.00,
            step = 0.05,
            decimals = 2,
            getFunc = function() return NWAimCam.savedVars.failsafeTime end,
            setFunc = function(value) NWAimCam.savedVars.failsafeTime = value end,
            default = defaultSettings.failsafeTime,
        },
        {
            type = "description",
            title = "Recommended Settings & Tips",
            text = "Recommended Zoom Immersion Control for Bow:\n" ..
                   "90 FOV = 1.25 sec\n" ..
                   "100 FOV = 1.35 sec\n" ..
                   "110 FOV = 1.45 sec\n" ..
                   "120 FOV = 1.50 sec\n" ..
                   "130 FOV = 1.55 sec\n\n" ..
                   "Ideal for Bow; other weapons with different attack charge or channel durations might require adjusting this slider to match your playstyle.\n\n" ..
                   "Dodges, Sprinting, WASD, and other actions will zoom out back to max FOV immediately.\n\n" ..
                   "Zoom in and out speed is controlled by the engine, so using a lower max FOV delivers greater immersion (Real Action Combat Players play ZOOMED IN).",
        },
    }

    LAM:RegisterOptionControls("NWAimCamOptions", optionsData)
end

-- Addon initialization entry point
function NWAimCam.OnAddOnLoaded(event, addonName)
    if addonName == NWAimCam.name then
        EVENT_MANAGER:UnregisterForEvent(NWAimCam.name, EVENT_ADD_ON_LOADED)
        
        NWAimCam.savedVars = ZO_SavedVars:NewAccountWide("NWAimCamVariables", 1, nil, defaultSettings, GetWorldName())
        
        if not NWAimCam.savedVars.customSkills then
            NWAimCam.savedVars.customSkills = {}
        end

        CreateSettingsMenu()
        
        if NWAimCam.savedVars.enabled then
            NWAimCam.RegisterEvents()
        end
    end
end

EVENT_MANAGER:RegisterForEvent(NWAimCam.name, EVENT_ADD_ON_LOADED, NWAimCam.OnAddOnLoaded)