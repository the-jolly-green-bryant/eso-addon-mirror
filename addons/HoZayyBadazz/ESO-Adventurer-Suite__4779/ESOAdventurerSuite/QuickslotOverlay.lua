-- ESO Adventurer Suite
-- Movable quickslot overlay: shows the currently selected item/food/potion.
local EPC = ESOProgressionCoach
EPC.QuickslotOverlay = EPC.QuickslotOverlay or {}
local Q = EPC.QuickslotOverlay
local wm = WINDOW_MANAGER

local function safe(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, a,b,c = pcall(fn, ...)
    if not ok then return fallback end
    return a,b,c
end

function Q:InvalidateBinding029199()
    self.bindingText029199 = nil
end

function Q:GetUseBinding029199()
    if self.bindingText029199 == nil then
        self.bindingText029199 = EPC.GetActionBindingMarkup029199 and EPC:GetActionBindingMarkup029199("ACTION_BUTTON_9", 19) or ""
    end
    return self.bindingText029199 or ""
end

function Q:GetPosition()
    local left = tonumber(EPC.saved and EPC.saved.quickslotOverlayLeft) or -1
    local top = tonumber(EPC.saved and EPC.saved.quickslotOverlayTop) or -1
    return left, top
end

function Q:Anchor()
    if not self.frame then return end
    local left, top = self:GetPosition()
    self.frame:ClearAnchors()
    if left >= 0 and top >= 0 then
        self.frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
    else
        self.frame:SetAnchor(BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT, -170, -135)
    end
end

function Q:Create()
    if self.frame then return self.frame end
    local frame = wm:CreateTopLevelWindow("EAS_QuickslotOverlay")
    frame:SetDimensions(76, 112)
    frame:SetClampedToScreen(true)
    frame:SetMouseEnabled(false)
    frame:SetMovable(false)
    if frame.SetDrawLayer and DL_OVERLAY then frame:SetDrawLayer(DL_OVERLAY) end
    if frame.SetDrawTier and DT_HIGH then frame:SetDrawTier(DT_HIGH) end
    if frame.SetDrawLevel then frame:SetDrawLevel(1000) end
    if frame.SetTopLevel then frame:SetTopLevel(true) end

    local bg = wm:CreateControl("EAS_QuickslotOverlayBG", frame, CT_BACKDROP)
    bg:SetAnchorFill(frame)
    bg:SetCenterColor(0.012,0.015,0.022,0.88)
    bg:SetEdgeColor(0.67,0.51,0.24,0.95)
    bg:SetEdgeTexture(nil,1,1,1)

    local icon = wm:CreateControl("EAS_QuickslotOverlayIcon", frame, CT_TEXTURE)
    icon:SetAnchor(TOPLEFT, frame, TOPLEFT, 8, 8)
    icon:SetDimensions(60,60)

    local count = wm:CreateControl("EAS_QuickslotOverlayCount", frame, CT_LABEL)
    count:SetAnchor(BOTTOMRIGHT, frame, TOPLEFT, 68, 70)
    count:SetDimensions(42,20)
    count:SetFont("$(BOLD_FONT)|18|soft-shadow-thick")
    count:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    count:SetColor(1,1,1,1)

    local name = wm:CreateControl("EAS_QuickslotOverlayName", frame, CT_LABEL)
    name:SetAnchor(TOPLEFT, frame, TOPLEFT, 3, 69)
    name:SetAnchor(TOPRIGHT, frame, TOPRIGHT, -3, 69)
    name:SetDimensions(70,22)
    name:SetFont("ZoFontGameSmall")
    name:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    name:SetColor(0.95,0.82,0.42,1)

    local binding = wm:CreateControl("EAS_QuickslotOverlayBinding029199", frame, CT_LABEL)
    binding:SetAnchor(TOPLEFT, frame, TOPLEFT, 3, 91)
    binding:SetAnchor(TOPRIGHT, frame, TOPRIGHT, -3, 91)
    binding:SetDimensions(70,18)
    binding:SetFont("ZoFontGameSmall")
    binding:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    binding:SetColor(0.90,0.92,0.97,1)

    local hint = wm:CreateControl("EAS_QuickslotOverlayHint", frame, CT_LABEL)
    hint:SetAnchor(TOP, frame, BOTTOM, 0, 2)
    hint:SetDimensions(100,18)
    hint:SetFont("ZoFontGameSmall")
    hint:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    hint:SetColor(0.95,0.82,0.42,1)
    hint:SetText("DRAG")
    hint:SetHidden(true)

    frame:SetHandler("OnMoveStop", function(control)
        if EPC.saved then
            EPC.saved.quickslotOverlayLeft = control:GetLeft()
            EPC.saved.quickslotOverlayTop = control:GetTop()
        end
    end)
    self.frame,self.icon,self.count,self.name,self.binding,self.hint = frame,icon,count,name,binding,hint
    self:Anchor()
    return frame
end

-- ESO's GetSlot* APIs need the quickslot hotbar category.  Without it,
-- the same numeric slot can be read from the active ability bar and display
-- the wrong icon/name/count.
function Q:GetSelectedQuickslotData()
    local slot = tonumber(safe(GetCurrentQuickslot, 1)) or 1
    local category = HOTBAR_CATEGORY_QUICKSLOT_WHEEL

    local texture, itemName, count, used
    if category ~= nil then
        texture = safe(GetSlotTexture, "", slot, category)
        itemName = safe(GetSlotName, "", slot, category)
        count = tonumber(safe(GetSlotItemCount, 0, slot, category)) or 0
        used = safe(IsSlotUsed, false, slot, category) == true
    else
        -- Compatibility fallback for very old API versions.
        texture = safe(GetSlotTexture, "", slot)
        itemName = safe(GetSlotName, "", slot)
        count = tonumber(safe(GetSlotItemCount, 0, slot)) or 0
        used = safe(IsSlotUsed, false, slot) == true
    end

    -- Some ESO versions briefly report IsSlotUsed=false for the selected
    -- quickslot even though the icon/name are valid. Treat real slot content
    -- as authoritative so the Quick Potion / Quickslot overlay does not vanish.
    texture = texture or ""
    itemName = itemName or ""
    if texture == "" and HOTBAR_CATEGORY_QUICKSLOT_WHEEL ~= nil then
        local fallbackTexture = safe(GetSlotTexture, "", slot, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
        local fallbackName = safe(GetSlotName, "", slot, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
        local fallbackCount = tonumber(safe(GetSlotItemCount, 0, slot, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)) or 0
        if fallbackTexture ~= "" or fallbackName ~= "" then
            texture, itemName, count = fallbackTexture or "", fallbackName or "", fallbackCount
        end
    end
    used = used == true or texture ~= "" or itemName ~= ""
    return slot, texture, itemName, count, used
end

function Q:HasAttackableReticleTarget()
    if safe(DoesUnitExist, false, "reticleover") ~= true then return false end
    if safe(IsUnitAttackable, false, "reticleover") ~= true then return false end
    if type(IsUnitDead) == "function" and safe(IsUnitDead, false, "reticleover") == true then return false end
    return true
end

-- Quickslot visibility has a special "before combat" meaning.  It should not
-- be visible during normal roaming.  An attackable reticle target is treated
-- as the preparation window immediately before combat.  Once combat starts it
-- stays visible, and when combat ends it is forced hidden again until the
-- player moves the reticle off the old target and lines up another enemy.
function Q:VisibilityAllows()
    local mode = EPC.saved and EPC.saved.quickslotOverlayVisibility or "BEFORE_AND_DURING"
    if mode == "BEFORE_COMBAT" then
        mode = "BEFORE_AND_DURING"
        if EPC.saved then EPC.saved.quickslotOverlayVisibility = mode end
    elseif mode == "OUT_OF_COMBAT" then
        mode = "BEFORE_ONLY"
        if EPC.saved then EPC.saved.quickslotOverlayVisibility = mode end
    end

    -- ALWAYS is a true persistent gameplay mode. The master checkbox and
    -- gameplay-HUD suppression are still respected by Refresh().
    if mode == "ALWAYS" then
        return true
    end

    local inCombat = safe(IsUnitInCombat, false, "player") == true
    local attackable = self:HasAttackableReticleTarget()

    -- Detect combat ending even if the event was missed.
    if self.lastCombatState == true and not inCombat then
        self.postCombatNeedsTargetClear = true
    end
    self.lastCombatState = inCombat

    if mode == "COMBAT" then
        return inCombat
    elseif mode == "BEFORE_ONLY" then
        return (not inCombat) and attackable
    elseif mode == "BEFORE_AND_DURING" then
        if inCombat then return true end

        -- After combat, do not instantly re-open just because the defeated or
        -- disengaged target is still under the reticle.  Re-arm only after the
        -- player looks away; the next attackable target will show the overlay.
        if self.postCombatNeedsTargetClear then
            if not attackable then
                self.postCombatNeedsTargetClear = false
            end
            return false
        end
        return attackable
    end

    return false
end

function Q:Refresh()
    self:Create()
    local show = EPC.saved and EPC.saved.showQuickslotOverlay ~= false
    if not self.layoutMode then
        show = show and self:VisibilityAllows()
    end
    if not self.layoutMode and EPC.IsGameplayHudSuppressed and EPC:IsGameplayHudSuppressed() then
        show = false
    end

    local slot, texture, itemName, count, used = self:GetSelectedQuickslotData()
    show = show and (used or itemName ~= "" or texture ~= "") and texture ~= ""
    self.frame:SetHidden(not show)
    if not show then return end

    self.icon:SetTexture(texture)
    self.name:SetText(itemName ~= "" and itemName or ("Quickslot " .. tostring(slot)))
    self.count:SetText(count > 0 and tostring(count) or "")
    if self.binding then
        self.binding:SetText(self:GetUseBinding029199())
    end
end

function Q:SetLayoutMode(active)
    self.layoutMode = active == true
    self:Create()
    self.frame:SetMouseEnabled(self.layoutMode)
    self.frame:SetMovable(self.layoutMode)
    self.hint:SetHidden(not self.layoutMode)
    if self.layoutMode then
        -- Always expose the selected quickslot during editing, even if empty.
        self.frame:SetHidden(false)
        local slot, texture, itemName = self:GetSelectedQuickslotData()
        self.icon:SetTexture(texture or "")
        self.name:SetText(itemName ~= "" and itemName or ("Quickslot " .. tostring(slot)))
    end
    self:Refresh()
    if self.layoutMode then self.frame:SetHidden(false) end
end

function Q:ResetPosition()
    if not EPC.saved then return end
    EPC.saved.quickslotOverlayLeft = -1
    EPC.saved.quickslotOverlayTop = -1
    self:Anchor()
end

function Q:Initialize()
    self.layoutMode = false
    self.lastCombatState = safe(IsUnitInCombat, false, "player") == true
    self.postCombatNeedsTargetClear = false
    self:Create()
    local prefix = EPC.name .. "_QuickslotOverlay"
    if EVENT_PLAYER_ACTIVATED then
        EVENT_MANAGER:RegisterForEvent(prefix.."_Activated", EVENT_PLAYER_ACTIVATED, function() self:Refresh() end)
    end
    if EVENT_PLAYER_COMBAT_STATE then
        EVENT_MANAGER:RegisterForEvent(prefix.."_Combat", EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
            if inCombat == false and self.lastCombatState == true then
                self.postCombatNeedsTargetClear = true
            end
            self.lastCombatState = inCombat == true
            self:Refresh()
        end)
    end
    if EVENT_RETICLE_TARGET_CHANGED then
        EVENT_MANAGER:RegisterForEvent(prefix.."_ReticleTarget", EVENT_RETICLE_TARGET_CHANGED, function() self:Refresh() end)
    end
    if EVENT_INVENTORY_SINGLE_SLOT_UPDATE then
        EVENT_MANAGER:RegisterForEvent(prefix.."_Inventory", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function() self:Refresh() end)
    end
    if EVENT_ACTIVE_QUICKSLOT_CHANGED then
        EVENT_MANAGER:RegisterForEvent(prefix.."_ActiveQuickslot", EVENT_ACTIVE_QUICKSLOT_CHANGED, function() self:Refresh() end)
    end
    if EVENT_KEYBINDINGS_LOADED then
        EVENT_MANAGER:RegisterForEvent(prefix.."_BindingsLoaded", EVENT_KEYBINDINGS_LOADED, function() self:InvalidateBinding029199() self:Refresh() end)
    end
    if EVENT_KEYBINDING_SET then
        EVENT_MANAGER:RegisterForEvent(prefix.."_BindingSet", EVENT_KEYBINDING_SET, function() self:InvalidateBinding029199() self:Refresh() end)
    end
    if EVENT_KEYBINDING_CLEARED then
        EVENT_MANAGER:RegisterForEvent(prefix.."_BindingCleared", EVENT_KEYBINDING_CLEARED, function() self:InvalidateBinding029199() self:Refresh() end)
    end
    if EVENT_GAMEPAD_PREFERRED_MODE_CHANGED then
        EVENT_MANAGER:RegisterForEvent(prefix.."_InputMode", EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, function() self:InvalidateBinding029199() self:Refresh() end)
    end
    if EVENT_HOTBAR_SLOT_UPDATED then
        EVENT_MANAGER:RegisterForEvent(prefix.."_HotbarSlot", EVENT_HOTBAR_SLOT_UPDATED, function() self:Refresh() end)
    end
    EVENT_MANAGER:RegisterForUpdate(prefix.."_Tick", 650, function()
        if self.layoutMode == true or (self.frame and not self.frame:IsHidden()) then self:Refresh() end
    end)
    self:Refresh()
end
