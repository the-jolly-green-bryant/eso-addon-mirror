-- Slightly Improved™ Experience Bar
-- The MIT License © 2019 Arthur Corenzan
-- FreeBSD License © 2014 Kevin Douglas

local NAMESPACE = "SlightlyImprovedExperienceBar"

--
--
--

local function UpdatePlayerProgressBarFragment(visibility)
    if visibility == "Always Show" then
        HUD_SCENE:AddFragment(PLAYER_PROGRESS_BAR_CURRENT_FRAGMENT)
        HUD_UI_SCENE:AddFragment(PLAYER_PROGRESS_BAR_CURRENT_FRAGMENT)
    else
        HUD_SCENE:RemoveFragment(PLAYER_PROGRESS_BAR_CURRENT_FRAGMENT)
        HUD_UI_SCENE:RemoveFragment(PLAYER_PROGRESS_BAR_CURRENT_FRAGMENT)
    end
end

local function UpdatePlayerProgressBarLabel(label)
    local barTypeInfo
    local level = 0
    local current = 0
    local levelSize = 0
    barTypeInfo = PLAYER_PROGRESS_BAR:GetBarTypeInfo()
    level, current, levelSize = PLAYER_PROGRESS_BAR:GetMostRecentlyShownInfo()

    if barTypeInfo then
        if levelSize then
            if current < levelSize then
                local percentageXP = zo_floor(current / levelSize * 100)
                label:SetText(zo_strformat(barTypeInfo.tooltipCurrentMaxFormat, ZO_CommaDelimitNumber(current), ZO_CommaDelimitNumber(levelSize), percentageXP))
            end
        end
    end
end

--
--
--

local defaultSavedVars = {
    visibility = "Always Show"
}

CALLBACK_MANAGER:RegisterCallback(NAMESPACE.."_OnSavedVarChanged", function(key, newValue, previousValue)
    if key == "visibility" then
        UpdatePlayerProgressBarFragment(newValue)
    end
end)

CALLBACK_MANAGER:RegisterCallback(NAMESPACE.."_OnAddOnLoaded", function(savedVars)

    -- Create and anchor progression label on top of the experience bar.
    local label = CreateControl("ZO_PlayerProgressBarProgressionLabel", ZO_PlayerProgressBar, CT_LABEL)
    label:SetFont("ZoFontWinH4")
    label:SetAnchor(CENTER, ZO_PlayerProgressBar)

    -- Hook into the method that updates the label with the level so it also updates the progression label.
    local setLevelLabelText = PLAYER_PROGRESS_BAR.SetLevelLabelText
    function PLAYER_PROGRESS_BAR:SetLevelLabelText(...)
        setLevelLabelText(self, ...)
        UpdatePlayerProgressBarLabel(label)
    end

    -- Update fragment once on load.
    UpdatePlayerProgressBarFragment(savedVars.visibility)
end)

--
--
--

-- Add-on entrypoint. You should NOT need to edit below this line.
-- Make sure you have set a NAMESPACE variable and you're good to go.
--
-- If you need to hook into the AddOnLoaded event use the NAMESPACE.."_OnAddOnLoaded" callback. e.g.
-- CALLBACK_MANAGER:RegisterCallback(NAMESPACE.."_OnAddOnLoaded", function(savedVars)
--     ...
-- end)
--
-- To listen to saved variables being changed use the NAMESPACE.."_OnSavedVarChanged" callback. e.g.
-- CALLBACK_MANAGER:RegisterCallback(NAMESPACE.."_OnSavedVarChanged", function(key, newValue, previousValue)
--     ...
-- end)
--
EVENT_MANAGER:RegisterForEvent(NAMESPACE, EVENT_ADD_ON_LOADED, function(eventCode, addOnName)
    if (addOnName == NAMESPACE) then
        local savedVars = ZO_SavedVars:New(NAMESPACE.."_SavedVars", 1, nil, defaultSavedVars)
        do
            local t = getmetatable(savedVars)
            local __newindex = t.__newindex
            function t.__newindex(self, key, value)
                CALLBACK_MANAGER:FireCallbacks(NAMESPACE.."_OnSavedVarChanged", key, value, self[key])
                __newindex(self, key, value)
            end
        end
        CALLBACK_MANAGER:FireCallbacks(NAMESPACE.."_OnAddOnLoaded", savedVars)
    end
end)
