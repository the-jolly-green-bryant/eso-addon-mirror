PillagerIndicator = {}

PillagerIndicator.name = "PillagerIndicator"
PillagerIndicator.version = "1.0.0"
local chat = LibChatMessage( PillagerIndicator.name, "PI" )
local worldName = GetWorldName()
local PILLAGER_ABILITY_ID = 172055
local PILLAGER_DURATTON = 10000
local LAM = LibAddonMenu2

function PillagerIndicator.OnAddOnLoaded( event, addonName )
    if addonName ~= PillagerIndicator.name then
        return
    end
    PillagerIndicator.Initialize()
end

-- Defaults
local defaults = {
    color = { 0.1686274558, 1, 0.4784313738, 0.6 },
    sound = "Skill_Gained",
    enabled = true,
}


--Methods
function PillagerIndicator:RegisterAnimation()
    local control = PillagerIndicatorFrame
    if not self.timeline then
        self.timeline = ANIMATION_MANAGER:CreateTimelineFromVirtual( "PillagerIndicatorFrameAnimation",
            control )
    end
    local timeline = self.timeline
    if not self.animation then
        self.animation = timeline:GetFirstAnimationOfType( ANIMATION_ALPHA )
    end
    local animation = self.animation
    animation:SetAlphaValues( 0, PillagerIndicator.SavedVariables.color[ 4 ] )
    --animation:SetEasingFunction( ZO_EaseInQuartic )
end

local function onPillagerEnd()
    if PillagerIndicatorFrameOverlay:GetAlpha() == 0 then
        return
    end
    PillagerIndicator.timeline:PlayFromEnd()
    EVENT_MANAGER:UnregisterForUpdate( "PillagerIndicator" )
end
local function onPillagerStart()
    PillagerIndicator.timeline:PlayFromStart()
    EVENT_MANAGER:RegisterForUpdate( "PillagerIndicator", PILLAGER_DURATTON,
        onPillagerEnd )
    PlaySound( PillagerIndicator.SavedVariables.sound )
end
--OEC: effectName: Pillager's Profit, changeType: 1, unitTag: player, beginTime 2314, endTime 2324, abilityId 172055
function PillagerIndicator:OnEffectChanged(
    changeType,
    effectSlot,
    effectName,
    unitTag,
    beginTime,
    endTime,
    stackCount,
    iconName,
    deprecatedBuffType,
    effectType,
    abilityType,
    statusEffectType,
    unitName,
    unitId,
    abilityId,
    sourceType )
    if not PillagerIndicator.SavedVariables.enabled then
        return
    end
    if changeType == EFFECT_RESULT_GAINED then
        onPillagerStart()
    elseif changeType == EFFECT_RESULT_FADED then
        onPillagerEnd()
    end
end

local function updateOverlay()
    local control = GetControl( "PillagerIndicatorFrameOverlay" )
    local color = PillagerIndicator.SavedVariables.color
    control:SetEdgeColor( unpack( color ) )
end
local function slashCommand( arg )
    local helpText =
    "Pillager Indicator\n\n/pi test - Test the Pillager Indicator\n/pi resetUI - Reset the UI if overlay is stuck\n /pi toggle - Enable or disable the Pillager Indicator\n/pi state - Check the current state of the Pillager Indicator\n/pi version - Show the current Pillager Indicator version\n/pi resetSettings - Reset the settings to default\n/pi settings - Open the settings menu\n/pi help - Show this help message"
    if arg == "resetSettings" then
        PillagerIndicator.SavedVariables = nil
        PillagerIndicator.SavedVariables = ZO_SavedVars:NewAccountWide( "PISettings", 1, nil, defaults, worldName )
    elseif arg == "test" then
        onPillagerStart()
    elseif arg == "resetUI" then
        onPillagerEnd()
    elseif arg == "help" then
        chat:Print( helpText )
    elseif arg == "toggle" then
        PillagerIndicator.SavedVariables.enabled = not PillagerIndicator.SavedVariables.enabled
        if PillagerIndicator.SavedVariables.enabled then
            chat:Print( "Pillager Indicator is now enabled." )
        else
            chat:Print( "Pillager Indicator is now disabled." )
            onPillagerEnd()
        end
    elseif arg == "state" then
        if PillagerIndicator.SavedVariables.enabled then
            chat:Print( "Pillager Indicator is enabled." )
        else
            chat:Print( "Pillager Indicator is disabled." )
        end
    elseif arg == "version" then
        chat:Print( "Pillager Indicator version " .. PillagerIndicator.version )
    elseif arg == "settings" then
        LAM:OpenToPanel( "PillagerIndicatorOptions" )
    else
        chat:Print( helpText )
    end
