local SH = SalesHistory

function SH.ShowResultsDialog()
    -- Show the XML-defined SalesHistoryWindow
    if SalesHistoryWindow then
        -- position to the right of the screen
        SalesHistoryWindow:ClearAnchors()
        SalesHistoryWindow:SetAnchor(CENTER, GuiRoot, RIGHT, -(SalesHistoryWindow:GetWidth() / 2 + 50), 0)
        SalesHistoryWindow:SetHidden(false)
        SH.RefreshSalesWindow()
        -- Ensure the XML Close button hides the window
        if SH.HookSalesWindowControls then SH.HookSalesWindowControls() end
    else
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, "[SalesHistory] SalesHistoryWindow not found.")
    end
end


-- Refresh the XML-defined SalesHistoryWindow (if present)
function SH.RefreshSalesWindow()
    if not SalesHistoryWindow then return end
    
    local results = SH.GetFilteredResults() or {}
    local per = SH.filterState.itemsPerPage or 12
    local page = SH.filterState.currentPage or 1
    local total = #results
    
    -- Calculate total gold from filtered results
    local totalGold = 0
    for _, sale in ipairs(results) do
        totalGold = totalGold + (sale.price or 0)
    end
    
    d("[SalesHistory] RefreshSalesWindow called")
    d(string.format("[SalesHistory] Total results: %d", total))
    
    if total == 0 then
        local status = SalesHistoryWindow:GetNamedChild("StatusLabel")
        if status then
            status:SetText("No results yet. Select a guild and press Scan.")
        end
        -- Clear all item labels
        for i = 1, 12 do
            local nameLabel = SalesHistoryWindow:GetNamedChild("Item" .. i .. "Name")
            local goldLabel = SalesHistoryWindow:GetNamedChild("Item" .. i .. "Gold")
            local dateLabel = SalesHistoryWindow:GetNamedChild("Item" .. i .. "Date")
            if nameLabel then nameLabel:SetText("") end
            if goldLabel then goldLabel:SetText("") end
            if dateLabel then dateLabel:SetText("") end
        end
        return
    end
    
    local pages = math.max(1, math.ceil(total / per))
    if page > pages then
        page = pages
        SH.filterState.currentPage = page
    end
    
    local startIdx = (page - 1) * per + 1
    local endIdx = math.min(startIdx + per - 1, total)
    
    -- Update each of the 12 hardcoded rows (3 labels per row)
    for i = 1, 12 do
        local nameLabel = SalesHistoryWindow:GetNamedChild("Item" .. i .. "Name")
        local goldLabel = SalesHistoryWindow:GetNamedChild("Item" .. i .. "Gold")
        local dateLabel = SalesHistoryWindow:GetNamedChild("Item" .. i .. "Date")
        
        if nameLabel and goldLabel and dateLabel then
            local resultIdx = startIdx + i - 1
            if resultIdx <= endIdx then
                local sale = results[resultIdx]
                local name = (sale.itemName or "Unknown"):gsub("%^n", ""):gsub("%^p", "")
                if sale.quantity and sale.quantity > 1 then
                    name = name .. " x" .. sale.quantity
                end
                nameLabel:SetText(name)
                goldLabel:SetText(tostring(sale.price) .. "g")
                dateLabel:SetText(sale.dateStr or "?")
                nameLabel:SetHidden(false)
                goldLabel:SetHidden(false)
                dateLabel:SetHidden(false)
            else
                nameLabel:SetText("")
                goldLabel:SetText("")
                dateLabel:SetText("")
                nameLabel:SetHidden(true)
                goldLabel:SetHidden(true)
                dateLabel:SetHidden(true)
            end
        end
    end
    
    -- Update status
    local status = SalesHistoryWindow:GetNamedChild("StatusLabel")
    if status then
        -- Format gold with commas
        local goldFormatted = tostring(totalGold):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
        status:SetText(string.format("Found %d sales | Page %d/%d | Total Gold: %sg", total, page, pages, goldFormatted))
    end
    
    d(string.format("[SalesHistory] Displayed %d-%d of %d results", startIdx, endIdx, total))
end

-- Wire up XML window controls (safe): Close button hides SalesHistoryWindow
function SH.HookSalesWindowControls()
    if not SalesHistoryWindow then return end
    local closeBtn = SalesHistoryWindow:GetNamedChild("CloseBtn")
    if not closeBtn then return end
    if type(closeBtn.SetHandler) == "function" then
        closeBtn:SetHandler("OnClicked", function()
            SalesHistoryWindow:SetHidden(true)
        end)
    end
end
