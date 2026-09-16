-- Common Works -- quality-of-life tweaks that ride on other parts of the UI:
-- the TTC context menu, the usable-ability glow, mounted toggle-sprint and PvP health bars.

CommonWorksUI = CommonWorksUI or {}
local CW = CommonWorksUI
local EM = EVENT_MANAGER

-- Promote TTC's two web actions to the main menu, retaining its callbacks and settings.
-- OptionalDependsOn ensures TTC initializes first.
--
-- TTC stores quality as GetItemLinkQuality() - 1, so legendary lands on 4.
local TTC_LEGENDARY_QUALITY = ITEM_FUNCTIONAL_QUALITY_LEGENDARY
local TTC_GOLD_QUALITY_ID = TTC_LEGENDARY_QUALITY - 1

-- Only the word is colored, so the rest matches every other menu line. Resolved once:
-- the quality palette does not change at runtime.
local ttcGoldWord
local function TTCGoldWord()
    ttcGoldWord = ttcGoldWord or GetItemQualityColor(TTC_LEGENDARY_QUALITY):Colorize("GOLD")
    return ttcGoldWord
end

-- Gear fields used by SearchOnline/PriceDetailOnline differ only in QualityID,
-- so changing it describes gold gear (including jewelry). Glyph TTC ids also
-- encode quality in the name, so exclude them.
local function IsTTCGoldCandidate(itemInfo)
    if type(itemInfo) ~= "table" or itemInfo.ID == nil then return false end
    if type(itemInfo.QualityID) ~= "number" then return false end
    if itemInfo.QualityID >= TTC_GOLD_QUALITY_ID then return false end
    return itemInfo.ItemType == ITEMTYPE_WEAPON or itemInfo.ItemType == ITEMTYPE_ARMOR
end

