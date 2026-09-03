-- ESO Adventurer Suite
-- Floating Recipe & Style Learner (Turbo Mode)

local EPC = ESOProgressionCoach
EPC.RecipeStyleLearner = EPC.RecipeStyleLearner or {}
local R = EPC.RecipeStyleLearner
local wm = WINDOW_MANAGER

local PREFIX = "ESOAdventurerSuite_RecipeStyleLearner"
local BOOK_ICON = "EsoUI/Art/MainMenu/menubar_journal_up.dds"

-- v0.29.153: the learner stays at its normal 64x64 size in HUD Layout
-- Mode. A dedicated invisible drag handle covers the book only while layout
-- mode is active, so the very first left-click-and-hold starts moving it.
local NORMAL_W, NORMAL_H = 64, 64

local function safe(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, a,b,c,d,e,f = pcall(fn, ...)
    if not ok then return fallback end
    return a,b,c,d,e,f
end

local function num(v, fallback)
    v = tonumber(v)
    if v == nil then return fallback or 0 end
    return v
end

local function lower(v)
    return string.lower(tostring(v or ""))
end

local function notify(text, good)
    if EPC and type(EPC.Print) == "function" then EPC:Print(text) end
    if type(ZO_Alert) == "function" then
        pcall(ZO_Alert, good == false and UI_ALERT_CATEGORY_ERROR or UI_ALERT_CATEGORY_ALERT, nil, text)
    end
end

function R:EnsureSaved()
    EPC.saved = EPC.saved or {}
    if EPC.saved.recipeStyleLearnerEnabled == nil then EPC.saved.recipeStyleLearnerEnabled = true end
    if EPC.saved.recipeStyleLearnerIncludeBank == nil then EPC.saved.recipeStyleLearnerIncludeBank = true end
    if EPC.saved.recipeStyleLearnerSuppressPopups == nil then EPC.saved.recipeStyleLearnerSuppressPopups = true end
    if EPC.saved.recipeStyleLearnerLeft == nil then EPC.saved.recipeStyleLearnerLeft = -1 end
    if EPC.saved.recipeStyleLearnerTop == nil then EPC.saved.recipeStyleLearnerTop = -1 end
end

function R:IsSceneShowing(name)
    if not SCENE_MANAGER or type(SCENE_MANAGER.GetScene) ~= "function" then return false end
    local scene = SCENE_MANAGER:GetScene(name)
    if not scene then return false end
    if type(scene.IsShowing) == "function" then
        local ok, value = pcall(scene.IsShowing, scene)
        return ok and value == true
    end
    return false
end

function R:IsBankOpen()
    if type(GetInteractionType) == "function" and rawget(_G, "INTERACTION_BANK") ~= nil then
        local interaction = safe(GetInteractionType, nil)
        if interaction == INTERACTION_BANK then return true end
    end
    return self:IsSceneShowing("bank") or self:IsSceneShowing("gamepad_banking")
end

function R:IsInventoryOrBankShowing()
    return self:IsSceneShowing("inventory")
        or self:IsSceneShowing("gamepad_inventory_root")
        or self:IsSceneShowing("bank")
        or self:IsSceneShowing("gamepad_banking")
        or self:IsBankOpen()
end

function R:RestorePosition()
    if not self.button or not GuiRoot then return end
    self:EnsureSaved()
    local x = num(EPC.saved.recipeStyleLearnerLeft, -1)
    local y = num(EPC.saved.recipeStyleLearnerTop, -1)
    self.button:ClearAnchors()
    self.button:SetDimensions(NORMAL_W, NORMAL_H)
    if x >= 0 and y >= 0 then
        self.button:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
    else
        self.button:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -112, 245)
    end
end

function R:SavePosition029153()
    if not self.button or not EPC.saved then return end
    EPC.saved.recipeStyleLearnerLeft = math.max(0, num(self.button:GetLeft(), 0))
    EPC.saved.recipeStyleLearnerTop = math.max(0, num(self.button:GetTop(), 0))
end

