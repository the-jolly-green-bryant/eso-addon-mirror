AlkoshTracker = AlkoshTracker or {}
local AT = AlkoshTracker

AT.name = "AlkoshTracker"
AT.version = "1.7.0-console.1"
AT.setId = 232
AT.abilityId = 75753 -- Line-Breaker / Roar of Alkosh proc used by ExoYs ProcSetTimer 2.14.0
AT.procEnd = 0
AT.hasFivePieces = false

local equipSlots = {
    EQUIP_SLOT_HEAD, EQUIP_SLOT_NECK, EQUIP_SLOT_CHEST, EQUIP_SLOT_SHOULDERS,
    EQUIP_SLOT_MAIN_HAND, EQUIP_SLOT_OFF_HAND, EQUIP_SLOT_WAIST, EQUIP_SLOT_LEGS,
    EQUIP_SLOT_FEET, EQUIP_SLOT_RING1, EQUIP_SLOT_RING2, EQUIP_SLOT_HAND,
    EQUIP_SLOT_BACKUP_MAIN, EQUIP_SLOT_BACKUP_OFF,
}

local twoHanders = {
    [WEAPONTYPE_FIRE_STAFF] = true, [WEAPONTYPE_FROST_STAFF] = true,
    [WEAPONTYPE_LIGHTNING_STAFF] = true, [WEAPONTYPE_HEALING_STAFF] = true,
    [WEAPONTYPE_BOW] = true, [WEAPONTYPE_TWO_HANDED_AXE] = true,
    [WEAPONTYPE_TWO_HANDED_HAMMER] = true, [WEAPONTYPE_TWO_HANDED_SWORD] = true,
}

local defaults = {
    left = 600,
    top = 600,
    iconSize = 72,
    onlyWhenFivePieces = true,
    onlyInCombat = false,
    locked = false,
    showDecimal = true,
    timerOffsetY = 0,
}

local function GetSetId(slot)
    local link = GetItemLink(BAG_WORN, slot)
    if not link or link == "" then return 0 end
    local _, _, _, _, _, setId = GetItemLinkSetInfo(link)
    return setId or 0
end

function AT:CountAlkoshPiecesOnBar()
    local count = 0
    -- Armor + jewelry always count.
    local fixed = {
        EQUIP_SLOT_HEAD, EQUIP_SLOT_NECK, EQUIP_SLOT_CHEST, EQUIP_SLOT_SHOULDERS,
        EQUIP_SLOT_WAIST, EQUIP_SLOT_LEGS, EQUIP_SLOT_FEET,
        EQUIP_SLOT_RING1, EQUIP_SLOT_RING2, EQUIP_SLOT_HAND,
    }
    for _, slot in ipairs(fixed) do
        if GetSetId(slot) == self.setId then count = count + 1 end
    end

    -- Count only the currently active weapon bar. A two-hander counts as two set pieces.
    local mainSlot, offSlot
    if GetActiveHotbarCategory() == HOTBAR_CATEGORY_BACKUP then
        mainSlot, offSlot = EQUIP_SLOT_BACKUP_MAIN, EQUIP_SLOT_BACKUP_OFF
    else
        mainSlot, offSlot = EQUIP_SLOT_MAIN_HAND, EQUIP_SLOT_OFF_HAND
    end

    if GetSetId(mainSlot) == self.setId then
        local wt = GetItemWeaponType(BAG_WORN, mainSlot)
        count = count + (twoHanders[wt] and 2 or 1)
    end
    if GetSetId(offSlot) == self.setId then count = count + 1 end
    return count
end

function AT:RefreshEquipment()
    self.hasFivePieces = self:CountAlkoshPiecesOnBar() >= 5
    self:RefreshVisibility()
end

function AT:IsHudVisible()
    if not SCENE_MANAGER then return true end
    local hud = SCENE_MANAGER:GetScene("hud")
    if not hud then return true end
    local state = hud:GetState()
    return state == SCENE_SHOWING or state == SCENE_SHOWN
end