-- Check once: this replaces LibCustomMenu globals; disabling requires /reloadui.
function CW.InstallTTCContextMenuPromotion()
    if CW.ttcContextMenuPromotionInstalled then return end
    if CW.SavedVars.ttcPromoteMenuEntries == false then return end
    if not (TamrielTradeCentre and TamrielTradeCentrePrice) then return end
    if not (TamrielTradeCentre_ItemInfo and TamrielTradeCentre_ItemInfo.New) then return end
    if not (TTC_SEARCHONLINE and TTC_PRICEHISTORYONLINE) then return end

    local searchOnlineLabel = GetString(TTC_SEARCHONLINE)
    local priceHistoryLabel = GetString(TTC_PRICEHISTORYONLINE)

    local originalAddCustomMenuItem = AddCustomMenuItem
    local originalAddCustomSubMenuItem = AddCustomSubMenuItem
    local originalShowMenu = ShowMenu
    local originalItemInfoNew = TamrielTradeCentre_ItemInfo.New

    -- Capture itemInfo at construction: TTC calls New(itemLink) immediately before
    -- MakeContextMenuEntries. This also identifies when a TTC menu is being built.
    local lastItemInfo, ttcBuilding = nil, false
    function TamrielTradeCentre_ItemInfo.New(self, itemLink)
        local itemInfo = originalItemInfoNew(self, itemLink)
        lastItemInfo = itemInfo
        ttcBuilding = true
        return itemInfo
    end

    -- Read and cleared by ShowMenu. Mirrors TTC's own enable flags without reading its
    -- locals: no TTC entry, no gold counterpart.
    local sawSearchOnline, sawPriceHistory = false, false

    -- Second return says which of the two it was, so only a confirmed TTC call arms
    -- the matching gold entry.
    local function PromotedLabel(label)
        if label == searchOnlineLabel then
            return string.format(CW.L.TTC_PROMOTED, searchOnlineLabel), true
        elseif label == priceHistoryLabel then
            return string.format(CW.L.TTC_PROMOTED, priceHistoryLabel), false
        end
    end

    local function MarkPromoted(isSearch)
        if isSearch then sawSearchOnline = true else sawPriceHistory = true end
    end

    -- Configured without a submenu, the two actions are already on the main menu and
    -- only need renaming.
    function AddCustomMenuItem(mytext, ...)
        local promotedLabel, isSearch = PromotedLabel(mytext)
        if promotedLabel and ttcBuilding then
            mytext = promotedLabel
            MarkPromoted(isSearch)
        end
        return originalAddCustomMenuItem(mytext, ...)
    end

    function AddCustomSubMenuItem(mytext, entries, myfont, normalColor, highlightColor, itemYPad, callback)
        if mytext ~= "TTC" or type(entries) ~= "table" or not ttcBuilding then
            return originalAddCustomSubMenuItem(mytext, entries, myfont, normalColor, highlightColor, itemYPad, callback)
        end

        local submenuEntries = {}
        local promotedEntries = {}

        for i = 1, #entries do
            local entry = entries[i]
            local promotedLabel, isSearch
            if type(entry) == "table" then promotedLabel, isSearch = PromotedLabel(entry.label) end
            if promotedLabel then
                MarkPromoted(isSearch)
                promotedEntries[#promotedEntries + 1] = {
                    label = promotedLabel,
                    entry = entry,
                }
            else
                submenuEntries[#submenuEntries + 1] = entry
            end
        end

        if #promotedEntries == 0 then
            return originalAddCustomSubMenuItem(mytext, entries, myfont, normalColor, highlightColor, itemYPad, callback)
        end

        local submenuIndex = originalAddCustomSubMenuItem(
            mytext,
            submenuEntries,
            myfont,
            normalColor,
            highlightColor,
            itemYPad,
            callback
        )

        -- After the submenu: TTC, Search Online, View Price History.
        for i = 1, #promotedEntries do
            local promoted = promotedEntries[i]
            local entry = promoted.entry
            originalAddCustomMenuItem(
                promoted.label,
                entry.callback,
                entry.itemType,
                entry.myfont,
                entry.normalColor,
                entry.highlightColor,
                entry.itemYPad,
                entry.horizontalAlignment,
                entry.isHighlighted,
                entry.onEnter,
                entry.onExit,
                entry.enabled
            )
        end

        return submenuIndex
    end

    -- Both submenu modes end here; append gold entries last.
    -- Copy itemInfo now so callbacks use the item this menu opened for.
    function ShowMenu(...)
        local search, history = sawSearchOnline, sawPriceHistory
        sawSearchOnline, sawPriceHistory = false, false
        ttcBuilding = false

        if (search or history) and IsTTCGoldCandidate(lastItemInfo) then
            local goldItemInfo = ZO_ShallowTableCopy(lastItemInfo)
            goldItemInfo.QualityID = TTC_GOLD_QUALITY_ID

            local gold = TTCGoldWord()
            if search then
                originalAddCustomMenuItem(string.format(CW.L.TTC_PROMOTED_GOLD, searchOnlineLabel, gold), function()
                    TamrielTradeCentrePrice:SearchOnline(goldItemInfo)
                end)
            end
            if history then
                originalAddCustomMenuItem(string.format(CW.L.TTC_PROMOTED_GOLD, priceHistoryLabel, gold), function()
                    TamrielTradeCentrePrice:PriceDetailOnline(goldItemInfo)
                end)
            end
        end

        return originalShowMenu(...)
    end

    CW.ttcContextMenuPromotionInstalled = true
end

-- Reuse ActionButton's idle gp_skillGlow.dds texture (actionbutton.lua:48).
-- FancyActionBar+ post-hooks UpdateUsable too (main.lua:5248); neither hook requires the other.
-- `useFailure` covers cost and non-cost failures, including a siphon's missing corpse
-- that IsSlotUsable misses; `usable` also includes cooldown (actionbutton.lua:405).
-- Both the base game and FAB+ refresh useFailure before UpdateUsable
-- (actionbutton.lua:319, main.lua:5240).

local glowIds = {}
local glowHooked = false

-- Repaint unconditionally: casts leave glowAnimation's texture hidden at alpha 0
-- (actionbutton.lua:689). Leave untouched gamepad glows shown at alpha 0 to preserve their flash.
local function OnUpdateUsable(button)
    local glow = button.glow
    if not glow then return end
    local id = CW.SlotAbilityId(button:GetSlot(), button:GetHotbarCategory())
    local on = glowIds[id] ~= nil and not button.useFailure
    if not on and not button.cwGlow then return end
    button.cwGlow = on
    glow:SetHidden(not on and not IsInGamepadPreferredMode())
    glow:SetAlpha(on and 1 or 0)
end

-- entry.glow is the sole switch; install the hook on first use.
-- Refresh live slots to apply changes immediately, including clearing the last glow.
function CW.UpdateAbilityGlow()
    ZO_ClearTable(glowIds)
    for _, entry in ipairs(CW.GcdAlertStore()) do
        if entry.glow then glowIds[entry.id] = true end
    end

    if next(glowIds) and not glowHooked then
        SecurePostHook(ActionButton, "UpdateUsable", OnUpdateUsable)
        glowHooked = true
    end

    for slot = 3, 8 do
        local button = ZO_ActionBar_GetButton(slot)
        if button then button:UpdateUsable() end
    end
end

-- Native Toggle Sprint while mounted
local mountSprintForced = false
local mountSprintRestoreValue = nil
local mountPowerEventRegistered = false
local mountDrainClearCall
local lastMountStamina = nil
local MOUNT_SPRINT_WATCH = CW.name .. "MountSprintWatch"
local mountSprintWatching = false
local mountEventRegistered = false
local mountSprintLastWritten = nil
local UpdateMountSprintWatch

local function GetNativeToggleSprint()
    return GetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_TOGGLE_SPRINT)
