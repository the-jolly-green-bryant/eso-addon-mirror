local ItemShare = {}
ItemShare.name = "ItemShare"
local CURRENT_CHARACTER_NAME = zo_strformat("<<t:1>>", GetUnitName("player")) or "Unknown"
local CURRENT_DISPLAY_NAME = GetDisplayName() or "@Unknown"

ItemShare.savedVars = nil

local SHARE_TEXTURE_PATH = "ItemShare/media/itemshare_share2.dds"
local SHARE_LIST_ICON = string.format("|t16:16:%s|t", SHARE_TEXTURE_PATH)

local defaults = {
    sharedItems = {},
    debugEnabled = false,
    guildBankSharingEnabled = false,
    spreadsheetUrl = "",
    listWindowState = {
        left = nil,
        top = nil,
        isOpen = false,
    }
}

local dmsg
local RemoveItemFromShareByKey
local SaveSharedEntry
local SaveSharedEntryFromSavedEntry
local RefreshShareListWindow
local RefreshShareListWindowIfVisible
local CanModifyGuildBankShare



ItemShare.ui = {
    listWindow = nil,
    listScroll = nil,
    listContent = nil,
    reloadButton = nil,
    sheetValueLabel = nil,
    sheetSendButton = nil,
    rowControls = {}
}

local function SaveListWindowState()
    if not ItemShare.savedVars or not ItemShare.savedVars.listWindowState then
        return
    end

    local window = ItemShare.ui and ItemShare.ui.listWindow
    if not window then
        return
    end

    local left = window.GetLeft and window:GetLeft() or nil
    local top = window.GetTop and window:GetTop() or nil

    ItemShare.savedVars.listWindowState.left = left
    ItemShare.savedVars.listWindowState.top = top
    ItemShare.savedVars.listWindowState.isOpen = not window:IsHidden()
end

local function ApplySavedListWindowPosition(window)
    if not ItemShare.savedVars or not ItemShare.savedVars.listWindowState then
        return
    end

    local state = ItemShare.savedVars.listWindowState
    if state.left == nil or state.top == nil then
        return
    end

    window:ClearAnchors()
    window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, state.left, state.top)
end

local function GetSortedSharedEntries()
    local entries = {}

    for itemKey, entry in pairs(ItemShare.savedVars.sharedItems or {}) do
        local copy = {}
        for k, v in pairs(entry) do
            copy[k] = v
        end
        copy.itemKey = itemKey
        entries[#entries + 1] = copy
    end

    table.sort(entries, function(a, b)
        local aName = tostring(a.itemName or a.itemLink or "")
        local bName = tostring(b.itemName or b.itemLink or "")
        local aSortName = zo_strlower(aName)
        local bSortName = zo_strlower(bName)
        if aSortName ~= bSortName then
            return aSortName < bSortName
        end
        if aName ~= bName then
            return aName < bName
        end

        local aLocation = tostring(a.sharedFrom or "")
        local bLocation = tostring(b.sharedFrom or "")
        if aLocation ~= bLocation then
            return aLocation < bLocation
        end

        return tostring(a.itemLink or "") < tostring(b.itemLink or "")
    end)

    return entries
end


local ITEM_SHARE_CHAT_LINK_TYPE = "itemshare"
local ITEM_SHARE_CHAT_LINK_TOKEN = "sheet"

local function GetStoredSpreadsheetUrl()
    if not ItemShare.savedVars then
        return ""
    end

    local url = tostring(ItemShare.savedVars.spreadsheetUrl or "")
    url = zo_strtrim(url)
    if url == "" then
        return ""
    end

    return url
end

local function SetStoredSpreadsheetUrl(url)
    if not ItemShare.savedVars then
        return
    end

    ItemShare.savedVars.spreadsheetUrl = zo_strtrim(tostring(url or ""))
end

local function BuildSpreadsheetChatLink()
    return GetStoredSpreadsheetUrl()
end

local function BuildSpreadsheetChatMessage()
    local url = GetStoredSpreadsheetUrl()
    if url == "" then
        return nil
    end

    return string.format("ItemShare Sheet: %s", url)
end

local function OpenItemShareWindow()
    RefreshShareListWindow()
end

local function QueueSpreadsheetChatMessage()
    local message = BuildSpreadsheetChatMessage()
    if not message then
        d("[ItemShare] No spreadsheet link is set. Use /itemshare sheet <url>")
        return
    end

    if StartChatInput then
        StartChatInput(message)
    else
        d(message)
    end
end

local function QueueSpreadsheetUrlToChat()
    local url = GetStoredSpreadsheetUrl()
    if url == "" then
        d("[ItemShare] No spreadsheet link is set. Use /itemshare sheet <url>")
        return
    end

    if StartChatInput then
        StartChatInput(url)
    else
        d(url)
    end
end

local function RefreshSpreadsheetControls()
    local label = ItemShare.ui and ItemShare.ui.sheetValueLabel
    local button = ItemShare.ui and ItemShare.ui.sheetSendButton
    local url = GetStoredSpreadsheetUrl()

    if label then
        if url ~= "" then
            label:SetText(url)
            label:SetColor(0.82, 0.76, 0.55, 1)
        else
            label:SetText("No spreadsheet link set. Use /itemshare sheet <url>")
            label:SetColor(0.65, 0.65, 0.65, 1)
        end
    end

    if button then
        if button.SetEnabled then
            button:SetEnabled(url ~= "")
        end
        button:SetAlpha(url ~= "" and 1 or 0.45)
    end
end

local function InstallItemShareLinkHandler()
    return
end

local function CreateShareListWindow()
    if ItemShare.ui.listWindow then
        return ItemShare.ui.listWindow
    end

    local wm = WINDOW_MANAGER
    local window = wm:CreateTopLevelWindow("ItemShareShareListWindow")
    window:SetDimensions(720, 520)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    window:SetMovable(true)
    window:SetMouseEnabled(true)
    window:SetClampedToScreen(true)
    window:SetHidden(true)
    window:SetHandler("OnMoveStop", function()
        SaveListWindowState()
    end)
    window:SetHandler("OnHide", function()
        SaveListWindowState()
    end)
    window:SetHandler("OnShow", function()
        SaveListWindowState()
    end)

    ApplySavedListWindowPosition(window)

    local backdrop = wm:CreateControl(nil, window, CT_BACKDROP)
    backdrop:SetAnchorFill(window)
    backdrop:SetCenterColor(0.05, 0.05, 0.05, 0.95)
    backdrop:SetEdgeColor(0.7, 0.7, 0.7, 1)
    backdrop:SetEdgeTexture(nil, 1, 1, 2, 0)

    local title = wm:CreateControl(nil, window, CT_LABEL)
    title:SetFont("ZoFontWinH1")
    title:SetColor(1, 1, 1, 1)
    title:SetText("Shared Items")
    title:SetAnchor(TOPLEFT, window, TOPLEFT, 18, 14)

    local closeButton = wm:CreateControl(nil, window, CT_BUTTON)
    closeButton:SetDimensions(32, 32)
    closeButton:SetAnchor(TOPRIGHT, window, TOPRIGHT, -8, 8)
    closeButton:SetNormalTexture("/esoui/art/buttons/decline_up.dds")
    closeButton:SetPressedTexture("/esoui/art/buttons/decline_down.dds")
    closeButton:SetMouseOverTexture("/esoui/art/buttons/decline_over.dds")
    closeButton:SetHandler("OnClicked", function()
        window:SetHidden(true)
        SaveListWindowState()
    end)

    local sheetHeader = wm:CreateControl(nil, window, CT_LABEL)
    sheetHeader:SetFont("ZoFontGameSmall")
    sheetHeader:SetColor(1, 1, 1, 1)
    sheetHeader:SetText("Spreadsheet")
    sheetHeader:SetAnchor(TOPLEFT, window, TOPLEFT, 18, 44)

    local sheetValueLabel = wm:CreateControl(nil, window, CT_LABEL)
    sheetValueLabel:SetFont("ZoFontGame")
    sheetValueLabel:SetAnchor(TOPLEFT, window, TOPLEFT, 18, 62)
    sheetValueLabel:SetAnchor(TOPRIGHT, window, TOPRIGHT, -150, 62)
    sheetValueLabel:SetHeight(18)
    sheetValueLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    if sheetValueLabel.SetMaxLineCount then
        sheetValueLabel:SetMaxLineCount(1)
    end
    sheetValueLabel:SetMouseEnabled(true)
    sheetValueLabel:SetHandler("OnMouseUp", function(_, button, upInside)
        if not upInside then
            return
        end

        local leftButton = MOUSE_BUTTON_INDEX_LEFT or 1
        if button == leftButton then
            QueueSpreadsheetUrlToChat()
        end
    end)

    local sheetSendButton = wm:CreateControl(nil, window, CT_BUTTON)
    sheetSendButton:SetDimensions(120, 28)
    sheetSendButton:SetAnchor(TOPRIGHT, window, TOPRIGHT, -18, 56)
    sheetSendButton:SetFont("ZoFontGameSmall")
    sheetSendButton:SetText("Send URL")
    sheetSendButton:SetNormalTexture("/esoui/art/buttons/accept_up.dds")
    sheetSendButton:SetPressedTexture("/esoui/art/buttons/accept_down.dds")
    sheetSendButton:SetMouseOverTexture("/esoui/art/buttons/accept_over.dds")
    sheetSendButton:SetDisabledTexture("/esoui/art/buttons/accept_disabled.dds")
    sheetSendButton:SetClickSound(SOUNDS.DIALOG_ACCEPT)
    sheetSendButton:SetHandler("OnClicked", function()
        QueueSpreadsheetChatMessage()
    end)

    local divider = wm:CreateControl(nil, window, CT_BACKDROP)
    divider:SetAnchor(TOPLEFT, window, TOPLEFT, 12, 90)
    divider:SetAnchor(TOPRIGHT, window, TOPRIGHT, -12, 90)
    divider:SetHeight(1)
    divider:SetCenterColor(0.6, 0.6, 0.6, 1)
    divider:SetEdgeColor(0.6, 0.6, 0.6, 1)

    local shareHeader = wm:CreateControl(nil, window, CT_LABEL)
    shareHeader:SetFont("ZoFontGameSmall")
    shareHeader:SetColor(1, 1, 1, 1)
    shareHeader:SetText("")
    shareHeader:SetAnchor(TOPLEFT, window, TOPLEFT, 20, 96)
    shareHeader:SetDimensions(20, 20)

    local itemHeader = wm:CreateControl(nil, window, CT_LABEL)
    itemHeader:SetFont("ZoFontGameSmall")
    itemHeader:SetColor(1, 1, 1, 1)
    itemHeader:SetText("Item")
    itemHeader:SetAnchor(TOPLEFT, window, TOPLEFT, 44, 96)

    local countHeader = wm:CreateControl(nil, window, CT_LABEL)
    countHeader:SetFont("ZoFontGameSmall")
    countHeader:SetColor(1, 1, 1, 1)
    countHeader:SetText("Count")
    countHeader:SetAnchor(TOPLEFT, window, TOPLEFT, 390, 96)
    countHeader:SetWidth(50)
    countHeader:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)

    local locationHeader = wm:CreateControl(nil, window, CT_LABEL)
    locationHeader:SetFont("ZoFontGameSmall")
    locationHeader:SetColor(1, 1, 1, 1)
    locationHeader:SetText("Location")
    locationHeader:SetAnchor(TOPLEFT, window, TOPLEFT, 460, 96)

    local instructionLabel = wm:CreateControl(nil, window, CT_LABEL)
    instructionLabel:SetFont("ZoFontGameSmall")
    instructionLabel:SetColor(0.85, 0.85, 0.85, 1)
    instructionLabel:SetText("Right Click a row to Enable / Disable Sharing from this window")
    instructionLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    instructionLabel:SetAnchor(BOTTOMLEFT, window, BOTTOMLEFT, 16, -48)
    instructionLabel:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -16, -48)
    instructionLabel:SetHeight(20)

    local reloadButton = wm:CreateControl(nil, window, CT_BUTTON)
    reloadButton:SetDimensions(200, 36)
    reloadButton:SetAnchor(BOTTOM, window, BOTTOM, 0, -12)
    reloadButton:SetFont("ZoFontGame")
    reloadButton:SetText("Reload UI")
    reloadButton:SetNormalTexture("/esoui/art/buttons/accept_up.dds")
    reloadButton:SetPressedTexture("/esoui/art/buttons/accept_down.dds")
    reloadButton:SetMouseOverTexture("/esoui/art/buttons/accept_over.dds")
    reloadButton:SetDisabledTexture("/esoui/art/buttons/accept_disabled.dds")
    reloadButton:SetClickSound(SOUNDS.DIALOG_ACCEPT)
    reloadButton:SetHandler("OnClicked", function()
        SyncSharedItemsWithInventory()
        ReloadUI()
    end)

    local scroll = wm:CreateControlFromVirtual(nil, window, "ZO_ScrollContainer")
    scroll:SetAnchor(TOPLEFT, window, TOPLEFT, 16, 116)
    scroll:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -16, -72)
    scroll:SetMouseEnabled(true)

    local content = scroll:GetNamedChild("ScrollChild")
    content:ClearAnchors()
    content:SetAnchor(TOPLEFT, scroll, TOPLEFT, 0, 0)
    content:SetDimensions(1, 1)

    window:SetHandler("OnKeyUp", function(_, key, ctrl, alt, command)
        if ctrl or alt or command then
            return
        end

        if key == KEY_R or key == string.byte("R") or key == string.byte("r") then
            ReloadUI()
        end
    end)

    ItemShare.ui.listWindow = window
    ItemShare.ui.listScroll = scroll
    ItemShare.ui.listContent = content
    ItemShare.ui.reloadButton = reloadButton
    ItemShare.ui.sheetValueLabel = sheetValueLabel
    ItemShare.ui.sheetSendButton = sheetSendButton
    RefreshSpreadsheetControls()
    return window