function AT:RefreshVisibility()
    if not self.control then return end
    local wrongEquipment = self.sv.onlyWhenFivePieces and not self.hasFivePieces
    local inMenu = not self:IsHudVisible()
    local outOfCombat = self.sv.onlyInCombat and not IsUnitInCombat("player")
    self.control:SetHidden(wrongEquipment or inMenu or outOfCombat)
end

function AT:CreateUI()
    local wm = WINDOW_MANAGER
    local win = wm:CreateTopLevelWindow("AlkoshTrackerWindow")
    win:SetDimensions(self.sv.iconSize, self.sv.iconSize)
    win:SetClampedToScreen(true)
    win:SetMovable(not self.sv.locked)
    win:SetMouseEnabled(not self.sv.locked)
    win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.sv.left, self.sv.top)
    win:SetHandler("OnMoveStop", function(ctrl)
        self.sv.left = ctrl:GetLeft()
        self.sv.top = ctrl:GetTop()
    end)

    local icon = wm:CreateControl("AlkoshTrackerIcon", win, CT_TEXTURE)
    icon:SetAnchorFill(win)
    icon:SetTexture(GetAbilityIcon(self.abilityId))

    local label = wm:CreateControl("AlkoshTrackerTimer", win, CT_LABEL)
    label:SetAnchor(CENTER, win, CENTER, 0, self.sv.timerOffsetY)
    label:SetDimensions(self.sv.iconSize, self.sv.iconSize)
    label:SetFont("$(BOLD_FONT)|" .. math.floor(self.sv.iconSize * 0.48) .. "|soft-shadow-thick")
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetColor(0, 1, 0, 1)

    local inactiveX = wm:CreateControl("AlkoshTrackerInactiveX", win, CT_LABEL)
    inactiveX:SetAnchor(CENTER, win, CENTER, 0, self.sv.timerOffsetY)
    inactiveX:SetDimensions(self.sv.iconSize, self.sv.iconSize)
    inactiveX:SetFont("$(BOLD_FONT)|" .. math.max(12, math.floor(self.sv.iconSize * 0.25)) .. "|soft-shadow-thick")
    inactiveX:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    inactiveX:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    inactiveX:SetColor(1, 1, 1, 1)
    inactiveX:SetText("Synergy")

    self.control, self.icon, self.label, self.inactiveX = win, icon, label, inactiveX
    self:UpdateUI()
end

function AT:ApplySettings()
    if not self.control then return end
    self.control:SetDimensions(self.sv.iconSize, self.sv.iconSize)
    self.control:SetMovable(not self.sv.locked)
    self.control:SetMouseEnabled(not self.sv.locked)
    self.label:ClearAnchors()
    self.label:SetAnchor(CENTER, self.control, CENTER, 0, self.sv.timerOffsetY)
    self.label:SetDimensions(self.sv.iconSize, self.sv.iconSize)
    self.label:SetFont("$(BOLD_FONT)|" .. math.floor(self.sv.iconSize * 0.48) .. "|soft-shadow-thick")
    self.inactiveX:ClearAnchors()
    self.inactiveX:SetAnchor(CENTER, self.control, CENTER, 0, self.sv.timerOffsetY)
    self.inactiveX:SetDimensions(self.sv.iconSize, self.sv.iconSize)
    self.inactiveX:SetFont("$(BOLD_FONT)|" .. math.max(12, math.floor(self.sv.iconSize * 0.25)) .. "|soft-shadow-thick")
    self:RefreshEquipment()
    self:UpdateUI()
end

function AT:UpdateUI()
    if not self.icon then return end
    local remaining = math.max(0, self.procEnd - GetGameTimeMilliseconds())
    self.icon:SetAlpha(1)

    if remaining > 0 then
        self.inactiveX:SetHidden(true)
        local seconds = remaining / 1000
        -- Smooth color transition: 10s green -> 5s orange -> 3s red.
        local r, g, b = 0, 1, 0
        if seconds <= 3 then
            r, g, b = 1, 0, 0
        elseif seconds <= 5 then
            -- Interpolate from red at 3s to orange at 5s.
            local t = (seconds - 3) / 2
            r = 1
            g = 0.55 * t
            b = 0
        elseif seconds < 10 then
            -- Interpolate from orange at 5s to green at 10s.
            local t = (seconds - 5) / 5
            r = 1 - t
            g = 0.55 + (0.45 * t)
            b = 0
        end
        self.label:SetColor(r, g, b, 1)

        if remaining < 10000 and self.sv.showDecimal then
            self.label:SetText(string.format("%.1f", seconds))
        else
            self.label:SetText(tostring(math.ceil(seconds)))
        end
    else
        self.procEnd = 0
        self.label:SetText("")
        self.inactiveX:SetHidden(false)
    end