end

local function NativeToggleSprintIsOn(value)
    return tostring(value) == "1"
end

local function NotifyToggleSprint(value)
    d("|c888888[Toggle Sprint " .. (NativeToggleSprintIsOn(value) and "On" or "Off") .. "]|r")
end

local function SetNativeToggleSprint(value)
    local previous = GetNativeToggleSprint()
    mountSprintLastWritten = tostring(value)
    SetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_TOGGLE_SPRINT, tostring(value))
    if NativeToggleSprintIsOn(previous) ~= NativeToggleSprintIsOn(value) then
        NotifyToggleSprint(value)
    end
end

local function RefreshMountSprintIcon()
    CW.UI.ApplyMountSprintIconVisibility()
end

local function SetMountStaminaDraining(draining)
    draining = draining == true
    if CW.mountStaminaDraining == draining then return end
    CW.mountStaminaDraining = draining
    RefreshMountSprintIcon()
end

local function CancelMountDrainClear()
    if mountDrainClearCall then zo_removeCallLater(mountDrainClearCall) end
end

local function ScheduleMountDrainClear()
    CancelMountDrainClear()
    mountDrainClearCall = zo_callLater(function() SetMountStaminaDraining(false) end, 400)
end

-- The engine filters this to the player's mount stamina.
local function OnMountPowerUpdate(_, _, _, _, current)
    if lastMountStamina ~= nil and current < lastMountStamina then
        CancelMountDrainClear()
        SetMountStaminaDraining(true)
    elseif lastMountStamina ~= nil and current >= lastMountStamina and CW.mountStaminaDraining then
        ScheduleMountDrainClear()
    end
    lastMountStamina = current
end

local function SetMountStaminaTracking(on)
    on = on == true
        and CW.SavedVars.showMountSprintIcon ~= false
        and mountSprintForced == true

    if on then
        if mountPowerEventRegistered then return end
        lastMountStamina = GetUnitPower("player", POWERTYPE_MOUNT_STAMINA)
        CW.mountStaminaDraining = false
        EM:RegisterForEvent(CW.name, EVENT_POWER_UPDATE, OnMountPowerUpdate)
        EM:AddFilterForEvent(CW.name, EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, "player")
        EM:AddFilterForEvent(CW.name, EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, POWERTYPE_MOUNT_STAMINA)
        mountPowerEventRegistered = true
        RefreshMountSprintIcon()
        return
    end

    if mountPowerEventRegistered then
        EM:UnregisterForEvent(CW.name, EVENT_POWER_UPDATE)
        mountPowerEventRegistered = false
    end
    lastMountStamina = nil
    CancelMountDrainClear()
    SetMountStaminaDraining(false)
end

function CW.UpdateMountStaminaTracking()
    SetMountStaminaTracking(CW.MountedToggleSprintActive())
end

function CW.MountSprintStaminaDraining()
    return CW.mountStaminaDraining == true
end

function CW.MountedToggleSprintActive()
    local sv = CW.SavedVars
    return sv.toggleSprintOnMount ~= false
        and (mountSprintRestoreValue ~= nil or sv.toggleSprintRestoreValue ~= nil)
        and mountSprintForced == true
        and IsMounted() == true
end

-- ESO fires an event for Toggle Sprint changes. Recognize our last-written value;
-- reconcile other values as player changes, without polling.
local function OnNativeToggleSprintChanged(_, _, settingId)
    if settingId ~= IN_WORLD_UI_SETTING_TOGGLE_SPRINT then return end
    if GetNativeToggleSprint() == mountSprintLastWritten then return end

    local sv = CW.SavedVars
    if IsMounted() and sv.toggleSprintOnMount ~= false then
        CW.UpdateMountedToggleSprint(true)
    else
        CW.RestoreMountedToggleSprint()
    end
end

-- One predicate handles arming and disarming; restore clears pending work when disabled.
UpdateMountSprintWatch = function()
    local sv = CW.SavedVars
    local pending = mountSprintForced or mountSprintRestoreValue ~= nil
        or sv.toggleSprintRestoreValue ~= nil
    local wantMount = sv.toggleSprintOnMount ~= false
    if wantMount ~= mountEventRegistered then
        mountEventRegistered = wantMount
        if wantMount then
            EM:RegisterForEvent(MOUNT_SPRINT_WATCH, EVENT_MOUNTED_STATE_CHANGED, function(_, mounted)
                CW.UpdateMountedToggleSprint(mounted)
            end)
        else
            EM:UnregisterForEvent(MOUNT_SPRINT_WATCH, EVENT_MOUNTED_STATE_CHANGED)
        end
    end

    local shouldWatch = pending or (wantMount and IsMounted())
    if shouldWatch == mountSprintWatching then return end
    mountSprintWatching = shouldWatch
    if shouldWatch then
        EM:RegisterForEvent(MOUNT_SPRINT_WATCH, EVENT_INTERFACE_SETTING_CHANGED, OnNativeToggleSprintChanged)
        EM:AddFilterForEvent(MOUNT_SPRINT_WATCH, EVENT_INTERFACE_SETTING_CHANGED,
            REGISTER_FILTER_SETTING_SYSTEM_TYPE, SETTING_TYPE_IN_WORLD)
    else
        EM:UnregisterForEvent(MOUNT_SPRINT_WATCH, EVENT_INTERFACE_SETTING_CHANGED)
    end
