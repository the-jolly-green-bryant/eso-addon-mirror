ratpins = {
    name            = "Ohi, ratpins",           -- Matches folder and Manifest file names.
    -- version         = "1.0",                -- A nuisance to match to the Manifest.
    author          = "ratphinx",
    color           = "DDFFEE",             -- Used in menu titles and so on.
    menuName        = "ratpins",          -- A UNIQUE identifier for menu object.
}

-- Default settings.
ratpins.savedVars = {
    firstLoad = true,                   -- First time the addon is loaded ever.
    accountWide = false,                -- Load settings from account savedVars, instead of character.
}

function ratpins.AnimateText()
    -- Avoid playing the animation over itself.
    if not ratpinsActive:IsHidden() then return end

    local animation, timeline = CreateSimpleAnimation(ANIMATION_ALPHA, ratpinsActive)

    ratpinsActive:SetHidden(false)
    animation:SetAlphaValues(ratpinsActive:GetAlpha(), 1)
    animation:SetDuration(3000)

    -- Fade-out after fade-in.
    timeline:SetHandler('OnStop', function()
        local animation, timeline = CreateSimpleAnimation(ANIMATION_ALPHA, ratpinsActive)

        animation:SetAlphaValues(ratpinsActive:GetAlpha(), 0)
        animation:SetDuration(3000)

        timeline:SetHandler('OnStop', function()
            ratpinsActive:SetHidden(true)
        end)

        timeline:PlayFromStart()
    end)

    timeline:PlayFromStart()
end

function ratpins.Activated(e)
    EVENT_MANAGER:UnregisterForEvent(ratpins.name, EVENT_PLAYER_ACTIVATED)

    if ratpins.savedVars.firstLoad then
        ratpins.savedVars.firstLoad = false

        d(ratpins.name .. GetString(SI_NEW_ADDON_MESSAGE)) -- Prints to chat.

        ZO_AlertNoSuppression(UI_ALERT_CATEGORY_ALERT, nil,
            ratpins.name .. GetString(SI_NEW_ADDON_MESSAGE)) -- Top-right alert.

        -- Animate the xml UI center text, after a delay.
        zo_callLater(ratpins.AnimateText, 3000)
    end
end

local function OnPlayerActivated()
    SetFloatingMarkerInfo(MAP_PIN_TYPE_GROUP_LEADER, 100, "/ratpins/icons/pinkarrow.dds")
end

EVENT_MANAGER:RegisterForEvent("ratpins", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)