end

local function GetOrCreateShareListRow(index)
    local existing = ItemShare.ui.rowControls[index]
    if existing then
        return existing
    end

    local wm = WINDOW_MANAGER
    local row = wm:CreateControl("ItemShareShareListRow" .. tostring(index), ItemShare.ui.listContent, CT_CONTROL)
    row:SetAnchor(TOPLEFT, ItemShare.ui.listContent, TOPLEFT, 0, (index - 1) * 24)
    row:SetDimensions(660, 22)
    row:SetMouseEnabled(true)

    local rowBackdrop = wm:CreateControl(nil, row, CT_BACKDROP)
    rowBackdrop:SetAnchorFill(row)
    rowBackdrop:SetCenterColor(0, 0, 0, 0)
    rowBackdrop:SetEdgeColor(0, 0, 0, 0)
    rowBackdrop:SetMouseEnabled(false)

    local statusIcon = wm:CreateControl(nil, row, CT_TEXTURE)
    statusIcon:SetAnchor(LEFT, row, LEFT, 2, 0)
    statusIcon:SetDimensions(16, 16)
    statusIcon:SetDrawLayer(DL_OVERLAY)
    statusIcon:SetDrawTier(DT_HIGH)
    statusIcon:SetTexture(SHARE_TEXTURE_PATH)
    statusIcon:SetMouseEnabled(true)

    local itemLabel = wm:CreateControl(nil, row, CT_LABEL)
    itemLabel:SetAnchor(TOPLEFT, row, TOPLEFT, 26, 0)
    itemLabel:SetDimensions(334, 22)
    itemLabel:SetFont("ZoFontGameSmall")
    itemLabel:SetColor(1, 1, 1, 1)
    itemLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    if itemLabel.SetMaxLineCount then
        itemLabel:SetMaxLineCount(1)
    end
    itemLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    itemLabel:SetMouseEnabled(true)

    local countLabel = wm:CreateControl(nil, row, CT_LABEL)
    countLabel:SetAnchor(TOPLEFT, row, TOPLEFT, 370, 0)
    countLabel:SetDimensions(50, 22)
    countLabel:SetFont("ZoFontGameSmall")
    countLabel:SetColor(1, 1, 1, 1)
    countLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    if countLabel.SetMaxLineCount then
        countLabel:SetMaxLineCount(1)
    end
    countLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    countLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)

    local locationLabel = wm:CreateControl(nil, row, CT_LABEL)
    locationLabel:SetAnchor(TOPLEFT, row, TOPLEFT, 440, 0)
    locationLabel:SetAnchor(TOPRIGHT, row, TOPRIGHT, 0, 0)
    locationLabel:SetFont("ZoFontGameSmall")
    locationLabel:SetColor(1, 1, 1, 1)
    locationLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    if locationLabel.SetMaxLineCount then
        locationLabel:SetMaxLineCount(1)
    end
    locationLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    local function IsGuildBankEntryDisabled()
        local isGuildBankEntry = row.entryData and tostring(row.entryData.locationKey or ""):find("guildbank", 1, true) == 1
        if not isGuildBankEntry then
            return false
        end

        local guildIdForEntry = nil
        if row.entryData then
            guildIdForEntry = tonumber(string.match(tostring(row.entryData.locationKey or ""), "^guildbank:(%d+)$"))
        end

        return not CanModifyGuildBankShare(BAG_GUILDBANK, row.entryData and row.entryData.slotIndex, guildIdForEntry)
    end

    local function RefreshRowAppearance()
        local isDisabled = IsGuildBankEntryDisabled()
        local isActive = row.isMouseOver and true or false

        if isActive then
            rowBackdrop:SetCenterColor(0.85, 0.72, 0.35, 0.14)
        elseif (tonumber(row.rowIndex or 0) % 2) == 0 then
            rowBackdrop:SetCenterColor(1, 1, 1, 0.05)
        else
            rowBackdrop:SetCenterColor(0, 0, 0, 0)
        end

        if isDisabled then
            itemLabel:SetColor(0.55, 0.55, 0.55, 1)
            countLabel:SetColor(0.55, 0.55, 0.55, 1)
            locationLabel:SetColor(0.55, 0.55, 0.55, 1)
            statusIcon:SetAlpha(0.35)
        else
            itemLabel:SetColor(1, 1, 1, 1)
            countLabel:SetColor(1, 1, 1, 1)
            locationLabel:SetColor(1, 1, 1, 1)
            statusIcon:SetAlpha(1)
        end
    end

    local function updateRowSharedVisuals()
        local isShared = row.entryKey and ItemShare.savedVars and ItemShare.savedVars.sharedItems and ItemShare.savedVars.sharedItems[row.entryKey] ~= nil
        row.isShared = isShared and true or false
        statusIcon:SetHidden(not row.isShared)
        RefreshRowAppearance()
    end

    local function handleRowMouseEnter()
        if ItemShare.ui and ItemShare.ui.hoveredRow and ItemShare.ui.hoveredRow ~= row then
            ItemShare.ui.hoveredRow.isMouseOver = false
            if ItemShare.ui.hoveredRow.RefreshAppearance then
                ItemShare.ui.hoveredRow:RefreshAppearance()
            end
        end

        row.isMouseOver = true
        if ItemShare.ui then
            ItemShare.ui.hoveredRow = row
        end
        RefreshRowAppearance()
    end

    local function toggleRowSharedState()
        local isGuildBankEntry = row.entryData and tostring(row.entryData.locationKey or ""):find("guildbank", 1, true) == 1
        local guildIdForEntry = nil
        if isGuildBankEntry and row.entryData then
            guildIdForEntry = tonumber(string.match(tostring(row.entryData.locationKey or ""), "^guildbank:(%d+)$"))
        end
        local canModifyGuildBankEntry = not isGuildBankEntry or CanModifyGuildBankShare(BAG_GUILDBANK, row.entryData and row.entryData.slotIndex, guildIdForEntry)

        if not canModifyGuildBankEntry then
            return
        end

        if row.isShared then
            local currentEntry = row.entryKey and ItemShare.savedVars.sharedItems[row.entryKey] or row.entryData
            RemoveItemFromShareByKey(row.entryKey, currentEntry, false)
            row.entryData = currentEntry or row.entryData
            row.isShared = false
            updateRowSharedVisuals()
        elseif row.entryData then
            local savedEntry = SaveSharedEntryFromSavedEntry(row.entryData, false)
            if savedEntry then
                row.entryData = savedEntry
                row.entryKey = tostring(savedEntry.itemKey or row.entryKey or "")
                row.isShared = true
                dmsg(string.format(
                    "Added shared item %s from %s (stack size: %d)",
                    tostring(savedEntry.itemName or savedEntry.itemLink or "Unknown Item"),
                    tostring(savedEntry.sharedFrom or "-"),
                    tonumber(savedEntry.count or 0) or 0
                ))
                updateRowSharedVisuals()
            else
                dmsg("Could not re-add item from shared list window.")
            end
        end
    end

    local function handleRowRightClick(button)
        local rightButton = MOUSE_BUTTON_INDEX_RIGHT or 2
        if button ~= rightButton then
            return false
        end

        toggleRowSharedState()
        return true
    end


    statusIcon:SetHandler("OnMouseEnter", function(self)
        handleRowMouseEnter()
        InitializeTooltip(InformationTooltip, self, TOPLEFT, 0, 0)
        SetTooltipText(InformationTooltip, "|c00FF00Shared Item|r\nThis item is available to others.")
    end)

    statusIcon:SetHandler("OnMouseExit", function()
        ClearTooltip(InformationTooltip)
    end)

    itemLabel:SetHandler("OnMouseEnter", function(self)
        handleRowMouseEnter()
    end)

    itemLabel:SetHandler("OnMouseExit", function()
    end)

    itemLabel:SetHandler("OnMouseUp", function(self, button, upInside)
        if not upInside then
            return
        end

        local didToggle = handleRowRightClick(button)
        if didToggle then
            return
        end

        local leftButton = MOUSE_BUTTON_INDEX_LEFT or 1
        if button == leftButton and row.itemLink and row.itemLink ~= "" then
            ZO_LinkHandler_OnLinkClicked(row.itemLink, button, self)
        end
    end)

    statusIcon:SetHandler("OnMouseUp", function(self, button, upInside)
        if not upInside then
            return
        end

        handleRowRightClick(button)
    end)

    row:SetHandler("OnMouseEnter", function()
        handleRowMouseEnter()
    end)

    row:SetHandler("OnMouseExit", function()
        row.isMouseOver = false
        if ItemShare.ui and ItemShare.ui.hoveredRow == row then
            ItemShare.ui.hoveredRow = nil
        end
        RefreshRowAppearance()
    end)

    row:SetHandler("OnMouseUp", function(self, button, upInside)
        if not upInside then
            return
        end

        handleRowRightClick(button)
    end)

    row.itemLabel = itemLabel
    row.countLabel = countLabel
    row.locationLabel = locationLabel
    row.statusIcon = statusIcon
    row.rowBackdrop = rowBackdrop
    row.UpdateSharedVisuals = updateRowSharedVisuals
    row.RefreshAppearance = RefreshRowAppearance
    ItemShare.ui.rowControls[index] = row
    return row