function R:ResetPosition()
    self:EnsureSaved()
    EPC.saved.recipeStyleLearnerLeft = -1
    EPC.saved.recipeStyleLearnerTop = -1
    self:RestorePosition()
end

function R:GetStringForType(prefix, value)
    if type(GetString) == "function" then
        local ok, result = pcall(GetString, prefix, value)
        if ok and result then return tostring(result) end
    end
    return ""
end

function R:ClassifyLink(link)
    if not link or link == "" then return nil end
    local itemType = num(safe(GetItemLinkItemType, -1, link), -1)
    local specialized = num(safe(GetItemLinkSpecializedItemType, -1, link), -1)
    local itemName = tostring(safe(GetItemLinkName, "", link) or "")
    local text = lower(itemName .. " " .. self:GetStringForType("SI_ITEMTYPE", itemType) .. " " .. self:GetStringForType("SI_SPECIALIZEDITEMTYPE", specialized))

    local recipeType = rawget(_G, "ITEMTYPE_RECIPE")
    local motifType = rawget(_G, "ITEMTYPE_RACIAL_STYLE_MOTIF")
    local isRecipe = recipeType ~= nil and itemType == recipeType
    local isMotif = motifType ~= nil and itemType == motifType

    if string.find(text, "recipe", 1, true)
        or string.find(text, "blueprint", 1, true)
        or string.find(text, "diagram", 1, true)
        or string.find(text, "pattern", 1, true)
        or string.find(text, "praxis", 1, true)
        or string.find(text, "formula", 1, true)
        or string.find(text, "design", 1, true) then
        isRecipe = true
    end

    if string.find(text, "motif", 1, true)
        or string.find(text, "style page", 1, true)
        or string.find(text, "crafting style", 1, true) then
        isMotif = true
    end

    if isRecipe then return "RECIPE" end
    if isMotif then return "STYLE" end
    return nil
end

function R:IsKnown(link, class)
    if class == "RECIPE" and type(IsItemLinkRecipeKnown) == "function" then
        local value = safe(IsItemLinkRecipeKnown, nil, link)
        if value ~= nil then return value == true end
    end
    if class == "STYLE" and type(IsItemLinkBookKnown) == "function" then
        local value = safe(IsItemLinkBookKnown, nil, link)
        if value ~= nil then return value == true end
    end
    -- Fallback across both knowledge APIs. If either says known, do not consume it.
    if type(IsItemLinkRecipeKnown) == "function" and safe(IsItemLinkRecipeKnown, false, link) == true then return true end
    if type(IsItemLinkBookKnown) == "function" and safe(IsItemLinkBookKnown, false, link) == true then return true end
    return false
end

function R:GetUniqueId(bagId, slotIndex)
    if type(GetItemUniqueId) ~= "function" or type(Id64ToString) ~= "function" then return "" end
    local id = safe(GetItemUniqueId, nil, bagId, slotIndex)
    if not id then return "" end
    return tostring(safe(Id64ToString, "", id) or "")
end

function R:IsLocked(bagId, slotIndex)
    if type(IsItemPlayerLocked) == "function" and safe(IsItemPlayerLocked, false, bagId, slotIndex) == true then return true end
    return false
end

function R:ScanBag(bagId, out)
    if bagId == nil then return end
    local size = num(safe(GetBagSize, 0, bagId), 0)
    for slotIndex = 0, size - 1 do
        local link = tostring(safe(GetItemLink, "", bagId, slotIndex, LINK_STYLE_DEFAULT or 0) or "")
        if link ~= "" and not self:IsLocked(bagId, slotIndex) then
            local class = self:ClassifyLink(link)
            if class and not self:IsKnown(link, class) then
                out[#out + 1] = {
                    bagId = bagId,
                    slotIndex = slotIndex,
                    uniqueId = self:GetUniqueId(bagId, slotIndex),
                    link = link,
                    class = class,
                    name = tostring(safe(GetItemLinkName, "Unknown", link) or "Unknown"),
                }
            end
        end
    end
end

