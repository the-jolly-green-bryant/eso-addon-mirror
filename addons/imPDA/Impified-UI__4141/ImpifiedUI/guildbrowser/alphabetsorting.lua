local feature = {}

function feature.Setup(addon)
    if not addon.savedVariables.guildBrowser.alphabeticalSorting then return end

    ZO_PostHook(ZO_GuildBrowser_GuildList_Shared, 'PopulateList', function(self)
        local scrollData = ZO_ScrollList_GetDataList(self.list)

        table.sort(scrollData, function(a, b) return a.data.guildName < b.data.guildName end)

        ZO_ScrollList_Commit(self.list)
    end)
end

function feature.GetSettingsControl(addon)
    return {
        {
            type = 'checkbox',
            name = 'Alphabetical search results (Guild Finder)',
            getFunc = function() return addon.savedVariables.guildBrowser.alphabeticalSorting end,
            setFunc = function(value) addon.savedVariables.guildBrowser.alphabeticalSorting = value end,
            requiresReload = true,
        },
    }
end

assert(ImpifiedUI, 'ImpifiedUI not found')
ImpifiedUI:AddFeature(feature)