end

function CW.RestoreMountedToggleSprint()
    local sv = CW.SavedVars
    local restoreValue = mountSprintRestoreValue or sv.toggleSprintRestoreValue
    SetMountStaminaTracking(false)
    mountSprintForced = false
    if restoreValue ~= nil then SetNativeToggleSprint(restoreValue) end
    mountSprintRestoreValue = nil
    sv.toggleSprintRestoreValue = nil
    RefreshMountSprintIcon()
    UpdateMountSprintWatch()
end

function CW.UpdateMountedToggleSprint(mounted)
    local sv = CW.SavedVars
    if mounted == nil then mounted = IsMounted() end

    if sv.toggleSprintOnMount ~= false and mounted then
        mountSprintRestoreValue = mountSprintRestoreValue or sv.toggleSprintRestoreValue
            or tostring(GetNativeToggleSprint())
        SetNativeToggleSprint("1")
        mountSprintForced = true
        sv.toggleSprintRestoreValue = mountSprintRestoreValue
        SetMountStaminaTracking(true)
        RefreshMountSprintIcon()
        UpdateMountSprintWatch()
    else
        CW.RestoreMountedToggleSprint()
    end
end

-- Group + friendly-player health bars in PvP
--
-- Force Group Members/Friendly Players to Injured in PvP, then restore on exit.
-- Enable the master Health Bars switch too, or per-type options have no effect.
-- PvP boundaries cross load screens, so EVENT_PLAYER_ACTIVATED handles save/force/restore.

-- Master Health Bars stores "true"/"false"; per-type options store the five-way
-- NameplateDisplayChoice ordinal (optionspanel_nameplates_shared.lua).
local FORCED_HEALTH_BARS = {
    { id = NAMEPLATE_TYPE_ALL_HEALTHBARS,             value = "true", isBool = true },
    { id = NAMEPLATE_TYPE_GROUP_MEMBER_HEALTHBARS,    value = tostring(NAMEPLATE_CHOICE_INJURED) },
    { id = NAMEPLATE_TYPE_FRIENDLY_PLAYER_HEALTHBARS, value = tostring(NAMEPLATE_CHOICE_INJURED) },
}

-- Normalised to the string SetSetting takes back, so a record writes straight out again.
local function ReadHealthBarSetting(entry)
    if entry.isBool then
        return tostring(GetSetting_Bool(SETTING_TYPE_NAMEPLATES, entry.id))
    end
    return tostring(GetSetting(SETTING_TYPE_NAMEPLATES, entry.id))
end

-- Restore only options we changed; leave pre-existing Injured choices alone.
local function RestoreHealthBars(sv)
    local restore = sv.friendlyHealthBarsRestore
    if restore == nil then return end   -- nothing of ours to undo

    for _, entry in ipairs(restore) do
        SetSetting(SETTING_TYPE_NAMEPLATES, entry.id, entry.value)
    end
    sv.friendlyHealthBarsRestore = nil
end

-- The SavedVars restore record also marks forced state, surviving /reloadui or crashes
-- until activation outside PvP. Even an empty record counts: all options were already set.
function CW.UpdateFriendlyHealthBars()
    local sv = CW.SavedVars
    if sv.friendlyHealthBarsInPvp ~= false and CW.IsPvpZone() then
        -- Record only on first PvP activation; Cyrodiil -> IC must not save our forced values.
        -- Later activations re-force any manual changes.
        local saved = sv.friendlyHealthBarsRestore == nil and {} or nil

        for _, entry in ipairs(FORCED_HEALTH_BARS) do
            local current = ReadHealthBarSetting(entry)
            -- Already where we want it: leave it, record nothing.
            if current ~= entry.value then
                if saved then saved[#saved + 1] = { id = entry.id, value = current } end
                SetSetting(SETTING_TYPE_NAMEPLATES, entry.id, entry.value)
            end
        end

        if saved then sv.friendlyHealthBarsRestore = saved end
        return
    end

    RestoreHealthBars(sv)
end
