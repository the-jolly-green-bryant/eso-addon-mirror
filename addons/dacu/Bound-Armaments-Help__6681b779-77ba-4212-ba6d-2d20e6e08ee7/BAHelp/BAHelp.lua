--    Developed by Dacu https://twitch.tv/DacuTV
------------------------------------------------------------
BAHelp = {}
BAHelp.currentEndtime = {}
function BAHelp.OnAddOnLoaded(event, addonName)
    if addonName == BAHelp.name then
        BAHelp:Initialize()
    end
end
count = 0
BAHelp.Default = {
    OffsetX = 400,
    OffsetY = 400
}
BAHelp.DisplayName = "Bound Armaments Help"
BAHelp.Version = "3.0.0"
BAHelp.Author = "Dacu"
BAHelp.name = "BAHelp"
BAHelp.variableVersion = 2

function BAHelp.readEffectInfo(_, changeType, _, effectName, unitTag, beginTime, endTime, stackCount, iconName,
    buffType, _, _, statusType, unitName, unitId, abilityId, combatUnitType)
    if (abilityId == 203447 and unitTag == "player") then
    end
    if (abilityId == 203447 and stackCount >= 4 and changeType == 3 and unitTag == "player") then
        createBuffImage()
        if endTime > GetFrameTimeSeconds() then
            BAHelpIndicatorbar:SetHidden(false)
            BAHelpIndicatorbar:SetMinMax(0, endTime - beginTime)
            BAHelp:UpdateBar(endTime)
            BAHelp.currentEndtime = endTime
            EVENT_MANAGER:RegisterForUpdate('BAHelpupdate', 200, function()
                BAHelp:UpdateBar(BAHelp.currentEndtime)
            end)
        end
    end
    if (abilityId == 203447 and (stackCount >= 4 and changeType == 2 or stackCount < 4 and changeType ~= 4) and unitTag ==
        "player") then
        BAHelpIndicatorBg:SetHidden(true)
        BAHelpIndicatorbar:SetHidden(true)
        EVENT_MANAGER:UnregisterForUpdate('BAHelpupdate')
    end
end

function BAHelp:UpdateBar(endTime)
    BAHelpIndicatorbar:SetValue(endTime - GetFrameTimeSeconds())
end

function createBuffImage()
    BAHelpIndicator:SetHidden(false)
    BAHelpIndicatorBg:SetHidden(false)
    BAHelpIndicatorbar:SetHidden(false)
end

function BAHelp.SaveLoc()
    BAHelp.savedVariables.OffsetX = BAHelpIndicator:GetLeft()
    BAHelp.savedVariables.OffsetY = BAHelpIndicator:GetTop()
end

function BAHelp:RestorePosition()
    BAHelpIndicator:ClearAnchors()
    BAHelpIndicator:SetTopmost(true)
    BAHelpIndicator:BringWindowToTop(true)
    BAHelpIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, BAHelp.savedVariables.OffsetX, BAHelp.savedVariables.OffsetY)
end

function BAHelp:getClass()
    player = GetUnitClassId("player")
    return player
end

function BAHelp:show()
    if BAHelpIndicator:IsHidden() then
        BAHelpIndicator:SetHidden(false)
        BAHelpIndicatorBg:SetHidden(false)
        BAHelpIndicatorbar:SetHidden(false)
    else
        BAHelpIndicator:SetHidden(true)
        BAHelpIndicatorBg:SetHidden(true)
        BAHelpIndicatorbar:SetHidden(true)
    end
end

function BAHelp:createWindow()
    local wm = WINDOW_MANAGER
    wm:CreateTopLevelWindow("BAHelpIndicator")
    BAHelpIndicator:SetMouseEnabled(true)
    BAHelpIndicator:SetMovable(true)
    BAHelpIndicator:SetClampedToScreen(true)
    BAHelpIndicator:SetHidden(true)
    BAHelpIndicator:SetDimensions(80, 80)
    BAHelpIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, BAHelp.Default.OffsetX, BAHelp.Default.OffsetY)
    BAHelpIndicator:SetHandler("OnMoveStop", BAHelp.SaveLoc)
    BAHelp:RestorePosition()
    wm:CreateControl("$(parent)Bg", BAHelpIndicator, CT_TEXTURE)
    BAHelpIndicatorBg:SetHidden(true)
    BAHelpIndicatorBg:SetExcludeFromResizeToFitExtents(true)
    BAHelpIndicatorBg:SetTexture("/esoui/art/icons/ability_sorcerer_bound_armaments_proc.dds")
    BAHelpIndicatorBg:SetAnchor(TOP, BAHelpIndicator, TOP, 0, 0)
    BAHelpIndicatorBg:SetDimensions(80, 80)
    BAHelpIndicatorBg:SetAlpha(0.7)
    wm:CreateControl("$(parent)bar", BAHelpIndicator, CT_STATUSBAR)
    BAHelpIndicatorbar:SetDimensions(80, 5)
    BAHelpIndicatorbar:SetColor(0, 1, 0, 0.7)
    BAHelpIndicatorbar:SetAlpha(0.7)
    BAHelpIndicatorbar:SetAnchor(TOPLEFT, BAHelpIndicator, TOPLEFT, 0, 80)
    BAHelpIndicatorbar:SetHidden(true)
    BAHelpIndicatorbar:SetAlpha(0.7)

end

function BAHelp:Initialize()
    EVENT_MANAGER:UnregisterForEvent(BAHelp.name, EVENT_ADD_ON_LOADED)
    SLASH_COMMANDS["/bashow"] = BAHelp.show
    BAHelp.savedVariables = ZO_SavedVars:New("BAHelpSavedVariables", BAHelp.variableVersion, nil, BAHelp.Default)
    BAHelp:createWindow()
    EVENT_MANAGER:RegisterForEvent("EffectChange", EVENT_EFFECT_CHANGED, BAHelp.readEffectInfo)
end

EVENT_MANAGER:RegisterForEvent(BAHelp.name, EVENT_ADD_ON_LOADED, BAHelp.OnAddOnLoaded)
