local EASInventoryGrid = {
    name = "EASInventoryGrid029239",
    maxCells = 240,
    maxGroupHeaders = 80,
    cells = {},
    groupHeaders = {},
    items = {},
    visible = false,
    lastSearch = "",
    quickslotAssignTarget = nil,
}

local wm = WINDOW_MANAGER

-- Native/free ESO emotes do not expose individual collectible artwork. Use a
-- bundled Suite activity glyph so every emote still has a visible icon.
local NATIVE_EMOTE_FALLBACK_ICON = "ESOAdventurerSuite/Art029125/eas_appicon_activity.dds"

local function emoteBadgeText(name, slashName)
    local source = tostring(name or "")
    if source == "" then source = tostring(slashName or ""):gsub("^/", "") end
    local first, second = source:match("^%s*([%w])[%w']*%s+([%w])")
    if first and second then return string.upper(first .. second) end
    local compact = source:gsub("[^%w]", "")
    if #compact >= 2 then return string.upper(compact:sub(1, 2)) end
    if #compact == 1 then return string.upper(compact) end
    return "EM"
end

local function safe(fn, default, ...)
    if type(fn) ~= "function" then return default end
    local ok, a, b, c, d, e = pcall(fn, ...)
    if not ok then return default end
    if a == nil then return default end
    return a, b, c, d, e
end

local function num(v, d)
    v = tonumber(v)
    if v == nil then return d or 0 end
    return v
end

local function lower(s)
    return string.lower(tostring(s or ""))
end

local LOCK_ICON_TEXTURE = (type(rawget(_G, "ZO_KEYBOARD_LOCKED_ICON")) == "string" and rawget(_G, "ZO_KEYBOARD_LOCKED_ICON")) or "EsoUI/Art/Miscellaneous/status_locked.dds"

local function isCurrencyMode(mode)
    return mode == rawget(_G, "SI_INVENTORY_MODE_CURRENCY") or mode == "wallet"
end

local function isQuickslotMode(mode)
    return mode == rawget(_G, "SI_INVENTORY_MODE_QUICKSLOTS") or mode == "quickslot"
end

local function formatNumber(value)
    value = tonumber(value) or 0
    if type(ZO_CommaDelimitNumber) == "function" then
        local ok, result = pcall(ZO_CommaDelimitNumber, value)
        if ok and result then return tostring(result) end
    end
    return tostring(value)
end

local function colorForQuality(link, displayQuality)
    -- Mirror ESO's own inventory rarity coloring.  The stock keyboard inventory
    -- uses displayQuality with INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, which is
    -- more reliable for the grid than guessing quality from the item link alone.
    local q = tonumber(displayQuality)
    if q == nil and link ~= "" then
        local qf = GetItemLinkDisplayQuality or GetItemLinkQuality
        q = num(safe(qf, nil, link), nil)
    end
    if q ~= nil and type(GetInterfaceColor) == "function" then
        local r, g, b = safe(GetInterfaceColor, nil, INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, q)
        if r ~= nil and g ~= nil and b ~= nil then return r, g, b, 1 end
    end
    local color = q ~= nil and safe(GetItemQualityColor, nil, q) or nil
    if color and color.UnpackRGBA then return color:UnpackRGBA() end
    return 0.35, 0.42, 0.50, 0.95
end

local function setCellQuality(cell, r, g, b, a)
    if not cell or not cell.bg then return end
    r, g, b, a = tonumber(r) or 0.35, tonumber(g) or 0.42, tonumber(b) or 0.50, tonumber(a) or 1
    cell.qualityR, cell.qualityG, cell.qualityB, cell.qualityA = r, g, b, a
    -- Brighter rarity frame and a lighter card so the icons pop more.
    cell.bg:SetEdgeColor(math.min(1, r * 1.10 + 0.05), math.min(1, g * 1.10 + 0.05), math.min(1, b * 1.10 + 0.05), 1)
    cell.bg:SetCenterColor(0.05 + r * 0.18, 0.06 + g * 0.18, 0.08 + b * 0.18, 0.985)
    if cell.qualityFrame then
        cell.qualityFrame:SetEdgeColor(math.min(1, r * 1.08 + 0.04), math.min(1, g * 1.08 + 0.04), math.min(1, b * 1.08 + 0.04), 0.95)
    end
    if cell.icon then
        cell.icon:SetColor(1, 1, 1, 1)
        if cell.icon.SetAlpha then cell.icon:SetAlpha(1) end
    end
end

local function hideTooltip()
    if InformationTooltip and type(ClearTooltip) == "function" then pcall(ClearTooltip, InformationTooltip) end
    if ItemTooltip and type(ClearTooltip) == "function" then pcall(ClearTooltip, ItemTooltip) end
end


-- v0.29.247: protected/private inventory actions must not be invoked through
-- ESO's stock context-menu callbacks when the slot control itself was created by
-- an addon. Doing so taints the menu callback and causes UseItem/Equip/etc. to
-- throw "private function from insecure code". Route protected game functions
-- through CallSecureProtected instead.
local function callGameFunction(functionName, ...)
    functionName = tostring(functionName or "")
    if functionName == "" then return false end

    local isProtected = false
    if type(IsProtectedFunction) == "function" then
        local ok, value = pcall(IsProtectedFunction, functionName)
        isProtected = ok and value == true
    end

    if isProtected then
        if type(CallSecureProtected) ~= "function" then return false end
        return pcall(CallSecureProtected, functionName, ...)
    end

    local fn = rawget(_G, functionName)
    if type(fn) ~= "function" then return false end
    return pcall(fn, ...)
end

local function menuText(stringId, fallback)
    if stringId ~= nil and type(GetString) == "function" then
        local ok, value = pcall(GetString, stringId)
        if ok and tostring(value or "") ~= "" then return tostring(value) end
    end
    return tostring(fallback or "Action")
end


local function enumText(prefix, value, fallback)
    if value ~= nil and type(GetString) == "function" then
        local ok, valueText = pcall(GetString, prefix, value)
        if ok and tostring(valueText or "") ~= "" then return tostring(valueText) end
    end
    return tostring(fallback or "Other")
end

local function cleanGroupName(value)
    local s = tostring(value or "")
    s = s:gsub("|c%x%x%x%x%x%x", ""):gsub("|r", "")
    s = s:gsub("^%s+", ""):gsub("%s+$", "")
    return s
end


function EASInventoryGrid:ShouldEnable()
    return type(rawget(_G, "ZO_PlayerInventory")) == "userdata" or type(rawget(_G, "ZO_PlayerInventory")) == "table"
end

function EASInventoryGrid:CreateCell(index)
    local parent = self.scrollChild
    local cell = wm:CreateControl(self.name .. "Cell" .. tostring(index), parent, CT_BUTTON)
    cell:SetMouseEnabled(true)
    cell:SetDimensions(44, 44)

    local bg = wm:CreateControl(nil, cell, CT_BACKDROP)
    bg:SetAnchorFill(cell)
    bg:SetCenterColor(0.03, 0.04, 0.06, 0.92)
    bg:SetEdgeColor(0.12, 0.18, 0.24, 0.95)
    bg:SetEdgeTexture("EsoUI/Art/Miscellaneous/white_1x1.dds", 1, 1, 2)
    cell.bg = bg

    local qualityFrame = wm:CreateControl(nil, cell, CT_BACKDROP)
    qualityFrame:SetAnchor(TOPLEFT, cell, TOPLEFT, 2, 2)
    qualityFrame:SetAnchor(BOTTOMRIGHT, cell, BOTTOMRIGHT, -2, -2)
    qualityFrame:SetCenterColor(0, 0, 0, 0)
    qualityFrame:SetEdgeColor(0.35, 0.42, 0.50, 0.70)
    qualityFrame:SetEdgeTexture("EsoUI/Art/Miscellaneous/white_1x1.dds", 1, 1, 1)
    qualityFrame:SetMouseEnabled(false)
    cell.qualityFrame = qualityFrame

    local icon = wm:CreateControl(nil, cell, CT_TEXTURE)
    icon:SetAnchor(TOPLEFT, cell, TOPLEFT, 3, 3)
    icon:SetAnchor(BOTTOMRIGHT, cell, BOTTOMRIGHT, -3, -3)
    icon:SetTexture("EsoUI/Art/Icons/icon_missing.dds")
    icon:SetTextureCoords(0.05, 0.95, 0.05, 0.95)
    cell.icon = icon

    -- No separate black stack box. Keep only the text so the item art stays visible.
    local count = wm:CreateControl(nil, cell, CT_LABEL)
    count:SetFont("ZoFontGameSmall")
    count:SetColor(1, 1, 1, 1)
    count:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    count:SetVerticalAlignment(TEXT_ALIGN_BOTTOM)
    count:SetAnchor(BOTTOMRIGHT, cell, BOTTOMRIGHT, -2, -1)
    count:SetDimensions(24, 12)
    cell.count = count

    -- Use ESO's real lock texture instead of an emoji glyph. The emoji was
    -- rendering as a tiny white square on clients/fonts that do not contain it.
    local lockIcon = wm:CreateControl(nil, cell, CT_TEXTURE)
    lockIcon:SetDimensions(15, 15)
    lockIcon:SetAnchor(TOPLEFT, cell, TOPLEFT, 2, 2)
    lockIcon:SetTexture(LOCK_ICON_TEXTURE)
    lockIcon:SetColor(1, 1, 1, 1)
    lockIcon:SetDrawLayer(DL_OVERLAY)
    lockIcon:SetDrawLevel(50)
    lockIcon:SetHidden(true)
    cell.lockIcon = lockIcon

    local marker = wm:CreateControl(nil, cell, CT_LABEL)
    marker:SetFont("ZoFontGameSmall")
    marker:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    marker:SetVerticalAlignment(TEXT_ALIGN_TOP)
    marker:SetAnchor(TOPLEFT, cell, TOPLEFT, 2, 1)
    marker:SetDimensions(16, 16)
    marker:SetHidden(true)
    cell.marker = marker

    local loadoutMarker = wm:CreateControl(nil, cell, CT_LABEL)
    loadoutMarker:SetFont("ZoFontGameBold")
    loadoutMarker:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    loadoutMarker:SetVerticalAlignment(TEXT_ALIGN_TOP)
    loadoutMarker:SetAnchor(TOPRIGHT, cell, TOPRIGHT, -2, 1)
    loadoutMarker:SetDimensions(18, 16)
    loadoutMarker:SetText("L")
    loadoutMarker:SetColor(0.44, 0.78, 1.00, 1)
    loadoutMarker:SetHidden(true)
    cell.loadoutMarker = loadoutMarker

    cell:SetHandler("OnMouseEnter", function(control)
        if control.bg then
            local r, g, b = control.qualityR or 0.35, control.qualityG or 0.42, control.qualityB or 0.50
            control.bg:SetCenterColor(0.10 + r * 0.22, 0.11 + g * 0.22, 0.13 + b * 0.22, 1)
        end

        -- Keep hover informational only. Calling ESO's full inventory-slot
        -- hover pipeline from an addon-created control can register stock
        -- mouseover keybind actions with an insecure call stack.
        if ItemTooltip and type(InitializeTooltip) == "function" and control.bagId ~= nil and control.slotIndex ~= nil then
            InitializeTooltip(ItemTooltip, control, RIGHT, 4, 0, LEFT)
            if type(ItemTooltip.SetBagItem) == "function" then
                pcall(ItemTooltip.SetBagItem, ItemTooltip, control.bagId, control.slotIndex)
            end
        elseif ItemTooltip and type(InitializeTooltip) == "function" and control.questItem then
            InitializeTooltip(ItemTooltip, control, RIGHT, 4, 0, LEFT)
            if control.toolIndex and type(ItemTooltip.SetQuestTool) == "function" then
                pcall(ItemTooltip.SetQuestTool, ItemTooltip, control.questIndex, control.toolIndex)
            elseif control.conditionIndex and type(ItemTooltip.SetQuestItem) == "function" then
                pcall(ItemTooltip.SetQuestItem, ItemTooltip, control.questIndex, control.stepIndex, control.conditionIndex)
            end
        elseif InformationTooltip and type(InitializeTooltip) == "function" and control.itemName then
            InitializeTooltip(InformationTooltip, control, RIGHT, 4, 0, LEFT)
            InformationTooltip:AddLine(tostring(control.itemName), "ZoFontWinH4")
        end
    end)
    cell:SetHandler("OnMouseExit", function(control)
        if control.bg then
            setCellQuality(control, control.qualityR, control.qualityG, control.qualityB, control.qualityA)
        end
        hideTooltip()
    end)

    -- Left click is handled by the button's normal OnClicked path so the context
    -- menu reliably appears on Suite-created grid cells. Right click uses
    -- OnMouseUp. If a Quickslot target is armed, left click assigns/replaces that
    -- slot instead of opening the menu.
    cell:SetHandler("OnClicked", function(control)
        if not control.slotType then return end
        if EASInventoryGrid.quickslotAssignTarget and control.bagId ~= nil and control.slotIndex ~= nil then
            if EASInventoryGrid:AssignItemToSelectedQuickslot(control) then return end
        end
        EASInventoryGrid:ShowSafeItemMenu(control)
    end)
    cell:SetHandler("OnMouseUp", function(control, button, upInside)
        if not upInside or not control.slotType then return end
        if button == MOUSE_BUTTON_INDEX_RIGHT then
            EASInventoryGrid:ShowSafeItemMenu(control)
        end
    end)

    self.cells[index] = cell
    return cell
end

function EASInventoryGrid:RefreshSoon()
    zo_callLater(function()
        if self.visible then self:Refresh(true) end
    end, 40)
end

function EASInventoryGrid:SafeUseBagItem(control)
    local bag, slot = tonumber(control and control.bagId), tonumber(control and control.slotIndex)
    if bag == nil or slot == nil then return false end
    local usable, onlyFromActionSlot = safe(IsItemUsable, false, bag, slot)
    if usable ~= true or onlyFromActionSlot == true then return false end

    local useType = safe(GetItemUseType, nil, bag, slot)
    if useType ~= nil and useType == rawget(_G, "ITEM_USE_TYPE_COMBINATION") then
        return callGameFunction("InitiateConfirmUseInventoryItem", bag, slot)
    end
    return callGameFunction("UseItem", bag, slot)
end

