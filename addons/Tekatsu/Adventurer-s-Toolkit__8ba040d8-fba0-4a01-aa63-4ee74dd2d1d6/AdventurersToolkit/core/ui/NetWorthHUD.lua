-- ============================================
-- MINI NET WORTH HUD
-- ============================================

function NWT.CreateUI()
    if NWT.ui.window then return end
    
    local window = WINDOW_MANAGER:CreateTopLevelWindow("NetWorthTracker_Window")
    window:SetDimensions(300, 455)
    window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 20, 120)
    window:SetHidden(true)
    window:SetMouseEnabled(false)
    window:SetMovable(false)
    
    local bg = WINDOW_MANAGER:CreateControl("$(parent)BG", window, CT_BACKDROP)
    bg:SetAnchorFill(window)
    bg:SetCenterColor(0, 0, 0, 0.7)
    bg:SetEdgeColor(0.3, 0.3, 0.3, 0.8)
    bg:SetEdgeTexture("", 1, 1, 1, 0)
    
    local title = WINDOW_MANAGER:CreateControl("$(parent)Title", window, CT_LABEL)
    title:SetDimensions(260, 25)
    title:SetAnchor(TOP, window, TOP, 0, 8)
    title:SetFont(NWT.GetFont("large"))
    title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    title:SetColor(1, 0.84, 0, 1)
    title:SetText("NET WORTH")
    
    local total = WINDOW_MANAGER:CreateControl("$(parent)Total", window, CT_LABEL)
    total:SetDimensions(260, 28)
    total:SetAnchor(TOP, title, BOTTOM, 0, 2)
    total:SetFont(NWT.GetFont("large"))
    total:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    total:SetColor(1, 1, 1, 1)
    total:SetText("0 gold")
    NWT.ui.total = total
    
    local goldLine = WINDOW_MANAGER:CreateControl("$(parent)Gold", window, CT_LABEL)
    goldLine:SetDimensions(260, 20)
    goldLine:SetAnchor(TOPLEFT, window, TOPLEFT, 15, 65)
    goldLine:SetFont(NWT.GetFont("normal"))
    goldLine:SetColor(1, 0.84, 0, 1)
    goldLine:SetText("Gold: 0")
    NWT.ui.gold = goldLine
    
    local invLine = WINDOW_MANAGER:CreateControl("$(parent)Inv", window, CT_LABEL)
    invLine:SetDimensions(260, 20)
    invLine:SetAnchor(TOPLEFT, window, TOPLEFT, 15, 87)
    invLine:SetFont(NWT.GetFont("normal"))
    invLine:SetColor(0.7, 0.9, 1, 1)
    invLine:SetText("Inventory: 0")
    NWT.ui.inventory = invLine
    
    local bankLine = WINDOW_MANAGER:CreateControl("$(parent)Bank", window, CT_LABEL)
    bankLine:SetDimensions(260, 20)
    bankLine:SetAnchor(TOPLEFT, window, TOPLEFT, 15, 109)
    bankLine:SetFont(NWT.GetFont("normal"))
    bankLine:SetColor(0.7, 1, 0.7, 1)
    bankLine:SetText("Bank: 0")
    NWT.ui.bank = bankLine
    
    local craftLine = WINDOW_MANAGER:CreateControl("$(parent)Craft", window, CT_LABEL)
    craftLine:SetDimensions(280, 20)
    craftLine:SetAnchor(TOPLEFT, window, TOPLEFT, 15, 131)
    craftLine:SetFont(NWT.GetFont("normal"))
    craftLine:SetColor(1, 0.7, 1, 1)
    craftLine:SetText("Craft Bag: 0")
    NWT.ui.craftBag = craftLine
    
    local vaultLine = WINDOW_MANAGER:CreateControl("$(parent)Vault", window, CT_LABEL)
    vaultLine:SetDimensions(280, 20)
    vaultLine:SetAnchor(TOPLEFT, window, TOPLEFT, 15, 153)
    vaultLine:SetFont(NWT.GetFont("normal"))
    vaultLine:SetColor(0.9, 0.7, 0.5, 1)
    vaultLine:SetText("Furniture Vault: 0")
    NWT.ui.furnitureVault = vaultLine
    
    local myHouseLine = WINDOW_MANAGER:CreateControl("$(parent)MyHouse", window, CT_LABEL)
    myHouseLine:SetDimensions(280, 20)
    myHouseLine:SetAnchor(TOPLEFT, window, TOPLEFT, 15, 175)
    myHouseLine:SetFont(NWT.GetFont("normal"))
    myHouseLine:SetColor(0.5, 0.9, 0.7, 1)
    myHouseLine:SetText("My Housing: --")
    NWT.ui.myHousing = myHouseLine
    
    local visitingLine = WINDOW_MANAGER:CreateControl("$(parent)Visiting", window, CT_LABEL)
    visitingLine:SetDimensions(280, 20)
    visitingLine:SetAnchor(TOPLEFT, window, TOPLEFT, 15, 197)
    visitingLine:SetFont(NWT.GetFont("normal"))
    visitingLine:SetColor(0.7, 0.7, 0.9, 1)
    visitingLine:SetText("Current House: --")
    NWT.ui.visitingHouse = visitingLine
    
    local guildBanksLine = WINDOW_MANAGER:CreateControl("$(parent)GuildBanks", window, CT_LABEL)
    guildBanksLine:SetDimensions(280, 20)
    guildBanksLine:SetAnchor(TOPLEFT, window, TOPLEFT, 15, 219)
    guildBanksLine:SetFont(NWT.GetFont("normal"))
    guildBanksLine:SetColor(0.9, 0.6, 0.9, 1)
    guildBanksLine:SetText("Guild Banks: --")
    NWT.ui.guildBanks = guildBanksLine
    
    local crownsLine = WINDOW_MANAGER:CreateControl("$(parent)Crowns", window, CT_LABEL)
    crownsLine:SetDimensions(280, 20)
    crownsLine:SetAnchor(TOPLEFT, window, TOPLEFT, 15, 241)
    crownsLine:SetFont(NWT.GetFont("normal"))
    crownsLine:SetColor(0.2, 0.8, 1, 1)
    crownsLine:SetText("Crowns: 0")
    NWT.ui.crowns = crownsLine
    
    local gemsLine = WINDOW_MANAGER:CreateControl("$(parent)Gems", window, CT_LABEL)
    gemsLine:SetDimensions(280, 20)
    gemsLine:SetAnchor(TOPLEFT, window, TOPLEFT, 15, 263)
    gemsLine:SetFont(NWT.GetFont("normal"))
    gemsLine:SetColor(1, 0.2, 0.6, 1)
    gemsLine:SetText("Crown Gems: 0")
    NWT.ui.crownGems = gemsLine
    
    local crownItemsLine = WINDOW_MANAGER:CreateControl("$(parent)CrownItems", window, CT_LABEL)
    crownItemsLine:SetDimensions(280, 20)
    crownItemsLine:SetAnchor(TOPLEFT, window, TOPLEFT, 15, 285)
    crownItemsLine:SetFont(NWT.GetFont("normal"))
    crownItemsLine:SetColor(0.6, 0.8, 1, 1)
    crownItemsLine:SetText("Crown Items: 0 store, 0 crate")
    NWT.ui.crownItems = crownItemsLine
    
    local top5Header = WINDOW_MANAGER:CreateControl("$(parent)TopHeader", window, CT_LABEL)
    top5Header:SetDimensions(280, 20)
    top5Header:SetAnchor(TOPLEFT, window, TOPLEFT, 15, 312)
    top5Header:SetFont(NWT.GetFont("normal"))
    top5Header:SetColor(1, 0.84, 0, 1)
    top5Header:SetText("TOP 5 ITEMS:")
    
    NWT.ui.topItemsLines = {}
    for i = 1, 5 do
        local line = WINDOW_MANAGER:CreateControl("$(parent)TopItem" .. i, window, CT_LABEL)
        line:SetDimensions(280, 20)
        line:SetAnchor(TOPLEFT, window, TOPLEFT, 15, 312 + (i * 22))
        line:SetFont(NWT.GetFont("normal"))
        line:SetColor(0.9, 0.9, 0.9, 1)
        line:SetText("")
        NWT.ui.topItemsLines[i] = line
    end
    
    NWT.ui.window = window
