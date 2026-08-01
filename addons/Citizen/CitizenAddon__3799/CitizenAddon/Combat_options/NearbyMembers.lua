CitizenNearbyMembers = {
    name = "CitizenNearbyMembers",
    lockUi = true,
}

--Refresh
---CitizenAddon.name .."NearbyMembers", 350
function CitizenNearbyMembers.Refresh()
    local n = 0

    local _, x1, y1, z1 = GetUnitWorldPosition('player')
    for i=1, GetGroupSize(), 1 do
        local tag = GetGroupUnitTagByIndex(i)

        if IsGroupMemberInSameLayerAsPlayer(tag) and (not IsUnitDead(tag)) then
            if CitizenAddon.combatOptions.nearbyMembers.DdOnly then
                if GetGroupMemberSelectedRole(tag) == LFG_ROLE_DPS then
                    local _, x2, y2, z2 = GetUnitWorldPosition(tag)
                    if (zo_sqrt((x1-x2)^2 + (y1-y2)^2 + (z1-z2)^2) / 100) <= CitizenAddon.combatOptions.nearbyMembers.range then
                        n = n + 1
                    end
                end
            else
                local _, x2, y2, z2 = GetUnitWorldPosition(tag)
                if (zo_sqrt((x1-x2)^2 + (y1-y2)^2 + (z1-z2)^2) / 100) <= CitizenAddon.combatOptions.nearbyMembers.range then
                    n = n + 1
                end
            end
        end
    end

    CitizenNM_Text:SetText(n)
end

function CitizenNearbyMembers.Start()
    local CitizenNM = CreateControl("CitizenNM", GuiRoot, CT_TOPLEVELCONTROL)
    CitizenNM:SetDimensions(54, 64)
    CitizenNM:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, CitizenAddon.combatOptions.nearbyMembers.left, CitizenAddon.combatOptions.nearbyMembers.top)
    CitizenNM:SetMouseEnabled(true)
    CitizenNM:SetMovable(true)
    CitizenNM:SetClampedToScreen(true)
    CitizenNM:SetDrawTier(DT_HIGH)
    CitizenNM:SetHidden(true)
    CitizenNM:SetHandler("OnMoveStop", function ()
        CitizenAddon.combatOptions.nearbyMembers.left = CitizenNM:GetLeft()
        CitizenAddon.combatOptions.nearbyMembers.top = CitizenNM:GetTop()
    end)
    -- Border Backdrop
    local border = CreateControl("CitizenNM_Border", CitizenNM, CT_BACKDROP)
    border:SetDimensions(54, 64)
    border:SetAnchor(CENTER, CitizenNM, CENTER, 0, 0)
    border:SetEdgeTexture("", 1, 1, 3)
    border:SetCenterColor(0, 0, 0, 0.7)
    border:SetEdgeColor(1, 1, 1, 0.7)
    -- Main Text Label
    local textLabel = CreateControl("CitizenNM_Text", CitizenNM, CT_LABEL)
    textLabel:SetFont("$(MEDIUM_FONT)|40|thick-outline")
    textLabel:SetColor(1, 1, 1, 1)
    textLabel:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)
    textLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    textLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    textLabel:SetText("")
    textLabel:SetAnchor(CENTER, CitizenNM, CENTER, 0, -1)
    -- "DD" Label (Initially Hidden)
    local ddLabel = CreateControl("CitizenNM_DD", CitizenNM, CT_LABEL)
    ddLabel:SetFont("$(BOLD_FONT)|14|thin-outline")
    ddLabel:SetColor(0.8, 0.8, 0.8, 1)
    ddLabel:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)
    ddLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    ddLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    ddLabel:SetText("DD")
    ddLabel:SetHidden(true)
    ddLabel:SetAnchor(BOTTOMLEFT, border, BOTTOMLEFT, 5, -2)
    -- "Range" Label
    local rangeLabel = CreateControl("CitizenNM_Range", CitizenNM, CT_LABEL)
    rangeLabel:SetFont("$(BOLD_FONT)|14|thin-outline")
    rangeLabel:SetColor(0.8, 0.8, 0.8, 1)
    rangeLabel:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)
    rangeLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    rangeLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    rangeLabel:SetText("er")
    rangeLabel:SetAnchor(BOTTOMRIGHT, border, BOTTOMRIGHT, -5, -2)
end