end

RefreshShareListWindow = function()
    local window = CreateShareListWindow()
    local entries = GetSortedSharedEntries()
    local rowHeight = 24
    local contentWidth = math.max((ItemShare.ui.listScroll and ItemShare.ui.listScroll:GetWidth()) or 660, 660)

    for index, entry in ipairs(entries) do
        local row = GetOrCreateShareListRow(index)
        row:SetAnchor(TOPLEFT, ItemShare.ui.listContent, TOPLEFT, 0, (index - 1) * rowHeight)
        row:SetDimensions(contentWidth - 8, rowHeight)
        row:SetHidden(false)
        row.rowIndex = index
        row.itemLink = tostring(entry.itemLink or "")
        row.entryKey = tostring(entry.itemKey or BuildSharedItemKey(entry.itemLink, entry.locationKey))
        row.entryData = entry
        local displayText = row.itemLink ~= "" and row.itemLink or tostring(entry.itemName or "")
        local traitText = tostring(entry.trait or "")
        if traitText ~= "" then
            displayText = string.format("%s (%s)", displayText, traitText)
        end
        row.itemLabel:SetText(displayText)
        row.countLabel:SetText(tostring(tonumber(entry.count or 0) or 0))
        row.locationLabel:SetText(tostring(entry.sharedFrom or "-"))
        row.isShared = true
        row.statusIcon:SetHidden(false)
        if row.RefreshAppearance then
            row:RefreshAppearance()
        end
    end

    for index = #entries + 1, #ItemShare.ui.rowControls do
        local row = ItemShare.ui.rowControls[index]
        if row then
            row:SetHidden(true)
        end
    end

    local contentHeight = math.max(#entries * rowHeight, 1)
    ItemShare.ui.listContent:SetDimensions(contentWidth, contentHeight)
    window:SetHidden(false)
    SaveListWindowState()
end

RefreshShareListWindowIfVisible = function()
    local window = ItemShare.ui and ItemShare.ui.listWindow
    if window and not window:IsHidden() then
        RefreshShareListWindow()
    end
end

dmsg = function(text)
    if not ItemShare.savedVars or not ItemShare.savedVars.debugEnabled then
        return
    end
    d(string.format("[ItemShare] %s", tostring(text)))
end

local function ConfirmReloadUI()
    local dialogName = "ITEM_SHARE_CONFIRM_RELOAD_UI"

    if not ItemShare.reloadDialogRegistered then
        ZO_Dialogs_RegisterCustomDialog(dialogName, {
            title = {
                text = "Reload UI",
            },
            mainText = {
                text = "Would you like to reload the UI?",
            },
            buttons = {
                [1] = {
                    text = SI_DIALOG_ACCEPT,
                    callback = function()
                        SyncSharedItemsWithInventory()
                        dmsg("Reloading UI.")
                        ReloadUI()
                    end,
                },
                [2] = {
                    text = SI_DIALOG_CANCEL,
                },
            },
        })
        ItemShare.reloadDialogRegistered = true
    end

    ZO_Dialogs_ShowDialog(dialogName)
end

local function GetNormalizedText(value)
    if not value or value == "" then
        return nil
    end
    return zo_strformat("<<t:1>>", value)
end

local function GetNormalizedItemName(bagId, slotIndex)
    return GetNormalizedText(GetItemName(bagId, slotIndex))
end

local function GetNormalizedItemLink(bagId, slotIndex)
    local itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT)
    if not itemLink or itemLink == "" then
        return nil
    end
    return itemLink