end

function AT.OnCombatEvent(_, result, _, _, _, _, sourceName, sourceType, _, _, _, _, _, _, _, _, abilityId)
    if abilityId ~= AT.abilityId then return end
    if sourceType ~= COMBAT_UNIT_TYPE_PLAYER then return end
    -- The proc event can arrive in several successful result forms; refresh the timer on any matching player event.
    local duration = GetAbilityDuration(AT.abilityId)
    if duration and duration > 0 then
        AT.procEnd = GetGameTimeMilliseconds() + duration
        AT:UpdateUI()
    end
end

function AT:Initialize()
    self.sv = ZO_SavedVars:NewAccountWide("AlkoshTrackerSV", 1, nil, defaults)
    self:CreateUI()
    if self.CreateMenu then self:CreateMenu() end

    EVENT_MANAGER:RegisterForEvent(self.name .. "Combat", EVENT_COMBAT_EVENT, self.OnCombatEvent)
    EVENT_MANAGER:AddFilterForEvent(self.name .. "Combat", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, self.abilityId)
    EVENT_MANAGER:AddFilterForEvent(self.name .. "Combat", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

    EVENT_MANAGER:RegisterForEvent(self.name .. "Equip", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(_, bagId)
        if bagId == BAG_WORN then zo_callLater(function() self:RefreshEquipment() end, 100) end
    end)
    EVENT_MANAGER:RegisterForEvent(self.name .. "WeaponPair", EVENT_ACTIVE_WEAPON_PAIR_CHANGED, function()
        zo_callLater(function() self:RefreshEquipment() end, 100)
    end)
    EVENT_MANAGER:RegisterForEvent(self.name .. "CombatState", EVENT_PLAYER_COMBAT_STATE, function()
        self:RefreshVisibility()
    end)
    EVENT_MANAGER:RegisterForEvent(self.name .. "Activated", EVENT_PLAYER_ACTIVATED, function()
        self.procEnd = 0
        zo_callLater(function() self:RefreshEquipment(); self:UpdateUI() end, 300)
    end)
    EVENT_MANAGER:RegisterForUpdate(self.name .. "Update", 100, function() self:UpdateUI() end)

    -- Keep the tracker completely hidden while any menu/scene replaces the normal HUD.
    local hudScene = SCENE_MANAGER and SCENE_MANAGER:GetScene("hud")
    if hudScene then
        hudScene:RegisterCallback("StateChange", function()
            self:RefreshVisibility()
        end)
    end
    local hudUiScene = SCENE_MANAGER and SCENE_MANAGER:GetScene("hudui")
    if hudUiScene then
        hudUiScene:RegisterCallback("StateChange", function()
            self:RefreshVisibility()
        end)
    end

    self:RefreshEquipment()
end


function AT:CreateMenu()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local panel = {
        type = "panel",
        name = "Alkoshtracker by JH",
        displayName = "Alkoshtracker by JH",
        author = "JH",
        version = self.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }
    LAM:RegisterAddonPanel("AlkoshTrackerOptions", panel)

    local options = {
        {
            type = "description",
            text = "Minimal tracker for Roar of Alkosh / Line-Breaker. You can move the Icon by typing /atmove and lock it in place with /atmove.",
        },
        {
            type = "checkbox",
            name = "Only show when 5x Alkosh is active",
            tooltip = "When enabled, the icon is only shown when at least 5 Alkosh set pieces count on the currently active weapon bar. When disabled, the icon remains visible.",
            getFunc = function() return self.sv.onlyWhenFivePieces end,
            setFunc = function(v) self.sv.onlyWhenFivePieces = v; self:RefreshEquipment() end,
            default = true,
        },
        {
            type = "checkbox",
            name = "Only show in combat",
            tooltip = "When enabled, the Alkosh tracker is hidden outside combat. Other display options, such as the 5x Alkosh check, still apply during combat.",
            getFunc = function() return self.sv.onlyInCombat end,
            setFunc = function(v) self.sv.onlyInCombat = v; self:RefreshVisibility() end,
            default = false,
        },
        {
            type = "checkbox",
            name = "Lock position",
            getFunc = function() return self.sv.locked end,
            setFunc = function(v) self.sv.locked = v; self:ApplySettings() end,
            default = false,
        },
        {
            type = "slider",
            name = "Icon size",
            min = 32, max = 160, step = 2,
            getFunc = function() return self.sv.iconSize end,
            setFunc = function(v) self.sv.iconSize = v; self:ApplySettings() end,
            default = 72,
        },
        {
            type = "slider",
            name = "Timer Y-axis",
            tooltip = "Moves the countdown and the Synergy text vertically together. Negative values move them up, positive values move them down.",
            min = -100, max = 100, step = 1,
            getFunc = function() return self.sv.timerOffsetY end,
            setFunc = function(v) self.sv.timerOffsetY = v; self:ApplySettings() end,
            default = 0,
        },
        {
            type = "checkbox",
            name = "Show decimal below 10 seconds",
            getFunc = function() return self.sv.showDecimal end,
            setFunc = function(v) self.sv.showDecimal = v end,
            default = true,
        },
        {
            type = "button",
            name = "Reset position",
            func = function()
                self.sv.left, self.sv.top = 600, 600
                self.control:ClearAnchors()
                self.control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.sv.left, self.sv.top)
            end,
        },
    }
    LAM:RegisterOptionControls("AlkoshTrackerOptions", options)