function EASInventoryGrid:SafeEquipBagItem(control)
    local bag, slot = tonumber(control and control.bagId), tonumber(control and control.slotIndex)
    if bag == nil or slot == nil then return false end
    if safe(IsItemPlayerLocked, false, bag, slot) == true then return false end

    local equipable = safe(IsEquipable, false, bag, slot)
    if equipable ~= true then return false end

    local actorCategory = safe(GetItemActorCategory, rawget(_G, "GAMEPLAY_ACTOR_CATEGORY_PLAYER"), bag, slot)
    if actorCategory == rawget(_G, "GAMEPLAY_ACTOR_CATEGORY_COMPANION") then
        local interaction = safe(GetInteractionType, nil)
        if interaction ~= rawget(_G, "INTERACTION_COMPANION_MENU") then return false end
    end
    local wornBag = actorCategory == rawget(_G, "GAMEPLAY_ACTOR_CATEGORY_COMPANION") and rawget(_G, "BAG_COMPANION_WORN") or rawget(_G, "BAG_WORN")
    if wornBag == nil then return false end

    local function doEquip()
        callGameFunction("RequestEquipItem", bag, slot, wornBag)
        self:RefreshSoon()
    end

    local bindType = safe(GetItemBindType, nil, bag, slot)
    local wouldBind = (bindType ~= nil and bindType == rawget(_G, "BIND_TYPE_ON_EQUIP")) or safe(IsItemBoPAndTradeable, false, bag, slot) == true
    wouldBind = wouldBind and safe(IsItemBound, false, bag, slot) ~= true
    if wouldBind and type(ZO_Dialogs_ShowPlatformDialog) == "function" then
        local itemName = tostring(safe(GetItemName, "Item", bag, slot) or "Item")
        local quality = num(safe(GetItemDisplayQuality, nil, bag, slot), nil)
        local color = quality ~= nil and safe(GetItemQualityColor, nil, quality) or nil
        if color and color.Colorize then itemName = color:Colorize(itemName) end
        pcall(ZO_Dialogs_ShowPlatformDialog, "CONFIRM_EQUIP_ITEM", { onAcceptCallback = doEquip }, { mainTextParams = { itemName } })
        return true
    end
    doEquip()
    return true
end

function EASInventoryGrid:SafeToggleQuickslot(control)
    local bag, slot = tonumber(control and control.bagId), tonumber(control and control.slotIndex)
    if bag == nil or slot == nil or not QUICKSLOT_KEYBOARD or type(QUICKSLOT_KEYBOARD.AreQuickSlotsShowing) ~= "function" or not QUICKSLOT_KEYBOARD:AreQuickSlotsShowing() then
        return false
    end
    local category = rawget(_G, "HOTBAR_CATEGORY_QUICKSLOT_WHEEL")
    if category == nil then return false end

    local current = safe(FindActionSlotMatchingItem, nil, bag, slot, category)
    if current then
        local ok = callGameFunction("ClearSlot", current, category)
        self:RefreshSoon()
        return ok
    end

    local valid = safe(GetFirstFreeValidSlotForItem, nil, bag, slot, category)
    if valid then
        local ok = callGameFunction("SelectSlotItem", bag, slot, valid, category)
        self:RefreshSoon()
        return ok
    end
    return false
end

function EASInventoryGrid:AssignItemToSelectedQuickslot(control)
    local target = tonumber(self.quickslotAssignTarget)
    local bag, slot = tonumber(control and control.bagId), tonumber(control and control.slotIndex)
    local category = rawget(_G, "HOTBAR_CATEGORY_QUICKSLOT_WHEEL")
    if not target or bag == nil or slot == nil or category == nil then return false end

    if type(IsValidItemForSlot) == "function" and safe(IsValidItemForSlot, false, bag, slot, target, category) ~= true then
        local validSomewhere = false
        for _, wheelSlot in ipairs(self:GetQuickslotSlotIndices()) do
            if safe(IsValidItemForSlot, false, bag, slot, wheelSlot, category) == true then
                validSomewhere = true
                break
            end
        end
        if not validSomewhere then
            if ESOProgressionCoach and type(ESOProgressionCoach.Print) == "function" then
                ESOProgressionCoach:Print("That item cannot be placed on the Quickslot wheel.")
            end
            return true
        end
        -- The selected wedge can report stale validity during refresh. Since the
        -- item is valid on this wheel, let the secure ESO assignment make the
        -- final decision for the chosen wedge.
    end

    local ok = callGameFunction("SelectSlotItem", bag, slot, target, category)
    if ok then
        if ESOProgressionCoach and type(ESOProgressionCoach.Print) == "function" then
            ESOProgressionCoach:Print("Quickslot updated. Open Quickslots to see the new item.")
        end
        self.quickslotAssignTarget = nil
        self:RefreshSoon()
        return true
    end
    if ESOProgressionCoach and type(ESOProgressionCoach.Print) == "function" then
        ESOProgressionCoach:Print("ESO did not allow that item to be assigned to the selected Quickslot.")
    end
    return true
end

function EASInventoryGrid:AssignSimpleActionToSelectedQuickslot(control)
    local target = tonumber(self.quickslotAssignTarget)
    local category = rawget(_G, "HOTBAR_CATEGORY_QUICKSLOT_WHEEL")
    local actionType = tonumber(control and control.actionType)
    local actionId = tonumber(control and control.actionId)
    if not target or category == nil or not actionType or not actionId then return false end

    local validSomewhere = true
    if actionType == rawget(_G, "ACTION_TYPE_COLLECTIBLE") and type(IsValidCollectibleForSlot) == "function" then
        validSomewhere = self:IsCollectibleValidForAnyQuickslot(actionId)
    elseif actionType == rawget(_G, "ACTION_TYPE_EMOTE") and type(IsValidEmoteForSlot) == "function" then
        validSomewhere = self:IsEmoteValidForAnyQuickslot(actionId)
    end
    if not validSomewhere then
        if ESOProgressionCoach and type(ESOProgressionCoach.Print) == "function" then
            ESOProgressionCoach:Print("ESO does not allow that Collection/Emote action on the Quickslot wheel.")
        end
        return true
    end

    local ok = callGameFunction("SelectSlotSimpleAction", actionType, actionId, target, category)
    if not ok then ok = callGameFunction("SelectSlotSimpleAction", actionType, actionId, target) end
    if ok then
        if ESOProgressionCoach and type(ESOProgressionCoach.Print) == "function" then
            ESOProgressionCoach:Print("Quickslot updated.")
        end
        self.quickslotAssignTarget = nil
        self.quickslotAssignIndex = nil
        self:RefreshSoon()
        return true
    end
    if ESOProgressionCoach and type(ESOProgressionCoach.Print) == "function" then
        ESOProgressionCoach:Print("ESO did not allow that action to be assigned to the selected Quickslot.")
    end
    return true
end

function EASInventoryGrid:AssignPickerEntryToSelectedQuickslot(control)
    if control and control.directUseOnly == true and tonumber(control.collectibleId or control.actionId) then
        return self:UseCollectibleFromPicker(control)
    end
    if control and tonumber(control.actionType) and tonumber(control.actionId) then
        return self:AssignSimpleActionToSelectedQuickslot(control)
    end
    return self:AssignItemToSelectedQuickslot(control)
end

function EASInventoryGrid:ArmQuickslotAssignment(slotNum, displayIndex)
    slotNum = tonumber(slotNum)
    if not slotNum then return end
    if tonumber(self.quickslotAssignTarget) == slotNum then
        self.quickslotAssignTarget = nil
        self.quickslotAssignIndex = nil
        if ESOProgressionCoach and type(ESOProgressionCoach.Print) == "function" then
            ESOProgressionCoach:Print("Quickslot replacement cancelled.")
        end
        self:RefreshSpecialMode()
        return
    end
    self.quickslotAssignTarget = slotNum
    self.quickslotAssignIndex = tonumber(displayIndex)
    if ESOProgressionCoach and type(ESOProgressionCoach.Print) == "function" then
        ESOProgressionCoach:Print(string.format("Quickslot %s selected. Choose an item from the Quickslot item picker below.", tostring(displayIndex or slotNum)))
    end
    self:RefreshSpecialMode()
end

function EASInventoryGrid:ShowSafeItemMenu(control)
    if not control then return end
    if type(ClearMenu) == "function" then pcall(ClearMenu) end

    local added = 0
    local function add(label, callback)
        if type(AddMenuItem) ~= "function" then return end
        AddMenuItem(label, callback, MENU_ADD_OPTION_LABEL)
        added = added + 1
    end

    if control.questItem then
        local canUse = false
        if control.toolIndex then
            canUse = safe(CanUseQuestTool, false, control.questIndex, control.toolIndex) == true
        elseif control.conditionIndex then
            canUse = safe(CanUseQuestItem, false, control.questIndex, control.stepIndex, control.conditionIndex) == true
        end
        if canUse then
            add(menuText(rawget(_G, "SI_ITEM_ACTION_USE"), "Use"), function()
                if control.toolIndex then
                    callGameFunction("UseQuestTool", control.questIndex, control.toolIndex)
                elseif control.conditionIndex then
                    callGameFunction("UseQuestItem", control.questIndex, control.stepIndex, control.conditionIndex)
                end
            end)
        end
    else
        local bag, slot = tonumber(control.bagId), tonumber(control.slotIndex)
        if bag ~= nil and slot ~= nil then
            if self.quickslotAssignTarget then
                local target = tonumber(self.quickslotAssignTarget)
                local category = rawget(_G, "HOTBAR_CATEGORY_QUICKSLOT_WHEEL")
                if target and category and (type(IsValidItemForSlot) ~= "function" or safe(IsValidItemForSlot, false, bag, slot, target, category) == true) then
                    add("Place in selected Quickslot", function() self:AssignItemToSelectedQuickslot(control) end)
                end
            end

            local usable, onlyFromActionSlot = safe(IsItemUsable, false, bag, slot)
            if usable == true and onlyFromActionSlot ~= true then
                add(menuText(rawget(_G, "SI_ITEM_ACTION_USE"), "Use"), function() self:SafeUseBagItem(control); self:RefreshSoon() end)
            end

            local actorCategory = safe(GetItemActorCategory, rawget(_G, "GAMEPLAY_ACTOR_CATEGORY_PLAYER"), bag, slot)
            local companionOkay = actorCategory ~= rawget(_G, "GAMEPLAY_ACTOR_CATEGORY_COMPANION") or safe(GetInteractionType, nil) == rawget(_G, "INTERACTION_COMPANION_MENU")
            if companionOkay and safe(IsEquipable, false, bag, slot) == true and safe(IsItemPlayerLocked, false, bag, slot) ~= true then
                add(menuText(rawget(_G, "SI_ITEM_ACTION_EQUIP"), "Equip"), function() self:SafeEquipBagItem(control) end)
            end

            if QUICKSLOT_KEYBOARD and type(QUICKSLOT_KEYBOARD.AreQuickSlotsShowing) == "function" and QUICKSLOT_KEYBOARD:AreQuickSlotsShowing() then
                local category = rawget(_G, "HOTBAR_CATEGORY_QUICKSLOT_WHEEL")
                local current = category and safe(FindActionSlotMatchingItem, nil, bag, slot, category) or nil
                local valid = category and safe(GetFirstFreeValidSlotForItem, nil, bag, slot, category) or nil
                if current then
                    add(menuText(rawget(_G, "SI_ITEM_ACTION_REMOVE_FROM_QUICKSLOT"), "Remove From Quickslot"), function() self:SafeToggleQuickslot(control) end)
                elseif valid then
                    add(menuText(rawget(_G, "SI_ITEM_ACTION_MAP_TO_QUICKSLOT"), "Add To Quickslot"), function() self:SafeToggleQuickslot(control) end)
                end
            end

            local link = tostring(control.link or safe(GetItemLink, "", bag, slot, LINK_STYLE_BRACKETS or LINK_STYLE_DEFAULT or 0) or "")
            if link ~= "" and type(ZO_LinkHandler_InsertLink) == "function" then
                add(menuText(rawget(_G, "SI_ITEM_ACTION_LINK_TO_CHAT"), "Link in Chat"), function()
                    local formatted = type(zo_strformat) == "function" and zo_strformat(SI_TOOLTIP_ITEM_NAME, link) or link
                    pcall(ZO_LinkHandler_InsertLink, formatted)
                end)
            end

            if safe(CanItemBePlayerLocked, false, bag, slot) == true then
                local locked = safe(IsItemPlayerLocked, false, bag, slot) == true
                local stringId = locked and rawget(_G, "SI_ITEM_ACTION_UNMARK_AS_LOCKED") or rawget(_G, "SI_ITEM_ACTION_MARK_AS_LOCKED")
                add(menuText(stringId, locked and "Unlock" or "Lock"), function()
                    callGameFunction("SetItemIsPlayerLocked", bag, slot, not locked)
                    if type(PlaySound) == "function" and SOUNDS then pcall(PlaySound, not locked and SOUNDS.INVENTORY_ITEM_LOCKED or SOUNDS.INVENTORY_ITEM_UNLOCKED) end
                    self:RefreshSoon()
                end)
            end

            if safe(CanItemBeMarkedAsJunk, false, bag, slot) == true and safe(IsItemPlayerLocked, false, bag, slot) ~= true then
                local junk = safe(IsItemJunk, false, bag, slot) == true
                local stringId = junk and rawget(_G, "SI_ITEM_ACTION_UNMARK_AS_JUNK") or rawget(_G, "SI_ITEM_ACTION_MARK_AS_JUNK")
                add(menuText(stringId, junk and "Unmark as Junk" or "Mark as Junk"), function()
                    callGameFunction("SetItemIsJunk", bag, slot, not junk)
                    if type(PlaySound) == "function" and SOUNDS then pcall(PlaySound, not junk and SOUNDS.INVENTORY_ITEM_JUNKED or SOUNDS.INVENTORY_ITEM_UNJUNKED) end
                    self:RefreshSoon()
                end)
            end
        end
    end

    if added == 0 then
        add(tostring(control.itemName or "Item"), function() end)
    end
    if type(ShowMenu) == "function" then pcall(ShowMenu, control) end
end

function EASInventoryGrid:EnsureSaved()
    if not ESOProgressionCoach then return end
    ESOProgressionCoach.saved = ESOProgressionCoach.saved or {}
    local s = ESOProgressionCoach.saved
    s.inventoryGridCollapsedGroups = s.inventoryGridCollapsedGroups or {}
end

