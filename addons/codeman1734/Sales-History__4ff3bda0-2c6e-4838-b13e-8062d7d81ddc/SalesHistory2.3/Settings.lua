local SH = SalesHistory

function SH.SetupSettings()
    local LAM = LibAddonMenu2
    if not LAM then
        CHAT_SYSTEM:AddMessage("[SalesHistory] LibAddonMenu-2.0 not found.")
        return
    end

    local function GetGuildChoices()
        local choices = {}
        for i = 1, GetNumGuilds() do
            local guildId   = GetGuildId(i)
            local guildName = GetGuildName(guildId)
            table.insert(choices, guildName)
        end
        if #choices == 0 then
            table.insert(choices, "No guilds found")
        end
        return choices
    end

    local panelData = {
        type               = "panel",
        name               = "Sales History",
        displayName        = "Sales History",
        author             = "Hearthcode",
        version            = SH.version,
        slashCommand       = "/saleshistory",
        registerForRefresh = true,
    }
    local optionsData = {
        {
            type       = "dropdown",
            name       = "Select Guild",
            tooltip    = "Choose which guild's trading house to scan.",
            choices    = GetGuildChoices(),
            getFunc    = function()
                local choices = GetGuildChoices()
                return choices[SH.savedVars.selectedGuildIndex] or choices[1]
            end,
            setFunc    = function(value)
                local choices = GetGuildChoices()
                for i, name in ipairs(choices) do
                    if name == value then
                        SH.savedVars.selectedGuildIndex = i
                        break
                    end
                end
            end,
            scrollable = true,
        },
        {
            type    = "button",
            name    = "Scan Sales History",
            tooltip = "Scan your guild's sales history via LibHistoire.",
            func    = function() SH.StartScan() end,
        },
        {
            type    = "button",
            name    = "View Results Dialog",
            tooltip = "Open a popup window with your filtered sales results",
            func    = function() SH.ShowResultsDialog() end,
        },
        {
            type    = "button",
            name    = "Close Results Window",
            tooltip = "Hide the results overlay if it's visible",
            func    = function()
                if SalesHistoryWindow then SalesHistoryWindow:SetHidden(true) end
            end,
        },
        {
            type    = "button",
            name    = "Reset to Defaults",
            tooltip = "Reset all filters and settings to default values",
            func    = function()
                SH.filterState.equipment = true
                SH.filterState.materials = true
                SH.filterState.furnishings = true
                SH.filterState.motifsRecipes = true
                SH.filterState.consumables = true
                SH.filterState.masterWrits = true
                SH.filterState.companionGear = true
                SH.filterState.miscellaneous = true
                SH.filterState.textSearch = ""
                SH.filterState.sortBy = "date"
                SH.filterState.currentPage = 1
                if SH.RefreshSalesWindow then SH.RefreshSalesWindow() end
            end,
        },
    }

    -- Calculate max pages based on current results
    local currentResults = SH.GetFilteredResults()
    local maxPages = math.max(1, math.ceil(#currentResults / SH.filterState.itemsPerPage))

    -- Add page slider
    table.insert(optionsData, {
        type    = "slider",
        name    = "Page",
        tooltip = "Navigate through pages of results",
        min     = 1,
        max     = maxPages,
        step    = 1,
        getFunc = function() return SH.filterState.currentPage end,
        setFunc = function(value)
            SH.filterState.currentPage = value
            if SH.RefreshSalesWindow then SH.RefreshSalesWindow() end
        end,
    })

    table.insert(optionsData, {
        type     = "editbox",
        name     = "Text Search",
        tooltip  = "Filter by item name (leave blank to show all)",
        getFunc  = function() return SH.filterState.textSearch end,
        setFunc  = function(value)
            SH.filterState.textSearch = value
            SH.filterState.currentPage = 1
            if SH.RefreshSalesWindow then SH.RefreshSalesWindow() end
        end,
        isMultiline = false,
    })

    table.insert(optionsData, {
        type    = "dropdown",
        name    = "Sort By",
        tooltip = "Choose how to sort results",
        choices = {"Date", "Price", "Unit Price"},
        getFunc = function()
            if SH.filterState.sortBy == "price" then return "Price"
            elseif SH.filterState.sortBy == "unitPrice" then return "Unit Price"
            else return "Date" end
        end,
        setFunc = function(value)
            if value == "Price" then SH.filterState.sortBy = "price"
            elseif value == "Unit Price" then SH.filterState.sortBy = "unitPrice"
            else SH.filterState.sortBy = "date" end
            SH.filterState.currentPage = 1
            if SH.RefreshSalesWindow then SH.RefreshSalesWindow() end
        end,
    })

    table.insert(optionsData, {
        type    = "button",
        name    = "Disable All Filters",
        tooltip = "Turn off all category filters",
        func    = function()
            SH.filterState.equipment = false
            SH.filterState.materials = false
            SH.filterState.furnishings = false
            SH.filterState.motifsRecipes = false
            SH.filterState.consumables = false
            SH.filterState.masterWrits = false
            SH.filterState.companionGear = false
            SH.filterState.miscellaneous = false
            SH.filterState.currentPage = 1
            if SH.RefreshSalesWindow then SH.RefreshSalesWindow() end
        end,
    })

    table.insert(optionsData, {
        type = "header",
        name = "Category Filters",
    })

    local function addCategoryCheckbox(key, label, tooltip)
        table.insert(optionsData, {
            type    = "checkbox",
            name    = label,
            tooltip = tooltip or "",
            getFunc = function() return SH.filterState[key] end,
            setFunc = function(value)
                SH.filterState[key] = value
                SH.filterState.currentPage = 1
                if SH.RefreshSalesWindow then SH.RefreshSalesWindow() end
            end,
        })
    end

    addCategoryCheckbox("equipment", "Equipment", "Show weapons and armor (excluding companion gear)")
    addCategoryCheckbox("materials", "Materials", "Show crafting materials, trait items, style materials, etc.")
    addCategoryCheckbox("furnishings", "Furnishings", "Show housing furnishings")
    addCategoryCheckbox("motifsRecipes", "Motifs & Recipes", "Show motifs, style pages, and recipes")
    addCategoryCheckbox("consumables", "Consumables", "Show food, drinks, potions, poisons, soul gems")
    addCategoryCheckbox("masterWrits", "Master Writs", "Show master writs")
    addCategoryCheckbox("companionGear", "Companion Gear", "Show companion weapons and armor")
    addCategoryCheckbox("miscellaneous", "Miscellaneous", "Show everything else not in above categories")

    -- Right-side results custom control (scrollable)
    table.insert(optionsData, {
        type = "custom",
        reference = "SalesHistoryResultsDisplay",
        width = "full",
        refreshFunc = function(control)
            if not control.scroll then
                local scroll = WINDOW_MANAGER:CreateControl(control:GetName() .. "Scroll", control, CT_SCROLL)
                scroll:SetAnchorFill(control)
                scroll:SetDimensions(control:GetWidth(), 400)

                local scrollChild = WINDOW_MANAGER:CreateControl(control:GetName() .. "ScrollChild", scroll, CT_LABEL)
                scrollChild:SetAnchor(TOPLEFT)
                scrollChild:SetFont("ZoFontGame")
                scrollChild:SetColor(1, 1, 1, 1)
                scrollChild:SetVerticalAlignment(TEXT_ALIGN_TOP)
                scrollChild:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
                scrollChild:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)

                scroll:SetScrollChild(scrollChild)
                control.scroll = scroll
                control.scrollChild = scrollChild
            end

            local results = SH.GetFilteredResults()
            if not results or #results == 0 then
                control.scrollChild:SetText("No results yet. Select a guild and press Scan.")
                return
            end

            local startIdx = (SH.filterState.currentPage - 1) * SH.filterState.itemsPerPage + 1
            local endIdx = math.min(startIdx + SH.filterState.itemsPerPage - 1, #results)
            local lines = {}
            for i = startIdx, endIdx do
                local sale = results[i]
                local name = sale.itemName or "Unknown"
                if sale.quantity and sale.quantity > 1 then
                    name = name .. " x" .. sale.quantity
                end
                table.insert(lines, string.format("%s | %sg | %s",
                    name, tostring(sale.price), sale.dateStr or "?"))
            end
            control.scrollChild:SetText(table.concat(lines, "\n"))
        end,
    })

    LAM:RegisterAddonPanel(SH.name .. "Panel", panelData)
    LAM:RegisterOptionControls(SH.name .. "Panel", optionsData)

    -- Position the XML-defined `SalesHistoryWindow` to the right when the LAM panel opens
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(panel)
        if panel:GetName() ~= (SH.name .. "Panel") then return end
        if not SalesHistoryWindow then return end
        SalesHistoryWindow:ClearAnchors()
        SalesHistoryWindow:SetAnchor(CENTER, GuiRoot, RIGHT, -(SalesHistoryWindow:GetWidth() / 2 + 50), 0)
        SalesHistoryWindow:SetHidden(false)
    end)

    CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", function(panel)
        if panel:GetName() ~= (SH.name .. "Panel") then return end
        if not SalesHistoryWindow then return end
        SalesHistoryWindow:SetHidden(true)
    end)
end
