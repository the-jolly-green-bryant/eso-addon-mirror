KyzderpsDerps = KyzderpsDerps or {}
KyzderpsDerps.Tribute = KyzderpsDerps.Tribute or {}
local Tribute = KyzderpsDerps.Tribute

---------------------------------------------------------------------
-- Update timer UI
---------------------------------------------------------------------
-- * FormatTimeMilliseconds(*integer* _timeValueInMilliseconds_, *[TimeFormatStyleCode|#TimeFormatStyleCode]* _formatType_, *[TimeFormatPrecisionCode|#TimeFormatPrecisionCode]* _precisionType_, *[TimeFormatDirectionCode|#TimeFormatDirectionCode]* _direction_)
-- ** _Returns:_ *string* _formattedTimeString_, *integer* _nextUpdateTimeInMilliseconds_
local function UpdateTimer()
    local timeRemaining = GetTributeRemainingTimeForTurn()
    local formattedTime = ""
    if (timeRemaining == nil) then
        formattedTime = "∞"
    else
        formattedTime = FormatTimeMilliseconds(timeRemaining, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_SECONDS, TIME_FORMAT_DIRECTION_DESCENDING)
    end
    KDD_TributeLabel:SetText(string.format("%s remaining", formattedTime))
end

---------------------------------------------------------------------
-- Game state change
---------------------------------------------------------------------
-- EVENT_TRIBUTE_GAME_FLOW_STATE_CHANGE (*[TributeGameFlowState|#TributeGameFlowState]* _flowState_)
local function OnGameFlowStateChange(_, flowState)
    local gameFlowStates = {
        [TRIBUTE_GAME_FLOW_STATE_BOARD_SETUP] = "BOARD_SETUP",
        [TRIBUTE_GAME_FLOW_STATE_GAME_OVER] = "GAME_OVER",
        [TRIBUTE_GAME_FLOW_STATE_INACTIVE] = "INACTIVE",
        [TRIBUTE_GAME_FLOW_STATE_INTRO] = "INTRO",
        [TRIBUTE_GAME_FLOW_STATE_PATRON_DRAFT] = "PATRON_DRAFT",
        [TRIBUTE_GAME_FLOW_STATE_PLAYING] = "PLAYING",
    }

    KyzderpsDerps:dbg(string.format("Tribute game flow state: %s", gameFlowStates[flowState]))
    KyzderpsDerps:dbg(GetTributePlayerInfo(TRIBUTE_PLAYER_PERSPECTIVE_OPPONENT))

    if (flowState == TRIBUTE_GAME_FLOW_STATE_PLAYING) then
        EVENT_MANAGER:RegisterForUpdate(KyzderpsDerps.name .. "TributePoll", 500, UpdateTimer)
        KDD_TributeLabel:SetHidden(false)
    elseif (flowState == TRIBUTE_GAME_FLOW_STATE_GAME_OVER) then
        EVENT_MANAGER:UnregisterForUpdate(KyzderpsDerps.name .. "TributePoll")
        KDD_TributeLabel:SetHidden(true)
    end
end

---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
function Tribute.Initialize()
    KyzderpsDerps:dbg("    Initializing Tribute module...")

    EVENT_MANAGER:UnregisterForEvent(KyzderpsDerps.name .. "TributeState", EVENT_TRIBUTE_GAME_FLOW_STATE_CHANGE)
    if (KyzderpsDerps.savedOptions.misc.tributeTimer) then
        EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "TributeState", EVENT_TRIBUTE_GAME_FLOW_STATE_CHANGE, OnGameFlowStateChange)

        -- Is it possible to reload or change settings during a match? Maybe?
        if (GetTributeMatchType() and GetTributeMatchType() ~= TRIBUTE_MATCH_TYPE_DEFAULT) then
            OnGameFlowStateChange(nil, TRIBUTE_GAME_FLOW_STATE_PLAYING)
        end
    end
end


---------------------------------------------------------------------
-- Settings
---------------------------------------------------------------------
function Tribute.GetSettings()
    return {
        type = "checkbox",
        name = "Show Tales of Tribute turn timer",
        tooltip = "Shows a numerical value of the time remaining in your or your opponent's turn",
        default = true,
        getFunc = function() return KyzderpsDerps.savedOptions.misc.tributeTimer end,
        setFunc = function(value)
            KyzderpsDerps.savedOptions.misc.tributeTimer = value
            Tribute.Initialize()
        end,
        width = "full",
    }
end

--[[
h5. TributePatronPerspectiveFavorState
* TRIBUTE_PATRON_PERSPECTIVE_FAVOR_STATE_FAVORS_OPPONENT
* TRIBUTE_PATRON_PERSPECTIVE_FAVOR_STATE_FAVORS_PLAYER
* TRIBUTE_PATRON_PERSPECTIVE_FAVOR_STATE_NEUTRAL


* GetNumPatronsFavoringPlayerPerspective(*[TributePlayerPerspective|#TributePlayerPerspective]* _playerPerspective_)
** _Returns:_ *integer* _numPatronsFavored_

* GetTributePlayerPerspectiveResource(*[TributePlayerPerspective|#TributePlayerPerspective]* _playerPerspective_, *[TributeResource|#TributeResource]* _resource_)
** _Returns:_ *integer* _value_

* GetTributePatronIdAtIndex(*luaindex* _index_)
** _Returns:_ *integer* _patronId_

* GetTributePatronName(*integer* _patronId_)
** _Returns:_ *string* _patronName_

* IsTributePatronNeutral(*integer* _patronId_)
** _Returns:_ *bool* _isNeutral_

* DoesTributePatronSkipNeutralFavorState(*integer* _patronId_)
** _Returns:_ *bool* _doesSkipNeutral_
]]