end


-- Console gamepad movement: /atmove toggles left-stick positioning.
local moveMode = false
local moveLastMs = 0
local MOVE_SPEED = 420

local function SavePosition()
    if not AT.control or not AT.sv then return end
    local l, t = AT.control:GetLeft(), AT.control:GetTop()
    if l and t then AT.sv.left, AT.sv.top = l, t end
end

local function MoveUpdate()
    if not moveMode or not AT.control then return end
    local now = GetFrameTimeMilliseconds()
    local dt = moveLastMs > 0 and ((now - moveLastMs) / 1000) or 0
    moveLastMs = now
    local x = GetGamepadLeftStickX and GetGamepadLeftStickX() or 0
    local y = GetGamepadLeftStickY and GetGamepadLeftStickY() or 0
    if math.abs(x) < 0.12 then x = 0 end
    if math.abs(y) < 0.12 then y = 0 end
    if x ~= 0 or y ~= 0 then
        local left = (AT.control:GetLeft() or AT.sv.left) + x * MOVE_SPEED * dt
        local top  = (AT.control:GetTop() or AT.sv.top) - y * MOVE_SPEED * dt
        AT.control:ClearAnchors()
        AT.control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
        SavePosition()
    end
end

local function ToggleMoveMode()
    moveMode = not moveMode
    moveLastMs = GetFrameTimeMilliseconds()
    if moveMode then
        EVENT_MANAGER:RegisterForUpdate(AT.name .. "Move", 16, MoveUpdate)
        d("[Alkosh Tracker] Move ON - move with left stick, /atmove to finish.")
    else
        EVENT_MANAGER:UnregisterForUpdate(AT.name .. "Move")
        SavePosition()
        d("[Alkosh Tracker] Move OFF - position saved.")
    end
end
SLASH_COMMANDS["/atmove"] = ToggleMoveMode

local function OnAddonLoaded(_, addonName)
    if addonName ~= AT.name then return end
    EVENT_MANAGER:UnregisterForEvent(AT.name, EVENT_ADD_ON_LOADED)
    AT:Initialize()
end
EVENT_MANAGER:RegisterForEvent(AT.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
