--[[
-------------------------------------------------------------------------------
-- FCOMounty, by Baertram
-------------------------------------------------------------------------------
This software is under : CreativeCommons CC BY-NC-SA 4.0
Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

You are free to:

    Share — copy and redistribute the material in any medium or format
    Adapt — remix, transform, and build upon the material
    The licensor cannot revoke these freedoms as long as you follow the license terms.


Under the following terms:

    Attribution — You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
    NonCommercial — You may not use the material for commercial purposes.
    ShareAlike — If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
    No additional restrictions — You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.


Please read full licence at :
http://creativecommons.org/licenses/by-nc-sa/4.0/legalcode
]]

if FCOM == nil then FCOM = {} end
local FCOMounty = FCOM

local EM = EVENT_MANAGER


--Request the update to the mount change
local function RequestMountUpdate(forceMountActivation)
    forceMountActivation = forceMountActivation or false
    local callbackName = "FCOMounty_updateMountCollectible"
    local function Update(doForceMountActivation)
        EM:UnregisterForUpdate(callbackName)
        --Update the mount collectible now
        --FCOMounty.ActivateMountForZone(zone, subZone, override, onlyUpdateMountVisibleEnhancements, updateMountEnh)
--d("[FCOMounty]RequestMountUpdate -> Activate mount now, force: " ..tostring(doForceMountActivation))
        FCOMounty.ActivateMountForZone(nil, nil, doForceMountActivation, nil, true)
    end
    --cancel previously scheduled update if any
    EM:UnregisterForUpdate(callbackName)
    --register a new one
    EM:RegisterForUpdate(callbackName, 1000, function() Update(forceMountActivation) end)
end

-- EVENT_COLLECTIBLE_USE_RESULT(number eventCode, number CollectibleUsageBlockReason result, boolean isAttemptingActivation)
function FCOMounty.EventCollectibleUseResult(eventCode, CollectibleUsageBlockReason, isAttemptingActivation)
    --d("[FCOMounty.EventCollectibleUseResult]CollectibleUsageBlockReason: " .. tostring(CollectibleUsageBlockReason) .. ", isAttemptingActivation: " .. tostring(isAttemptingActivation) .. ", doNotChangePresetMount: " .. tostring(FCOMounty.preventerVars.doNotChangePresetMount))
    if not FCOMounty.preventerVars.doNotChangePresetMount and isAttemptingActivation then
        FCOMounty.preventerVars.manuallyMountChosen = true
        --Should the actively choosen mount be saved as the zone & subzone preset mount?
        local settings = FCOMounty.settingsVars.settings
        if settings.autoPresetForZoneOnNewMount and not settings.randomizeMountsForZoneAndSubzone then
            --Check a bit later as this event needs to finish first in order to update the active mount with the new chosen one from the collectibles!
            zo_callLater(function()
                FCOMounty.preventerVars.getMountFromSettingsNow = false
                FCOMounty.checkAndPresetMountForZone()
            end, 250)
        elseif not settings.autoPresetForZoneOnNewMount then
            --d(">2")
            --Set the preventer variable so after a manual collectibel mount change the settings are read again to set
            --the selected zone & subzone mount later on again (e.g. on unmount or weapon pair change)
            FCOMounty.preventerVars.getMountFromSettingsNow = true
        end
    end
    FCOMounty.preventerVars.doNotChangePresetMount = false
end

--EVENT_PLAYER_COMBAT_STATE (number eventCode, boolean inCombat)
function FCOMounty.EventPlayerCombatState(eventCode, inCombat)
    if not inCombat and FCOMounty.preventerVars.updateMountInCombat then
        local isInDungeon, isInDelve = FCOMounty.isPlayerInDungeon()
        if isInDungeon or isInDelve then return false end
        FCOMounty.preventerVars.updateMountInCombat = false
        --Activate the mount for the current zone & subzone, force teh activation as we got out of combat
        RequestMountUpdate(true)
    end
end

