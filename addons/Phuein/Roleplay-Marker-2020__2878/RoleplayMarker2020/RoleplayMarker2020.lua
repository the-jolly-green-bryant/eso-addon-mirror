RoleplayMarker = {
    name            = "RoleplayMarker2020",
    author          = "Phuein",
    color           = "BB55EE",             -- Used in menu titles and so on.
    menuName        = "Roleplay Marker 2020",    -- A UNIQUE identifier for menu object.
}

-- Default settings.
RoleplayMarker.savedVars = {
    firstLoad = true,                   -- First time the addon is loaded ever.
    accountWide = false,                -- Load settings from account savedVars, instead of character.
    markedByTitle = true,
    markerTextureColor = {1, 1, 1, 1}, -- No coloration.
}

RoleplayMarker.markerTexture = 'RoleplayMarker2020/icons/quest1.dds'
RoleplayMarker.markerTitle = 'Recruit' -- Empty string to mark characters without an active title.
RoleplayMarker.markerMatchName = "^-.*'" -- Regexp.

-- Wraps text with a color.
function RoleplayMarker.Colorize(text, color)
    -- Default to addon's .color.
    if not color then color = RoleplayMarker.color end

    text = string.format('|c%s%s|r', color, text)

    return text
end

RoleplayMarker.UnitFrameChanged = false
function RoleplayMarker.ReticleChanged(event, a, b)
    -- Only for players.
    if not IsUnitPlayer('reticleover') then
        -- Reset changes.
        if RoleplayMarker.UnitFrameChanged == true then
            RoleplayMarker.UnitFrameChanged = false
            -- Empty.
        end
        return
    end

    RoleplayMarker.UnitFrameChanged = true

    local targetName = ZO_TargetUnitFramereticleoverName:GetText()

    local match = false

    -- Character name starts with - and has an ' in it.
    if targetName:match(RoleplayMarker.markerMatchName) then
        match = true
    end

    if RoleplayMarker.savedVars.markedByTitle then
        if GetUnitTitle('reticleover') == RoleplayMarker.markerTitle then
            match = true
        end
    end

    if not match then
        for i=0, #SubmittedCharacterNames, 1 do
            if SubmittedCharacterNames[i] == targetName then
                match = true
                break
            end
        end
    end

    if not match then return end

    -- Persistent changes.
    zo_callLater(function ()
        -- UNIT_FRAMES.staticFrames['reticleover']
        ZO_TargetUnitFramereticleoverName:SetText(targetName .. '  ＲＰ')
        ZO_TargetUnitFramereticleoverRankIcon:SetTexture(RoleplayMarker.markerTexture)
        ZO_TargetUnitFramereticleoverRankIcon:SetColor(unpack(RoleplayMarker.savedVars.markerTextureColor))
    end, 10)
end

function RoleplayMarker.OnAddOnLoaded(event, addonName)
    if addonName ~= RoleplayMarker.name then return end
    EVENT_MANAGER:UnregisterForEvent(RoleplayMarker.name, EVENT_ADD_ON_LOADED)

    -- Load saved variables.
    RoleplayMarker.characterSavedVars = ZO_SavedVars:New("RoleplayMarkerSavedVariables", 2, nil, RoleplayMarker.savedVars)
    RoleplayMarker.accountSavedVars = ZO_SavedVars:NewAccountWide("RoleplayMarkerSavedVariables", 2, nil, RoleplayMarker.savedVars)

    if not RoleplayMarker.characterSavedVars.accountWide then
        RoleplayMarker.savedVars = RoleplayMarker.characterSavedVars
    else
        RoleplayMarker.savedVars = RoleplayMarker.accountSavedVars
    end

    -- Settings menu in Settings.lua.
    RoleplayMarker.LoadSettings()

    EVENT_MANAGER:RegisterForEvent(RoleplayMarker.name, EVENT_RETICLE_TARGET_CHANGED, RoleplayMarker.ReticleChanged)
end
-- When any addon is loaded, but before UI (Chat) is loaded.
EVENT_MANAGER:RegisterForEvent(RoleplayMarker.name, EVENT_ADD_ON_LOADED, RoleplayMarker.OnAddOnLoaded)