function EASInventoryGrid:CreateGroupHeader(index)
    local parent = self.scrollChild
    local header = wm:CreateControl(self.name .. "GroupHeader" .. tostring(index), parent, CT_BUTTON)
    header:SetDimensions(420, 28)
    header:SetMouseEnabled(true)
    header:SetHidden(true)

    local bg = wm:CreateControl(nil, header, CT_BACKDROP)
    bg:SetAnchorFill(header)
    bg:SetCenterColor(0.035, 0.055, 0.075, 0.98)
    bg:SetEdgeColor(0.28, 0.48, 0.62, 0.95)
    bg:SetEdgeTexture("EsoUI/Art/Miscellaneous/white_1x1.dds", 1, 1, 1)
    header.bg = bg

    local toggle = wm:CreateControl(nil, header, CT_LABEL)
    toggle:SetAnchor(LEFT, header, LEFT, 8, 0)
    toggle:SetDimensions(28, 24)
    toggle:SetFont("ZoFontGameBold")
    toggle:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    toggle:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    toggle:SetColor(0.95, 0.84, 0.38, 1)
    header.toggleLabel = toggle

    local title = wm:CreateControl(nil, header, CT_LABEL)
    title:SetAnchor(LEFT, toggle, RIGHT, 4, 0)
    -- Leave a dedicated right-side lane for the full "# items" text.
    title:SetAnchor(RIGHT, header, RIGHT, -140, 0)
    title:SetFont("ZoFontGameBold")
    title:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    title:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    title:SetColor(0.90, 0.94, 0.98, 1)
    header.titleLabel = title

    local count = wm:CreateControl(nil, header, CT_LABEL)
    count:SetAnchor(RIGHT, header, RIGHT, -10, 0)
    count:SetDimensions(122, 24)
    count:SetFont("ZoFontGame")
    count:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    count:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    count:SetColor(0.96, 0.88, 0.56, 1)
    header.countLabel = count

    header:SetHandler("OnMouseEnter", function(control)
        if control.bg then control.bg:SetCenterColor(0.07, 0.10, 0.14, 1) end
    end)
    header:SetHandler("OnMouseExit", function(control)
        if control.bg then control.bg:SetCenterColor(0.035, 0.055, 0.075, 0.98) end
    end)
    header:SetHandler("OnClicked", function(control)
        if not control.groupKey then return end
        self:EnsureSaved()
        local collapsed = ESOProgressionCoach.saved.inventoryGridCollapsedGroups
        collapsed[control.groupKey] = not (collapsed[control.groupKey] == true)
        self:Refresh()
    end)

    self.groupHeaders[index] = header
    return header
end

function EASInventoryGrid:GetCollapsedGroupTable()
    self:EnsureSaved()
    return ESOProgressionCoach and ESOProgressionCoach.saved and ESOProgressionCoach.saved.inventoryGridCollapsedGroups or {}
end

function EASInventoryGrid:GetCurrentGroupScope()
    local data, inventoryType = self:GetActiveInventoryData()
    local currentFilter = type(data) == "table" and data.currentFilter or 0
    return tostring(inventoryType or 0) .. ":" .. tostring(currentFilter or 0)
end

function EASInventoryGrid:GetSetName(link)
    if not link or link == "" or type(GetItemLinkSetInfo) ~= "function" then return nil end
    local hasSet, setName = safe(GetItemLinkSetInfo, false, link, true)
    setName = cleanGroupName(setName)
    if hasSet == true and setName ~= "" then return setName end
    return nil
end

function EASInventoryGrid:GetBuiltInGroupName(item)
    if not item then return "Other" end
    if item.questItem then return "Quest Items" end
    local link = tostring(item.link or "")
    if link == "" then return "Other" end

    local data = self:GetActiveInventoryData()
    local filter = type(data) == "table" and data.currentFilter or nil
    local setName = self:GetSetName(link)
    local weapons = rawget(_G, "ITEM_TYPE_DISPLAY_CATEGORY_WEAPONS")
    local armor = rawget(_G, "ITEM_TYPE_DISPLAY_CATEGORY_ARMOR")
    local jewelry = rawget(_G, "ITEM_TYPE_DISPLAY_CATEGORY_JEWELRY")
    local all = rawget(_G, "ITEM_TYPE_DISPLAY_CATEGORY_ALL")

    local armorType = num(safe(GetItemLinkArmorType, 0, link), 0)
    local weaponType = num(safe(GetItemLinkWeaponType, 0, link), 0)
    local equipType = num(safe(GetItemLinkEquipType, 0, link), 0)

    local isJewelry = equipType == rawget(_G, "EQUIP_TYPE_RING") or equipType == rawget(_G, "EQUIP_TYPE_NECK")
    local isArmor = armorType ~= 0 and not isJewelry
    local isWeapon = weaponType ~= 0

    if filter == armor then
        if setName then return "Set: " .. setName end
        return enumText("SI_ARMORTYPE", armorType, "Non-Set Armor")
    elseif filter == weapons then
        if setName then return "Set: " .. setName end
        return enumText("SI_WEAPONTYPE", weaponType, "Non-Set Weapons")
    elseif filter == jewelry then
        if setName then return "Set: " .. setName end
        return enumText("SI_EQUIPTYPE", equipType, "Non-Set Jewelry")
    elseif filter == all or filter == nil then
        if setName then
            if isWeapon then return "Weapons • " .. setName end
            if isJewelry then return "Jewelry • " .. setName end
            if isArmor then return "Armor • " .. setName end
            return "Set • " .. setName
        end
        if isWeapon then return "Weapons • " .. enumText("SI_WEAPONTYPE", weaponType, "Other") end
        if isJewelry then return "Jewelry • " .. enumText("SI_EQUIPTYPE", equipType, "Other") end
        if isArmor then return "Armor • " .. enumText("SI_ARMORTYPE", armorType, "Other") end
    end

    local itemType, specialized = safe(GetItemLinkItemType, nil, link)
    itemType, specialized = tonumber(itemType), tonumber(specialized)
    if specialized and specialized ~= 0 then
        local textValue = cleanGroupName(enumText("SI_SPECIALIZEDITEMTYPE", specialized, ""))
        if textValue ~= "" and textValue ~= "Other" then return textValue end
    end
    if itemType and itemType ~= 0 then
        return cleanGroupName(enumText("SI_ITEMTYPE", itemType, "Other"))
    end
    return "Other"
end

function EASInventoryGrid:GetGroupName(item)
    local autoName = cleanGroupName(item and item.autoCategoryGroup or "")
    if autoName ~= "" then return autoName end
    return self:GetBuiltInGroupName(item)
end

function EASInventoryGrid:GetItemQualityRank(item)
    if not item then return 0 end
    local q = tonumber(item.displayQuality)
    if q == nil and tostring(item.link or "") ~= "" then
        local qf = GetItemLinkDisplayQuality or GetItemLinkQuality
        q = num(safe(qf, nil, item.link), nil)
    end
    return q or 0
end

