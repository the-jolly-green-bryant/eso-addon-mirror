StarNames = StarNames or {}

----------------------------------------------------------------
-- Refresh/reset star labels to the default
function StarNames.RefreshLabels(show)
    for i = 1, ZO_ChampionPerksCanvas:GetNumChildren() do
        local child = ZO_ChampionPerksCanvas:GetChild(i)
        if (child.star and child.star.championSkillData) then
            local id = child.star.championSkillData.championSkillId
            local n = child:GetNamedChild("Name")
            if (not n) then
                n = WINDOW_MANAGER:CreateControl("$(parent)Name", child, CT_LABEL)
                n:SetInheritScale(false)
                n:SetAnchor(CENTER, child, CENTER, 0, -20)
            end
            local slottable = CanChampionSkillTypeBeSlotted(GetChampionSkillType(id))
            if (slottable) then
                n:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick", StarNames.savedOptions.slottableLabelSize))
                n:SetColor(unpack(StarNames.savedOptions.slottableLabelColor))
            else
                n:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick", StarNames.savedOptions.passiveLabelSize))
                n:SetColor(unpack(StarNames.savedOptions.passiveLabelColor))
            end
            n:SetText(zo_strformat("<<C:1>>", GetChampionSkillName(id)))
            n:SetHidden(not show)
        elseif (child.star and child.star.championClusterData) then
            local text = ""
            for _, clusterChild in ipairs(child.star.championClusterData.clusterChildren) do
                text = text .. clusterChild:GetFormattedName() .. "\n"
            end
            local n = child:GetNamedChild("Name")
            if (not n) then
                n = WINDOW_MANAGER:CreateControl("$(parent)Name", child, CT_LABEL)
                n:SetInheritScale(false)
                n:SetAnchor(CENTER, child, CENTER, 0, -20)
            end
            n:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thin", StarNames.savedOptions.clusterLabelSize))
            n:SetColor(unpack(StarNames.savedOptions.clusterLabelColor))
            n:SetText(text)
            n:SetHidden(not show)
        end
    end
end

----------------------------------------------------------------
-- Utility function to check if the center of a control is somewhere in the GUI
local function IsInBounds(control)
    local x, y = control:GetCenter()
    return x >= 0 and x <= GuiRoot:GetWidth() and y >= 0 and y <= GuiRoot:GetHeight()
end

----------------------------------------------------------------
-- Wait until CP animation ends to determine current constellation based on canvas location
local function OnCanvasAnimationStopped()
    EVENT_MANAGER:UnregisterForUpdate(StarNames.name .. "RectTimeout")

    if (ZO_ChampionPerksCanvas:IsHidden()) then
        -- This is not consistent, do not use this to trigger CP exit events
        return
    end

    local greenBounds = IsInBounds(ZO_ChampionPerksCanvasConstellation1) or IsInBounds(ZO_ChampionPerksCanvasConstellation4)
    local blueBounds = IsInBounds(ZO_ChampionPerksCanvasConstellation2) or IsInBounds(ZO_ChampionPerksCanvasConstellation5)
    local redBounds = IsInBounds(ZO_ChampionPerksCanvasConstellation3) or IsInBounds(ZO_ChampionPerksCanvasConstellation6)

    local activeConstellation = nil
    if (greenBounds and blueBounds and redBounds) then
        activeConstellation = "All"
        if (StarNames.savedOptions.showOnMainScreen == false) then
            StarNames.RefreshLabels(StarNames.savedOptions.showOnMainScreen)
        end
    elseif (greenBounds) then
        activeConstellation = "Green"
        StarNames.RefreshLabels(StarNames.savedOptions.showLabels)
    elseif (blueBounds) then
        activeConstellation = "Blue"
        StarNames.RefreshLabels(StarNames.savedOptions.showLabels)
    elseif (redBounds) then
        activeConstellation = "Red"
        StarNames.RefreshLabels(StarNames.savedOptions.showLabels)
    else
        activeConstellation = "Cluster"
        StarNames.RefreshLabels(StarNames.savedOptions.showLabels)
    end
end

----------------------------------------------------------------
-- Function to hide labels when starting animation
local function OnCanvasAnimationStarted()
    -- TODO: Implement handler for OnCanvasAnimationStarted if needed
    return
end

----------------------------------------------------------------
-- Utility function to toggle the visibility of star labels
function StarNames.ToggleLabels()
    -- TODO: Have this function update the settings menu if it's open
    StarNames.savedOptions.showLabels = not StarNames.savedOptions.showLabels
    StarNames.dbg("ToggleLabels: showLabels set to " .. tostring(StarNames.savedOptions.showLabels))
    StarNames.RefreshLabels(StarNames.savedOptions.showLabels)
end

----------------------------------------------------------------
-- Some first-time actions
function StarNames.InitLabels()
    -- Timeout to not spam operations on every animation tick
    ZO_ChampionPerksCanvasConstellation1:SetHandler("OnRectChanged", function()
        EVENT_MANAGER:RegisterForUpdate(StarNames.name .. "RectTimeout", 100, OnCanvasAnimationStopped)
    end)
    -- TODO: Add handler for OnCanvasAnimationStarted to not show labels; may make transitions to main screen look better when option to hide labels on it is selected
end
