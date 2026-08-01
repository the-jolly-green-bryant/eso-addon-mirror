-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- TBO_TributeGameTracker: A simple API for ESO's EVENT_MANAGER periodic Update 
--
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Version 1.1.0 by Teebow Ganx
-- Copyright (c) 2021 Trailing Zee Productions, LLC.
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -

-- Right now (June 2022) there doesn't seem to be an easy way to know if the player
-- is currently playing the Tribute card game. So this object will tell you the state
-- or if the player is actively playing the game.

-- The game can be in one of these states.  There doesn't seem to be a way to query
-- to see which state the game is in, it only seems to be that you can get notified
-- when the game state changes.

-- So the assumption here is you create this tracker object in your Addon's OnLoad function
-- Which happens when loading UI therefore I'm hoping the game isn't active.

-- If the use hits /reloadUI while in the middle of a game. I dunno what happens.

-- TributeGameFlowState
-- * TRIBUTE_GAME_FLOW_STATE_BOARD_SETUP
-- * TRIBUTE_GAME_FLOW_STATE_GAME_OVER
-- * TRIBUTE_GAME_FLOW_STATE_INACTIVE
-- * TRIBUTE_GAME_FLOW_STATE_INTRO
-- * TRIBUTE_GAME_FLOW_STATE_PATRON_DRAFT
-- * TRIBUTE_GAME_FLOW_STATE_PLAYING

local tboTributeTracker = ZO_CallbackObject:Subclass()
TBO_TributeGameTracker = tboTributeTracker

local eventHandlerInstalled = false
local currentGameState = TRIBUTE_GAME_FLOW_STATE_INACTIVE -- Assume game is inactive when object is created


-- TributeGameFlowState
-- * TRIBUTE_GAME_FLOW_STATE_BOARD_SETUP
-- * TRIBUTE_GAME_FLOW_STATE_GAME_OVER
-- * TRIBUTE_GAME_FLOW_STATE_INACTIVE
-- * TRIBUTE_GAME_FLOW_STATE_INTRO
-- * TRIBUTE_GAME_FLOW_STATE_PATRON_DRAFT
-- * TRIBUTE_GAME_FLOW_STATE_PLAYING

local function EVENT_TributeGameStateChanged(eventCode, flowState)
	
    currentGameState = flowState

    local flowStateStr = "Unknown"
	if flowState == TRIBUTE_GAME_FLOW_STATE_BOARD_SETUP then flowStateStr = "Setting Up Board" end
	if flowState == TRIBUTE_GAME_FLOW_STATE_GAME_OVER then flowStateStr = "Game Over" end
	if flowState == TRIBUTE_GAME_FLOW_STATE_INACTIVE then flowStateStr = "Inactive" end
	if flowState == TRIBUTE_GAME_FLOW_STATE_INTRO then flowStateStr = "Introduction" end
	if flowState == TRIBUTE_GAME_FLOW_STATE_PATRON_DRAFT then flowStateStr = "Drafting Patrons" end
	if flowState == TRIBUTE_GAME_FLOW_STATE_PLAYING then flowStateStr = "Playing The Game" end
	-- d(string.format("TBO_TributeGameTracker: Tribute Game State Changed: %s", flowStateStr))
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

function TBO_TributeGameTracker:New()
    	
    local tboTributeTrackerObj = ZO_Object.New(self)

    if eventHandlerInstalled == false then
        EVENT_MANAGER:RegisterForEvent("TBO_TributeGameTracker", EVENT_TRIBUTE_GAME_FLOW_STATE_CHANGE, EVENT_TributeGameStateChanged)
        eventHandlerInstalled = true      
    end

    return tboTributeTrackerObj
end

function TBO_TributeGameTracker:SetCurrGameState(inGameState)

    if inGameState == TRIBUTE_GAME_FLOW_STATE_BOARD_SETUP or
        inGameState == TRIBUTE_GAME_FLOW_STATE_GAME_OVER or
        inGameState == TRIBUTE_GAME_FLOW_STATE_INACTIVE or
        inGameState == TRIBUTE_GAME_FLOW_STATE_INTRO or
        inGameState == TRIBUTE_GAME_FLOW_STATE_PATRON_DRAFT or
        inGameState == TRIBUTE_GAME_FLOW_STATE_PLAYING then
            currentGameState = inGameState
    end
end

function TBO_TributeGameTracker:GameIsActive()
    return currentGameState ~= TRIBUTE_GAME_FLOW_STATE_INACTIVE
end

function TBO_TributeGameTracker:GetCurrGameState()
    return currentGameState
end