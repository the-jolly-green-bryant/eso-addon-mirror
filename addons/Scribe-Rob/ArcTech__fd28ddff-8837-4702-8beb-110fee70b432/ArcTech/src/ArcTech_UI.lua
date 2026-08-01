function ArcTech.UpdatePanel()
    local event = ArcTech.GetNextEvent()

    if not event then
        ArcTechPanelNextEvent:SetText("No upcoming events")
        ArcTechPanelDescription:SetText("")
        return
    end

    local remaining = FormatTimeSeconds(
        tonumber(event.datetime) - GetTimeStamp(),
        TIME_FORMAT_STYLE_DESCRIPTIVE
    )

    ArcTechPanelNextEvent:SetText(event.title .. " (" .. remaining .. ")")
    ArcTechPanelDescription:SetText(event.description)
end

function ArcTech.TogglePanel()
    ArcTechPanel:SetHidden(not ArcTechPanel:IsHidden())

    if not ArcTechPanel:IsHidden() then
        ArcTech.UpdatePanel()
    end
end