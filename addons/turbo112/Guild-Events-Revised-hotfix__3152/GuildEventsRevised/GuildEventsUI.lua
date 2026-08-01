GuildEventsUI = GuildEventsUI or {}
local ui = GuildEventsUI

function GuildEventsUI.init()
    if ui.created then return end
    ui.created = true

    GuildEventsUI:CreateEvents()
    GuildEventsUI:Create()
    GuildEventsUI:CreateScene()
end
