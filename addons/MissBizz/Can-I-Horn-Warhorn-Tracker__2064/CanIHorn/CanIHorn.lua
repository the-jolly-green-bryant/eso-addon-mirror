-------------------------------------------------------------------------------------------------
--  Libraries --
-------------------------------------------------------------------------------------------------
local LAM2 = LibStub:GetLibrary("LibAddonMenu-2.0")

-------------------------------------------------------------------------------------------------
--  Addon Info --
-------------------------------------------------------------------------------------------------

local addon = {
    name = "CanIHorn",
    version = "1.4.1",
    author = "MissBizz",
    DisplayName = "Can I Horn?"
}

local ChangeLog = "API update! Yay no more out of date!"

local savedVariables


----------------------------------------------------------
--  GLOBALS / GUI  --
----------------------------------------------------------
local HornState = ""
local HornActive = "HornActive"
local HornInactive = "HornInactive"
local ForceInactive = "ForceInactive"
local SupportRangeOnly = true
local showOnlyInCombat = false
local showOnlyGrouped = false


function addon.groupVisibility (_,_)
    if savedVariables.showOnlyGrouped and IsUnitGrouped("player") then
        CanIHornIndicatorText:SetHidden(false)
    elseif savedVariables.showOnlyGrouped and IsUnitGrouped("player") == false then
        CanIHornIndicatorText:SetHidden(true)
    elseif savedVariables.showOnlyGrouped == false and savedVariables.showOnlyInCombat then
        addon.onPlayerCombatState()
    elseif savedVariables.showOnlyGrouped == false and savedVariables.showOnlyInCombat == false then
        CanIHornIndicatorText:SetHidden(false)
    end
end
function addon.onPlayerCombatState (eventCode, inCombat)
    if savedVariables.showOnlyInCombat then
        local show = not IsUnitInCombat("player")
        if CanIHornIndicatorText:IsHidden() ~= show then
            CanIHornIndicatorText:SetHidden(show)
        end
    else
        if CanIHornIndicatorText:IsHidden() then
            CanIHornIndicatorText:SetHidden(false)
        end
    end
end

function addon.CombatStateDisplay()
    if IsUnitInCombat("player") and savedvariables.showOnlyInCombat then
        CanIHornIndicatorText:SetHidden(false)
    elseif savedVariables.showOnlyInCombat and IsUnitInCombat("player") == false then
        CanIHornIndicatorText:SetHidden(true)
    else
        CanIHornIndicatorText:SetHidden(false)
    end
end

local DisplayDefaults = {
    HornActive = {
        Colour = {1, 0, 0, 1},
        Text = "Warhorn is Active",
        fontName = "Univers67",
        fontSize = "20",
        fontOutline = "soft-shadow-thick"
    },
    HornInactive = {
        Colour = {0, 1, 0, 1},
        Text = "Warhorn not Active",
        fontName = "Univers67",
        fontSize = "20",
        fontOutline = "soft-shadow-thick"
    },
    ForceInactive = {
        Colour = {1, 1, 0, 1},
        Text = "Warhorn is Active",
        fontName = "Univers67",
        fontSize = "20",
        fontOutline = "soft-shadow-thick"
    },
    CurrentVersion = "0",
    SupportRangeOnly = true,
    isLocked = false,
    showOnlyInCombat = false
}


local function UpdateColour()
    CanIHornIndicatorText:SetColor(unpack(savedVariables[HornState].Colour))
end

local function UpdateFont()
    CanIHornIndicatorText:SetFont("EsoUi/Common/Fonts/"..savedVariables[HornState].fontName..".otf|"..savedVariables[HornState].fontSize.."|"..savedVariables[HornState].fontOutline)
end

function addon.OnIndicatorMoveStop()
    savedVariables.left = CanIHornIndicator:GetLeft()

    savedVariables.top = CanIHornIndicator:GetTop()
end

function addon.RestorePosition()
    CanIHornIndicator:ClearAnchors()
    CanIHornIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, savedVariables.left, savedVariables.top)
end



CAN_I_HORN = addon