end
SLASH_COMMANDS[ "/pillagerindicator" ] = slashCommand
SLASH_COMMANDS[ "/pi" ] = slashCommand
SLASH_COMMANDS[ "/pillager" ] = slashCommand
------------
--Settings--
------------
local optionsData = {}
local function createSettingsMenu()
    local panelData = {
        type = "panel",
        name = "Pillager Indicator",
        author = "JN Slevin",
        version = PillagerIndicator.version,
        registerForRefresh = true,
        registerForDefaults = true,
        keywords = "pillagerindicatorultimate",
    }
    LAM:RegisterAddonPanel( "PillagerIndicatorOptions", panelData )

    optionsData[ #optionsData + 1 ] = {
        type = "header",
        name = "Pillager Indicator Options"
    }
    optionsData[ #optionsData + 1 ] = {
        type = "checkbox",
        name = "Enable Pillager Indicator",
        getFunc = function() return PillagerIndicator.SavedVariables.enabled end,
        setFunc = function( value )
            PillagerIndicator.SavedVariables.enabled = value
        end,
        default = defaults.enabled,
    }
    optionsData[ #optionsData + 1 ] = {
        type = "header",
        name = "Pillager Indicator Preferences",
        width = "full",
    }
    optionsData[ #optionsData + 1 ] = {
        type = "description",
        text = "Change the color of the overlay and the sound that plays when Pillager's Profit is active.",
        disabled = function() return not PillagerIndicator.SavedVariables.enabled end,
    }
    optionsData[ #optionsData + 1 ] = {
        type = "colorpicker",
        name = "Color / opacity of overlay",
        getFunc = function() return unpack( PillagerIndicator.SavedVariables.color ) end, --(alpha is optional)
        setFunc = function( r, g, b, a )
            PillagerIndicator.SavedVariables.color = { r, g, b, a }
            updateOverlay()
            PillagerIndicator:RegisterAnimation()
        end,            --(alpha is optional)
        width = "full", --or "half" (optional)
        tooltip =
        "Color of the overlay when Pillager's Profit is active.\n\nThe base color is blue, so the color might not reflect the exact value you choose.",
        disabled = function() return not PillagerIndicator.SavedVariables.enabled end,
        default = { r = defaults.color[ 1 ], g = defaults.color[ 2 ], b = defaults.color[ 3 ], a = defaults.color[ 4 ] },
    }
    optionsData[ #optionsData + 1 ] = {
        type = "dropdown",
        name = "Sound",
        choices = {
            "No_Sound",
            "Skill_Gained",
            "Stable_FeedCarry",
            "QuestShare_Accepted",
            "Telvar_Gained",
            "Undaunted_Transact",
            "Justice_NoLongerKOS",
            "BG_MatchWon",
            "ElderScroll_Captured_Aldmeri",
            "Emperor_Coronated_Aldmeri",
            "AvA_Gate_Opened",
            "AvA_Gate_Closed",
            "EnlightenedState_Gained",
            "LevelUpReward_Fanfare",
            "Book_Collection_Completed",
            "Raid_Trial_Completed",
            "Champion_PointGained",
            "Champion_PointsCommitted",
            "Champion_RespecToggled",
            "Champion_SystemUnlocked",
        },
        getFunc = function() return PillagerIndicator.SavedVariables.sound end,
        setFunc = function( value )
            PillagerIndicator.SavedVariables.sound = value
        end,
        tooltip = "Sound that plays when Pillager's Profit is active.",
        width = "full",
        disabled = function() return not PillagerIndicator.SavedVariables.enabled end,
        default = defaults.sound
    }
    optionsData[ #optionsData + 1 ] = {
        type = "button",
        name = "Play Test Sound",
        func = function()
            PlaySound( PillagerIndicator.SavedVariables.sound )
        end,
        width = "full",
        disabled = function() return not PillagerIndicator.SavedVariables.enabled end,

    }
    optionsData[ #optionsData + 1 ] = {
        type = "divider",
        width = "full",
        disabled = function() return not PillagerIndicator.SavedVariables.enabled end,
    }
    optionsData[ #optionsData + 1 ] = {
        type = "button",
        name = "Test Pillager Indicator",
        func = function()
            onPillagerStart()
        end,
        disabled = function() return not PillagerIndicator.SavedVariables.enabled end,
    }
    LAM:RegisterOptionControls( "PillagerIndicatorOptions", optionsData )
end
local function OnPlayerActivated( eventCode )
    EVENT_MANAGER:UnregisterForEvent( PillagerIndicator.name, eventCode )
    createSettingsMenu()
end

function PillagerIndicator.Initialize()
    EVENT_MANAGER:UnregisterForEvent( PillagerIndicator.name, EVENT_ADD_ON_LOADED )
    EVENT_MANAGER:RegisterForEvent( PillagerIndicator.name, EVENT_EFFECT_CHANGED, PillagerIndicator.OnEffectChanged )
    EVENT_MANAGER:AddFilterForEvent( PillagerIndicator.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID,
        PILLAGER_ABILITY_ID )
    EVENT_MANAGER:AddFilterForEvent( PillagerIndicator.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player" )
    PillagerIndicator.SavedVariables = ZO_SavedVars:NewAccountWide( "PISettings", 1, nil, defaults,
        worldName )
    PillagerIndicator:RegisterAnimation()
    updateOverlay()
end

----------
--Events--
----------
EVENT_MANAGER:RegisterForEvent( PillagerIndicator.name, EVENT_ADD_ON_LOADED, PillagerIndicator.OnAddOnLoaded )
EVENT_MANAGER:RegisterForEvent( PillagerIndicator.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated )
