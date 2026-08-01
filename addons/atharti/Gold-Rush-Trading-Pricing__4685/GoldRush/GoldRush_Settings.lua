local GR = GoldRush

function GR.InitSettings()
    local LAM = LibAddonMenu2

    GR.SV.guildProcessorsEnabled = GR.SV.guildProcessorsEnabled or {}
    for i = 1, GetNumGuilds() do
        local guildId = GetGuildId(i)
        local guildName = GetGuildName(guildId)
        if guildName and guildName ~= "" and GR.SV.guildProcessorsEnabled[guildName] == nil then
            GR.SV.guildProcessorsEnabled[guildName] = true
        end
    end

    local optionsData = {
        {
            type = "header",
            name = "Sale Notifications",
        },
        {
            type = "checkbox",
            name = "Show Center-Screen Notification",
            tooltip = "Displays a pop‑up announcement in the center of the screen and plays a sound when you sell an item.",
            getFunc = function() return GR.SV.enableSaleNotifications end,
            setFunc = function(value) GR.SV.enableSaleNotifications = value end,
            default = true,
        },
        {
            type = "checkbox",
            name = "Show Chat Notification",
            tooltip = "Prints a message in the chat window when you sell an item.",
            getFunc = function() return GR.SV.enableSaleNotificationsChat end,
            setFunc = function(value) GR.SV.enableSaleNotificationsChat = value end,
            default = true,
        },
        {
            type = "header",
            name = "Trading Guilds Are...",
        },
    }

    for i = 1, GetNumGuilds() do
        local guildId = GetGuildId(i)
        local guildName = GetGuildName(guildId)
        if guildName and guildName ~= "" then
            table.insert(optionsData, {
                type = "checkbox",
                name = guildName,
                tooltip = "Enable or disable GoldRush's trader history processor for " .. guildName .. ".",
                getFunc = function() return GR.SV.guildProcessorsEnabled[guildName] end,
                setFunc = function(value) GR.SV.guildProcessorsEnabled[guildName] = value end,
                default = true,
                requiresReload = true,
            })
        end
    end

    local panelData = {
        type = "panel",
        name = "Gold Rush",
        displayName = "|cFFD700Gold Rush|r",
        author = "|cFFD700@Atharti|r",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    LAM:RegisterAddonPanel("GoldRushPanel", panelData)
    LAM:RegisterOptionControls("GoldRushPanel", optionsData)
end