function R:BuildQueue()
    self:EnsureSaved()
    local out = {}
    self:ScanBag(BAG_BACKPACK, out)
    if EPC.saved.recipeStyleLearnerIncludeBank == true and self:IsBankOpen() then
        self:ScanBag(BAG_BANK, out)
        self:ScanBag(BAG_SUBSCRIBER_BANK, out)
    end
    return out
end

function R:FindEntry(entry)
    if not entry then return nil end
    local bags = { BAG_BACKPACK }
    if self:IsBankOpen() then
        bags[#bags + 1] = BAG_BANK
        bags[#bags + 1] = BAG_SUBSCRIBER_BANK
    end
    for _, bagId in ipairs(bags) do
        if bagId ~= nil then
            local size = num(safe(GetBagSize, 0, bagId), 0)
            for slotIndex = 0, size - 1 do
                if entry.uniqueId ~= "" and self:GetUniqueId(bagId, slotIndex) == entry.uniqueId then
                    return bagId, slotIndex
                end
            end
        end
    end
    return entry.bagId, entry.slotIndex
end

function R:FindEmptyBackpackSlot()
    if type(FindFirstEmptySlotInBag) == "function" then
        local slot = safe(FindFirstEmptySlotInBag, nil, BAG_BACKPACK)
        if slot ~= nil and num(slot, -1) >= 0 then return slot end
    end
    local size = num(safe(GetBagSize, 0, BAG_BACKPACK), 0)
    for slotIndex = 0, size - 1 do
        local link = tostring(safe(GetItemLink, "", BAG_BACKPACK, slotIndex, LINK_STYLE_DEFAULT or 0) or "")
        if link == "" then return slotIndex end
    end
    return nil
end

function R:UseBackpackItem(slotIndex)
    -- UseItem is protected/private from insecure addon code on current ESO.
    -- Never call it directly: one direct call taints the stack before the
    -- protected fallback can run. CallSecureProtected is the addon-safe path
    -- for usable inventory items while out of combat.
    if type(CallSecureProtected) ~= "function" then return false end
    if type(CanUseItem) == "function" then
        local usable = safe(CanUseItem, nil, BAG_BACKPACK, slotIndex)
        if usable == false then return false end
    end
    local ok, result = pcall(CallSecureProtected, "UseItem", BAG_BACKPACK, slotIndex)
    return ok and result ~= false
end

function R:BeginPopupSuppression()
    if not EPC.saved or EPC.saved.recipeStyleLearnerSuppressPopups ~= true or self.popupSuppressed then return end
    self.popupSuppressed = {}
    local controls = {
        rawget(_G, "ZO_AlertTextNotification"),
        rawget(_G, "ZO_CenterScreenAnnounce"),
        rawget(_G, "ZO_CenterScreenAnnounceControl"),
        rawget(_G, "CENTER_SCREEN_ANNOUNCE") and rawget(_G, "CENTER_SCREEN_ANNOUNCE").control or nil,
    }
    for _, control in ipairs(controls) do
        if control and type(control.SetHidden) == "function" then
            local hidden = type(control.IsHidden) == "function" and safe(control.IsHidden, false, control) == true or false
            self.popupSuppressed[#self.popupSuppressed + 1] = { control = control, hidden = hidden }
            pcall(control.SetHidden, control, true)
        end
    end
end

function R:EndPopupSuppression()
    if not self.popupSuppressed then return end
    for _, entry in ipairs(self.popupSuppressed) do
        if entry.control and type(entry.control.SetHidden) == "function" then
            pcall(entry.control.SetHidden, entry.control, entry.hidden == true)
        end
    end
    self.popupSuppressed = nil
end

function R:FinishTurbo()
    self.running = false
    self:EndPopupSuppression()
    local stats = self.stats or { attempted = 0, skipped = 0, bankMoved = 0 }
    notify(string.format("TURBO LEARNER finished: %d used%s%s.",
        stats.attempted or 0,
        (stats.bankMoved or 0) > 0 and string.format(" | %d moved from bank", stats.bankMoved) or "",
        (stats.skipped or 0) > 0 and string.format(" | %d skipped", stats.skipped) or ""),
        (stats.skipped or 0) == 0)
    self.queue = nil
    self.queueIndex = nil
    self:RefreshStatus()
end

function R:ProcessNext()
    if not self.running then return end
    local queue = self.queue or {}
    local index = num(self.queueIndex, 1)
    if index > #queue then self:FinishTurbo(); return end
    local entry = queue[index]
    self.queueIndex = index + 1

    local bagId, slotIndex = self:FindEntry(entry)
    local link = bagId ~= nil and tostring(safe(GetItemLink, "", bagId, slotIndex, LINK_STYLE_DEFAULT or 0) or "") or ""
    if link == "" or self:IsKnown(link, entry.class) then
        self.stats.skipped = (self.stats.skipped or 0) + 1
        if type(zo_callLater) == "function" then zo_callLater(function() self:ProcessNext() end, 60) else self:ProcessNext() end
        return
    end

    local function useFromBackpack(useSlot)
        if self:UseBackpackItem(useSlot) then
            self.stats.attempted = (self.stats.attempted or 0) + 1
        else
            self.stats.skipped = (self.stats.skipped or 0) + 1
        end
        if type(zo_callLater) == "function" then
            zo_callLater(function() self:ProcessNext() end, 340)
        else
            self:ProcessNext()
        end
    end

    if bagId == BAG_BACKPACK then
        useFromBackpack(slotIndex)
        return
    end

    if bagId == BAG_BANK or bagId == BAG_SUBSCRIBER_BANK then
        if not self:IsBankOpen() or type(RequestMoveItem) ~= "function" then
            self.stats.skipped = (self.stats.skipped or 0) + 1
            if type(zo_callLater) == "function" then zo_callLater(function() self:ProcessNext() end, 80) else self:ProcessNext() end
            return
        end
        local destination = self:FindEmptyBackpackSlot()
        if destination == nil then
            self.stats.skipped = (self.stats.skipped or 0) + 1
            notify("TURBO LEARNER: backpack is full; bank items cannot be learned until there is an empty slot.", false)
            if type(zo_callLater) == "function" then zo_callLater(function() self:ProcessNext() end, 80) else self:ProcessNext() end
            return
        end
        local ok, result = pcall(RequestMoveItem, bagId, slotIndex, BAG_BACKPACK, destination, 1)
        if not ok or result == false then
            self.stats.skipped = (self.stats.skipped or 0) + 1
            if type(zo_callLater) == "function" then zo_callLater(function() self:ProcessNext() end, 80) else self:ProcessNext() end
            return
        end
        self.stats.bankMoved = (self.stats.bankMoved or 0) + 1
        local tries = 0
        local function waitForMove()
            tries = tries + 1
            local movedBag, movedSlot = self:FindEntry(entry)
            if movedBag == BAG_BACKPACK and movedSlot ~= nil then
                useFromBackpack(movedSlot)
                return
            end
            if tries >= 8 then
                self.stats.skipped = (self.stats.skipped or 0) + 1
                if type(zo_callLater) == "function" then zo_callLater(function() self:ProcessNext() end, 80) else self:ProcessNext() end
                return
            end
            if type(zo_callLater) == "function" then zo_callLater(waitForMove, 120) else waitForMove() end
        end
        if type(zo_callLater) == "function" then zo_callLater(waitForMove, 120) else waitForMove() end
        return
    end

    self.stats.skipped = (self.stats.skipped or 0) + 1
    if type(zo_callLater) == "function" then zo_callLater(function() self:ProcessNext() end, 80) else self:ProcessNext() end
end

function R:StartTurbo()
    self:EnsureSaved()
    if self.running then
        notify("TURBO LEARNER is already running.", false)
        return
    end
    if EPC.saved.recipeStyleLearnerEnabled == false then
        notify("Recipe & Style Learner is disabled in Suite Settings.", false)
        return
    end
    if type(IsUnitInCombat) == "function" and safe(IsUnitInCombat, false, "player") == true then
        notify("TURBO LEARNER cannot use protected inventory items while you are in combat.", false)
        return
    end
    if not self:IsInventoryOrBankShowing() then
        notify("Open Inventory or Bank before using Turbo Learner.", false)
        return
    end
    local queue = self:BuildQueue()
    if #queue == 0 then
        notify("TURBO LEARNER: no unknown recipes, furnishing plans, motifs, or style pages found here.", true)
        self:RefreshStatus()
        return
    end
    self.queue = queue
    self.queueIndex = 1
    self.stats = { attempted = 0, skipped = 0, bankMoved = 0 }
    self.running = true
    self:BeginPopupSuppression()
    notify(string.format("TURBO LEARNER: %d unknown item%s queued.", #queue, #queue == 1 and "" or "s"), true)
    self:RefreshStatus()
    self:ProcessNext()
end

function R:GetUnknownCount()
    if not self:IsInventoryOrBankShowing() then return 0 end
    return #self:BuildQueue()
end

function R:RefreshStatus()
    if not self.button then return end
    local count = 0
    if not self.running then count = self:GetUnknownCount() end
    if self.countLabel then
        self.countLabel:SetText(self.running and "..." or tostring(count))
        self.countLabel:SetHidden(false)
    end
    if self.glow then
        if self.running then self.glow:SetEdgeColor(1.00, 0.70, 0.18, 1)
        elseif count > 0 then self.glow:SetEdgeColor(0.20, 0.85, 0.62, 1)
        else self.glow:SetEdgeColor(0.28, 0.36, 0.46, 0.9) end
    end
end

function R:RefreshVisibility()
    self:EnsureSaved()
    if not self.button then return end
    local layout = self.layoutMode == true or (EPC and EPC.unitFramesMoveMode == true)
    local show = layout or (EPC.saved.recipeStyleLearnerEnabled ~= false and self:IsInventoryOrBankShowing())
    self.button:SetHidden(not show)
    if show then
        if layout then
            if self.countLabel then self.countLabel:SetText("MOVE") end
            if self.glow then self.glow:SetEdgeColor(1.00, 0.72, 0.22, 1) end
        else
            self:RefreshStatus()
        end
    end
    if not show and self.running then
        self.running = false
        self:EndPopupSuppression()
    end
end

function R:SetLayoutMode(active)
    active = active == true
    self:EnsureSaved()
    self:CreateUI()
    self.layoutMode = active
    if not self.button then return end

    self.button:SetDimensions(NORMAL_W, NORMAL_H)
    self.button:SetMovable(true)
    self.button:SetMouseEnabled(true)
    if self.layoutDragHandle029153 then
        self.layoutDragHandle029153:SetMouseEnabled(active)
        self.layoutDragHandle029153:SetHidden(not active)
    end
    if active then
        -- HUD Layout Mode intentionally previews the learner even when Inventory
        -- and Bank are closed. The invisible 64x64 drag handle receives the
        -- first mouse-down and starts moving immediately.
        self.button:SetHidden(false)
        if self.button.SetTopLevel then self.button:SetTopLevel(true) end
        if self.button.SetDrawTier and DT_HIGH then self.button:SetDrawTier(DT_HIGH) end
        if self.button.SetDrawLayer and DL_OVERLAY then self.button:SetDrawLayer(DL_OVERLAY) end
        if self.button.SetDrawLevel then self.button:SetDrawLevel(950) end
        if self.button.BringWindowToTop then self.button:BringWindowToTop() end
        if self.countLabel then self.countLabel:SetText("MOVE") end
        if self.glow then self.glow:SetEdgeColor(1.00, 0.72, 0.22, 1) end
    else
        self:RefreshVisibility()
    end
end

function R:RaiseForLayout()
    if self.layoutMode ~= true or not self.button or self.button:IsHidden() then return end
    if self.button.SetTopLevel then self.button:SetTopLevel(true) end
    if self.button.SetDrawTier and DT_HIGH then self.button:SetDrawTier(DT_HIGH) end
    if self.button.SetDrawLayer and DL_OVERLAY then self.button:SetDrawLayer(DL_OVERLAY) end
    if self.button.SetDrawLevel then self.button:SetDrawLevel(950) end
    if self.button.BringWindowToTop then self.button:BringWindowToTop() end
end

function R:CreateUI()
    if self.button or not wm or not GuiRoot then return end
    local b = wm:CreateTopLevelWindow("EAS_RecipeStyleLearner")
    b:SetDimensions(NORMAL_W, NORMAL_H)
    b:SetMouseEnabled(true)
    b:SetMovable(true)
    b:SetClampedToScreen(true)
    b:SetDrawTier(DT_HIGH)
    b:SetDrawLayer(DL_OVERLAY)
    b:SetDrawLevel(900)
    b:SetHidden(true)
    self.button = b

    local bg = wm:CreateControl(nil, b, CT_BACKDROP)
    bg:SetDimensions(NORMAL_W, NORMAL_H)
    bg:SetAnchor(CENTER, b, CENTER, 0, 0)
    bg:SetCenterColor(0.018, 0.026, 0.040, 0.96)
    bg:SetEdgeColor(0.28, 0.36, 0.46, 0.9)
    bg:SetEdgeTexture(nil, 1, 1, 1)
    self.glow = bg

    local icon = wm:CreateControl(nil, b, CT_TEXTURE)
    icon:SetDimensions(46, 46)
    icon:SetAnchor(CENTER, b, CENTER, 0, 0)
    icon:SetTexture(BOOK_ICON)
    self.icon = icon

    local count = wm:CreateControl(nil, b, CT_LABEL)
    count:SetFont("ZoFontGameBold")
    count:SetAnchor(BOTTOMRIGHT, bg, BOTTOMRIGHT, -4, -1)
    count:SetDimensions(28, 20)
    count:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    count:SetColor(1, 0.84, 0.30, 1)
    count:SetText("0")
    self.countLabel = count

    -- Normal inventory/bank behavior: the compact book can still be dragged,
    -- and a click without movement starts Turbo Learner. HUD Layout Mode uses
    -- the dedicated overlay handle below instead, avoiding the old first-click
    -- focus/double-click behavior.
    b:SetHandler("OnMouseDown", function(control, button)
        if button ~= MOUSE_BUTTON_INDEX_LEFT then return end
        if self.layoutMode == true or (EPC and EPC.unitFramesMoveMode == true) then return end
        self.pressLeft = num(control:GetLeft(), 0)
        self.pressTop = num(control:GetTop(), 0)
        if control.StartMoving then control:StartMoving() end
    end)
    b:SetHandler("OnMouseUp", function(control, button, upInside)
        if button ~= MOUSE_BUTTON_INDEX_LEFT then return end
        if self.layoutMode == true or (EPC and EPC.unitFramesMoveMode == true) then return end
        if control.StopMoving then control:StopMoving() end
        local left = num(control:GetLeft(), 0)
        local top = num(control:GetTop(), 0)
        self:SavePosition029153()
        local moved = math.abs(left - num(self.pressLeft, left)) > 4 or math.abs(top - num(self.pressTop, top)) > 4
        self.pressLeft, self.pressTop = nil, nil
        if upInside ~= false and not moved then
            self:StartTurbo()
        end
    end)
    b:SetHandler("OnMoveStop", function(control)
        if control.StopMoving then control:StopMoving() end
        self:SavePosition029153()
    end)

    -- Dedicated one-click drag surface for HUD Layout Mode. It is exactly the
    -- same size as the visible book (no oversized grab box), but sits above the
    -- child textures so the first mouse-down cannot be swallowed by them.
    local layoutDragHandle = wm:CreateControl(nil, b, CT_CONTROL)
    layoutDragHandle:SetAnchorFill(b)
    layoutDragHandle:SetMouseEnabled(false)
    layoutDragHandle:SetHidden(true)
    if layoutDragHandle.SetDrawLayer and DL_OVERLAY then layoutDragHandle:SetDrawLayer(DL_OVERLAY) end
    if layoutDragHandle.SetDrawLevel then layoutDragHandle:SetDrawLevel(2000) end
    layoutDragHandle:SetHandler("OnMouseDown", function(_, button)
        if button ~= MOUSE_BUTTON_INDEX_LEFT then return end
        if self.layoutMode ~= true and not (EPC and EPC.unitFramesMoveMode == true) then return end
        self.layoutDragging029153 = true
        if b.BringWindowToTop then b:BringWindowToTop() end
        if b.StartMoving then b:StartMoving() end
    end)
    layoutDragHandle:SetHandler("OnMouseUp", function(_, button)
        if button ~= MOUSE_BUTTON_INDEX_LEFT then return end
        if self.layoutDragging029153 ~= true then return end
        self.layoutDragging029153 = false
        if b.StopMoving then b:StopMoving() end
        self:SavePosition029153()
    end)
    self.layoutDragHandle029153 = layoutDragHandle

    b:SetHandler("OnMouseEnter", function(control)
        if InformationTooltip and type(InitializeTooltip) == "function" then
            InitializeTooltip(InformationTooltip, control, TOPRIGHT, 0, 0, TOPLEFT)
            InformationTooltip:AddLine("TURBO RECIPE & STYLE LEARNER", "ZoFontWinH4")
            InformationTooltip:AddLine("Click once to rapidly learn every unknown recipe, furnishing plan, motif, and style page available in your backpack. While the Bank is open it can pull learnable items into an empty backpack slot first.", "ZoFontGame")
            InformationTooltip:AddLine("In Suite HUD Layout Mode, left-click and hold the book, then drag immediately. No double-click is required. You can also drag the compact book while Inventory/Bank is open.", "ZoFontGameSmall")
        end
    end)
    b:SetHandler("OnMouseExit", function()
        if InformationTooltip and type(ClearTooltip) == "function" then ClearTooltip(InformationTooltip) end
    end)

    self:RestorePosition()
end

function R:RegisterScenes()
    if self.scenesRegistered or not SCENE_MANAGER then return end
    self.scenesRegistered = true
    for _, name in ipairs({"inventory", "bank", "gamepad_inventory_root", "gamepad_banking"}) do
        local scene = type(SCENE_MANAGER.GetScene) == "function" and SCENE_MANAGER:GetScene(name) or nil
        if scene and type(scene.RegisterCallback) == "function" then
            scene:RegisterCallback("StateChange", function()
                if type(zo_callLater) == "function" then zo_callLater(function() self:RefreshVisibility() end, 0)
                else self:RefreshVisibility() end
            end)
        end
    end
end

function R:Initialize()
    self:EnsureSaved()
    self:CreateUI()
    self:RegisterScenes()
    if EVENT_MANAGER then
        if EVENT_OPEN_BANK then EVENT_MANAGER:RegisterForEvent(PREFIX .. "_OpenBank", EVENT_OPEN_BANK, function() if type(zo_callLater)=="function" then zo_callLater(function() self:RefreshVisibility() end, 0) else self:RefreshVisibility() end end) end
        if EVENT_CLOSE_BANK then EVENT_MANAGER:RegisterForEvent(PREFIX .. "_CloseBank", EVENT_CLOSE_BANK, function() self:RefreshVisibility() end) end
        if EVENT_INVENTORY_SINGLE_SLOT_UPDATE then EVENT_MANAGER:RegisterForEvent(PREFIX .. "_Inventory", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function()
            if self.button and not self.button:IsHidden() and not self.running then
                if EVENT_MANAGER then
                    EVENT_MANAGER:UnregisterForUpdate(PREFIX .. "_Debounce")
                    EVENT_MANAGER:RegisterForUpdate(PREFIX .. "_Debounce", 220, function()
                        EVENT_MANAGER:UnregisterForUpdate(PREFIX .. "_Debounce")
                        self:RefreshStatus()
                    end)
                end
            end
        end) end
    end
    self:RefreshVisibility()
end
