GuildSalesJournal = GuildSalesJournal or {}
GuildSalesJournal.Settings = GuildSalesJournal.Settings or {}
local GSJ = GuildSalesJournal
local Settings = GSJ.Settings

local function AddSignature(menu)
    menu:AddSetting({
        type = LibHarvensAddonSettings.ST_LABEL,
        label = "|cFFD700Built on tea, toast and ADHD. Tested live on PS5. - SugaComa|r",
    })
end

function Settings:Initialize()
    if not LibHarvensAddonSettings then
        GSJ:Message("LibHarvensAddonSettings not found. Settings menu unavailable.")
        return
    end

    local LHAS = LibHarvensAddonSettings
    local menu = LHAS:AddAddon("Personal Finance Journal", {
        allowDefaults = true,
        allowRefresh = true,
    })
    if not menu then
        GSJ:Message("Could not create the LHAS settings menu.")
        return
    end
    self.menu = menu

    menu:AddSetting({ type = LHAS.ST_SECTION, label = "Journal Refresh" })

    menu:AddSetting({
        type = LHAS.ST_DROPDOWN,
        label = "Refresh Mode",
        tooltip = "Automatic refreshes cached Guild History when the journal opens. Manual uses Square inside the journal.",
        items = {
            { name = "Automatic on Journal Open", data = "AUTO" },
            { name = "Manual - Square to Refresh", data = "MANUAL" },
        },
        getFunction = function()
            return GSJ.settings.refreshMode == "MANUAL"
                and "Manual - Square to Refresh"
                or "Automatic on Journal Open"
        end,
        setFunction = function(_, _, item)
            if item and item.data then
                GSJ.settings.refreshMode = item.data
                if GSJ.Journal and GSJ.Journal.Refresh then GSJ.Journal:Refresh() end
            end
        end,
    })

    menu:AddSetting({ type = LHAS.ST_SECTION, label = "Journal Storage" })

    menu:AddSetting({
        type = LHAS.ST_DROPDOWN,
        label = "History Size",
        tooltip = "Sets the tested record ceiling and the automatic oldest-first purge batch.",
        items = {
            { name = "Compact - 1,000 / remove 250", data = "compact" },
            { name = "Balanced - 2,000 / remove 500", data = "balanced" },
            { name = "Extended - 5,000 / remove 1,000", data = "extended" },
        },
        getFunction = function()
            local key = GSJ.settings.storageProfile
            if key == "compact" then return "Compact - 1,000 / remove 250" end
            if key == "extended" then return "Extended - 5,000 / remove 1,000" end
            return "Balanced - 2,000 / remove 500"
        end,
        setFunction = function(_, _, item)
            if item and item.data then
                GSJ:ApplyStorageProfile(item.data)
                if GSJ.Journal and GSJ.Journal.Refresh then GSJ.Journal:Refresh() end
            end
        end,
    })

    menu:AddSetting({
        type = LHAS.ST_LABEL,
        label = function()
            return string.format(
                "Stored records: %d / %d | Purge batch: %d",
                tonumber(GSJ.sales.count) or 0,
                tonumber(GSJ.settings.maxEntries) or 0,
                tonumber(GSJ.settings.purgeBatch) or 0
            )
        end,
    })

    menu:AddSetting({ type = LHAS.ST_SECTION, label = "Maintenance" })

    menu:AddSetting({
        type = LHAS.ST_BUTTON,
        label = "Refresh Cached Guild History",
        buttonText = "Refresh",
        clickHandler = function()
            GSJ:RefreshTraderHistory(false)
            if menu.RefreshSettings then menu:RefreshSettings() end
        end,
    })

    menu:AddSetting({
        type = LHAS.ST_BUTTON,
        label = "Clear Sales History",
        tooltip = "Deletes journal records but keeps addon settings.",
        buttonText = "Clear",
        clickHandler = function()
            GSJ:ClearSales()
            if menu.RefreshSettings then menu:RefreshSettings() end
        end,
    })

    menu:AddSetting({
        type = LHAS.ST_BUTTON,
        label = "Reset Settings",
        tooltip = "Returns refresh and storage settings to defaults. Sales history is retained.",
        buttonText = "Reset",
        clickHandler = function()
            GSJ:ResetSettings()
            if menu.RefreshSettings then menu:RefreshSettings() end
        end,
    })

    AddSignature(menu)
end