end

local function GetCurrentAccountName()
    return GetDisplayName() or "@Unknown"
end

local function GetCurrentCharacterName()
    return GetNormalizedText(GetUnitName("player")) or "Unknown"
end

local function GetCurrentDisplayName()
    return CURRENT_DISPLAY_NAME
end


local function GetSelectedGuildBankLocationInfo()
    local guildId = 0
    if GetSelectedGuildBankId then
        guildId = tonumber(GetSelectedGuildBankId()) or 0
    end

    local guildName = ""
    if guildId > 0 and GetGuildName then
        guildName = GetNormalizedText(GetGuildName(guildId)) or ""
    end

    if guildId > 0 and guildName ~= "" then
        return string.format("guildbank:%d", guildId), string.format("Guild Bank (%s)", guildName)
    elseif guildId > 0 then
        return string.format("guildbank:%d", guildId), "Guild Bank"
    end

    return "guildbank", "Guild Bank"
end

CanModifyGuildBankShare = function(bagId, slotIndex, guildId)
    if not (BAG_GUILDBANK and bagId == BAG_GUILDBANK) then
        return true
    end

    if not (ItemShare.savedVars and ItemShare.savedVars.guildBankSharingEnabled) then
        return false
    end

    if type(CanUseBank) == "function" and GUILD_PERMISSION_BANK_WITHDRAW ~= nil then
        return CanUseBank(GUILD_PERMISSION_BANK_WITHDRAW)
    end

    local selectedGuildId = tonumber(guildId)
    if (not selectedGuildId or selectedGuildId <= 0) and type(GetSelectedGuildBankId) == "function" then
        selectedGuildId = tonumber(GetSelectedGuildBankId()) or 0
    end

    if selectedGuildId > 0
        and type(DoesPlayerHaveGuildPermission) == "function"
        and GUILD_PERMISSION_BANK_WITHDRAW ~= nil then
        return DoesPlayerHaveGuildPermission(selectedGuildId, GUILD_PERMISSION_BANK_WITHDRAW) == true
    end

    return false
end


local function GetDisplaySharedItemName(itemName)
    return string.format("%s %s", SHARE_LIST_ICON, tostring(itemName or ""))
end

local function GetBagLocationInfo(bagId)
    if bagId == BAG_BACKPACK then
        local characterName = GetCurrentCharacterName()
        local locationLabel = string.format("Inventory (%s)", characterName)
        local locationKey = string.format("inventory:%s", zo_strlower(characterName))
        return locationKey, locationLabel
    elseif bagId == BAG_BANK or (BAG_SUBSCRIBER_BANK and bagId == BAG_SUBSCRIBER_BANK) then
        return "bank", "Bank"
    elseif BAG_GUILDBANK and bagId == BAG_GUILDBANK then
        return GetSelectedGuildBankLocationInfo()
    elseif BAG_VIRTUAL and bagId == BAG_VIRTUAL then
        return "craftbag", "Craft Bag"
    elseif (BAG_HOUSE_BANK_ONE and bagId == BAG_HOUSE_BANK_ONE)
        or (BAG_HOUSE_BANK_TWO and bagId == BAG_HOUSE_BANK_TWO)
        or (BAG_HOUSE_BANK_THREE and bagId == BAG_HOUSE_BANK_THREE)
        or (BAG_HOUSE_BANK_FOUR and bagId == BAG_HOUSE_BANK_FOUR)
        or (BAG_HOUSE_BANK_FIVE and bagId == BAG_HOUSE_BANK_FIVE)
        or (BAG_HOUSE_BANK_SIX and bagId == BAG_HOUSE_BANK_SIX)
        or (BAG_HOUSE_BANK_SEVEN and bagId == BAG_HOUSE_BANK_SEVEN)
        or (BAG_HOUSE_BANK_EIGHT and bagId == BAG_HOUSE_BANK_EIGHT)
        or (BAG_HOUSE_BANK_NINE and bagId == BAG_HOUSE_BANK_NINE)
        or (BAG_HOUSE_BANK_TEN and bagId == BAG_HOUSE_BANK_TEN) then
        return "housestorage", "House Storage"
    elseif BAG_FURNITURE_VAULT and bagId == BAG_FURNITURE_VAULT then
        return "furnishingvault", "Furnishing Vault"
    end

    return string.format("bag:%s", tostring(bagId)), string.format("Bag %s", tostring(bagId))
end

local function GetBagLocationLabel(bagId)
    local _, locationLabel = GetBagLocationInfo(bagId)
    return locationLabel
end

local function BuildSharedItemKey(itemLink, locationKey)
    return string.format("%s||%s", tostring(itemLink or ""), tostring(locationKey or ""))
end

local function BuildLocationKeyFromSharedFrom(sharedFrom)
    local value = zo_strlower(tostring(sharedFrom or ""))
    if value == "" then
        return ""
    end
    if value == "bank" then
        return "bank"
    elseif value == "craft bag" then
        return "craftbag"
    elseif value == "house storage" then
        return "housestorage"
    elseif value == "furnishing vault" then
        return "furnishingvault"
    elseif string.find(value, "inventory %(", 1, true) == 1 then
        local characterName = string.match(tostring(sharedFrom or ""), "^Inventory %((.*)%)$")
        if characterName and characterName ~= "" then
            return string.format("inventory:%s", zo_strlower(characterName))
        end
        return "inventory"
    elseif string.find(value, "guild bank %(", 1, true) == 1 then
        return value
    elseif value == "guild bank" then
        return "guildbank"
    end
    return value
end

local function JoinSortedLocations(locationSet)
    local locations = {}
    for locationName, hasLocation in pairs(locationSet or {}) do
        if hasLocation then
            table.insert(locations, locationName)
        end
    end

    table.sort(locations)
    return table.concat(locations, ", ")
end

local function MergeLocationStrings(...)
    local merged = {}
    for i = 1, select("#", ...) do
        local locationText = select(i, ...)
        if locationText and locationText ~= "" then
            for part in string.gmatch(locationText, "([^,]+)") do
                local trimmed = zo_strtrim and zo_strtrim(part) or part:gsub("^%s+", ""):gsub("%s+$", "")
                if trimmed ~= "" then
                    merged[trimmed] = true
                end
            end
        end
    end
    return JoinSortedLocations(merged)
end