local function CreateSettingsWindow()
    local panelData = {
        type = "panel",
        name = "Can I Horn?",
        displayName = "Can I Horn?",
        author = addon.author,
        version = addon.version,
        slashCommand = "/canihorn",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local cntrlOptionsPanel = LAM2:RegisterAddonPanel("MissBizz_CanIHorn", panelData)

    local optionsData = {
        [1] = {
            type = "header",
            name = "Support Range",
        },
        [2] = {
            type = "description",
            text = "When support range only is ON, the addon will only change states when someone within support range (~28m) of you gains the warhorn buff. Recommended on for split areas such as Hel Ra.",
        },
        [3] = {
            type = "checkbox",
            name = "Support Range Only",
            tooltip = "A group member is considered in your support range if they are 'lit up' in the group frame",
            getFunc = function() return savedVariables.SupportRangeOnly end,
            setFunc = function(newValue)
                savedVariables.SupportRangeOnly = newValue
                SupportRangeOnly = newValue
            end,
        },
        [4] = {
            type = "header",
            name = "Warhorn Active",
        },
        [5] = {
            type = "description",
            text = "When warhorn is active. If using Aggressive horn, these settings will apply when both Aggressive Horn and Major Force are active.",
        },
        [6] = {
            type = "colorpicker",
            name = "Horn Active Color",
            tooltip = "Changes the colour of the text when warhorn is active.",
            getFunc = function() return unpack(savedVariables[HornActive].Colour) end,
            setFunc = function(r,g,b,a)
                savedVariables[HornActive].Colour = { r, g, b, a }
                UpdateColour()
            end,
        },
        [7] = {
            type = "dropdown",
            name = "Font Name",
            tooltip = "Font Name to be used.",
            choices = {"Univers57", "Univers67", "FTN47", "FTN57", "FTN87", "ProseAntiquePSMT", "Handwritten_Bold", "TrajanPro-Regular"},
            getFunc = function() return savedVariables[HornActive].fontName end,
            setFunc = function(newValue)
                savedVariables[HornActive].fontName = newValue
                UpdateFont()
            end,
        },
        [8] = {
            type = "slider",
            name = "Size",
            tooltip = "Font Size to be used when warhorn is active.",
            min = 20,
            max = 72,
            step = 1,
            getFunc = function() return savedVariables[HornActive].fontSize end,
            setFunc = function(newValue2)
                savedVariables[HornActive].fontSize = newValue2
                UpdateFont()
            end,
        },
        [9] = {
            type = "dropdown",
            name = "Outline",
            tooltip = "Font Outline to be used.",
            choices = {"thick-outline", "soft-shadow-thick", "soft-shadow-thin", "none" },
            getFunc = function() return savedVariables[HornActive].fontOutline or "none" end,
            setFunc = function(newValue3)
                if newValue == "none" then newValue3 = nil end
                savedVariables[HornActive].fontOutline = newValue3
                UpdateFont()
            end,
        },
        [10] = {
            type = "header",
            name = "Warhorn Inactive",
        },
        [11] = {
            type = "description",
            text = "When warhorn is not active.",
        },
        [12] = {
            type = "colorpicker",
            name = "Horn Not Active Color",
            tooltip = "Changes the colour of the text when warhorn is not active.",
            getFunc = function() return unpack(savedVariables[HornInactive].Colour) end,
            setFunc = function(r,g,b,a)
                savedVariables[HornInactive].Colour = { r, g, b, a }
                UpdateColour()
            end,
        },
        [13] = {
            type = "dropdown",
            name = "Font Name",
            tooltip = "Font Name to be used.",
            choices = {"Univers57", "Univers67", "FTN47", "FTN57", "FTN87", "ProseAntiquePSMT", "Handwritten_Bold", "TrajanPro-Regular"},
            getFunc = function() return savedVariables[HornInactive].fontName end,
            setFunc = function(newValue)
                savedVariables[HornInactive].fontName = newValue
                UpdateFont()
            end,
        },
        [14] = {
            type = "slider",
            name = "Size",
            tooltip = "Font Size to be used when warhorn is active.",
            min = 20,
            max = 72,
            step = 1,
            getFunc = function() return savedVariables[HornInactive].fontSize end,
            setFunc = function(newValue2)
                savedVariables[HornInactive].fontSize = newValue2
                UpdateFont()
            end,
        },
        [15] = {
            type = "dropdown",
            name = "Outline",
            tooltip = "Font Outline to be used.",
            choices = {"thick-outline", "soft-shadow-thick", "soft-shadow-thin", "none" },
            getFunc = function() return savedVariables[HornInactive].fontOutline or "none" end,
            setFunc = function(newValue3)
                if newValue == "none" then newValue3 = nil end
                savedVariables[HornInactive].fontOutline = newValue3
                UpdateFont()
            end,
        },
        [16] = {
            type = "header",
            name = "Warhorn Active, Major Force Inactive",
        },
        [17] = {
            type = "description",
            text = "When warhorn is active, but Major Force is no longer active. Only applied to Aggressive Horn.",
        },
        [18] = {
            type = "colorpicker",
            name = "Horn Active - No Major Force",
            tooltip = "Changes the colour of the text when warhorn is active, but major force is lost. (Does not apply for unmorphed warhorn or sturdy horn)",
            getFunc = function() return unpack(savedVariables[ForceInactive].Colour) end,
            setFunc = function(r,g,b,a)
                savedVariables[ForceInactive].Colour = { r, g, b, a }
                UpdateColour()
            end,
        },
        [19] = {
            type = "dropdown",
            name = "Font Name",
            tooltip = "Font Name to be used.",
            choices = {"Univers57", "Univers67", "FTN47", "FTN57", "FTN87", "ProseAntiquePSMT", "Handwritten_Bold", "TrajanPro-Regular"},
            getFunc = function() return savedVariables[ForceInactive].fontName end,
            setFunc = function(newValue)
                savedVariables[ForceInactive].fontName = newValue
                UpdateFont()
            end,
        },
        [20] = {
            type = "slider",
            name = "Size",
            tooltip = "Font Size to be used when warhorn is active.",
            min = 20,
            max = 72,
            step = 1,
            getFunc = function() return savedVariables[ForceInactive].fontSize end,
            setFunc = function(newValue2)
                savedVariables[ForceInactive].fontSize = newValue2
                UpdateFont()
            end,
        },
        [21] = {
            type = "dropdown",
            name = "Outline",
            tooltip = "Font Outline to be used.",
            choices = {"thick-outline", "soft-shadow-thick", "soft-shadow-thin", "none" },
            getFunc = function() return savedVariables[ForceInactive].fontOutline or "none" end,
            setFunc = function(newValue3)
                if newValue == "none" then newValue3 = nil end
                savedVariables[ForceInactive].fontOutline = newValue3
                UpdateFont()
            end,
        },
        [22] = {
            type = "header",
            name = "Visibility",
        },
        [23] = {
            type = "checkbox",
            name = "Lock",
            tooltip = "Locks the current position of the text!",
            getFunc = function() return savedVariables.isLocked end,
            setFunc = function(isLocked)
                savedVariables.isLocked = isLocked
                CanIHornIndicator:SetMouseEnabled(not isLocked)
            end,
        },
        [24] = {
            type = "checkbox",
            name = "Show only in combat",
            tooltip = "Shows the text only when in combat. ",
            getFunc = function() return savedVariables.showOnlyInCombat end,
            setFunc = function(value4)
                showOnlyInCombat = value4
                savedVariables.showOnlyInCombat = value4
                addon.CombatStateDisplay()
            end,
        },
        [25] = {
            type = "checkbox",
            name = "Show only while grouped",
            tooltip = "Shows the text only when in a group. ",
            getFunc = function() return savedVariables.showOnlyGrouped end,
            setFunc = function(value5)
                showOnlyGrouped = value5
                savedVariables.showOnlyGrouped = value5
                addon.groupVisibility()
            end,
        },
    }

    LAM2:RegisterOptionControls("MissBizz_CanIHorn", optionsData)
end

----------------------------------------------------------
-- Display Functions  --
----------------------------------------------------------
local function HornDisplay()
    CanIHornIndicatorText:SetFont("EsoUi/Common/Fonts/"..savedVariables[HornState].fontName..".otf|"..savedVariables[HornState].fontSize.."|"..savedVariables[HornState].fontOutline)
    CanIHornIndicatorText:SetText(savedVariables[HornState].Text)
    CanIHornIndicatorText:SetColor(unpack(savedVariables[HornState].Colour))
end

----------------------------------------------------------
-- Major Force Functions  --
----------------------------------------------------------

--this sets horn to false, so that if a horn hasn't sounded - major force will be ignored.
local ForceHornActive = false

local function WatchForce(_, changeType, _, effectName, unitTag, _, _, _, _, _, _, _, _, _, _, abilityId, _)

    --if Warhorn hasn't sounded yet, ForceHornActive will be false and therefore nothing will happen, lua assumes you mean you want the variable true
    if ForceHornActive then

        --d(string.format("Passed agressive warhorn true check"))

        if changeType == EFFECT_RESULT_FADED then
            HornState = "ForceInactive"
            HornDisplay()
            --this changed the text colour to yellow when major force fades
            ForceHornActive = false
            --sets warhornActive back to false so other major forces don't change the colour
        end
    end
end

----------------------------------------------------------
-- Main Horn Functions  --
----------------------------------------------------------
local nearbyHorn
-- (_, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitID, abilityId, sourceUnitType)
--This is our main function to change text when a warhorn fires or fades.
local function IsHornOn(_, changeType, _, effectName, unitTag, _, _, _, _, _, _, _, _, _, _, abilityId, _)
    nearbyHorn = IsUnitInGroupSupportRange(unitTag)
    if changeType == EFFECT_RESULT_GAINED then
        --d(string.format("Horn found. Unit:%s,", unitTag))
        if SupportRangeOnly then
            --d(string.format("SRO true passed"))
            if nearbyHorn then
                --d(string.format("nearby horn found"))
                HornState = "HornActive"
                HornDisplay()
                --checks only for aggressive horn, as that is the only time we care about major force
                if abilityId == 40224 then
                    ForceHornActive = true
                    --d(string.format("ForceHornActive set to true SRO true"))
                    --sets WarhornActive to true to it will pass the check in the WatchForce function
                end
                return
            end
        end
    elseif SupportRangeOnly == false then
        --d(string.format("far horn found"))
        HornState = "HornActive"
        HornDisplay()
        --checks only for aggressive horn, as that is the only time we care about major force
        if abilityId == 40224 then
            ForceHornActive = true
            --d(string.format("ForceHornActive set to true for SRO false"))
            --sets WarhornActi
            -- -- ve to true to it will pass the check in the WatchForce function
            return
        end


    else
        --d(string.format("IsHornOn() effectName: %s, abilityId %s, unitTag %s", effectName, abilityId, unitTag))
        HornState = "HornInactive"
        HornDisplay()
        --d(string.format("HornInactive"))

        --d(string.format("IsHornOn() other effectName %s, abilityId %s, unitTag %s, changeType $s", effectName, abilityId, unitTag, changeType))
    end
end
--------------------------------------------------
-- Warhorn ID's  --
----------------------------------------------------------
local hornID  = { [38564] = true, [40224] = true, [40221] = true }
--38564 is warhorn, 40224 aggressive, 40221 sturdy

--------------------------------------------------
-- Ability Event Registrations  --
----------------------------------------------------------
-- This makes sure we only run our IsHornOn function when it has to do with a warhorn ability ID (which we grab from the table above). That way IsHornOn doesn't run for every buff and ability ever
local function RegisterFilterAbilities()
    local eventCounter = 0
    for abilityId,_ in pairs(hornID) do
        eventCounter = eventCounter + 1
        local eventName = addon.name .. eventCounter
        EVENT_MANAGER:RegisterForEvent(eventName, EVENT_EFFECT_CHANGED, IsHornOn)
        EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, abilityId, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
    end
end

--registers the Major Force buff specifically
local function RegisterForce()
    EVENT_MANAGER:RegisterForEvent(forceevent, EVENT_EFFECT_CHANGED, WatchForce)
    EVENT_MANAGER:AddFilterForEvent(forceevent, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 40225, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
end

--------------------------------------------------
-- Initial Horn Check  --
----------------------------------------------------------

--intial check for horn upon login
local function CheckForHorn()
    local isActiveHorn = false

    for i=1,GetNumBuffs("player") do
        local abilityId = select(11, GetUnitBuffInfo("player", i))
        if hornID[abilityID] then
            isActiveHorn = true
            break
        end
    end
    if isActiveHorn then
        HornState = "HornActive"
        HornDisplay()
        --d(string.format("CheckForHorn() It is it buffName: %s, abilityId %s, buffSlot %s", buffName, abilityID, buffSlot))
    else
        HornState = "HornInactive"
        HornDisplay()
    end
end


--waits until the player is activated to check for horn
local function OnPlayerActivated()
    --d("it worked!")
    CheckForHorn()
    addon.onPlayerCombatState()
    addon.groupVisibility()

    if savedVariables.CurrentVersion ~= addon.version then
        d(string.format(addon.DisplayName .. " - " ..addon.version .. " - " ..ChangeLog))
        savedVariables.CurrentVersion = addon.version
    end

end


----------------------------------------------------------
-- Initialize Function  --
----------------------------------------------------------

--The EVENT_ADD_ON_LOADED event fired, we made it past the check that it is indeed out addon on, so let's run this
local function Initialize()

    --register event to watch for when player loads
    EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

    savedVariables = ZO_SavedVars:New("CanIHornSavedVariables", 2, nil, DisplayDefaults)

    addon.RestorePosition()

    RegisterFilterAbilities()
    RegisterForce()
    CreateSettingsWindow()
    local fragment = ZO_HUDFadeSceneFragment:New(CanIHornIndicator)
    HUD_SCENE:AddFragment(fragment)
    HUD_UI_SCENE:AddFragment(fragment)
    GAME_MENU_SCENE:AddFragment(fragment)

end



local function OnAddOnLoaded(_, addonName)

    -- Checks to see if it's out add on that loaded, if not - return to keep checking whenever any addon loads.
    if addonName ~= addon.name then return end

    -- unregister our EVENT_ADD_ON_LOADED event because now that we know our addon loaded and initliazed... we don't care when any more addons load.
    EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)

    --If we got past that, it means our addon loaded. Initliaze will do all the stuff to set out addon up
    Initialize()

end

----------------------------------------------------------
--  Register Events  --
----------------------------------------------------------
--This registers our event, so whenever EVENT_ADD_ON_LOADED fires, it runs our OnAddOnLoaded function
EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_PLAYER_COMBAT_STATE, addon.onPlayerCombatState)
EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_GROUP_MEMBER_JOINED, addon.groupVisibility)
EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_GROUP_MEMBER_LEFT, addon.groupVisibility)
