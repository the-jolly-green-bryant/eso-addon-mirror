--[[
	Addon: util
	Author: TProg Taonnor
	Created by @Taonnor
]]--

-- Version Control
local VERSION = 3

--[[
	Class definition (Static class)
]]--
-- A table in hole lua workspace must be unique
-- The ui helper is global util table, used in several of my addons
-- The table is created as "static" class without constructor and static helper methods
if (TaosUiHelper == nil or TaosUiHelper.Version == nil or TaosUiHelper.Version < VERSION) then
	TaosUiHelper = {}
	TaosUiHelper.__index = TaosUiHelper
    TaosUiHelper.Version = VERSION

    -- Global Callback Variables
    TUI_HUD_HIDDEN_STATE_CHANGED = "TUI-HudHiddenStateChange" -- Older version, for compability
    TAO_HUD_HIDDEN_STATE_CHANGED = "TAO-HudHiddenStateChange"

	-- isHidden logic for hud scenes
    -- This logic will fire TAO_HUD_HIDDEN_STATE_CHANGED if hud scenes not visible:
    -- hud = true; hudui = true -> isHidden = true
    -- hud = true; hudui = false -> isHidden = false
    -- hud = false; hudui = true -> isHidden = false
    -- hud = false; hudui = false -> isHidden = false
    local _internalHudSceneState = true
    local _internalHudUiSceneState = true
    local _internalHudHiddenState = true
    
    --[[
	    ==============
        PUBLIC METHODS
        ==============
    ]]--

    --[[
        CurrentHudHiddenState Gets the hidden state of hud/hudui
    ]]--
    function CurrentHudHiddenState()
        return _internalHudHiddenState
    end

     --[[
        FireCallbacksAsync Fires callbacks async, maximum 2 values
    ]]--
    function FireCallbacksAsync(callbackName, value1, value2)
        -- zo_callLater will use EVENT_MANAGER to fire the callbacks async after 1 ms
        zo_callLater(
            function() 
                CALLBACK_MANAGER:FireCallbacks(callbackName, value1, value2)
            end, 1)
    end
    
     --[[
        GetAdjustedLabelColor Returns dark or light color for labels on base of background color
    ]]--
    function GetAdjustedLabelColor(backgroundColor)
        local isDarken = (backgroundColor.R * 76.245 + backgroundColor.G * 149.685 + backgroundColor.B * 29.07) > 186

        if (isDarken) then
            return { R = 0.1, G = 0.1, B = 0.1, A = 1 }
        else
            return { R = 0.9, G = 0.9, B = 0.9, A = 1 }
        end
    end

    --[[
	    ===============
        PRIVATE METHODS
        ===============
    ]]--

    --[[
        UpdateHiddenState updates the hidden state on base of hud/hudui state
    ]]--
    local function UpdateHiddenState()
		local isHidden = _internalHudSceneState and _internalHudUiSceneState
		
        if (isHidden ~= _internalHudHiddenState) then
            _internalHudHiddenState = isHidden
            FireCallbacksAsync(TUI_HUD_HIDDEN_STATE_CHANGED, isHidden)
            FireCallbacksAsync(TAO_HUD_HIDDEN_STATE_CHANGED, isHidden)
        end
    end

    --[[
        HudSceneOnStateChange callback of hud OnStateChange
    ]]--
    local function HudSceneOnStateChange(oldState, newState)
        if (newState == SCENE_HIDING) then
            _internalHudSceneState = true
			-- make call async to catch both state changes before changing visibility
			zo_callLater(UpdateHiddenState, 1)
        elseif (newState == SCENE_SHOWING) then
            _internalHudSceneState = false
			-- make call async to catch both state changes before changing visibility
			zo_callLater(UpdateHiddenState, 1)
        end
    end

    --[[
        HudUiSceneOnStateChange callback of hudui OnStateChange
    ]]--
    local function HudUiSceneOnStateChange(oldState, newState)
		if (newState == SCENE_HIDING) then
            _internalHudUiSceneState = true
			-- make call async to catch both state changes before changing visibility
			zo_callLater(UpdateHiddenState, 1)
        elseif (newState == SCENE_SHOWING) then
            _internalHudUiSceneState = false
			-- make call async to catch both state changes before changing visibility
			zo_callLater(UpdateHiddenState, 1)
        end
    end

    --[[
        Register callbacks to scenes
    ]]--
     -- Reticle Scene
    SCENE_MANAGER:GetScene("hud"):RegisterCallback("StateChange", HudSceneOnStateChange)
     -- Mouse Scene
    SCENE_MANAGER:GetScene("hudui"):RegisterCallback("StateChange", HudUiSceneOnStateChange)
    
end