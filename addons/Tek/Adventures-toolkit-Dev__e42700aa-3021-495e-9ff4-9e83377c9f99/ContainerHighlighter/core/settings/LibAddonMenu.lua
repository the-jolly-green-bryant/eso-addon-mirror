-- ============================================
-- SETTINGS MODULE (LibAddonMenu)
-- ============================================

function NWT.CreateSettingsMenu()
    local LAM = LibAddonMenu2
    if not LAM then return end
    
    local numGuilds = GetNumGuilds()
    local addonVersion = "13.3.2"
    
    -- Shared colorblind options
    local colorblindChoices = { "normal", "protanopia", "deuteranopia", "tritanopia" }
    local colorblindNames = {
        ["normal"] = "Normal Vision",
        ["protanopia"] = "Protanopia (Red-Blind)",
        ["deuteranopia"] = "Deuteranopia (Green-Blind)",
        ["tritanopia"] = "Tritanopia (Blue-Blind)",
    }
    
    -- ========== PANEL: GENERAL SETTINGS ==========
    local generalPanelData = {
        type = "panel",
        name = "TM - General",
        displayName = "|cFFAAAAAdventurer's Toolkit|r - General",
        author = "Tek",
        version = addonVersion,
        slashCommand = "/tmsettings",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    
    local generalOptionsTable = {
        { type = "description", text = "|cFFD700Adventurer's Toolkit|r v" .. addonVersion .. " by Tek" },
        { type = "description", text = "|cFFFFAA/nw|r Net Worth  |  |cFFFFAA/gst|r Guild Sales  |  |cFFFFAA/pb|r Plan Browser\n|cFFFFAA/house|r Housing  |  |cFFFFAA/wishlist|r Wishlist  |  |cFFFFAA/fish|r Fishing" },
        {
            type = "dropdown",
            name = "Colorblind Mode",
            tooltip = "Adjust colors across ALL addon features for color vision deficiency.",
            choices = colorblindChoices,
            choicesValues = colorblindChoices,
            getFunc = function() return NWT.savedVars.planBrowser.colorblindMode or "normal" end,
            setFunc = function(value) 
                NWT.savedVars.planBrowser.colorblindMode = value
            end,
            default = "normal",
            scrollable = true,
        },
        { type = "header", name = "Feature Toggles" },
        {
            type = "checkbox",
            name = "Guild Bookkeeper",
            tooltip = "Enable/disable the Guild Bookkeeper feature for tracking dues and raffle deposits. Requires UI reload.",
            getFunc = function() return NWT.savedVars.features.bookkeeper ~= false end,
            setFunc = function(value)
                NWT.savedVars.features.bookkeeper = value
            end,
            default = true,
        },
        {
            type = "checkbox",
            name = "Loot Radar",
            tooltip = "Enable/disable the 3D container marker feature. Requires UI reload.",
            getFunc = function() return NWT.savedVars.features.lootRadar ~= false end,
            setFunc = function(value)
                NWT.savedVars.features.lootRadar = value
            end,
            default = true,
        },
        {
            type = "checkbox",
            name = "Plan Browser",
            tooltip = "Enable/disable the Furnishing Plan Browser. Requires UI reload.",
            getFunc = function() return NWT.savedVars.features.planBrowser ~= false end,
            setFunc = function(value)
                NWT.savedVars.features.planBrowser = value
            end,
            default = true,
        },
        {
            type = "checkbox",
            name = "Housing Dashboard",
            tooltip = "Enable/disable the Housing Stats dashboard. Requires UI reload.",
            getFunc = function() return NWT.savedVars.features.housingDashboard ~= false end,
            setFunc = function(value)
                NWT.savedVars.features.housingDashboard = value
            end,
            default = true,
        },
        {
            type = "checkbox",
            name = "Fishing Tracker",
            tooltip = "Enable/disable the Fishing Stats tracker. Requires UI reload.",
            getFunc = function() return NWT.savedVars.features.fishingTracker ~= false end,
            setFunc = function(value)
                NWT.savedVars.features.fishingTracker = value
            end,
            default = true,
        },
        {
            type = "checkbox",
            name = "PVP Dashboard",
            tooltip = "Enable/disable the PVP Dashboard (AP tracking, K/D analytics, Tel Var, Keeps). Requires UI reload.",
            getFunc = function() return NWT.savedVars.features.pvpDashboard ~= false end,
            setFunc = function(value)
                NWT.savedVars.features.pvpDashboard = value
            end,
            default = true,
        },
    }
    
    LAM:RegisterAddonPanel("TM_General_Settings", generalPanelData)
    LAM:RegisterOptionControls("TM_General_Settings", generalOptionsTable)
    
    -- ========== PANEL: NET WORTH ==========
    local nwPanelData = {
        type = "panel",
        name = "TM - Net Worth",
        displayName = "|cFFAAAAAdventurer's Toolkit|r - Net Worth",
        author = "Tek",
        version = addonVersion,
        slashCommand = "/nwsettings",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    
    local nwOptionsTable = {
        { type = "button", name = "Show Net Worth", tooltip = "Display your net worth in chat (/nw)", func = function() NWT.ShowNetWorthInChat() end },
        { type = "header", name = "Include in Calculation" },
        { type = "checkbox", name = "Include Bank", tooltip = "Include items in your bank when calculating net worth", getFunc = function() return NWT.savedVars.includeBank end, setFunc = function(value) NWT.savedVars.includeBank = value end, default = true },
        { type = "checkbox", name = "Include Craft Bag", tooltip = "Include items in your craft bag when calculating net worth", getFunc = function() return NWT.savedVars.includeCraftBag end, setFunc = function(value) NWT.savedVars.includeCraftBag = value end, default = true },
        { type = "checkbox", name = "Include Furniture Vault", tooltip = "Include items in your furniture vault when calculating net worth", getFunc = function() return NWT.savedVars.includeFurnitureVault end, setFunc = function(value) NWT.savedVars.includeFurnitureVault = value end, default = true },
        { type = "checkbox", name = "Include My Housing", tooltip = "Include your own house furniture value (saves and persists)", getFunc = function() return NWT.savedVars.includeMyHousing end, setFunc = function(value) NWT.savedVars.includeMyHousing = value end, default = true },
        { type = "header", name = "Crown Conversion" },
        { type = "checkbox", name = "Include Crowns as Gold", tooltip = "Convert your crown balance to gold value and include in net worth", getFunc = function() return NWT.savedVars.includeCrownsAsGold end, setFunc = function(value) NWT.savedVars.includeCrownsAsGold = value end, default = true },
        { type = "slider", name = "Crown to Gold Rate", tooltip = "How much gold you sell each crown for (e.g. 100 means 1 crown = 100 gold)", min = 0, max = 2000, step = 100, getFunc = function() return NWT.savedVars.crownToGoldRate end, setFunc = function(value) NWT.savedVars.crownToGoldRate = value end, default = 100 },
        { type = "header", name = "Writ Voucher Conversion" },
        { type = "slider", name = "Writ Voucher to Gold Rate", tooltip = "Gold value per writ voucher (e.g. 1000 means 1 WV = 1000 gold). Used for furniture vault crafting stations.", min = 0, max = 2000, step = 100, getFunc = function() return NWT.savedVars.writVoucherToGoldRate or 1000 end, setFunc = function(value) NWT.savedVars.writVoucherToGoldRate = value end, default = 1000 },
        { type = "header", name = "Guild Banks" },
        { type = "description", text = "Open each guild bank once to scan. Enable below to include in net worth." },
    }
    
    for i = 1, numGuilds do
        local guildId = GetGuildId(i)
        local guildName = GetGuildName(guildId) or ("Guild " .. i)
        local savedValue = NWT.savedVars.guildBankValues and NWT.savedVars.guildBankValues[guildId]
        local valueText = savedValue and (" (" .. NWT.FormatGold(savedValue) .. "g)") or " (not scanned)"
        table.insert(nwOptionsTable, {
            type = "checkbox",
            name = guildName .. valueText,
            tooltip = "Include " .. guildName .. " guild bank in net worth",
            getFunc = function() return NWT.savedVars.enabledGuildBanks[guildId] end,
            setFunc = function(value) NWT.savedVars.enabledGuildBanks[guildId] = value end,
            default = false,
        })
    end
    
    -- Crown Data section
    table.insert(nwOptionsTable, { type = "header", name = "Crown Data Capture" })
    table.insert(nwOptionsTable, { 
        type = "description", 
        text = "Capture crown furniture prices from the Crown Store. Open furniture browser, then use these buttons." 
    })
    table.insert(nwOptionsTable, { 
        type = "button", 
        name = "Scan Current List", 
        tooltip = "Scan all items in the current furniture browser list", 
        func = function() 
            local count = NWT.ScanAllBrowserItems and NWT.ScanAllBrowserItems() or 0
NWT.Debug(string.format("|c00FF00[Crown Scan]|r Captured %d items", count))
        end 
    })
    table.insert(nwOptionsTable, { 
        type = "button", 
        name = "Show Captured", 
        tooltip = "Display all captured crown items in chat", 
        func = function() 
            if NWT.ShowCapturedCrownData then NWT.ShowCapturedCrownData() end
        end 
    })
    table.insert(nwOptionsTable, { 
        type = "button", 
        name = "Submit Crown Data", 
        tooltip = "Submit captured crown data to the server", 
        func = function() 
            if NWT.SubmitCrownData then NWT.SubmitCrownData() end
        end 
    })
    table.insert(nwOptionsTable, { 
        type = "button", 
        name = "Clear Captured", 
        tooltip = "Clear all captured crown data", 
        func = function() 
            if NWT.ClearCapturedCrownData then NWT.ClearCapturedCrownData() end
        end,
        isDangerous = true,
    })
    
    LAM:RegisterAddonPanel("TM_NetWorth_Settings", nwPanelData)
    LAM:RegisterOptionControls("TM_NetWorth_Settings", nwOptionsTable)
    
    -- ========== PANEL: GUILD SALES TRACKER ==========
    local gstPanelData = {
        type = "panel",
        name = "TM - Guild Sales",
        displayName = "|cFFAAAAAdventurer's Toolkit|r - Guild Sales",
        author = "Tek",
        version = addonVersion,
        slashCommand = "/gstsettings",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    
    local gstOptionsTable = {
        { type = "description", text = "Manage your guild trader analytics and scan settings." },
        { type = "header", name = "Data Collection" },
        { type = "button", name = "Clear All Data", tooltip = "Clear all saved sales data (cannot be undone)", func = function() NWT.ClearGuildSalesData() end, isDangerous = true },
    }
    
    for i = 1, numGuilds do
        local guildId = GetGuildId(i)
        local guildName = GetGuildName(guildId) or ("Guild " .. i)
        table.insert(gstOptionsTable, {
            type = "button",
            name = "Scan: " .. guildName,
            tooltip = "Scan " .. guildName .. " trader history",
            func = function() NWT.ScanGuild(guildId) end,
        })
    end
    
    LAM:RegisterAddonPanel("TM_GuildSales_Settings", gstPanelData)
    LAM:RegisterOptionControls("TM_GuildSales_Settings", gstOptionsTable)
    
    -- ========== PANEL: HOUSING ==========
    local housingPanelData = {
        type = "panel",
        name = "TM - Housing",
        displayName = "|cFFAAAAAdventurer's Toolkit|r - Housing",
        author = "Tek",
        version = addonVersion,
        slashCommand = "/housingsettings",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    
    local housingOptionsTable = {
        { type = "description", text = "|cFFD700Housing Dashboard:|r Real-time limits, house statistics, and furniture searching." },
        { type = "header", name = "HUD Settings" },
        { type = "checkbox", name = "Enable Housing HUD", tooltip = "Show item limits when inside your owned houses.", getFunc = function() return NWT.savedVars.housingHudEnabled end, setFunc = function(value) NWT.savedVars.housingHudEnabled = value NWT.UpdateHousingLimitUI() end, default = true },
        { type = "header", name = "Furniture Finder" },
        { type = "button", name = "Clear Furniture Cache", tooltip = "Clear all cached furniture data", func = function() NWT.savedVars.furnitureCache = {} NWT.savedVars.furnitureVaultCache = {}  end, isDangerous = true },
    }
    
    LAM:RegisterAddonPanel("TM_Housing_Settings", housingPanelData)
    LAM:RegisterOptionControls("TM_Housing_Settings", housingOptionsTable)
end