local function GetLocalizedStringByPrefix(prefix, value, fallback)
    local globalName = prefix .. tostring(value)
    local stringId = _G[globalName]
    if stringId then
        local text = GetString(stringId)
        if text and text ~= "" then
            return zo_strformat("<<t:1>>", text)
        end
    end
    return fallback or tostring(value)
end

local function GetItemTypeInfo(bagId, slotIndex)
    local itemType = GetItemType(bagId, slotIndex) or 0
    local itemTypeName = GetLocalizedStringByPrefix("SI_ITEMTYPE", itemType, tostring(itemType))
    return itemType, itemTypeName
end

local function GetItemQualityInfo(bagId, slotIndex)
    local quality = GetItemQuality(bagId, slotIndex) or 0
    local qualityName = GetLocalizedStringByPrefix("SI_ITEMQUALITY", quality, tostring(quality))
    return quality, qualityName
end

local function GetItemTraitInfo(bagId, slotIndex)
    local traitType = GetItemTrait(bagId, slotIndex)
    if not traitType or traitType == ITEM_TRAIT_TYPE_NONE or traitType == 0 then
        return "", ITEM_TRAIT_TYPE_NONE
    end

    local traitName = GetLocalizedStringByPrefix("SI_ITEMTRAITTYPE", traitType, tostring(traitType))
    return traitName, traitType
end

local function GetItemShareCount(bagId, slotIndex)
    local stackCount = GetSlotStackSize(bagId, slotIndex)
    if stackCount and stackCount > 0 then
        return stackCount
    end
    return 1
end

local function GetItemFurnitureDataIdSafe(bagId, slotIndex)
    if not GetItemFurnitureDataId then
        return 0
    end
    return tonumber(GetItemFurnitureDataId(bagId, slotIndex)) or 0
end

local function IsEntryFurnishing(entry)
    return entry and tonumber(entry.itemType or 0) == tonumber(ITEMTYPE_FURNISHING or -1)
end

local function GetCurrentHouseLocationLabel()
    local houseName = nil
    if GetCurrentZoneHouseId and GetHouseDescription then
        local houseId = GetCurrentZoneHouseId()
        if houseId and houseId > 0 then
            houseName = select(1, GetHouseDescription(houseId))
        end
    end

    if houseName and houseName ~= "" then
        return string.format("Placed Furnishing (%s)", zo_strformat("<<t:1>>", houseName))
    end

    return "Placed Furnishing"
end

local function GetItemDataFromBagSlot(bagId, slotIndex)
    local itemName = GetNormalizedItemName(bagId, slotIndex)
    local itemLink = GetNormalizedItemLink(bagId, slotIndex)
    if not itemName or not itemLink then
        return nil
    end

    local itemType, itemTypeName = GetItemTypeInfo(bagId, slotIndex)
    local quality, qualityName = GetItemQualityInfo(bagId, slotIndex)
    local traitName, traitType = GetItemTraitInfo(bagId, slotIndex)
    local furnitureDataId = GetItemFurnitureDataIdSafe(bagId, slotIndex)
    local locationKey, sharedFrom = GetBagLocationInfo(bagId)

    return {
        itemKey = BuildSharedItemKey(itemLink, locationKey),
        itemName = itemName,
        itemLink = itemLink,
        itemType = itemType,
        itemTypeName = itemTypeName,
        quality = quality,
        qualityName = qualityName,
        trait = traitName,
        traitType = traitType,
        furnitureDataId = furnitureDataId,
        bagId = bagId,
        slotIndex = slotIndex,
        locationKey = locationKey,
        sharedFrom = sharedFrom,
    }
end

local function IsItemEligibleForShare(bagId, slotIndex)
    if bagId == nil or slotIndex == nil then
        return false, "Invalid inventory slot."
    end
    if IsItemBound(bagId, slotIndex) then
        return false, "Item is already bound."
    end
    if IsItemBoPAndTradeable(bagId, slotIndex) then
        return false, "Item is restricted to temporary group sharing."
    end
    return true, nil
end

local function IsItemLinkSharedInLocation(itemLink, locationKey)
    if not itemLink or not locationKey or not ItemShare.savedVars or not ItemShare.savedVars.sharedItems then
        return false
    end

    local entryKey = BuildSharedItemKey(itemLink, locationKey)
    return ItemShare.savedVars.sharedItems[entryKey] ~= nil
end

local function FindSharedEntryKeyForBagSlot(bagId, slotIndex)
    local itemLink = GetNormalizedItemLink(bagId, slotIndex)
    if not itemLink then
        return nil
    end

    local locationKey = select(1, GetBagLocationInfo(bagId))
    local entryKey = BuildSharedItemKey(itemLink, locationKey)
    if ItemShare.savedVars and ItemShare.savedVars.sharedItems then
        return ItemShare.savedVars.sharedItems[entryKey] and entryKey or nil
    end
    return nil
end

local function TryRefreshInventoryVisuals()
    if not PLAYER_INVENTORY or not PLAYER_INVENTORY.inventories then
        return
    end

    for _, inventory in pairs(PLAYER_INVENTORY.inventories) do
        local listView = inventory and inventory.listView
        if listView and ZO_ScrollList_RefreshVisible then
            ZO_ScrollList_RefreshVisible(listView)
        end
    end
end

local function GetBagAndSlotFromSlotData(control, slotData)
    local bagId, slotIndex = nil, nil

    if type(slotData) == "table" then
        bagId = slotData.bagId
            or (slotData.slotData and slotData.slotData.bagId)
            or (slotData.dataEntry and slotData.dataEntry.data and slotData.dataEntry.data.bagId)
            or (slotData.rawSlotData and slotData.rawSlotData.bagId)

        slotIndex = slotData.slotIndex
            or (slotData.slotData and slotData.slotData.slotIndex)
            or (slotData.dataEntry and slotData.dataEntry.data and slotData.dataEntry.data.slotIndex)
            or (slotData.rawSlotData and slotData.rawSlotData.slotIndex)
    end

    if (bagId == nil or slotIndex == nil) and ZO_InventorySlot_GetBagAndIndex then
        bagId, slotIndex = ZO_InventorySlot_GetBagAndIndex(control)
    end

    return bagId, slotIndex
end

local function EnsureShareMarker(control)
    if not control then
        return nil
    end

    if control.ItemShareMarker and control.ItemShareMarker.SetTexture then
        return control.ItemShareMarker
    end

    local marker = WINDOW_MANAGER:CreateControl(nil, control, CT_TEXTURE)
    marker:SetDrawLayer(DL_OVERLAY)
    marker:SetDrawTier(DT_HIGH)
    marker:SetDimensions(18, 18)
    marker:SetTexture(SHARE_TEXTURE_PATH)
    marker:SetHidden(true)
    marker:SetMouseEnabled(true)

    marker:SetHandler("OnMouseEnter", function(self)
        InitializeTooltip(InformationTooltip, self, TOPLEFT, 0, 0)
        SetTooltipText(InformationTooltip, "|c00FF00Shared Item|r\nThis item is available to others.")
    end)

    marker:SetHandler("OnMouseExit", function()
        ClearTooltip(InformationTooltip)
    end)

    local icon = control.GetNamedChild and control:GetNamedChild("Icon") or nil
    local nameLabel = control.GetNamedChild and control:GetNamedChild("Name") or nil

    if icon then
        marker:ClearAnchors()
        marker:SetAnchor(RIGHT, icon, LEFT, -4, 0)
        marker:SetDrawLayer(icon:GetDrawLayer())
        marker:SetDrawTier(icon:GetDrawTier() + 1)
    else
        marker:SetAnchor(TOPLEFT, control, TOPLEFT, 2, 2)
    end

    control.ItemShareMarker = marker
    return marker
end

local function UpdateSharedRowMarker(control, slotData)
    if not control then
        return
    end

    local marker = EnsureShareMarker(control)
    if not marker then
        return
    end

    local bagId, slotIndex = GetBagAndSlotFromSlotData(control, slotData)
    if bagId == nil or slotIndex == nil then
        marker:SetHidden(true)
        return
    end

    local itemLink = GetNormalizedItemLink(bagId, slotIndex)
    local locationKey = select(1, GetBagLocationInfo(bagId))
    if itemLink and locationKey and IsItemLinkSharedInLocation(itemLink, locationKey) then
        marker:SetHidden(false)
    else
        marker:SetHidden(true)
    end
end

