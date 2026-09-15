-- ESO Adventurer Suite
-- v0.29.646 - transformed/special hotbar support with normal-swap isolation.
-- Werewolf/temporary hotbars still get structural refreshes. Ordinary Primary
-- <-> Backup weapon swaps never use this structural path, even if its listeners
-- survive or are reinstalled later.

local EPC = ESOProgressionCoach
if not EPC or not EPC.DualActionBar then return end

local D = EPC.DualActionBar

local function safe(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, a = pcall(fn, ...)
    if not ok or a == nil then return fallback end
    return a
end

local function nowMs()
    if type(GetFrameTimeMilliseconds) == "function" then
        return tonumber(safe(GetFrameTimeMilliseconds, 0)) or 0
    end
    if type(GetGameTimeMilliseconds) == "function" then
        return tonumber(safe(GetGameTimeMilliseconds, 0)) or 0
    end
    return 0
end

local function activeCategory()
    return safe(GetActiveHotbarCategory, nil)
end

local function normalCategories()
    local primary = rawget(_G, "HOTBAR_CATEGORY_PRIMARY")
    local backup = rawget(_G, "HOTBAR_CATEGORY_BACKUP")
    if primary == nil then primary = 0 end
    if backup == nil then backup = 1 end
    return primary, backup
end

local function isWerewolfForm()
    local fn = rawget(_G, "IsWerewolf")
    if type(fn) == "function" then
        return safe(fn, false) == true
    end
    return false
end

local function normalWeaponSwapBlocked()
    local stamp = nowMs()
    local untilMs = tonumber(EPC.weaponSwapBroadRefreshUntil029636)
        or tonumber(EPC.weaponSwapSettlingUntil029636)
        or tonumber(EPC.weaponSwapSettlingUntil029635)
        or 0
    if stamp <= 0 or stamp >= untilMs then return false end

    local category = activeCategory()
    local primary, backup = normalCategories()
    if category ~= primary and category ~= backup then return false end
    if isWerewolfForm() then return false end
    return true
end

function D:IsSingleTransformedHotbar029554(category)
    category = category ~= nil and category or activeCategory()
    local primary, backup = normalCategories()

    if category ~= nil and category ~= primary and category ~= backup then
        return true
    end
    return isWerewolfForm()
end

function D:ApplyTransformedHotbarLayout029554(force)
    if not self.window or not self.rows or #self.rows < 2 then return false end

    -- Structural layout changes are never needed for ordinary weapon swapping.
    if self.layoutMode ~= true and normalWeaponSwapBlocked() and self._transformed029554 ~= true then
        return false
    end

    local category = activeCategory()
    local transformed = self:IsSingleTransformedHotbar029554(category)
    local row1, row2 = self.rows[1], self.rows[2]

    if transformed then
        if not self._transformed029554 or self._transformedCategory029554 ~= category or force == true then
            self._transformed029554 = true
            self._transformedCategory029554 = category
            self._normalRowCategories029554 = self._normalRowCategories029554 or {
                row1 and row1.epcCategory,
                row2 and row2.epcCategory,
            }
        end

        if row1 then
            row1.epcCategory = category
            row1.epcBarNumber = 1
            if row1.SetHidden then row1:SetHidden(false) end
            if row1.SetAlpha then row1:SetAlpha(1) end
        end
        if row2 and row2.SetHidden then row2:SetHidden(true) end

        local size = tonumber(EPC.saved and EPC.saved.dualActionBarIconSize029189) or 54
        size = math.max(42, math.min(78, size))
        local oneRowHeight = size + 8
        local currentWidth = self.window.GetWidth and self.window:GetWidth() or 0
        if self.window.SetDimensions and currentWidth and currentWidth > 0 then
            self.window:SetDimensions(currentWidth, oneRowHeight)
        elseif self.window.SetHeight then
            self.window:SetHeight(oneRowHeight)
        end
        return true
    end

    if self._transformed029554 then
        self._transformed029554 = false
        self._transformedCategory029554 = nil

        local order = type(self.GetBarOrder) == "function" and self:GetBarOrder() or nil
        if type(order) == "table" then
            for index, row in ipairs(self.rows) do
                local entry = order[index]
                if entry then
                    row.epcCategory = entry.category
                    row.epcBarNumber = entry.number
                end
                if row.SetHidden then row:SetHidden(false) end
            end
        else
            local primary, backup = normalCategories()
            if row1 then row1.epcCategory = primary row1.epcBarNumber = 1 if row1.SetHidden then row1:SetHidden(false) end end
            if row2 then row2.epcCategory = backup row2.epcBarNumber = 2 if row2.SetHidden then row2:SetHidden(false) end end
        end

        if type(self.ApplyDimensions) == "function" then self:ApplyDimensions(true) end
    end
    return false
end

if type(D.RefreshStatic029311) == "function" and not D._transformedStaticWrap029554 then
    local base = D.RefreshStatic029311
    function D:RefreshStatic029311(...)
        if self.layoutMode ~= true and normalWeaponSwapBlocked() and self._transformed029554 ~= true then
            return nil
        end
        self:ApplyTransformedHotbarLayout029554(false)
        local result = base(self, ...)
        self:ApplyTransformedHotbarLayout029554(false)
        return result
    end
    D._transformedStaticWrap029554 = true
end

if type(D.RefreshDynamic029311) == "function" and not D._transformedDynamicWrap029554 then
    local base = D.RefreshDynamic029311
    function D:RefreshDynamic029311(force)
        if self.layoutMode ~= true and normalWeaponSwapBlocked() and self._transformed029554 ~= true then
            return nil
        end

        local category = activeCategory()
        local changed = category ~= self._lastSeenHotbar029554
        self._lastSeenHotbar029554 = category
        local wasTransformed = self._transformed029554 == true
        local isTransformed = self:IsSingleTransformedHotbar029554(category)

        if changed or wasTransformed ~= isTransformed then
            self:ApplyTransformedHotbarLayout029554(true)
            if type(self.RefreshStatic029311) == "function" then
                self:RefreshStatic029311(true)
            end
            force = true
        else
            self:ApplyTransformedHotbarLayout029554(false)
        end

        return base(self, force)
    end
    D._transformedDynamicWrap029554 = true
end

-- Event response is retained only for genuine transformed/special hotbar state.
-- Ordinary front/back swaps are explicitly ignored here, so this module cannot
-- become a swap hitch even if another file fails to unregister its listeners.
if EVENT_MANAGER then
    local prefix = (EPC.name or "ESOAdventurerSuite") .. "_TransformBar029554"
    local function refreshSoon()
        if not EVENT_MANAGER then return end
        if normalWeaponSwapBlocked() and D._transformed029554 ~= true then return end

        local category = activeCategory()
        local transformedNow = D:IsSingleTransformedHotbar029554(category)
        if not transformedNow and D._transformed029554 ~= true then return end

        EVENT_MANAGER:UnregisterForUpdate(prefix .. "_Deferred")
        EVENT_MANAGER:RegisterForUpdate(prefix .. "_Deferred", 80, function()
            EVENT_MANAGER:UnregisterForUpdate(prefix .. "_Deferred")
            if normalWeaponSwapBlocked() and D._transformed029554 ~= true then return end
            if D and D.RefreshStatic029311 then D:RefreshStatic029311(true) end
            if D and D.RefreshDynamic029311 then D:RefreshDynamic029311(true) end
        end)
    end

    if rawget(_G, "EVENT_ACTIVE_WEAPON_PAIR_CHANGED") then
        EVENT_MANAGER:RegisterForEvent(prefix .. "_Pair", EVENT_ACTIVE_WEAPON_PAIR_CHANGED, refreshSoon)
    end
    if rawget(_G, "EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED") then
        EVENT_MANAGER:RegisterForEvent(prefix .. "_Hotbar", EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED, refreshSoon)
    end
    if rawget(_G, "EVENT_ACTION_SLOT_UPDATED") then
        EVENT_MANAGER:RegisterForEvent(prefix .. "_Slot", EVENT_ACTION_SLOT_UPDATED, refreshSoon)
    end
end

if D.window then
    D:ApplyTransformedHotbarLayout029554(true)
    if D.RefreshStatic029311 then D:RefreshStatic029311(true) end
    if D.RefreshDynamic029311 then D:RefreshDynamic029311(true) end
end
