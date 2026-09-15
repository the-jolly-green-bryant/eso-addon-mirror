-- ESO Adventurer Suite
-- v0.29.647 - World Ultimate readiness, detached from the Dual Action Bar chain.
-- No RefreshDynamic/AbilityOverlay wrapper is installed. Ultimate presentation is
-- refreshed by UltimatePercentFix's lightweight 500ms two-slot pulse instead.

local EPC = ESOProgressionCoach
if not EPC then return end

local A = EPC.AbilityOverlays
local D = EPC.DualActionBar
local WM = WINDOW_MANAGER

EPC.WorldUltimateReadiness029640 = EPC.WorldUltimateReadiness029640 or {}
local W = EPC.WorldUltimateReadiness029640
local POST_SWAP_COOLDOWN_MS = 1200

local function safe(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, a = pcall(fn, ...)
    if not ok or a == nil then return fallback end
    return a
end

local function nowMs()
    if type(GetFrameTimeMilliseconds) == "function" then return tonumber(GetFrameTimeMilliseconds()) or 0 end
    if type(GetGameTimeMilliseconds) == "function" then return tonumber(GetGameTimeMilliseconds()) or 0 end
    return 0
end

local function swapPresentationBlocked()
    local stamp = nowMs()
    local untilMs = tonumber(EPC.weaponSwapBroadRefreshUntil029636)
        or tonumber(EPC.weaponSwapSettlingUntil029636) or 0
    return stamp > 0 and untilMs > 0 and stamp < (untilMs + POST_SWAP_COOLDOWN_MS)
end

local function normalCategories()
    local primary = rawget(_G, "HOTBAR_CATEGORY_PRIMARY")
    local backup = rawget(_G, "HOTBAR_CATEGORY_BACKUP")
    if primary == nil then primary = 0 end
    if backup == nil then backup = 1 end
    return primary, backup
end

local function activeCategory()
    return safe(GetActiveHotbarCategory, nil)
end

local function ultimateSlot()
    local base = tonumber(rawget(_G, "ACTION_BAR_ULTIMATE_SLOT_INDEX"))
    if base ~= nil then return base + 1 end
    if D and type(D.slots) == "table" and #D.slots > 0 then return D.slots[#D.slots] end
    return 8
end

local function inSpecialHotbar()
    local category = activeCategory()
    local primary, backup = normalCategories()
    if category == nil or category == primary or category == backup then return false end
    if D and type(D.IsSingleTransformedHotbar029554) == "function" then
        local ok, transformed = pcall(D.IsSingleTransformedHotbar029554, D, category)
        if ok then return transformed == true end
    end
    return true
end

W.worldAbilityCache = W.worldAbilityCache or {}
W.slotCache029647 = W.slotCache029647 or {}

function W:Invalidate029647()
    self.slotCache029647 = {}
end

local function isWorldAbility(abilityId)
    abilityId = tonumber(abilityId) or 0
    if abilityId <= 0 then return false end
    local cached = W.worldAbilityCache[abilityId]
    if cached ~= nil then return cached == true end
    local worldType = rawget(_G, "SKILL_TYPE_WORLD")
    local result = false
    if worldType ~= nil and type(GetSpecificSkillAbilityKeysByAbilityId) == "function" then
        result = safe(GetSpecificSkillAbilityKeysByAbilityId, nil, abilityId) == worldType
    end
    W.worldAbilityCache[abilityId] = result
    return result
end

local function getUltimateCost(slot, category, abilityId)
    local cost = tonumber(safe(GetSlotAbilityCost, 0, slot, category)) or 0
    if cost <= 0 and type(GetAbilityCost) == "function" and rawget(_G, "COMBAT_MECHANIC_FLAGS_ULTIMATE") ~= nil then
        cost = tonumber(safe(GetAbilityCost, 0, abilityId, COMBAT_MECHANIC_FLAGS_ULTIMATE, nil, "player")) or 0
    end
    return math.max(0, cost)
end

local function getStatic(category)
    if category == nil then return nil end
    local cached = W.slotCache029647[category]
    if cached ~= nil then return cached ~= false and cached or nil end
    local slot = ultimateSlot()
    if safe(IsSlotUsed, false, slot, category) ~= true then
        W.slotCache029647[category] = false
        return nil
    end
    local abilityId = tonumber(safe(GetSlotBoundId, 0, slot, category)) or 0
    if abilityId <= 0 or not isWorldAbility(abilityId) then
        W.slotCache029647[category] = false
        return nil
    end
    local info = {
        category = category,
        slot = slot,
        abilityId = abilityId,
        icon = tostring(safe(GetSlotTexture, "", slot, category) or ""),
        name = tostring(safe(GetSlotName, "", slot, category) or ""),
        cost = getUltimateCost(slot, category, abilityId),
    }
    W.slotCache029647[category] = info
    return info
end

local function readWorldUltimate(category)
    local static = getStatic(category)
    if not static then return nil end
    local flag = rawget(_G, "COMBAT_MECHANIC_FLAGS_ULTIMATE")
    if flag == nil then return nil end
    local current = tonumber(safe(GetUnitPower, 0, "player", flag)) or 0
    return {
        category = static.category, slot = static.slot, abilityId = static.abilityId,
        icon = static.icon, name = static.name, cost = static.cost, current = current,
        ready = static.cost > 0 and current >= static.cost,
    }
end

local function worldUltimates()
    if inSpecialHotbar() then return nil, nil end
    local primary, backup = normalCategories()
    return readWorldUltimate(primary), readWorldUltimate(backup)
end

local function readyInactive()
    local current = activeCategory()
    local a, b = worldUltimates()
    if a and a.ready and a.category ~= current then return a end
    if b and b.ready and b.category ~= current then return b end
    return nil
end

local function readyKey(info)
    if not info or not info.ready then return nil end
    return tostring(info.category) .. ":" .. tostring(info.abilityId)
end

local function playReadyOnce(info)
    local key = readyKey(info)
    if not key or W.lastReadySoundKey == key then return end
    W.lastReadySoundKey = key
    local sound = SOUNDS and rawget(SOUNDS, "ABILITY_ULTIMATE_READY")
    if sound and type(PlaySound) == "function" then pcall(PlaySound, sound) end
end

local function ensureBadge(widget)
    if not widget or not WM or not GuiRoot then return nil end
    if widget.epcWorldReadyBadge029640 then return widget.epcWorldReadyBadge029640 end
    local badge = WM:CreateControl(nil, GuiRoot, CT_CONTROL)
    badge:SetDimensions(42, 42)
    badge:SetAnchor(LEFT, widget, RIGHT, 7, 0)
    badge:SetMouseEnabled(false)
    badge:SetHidden(true)
    local bg = WM:CreateControl(nil, badge, CT_BACKDROP)
    bg:SetAnchorFill(badge)
    bg:SetCenterColor(0.02, 0.025, 0.04, 0.94)
    bg:SetEdgeColor(1.00, 0.78, 0.16, 1.00)
    bg:SetEdgeTexture(nil, 4, 4, 4)
    local icon = WM:CreateControl(nil, badge, CT_TEXTURE)
    icon:SetAnchor(TOPLEFT, badge, TOPLEFT, 3, 3)
    icon:SetAnchor(BOTTOMRIGHT, badge, BOTTOMRIGHT, -3, -3)
    local ready = WM:CreateControl(nil, badge, CT_LABEL)
    ready:SetAnchor(BOTTOMLEFT, badge, BOTTOMLEFT, -7, 2)
    ready:SetAnchor(BOTTOMRIGHT, badge, BOTTOMRIGHT, 7, 2)
    ready:SetHeight(16)
    ready:SetFont("$(BOLD_FONT)|11|soft-shadow-thick")
    ready:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    ready:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    ready:SetColor(1.00, 0.86, 0.30, 1.00)
    ready:SetText("SWAP")
    if badge.SetDrawLayer and DL_OVERLAY then badge:SetDrawLayer(DL_OVERLAY) end
    if badge.SetDrawTier and DT_HIGH then badge:SetDrawTier(DT_HIGH) end
    if badge.SetDrawLevel then badge:SetDrawLevel(2600) end
    badge.epcIcon = icon
    badge.epcReady = ready
    widget.epcWorldReadyBadge029640 = badge
    return badge
end

local function refreshAbility()
    if not A or not A.widgets or #A.widgets == 0 then return end
    local widget = A.widgets[#A.widgets]
    local badge = ensureBadge(widget)
    if not badge then return end
    local info = readyInactive()
    local show = info ~= nil and EPC.saved and EPC.saved.showAbilityOverlays ~= false
        and A.layoutMode ~= true
        and not (EPC.IsGameplayHudSuppressed and EPC:IsGameplayHudSuppressed())
    badge:SetHidden(not show)
    if not show then widget.epcWorldReadyKey029640 = nil return end
    if type(widget.GetScale) == "function" and type(badge.SetScale) == "function" then
        badge:SetScale(tonumber(safe(widget.GetScale, 1, widget)) or 1)
    end
    local key = readyKey(info)
    if widget.epcWorldReadyKey029640 ~= key then
        widget.epcWorldReadyKey029640 = key
        badge.epcIcon:SetTexture(info.icon or "")
    end
    playReadyOnce(info)
end

local function refreshDual()
    if not D or not D.rows or inSpecialHotbar() then return end
    local current = activeCategory()
    local ultOrdinal = #(D.slots or {})
    if ultOrdinal <= 0 then return end
    local a, b = worldUltimates()
    local byCategory = {}
    if a then byCategory[a.category] = a end
    if b then byCategory[b.category] = b end
    local anyReady = false
    for _, row in ipairs(D.rows) do
        local category = row.epcCategory
        local frame = row.slots and row.slots[ultOrdinal]
        local info = byCategory[category]
        local ready = info and info.ready == true
        local inactive = category ~= current
        if ready then anyReady = true end
        if frame then
            if frame.epcReadyGlow029365 and ready then
                frame.epcReadyGlow029365:SetHidden(false)
                frame.epcReadyGlow029365:SetAlpha(inactive and 1.0 or 0.92)
            end
            if frame.epcSwap then
                if ready and inactive then
                    frame.epcSwap:SetText("SWAP")
                    frame.epcSwap:SetHidden(false)
                elseif not (D.smartNeedsSwap029189 == true and D.smartCategory029189 == category) then
                    frame.epcSwap:SetHidden(true)
                end
            end
            if ready and inactive and row.SetAlpha then
                local alpha = math.max(0.10, math.min(1.0,
                    (tonumber(EPC.saved and EPC.saved.dualActionBarInactiveAlpha029189) or 45) / 100))
                row:SetAlpha(math.max(alpha, 0.78))
            end
        end
        if ready and inactive then playReadyOnce(info) end
    end
    if not anyReady then W.lastReadySoundKey = nil end
end

function W:RefreshPresentation029647()
    if swapPresentationBlocked() then return end
    refreshAbility()
    refreshDual()
end

if EVENT_MANAGER then
    local prefix = (EPC.name or "ESOAdventurerSuite") .. "_WorldReadyCache029647"
    local function invalidate() W:Invalidate029647() end
    if rawget(_G, "EVENT_ACTION_SLOT_UPDATED") then
        EVENT_MANAGER:RegisterForEvent(prefix .. "_Slot", EVENT_ACTION_SLOT_UPDATED, invalidate)
    end
    if rawget(_G, "EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED") then
        EVENT_MANAGER:RegisterForEvent(prefix .. "_Bars", EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, invalidate)
    end
end

SLASH_COMMANDS = SLASH_COMMANDS or {}
SLASH_COMMANDS["/easworldready"] = function()
    local active = activeCategory()
    local a, b = worldUltimates()
    local function describe(info)
        if not info then return "none" end
        return string.format("%s id=%d cost=%d ult=%d ready=%s",
            info.name ~= "" and info.name or "World Ultimate", info.abilityId,
            math.floor(info.cost + 0.5), math.floor(info.current + 0.5),
            info.ready and "yes" or "no")
    end
    local text = "EAS World Ready | active=" .. tostring(active)
        .. " | primary=" .. describe(a) .. " | backup=" .. describe(b)
    if type(d) == "function" then d(text) end
end