local function HookInventoryRowCallbacks()
    if not PLAYER_INVENTORY or not PLAYER_INVENTORY.inventories then
        return
    end

    for _, inventory in pairs(PLAYER_INVENTORY.inventories) do
        local listView = inventory and inventory.listView
        local dataTypes = listView and listView.dataTypes

        if dataTypes then
            for _, dataType in pairs(dataTypes) do
                if dataType and not dataType.ItemShareWrapped then
                    if type(dataType.callbackFunction) == "function" then
                        local originalCallbackFunction = dataType.callbackFunction
                        dataType.callbackFunction = function(control, slotData, ...)
                            originalCallbackFunction(control, slotData, ...)
                            UpdateSharedRowMarker(control, slotData)
                        end
                        dataType.ItemShareWrapped = true
                    elseif type(dataType.callback) == "function" then
                        local originalCallback = dataType.callback
                        dataType.callback = function(control, slotData, ...)
                            originalCallback(control, slotData, ...)
                            UpdateSharedRowMarker(control, slotData)
                        end
                        dataType.ItemShareWrapped = true
                    elseif type(dataType.setupCallback) == "function" then
                        local originalSetupCallback = dataType.setupCallback
                        dataType.setupCallback = function(control, slotData, ...)
                            originalSetupCallback(control, slotData, ...)
                            UpdateSharedRowMarker(control, slotData)
                        end
                        dataType.ItemShareWrapped = true
                    end
                end
            end
        end
    end

    TryRefreshInventoryVisuals()
end

local function AddItemToShareFromBagSlot(bagId, slotIndex)
    local isEligible, reason = IsItemEligibleForShare(bagId, slotIndex)
    if not isEligible then
        dmsg(string.format("Cannot add item to share: %s", tostring(reason)))
        return
    end

    local itemData = GetItemDataFromBagSlot(bagId, slotIndex)
    if not itemData then
        dmsg("Could not determine item data.")
        return
    end

    local stackCount = GetItemShareCount(bagId, slotIndex)
    local existing = ItemShare.savedVars.sharedItems[itemData.itemKey]
    SaveSharedEntry(itemData, stackCount, existing and existing.firstDumpedAt or GetTimeStamp(), true)

    dmsg(string.format(
        "%s shared item %s from %s (stack size: %d)",
        existing and "Updated" or "Added",
        itemData.itemName,
        itemData.sharedFrom,
        stackCount
    ))
end

RemoveItemFromShareByKey = function(itemKey, entry, refreshListWindow)
    if not itemKey or itemKey == "" then
        return
    end

    local itemName = entry and entry.itemName or itemKey
    ItemShare.savedVars.sharedItems[itemKey] = nil
    dmsg(string.format("Removed %s from shared list.", tostring(itemName)))
    TryRefreshInventoryVisuals()
    if refreshListWindow ~= false then
        RefreshShareListWindowIfVisible()
    end
end


SaveSharedEntry = function(itemData, count, firstDumpedAt, refreshListWindow)
    if not itemData or not itemData.itemKey then
        return nil
    end

    local now = GetTimeStamp()
    local existing = ItemShare.savedVars.sharedItems[itemData.itemKey]
    local entry = existing or {}

    entry.itemKey = itemData.itemKey
    entry.accountName = GetCurrentAccountName()
    entry.itemName = itemData.itemName
    entry.itemLink = itemData.itemLink
    entry.itemType = itemData.itemType
    entry.itemTypeName = itemData.itemTypeName
    entry.quality = itemData.quality
    entry.qualityName = itemData.qualityName
    entry.trait = itemData.trait
    entry.traitType = itemData.traitType
    entry.furnitureDataId = itemData.furnitureDataId
    entry.bagId = itemData.bagId
    entry.slotIndex = itemData.slotIndex
    entry.locationKey = itemData.locationKey
    entry.sharedFrom = itemData.sharedFrom
    entry.count = tonumber(count or 0) or 0
    entry.firstDumpedAt = tonumber(firstDumpedAt or entry.firstDumpedAt or now) or now
    entry.lastDumpedAt = now

    ItemShare.savedVars.sharedItems[itemData.itemKey] = entry
    TryRefreshInventoryVisuals()
    if refreshListWindow ~= false then
        RefreshShareListWindowIfVisible()
    end
    return entry
end

SaveSharedEntryFromSavedEntry = function(entry, refreshListWindow)
    if not entry or not entry.itemLink then
        return nil
    end

    local locationKey = tostring(entry.locationKey or "")
    if locationKey == "" then
        locationKey = BuildLocationKeyFromSharedFrom(entry.sharedFrom)
    end

    local itemData = {
        itemKey = BuildSharedItemKey(entry.itemLink, locationKey),
        itemName = entry.itemName,
        itemLink = entry.itemLink,
        itemType = entry.itemType,
        itemTypeName = entry.itemTypeName,
        quality = entry.quality,
        qualityName = entry.qualityName,
        trait = entry.trait,
        traitType = entry.traitType,
        furnitureDataId = entry.furnitureDataId,
        bagId = entry.bagId,
        slotIndex = entry.slotIndex,
        locationKey = locationKey,
        sharedFrom = entry.sharedFrom,
    }

    return SaveSharedEntry(itemData, entry.count, entry.firstDumpedAt or GetTimeStamp(), refreshListWindow)
end

local function RemoveItemFromShareFromBagSlot(bagId, slotIndex)
    local itemData = GetItemDataFromBagSlot(bagId, slotIndex)
    if not itemData or not itemData.itemLink or not itemData.itemName then
        dmsg("Could not determine item data.")
        return
    end

    local existing = ItemShare.savedVars.sharedItems[itemData.itemKey]
    if existing then
        RemoveItemFromShareByKey(itemData.itemKey, existing, true)
    else
        dmsg(string.format("Item was not found in shared list: %s", itemData.itemName))
    end
end

local function AddInventoryContextMenu(slot)
    if not slot or slot.bagId == nil or slot.slotIndex == nil then
        return
    end

    local bagId = slot.bagId
    local slotIndex = slot.slotIndex

    if not CanModifyGuildBankShare(bagId, slotIndex, GetSelectedGuildBankId and GetSelectedGuildBankId() or nil) then
        return
    end
    local itemLink = GetNormalizedItemLink(bagId, slotIndex)
    local itemName = GetNormalizedItemName(bagId, slotIndex)
    if not itemLink or not itemName then
        return
    end

    local sharedEntryKey = FindSharedEntryKeyForBagSlot(bagId, slotIndex)
    if sharedEntryKey then
        AddCustomMenuItem("Remove from Shared List", function()
            RemoveItemFromShareFromBagSlot(bagId, slotIndex)
        end, MENU_ADD_OPTION_LABEL)
        return
    end

    local isEligible = IsItemEligibleForShare(bagId, slotIndex)
    if not isEligible then
        return
    end

    AddCustomMenuItem("Add to Share", function()
        AddItemToShareFromBagSlot(bagId, slotIndex)
    end, MENU_ADD_OPTION_LABEL)
end

local function RegisterContextMenus()
    if not LibCustomMenu then
        dmsg("LibCustomMenu not found.")
        return
    end

    LibCustomMenu:RegisterContextMenu(function(inventorySlot)
        AddInventoryContextMenu(inventorySlot)
    end, LibCustomMenu.CATEGORY_LATE)
end

local function ResetSharedItems()
    ItemShare.savedVars.sharedItems = {}
    dmsg("Saved variables reset. No shared items remain.")
    TryRefreshInventoryVisuals()
    RefreshShareListWindowIfVisible()
end

local function PrintSharedItems()
    RefreshShareListWindow()
end

local function GetTrackedBagIds()
    local bagIds = { BAG_BACKPACK, BAG_BANK }

    if BAG_SUBSCRIBER_BANK then
        table.insert(bagIds, BAG_SUBSCRIBER_BANK)
    end
    if BAG_VIRTUAL then
        table.insert(bagIds, BAG_VIRTUAL)
    end

    local houseBanks = {
        BAG_HOUSE_BANK_ONE,
        BAG_HOUSE_BANK_TWO,
        BAG_HOUSE_BANK_THREE,
        BAG_HOUSE_BANK_FOUR,
        BAG_HOUSE_BANK_FIVE,
        BAG_HOUSE_BANK_SIX,
        BAG_HOUSE_BANK_SEVEN,
        BAG_HOUSE_BANK_EIGHT,
        BAG_HOUSE_BANK_NINE,
        BAG_HOUSE_BANK_TEN,
    }

    for _, bagId in ipairs(houseBanks) do
        if bagId then
            table.insert(bagIds, bagId)
        end
    end

    if BAG_FURNITURE_VAULT then
        table.insert(bagIds, BAG_FURNITURE_VAULT)
    end
    if BAG_GUILDBANK then
        table.insert(bagIds, BAG_GUILDBANK)
    end

    return bagIds