end

function NWT.UpdateUI()
    if not NWT.ui or not NWT.ui.window then return end
    local nw = NWT.netWorth
    local format = NWT.FormatGold
    
    NWT.ui.total:SetText(format(nw.total) .. " gold")
    NWT.ui.gold:SetText("Gold: " .. format(nw.gold))
    NWT.ui.inventory:SetText("Inventory: " .. format(nw.inventory))
    NWT.ui.bank:SetText("Bank: " .. format(nw.bank))
    NWT.ui.craftBag:SetText("Craft Bag: " .. format(nw.craftBag))
    
    local vaultSlot = GetNextFurnitureVaultSlotId(nil)
    local vSuffix = (nw.furnitureVault > 0 and not vaultSlot) and " (saved)" or ""
    NWT.ui.furnitureVault:SetText("Furniture Vault: " .. format(nw.furnitureVault) .. vSuffix)
    
    local hId = GetCurrentZoneHouseId()
    local hSuffix = (hId == 0 or not IsOwnerOfCurrentHouse()) and " (saved)" or ""
    NWT.ui.myHousing:SetText(nw.myHousing > 0 and ("My Housing: " .. format(nw.myHousing) .. hSuffix) or "My Housing: --")
    local visitVal = nw.visitingHouseWithCrowns or nw.visitingHouse or 0
    local visitText = "Current House: "
    if visitVal > 0 then
        visitText = visitText .. format(visitVal)
        local parts = {}
        if (nw.visitingHouseCrowns or 0) > 0 then table.insert(parts, nw.visitingHouseCrowns .. " crowns") end
        if (nw.visitingHouseWV or 0) > 0 then table.insert(parts, nw.visitingHouseWV .. " WV") end
        if #parts > 0 then visitText = visitText .. " (" .. table.concat(parts, ", ") .. ")" end
    else
        visitText = visitText .. "--"
    end
    NWT.ui.visitingHouse:SetText(visitText)
    NWT.ui.guildBanks:SetText(nw.guildBanks > 0 and ("Guild Banks: " .. format(nw.guildBanks) .. " (saved)") or "Guild Banks: --")
    
    local cText = "Crowns: " .. format(nw.crowns)
    if nw.crownsAsGold > 0 then cText = cText .. " (=" .. format(nw.crownsAsGold) .. "g)" end
    NWT.ui.crowns:SetText(cText)
    NWT.ui.crownGems:SetText("Crown Gems: " .. format(nw.crownGems))
    NWT.ui.crownItems:SetText("Crown Items: " .. nw.crownStoreItems .. " store, " .. nw.crownCrateItems .. " crate")
    
    for i = 1, 5 do
        if NWT.ui.topItemsLines and NWT.ui.topItemsLines[i] then
            local item = NWT.topItems[i]
            if item then
                local name = item.name or "Unknown"
                if string.len(name) > 20 then name = string.sub(name, 1, 18) .. ".." end
                NWT.ui.topItemsLines[i]:SetText(i .. ". " .. name .. " x" .. item.count .. " = " .. format(item.value))
            else NWT.ui.topItemsLines[i]:SetText("") end
        end
    end
end

function NWT.ShowUI()
    if NWT.ui and NWT.ui.window then
        NWT.CalculateNetWorth()
        NWT.UpdateUI()
        NWT.ui.window:SetHidden(false)
        NWT.uiVisible = true
    end
end

function NWT.HideUI()
    if NWT.ui and NWT.ui.window then
        NWT.ui.window:SetHidden(true)
        NWT.uiVisible = false
    end
end

function NWT.ToggleUI()
    if NWT.ui and NWT.ui.window then
        if NWT.ui.window:IsHidden() then NWT.ShowUI() else NWT.HideUI() end
    end
end

function NWT.OnUpdate()
    if not NWT.initialized or not NWT.ui or not NWT.ui.window then return end
    if IsGameCameraUIModeActive() then NWT.ui.window:SetHidden(true)
    elseif NWT.uiVisible then NWT.ui.window:SetHidden(false) end
end