-- EVENT_MOUNTED_STATE_CHANGED (number eventCode, boolean mounted)
function FCOMounty.EventMountedStateChanged(eventCode, isMounted)
--d("[FCOMounty.EventMountedStateChanged] isMounted: " ..tostring(isMounted) .. ", mountManuallyChosen: " .. tostring(FCOMounty.preventerVars.manuallyMountChosen))
    if not isMounted then
        local isInDungeon, isInDelve = FCOMounty.isPlayerInDungeon()
        if isInDungeon or isInDelve then return false end
        local inCombat = IsUnitInCombat("player")
        if not inCombat then
            FCOMounty.preventerVars.updateMountInCombat = false
            --Activate the mount for the current zone & subzone
            zo_callLater(function()
                RequestMountUpdate(true) -- Force the mount activation as we got unmounted
            end, 1000)
        else
            FCOMounty.preventerVars.updateMountInCombat = true
        end
    end
end

-- EVENT_ACTIVE_WEAPON_PAIR_CHANGED (number eventCode, number ActiveWeaponPair activeWeaponPair, boolean locked)
function FCOMounty.EventActiveWeaponPairChanged(eventCode, ActiveWeaponPair, locked)
--d("FCOMounty.EventActiveWeaponPairChanged - locked: " .. tostring(locked))
    if not FCOMounty.preventerVars.manuallyMountChosen and locked and not IsMounted() then
        local isInDungeon, isInDelve = FCOMounty.isPlayerInDungeon()
        if isInDungeon or isInDelve then return false end
        local inCombat = IsUnitInCombat("player")
        if not inCombat then
            FCOMounty.preventerVars.updateMountInCombat = false
            RequestMountUpdate(false) -- do not force the mount activation on weapon pair swap
        else
            FCOMounty.preventerVars.updateMountInCombat = true
        end
    end
end

--[[
-- EVENT_ACTION_LAYER_POPPED (number eventCode, number layerIndex, number activeLayerIndex)
function FCOMounty.EventActionLayerPopped(eventCode, layerIndex, activeLayerIndex)
    if not FCOMounty.preventerVars.manuallyMountChosen and layerIndex == LAYER_MOUSE_UI_MODE and not IsMounted() then
--d("FCOMounty.EventActionLayerPopped - layerIndex: " .. tostring(layerIndex .. ", activeLayerIndex: " .. tostring(activeLayerIndex)))
        local inCombat = IsUnitInCombat("player")
        if not inCombat then
            RequestMountUpdate(false) -- do not force the mount activation on action layer pop
        end
    end
end
--EVENT_ACTION_LAYER_PUSHED (number eventCode, number layerIndex, number activeLayerIndex)
function FCOMounty.EventActionLayerPushed(eventCode, layerIndex, activeLayerIndex)
    if not FCOMounty.preventerVars.manuallyMountChosen and layerIndex == LAYER_MOUSE_UI_MODE and not IsMounted() then
--d("FCOMounty.EventActionLayerPushed - layerIndex: " .. tostring(layerIndex .. ", activeLayerIndex: " .. tostring(activeLayerIndex)))
        local inCombat = IsUnitInCombat("player")
        if not inCombat then
            RequestMountUpdate(false) -- do not force the mount activation on action layer push
        end
    end
end
]]

