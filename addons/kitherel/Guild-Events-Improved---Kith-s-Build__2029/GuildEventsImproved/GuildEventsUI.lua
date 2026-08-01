GuildEventsUI = GuildEventsUI or {}
local ui = GuildEventsUI

function GuildEventsUI.refresh()
    --ui.fragmentEnabled.enabled:UpdateValue()
    --ui.fragmentEnabled.text:UpdateValue()
    --ui.fragmentOptions.cyr:UpdateValue()
    --ui.fragmentOptions.restart:UpdateValue()
    --ui.fragmentOptions.kick:UpdateValue()
    --ui.fragmentOptions.kickTime:UpdateValue()
    --ui.fragmentOptions.max:UpdateValue()
end

function GuildEventsUI.init()
    if ui.created then return end
    ui.created = true
    --AutoInviteUI:CreateEnabledFragment()
    --AutoInviteUI:CreateOptionFragment()
    --AutoInviteUI:CreateScene()

    GuildEventsUI:CreateEvents()
    GuildEventsUI:Create()
    GuildEventsUI:CreateScene()
end
