--[[
    This addon is a template that helps developers create new addons.
    Most parts can be removed or modified to need.
--]]

GamepadStayMounted = {
    name     = "GamepadStayMounted",        -- Matches folder and Manifest file names.
    appVersion = "1.1.0",                -- A nuisance to match to the Manifest.
    author   = "SirNightstorm",
    color    = "DDFFEE",           -- Used in menu titles and so on.
    menuName = "Stay Mounted",        -- A UNIQUE identifier for menu object.
}

-- Default settings.
GamepadStayMounted.saved = {
    allowUse = true,
    allowOpen = true
--     firstLoad = true,                   -- First time the addon is loaded ever.
--     accountWide = false,                -- Load settings from account savedVars, instead of character.
}

-- Wraps text with a color.
-- function GamepadStayMounted.Colorize(text, color)
--     -- Default to addon's .color.
--     if not color then color = GamepadStayMounted.color end

--     text = string.format('|c%s%s|r', color, text)

--     return text
-- end

local useString = GetString(SI_GAMECAMERAACTIONTYPE5) -- Use
local openString = GetString(SI_GAMECAMERAACTIONTYPE13) -- Open

local function isAllowedInteraction()
    local action, interactableName, interactionBlocked, isOwned, additionalInteractInfo, context, contextLink, isCriminalInteract = GetGameCameraInteractableActionInfo()

	-- local playersZoneIndex = GetUnitZoneIndex("player")
	-- local zoneId = GetZoneId(playersZoneIndex or 0)

    -- d("Zone Id " .. (zoneId or -1))

    -- if zoneId == 181 then -- Cyrodiil
        -- _G["GSM"] = { GetGameCameraInteractableActionInfo(), useString }

        if (action == useString and GamepadStayMounted.saved.allowUse) or
           (action == openString and GamepadStayMounted.saved.allowUse) then
            return true
        end
    -- end

    return false
end

local function overrideInteractFunction()
    local oldGIPV = RETICLE.GetInteractPromptVisible
    RETICLE.GetInteractPromptVisible = function(self)
        if IsMounted() and not isAllowedInteraction() then
            -- RETICLE.additionalInfo:SetHidden(false)
            -- RETICLE.additionalInfo:SetText("")
            -- RETICLE.interactKeybindButton:SetNormalTextColor(ZO_ERROR_COLOR)

            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, "Dismount to interact")
            return false
        else
            local ret = oldGIPV(self)
            -- ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, GamepadStayMounted.name..": GetInteractPromptVisible: "..tostring(ret))
            return ret
        end
    end

    local updateInteractText = RETICLE.UpdateInteractText
    RETICLE.UpdateInteractText = function(self, ...)
        -- stealInfoControl:SetHidden(IsInteractionAllowed() or settings.hideInfo)
        -- SetInfoText()
        local ret = updateInteractText(self, ...)
        if IsMounted() and IsInGamepadPreferredMode() and not isAllowedInteraction() then
            RETICLE.interactKeybindButton:SetEnabled(false) -- SetNormalTextColor(ZO_ERROR_COLOR)
            RETICLE.additionalInfo:SetHidden(false)
            RETICLE.additionalInfo:SetText("Dismount to interact")

        end
    end

    -- local oldSI = INTERACTIVE_WHEEL_MANAGER.StartInteraction
    -- INTERACTIVE_WHEEL_MANAGER.StartInteraction = function(self, interactionType, ...)
    --     if IsMounted() then
    --         ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, "Interaction disabled - mounted")
    --         return true
    --     else
    --         return oldSI(self, interactionType, ...)
    --     end
    -- end
end

-- Only show the loading message on first load ever.
function GamepadStayMounted.Activated(e)
    EVENT_MANAGER:UnregisterForEvent(GamepadStayMounted.name, EVENT_PLAYER_ACTIVATED)

    -- if GamepadStayMounted.savedVars.firstLoad then
    --     GamepadStayMounted.savedVars.firstLoad = false

    --     d(GamepadStayMounted.name .. GetString(SI_NEW_ADDON_MESSAGE)) -- Prints to chat.

    --     ZO_AlertNoSuppression(UI_ALERT_CATEGORY_ALERT, nil,
    --         GamepadStayMounted.name .. GetString(SI_NEW_ADDON_MESSAGE)) -- Top-right alert.
    -- end
end

-- When player is ready, after everything has been loaded.
EVENT_MANAGER:RegisterForEvent(GamepadStayMounted.name, EVENT_PLAYER_ACTIVATED, GamepadStayMounted.Activated)

function GamepadStayMounted.OnAddOnLoaded(event, addonName)
    if addonName ~= GamepadStayMounted.name then return end
    EVENT_MANAGER:UnregisterForEvent(GamepadStayMounted.name, EVENT_ADD_ON_LOADED)

    -- Load saved variables.
    -- GamepadStayMounted.characterSavedVars = ZO_SavedVars:New("GamepadStayMountedSavedVariables", 1, nil, GamepadStayMounted.savedVars)
    GamepadStayMounted.saved = ZO_SavedVars:NewAccountWide("GamepadStayMountedSavedVariables", 1, nil, GamepadStayMounted.saved)

    -- if not GamepadStayMounted.characterSavedVars.accountWide then
    --     GamepadStayMounted.savedVars = GamepadStayMounted.characterSavedVars
    -- else
    --     GamepadStayMounted.savedVars = GamepadStayMounted.accountSavedVars
    -- end

    -- Settings menu in Settings.lua.
    GamepadStayMounted.LoadSettings()

    overrideInteractFunction()

    -- The following is only needed when changing SLASH_COMMANDS live,
    -- but not when loading addons, starting with 100030.
    -- CHAT_SYSTEM.textEntry.slashCommandAutoComplete:InvalidateSlashCommandCache()
end

-- When any addon is loaded, but before UI (Chat) is loaded.
EVENT_MANAGER:RegisterForEvent(GamepadStayMounted.name, EVENT_ADD_ON_LOADED, GamepadStayMounted.OnAddOnLoaded)