function EASInventoryGrid:BuildGroups(items)
    local groups, byName = {}, {}
    for index, item in ipairs(items or {}) do
        local name = self:GetGroupName(item)
        local group = byName[name]
        if not group then
            group = { name = name, items = {} }
            byName[name] = group
            groups[#groups + 1] = group
        end
        group.items[#group.items + 1] = index
    end

    -- Keep AutoCategory / set grouping, but always order the actual item cards
    -- from highest ESO display quality to lowest quality inside each group.
    for _, group in ipairs(groups) do
        table.sort(group.items, function(aIndex, bIndex)
            local a, b = items[aIndex], items[bIndex]
            local aq, bq = self:GetItemQualityRank(a), self:GetItemQualityRank(b)
            if aq ~= bq then return aq > bq end
            local an, bn = lower(a and a.name or ""), lower(b and b.name or "")
            if an ~= bn then return an < bn end
            return tonumber(aIndex) < tonumber(bIndex)
        end)
    end
    return groups
end

function EASInventoryGrid:LayoutGroupedItems(items)
    if not self.root or not self.scrollChild then return end
    self:EnsureSaved()
    local collapsed = self:GetCollapsedGroupTable()
    local groups = self:BuildGroups(items)
    local width = num(self.root:GetWidth(), 360)
    local cellSize, gap, headerH = 44, 5, 28
    local cols = math.max(5, math.floor((width - 8) / (cellSize + gap)))
    self.columns = cols
    local y = 4
    local headerIndex = 0
    local scope = self:GetCurrentGroupScope()

    for _, group in ipairs(groups) do
        headerIndex = headerIndex + 1
        local header = self.groupHeaders[headerIndex] or self:CreateGroupHeader(headerIndex)
        local key = scope .. ":" .. tostring(group.name)
        local isCollapsed = collapsed[key] == true
        header.groupKey = key
        header:SetHidden(false)
        header:ClearAnchors()
        -- Keep the category header clear of the scroll bar so the trailing
        -- word "items" is never clipped at the right edge.
        header:SetDimensions(math.max(180, width - 28), headerH)
        header:SetAnchor(TOPLEFT, self.scrollChild, TOPLEFT, 4, y)
        header.toggleLabel:SetText(isCollapsed and "[+]" or "[-]")
        header.titleLabel:SetText(group.name)
        local itemCount = #group.items
        header.countLabel:SetText(string.format("%d %s", itemCount, itemCount == 1 and "item" or "items"))
        y = y + headerH + 4

        if isCollapsed then
            for _, itemIndex in ipairs(group.items) do
                local cell = self.cells[itemIndex]
                if cell then cell:SetHidden(true) end
            end
        else
            for pos, itemIndex in ipairs(group.items) do
                local cell = self.cells[itemIndex]
                if cell then
                    local col = (pos - 1) % cols
                    local row = math.floor((pos - 1) / cols)
                    cell:SetHidden(false)
                    cell:ClearAnchors()
                    cell:SetAnchor(TOPLEFT, self.scrollChild, TOPLEFT, 4 + col * (cellSize + gap), y + row * (cellSize + gap))
                end
            end
            local rows = math.max(1, math.ceil(#group.items / cols))
            y = y + rows * (cellSize + gap) + 4
        end
    end

    for i = headerIndex + 1, #self.groupHeaders do
        if self.groupHeaders[i] then self.groupHeaders[i]:SetHidden(true) end
    end
    for i = #(items or {}) + 1, #self.cells do
        if self.cells[i] then self.cells[i]:SetHidden(true) end
    end
    self.scrollChild:SetDimensions(width, math.max(20, y + 6))
end

function EASInventoryGrid:Create()
    if self.root or not self:ShouldEnable() then return end
    local anchor = rawget(_G, "ZO_PlayerInventoryList") or rawget(_G, "ZO_PlayerInventory")
    if not anchor then return end
    -- TopLevelWindow controls in ESO must remain parented to GuiRoot.  They can
    -- still be anchored to ZO_PlayerInventoryList, but SetParent() to the
    -- inventory control throws a hard UI error.
    local root = wm:CreateTopLevelWindow(self.name .. "Root")
    root:SetParent(GuiRoot)
    root:SetClampedToScreen(true)
    root:SetMouseEnabled(false)
    root:SetHidden(true)
    root:SetDrawLayer(DL_OVERLAY)
    root:SetDrawLevel(20)
    root:SetAnchor(TOPLEFT, anchor, TOPLEFT, 0, 0)
    root:SetAnchor(BOTTOMRIGHT, anchor, BOTTOMRIGHT, 0, 0)
    self.root = root

    local bg = wm:CreateControl(nil, root, CT_BACKDROP)
    bg:SetAnchorFill(root)
    bg:SetCenterColor(0.01, 0.02, 0.03, 0.10)
    bg:SetEdgeColor(0, 0, 0, 0)

    local scroll = wm:CreateControlFromVirtual(self.name .. "Scroll", root, "ZO_ScrollContainer")
    scroll:SetAnchorFill(root)
    self.scroll = scroll
    self.scrollChild = scroll:GetNamedChild("ScrollChild")
    if self.scrollChild then
        self.scrollChild:SetResizeToFitPadding(0, 0)
    end

    for i = 1, self.maxCells do
        self:CreateCell(i)
    end
    for i = 1, self.maxGroupHeaders do
        self:CreateGroupHeader(i)
    end

    -- Currency and Quickslots use the same Suite visual language instead of
    -- dropping back to ESO's row/radial presentation.
    local special = wm:CreateControl(nil, root, CT_CONTROL)
    special:SetAnchorFill(root)
    special:SetHidden(true)
    self.special = special

    local specialTitle = wm:CreateControl(nil, special, CT_LABEL)
    specialTitle:SetAnchor(TOPLEFT, special, TOPLEFT, 8, 6)
    specialTitle:SetDimensions(250, 28)
    specialTitle:SetFont("ZoFontWinH3")
    specialTitle:SetColor(0.94, 0.88, 0.58, 1)
    self.specialTitle = specialTitle

    local specialHint = wm:CreateControl(nil, special, CT_LABEL)
    specialHint:SetAnchor(TOPLEFT, specialTitle, BOTTOMLEFT, 0, 0)
    specialHint:SetDimensions(430, 22)
    specialHint:SetFont("ZoFontGameSmall")
    specialHint:SetColor(0.68, 0.76, 0.84, 1)
    self.specialHint = specialHint

    self.specialCells = {}
    for i = 1, 40 do
        local card = wm:CreateControl(self.name .. "SpecialCell" .. tostring(i), special, CT_BUTTON)
        card:SetDimensions(104, 74)
        card:SetMouseEnabled(true)
        card:SetHidden(true)

        local cbg = wm:CreateControl(nil, card, CT_BACKDROP)
        cbg:SetAnchorFill(card)
        cbg:SetCenterColor(0.055, 0.07, 0.09, 0.97)
        cbg:SetEdgeColor(0.28, 0.42, 0.54, 0.95)
        cbg:SetEdgeTexture("EsoUI/Art/Miscellaneous/white_1x1.dds", 1, 1, 2)
        card.bg = cbg

        local selectionFrame = wm:CreateControl(nil, card, CT_BACKDROP)
        selectionFrame:SetAnchor(TOPLEFT, card, TOPLEFT, 2, 2)
        selectionFrame:SetAnchor(BOTTOMRIGHT, card, BOTTOMRIGHT, -2, -2)
        selectionFrame:SetCenterColor(0, 0, 0, 0)
        selectionFrame:SetEdgeColor(1, 0.82, 0.28, 1)
        selectionFrame:SetEdgeTexture("EsoUI/Art/Miscellaneous/white_1x1.dds", 1, 1, 2)
        selectionFrame:SetMouseEnabled(false)
        selectionFrame:SetHidden(true)
        card.selectionFrame = selectionFrame

        local cicon = wm:CreateControl(nil, card, CT_TEXTURE)
        cicon:SetDimensions(34, 34)
        cicon:SetAnchor(TOP, card, TOP, 0, 6)
        cicon:SetTexture("EsoUI/Art/Icons/icon_missing.dds")
        cicon:SetTextureCoords(0.05, 0.95, 0.05, 0.95)
        card.icon = cicon

        local cname = wm:CreateControl(nil, card, CT_LABEL)
        cname:SetAnchor(BOTTOMLEFT, card, BOTTOMLEFT, 4, -3)
        cname:SetAnchor(BOTTOMRIGHT, card, BOTTOMRIGHT, -4, -3)
        cname:SetDimensions(96, 18)
        cname:SetFont("ZoFontGameSmall")
        cname:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        cname:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
        cname:SetColor(0.88, 0.92, 0.98, 1)
        card.nameLabel = cname

        local cvalue = wm:CreateControl(nil, card, CT_LABEL)
        cvalue:SetAnchor(TOPRIGHT, card, TOPRIGHT, -4, 3)
        cvalue:SetDimensions(62, 18)
        cvalue:SetFont("ZoFontGameSmall")
        cvalue:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        cvalue:SetColor(1, 0.93, 0.58, 1)
        card.valueLabel = cvalue

        card:SetHandler("OnMouseEnter", function(control)
            if control.specialKind == "quickslot" then self:ForceHideNativeQuickslotSurface() end
            if control.specialKind == "quickslot" and control.rarityR then
                control.bg:SetCenterColor(0.10 + control.rarityR * 0.18, 0.11 + control.rarityG * 0.18, 0.13 + control.rarityB * 0.18, 1)
            else
                control.bg:SetCenterColor(0.10, 0.13, 0.17, 1)
            end
            if InformationTooltip and type(InitializeTooltip) == "function" then
                InitializeTooltip(InformationTooltip, control, LEFT, -6, 0, RIGHT)
                InformationTooltip:AddLine(tostring(control.displayName or ""), "ZoFontWinH4")
                if control.specialKind == "currency" and control.description and control.description ~= "" then
                    InformationTooltip:AddLine(control.description, "ZoFontGameSmall")
                elseif control.specialKind == "quickslot" then
                    InformationTooltip:AddLine(control.isCurrent and "Current quickslot" or "Quickslot", "ZoFontGameSmall")
                    InformationTooltip:AddLine("Left-click: choose this slot for replacement, then open Items and left-click the item you want here.", "ZoFontGameSmall")
                    InformationTooltip:AddLine("Right-click: make this filled slot active without entering replacement mode.", "ZoFontGameSmall")
                end
            end
        end)
        card:SetHandler("OnMouseExit", function(control)
            if control.specialKind == "quickslot" and control.rarityR then
                control.bg:SetCenterColor(0.045 + control.rarityR * 0.16, 0.055 + control.rarityG * 0.16, 0.070 + control.rarityB * 0.16, 0.985)
            else
                control.bg:SetCenterColor(0.055, 0.07, 0.09, 0.97)
            end
            hideTooltip()
        end)
        card:SetHandler("OnClicked", function(control)
            if control.specialKind ~= "quickslot" or not control.slotNum then return end
            self:ForceHideNativeQuickslotSurface()
            -- Select the slot for replacement. Filled slots are also made active
            -- so the existing behavior remains useful.
            if control.slotUsed and type(SetCurrentQuickslot) == "function" then
                pcall(SetCurrentQuickslot, control.slotNum)
            end
            self:ArmQuickslotAssignment(control.slotNum, control.displayIndex)
        end)
        card:SetHandler("OnMouseUp", function(control, button, upInside)
            if not upInside or control.specialKind ~= "quickslot" or not control.slotNum then return end
            self:ForceHideNativeQuickslotSurface()
            if button == MOUSE_BUTTON_INDEX_RIGHT and control.slotUsed and type(SetCurrentQuickslot) == "function" then
                pcall(SetCurrentQuickslot, control.slotNum)
                zo_callLater(function() if self.visible then self:RefreshSpecialMode() end end, 1)
            end
        end)

        self.specialCells[i] = card
    end

    -- v0.29.249: in-place Quickslot item picker. Selecting a Quickslot no
    -- longer requires leaving this tab; valid backpack items appear below it.
    local picker = wm:CreateControl(self.name .. "QuickslotPicker", special, CT_CONTROL)
    picker:SetAnchor(TOPLEFT, special, TOPLEFT, 6, 226)
    picker:SetAnchor(BOTTOMRIGHT, special, BOTTOMRIGHT, -6, -6)
    picker:SetHidden(true)
    self.quickslotPicker = picker

    local pickerTitle = wm:CreateControl(nil, picker, CT_LABEL)
    pickerTitle:SetAnchor(TOPLEFT, picker, TOPLEFT, 2, 0)
    pickerTitle:SetDimensions(420, 24)
    pickerTitle:SetFont("ZoFontGameBold")
    pickerTitle:SetColor(1.00, 0.86, 0.34, 1)
    pickerTitle:SetText("CHOOSE AN ITEM")
    self.quickslotPickerTitle = pickerTitle

    local pickerHint = wm:CreateControl(nil, picker, CT_LABEL)
    pickerHint:SetAnchor(TOPLEFT, pickerTitle, BOTTOMLEFT, 0, 0)
    pickerHint:SetDimensions(430, 20)
    pickerHint:SetFont("ZoFontGameSmall")
    pickerHint:SetColor(0.70, 0.80, 0.88, 1)
    pickerHint:SetText("Quickslot-compatible items + Collections: Mementos, Polymorphs, Companions, Emotes and other actions ESO allows on the Quickslot wheel")

    local pickerScroll = wm:CreateControlFromVirtual(self.name .. "QuickslotPickerScroll", picker, "ZO_ScrollContainer")
    pickerScroll:SetAnchor(TOPLEFT, picker, TOPLEFT, 0, 46)
    pickerScroll:SetAnchor(BOTTOMRIGHT, picker, BOTTOMRIGHT, 0, 0)
    self.quickslotPickerScroll = pickerScroll
    self.quickslotPickerChild = pickerScroll:GetNamedChild("ScrollChild")
    if self.quickslotPickerChild then self.quickslotPickerChild:SetResizeToFitPadding(0, 0) end

    self.quickslotPickerCells = {}
    for i = 1, self.maxCells do
        local qcell = wm:CreateControl(self.name .. "QuickslotPickerCell" .. tostring(i), self.quickslotPickerChild, CT_BUTTON)
        qcell:SetDimensions(48, 48)
        qcell:SetMouseEnabled(true)
        qcell:SetHidden(true)

        local qbg = wm:CreateControl(nil, qcell, CT_BACKDROP)
        qbg:SetAnchorFill(qcell)
        qbg:SetCenterColor(0.045, 0.06, 0.08, 0.98)
        qbg:SetEdgeColor(0.30, 0.42, 0.54, 1)
        qbg:SetEdgeTexture("EsoUI/Art/Miscellaneous/white_1x1.dds", 1, 1, 2)
        qcell.bg = qbg

        local qicon = wm:CreateControl(nil, qcell, CT_TEXTURE)
        qicon:SetAnchor(TOPLEFT, qcell, TOPLEFT, 3, 3)
        qicon:SetAnchor(BOTTOMRIGHT, qcell, BOTTOMRIGHT, -3, -3)
        qicon:SetTextureCoords(0.05, 0.95, 0.05, 0.95)
        qcell.icon = qicon

        local qcount = wm:CreateControl(nil, qcell, CT_LABEL)
        qcount:SetAnchor(BOTTOMRIGHT, qcell, BOTTOMRIGHT, -2, -1)
        qcount:SetDimensions(28, 14)
        qcount:SetFont("ZoFontGameSmall")
        qcount:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        qcount:SetColor(1, 1, 1, 1)
        qcell.countLabel = qcount

        local emoteBadge = wm:CreateControl(nil, qcell, CT_LABEL)
        emoteBadge:SetAnchor(BOTTOMLEFT, qcell, BOTTOMLEFT, 3, -1)
        emoteBadge:SetDimensions(24, 14)
        emoteBadge:SetFont("$(BOLD_FONT)|11|soft-shadow-thick")
        emoteBadge:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        emoteBadge:SetColor(1, 1, 1, 0.96)
        emoteBadge:SetHidden(true)
        qcell.emoteBadgeLabel = emoteBadge

        qcell:SetHandler("OnMouseEnter", function(control)
            if control.bg then control.bg:SetCenterColor(0.10, 0.13, 0.17, 1) end
            if control.actionType then
                if InformationTooltip and type(InitializeTooltip) == "function" then
                    InitializeTooltip(InformationTooltip, control, LEFT, -6, 0, RIGHT)
                    InformationTooltip:AddLine(tostring(control.displayName or "Quickslot Action"), "ZoFontWinH4")
                    if tostring(control.description or "") ~= "" then InformationTooltip:AddLine(tostring(control.description), "ZoFontGame") end
                    if control.directUseOnly == true then
                        InformationTooltip:AddLine(tostring(control.categoryLabel or "Collection") .. " • USE / EQUIP directly", "ZoFontGameSmall")
                        InformationTooltip:AddLine("ESO does not allow this collectible on the current Quickslot wheel, so clicking it uses/equips it instead.", "ZoFontGameSmall")
                    else
                        InformationTooltip:AddLine(tostring(control.categoryLabel or "Collection") .. " • Quickslot compatible", "ZoFontGameSmall")
                    end
                end
            elseif ItemTooltip and type(InitializeTooltip) == "function" and control.bagId ~= nil and control.slotIndex ~= nil then
                InitializeTooltip(ItemTooltip, control, LEFT, -6, 0, RIGHT)
                if type(ItemTooltip.SetBagItem) == "function" then pcall(ItemTooltip.SetBagItem, ItemTooltip, control.bagId, control.slotIndex) end
            end
        end)
        qcell:SetHandler("OnMouseExit", function(control)
            if control.bg then
                local r,g,b = control.qualityR or 0.3, control.qualityG or 0.42, control.qualityB or 0.54
                control.bg:SetCenterColor(0.045 + r * 0.12, 0.055 + g * 0.12, 0.070 + b * 0.12, 0.98)
            end
            hideTooltip()
        end)
        qcell:SetHandler("OnClicked", function(control)
            if self:AssignPickerEntryToSelectedQuickslot(control) then
                zo_callLater(function()
                    if self.visible then
                        self:RefreshQuickslotPanel()
                        self:RefreshQuickslotPicker()
                    end
                end, 25)
            end
        end)
        self.quickslotPickerCells[i] = qcell
    end
end

function EASInventoryGrid:GetCurrentInventoryMode()
    -- Fragment visibility is the most reliable signal while the top menu is
    -- transitioning.  Check it before the mode bar so a stale previous mode
    -- can never leave the Suite grid over Currency or Quickslots.
    local function showing(fragment)
        return fragment and type(fragment.IsShowing) == "function" and fragment:IsShowing()
    end
    if showing(rawget(_G, "CRAFT_BAG_FRAGMENT")) then return rawget(_G, "SI_INVENTORY_MODE_CRAFT_BAG") or "craftBag" end
    if showing(rawget(_G, "QUEST_ITEMS_FRAGMENT")) then return rawget(_G, "SI_INVENTORY_MODE_QUEST_ITEMS") or "quest" end
    if showing(rawget(_G, "WALLET_FRAGMENT")) then return rawget(_G, "SI_INVENTORY_MODE_CURRENCY") or "wallet" end
    if showing(rawget(_G, "KEYBOARD_QUICKSLOT_FRAGMENT")) or showing(rawget(_G, "KEYBOARD_QUICKSLOT_CIRCLE_FRAGMENT")) then
        return rawget(_G, "SI_INVENTORY_MODE_QUICKSLOTS") or "quickslot"
    end
    if showing(rawget(_G, "INVENTORY_FRAGMENT")) then return rawget(_G, "SI_INVENTORY_MODE_ITEMS") or "inventory" end

    -- Fallback to ESO's mode bar descriptor outside the fragment transition.
    local bar = rawget(_G, "INVENTORY_MENU_BAR")
    if type(bar) == "table" and type(bar.modeBar) == "table" and type(bar.modeBar.GetLastFragment) == "function" then
        local ok, fragmentId = pcall(bar.modeBar.GetLastFragment, bar.modeBar)
        if ok then return fragmentId end
    end
    return nil
end

function EASInventoryGrid:GetFragmentControl(fragment)
    if not fragment then return nil end
    if type(fragment.GetControl) == "function" then
        local ok, control = pcall(fragment.GetControl, fragment)
        if ok and control then return control end
    end
    return fragment.control
end

function EASInventoryGrid:SetNativeSpecialPanelHidden(kind, hidden)
    self.specialNativeState = self.specialNativeState or {}
    local fragment = kind == "currency" and rawget(_G, "WALLET_FRAGMENT") or (rawget(_G, "KEYBOARD_QUICKSLOT_FRAGMENT") or rawget(_G, "KEYBOARD_QUICKSLOT_CIRCLE_FRAGMENT"))
    local control = self:GetFragmentControl(fragment)
    if not control then return end

    -- v0.29.264: alpha alone is not enough for ESO's Quickslot panel. Its native
    -- hover/highlight code can momentarily drive child controls visible again,
    -- which causes the one-frame flash behind the Suite cards. Keep the fragment
    -- control actually HIDDEN for the whole Suite inventory scene, while leaving
    -- ESO's underlying quickslot/currency data APIs untouched.
    if hidden == false and self.visible then return end

    local state = self.specialNativeState[kind]
    if hidden then
        if not state then
            state = { control = control }
            if type(control.GetAlpha) == "function" then state.alpha = control:GetAlpha() end
            if type(control.IsMouseEnabled) == "function" then state.mouse = control:IsMouseEnabled() end
            if type(control.IsHidden) == "function" then state.hidden = control:IsHidden() end
            self.specialNativeState[kind] = state
        end
        if type(control.SetMouseEnabled) == "function" then pcall(control.SetMouseEnabled, control, false) end
        if type(control.SetAlpha) == "function" then pcall(control.SetAlpha, control, 0) end
        if type(control.SetHidden) == "function" then pcall(control.SetHidden, control, true) end
    elseif state and state.control then
        local c = state.control
        if type(c.SetHidden) == "function" then pcall(c.SetHidden, c, state.hidden == true) end
        if type(c.SetAlpha) == "function" then pcall(c.SetAlpha, c, state.alpha ~= nil and state.alpha or 1) end
        if state.mouse ~= nil and type(c.SetMouseEnabled) == "function" then pcall(c.SetMouseEnabled, c, state.mouse) end
        self.specialNativeState[kind] = nil
    end
end

function EASInventoryGrid:ForceHideNativeQuickslotSurface()
    if not self.visible then return end
    self:SetNativeSpecialPanelHidden("quickslot", true)

    -- Some ESO builds expose both keyboard quickslot fragments at once. Hide
    -- both explicit fragment controls so moving the mouse over a Suite card can
    -- never wake the alternate native circle for a frame.
    for _, fragment in ipairs({ rawget(_G, "KEYBOARD_QUICKSLOT_FRAGMENT"), rawget(_G, "KEYBOARD_QUICKSLOT_CIRCLE_FRAGMENT") }) do
        local c = self:GetFragmentControl(fragment)
        if c then
            if type(c.SetMouseEnabled) == "function" then pcall(c.SetMouseEnabled, c, false) end
            if type(c.SetAlpha) == "function" then pcall(c.SetAlpha, c, 0) end
            if type(c.SetHidden) == "function" then pcall(c.SetHidden, c, true) end
        end
    end
end

function EASInventoryGrid:AnchorRootToInventoryArea()
    if not self.root then return end
    local anchor = rawget(_G, "ZO_PlayerInventoryList") or rawget(_G, "ZO_PlayerInventory")
    if anchor then
        self.root:ClearAnchors()
        self.root:SetAnchor(TOPLEFT, anchor, TOPLEFT, 0, 0)
        self.root:SetAnchor(BOTTOMRIGHT, anchor, BOTTOMRIGHT, 0, 0)
    end
end

function EASInventoryGrid:LayoutSpecialCells(count)
    if not self.special or not self.specialCells then return end
    local width = num(self.root and self.root:GetWidth(), 440)
    local cardW, cardH, gap = 104, 74, 6
    local cols = math.max(3, math.floor((width - 12) / (cardW + gap)))
    for i, card in ipairs(self.specialCells) do
        if i <= count then
            local col = (i - 1) % cols
            local row = math.floor((i - 1) / cols)
            card:ClearAnchors()
            card:SetAnchor(TOPLEFT, self.special, TOPLEFT, 6 + col * (cardW + gap), 56 + row * (cardH + gap))
        end
    end
end

function EASInventoryGrid:CollectCurrencies()
    local result, seen = {}, {}
    if type(IsCurrencyValid) ~= "function" or type(GetCurrencyAmount) ~= "function" then return result end

    -- v0.29.246: NEVER iterate pairs(_G) here. ESO's global table contains
    -- private/protected functions and merely walking those entries from addon
    -- code can taint the call stack. CurrencyType is a compact numeric enum, so
    -- probe only numeric IDs through the public IsCurrencyValid() API.
    local maxCurrencyType = tonumber(rawget(_G, "CURT_MAX_VALUE")) or 64
    maxCurrencyType = math.max(32, math.min(256, maxCurrencyType + 8))

    local function addCurrency(currencyType)
        currencyType = tonumber(currencyType)
        if not currencyType or currencyType <= 0 or seen[currencyType] then return end
        seen[currencyType] = true
        if safe(IsCurrencyValid, false, currencyType) ~= true then return end

        local location = safe(GetCurrencyPlayerStoredLocation, nil, currencyType)
        local amount = nil
        if location ~= nil then amount = safe(GetCurrencyAmount, nil, currencyType, location) end
        if amount == nil then
            local candidates = { rawget(_G, "CURRENCY_LOCATION_CHARACTER"), rawget(_G, "CURRENCY_LOCATION_ACCOUNT") }
            for _, loc in ipairs(candidates) do
                if loc ~= nil then
                    local v = safe(GetCurrencyAmount, nil, currencyType, loc)
                    if v ~= nil and (amount == nil or tonumber(v) > tonumber(amount)) then amount, location = v, loc end
                end
            end
        end
        amount = tonumber(amount) or 0
        local name = tostring(safe(GetCurrencyName, "Currency", currencyType, amount == 1, false) or "Currency")
        local icon = ""
        if type(ZO_Currency_GetPlatformCurrencyIcon) == "function" then icon = tostring(safe(ZO_Currency_GetPlatformCurrencyIcon, "", currencyType) or "") end
        if icon == "" and type(GetCurrencyKeyboardIcon) == "function" then icon = tostring(safe(GetCurrencyKeyboardIcon, "", currencyType) or "") end
        local r, g, b = 0.90, 0.82, 0.48
        if type(GetCurrencyKeyboardColor) == "function" then
            local cr, cg, cb = safe(GetCurrencyKeyboardColor, nil, currencyType)
            if cr ~= nil then r, g, b = cr, cg, cb end
        end
        result[#result + 1] = {
            currencyType = currencyType, location = location, amount = amount, name = name, icon = icon,
            description = tostring(safe(GetCurrencyDescription, "", currencyType) or ""), r = r, g = g, b = b,
        }
    end

    for currencyType = 1, maxCurrencyType do addCurrency(currencyType) end

    -- Explicitly include commonly exposed enum constants in case a future API
    -- places a valid currency above CURT_MAX_VALUE during a transition build.
    local known = {
        "CURT_MONEY", "CURT_ALLIANCE_POINTS", "CURT_TELVAR_STONES", "CURT_WRIT_VOUCHERS",
        "CURT_CHAOTIC_CREATIA", "CURT_CROWN_GEMS", "CURT_EVENT_TICKETS", "CURT_UNDAUNTED_KEYS",
        "CURT_CROWNS", "CURT_OUTFIT_STYLE_STONES", "CURT_ENDEAVOR_SEALS", "CURT_ARCHIVAL_FORTUNES"
    }
    for _, constantName in ipairs(known) do addCurrency(rawget(_G, constantName)) end

    table.sort(result, function(a, b)
        if (a.amount > 0) ~= (b.amount > 0) then return a.amount > 0 end
        return lower(a.name) < lower(b.name)
    end)
    return result
end

function EASInventoryGrid:HideQuickslotPicker(clearSelection)
    if clearSelection then
        self.quickslotAssignTarget = nil
        self.quickslotAssignIndex = nil
    end
    if self.quickslotPicker then self.quickslotPicker:SetHidden(true) end
    if type(self.quickslotPickerCells) == "table" then
        for _, cell in ipairs(self.quickslotPickerCells) do
            if cell then
                cell:SetHidden(true)
                cell.bagId, cell.slotIndex, cell.link, cell.collectibleId, cell.emoteId, cell.actionType, cell.actionId, cell.categoryLabel, cell.displayName, cell.description = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
            cell.directUseOnly, cell.quickslotCompatible, cell.nativeEmote = nil, nil, nil
            if cell.emoteBadgeLabel then cell.emoteBadgeLabel:SetHidden(true); cell.emoteBadgeLabel:SetText("") end
            end
        end
    end
    if self.quickslotPickerEmpty then self.quickslotPickerEmpty:SetHidden(true) end
end

function EASInventoryGrid:RefreshCurrencyPanel()
    -- Leaving Quickslots must fully tear down its picker AND clear every
    -- Quickslot-only visual state. The special cards are intentionally reused
    -- between tabs, so rarity tints/selection frames must not carry into Currency.
    self:HideQuickslotPicker(true)
    local currencies = self:CollectCurrencies()
    self.specialTitle:SetText("CURRENCY")
    self.specialHint:SetText("Your character and account currencies")
    self:LayoutSpecialCells(math.min(#currencies, #self.specialCells))
    for i, card in ipairs(self.specialCells) do
        local data = currencies[i]

        -- Reset reused Quickslot styling before drawing Currency.
        card.rarityR, card.rarityG, card.rarityB = nil, nil, nil
        card.slotNum, card.slotUsed, card.isCurrent, card.displayIndex = nil, nil, nil, nil
        if card.selectionFrame then card.selectionFrame:SetHidden(true) end
        if card.bg then
            card.bg:SetCenterColor(0.055, 0.07, 0.09, 0.97)
            card.bg:SetEdgeColor(0.22, 0.28, 0.34, 0.95)
        end

        card:SetHidden(data == nil)
        if data then
            card.specialKind = "currency"
            card.displayName = data.name
            card.description = data.description
            card.icon:SetTexture(data.icon ~= "" and data.icon or "EsoUI/Art/Icons/icon_missing.dds")
            card.nameLabel:SetText(data.name)
            card.valueLabel:SetText(formatNumber(data.amount))
            card.valueLabel:SetColor(data.r or 1, data.g or 1, data.b or 1, 1)

            -- Currency keeps a clean neutral card; only the thin border/value
            -- uses ESO's currency color. No item-rarity background survives.
            local r, g, b = data.r or 0.5, data.g or 0.5, data.b or 0.5
            card.bg:SetCenterColor(0.055, 0.07, 0.09, 0.97)
            card.bg:SetEdgeColor(r, g, b, 0.90)
        else
            card.specialKind = nil
            card.displayName, card.description = nil, nil
        end
    end
end

function EASInventoryGrid:GetQuickslotSlotIndices()
    local category = rawget(_G, "HOTBAR_CATEGORY_QUICKSLOT_WHEEL")
    if category == nil then return {} end

    -- API 101050 uses wheel-local action slot indices. Older ESO builds/addons
    -- used the legacy 9..16 range, so do not hard-code either layout. Ask ESO
    -- which slots are mutable for the Quickslot wheel and fall back from the
    -- current Quickslot value only if that query is unavailable.
    local slots = {}
    if type(IsActionSlotMutable) == "function" then
        for slotIndex = 1, 32 do
            if safe(IsActionSlotMutable, false, slotIndex, category) == true then
                slots[#slots + 1] = slotIndex
                if #slots >= 8 then break end
            end
        end
    end

    if #slots < 8 then
        slots = {}
        local current = type(GetCurrentQuickslot) == "function" and num(safe(GetCurrentQuickslot, nil), nil) or nil
        local first = (current and current >= 9) and 9 or 1
        for i = 0, 7 do slots[#slots + 1] = first + i end
    end
    return slots
end

function EASInventoryGrid:GetQuickslotQualityByNameIcon(name, icon)
    local bag = rawget(_G, "BAG_BACKPACK") or 1
    if type(GetBagSize) ~= "function" then return 0, "" end
    local targetName = lower(name)
    local targetIcon = tostring(icon or "")
    local size = num(safe(GetBagSize, 0, bag), 0)
    local bestQuality, bestLink = 0, ""
    for slotIndex = 0, size - 1 do
        local link = tostring(safe(GetItemLink, "", bag, slotIndex, LINK_STYLE_DEFAULT or 0) or "")
        if link ~= "" then
            local itemName = tostring(safe(GetItemLinkName, "", link) or safe(GetItemName, "", bag, slotIndex) or "")
            local itemIcon = tostring(safe(GetItemLinkIcon, "", link) or "")
            if (targetName ~= "" and lower(itemName) == targetName) or (targetIcon ~= "" and itemIcon == targetIcon) then
                local q = num(safe(GetItemDisplayQuality, nil, bag, slotIndex), nil)
                if q == nil then
                    local qf = GetItemLinkDisplayQuality or GetItemLinkQuality
                    q = num(safe(qf, 0, link), 0)
                end
                q = q or 0
                if q > bestQuality then
                    bestQuality, bestLink = q, link
                end
            end
        end
    end
    return bestQuality, bestLink
end

function EASInventoryGrid:CollectQuickslots()
    local result = {}
    local category = rawget(_G, "HOTBAR_CATEGORY_QUICKSLOT_WHEEL")
    if category == nil then return result end
    local slots = self:GetQuickslotSlotIndices()
    local current = type(GetCurrentQuickslot) == "function" and num(safe(GetCurrentQuickslot, nil), nil) or nil
    for i, slotNum in ipairs(slots) do
        local actionType = num(safe(GetSlotType, 0, slotNum, category), 0)
        local used = actionType ~= (rawget(_G, "ACTION_TYPE_NOTHING") or 0)
        local name = used and tostring(safe(GetSlotName, "Quickslot " .. tostring(i), slotNum, category) or ("Quickslot " .. tostring(i))) or ("Empty Slot " .. tostring(i))
        local icon = used and tostring(safe(GetSlotTexture, "", slotNum, category) or "") or tostring(rawget(_G, "ZO_UTILITY_SLOT_EMPTY_TEXTURE") or "EsoUI/Art/Quickslots/quickslot_emptySlot.dds")
        local count = used and num(safe(GetSlotItemCount, 0, slotNum, category), 0) or 0
        local displayQuality, itemLink = 0, ""
        if used then displayQuality, itemLink = self:GetQuickslotQualityByNameIcon(name, icon) end
        result[#result + 1] = { slotNum=slotNum, index=i, actionType=actionType, used=used, name=name, icon=icon, count=count or 0, current=current == slotNum, displayQuality=displayQuality or 0, itemLink=itemLink or "" }
    end
    return result
end

function EASInventoryGrid:GetCollectionCategoryLabel(categoryType)
    local labels = {}
    local function add(globalName, label)
        local value = rawget(_G, globalName)
        if value ~= nil then labels[value] = label end
    end
    add("COLLECTIBLE_CATEGORY_TYPE_MEMENTO", "Memento")
    add("COLLECTIBLE_CATEGORY_TYPE_POLYMORPH", "Polymorph")
    add("COLLECTIBLE_CATEGORY_TYPE_COMPANION", "Companion")
    add("COLLECTIBLE_CATEGORY_TYPE_ASSISTANT", "Assistant")
    add("COLLECTIBLE_CATEGORY_TYPE_MOUNT", "Mount")
    add("COLLECTIBLE_CATEGORY_TYPE_VANITY_PET", "Non-Combat Pet")
    add("COLLECTIBLE_CATEGORY_TYPE_COSTUME", "Costume")
    add("COLLECTIBLE_CATEGORY_TYPE_HAT", "Hat")
    add("COLLECTIBLE_CATEGORY_TYPE_PERSONALITY", "Personality")
    add("COLLECTIBLE_CATEGORY_TYPE_SKIN", "Skin")
    add("COLLECTIBLE_CATEGORY_TYPE_EMOTE", "Collected Emote")
    add("COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING", "Body Marking")
    add("COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING", "Head Marking")
    add("COLLECTIBLE_CATEGORY_TYPE_HAIR", "Hair")
    add("COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS", "Facial Hair / Horns")
    add("COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY", "Facial Accessory")
    add("COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY", "Adornment")
    return labels[categoryType] or "Collection"
end

function EASInventoryGrid:IsDirectUseCollectionCategory(categoryType)
    local allowed = {}
    local function add(name)
        local v = rawget(_G, name)
        if v ~= nil then allowed[v] = true end
    end
    -- Collection entries the player can equip/use even when ESO does not allow
    -- them to be placed on the current Utility Quickslot wheel.
    add("COLLECTIBLE_CATEGORY_TYPE_COSTUME")
    add("COLLECTIBLE_CATEGORY_TYPE_ASSISTANT")
    add("COLLECTIBLE_CATEGORY_TYPE_COMPANION")
    add("COLLECTIBLE_CATEGORY_TYPE_MEMENTO")
    add("COLLECTIBLE_CATEGORY_TYPE_POLYMORPH")
    add("COLLECTIBLE_CATEGORY_TYPE_HAT")
    add("COLLECTIBLE_CATEGORY_TYPE_PERSONALITY")
    add("COLLECTIBLE_CATEGORY_TYPE_SKIN")
    add("COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING")
    add("COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING")
    add("COLLECTIBLE_CATEGORY_TYPE_HAIR")
    add("COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS")
    add("COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY")
    add("COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY")
    add("COLLECTIBLE_CATEGORY_TYPE_MOUNT")
    add("COLLECTIBLE_CATEGORY_TYPE_VANITY_PET")
    return allowed[categoryType] == true
end

function EASInventoryGrid:UseCollectibleFromPicker(control)
    local collectibleId = tonumber(control and (control.collectibleId or control.actionId))
    if not collectibleId or collectibleId <= 0 then return false end

    -- Use the protected path first so appearance/assistant actions do not taint
    -- ESO's protected UI. This covers costumes, markings, assistants,
    -- polymorphs, companions, mounts, pets and similar usable Collections.
    local sent = false
    if type(CallSecureProtected) == "function" then
        local ok = pcall(CallSecureProtected, "UseCollectible", collectibleId)
        sent = ok == true
    elseif type(UseCollectible) == "function" then
        -- Older API fallback only.
        local ok = pcall(UseCollectible, collectibleId)
        sent = ok == true
    end

    if ESOProgressionCoach and type(ESOProgressionCoach.Print) == "function" then
        if sent then
            ESOProgressionCoach:Print("Collection action used: " .. tostring(control.displayName or "Collectible"))
        else
            ESOProgressionCoach:Print("ESO did not allow that Collection action right now.")
        end
    end
    if sent then self:RefreshSoon() end
    return true
end

function EASInventoryGrid:IsCollectibleValidForAnyQuickslot(collectibleId)
    collectibleId = tonumber(collectibleId)
    local category = rawget(_G, "HOTBAR_CATEGORY_QUICKSLOT_WHEEL")
    if not collectibleId or collectibleId <= 0 or category == nil then return false end

    -- This is the authoritative test for the Utility/Quickslot wheel.  Do not
    -- reject a collectible just because IsCollectibleSlottable() says false;
    -- that helper excludes some collection types that ESO itself still accepts
    -- as simple actions on the utility wheel (polymorphs, mementos, companions,
    -- assistants, etc.).
    if type(IsValidCollectibleForSlot) == "function" then
        for _, wheelSlot in ipairs(self:GetQuickslotSlotIndices()) do
            if safe(IsValidCollectibleForSlot, false, collectibleId, wheelSlot, category) == true then
                return true
            end
        end
    end

    local actionType = rawget(_G, "ACTION_TYPE_COLLECTIBLE")
    if actionType ~= nil then
        if type(FindActionSlotMatchingSimpleAction) == "function" then
            local existing = safe(FindActionSlotMatchingSimpleAction, nil, actionType, collectibleId, category)
            if existing ~= nil then return true end
        end
        if type(GetFirstFreeValidSlotForSimpleAction) == "function" then
            local free = safe(GetFirstFreeValidSlotForSimpleAction, nil, actionType, collectibleId, category)
            if free ~= nil then return true end
        end
    end
    return false
end

function EASInventoryGrid:IsExcludedQuickslotCollectionCategory(categoryType)
    local blocked = {}
    local function add(name)
        local v = rawget(_G, name)
        if v ~= nil then blocked[v] = true end
    end
    -- These are appearance/service Collections, not things the user wants in
    -- the Quickslot picker. Assistants are intentionally excluded as requested.
    add("COLLECTIBLE_CATEGORY_TYPE_COSTUME")
    add("COLLECTIBLE_CATEGORY_TYPE_ASSISTANT")
    add("COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING")
    add("COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING")
    add("COLLECTIBLE_CATEGORY_TYPE_HAT")
    add("COLLECTIBLE_CATEGORY_TYPE_PERSONALITY")
    add("COLLECTIBLE_CATEGORY_TYPE_SKIN")
    add("COLLECTIBLE_CATEGORY_TYPE_HAIR")
    add("COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS")
    add("COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY")
    add("COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY")
    return blocked[categoryType] == true
end

function EASInventoryGrid:CollectQuickslotCollectibles()
    if type(self.quickslotCollectibleCache) == "table" then return self.quickslotCollectibleCache end
    local result, seen = {}, {}
    local actionType = rawget(_G, "ACTION_TYPE_COLLECTIBLE")
    if actionType == nil then
        self.quickslotCollectibleCache = result
        return result
    end

    local function addCollectible(collectibleId)
        collectibleId = tonumber(collectibleId)
        if not collectibleId or collectibleId <= 0 or seen[collectibleId] then return end
        seen[collectibleId] = true

        local unlocked = type(IsCollectibleUnlocked) ~= "function" or safe(IsCollectibleUnlocked, false, collectibleId) == true
        if not unlocked then return end
        if type(IsCollectibleValidForPlayer) == "function" and safe(IsCollectibleValidForPlayer, false, collectibleId) ~= true then return end

        local categoryType = type(GetCollectibleCategoryType) == "function" and safe(GetCollectibleCategoryType, nil, collectibleId) or nil
        if self:IsExcludedQuickslotCollectionCategory(categoryType) then return end

        -- Only show Collections that can actually be placed on the Quickslot wheel.
        -- Do not use the previous direct-use fallback; appearance/service entries
        -- such as costumes, markings, hats/skins and assistants do not belong here.
        local quickslotCompatible = self:IsCollectibleValidForAnyQuickslot(collectibleId)
        if not quickslotCompatible then return end
        local directUseOnly = false

        local name = type(GetCollectibleName) == "function" and tostring(safe(GetCollectibleName, "", collectibleId) or "") or ""
        local description, icon, hint = "", "", ""
        if type(GetCollectibleInfo) == "function" then
            local a,b,c,d,e,f,g,h,i = safe(GetCollectibleInfo, nil, collectibleId)
            if name == "" then name = tostring(a or "") end
            description = tostring(b or "")
            icon = tostring(c or "")
            hint = tostring(i or "")
        end
        local link = type(GetCollectibleLink) == "function" and tostring(safe(GetCollectibleLink, "", collectibleId, LINK_STYLE_DEFAULT or 0) or "") or ""

        result[#result + 1] = {
            kind = "collectible",
            actionType = actionType,
            actionId = collectibleId,
            collectibleId = collectibleId,
            link = link,
            name = name ~= "" and name or "Collection Item",
            description = description ~= "" and description or hint,
            icon = icon,
            stack = 1,
            displayQuality = 0,
            categoryType = categoryType,
            categoryLabel = self:GetCollectionCategoryLabel(categoryType),
            quickslotCompatible = quickslotCompatible == true,
            directUseOnly = directUseOnly == true,
        }
    end

    -- Walk the Collections book so we get owned polymorphs, mementos,
    -- companions and all other actual Quickslot-compatible collectibles. Appearance/service categories are filtered out.
    if type(GetNumCollectibleCategories) == "function" and type(GetCollectibleId) == "function" then
        local topCount = num(safe(GetNumCollectibleCategories, 0), 0)
        for topIndex = 1, topCount do
            local _, numSubCategories, numCollectibles = safe(GetCollectibleCategoryInfo, nil, topIndex)
            numSubCategories = num(numSubCategories, 0)
            numCollectibles = num(numCollectibles, 0)
            for collectibleIndex = 1, numCollectibles do
                addCollectible(safe(GetCollectibleId, nil, topIndex, nil, collectibleIndex))
            end
            for subIndex = 1, numSubCategories do
                local _, subCollectibleCount = safe(GetCollectibleSubCategoryInfo, nil, topIndex, subIndex)
                subCollectibleCount = num(subCollectibleCount, 0)
                for collectibleIndex = 1, subCollectibleCount do
                    addCollectible(safe(GetCollectibleId, nil, topIndex, subIndex, collectibleIndex))
                end
            end
        end
    end

    table.sort(result, function(a, b)
        local ac, bc = lower(a.categoryLabel), lower(b.categoryLabel)
        if ac ~= bc then return ac < bc end
        return lower(a.name) < lower(b.name)
    end)
    self.quickslotCollectibleCache = result
    return result
end

function EASInventoryGrid:IsEmoteValidForAnyQuickslot(emoteId)
    emoteId = tonumber(emoteId)
    local category = rawget(_G, "HOTBAR_CATEGORY_QUICKSLOT_WHEEL")
    if not emoteId or emoteId <= 0 or category == nil then return false end
    if type(IsValidEmoteForSlot) == "function" then
        for _, wheelSlot in ipairs(self:GetQuickslotSlotIndices()) do
            if safe(IsValidEmoteForSlot, false, emoteId, wheelSlot, category) == true then return true end
        end
    end
    local actionType = rawget(_G, "ACTION_TYPE_EMOTE")
    if actionType ~= nil then
        if type(FindActionSlotMatchingSimpleAction) == "function" then
            local existing = safe(FindActionSlotMatchingSimpleAction, nil, actionType, emoteId, category)
            if existing ~= nil then return true end
        end
        if type(GetFirstFreeValidSlotForSimpleAction) == "function" then
            local free = safe(GetFirstFreeValidSlotForSimpleAction, nil, actionType, emoteId, category)
            if free ~= nil then return true end
        end
    end
    return false
end

function EASInventoryGrid:CollectQuickslotEmotes()
    if type(self.quickslotEmoteCache) == "table" then return self.quickslotEmoteCache end
    local result = {}
    local actionType = rawget(_G, "ACTION_TYPE_EMOTE")
    if actionType == nil or type(GetNumEmotes) ~= "function" or type(GetEmoteInfo) ~= "function" then
        self.quickslotEmoteCache = result
        return result
    end

    local count = num(safe(GetNumEmotes, 0), 0)
    for emoteIndex = 1, count do
        local slashName, emoteCategory, emoteId, displayName, showInGamepadUI = safe(GetEmoteInfo, nil, emoteIndex)
        emoteId = tonumber(emoteId)
        if emoteId and emoteId > 0 and self:IsEmoteValidForAnyQuickslot(emoteId) then
            local collectibleId = nil
            if type(GetEmoteCollectibleId) == "function" then
                local rawCollectibleId = safe(GetEmoteCollectibleId, nil, emoteIndex)
                collectibleId = tonumber(rawCollectibleId)
            end
            local unlocked = true
            if collectibleId and collectibleId > 0 and type(IsCollectibleUnlocked) == "function" then
                unlocked = safe(IsCollectibleUnlocked, false, collectibleId) == true
            end
            if unlocked then
                local icon = NATIVE_EMOTE_FALLBACK_ICON
                local nativeEmote = not collectibleId or collectibleId <= 0
                if collectibleId and collectibleId > 0 and type(GetCollectibleInfo) == "function" then
                    local _,_,collectibleIcon = safe(GetCollectibleInfo, nil, collectibleId)
                    collectibleIcon = tostring(collectibleIcon or "")
                    if collectibleIcon ~= "" and collectibleIcon ~= "ZO_NO_TEXTURE_FILE" then
                        icon = collectibleIcon
                        nativeEmote = false
                    end
                end
                local name = tostring(displayName or "")
                if name == "" then
                    name = tostring(slashName or "Emote"):gsub("^/", "")
                end
                result[#result + 1] = {
                    kind = "emote",
                    actionType = actionType,
                    actionId = emoteId,
                    emoteId = emoteId,
                    emoteIndex = emoteIndex,
                    collectibleId = collectibleId,
                    nativeEmote = nativeEmote,
                    emoteBadge = nativeEmote and emoteBadgeText(name, slashName) or "",
                    name = zo_strformat("<<C:1>>", name),
                    description = tostring(slashName or ""),
                    icon = icon,
                    stack = 1,
                    displayQuality = 0,
                    categoryLabel = nativeEmote and "ESO Emote" or "Collected Emote",
                }
            end
        end
    end

    table.sort(result, function(a, b) return lower(a.name) < lower(b.name) end)
    self.quickslotEmoteCache = result
    return result
end

function EASInventoryGrid:CollectQuickslotPickerItems()
    local result = {}
    local target = tonumber(self.quickslotAssignTarget)
    local category = rawget(_G, "HOTBAR_CATEGORY_QUICKSLOT_WHEEL")
    if not target or category == nil then return result end

    local bag = rawget(_G, "BAG_BACKPACK") or 1
    local wheelSlots = self:GetQuickslotSlotIndices()

    local function canQuickslotItem(slotIndex)
        if type(IsValidItemForSlot) == "function" then
            for _, wheelSlot in ipairs(wheelSlots) do
                if safe(IsValidItemForSlot, false, bag, slotIndex, wheelSlot, category) == true then return true end
            end
        end
        if type(FindActionSlotMatchingItem) == "function" then
            local existing = safe(FindActionSlotMatchingItem, nil, bag, slotIndex, category)
            if existing ~= nil then return true end
        end
        if type(IsValidItemForSlot) ~= "function" and type(GetFirstFreeValidSlotForItem) == "function" then
            local free = safe(GetFirstFreeValidSlotForItem, nil, bag, slotIndex, category)
            if free ~= nil then return true end
        end
        return false
    end

    if type(GetBagSize) == "function" then
        local size = num(safe(GetBagSize, 0, bag), 0)
        for slotIndex = 0, size - 1 do
            local link = tostring(safe(GetItemLink, "", bag, slotIndex, LINK_STYLE_DEFAULT or 0) or "")
            if link ~= "" and canQuickslotItem(slotIndex) then
                local q = num(safe(GetItemDisplayQuality, nil, bag, slotIndex), nil)
                if q == nil then
                    local qf = GetItemLinkDisplayQuality or GetItemLinkQuality
                    q = num(safe(qf, 0, link), 0)
                end
                result[#result + 1] = {
                    kind = "item",
                    bagId = bag,
                    slotIndex = slotIndex,
                    link = link,
                    name = tostring(safe(GetItemLinkName, "", link) or safe(GetItemName, "Item", bag, slotIndex) or "Item"),
                    icon = tostring(safe(GetItemLinkIcon, "", link) or ""),
                    stack = num(safe(GetSlotStackSize, 1, bag, slotIndex), 1),
                    displayQuality = q or 0,
                }
            end
        end
    end

    for _, collectible in ipairs(self:CollectQuickslotCollectibles()) do result[#result + 1] = collectible end
    for _, emote in ipairs(self:CollectQuickslotEmotes()) do result[#result + 1] = emote end

    table.sort(result, function(a, b)
        if (a.displayQuality or 0) ~= (b.displayQuality or 0) then return (a.displayQuality or 0) > (b.displayQuality or 0) end
        if a.kind ~= b.kind then
            local order = { item = 1, collectible = 2, emote = 3 }
            return (order[a.kind] or 9) < (order[b.kind] or 9)
        end
        local an, bn = lower(a.name), lower(b.name)
        if an ~= bn then return an < bn end
        return (a.slotIndex or a.collectibleId or 0) < (b.slotIndex or b.collectibleId or 0)
    end)
    return result
end

function EASInventoryGrid:RefreshQuickslotPicker()
    if not self.quickslotPicker or not self.quickslotPickerCells then return end
    local target = tonumber(self.quickslotAssignTarget)
    if not target then
        self.quickslotPicker:SetHidden(true)
        for _, cell in ipairs(self.quickslotPickerCells) do cell:SetHidden(true) end
        return
    end

    self.quickslotPicker:SetHidden(false)
    local displayIndex = tonumber(self.quickslotAssignIndex) or target
    self.quickslotPickerTitle:SetText(string.format("CHOOSE ITEM FOR QUICKSLOT %s", tostring(displayIndex)))
    local items = self:CollectQuickslotPickerItems()
    if self.quickslotPickerEmpty then
        self.quickslotPickerEmpty:SetHidden(#items > 0)
        if #items == 0 then
            self.quickslotPickerEmpty:SetText("No Quickslot-compatible items or usable Collection/Emote actions were found.")
        end
    end
    local width = tonumber(self.quickslotPicker:GetWidth()) or 440
    local cellSize, gap = 48, 5
    local cols = math.max(5, math.floor((width - 4) / (cellSize + gap)))
    local rows = math.max(1, math.ceil(#items / cols))
    if self.quickslotPickerChild then self.quickslotPickerChild:SetDimensions(width, rows * (cellSize + gap) + 4) end

    for i, cell in ipairs(self.quickslotPickerCells) do
        local item = items[i]
        cell:SetHidden(item == nil)
        if item then
            local col = (i - 1) % cols
            local row = math.floor((i - 1) / cols)
            cell:ClearAnchors()
            cell:SetAnchor(TOPLEFT, self.quickslotPickerChild, TOPLEFT, 2 + col * (cellSize + gap), 2 + row * (cellSize + gap))
            cell.bagId, cell.slotIndex, cell.link = item.bagId, item.slotIndex, item.link
            cell.collectibleId = item.collectibleId
            cell.emoteId = item.emoteId
            cell.actionType = item.actionType
            cell.actionId = item.actionId
            cell.categoryLabel = item.categoryLabel
            cell.displayName = item.name
            cell.description = item.description
            cell.directUseOnly = item.directUseOnly == true
            cell.quickslotCompatible = item.quickslotCompatible == true
            cell.nativeEmote = item.nativeEmote == true
            cell.icon:SetHidden(false)
            cell.icon:SetColor(1, 1, 1, 1)
            if cell.icon.SetAlpha then cell.icon:SetAlpha(1) end
            cell.icon:SetTexture(tostring(item.icon or "") ~= "" and item.icon or NATIVE_EMOTE_FALLBACK_ICON)
            if cell.emoteBadgeLabel then
                cell.emoteBadgeLabel:SetText(tostring(item.emoteBadge or ""))
                cell.emoteBadgeLabel:SetHidden(item.nativeEmote ~= true)
            end
            if item.directUseOnly == true then
                cell.countLabel:SetText("USE")
            else
                cell.countLabel:SetText((item.stack or 1) > 1 and tostring(item.stack) or "")
            end
            local r,g,b,a = colorForQuality(item.link or "", item.displayQuality)
            if item.kind == "collectible" then
                if item.directUseOnly == true then r,g,b,a = 1.00, 0.72, 0.32, 1
                else r,g,b,a = 0.52, 0.82, 1.00, 1 end
            end
            if item.kind == "emote" then r,g,b,a = 0.92, 0.56, 1.00, 1 end
            cell.qualityR, cell.qualityG, cell.qualityB = r,g,b
            cell.bg:SetEdgeColor(r,g,b,a or 1)
            cell.bg:SetCenterColor(0.045 + r * 0.12, 0.055 + g * 0.12, 0.070 + b * 0.12, 0.98)
        else
            cell.bagId, cell.slotIndex, cell.link, cell.collectibleId, cell.emoteId, cell.actionType, cell.actionId, cell.categoryLabel, cell.displayName, cell.description = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
            cell.directUseOnly, cell.quickslotCompatible = nil, nil
        end
    end
end

function EASInventoryGrid:RefreshQuickslotPanel()
    local slots = self:CollectQuickslots()
    self.specialTitle:SetText("QUICKSLOTS")
    self.specialHint:SetText(self.quickslotAssignTarget and "Choose an item below for the selected Quickslot • click the selected slot again to cancel" or "Left-click a Quickslot to choose/reassign an item right here • Right-click a filled slot to make it active")
    self:LayoutSpecialCells(math.min(#slots, #self.specialCells))
    for i, card in ipairs(self.specialCells) do
        local data = slots[i]
        card:SetHidden(data == nil)
        if data then
            card.specialKind = "quickslot"
            card.displayName = data.name
            card.description = nil
            card.slotNum, card.slotUsed, card.isCurrent, card.displayIndex = data.slotNum, data.used, data.current, data.index
            card.icon:SetTexture(data.icon ~= "" and data.icon or "EsoUI/Art/Quickslots/quickslot_emptySlot.dds")
            card.nameLabel:SetText(data.name)
            card.valueLabel:SetText(data.count > 0 and formatNumber(data.count) or tostring(data.index))
            local assigning = tonumber(self.quickslotAssignTarget) == tonumber(data.slotNum)
            local rr, gg, bb, aa = colorForQuality(data.itemLink or "", data.displayQuality or 0)
            card.rarityR, card.rarityG, card.rarityB = nil, nil, nil
            if data.used and (data.displayQuality or 0) > 0 then
                card.rarityR, card.rarityG, card.rarityB = rr, gg, bb
                card.bg:SetEdgeColor(math.min(1, rr * 1.12 + 0.05), math.min(1, gg * 1.12 + 0.05), math.min(1, bb * 1.12 + 0.05), 1)
                card.bg:SetCenterColor(0.045 + rr * 0.16, 0.055 + gg * 0.16, 0.070 + bb * 0.16, 0.985)
            elseif data.used then
                card.bg:SetEdgeColor(0.46, 0.66, 0.78, 0.95)
                card.bg:SetCenterColor(0.055, 0.07, 0.09, 0.97)
            else
                card.bg:SetEdgeColor(0.22, 0.28, 0.34, 0.95)
                card.bg:SetCenterColor(0.055, 0.07, 0.09, 0.97)
            end
            -- Keep selection/current-state obvious without replacing the rarity color.
            if assigning then
                if card.selectionFrame then card.selectionFrame:SetHidden(false); card.selectionFrame:SetEdgeColor(1.00, 0.82, 0.28, 1) end
            elseif data.current then
                if card.selectionFrame then card.selectionFrame:SetHidden(false); card.selectionFrame:SetEdgeColor(0.35, 0.95, 1.00, 1) end
            elseif card.selectionFrame then
                card.selectionFrame:SetHidden(true)
            end
            card.valueLabel:SetColor(assigning and 1.00 or (data.current and 0.45 or 0.90), assigning and 0.84 or (data.current and 0.95 or 0.85), assigning and 0.28 or (data.current and 1.00 or 0.58), 1)
        end
    end
    self:RefreshQuickslotPicker()
end

function EASInventoryGrid:RefreshSpecialMode()
    if not self.visible or not self.root then return false end
    local mode = self:GetCurrentInventoryMode()
    if not isCurrencyMode(mode) and not isQuickslotMode(mode) then
        if self.special then self.special:SetHidden(true) end
        self:HideQuickslotPicker(true)
        if self.scroll then self.scroll:SetHidden(false) end
        self:SetNativeSpecialPanelHidden("currency", false)
        self:SetNativeSpecialPanelHidden("quickslot", false)
        return false
    end

    self:AnchorRootToInventoryArea()
    self.root:SetHidden(false)
    self:SetNativeListsHidden(true)
    if self.scroll then self.scroll:SetHidden(true) end
    if self.special then self.special:SetHidden(false) end

    if isCurrencyMode(mode) then
        self:HideQuickslotPicker(true)
        self:SetNativeSpecialPanelHidden("quickslot", false)
        self:SetNativeSpecialPanelHidden("currency", true)
        self:RefreshCurrencyPanel()
    else
        self:SetNativeSpecialPanelHidden("currency", false)
        self:SetNativeSpecialPanelHidden("quickslot", true)
        self:RefreshQuickslotPanel()
    end
    return true
end

function EASInventoryGrid:GetGridInventoryTypeForMode(mode)
    if mode == rawget(_G, "SI_INVENTORY_MODE_ITEMS") or mode == "inventory" then
        return tonumber(rawget(_G, "INVENTORY_BACKPACK")) or 1
    elseif mode == rawget(_G, "SI_INVENTORY_MODE_CRAFT_BAG") or mode == "craftBag" then
        return tonumber(rawget(_G, "INVENTORY_CRAFT_BAG")) or 6
    elseif mode == rawget(_G, "SI_INVENTORY_MODE_QUEST_ITEMS") or mode == "quest" then
        return tonumber(rawget(_G, "INVENTORY_QUEST_ITEM")) or 2
    end
    -- Currency and Quickslots are specialized ESO panels, not ordinary item
    -- scroll lists, so they stay native and fully interactive.
    return nil
end

function EASInventoryGrid:GetActiveInventoryData()
    local inv = rawget(_G, "PLAYER_INVENTORY")
    if type(inv) ~= "table" or type(inv.inventories) ~= "table" then return nil, nil end

    local mode = self:GetCurrentInventoryMode()
    local inventoryType = self:GetGridInventoryTypeForMode(mode)
    if not inventoryType then return nil, nil end

    local data = inv.inventories[inventoryType]
    if type(data) ~= "table" then return nil, nil end
    return data, inventoryType
end

function EASInventoryGrid:IsGridModeActive()
    return self:GetGridInventoryTypeForMode(self:GetCurrentInventoryMode()) ~= nil
end

function EASInventoryGrid:SetNativeListsHidden(hidden)
    local inv = rawget(_G, "PLAYER_INVENTORY")
    if type(inv) ~= "table" or type(inv.inventories) ~= "table" then return end
    self.nativeListState = self.nativeListState or {}

    -- Keep ESO's list machinery alive for filtering/sorting, but make the row
    -- surfaces impossible to see while the Suite inventory is open. ESO can
    -- call SetHidden(false) during a tab transition; alpha=0 prevents that
    -- single-frame native-list flash without disabling the data source.
    for _, inventoryData in pairs(inv.inventories) do
        if type(inventoryData) == "table" then
            local list = inventoryData.listView
            if list then
                local state = self.nativeListState[list]
                if hidden then
                    if not state then
                        state = {}
                        if type(list.GetAlpha) == "function" then state.alpha = list:GetAlpha() end
                        self.nativeListState[list] = state
                    end
                    if type(list.SetAlpha) == "function" then pcall(list.SetAlpha, list, 0) end
                    if type(list.SetHidden) == "function" then pcall(list.SetHidden, list, true) end
                else
                    if type(list.SetAlpha) == "function" then pcall(list.SetAlpha, list, state and state.alpha ~= nil and state.alpha or 1) end
                    -- Let ESO decide visibility after we leave the Suite scene.
                    if type(list.SetHidden) == "function" then pcall(list.SetHidden, list, false) end
                    self.nativeListState[list] = nil
                end
            end
        end
    end
end

function EASInventoryGrid:UpdateNativeList(force)
    local inv = rawget(_G, "PLAYER_INVENTORY")
    local data, inventoryType = self:GetActiveInventoryData()
    if type(inv) ~= "table" or type(inv.UpdateList) ~= "function" or not inventoryType then return end
    if self.updatingNative then return end
    self.updatingNative = true
    -- ESO supports UPDATE_EVEN_IF_HIDDEN as the second argument.  This is the
    -- key to keeping native category/search/sort logic working while its rows
    -- remain completely hidden behind the Suite grid.
    pcall(inv.UpdateList, inv, inventoryType, true)
    self.updatingNative = false
end

function EASInventoryGrid:GetActiveList()
    local data = self:GetActiveInventoryData()
    return type(data) == "table" and data.listView or nil
end

function EASInventoryGrid:GetSearchText()
    local data = self:GetActiveInventoryData()
    local box = type(data) == "table" and data.searchBox or nil
    if not box then box = rawget(_G, "ZO_PlayerInventorySearchFiltersTextSearchBox") or rawget(_G, "ZO_PlayerInventorySearchBox") end
    if box and type(box.GetText) == "function" then return lower(box:GetText()) end
    return ""
end

function EASInventoryGrid:RefreshLayout()
    if not self.root or not self.scrollChild then return end
    local w = num(self.root:GetWidth(), 360)
    local cellSize = 44
    local gap = 5
    local cols = math.max(5, math.floor((w - 8) / (cellSize + gap)))
    self.columns = cols
    for i, cell in ipairs(self.cells) do
        local col = (i - 1) % cols
        local row = math.floor((i - 1) / cols)
        cell:ClearAnchors()
        cell:SetAnchor(TOPLEFT, self.scrollChild, TOPLEFT, 4 + col * (cellSize + gap), 4 + row * (cellSize + gap))
    end
end

function EASInventoryGrid:CollectItems()
    local out = {}

    -- IMPORTANT: mirror ESO's already-filtered/sorted keyboard inventory data
    -- instead of rescanning BAG_BACKPACK ourselves.  This makes the grid react
    -- to ALL/Weapons/Apparel/Consumables/Materials/etc., the sub-filters, text
    -- search, and the native Name/Value sorting controls automatically.
    local activeData = self:GetActiveInventoryData()
    local list = self:GetActiveList()
    if list and type(ZO_ScrollList_GetDataList) == "function" then
        local dataList = safe(ZO_ScrollList_GetDataList, nil, list)
        if type(dataList) == "table" then
            local currentAutoCategoryGroup = nil
            local autoCategoryLoaded = type(rawget(_G, "AutoCategory")) == "table"
            for _, entry in ipairs(dataList) do
                local slot = type(entry) == "table" and (entry.data or entry) or nil
                local typeId = type(entry) == "table" and tonumber(entry.typeId or entry.type) or nil
                if type(slot) == "table" then
                    -- AutoCategory - Revised inserts category header data entries
                    -- into ESO's native scroll data. Preserve those category names
                    -- and apply them to the following item cells in the Suite grid.
                    local headerName = cleanGroupName(slot.categoryName or slot.headerName or slot.header or slot.text or slot.name)
                    local looksLikeAutoCategoryHeader = autoCategoryLoaded and (
                        typeId == 998 or
                        (slot.bagId == nil and slot.slotIndex == nil and slot.iconFile == nil and headerName ~= "" and (slot.isHeader == true or slot.categoryName ~= nil or slot.headerName ~= nil))
                    )
                    if looksLikeAutoCategoryHeader then
                        currentAutoCategoryGroup = headerName ~= "" and headerName or "AutoCategory"
                    elseif slot.bagId ~= nil and slot.slotIndex ~= nil then
                        local bagId = slot.bagId
                        local slotIndex = slot.slotIndex
                        local link = tostring(safe(GetItemLink, "", bagId, slotIndex, LINK_STYLE_DEFAULT or 0) or "")
                        local name = tostring(slot.name or "")
                        if name == "" and link ~= "" then name = tostring(safe(GetItemLinkName, "", link) or "") end
                        if name == "" then name = tostring(safe(GetItemName, "", bagId, slotIndex) or "") end

                        out[#out + 1] = {
                            bagId = bagId,
                            slotIndex = slotIndex,
                            link = link,
                            name = name,
                            icon = tostring(slot.iconFile or (link ~= "" and safe(GetItemLinkIcon, "", link) or "") or ""),
                            stack = num(slot.stackCount, num(safe(GetSlotStackSize, 1, bagId, slotIndex), 1)),
                            locked = slot.isPlayerLocked == true or slot.locked == true or safe(IsItemPlayerLocked, false, bagId, slotIndex) == true,
                            junk = slot.isJunk == true or safe(IsItemJunk, false, bagId, slotIndex) == true,
                            displayQuality = tonumber(slot.displayQuality or slot.quality),
                            age = tonumber(slot.age) or 0,
                            slotType = type(activeData) == "table" and activeData.slotType or rawget(_G, "SLOT_TYPE_ITEM"),
                            filterData = slot.filterData,
                            dataEntry = entry,
                            autoCategoryGroup = currentAutoCategoryGroup,
                        }
                    elseif slot.iconFile or slot.name then
                        -- Quest-item style lists do not expose a backpack bag/slot.
                        -- Still render them in the Suite grid instead of falling back
                        -- to ESO's row list on those tabs.
                        out[#out + 1] = {
                            bagId = nil,
                            slotIndex = nil,
                            link = "",
                            name = tostring(slot.name or "Quest Item"),
                            icon = tostring(slot.iconFile or ""),
                            stack = num(slot.stackCount, 1),
                            locked = false,
                            junk = false,
                            displayQuality = tonumber(slot.displayQuality or slot.quality) or 1,
                            questItem = true,
                            slotType = type(activeData) == "table" and activeData.slotType or rawget(_G, "SLOT_TYPE_QUEST_ITEM"),
                            questIndex = slot.questIndex,
                            toolIndex = slot.toolIndex,
                            stepIndex = slot.stepIndex,
                            conditionIndex = slot.conditionIndex,
                            filterData = slot.filterData,
                            dataEntry = entry,
                            autoCategoryGroup = currentAutoCategoryGroup,
                        }
                    end
                end
            end
            return out
        end
    end

    -- Defensive fallback if ESO's scroll-list data is unavailable for a frame.
    -- Search still works here, but normal operation should always use the block above.
    if type(GetBagSize) ~= "function" then return out end
    local search = self:GetSearchText()
    local activeData = self:GetActiveInventoryData()
    local bagId = BAG_BACKPACK or 1
    if type(activeData) == "table" and type(activeData.backingBags) == "table" and activeData.backingBags[1] ~= nil then
        bagId = activeData.backingBags[1]
    end
    local size = num(safe(GetBagSize, 0, bagId), 0)
    for slotIndex = 0, size - 1 do
        local link = tostring(safe(GetItemLink, "", bagId, slotIndex, LINK_STYLE_DEFAULT or 0) or "")
        if link ~= "" then
            local name = tostring(safe(GetItemLinkName, "", link) or "")
            if name == "" then name = tostring(safe(GetItemName, "", bagId, slotIndex) or "") end
            if search == "" or string.find(lower(name), search, 1, true) then
                out[#out + 1] = {
                    bagId = bagId,
                    slotIndex = slotIndex,
                    link = link,
                    name = name,
                    icon = tostring(safe(GetItemLinkIcon, "", link) or ""),
                    stack = num(safe(GetSlotStackSize, 1, bagId, slotIndex), 1),
                    locked = safe(IsItemPlayerLocked, false, bagId, slotIndex) == true,
                    junk = safe(IsItemJunk, false, bagId, slotIndex) == true,
                    displayQuality = num(safe(GetItemDisplayQuality, nil, bagId, slotIndex), nil),
                    slotType = type(activeData) == "table" and activeData.slotType or rawget(_G, "SLOT_TYPE_ITEM"),
                }
            end
        end
    end
    return out
end

function EASInventoryGrid:BindCellToNativeSlot(cell, item)
    if not cell then return end

    -- Data-only binding. We intentionally do not call ZO_Inventory_BindSlot on
    -- addon-created controls, because stock action closures from that pipeline
    -- can later execute private inventory functions from an insecure stack.
    cell.slotType = nil
    cell.bagId = nil
    cell.slotIndex = nil
    cell.stackCount = item and num(item.stack, 1) or 0
    cell.questIndex, cell.toolIndex, cell.stepIndex, cell.conditionIndex = nil, nil, nil, nil
    cell.filterData = nil
    cell.dataEntry = nil

    if not item then return end
    cell.filterData = item.filterData
    cell.dataEntry = item.dataEntry
    cell.slotType = tonumber(item.slotType) or (item.questItem and rawget(_G, "SLOT_TYPE_QUEST_ITEM") or rawget(_G, "SLOT_TYPE_ITEM"))
    cell.stackCount = num(item.stack, 1)

    if item.questItem then
        cell.questIndex = item.questIndex
        cell.toolIndex = item.toolIndex
        cell.stepIndex = item.stepIndex
        cell.conditionIndex = item.conditionIndex
    else
        cell.bagId = item.bagId
        cell.slotIndex = item.slotIndex
    end
end

function EASInventoryGrid:Refresh(forceNativeUpdate)
    self:Create()
    if not self.root or not self.visible then return end

    if self:RefreshSpecialMode() then return end

    if not self:IsGridModeActive() then
        self.root:SetHidden(true)
        self:SetNativeListsHidden(true)
        self:SetNativeSpecialPanelHidden("currency", false)
        self:SetNativeSpecialPanelHidden("quickslot", false)
        return
    end

    if self.special then self.special:SetHidden(true) end
    if self.scroll then self.scroll:SetHidden(false) end
    self:SetNativeSpecialPanelHidden("currency", false)
    self:SetNativeSpecialPanelHidden("quickslot", false)
    self.root:SetHidden(false)
    if forceNativeUpdate == true then self:UpdateNativeList(true) end

    local anchor = self:GetActiveList() or rawget(_G, "ZO_PlayerInventoryList") or rawget(_G, "ZO_PlayerInventory")
    if anchor then
        self.root:ClearAnchors()
        self.root:SetAnchor(TOPLEFT, anchor, TOPLEFT, 0, 0)
        self.root:SetAnchor(BOTTOMRIGHT, anchor, BOTTOMRIGHT, 0, 0)
    end
    self:SetNativeListsHidden(true)

    self:RefreshLayout()
    self.items = self:CollectItems()

    for i, cell in ipairs(self.cells) do
        local item = self.items[i]
        if item then
            local r, g, b, a = colorForQuality(item.link, item.displayQuality)
            cell:SetHidden(false)
            self:BindCellToNativeSlot(cell, item)
            cell.link = item.link
            cell.itemName = item.name
            cell.questItem = item.questItem == true
            cell.icon:SetTexture(item.icon ~= "" and item.icon or "EsoUI/Art/Icons/icon_missing.dds")
            cell.count:SetText((item.stack or 1) > 1 and tostring(item.stack) or "")
            setCellQuality(cell, r, g, b, a)
            if cell.lockIcon then cell.lockIcon:SetHidden(not item.locked) end
            if item.junk and not item.locked then
                cell.marker:SetText("J")
                cell.marker:SetHidden(false)
                cell.marker:SetColor(0.92, 0.36, 0.30, 1)
            else
                cell.marker:SetHidden(true)
            end
            if cell.loadoutMarker then
                local used = item.questItem ~= true and EPC and EPC.saved and EPC.saved.loadoutInventoryMarkers029272 ~= false and EPC.LoadoutManager and type(EPC.LoadoutManager.IsItemInAnySetup) == "function" and EPC.LoadoutManager:IsItemInAnySetup(item.bagId, item.slotIndex)
                cell.loadoutMarker:SetHidden(used ~= true)
            end
        else
            cell:SetHidden(true)
            self:BindCellToNativeSlot(cell, nil)
            cell.link = nil
            cell.itemName, cell.questItem = nil, nil
            if cell.lockIcon then cell.lockIcon:SetHidden(true) end
            if cell.marker then cell.marker:SetHidden(true) end
            if cell.loadoutMarker then cell.loadoutMarker:SetHidden(true) end
        end
    end
    self:LayoutGroupedItems(self.items)
end

function EASInventoryGrid:SetVisible(show)
    self.visible = show == true
    self:Create()
    if not self.root then return end

    if self.visible then
        self.lastSignature = nil
        self.lastMode = nil
        -- Hide every native content surface up-front for the whole inventory
        -- scene. This prevents ESO from getting one rendered frame ahead of us
        -- when switching Items/Craft Bag/Quest/Currency/Quickslots.
        self:SetNativeListsHidden(true)
        self:SetNativeSpecialPanelHidden("currency", true)
        self:SetNativeSpecialPanelHidden("quickslot", true)
        self:Refresh(true)
        EVENT_MANAGER:RegisterForUpdate(self.name .. "Refresh", 120, function()
            if not self.visible then return end

            local mode = self:GetCurrentInventoryMode()
            local gridMode = self:GetGridInventoryTypeForMode(mode)
            if isCurrencyMode(mode) or isQuickslotMode(mode) then
                self.lastSignature = nil
                self.lastMode = mode
                if isQuickslotMode(mode) then self:ForceHideNativeQuickslotSurface() end
                self:RefreshSpecialMode()
                return
            elseif not gridMode then
                if self.root then self.root:SetHidden(true) end
                self:SetNativeListsHidden(true)
                self:SetNativeSpecialPanelHidden("currency", false)
                self:SetNativeSpecialPanelHidden("quickslot", false)
                self.lastSignature = nil
                self.lastMode = mode
                return
            end

            if self.root then self.root:SetHidden(false) end
            local data, inventoryType = self:GetActiveInventoryData()
            local filter = type(data) == "table" and tostring(data.currentFilter or "") or ""
            local sortKey = type(data) == "table" and tostring(data.currentSortKey or "") or ""
            local sortOrder = type(data) == "table" and tostring(data.currentSortOrder or "") or ""
            local signature = table.concat({tostring(mode or ""), tostring(inventoryType or ""), filter, sortKey, sortOrder, self:GetSearchText()}, "|")
            if mode ~= self.lastMode or signature ~= self.lastSignature then
                self.lastMode = mode
                self.lastSignature = signature
                self:Refresh(true)
            else
                self:SetNativeListsHidden(true)
            end
        end)
    else
        EVENT_MANAGER:UnregisterForUpdate(self.name .. "Refresh")
        self.quickslotAssignTarget = nil
        self.quickslotAssignIndex = nil
        if self.root then self.root:SetHidden(true) end
        self:SetNativeListsHidden(false)
        self:SetNativeSpecialPanelHidden("currency", false)
        self:SetNativeSpecialPanelHidden("quickslot", false)
    end
end

-- ESO 12.x can briefly expose smithing improvement rows before their booster
-- quality fields have been populated.  The stock GetBoosterRowForQuality()
-- subtracts 1 from that nil value while hovering an improvement candidate.
-- Keep the stock behavior, but simply skip an uninitialized booster row.
function EASInventoryGrid:InstallSmithingImprovementSafety()
    -- v0.29.329: Do not override ESO smithing improvement row lookup.
    -- ESO owns booster-row construction/hover animation; replacing this method
    -- can return nil while SmithingImprovement_Keyboard expects a real row.
    return true
end

function EASInventoryGrid:Initialize()
    self:Create()

    local collectibleEvent = rawget(_G, "EVENT_COLLECTIBLE_UPDATED") or rawget(_G, "EVENT_COLLECTION_UPDATED")
    if collectibleEvent then
        EVENT_MANAGER:RegisterForEvent(self.name .. "Collectibles", collectibleEvent, function()
            self.quickslotCollectibleCache = nil
            if self.visible and self.quickslotAssignTarget then self:RefreshQuickslotPicker() end
        end)
    end

    local inv = rawget(_G, "PLAYER_INVENTORY")
    if type(SecurePostHook) == "function" and type(inv) == "table" and not self.hooksInstalled then
        if type(inv.ChangeFilter) == "function" then
            SecurePostHook(inv, "ChangeFilter", function(_, tabData)
                if not self.visible then return end
                zo_callLater(function()
                    if self.visible then self:Refresh(true) end
                end, 1)
            end)
        end

        local bar = rawget(_G, "INVENTORY_MENU_BAR")
        if type(bar) == "table" and type(bar.OnButtonClicked) == "function" then
            SecurePostHook(bar, "OnButtonClicked", function()
                if not self.visible then return end
                zo_callLater(function()
                    if self.visible then
                        self.lastMode = nil
                        self.lastSignature = nil
                        self:Refresh(true)
                    end
                end, 1)
            end)
        end
        self.hooksInstalled = true
    end

    -- React on fragment state changes immediately instead of waiting for the
    -- polling update. Native surfaces are already pre-hidden, so this makes the
    -- Suite replacement feel like one continuous panel with no ESO flash.
    if not self.fragmentHooksInstalled then
        local fragments = {
            rawget(_G, "INVENTORY_FRAGMENT"), rawget(_G, "CRAFT_BAG_FRAGMENT"),
            rawget(_G, "QUEST_ITEMS_FRAGMENT"), rawget(_G, "WALLET_FRAGMENT"),
            rawget(_G, "KEYBOARD_QUICKSLOT_FRAGMENT"), rawget(_G, "KEYBOARD_QUICKSLOT_CIRCLE_FRAGMENT"),
        }
        for _, fragment in ipairs(fragments) do
            if fragment and type(fragment.RegisterCallback) == "function" then
                pcall(fragment.RegisterCallback, fragment, "StateChange", function()
                    if not self.visible then return end
                    self:SetNativeListsHidden(true)
                    self:SetNativeSpecialPanelHidden("currency", true)
                    self:SetNativeSpecialPanelHidden("quickslot", true)
                    self.lastMode = nil
                    self.lastSignature = nil
                    zo_callLater(function() if self.visible then self:Refresh(true) end end, 0)
                end)
            end
        end
        self.fragmentHooksInstalled = true
    end

    local scene = SCENE_MANAGER and SCENE_MANAGER:GetScene("inventory") or nil
    if scene and type(scene.RegisterCallback) == "function" then
        scene:RegisterCallback("StateChange", function(_, newState)
            local showing = newState == SCENE_SHOWING or newState == SCENE_SHOWN
            self:SetVisible(showing)
        end)
    end

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function()
        if self.visible then zo_callLater(function() if self.visible then self:Refresh(true) end end, 20) end
    end)

    EVENT_MANAGER:RegisterForEvent(self.name .. "Bag", EVENT_INVENTORY_FULL_UPDATE, function()
        if self.visible then zo_callLater(function() if self.visible then self:Refresh(true) end end, 20) end
    end)

    if rawget(_G, "EVENT_HOTBAR_SLOT_UPDATED") then
        EVENT_MANAGER:RegisterForEvent(self.name .. "QuickslotUpdate", EVENT_HOTBAR_SLOT_UPDATED, function(_, _, category)
            if self.visible and category == rawget(_G, "HOTBAR_CATEGORY_QUICKSLOT_WHEEL") then
                zo_callLater(function() if self.visible then self:RefreshSpecialMode() end end, 10)
            end
        end)
    end
    if rawget(_G, "EVENT_CURRENCY_UPDATE") then
        EVENT_MANAGER:RegisterForEvent(self.name .. "CurrencyUpdate", EVENT_CURRENCY_UPDATE, function()
            if self.visible then zo_callLater(function() if self.visible then self:RefreshSpecialMode() end end, 10) end
        end)
    end

    EVENT_MANAGER:RegisterForEvent(self.name .. "SmithingSafety", EVENT_PLAYER_ACTIVATED, function()
        EVENT_MANAGER:UnregisterForEvent(self.name .. "SmithingSafety", EVENT_PLAYER_ACTIVATED)
    end)
end

EVENT_MANAGER:RegisterForEvent(EASInventoryGrid.name, EVENT_ADD_ON_LOADED, function(_, addonName)
    if addonName ~= "ESOAdventurerSuite" then return end
    EVENT_MANAGER:UnregisterForEvent(EASInventoryGrid.name, EVENT_ADD_ON_LOADED)
    EASInventoryGrid:Initialize()
end)