end

local function BuildPlacedFurnitureIndex()
    local placedCountsByFurnitureDataId = {}
    local placedCountsByName = {}
    local placedLocationsByFurnitureDataId = {}
    local placedLocationsByName = {}

    if not GetNextPlacedHousingFurnitureId or not GetPlacedHousingFurnitureInfo then
        return placedCountsByFurnitureDataId, placedCountsByName, placedLocationsByFurnitureDataId, placedLocationsByName
    end

    local canInspectPlacedFurniture = true
    if HasAnyEditingPermissionsForCurrentHouse then
        canInspectPlacedFurniture = HasAnyEditingPermissionsForCurrentHouse()
    elseif IsOwnerOfCurrentHouse then
        canInspectPlacedFurniture = IsOwnerOfCurrentHouse()
    end

    if not canInspectPlacedFurniture then
        return placedCountsByFurnitureDataId, placedCountsByName, placedLocationsByFurnitureDataId, placedLocationsByName
    end

    local placedLocation = GetCurrentHouseLocationLabel()
    local furnitureId = GetNextPlacedHousingFurnitureId(nil)

    while furnitureId do
        local itemName, _, furnitureDataId = GetPlacedHousingFurnitureInfo(furnitureId)
        if itemName and itemName ~= "" then
            local normalizedName = zo_strformat("<<t:1>>", itemName)
            placedCountsByName[normalizedName] = (placedCountsByName[normalizedName] or 0) + 1
            placedLocationsByName[normalizedName] = placedLocationsByName[normalizedName] or {}
            placedLocationsByName[normalizedName][placedLocation] = true
        end

        furnitureDataId = tonumber(furnitureDataId) or 0
        if furnitureDataId > 0 then
            placedCountsByFurnitureDataId[furnitureDataId] = (placedCountsByFurnitureDataId[furnitureDataId] or 0) + 1
            placedLocationsByFurnitureDataId[furnitureDataId] = placedLocationsByFurnitureDataId[furnitureDataId] or {}
            placedLocationsByFurnitureDataId[furnitureDataId][placedLocation] = true
        end

        furnitureId = GetNextPlacedHousingFurnitureId(furnitureId)
    end

    return placedCountsByFurnitureDataId, placedCountsByName, placedLocationsByFurnitureDataId, placedLocationsByName
end

local function BuildActualInventoryIndex()
    local countsByEntryKey = {}
    local countsByLink = {}
    local bagCountsByFurnitureDataId = {}
    local placedCountsByFurnitureDataId = {}
    local placedCountsByName = {}

    for _, bagId in ipairs(GetTrackedBagIds()) do
        local locationKey, locationLabel = GetBagLocationInfo(bagId)
        local bagSize = GetBagSize(bagId) or 0
        for slotIndex = 0, bagSize - 1 do
            local slotItemName = GetItemName(bagId, slotIndex)
            if slotItemName and slotItemName ~= "" then
                local isEligible = IsItemEligibleForShare(bagId, slotIndex)
                if isEligible then
                    local itemData = GetItemDataFromBagSlot(bagId, slotIndex)
                    if itemData and itemData.itemLink then
                        local stackCount = GetItemShareCount(bagId, slotIndex)
                        local entryKey = BuildSharedItemKey(itemData.itemLink, locationKey)

                        countsByEntryKey[entryKey] = {
                            count = (countsByEntryKey[entryKey] and countsByEntryKey[entryKey].count or 0) + stackCount,
                            sharedFrom = locationLabel,
                            locationKey = locationKey,
                            trait = tostring(itemData.trait or ""),
                            furnitureDataId = tonumber(itemData.furnitureDataId) or 0,
                        }
                        countsByLink[itemData.itemLink] = (countsByLink[itemData.itemLink] or 0) + stackCount

                        if tonumber(itemData.furnitureDataId) > 0 then
                            local furnitureDataId = tonumber(itemData.furnitureDataId)
                            bagCountsByFurnitureDataId[furnitureDataId] = (bagCountsByFurnitureDataId[furnitureDataId] or 0) + stackCount
                        end
                    end
                end
            end
        end
    end

    if GetPlacedFurnitureCount and GetPlacedFurnitureIdInfo then
        local placedCount = GetPlacedFurnitureCount() or 0
        for index = 1, placedCount do
            local furnitureId = GetPlacedFurnitureIdInfo(index)
            if furnitureId and GetPlacedFurnitureInfo then
                local _, furnitureDataId = GetPlacedFurnitureInfo(furnitureId)
                furnitureDataId = tonumber(furnitureDataId) or 0
                if furnitureDataId > 0 then
                    placedCountsByFurnitureDataId[furnitureDataId] = (placedCountsByFurnitureDataId[furnitureDataId] or 0) + 1
                end
            end
        end
    elseif GetNextPlacedHousingFurnitureId and GetPlacedHousingFurnitureInfo then
        local furnitureId = GetNextPlacedHousingFurnitureId()
        while furnitureId do
            local _, itemName, _, _, _, _, _, _, furnitureDataId = GetPlacedHousingFurnitureInfo(furnitureId)
            furnitureDataId = tonumber(furnitureDataId) or 0
            if furnitureDataId > 0 then
                placedCountsByFurnitureDataId[furnitureDataId] = (placedCountsByFurnitureDataId[furnitureDataId] or 0) + 1
            elseif itemName and itemName ~= "" then
                local normalizedName = GetNormalizedText(itemName)
                if normalizedName then
                    placedCountsByName[normalizedName] = (placedCountsByName[normalizedName] or 0) + 1
                end
            end
            furnitureId = GetNextPlacedHousingFurnitureId(furnitureId)
        end
    end

    return {
        countsByEntryKey = countsByEntryKey,
        countsByLink = countsByLink,
        bagCountsByFurnitureDataId = bagCountsByFurnitureDataId,
        placedCountsByFurnitureDataId = placedCountsByFurnitureDataId,
        placedCountsByName = placedCountsByName,
    }
end

local function FindAlternateSharedEntryMatch(entry, inventoryIndex)
    if not entry or not inventoryIndex then
        return nil
    end

    local entryItemLink = tostring(entry.itemLink or "")
    if entryItemLink == "" then
        return nil
    end

    local entryTrait = tostring(entry.trait or "")
    local entryLocationKey = tostring(entry.locationKey or BuildLocationKeyFromSharedFrom(entry.sharedFrom) or "")

    for entryKey, actualEntry in pairs(inventoryIndex.countsByEntryKey or {}) do
        if entryKey ~= "" and entryKey ~= tostring(entry.itemKey or "") and type(actualEntry) == "table" then
            local actualItemLink, actualLocationKey = string.match(entryKey, "^(.*)||([^|]*)$")
            actualItemLink = tostring(actualItemLink or "")
            actualLocationKey = tostring(actualLocationKey or "")

            if actualItemLink == entryItemLink and actualLocationKey ~= "" and actualLocationKey ~= entryLocationKey then
                local actualTrait = tostring(actualEntry.trait or "")
                local traitMatches = (entryTrait == "" and actualTrait == "") or (entryTrait ~= "" and actualTrait == entryTrait)

                if traitMatches then
                    return {
                        itemKey = entryKey,
                        locationKey = actualLocationKey,
                        sharedFrom = tostring(actualEntry.sharedFrom or entry.sharedFrom or "-"),
                        count = tonumber(actualEntry.count or 0) or 0,
                    }
                end
            end
        end
    end

    return nil
end