--EVENT_RIDING_SKILL_IMPROVEMENT (*[RidingTrainType|#RidingTrainType]* _ridingSkillType_, *integer* _previous_, *integer* _current_, *[RidingTrainSource|#RidingTrainSource]* _source_)
function FCOMounty.EventRidingSkillImprovement(event, ridingSkillType, previous, current, source)
    --Get the current riding skill infos
    FCOMounty.getRidingTrainInfo()
end

--Check if we are inside a dungeon or a raid dungeon
function FCOMounty.isPlayerInDungeon()
    --Check if the player is currently in a 4, 12, or more person dungeon (e.g. a raid)
    -->Attention: Function IsUnitInDungeon will return true for a delve too!
    FCOMounty.isInDungeon = IsUnitInDungeon("player") or false
    FCOMounty.isInDelve = false
    if FCOMounty.isInDungeon and GetCurrentZoneDungeonDifficulty() == DUNGEON_DIFFICULTY_NONE then
        --Player is in a delve
        FCOMounty.isInDungeon = false
        FCOMounty.isInDelve = true
    end
--d("[FCOMounty]isInDungeon: " .. tostring(FCOMounty.isInDungeon))
    return FCOMounty.isInDungeon, FCOMounty.isInDelve

end

--Player activated function
function FCOMounty.Player_Activated(...)
--d("[FCOMounty]Player activated")
    --Hook the stable scene
    FCOMounty.hookStableScene()
    --Reset current zone and subZone variables
    FCOMounty.LAMSelectedZone       = FCOM_NONE_ENTRIES
    FCOMounty.LAMSelectedSubZone    = FCOM_NONE_ENTRIES
    --Get the current game client's language
    local lang = GetCVar("language.2")
    if lang == nil or lang == "" then lang = "en" end
    FCOMounty.lang = lang
    --Check if we are inside a dungeon/raid dungeon and disable FCOMounty checks then
    local isInDungeon, isInDelve = FCOMounty.isPlayerInDungeon()
    if not isInDungeon and not isInDelve then
        --Update current zone's mount data
        FCOMounty.EnhanceZoneDataByCurrentZone()

        --Activate the mount for the current zone & subzone, force the activation on addon load/player activated
        RequestMountUpdate(true)

        --Register for the mount state changed event to check for the active zone and mount
        EM:RegisterForEvent(FCOMounty.addonVars.addonName, EVENT_MOUNTED_STATE_CHANGED, FCOMounty.EventMountedStateChanged)
        EM:RegisterForEvent(FCOMounty.addonVars.addonName, EVENT_COLLECTIBLE_USE_RESULT, FCOMounty.EventCollectibleUseResult)

        --EM:RegisterForEvent(FCOMounty.addonVars.addonName, EVENT_ACTION_LAYER_POPPED, FCOMounty.EventActionLayerPopped)
        --EM:RegisterForEvent(FCOMounty.addonVars.addonName, EVENT_ACTION_LAYER_PUSHED, FCOMounty.EventActionLayerPushed)
        EM:RegisterForEvent(FCOMounty.addonVars.addonName, EVENT_ACTIVE_WEAPON_PAIR_CHANGED, FCOMounty.EventActiveWeaponPairChanged)

        EM:RegisterForEvent(FCOMounty.addonVars.addonName, EVENT_RIDING_SKILL_IMPROVEMENT, FCOMounty.EventRidingSkillImprovement)

        EM:RegisterForEvent(FCOMounty.addonVars.addonName, EVENT_PLAYER_COMBAT_STATE, FCOMounty.EventPlayerCombatState)
    --else
        --d("[FCOMounty] Disabled addon inside delves & dungeons (for an improved performance)!")
    end
end

function FCOMounty.addonLoaded(eventName, addon)
    if addon ~= FCOMounty.addonVars.addonName then return end
    EM:UnregisterForEvent(eventName)

    --Register for the zone change/player ready event
    EM:RegisterForEvent(FCOMounty.addonVars.addonName, EVENT_PLAYER_ACTIVATED, FCOMounty.Player_Activated)

    --Build the mount data
    FCOMounty.BuildMountData()

    --Get the SavedVariables
    FCOMounty.getSettings()

    --Create the settings panel object of libAddonMenu 2.0
    FCOMounty.LAM = LibAddonMenu2
    --Create the zone data object of libZone
    FCOMounty.libZone = LibZone

    --Slash commands
    SLASH_COMMANDS["/fcomz"] = function() FCOMounty.zone2Chat() end
    SLASH_COMMANDS["/fcomr"] = function() FCOMounty.reportMissingZoneData() end
    SLASH_COMMANDS["/fcoma"] = function() FCOMounty.EnhanceZoneDataByCurrentZone() end

    --Build the LAM
    FCOMounty.buildAddonMenu()
end

function FCOMounty.initialize()
    EM:RegisterForEvent(FCOMounty.addonVars.addonName, EVENT_ADD_ON_LOADED, FCOMounty.addonLoaded)
end
FCOMounty.initialize()
