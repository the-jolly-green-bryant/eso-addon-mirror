-- Settings menu.
function GuildRankColors.LoadSettings()
    local panelData = {
        type = "panel",
        name = GuildRankColors.menuName,
        displayName = GuildRankColors.Colorize(GuildRankColors.menuName),
        author = GuildRankColors.Colorize(GuildRankColors.author, "F3F0A5"),
        slashCommand = "/guildrankcolors",
        -- registerForRefresh = true,
        -- registerForDefaults = true,
    }

    LibAddonMenu2:RegisterAddonPanel(GuildRankColors.menuName, panelData)

    local optionsTable = {}

    table.insert(
        optionsTable,
        {
            type = "checkbox",
            name = "Account Wide",
            tooltip = "Use the same settings throughout the entire account - instead of per character.",
            getFunc = function()
                return GuildRankColors.savedVars.accountWide
            end,
            setFunc = function(v)
                GuildRankColors.characterSavedVars.accountWide = v
                GuildRankColors.accountSavedVars.accountWide = v
            end,
            width = "full", --or "half",
            requiresReload = true,
        }
    )

    table.insert(optionsTable, {
        type = "description",
        text = "Use the Black color to disable any rank color.\n" ..
        "Your own rank in every guild is tooltipped in |cFFDD55Gold|r.",
        width = "full",
    })

    GuildRankColors.playerRanks = {
        [1] = nil,
        [2] = nil,
        [3] = nil,
        [4] = nil,
        [5] = nil,
    }

    for i=1, GetNumGuilds() do
        guildId = GetGuildId(i)
        guildName = GetGuildName(guildId)

        guildMemberIndex = GetGuildMemberIndexFromDisplayName(guildId, GetUnitDisplayName('player'))
        _, _, rankIndex, _, _ = GetGuildMemberInfo(guildId, guildMemberIndex)

        table.insert(optionsTable, {
            type = "header",
            name = ZO_HIGHLIGHT_TEXT:Colorize(guildName),
            width = "full",
        })

        for j=1, GetNumGuildRanks(guildId) do
            guildRankName = GetGuildRankCustomName(guildId, j)
            guildRankLargeIcon = GetGuildRankLargeIcon(GetGuildRankIconIndex(guildId, j))

            if rankIndex == j then
                GuildRankColors.playerRanks[i] = j
                guildRankName = "|cFFDD55" .. guildRankName .. "|r"
            else
                guildRankName = "|cFFFFFF" .. guildRankName .. "|r"
            end

            table.insert(optionsTable, {
                type = "texture",
                image = guildRankLargeIcon,
                imageWidth = 64,
                imageHeight = 64,
                tooltip = guildRankName,
                width = "half",
            })

            table.insert(optionsTable, {
                type = "colorpicker",
                -- name = guildRankName,
                tooltip = "Pick a chat color for the " .. guildRankName .. " guild rank.",
                getFunc = function()
                    local color = GuildRankColors.savedVars.guildRankColors[i][j]

                    -- Default black means no color change.
                    if not color then return 0, 0, 0 end

                    return color.r, color.g, color.b
                end,
                setFunc = function(r, g, b)
                    if r == 0 and g == 0 and b == 0 then
                        -- Black is disabled.
                        GuildRankColors.savedVars.guildRankColors[i][j] = nil
                    else
                        GuildRankColors.savedVars.guildRankColors[i][j] = ZO_ColorDef:New(r, g, b)
                    end
                end,
                width = "half",
            })
        end
    end

    LibAddonMenu2:RegisterOptionControls(GuildRankColors.menuName, optionsTable)
end