local function SyncSharedItemsWithInventory()
    local sharedItems = ItemShare.savedVars.sharedItems
    local inventoryIndex = BuildActualInventoryIndex()
    local removedCount, updatedCount, unchangedCount, furnishingProtectedCount = 0, 0, 0, 0

    local snapshot = {}
    for itemKey, entry in pairs(sharedItems) do
        snapshot[itemKey] = entry
    end

    for itemKey, entry in pairs(snapshot) do
        local itemName = tostring(entry.itemName or "Unknown Item")
        local actualByEntry = inventoryIndex.countsByEntryKey[itemKey]
        local actualCount = actualByEntry and (tonumber(actualByEntry.count or 0) or 0) or 0
        local currentLocation = actualByEntry and tostring(actualByEntry.sharedFrom or entry.sharedFrom or "-") or tostring(entry.sharedFrom or "-")
        local currentLocationKey = actualByEntry and tostring(actualByEntry.locationKey or entry.locationKey or "") or tostring(entry.locationKey or "")
        local currentItemKey = itemKey
        local isFurnishing = IsEntryFurnishing(entry)
        local furnitureDataId = tonumber(entry.furnitureDataId) or 0

        if actualCount == 0 then
            local alternateMatch = FindAlternateSharedEntryMatch(entry, inventoryIndex)
            if alternateMatch then
                actualCount = tonumber(alternateMatch.count or 0) or 0
                currentLocation = tostring(alternateMatch.sharedFrom or currentLocation or "-")
                currentLocationKey = tostring(alternateMatch.locationKey or currentLocationKey or "")
                currentItemKey = tostring(alternateMatch.itemKey or currentItemKey or itemKey)
            end
        end

        if isFurnishing and actualCount == 0 then
            local extraCount = 0
            if furnitureDataId > 0 then
                extraCount = (inventoryIndex.bagCountsByFurnitureDataId[furnitureDataId] or 0) + (inventoryIndex.placedCountsByFurnitureDataId[furnitureDataId] or 0)
            else
                extraCount = inventoryIndex.placedCountsByName[entry.itemName] or 0
            end

            if extraCount > 0 then
                actualCount = extraCount
                currentLocation = "Placed Furniture"
            end
        end

        if actualCount <= 0 then
            if isFurnishing then
                furnishingProtectedCount = furnishingProtectedCount + 1
                unchangedCount = unchangedCount + 1
                dmsg(string.format("Kept furnishing share entry (unverified instead of removing): %s", itemName))
            else
                sharedItems[itemKey] = nil
                removedCount = removedCount + 1
                dmsg(string.format("Removed missing shared item: %s [%s]", itemName, tostring(entry.sharedFrom or "-")))
            end
        else
            local previousCount = tonumber(entry.count or 0) or 0
            local previousLocation = tostring(entry.sharedFrom or "")
            local previousItemKey = tostring(entry.itemKey or itemKey)
            local previousLocationKey = tostring(entry.locationKey or "")
            local targetItemKey = tostring(currentItemKey or itemKey)

            entry.count = actualCount
            entry.sharedFrom = currentLocation
            entry.locationKey = currentLocationKey
            entry.itemKey = targetItemKey
            entry.lastDumpedAt = GetTimeStamp()

            if targetItemKey ~= itemKey then
                sharedItems[itemKey] = nil
                sharedItems[targetItemKey] = entry
            else
                sharedItems[itemKey] = entry
            end

            if previousCount ~= actualCount
                or previousLocation ~= currentLocation
                or previousItemKey ~= targetItemKey
                or previousLocationKey ~= currentLocationKey then
                updatedCount = updatedCount + 1
                dmsg(string.format("Updated shared item: %s (%d) - %s", itemName, actualCount, currentLocation))
            else
                unchangedCount = unchangedCount + 1
            end
        end
    end

    dmsg(string.format(
        "Sync complete. Updated: %d, Removed: %d, Unchanged: %d, Furnishing protected: %d",
        updatedCount,
        removedCount,
        unchangedCount,
        furnishingProtectedCount
    ))
    RefreshShareListWindowIfVisible()
end

local function OnSlashCommand(arg)
    local rawArg = zo_strtrim(arg or "")
    local lowerArg = zo_strlower(rawArg)

    if lowerArg == "" then
        dmsg("Commands:")
        dmsg("/itemshare list      - Open the shared items window")
        dmsg("/itemshare reset     - Clear all shared entries")
        dmsg("/itemshare sync      - Update counts and remove items no longer owned")
        dmsg("/itemshare save      - Reload the UI")
        dmsg("/itemshare debug     - Toggle debug messages on or off")
        dmsg("/itemshare sheet     - Show the saved spreadsheet link")
        dmsg("/itemshare sharelink - Put the spreadsheet URL into chat")
        dmsg("                   - Furnishings also check furnishing vault and placed furniture")
    elseif lowerArg == "list" then
        local window = ItemShare.ui and ItemShare.ui.listWindow
        if window and not window:IsHidden() then
            window:SetHidden(true)
            SaveListWindowState()
        else
            PrintSharedItems()
        end
    elseif lowerArg == "clear" or lowerArg == "reset" then
        ResetSharedItems()
    elseif lowerArg == "sync" or lowerArg == "cleanup" or lowerArg == "reconcile" then
        SyncSharedItemsWithInventory()
    elseif lowerArg == "save" then
        SyncSharedItemsWithInventory()
        ConfirmReloadUI()
    elseif lowerArg == "debug" then
        ItemShare.savedVars.debugEnabled = not not ItemShare.savedVars.debugEnabled and false or true
        d(string.format("[ItemShare] Debug %s.", ItemShare.savedVars.debugEnabled and "enabled" or "disabled"))
    elseif lowerArg == "guildbank" then
        local current = ItemShare.savedVars.guildBankSharingEnabled == true
        ItemShare.savedVars.guildBankSharingEnabled = not current

        d(string.format(
            "[ItemShare] Guild bank sharing %s.",
            ItemShare.savedVars.guildBankSharingEnabled and "enabled" or "disabled"
        ))
        RefreshShareListWindowIfVisible()
    elseif lowerArg == "sheet clear" then
        SetStoredSpreadsheetUrl("")
        RefreshSpreadsheetControls()
        d("[ItemShare] Spreadsheet link cleared.")
        OpenItemShareWindow()
    elseif string.match(lowerArg, "^sheet%s+") then
        local url = rawArg:match("^sheet%s+(.+)$")
        url = zo_strtrim(tostring(url or ""))
        if url == "" then
            local currentUrl = GetStoredSpreadsheetUrl()
            if currentUrl ~= "" then
                d(string.format("[ItemShare] Spreadsheet link: %s", currentUrl))
                OpenItemShareWindow()
            else
                d("[ItemShare] No spreadsheet link is set. Use /itemshare sheet <url>")
            end
        else
            SetStoredSpreadsheetUrl(url)
            RefreshSpreadsheetControls()
            d(string.format("[ItemShare] Spreadsheet link saved: %s", url))
            OpenItemShareWindow()
        end
    elseif lowerArg == "sharelink" then
        QueueSpreadsheetChatMessage()
    else
        dmsg("Commands:")
        dmsg("/itemshare list      - Open the shared items window")
        dmsg("/itemshare reset     - Clear all shared entries")
        dmsg("/itemshare sync      - Update counts and remove items no longer owned")
        dmsg("/itemshare save      - Reload the UI")
        dmsg("/itemshare sheet     - Show the saved spreadsheet link")
        dmsg("/itemshare sharelink - Put the spreadsheet URL into chat")
        dmsg("                   - Furnishings also check furnishing vault and placed furniture")
    end
end

local function OnAddonLoaded(event, addonName)
    if addonName ~= ItemShare.name then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(ItemShare.name, EVENT_ADD_ON_LOADED)

    ItemShare.savedVars = ZO_SavedVars:NewAccountWide(
        "ItemShareSavedVars",
        2,
        nil,
        defaults
    )

    InstallItemShareLinkHandler()
    RegisterContextMenus()
    HookInventoryRowCallbacks()
    if zo_callLater then
        zo_callLater(HookInventoryRowCallbacks, 500)
    end

    SLASH_COMMANDS["/itemshare"] = OnSlashCommand
    SLASH_COMMANDS["/ishare"] = OnSlashCommand

    if ItemShare.savedVars.listWindowState and ItemShare.savedVars.listWindowState.isOpen then
        PrintSharedItems()
    else
        CreateShareListWindow()
    end

    dmsg("Loaded.")
end

EVENT_MANAGER:RegisterForEvent(ItemShare.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
