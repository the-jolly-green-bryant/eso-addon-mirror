-- Quartermaster/ui/HoldDialog.lua
-- Hold creation dialog. Two flavours:
--   * Gamepad: ZO_GamepadDialog template
--   * Keyboard: ZO_Dialog1
-- Both register the same dialog name with ZO_Dialogs and are dispatched by
-- the current input mode at OpenForRow time.

AccountHold = AccountHold or {}
AccountHold.UI = AccountHold.UI or {}
AccountHold.UI.HoldDialog = AccountHold.UI.HoldDialog or {}

local HoldDialog = AccountHold.UI.HoldDialog
local addon

local DIALOG_NAME_GP       = "ACCOUNT_HOLD_PLACE_GP"
local DIALOG_NAME_KB       = "ACCOUNT_HOLD_PLACE_KB"
local DIALOG_NAME_OVERRIDE  = "ACCOUNT_HOLD_PLACE_OVERRIDE"

-- Nudge the gamepad Quartermaster tab to repaint immediately after a hold is
-- created, so the reserved item reflects its status without the player having
-- to scroll away and back. Safe no-op on keyboard / before the tab exists.
local function notifyGamepadTab()
    local gp = AccountHold.UI and AccountHold.UI.InventoryTabGamepad
    if gp and gp.NotifyHoldChanged then
        pcall(function() gp.NotifyHoldChanged() end)
    end
end

-- Collapse any error to a single short line for chat (never dump a multi-line
-- traceback — the player relies on short debug lines being findable).
local function shortErr(err)
    local s = tostring(err or "")
    s = s:gsub("[\r\n].*$", "")
    if #s > 120 then s = s:sub(1, 117) .. "..." end
    return s
end

-- Whether the player can WITHDRAW items from a guild bank (bug 7). Depositing
-- reserved items into a guild bank the player can't withdraw from would strand
-- them, so guild-bank routes are gated on this. Defaults to true when the
-- permission API is unavailable so we never over-restrict.
local function guildBankRetrievable(guildId)
    if not DoesPlayerHaveGuildPermission then return true end
    local perm = _G["GUILD_PERMISSION_BANK_WITHDRAW"]
    if not perm then return true end
    local ok, res = pcall(DoesPlayerHaveGuildPermission, guildId, perm)
    if not ok then return true end
    return res and true or false
end

-- ---------------------------------------------------------------------------
-- Route enumeration (P1 #6 / #7)
-- Returns an ordered list of { key = canonical id, label = display string }
-- for every container the player can currently route through. The list is
-- always headed by the user's settings-default route (if reachable) so the
-- dialog pre-selects it.
-- ---------------------------------------------------------------------------
local function enumerateRoutes()
    local out = {}
    local seen = {}
    local function push(key, label)
        if not key or seen[key] then return end
        seen[key] = true
        out[#out + 1] = { key = key, label = label }
    end

    -- Account bank — always available as a destination conceptually.
    push("account_bank", GetString(SI_ACCOUNTHOLD_LOC_BANK))

    -- Guild banks the player belongs to — but ONLY those the player may also
    -- WITHDRAW from (bug 7). Depositing into a guild bank you can't withdraw
    -- from would strand the item, so such banks are omitted as routes.
    if GetNumGuilds then
        local n = GetNumGuilds() or 0
        for i = 1, n do
            local guildId = GetGuildId and GetGuildId(i) or 0
            if guildId ~= 0 and guildBankRetrievable(guildId) then
                local name = (GetGuildName and GetGuildName(guildId)) or "?"
                push("guildbank:" .. tostring(guildId),
                     ZO_CachedStrFormat and
                        ZO_CachedStrFormat(GetString(SI_ACCOUNTHOLD_LOC_GUILD_BANK), name)
                        or string.format(GetString(SI_ACCOUNTHOLD_LOC_GUILD_BANK), name))
            end
        end
    end

    -- House storage chests in the currently-loaded house, if any.
    if GetCurrentZoneHouseId then
        local houseId = GetCurrentZoneHouseId() or 0
        if houseId ~= 0 then
            local houseBags = {
                "BAG_HOUSE_BANK_ONE",  "BAG_HOUSE_BANK_TWO",  "BAG_HOUSE_BANK_THREE",
                "BAG_HOUSE_BANK_FOUR", "BAG_HOUSE_BANK_FIVE", "BAG_HOUSE_BANK_SIX",
                "BAG_HOUSE_BANK_SEVEN","BAG_HOUSE_BANK_EIGHT","BAG_HOUSE_BANK_NINE",
                "BAG_HOUSE_BANK_TEN",
            }
            for _, n in ipairs(houseBags) do
                local bagId = _G[n]
                if type(bagId) == "number" then
                    push(string.format("house:%d:%d", houseId, bagId),
                         ZO_CachedStrFormat(GetString(SI_ACCOUNTHOLD_LOC_HOUSE), "#" .. tostring(houseId)))
                end
            end
        end
    end

    return out
end

-- True when a location key refers to a SHARED storage container (account bank,
-- a guild bank, or house storage) rather than a character's own bags. Items
-- already sitting in shared storage need no route step — the hold is simply
-- staged for the target to collect from that container's Quartermaster tab.
local function isStorageLocationKey(key)
    if type(key) ~= "string" then return false end
    return key == "bank"
        or key:sub(1, 10) == "guildbank:"
        or key:sub(1, 6)  == "house:"
end

-- Resolve the default route key from settings, falling back to account_bank
-- when the saved value isn't currently reachable.
local function defaultRouteKey()
    local s = addon and addon.sv and addon.sv.settings
    return (s and s.defaultPreferredRoute) or "account_bank"
end

local function buildSpec(row, requestedCount, equipOnReceive, route, targetCharacterId)
    local entry = row.entry
    return {
        holdType       = "item",
        itemSignature  = entry.itemSignature,
        itemLink       = entry.itemLink,
        desiredCount   = requestedCount,
        preferredRoute = route or defaultRouteKey(),
        equipOnReceive = equipOnReceive and true or false,
        targetCharacterId = targetCharacterId,
    }
end

-- Ordered list of characters a hold may be reserved FOR. Only characters the
-- player allows to request items are offered; the current character is placed
-- first when eligible so the common "give this to me" case is the default.
local function enumerateTargets()
    local out = {}
    local me = addon and addon:GetCharacterId()
    local list = (addon and addon.ListRequestableCharacters and addon:ListRequestableCharacters()) or {}
    for _, c in ipairs(list) do
        if c.id == me then
            table.insert(out, 1, c)
        else
            out[#out + 1] = c
        end
    end
    if #out == 0 and me then
        out[1] = { id = me, name = (addon:GetCharacterRecord(me).name or "?") }
    end
    return out
end

-- Parse a count string from the dialog editBox, clamped to [1, available].
local function parseCount(text, maxCount)
    local n = tonumber(tostring(text or "")) or 1
    if n < 1 then n = 1 end
    if maxCount and maxCount > 0 and n > maxCount then n = maxCount end
    return n
end

-- ---------------------------------------------------------------------------
-- Init: register dialog templates with ZO_Dialogs
-- ---------------------------------------------------------------------------

function HoldDialog:Initialize(addonRef)
    addon = addonRef

    if ZO_Dialogs_RegisterCustomDialog then
        local function bodyText(dialog)
            local d = dialog.data or {}
            local routes = d.routes or {}
            local routeLabel = (routes[d.routeIndex or 1] and routes[d.routeIndex or 1].label) or "?"
            local targets = d.targets or {}
            local targetLabel = (targets[d.targetIndex or 1] and targets[d.targetIndex or 1].name) or "?"
            if d.inStorage then
                return string.format(GetString(SI_ACCOUNTHOLD_DIALOG_HOLD_BODY_INSTORAGE),
                    d.itemName or "?",
                    d.locationLabel or "?",
                    targetLabel,
                    d.locationLabel or "?")
            end
            return string.format(GetString(SI_ACCOUNTHOLD_DIALOG_HOLD_BODY_FULL),
                d.itemName or "?",
                d.locationLabel or "?",
                targetLabel,
                routeLabel)
        end

        local function onConfirm(dialog)
            local d = dialog.data or {}
            if not d.row then return end
            local routes = d.routes or {}
            local routeKey = routes[d.routeIndex or 1] and routes[d.routeIndex or 1].key
            local targets = d.targets or {}
            local targetId = targets[d.targetIndex or 1] and targets[d.targetIndex or 1].id
            local mode = (d.holdMode == "set") and "set" or "item"
            local created = nil
            if mode == "set" then
                -- Reserve one set-level hold keyed by setId (matches any piece
                -- carrying the set bonus). There is no per-piece expansion.
                local e = d.row.entry
                if e and e.setId and e.setId ~= 0 then
                    created = addon.Holds:Create({
                        holdType       = "set",
                        setId          = e.setId,
                        itemLink       = e.itemLink,
                        desiredCount   = 1,
                        preferredRoute = routeKey or defaultRouteKey(),
                        equipOnReceive = d.equip or false,
                        targetCharacterId = targetId,
                    })
                end
            else
                -- Reserve exactly the highlighted concrete item/stack.
                -- Pull the count from the editBox when present; fall back to data.
                local typed = (dialog.GetEditBoxText and dialog:GetEditBoxText())
                              or (dialog.editControl and dialog.editControl.GetText
                                  and dialog.editControl:GetText())
                              or d.count
                local count = parseCount(typed, d.maxCount)
                created = addon.Holds:Create(buildSpec(d.row, count, d.equip or false, routeKey, targetId))
            end
            -- Item already in shared storage: stage the new hold for pickup at
            -- that container so it lands directly in the target's Quartermaster
            -- collect list, with no deposit step required.
            if d.inStorage and d.storageContainerKey and created and created.id
               and addon.Holds and addon.Holds.MarkInTransit then
                addon.Holds:MarkInTransit(created.id, d.storageContainerKey)
            end
            -- Refresh the gamepad tab detail immediately so the item shows its
            -- reservation without needing the player to move to another row.
            notifyGamepadTab()
        end

        local function onCycleRoute(dialog)
            local d = dialog.data or {}
            local routes = d.routes or {}
            if #routes <= 1 then return end
            d.routeIndex = ((d.routeIndex or 1) % #routes) + 1
            -- Re-render. ZO_Dialogs re-evaluates the text functions on
            -- ShowDialog, but for already-shown dialogs we update by hand
            -- where possible; otherwise the next reopen will reflect the
            -- selection (the chosen index is captured at confirm time).
            if dialog.mainTextControl and dialog.mainTextControl.SetText then
                dialog.mainTextControl:SetText(bodyText(dialog))
            end
        end

        local function onCycleTarget(dialog)
            local d = dialog.data or {}
            local targets = d.targets or {}
            if #targets <= 1 then return end
            d.targetIndex = ((d.targetIndex or 1) % #targets) + 1
            if dialog.mainTextControl and dialog.mainTextControl.SetText then
                dialog.mainTextControl:SetText(bodyText(dialog))
            end
        end

        -- Gamepad dialog (console): a PARAMETRIC dropdown dialog — the same
        -- always-visible-dropdown pattern the game itself uses for gamepad
        -- option dialogs (e.g. the add-on manager options screen). The player
        -- scrolls onto "Reserve for" / "Route via" and presses (A) to open each
        -- dropdown; (X) Confirms, (B) Cancels. This replaces the old BASIC
        -- dialog whose cycle-button layout triggered the console UI error
        -- 2007bc7c. The confirm is pcall-guarded so any failure inside
        -- Holds:Create becomes a single short chat line, never a UI crash.
        local function holdDropdownRow(headerText, kind)
            return {
                header   = headerText,
                template = "ZO_GamepadDropdownItem",
                templateData = {
                    -- Route row is hidden when the item is already in storage.
                    visible = (kind == "route") and function(dialog)
                        return not (dialog and dialog.data and dialog.data.inStorage)
                    end or nil,
                    setup = function(control, data, selected)
                        local dropdown = control.dropdown
                        if not dropdown then return end
                        local d = (data.dialog and data.dialog.data) or {}
                        if dropdown.SetNormalColor and ZO_GAMEPAD_COMPONENT_COLORS then
                            pcall(function()
                                dropdown:SetNormalColor(ZO_GAMEPAD_COMPONENT_COLORS.UNSELECTED_INACTIVE:UnpackRGB())
                                dropdown:SetHighlightedColor(ZO_GAMEPAD_COMPONENT_COLORS.SELECTED_ACTIVE:UnpackRGB())
                            end)
                        end
                        if dropdown.SetSelectedItemTextColor then
                            pcall(function() dropdown:SetSelectedItemTextColor(selected) end)
                        end
                        dropdown:SetSortsItems(false)
                        dropdown:ClearItems()
                        local options  = (kind == "target") and (d.targets or {}) or (d.routes or {})
                        local curIndex = (kind == "target") and (d.targetIndex or 1) or (d.routeIndex or 1)
                        for i, opt in ipairs(options) do
                            local idx   = i
                            local label = opt.name or opt.label or "?"
                            local entry = dropdown:CreateItemEntry(label, function()
                                if kind == "target" then d.targetIndex = idx else d.routeIndex = idx end
                            end)
                            dropdown:AddItem(entry)
                        end
                        dropdown:UpdateItems()
                        local IGNORE_CALLBACK = true
                        dropdown:SelectItemByIndex(curIndex, IGNORE_CALLBACK)
                    end,
                    callback = function(dialog)
                        local tc = dialog.entryList and dialog.entryList:GetTargetControl()
                        if tc and tc.dropdown then tc.dropdown:Activate() end
                    end,
                    narrationText = ZO_GetDefaultParametricListDropdownNarrationText,
                },
            }
        end

        local function deactivateHoldDropdown(dialog)
            local tc = dialog and dialog.entryList and dialog.entryList.GetTargetControl
                       and dialog.entryList:GetTargetControl()
            if tc and tc.dropdown then pcall(function() tc.dropdown:Deactivate() end) end
        end

        ZO_Dialogs_RegisterCustomDialog(DIALOG_NAME_GP, {
            canQueue    = true,
            gamepadInfo = { dialogType = GAMEPAD_DIALOGS and GAMEPAD_DIALOGS.PARAMETRIC or 3 },
            title       = { text = GetString(SI_ACCOUNTHOLD_DIALOG_HOLD_TITLE) },
            setup = function(dialog, data)
                if ZO_GenericGamepadDialog_RefreshText then
                    local d = data or {}
                    local subText = string.format("%s\n%s",
                        d.itemName or "?", d.locationLabel or "")
                    pcall(function()
                        ZO_GenericGamepadDialog_RefreshText(dialog,
                            GetString(SI_ACCOUNTHOLD_DIALOG_HOLD_TITLE), subText)
                    end)
                end
                if dialog.setupFunc then
                    pcall(function() dialog:setupFunc(nil, data) end)
                end
            end,
            parametricList = {
                holdDropdownRow(GetString(SI_ACCOUNTHOLD_DIALOG_CYCLE_TARGET), "target"),
                holdDropdownRow(GetString(SI_ACCOUNTHOLD_DIALOG_CYCLE_ROUTE), "route"),
            },
            blockDialogReleaseOnPress = true,
            buttons = {
                {
                    keybind  = "DIALOG_PRIMARY",
                    text     = GetString(SI_GAMEPAD_SELECT_OPTION),
                    callback = function(dialog)
                        local td = dialog.entryList and dialog.entryList:GetTargetData()
                        if td and td.callback then td.callback(dialog) end
                    end,
                },
                {
                    keybind  = "DIALOG_SECONDARY",
                    text     = GetString(SI_ACCOUNTHOLD_DIALOG_CONFIRM),
                    callback = function(dialog)
                        deactivateHoldDropdown(dialog)
                        local ok, err = pcall(onConfirm, dialog)
                        if not ok and addon and addon.Log then
                            addon:Log("|cFF6666[Quartermaster]|r hold failed: " .. shortErr(err))
                        end
                        if ZO_Dialogs_ReleaseDialogOnButtonPress then
                            ZO_Dialogs_ReleaseDialogOnButtonPress(DIALOG_NAME_GP)
                        end
                    end,
                },
                {
                    keybind  = "DIALOG_NEGATIVE",
                    text     = GetString(SI_ACCOUNTHOLD_DIALOG_CANCEL),
                    callback = function(dialog)
                        deactivateHoldDropdown(dialog)
                        if ZO_Dialogs_ReleaseDialogOnButtonPress then
                            ZO_Dialogs_ReleaseDialogOnButtonPress(DIALOG_NAME_GP)
                        end
                    end,
                },
            },
            onHidingCallback = deactivateHoldDropdown,
        })

        -- Keyboard dialog (PC)
        ZO_Dialogs_RegisterCustomDialog(DIALOG_NAME_KB, {
            canQueue = true,
            title    = { text = GetString(SI_ACCOUNTHOLD_DIALOG_HOLD_TITLE) },
            mainText = { text = bodyText },
            editBox  = {
                defaultText  = "",
                textType     = TEXT_TYPE_NUMERIC,
                maxInputCharacters = 4,
            },
            buttons = {
                [1] = {
                    text     = GetString(SI_ACCOUNTHOLD_DIALOG_CONFIRM),
                    callback = onConfirm,
                },
                [2] = {
                    text     = GetString(SI_ACCOUNTHOLD_DIALOG_CYCLE_TARGET),
                    callback = onCycleTarget,
                    noReleaseOnClick = true,
                },
                [3] = {
                    text     = GetString(SI_ACCOUNTHOLD_DIALOG_CYCLE_ROUTE),
                    callback = onCycleRoute,
                    noReleaseOnClick = true,
                    visible  = function(dialog)
                        return not (dialog and dialog.data and dialog.data.inStorage)
                    end,
                },
                [4] = {
                    text     = GetString(SI_ACCOUNTHOLD_DIALOG_CANCEL),
                },
            },
        })

        -- Override-confirmation dialog (bug 3). Shown when the player tries to
        -- reserve an item/set that already has an active reservation. On
        -- confirm we cancel the existing hold(s) for that item and continue
        -- into the normal place-hold flow; on cancel we abort untouched.
        ZO_Dialogs_RegisterCustomDialog(DIALOG_NAME_OVERRIDE, {
            canQueue = true,
            gamepadInfo = { dialogType = GAMEPAD_DIALOGS and GAMEPAD_DIALOGS.BASIC or 1 },
            title    = { text = GetString(SI_ACCOUNTHOLD_DIALOG_OVERRIDE_TITLE) },
            mainText = {
                text = function(dialog)
                    local d = dialog.data or {}
                    if d.holderName and d.holderName ~= "" then
                        return string.format(GetString(SI_ACCOUNTHOLD_DIALOG_OVERRIDE_BODY),
                            d.itemName or "?", d.holderName)
                    end
                    return string.format(GetString(SI_ACCOUNTHOLD_DIALOG_OVERRIDE_BODY_ANON),
                        d.itemName or "?")
                end,
            },
            buttons = {
                {
                    text     = GetString(SI_ACCOUNTHOLD_DIALOG_OVERRIDE_CONFIRM),
                    keybind  = "DIALOG_PRIMARY",
                    callback = function(dialog)
                        local d = dialog.data or {}
                        local row = d.row
                        if not row then return end
                        -- Cancel only the same KIND of hold we are re-placing so
                        -- an item reservation never silently drops a set hold on
                        -- the same gear (and vice versa), then continue in the
                        -- chosen mode.
                        local holdMode = (d.holdMode == "set") and "set" or "item"
                        pcall(function() addon.Holds:CancelActiveForRow(row, holdMode) end)
                        notifyGamepadTab()
                        zo_callLater(function()
                            HoldDialog:_ProceedPlaceHold(row, holdMode)
                        end, 50)
                    end,
                },
                {
                    text     = GetString(SI_ACCOUNTHOLD_DIALOG_CANCEL),
                    keybind  = "DIALOG_NEGATIVE",
                },
            },
        })
    end
end

-- ---------------------------------------------------------------------------
-- Open
-- ---------------------------------------------------------------------------

function HoldDialog:OpenForRow(row, count, equipOnReceive, holdMode)
    if not row or not row.entry then return end
    if row.entry.isCharacterBound then
        if addon and addon.Diagnostic then
            addon:Diagnostic("info",
                "Hold dialog suppressed: item is character-bound (%s).",
                tostring(row.entry.name or row.entry.itemLink or "?"))
        end
        return
    end
    if row.isCraftBag then
        if addon and addon.Diagnostic then
            addon:Diagnostic("info",
                "Hold dialog suppressed: item lives in the craft bag (already account-wide).")
        end
        return
    end

    local routes = enumerateRoutes()
    local defKey = defaultRouteKey()
    local routeIndex = 1
    for i, r in ipairs(routes) do
        if r.key == defKey then routeIndex = i; break end
    end

    -- If the item is ALREADY in shared storage, there is no route decision to
    -- make: the item just needs to be collected from that container. Collapse
    -- the route list to the current container and flag the dialog so the route
    -- control is hidden and the hold is staged for pickup on confirm.
    local inStorage = isStorageLocationKey(row.locationKey)
    local storageContainerKey = nil
    if inStorage then
        storageContainerKey = row.locationKey
        routes = { { key = row.locationKey, label = row.locationLabel or "?" } }
        routeIndex = 1
    end

    local maxCount = row.entry.stackCount or 1
    local targets = enumerateTargets()
    local data = {
        row           = row,
        itemName      = row.entry.name or row.entry.itemLink or "?",
        locationLabel = row.locationLabel or "?",
        count         = count or maxCount or 1,
        maxCount      = maxCount,
        equip         = equipOnReceive and true or false,
        routes        = routes,
        routeIndex    = routeIndex,
        targets       = targets,
        targetIndex   = 1,
        holdMode      = holdMode or "item",
        inStorage           = inStorage,
        storageContainerKey = storageContainerKey,
    }
    local name = IsInGamepadPreferredMode() and DIALOG_NAME_GP or DIALOG_NAME_KB
    if IsInGamepadPreferredMode() then
        -- Gamepad/console: the GP dialog is a PARAMETRIC dialog with three
        -- keybind buttons. ZO_Dialogs_ShowDialog is the KEYBOARD show path
        -- (isGamepad=nil), which would try to lay the 3 buttons onto the
        -- 2-button keyboard template and crash in zo_dialog.lua (GetButtonControl
        -- returns nil). ShowGamepadDialog sets isGamepad=true so it renders as
        -- the parametric gamepad dialog.
        if ZO_Dialogs_ShowGamepadDialog then
            ZO_Dialogs_ShowGamepadDialog(name, data)
        end
    elseif ZO_Dialogs_ShowDialog then
        -- Keyboard only: seed the editBox with the requested count so the
        -- user can confirm without typing. The gamepad dialog has no
        -- editBox (see registration note) and defaults to the full stack.
        ZO_Dialogs_ShowDialog(name, data, { initialEditText = tostring(data.count) })
    end
end

-- Entry point for placing a hold from an inventory row. `holdMode` selects the
-- kind of reservation:
--   * "item" (default) reserves exactly the highlighted concrete item/stack.
--   * "set" reserves one set-level hold keyed by setId (matches any piece).
-- First checks whether a reservation of the SAME kind already exists; if so,
-- prompts the player to override it (bug 3). Otherwise proceeds straight to the
-- route/target dialog. There is no set-vs-per-piece chooser: the two kinds are
-- distinct, deterministic entry points (A = item, X = set on gamepad).
function HoldDialog:BeginPlaceHold(row, holdMode)
    if not row or not row.entry then return end
    holdMode = (holdMode == "set") and "set" or "item"
    -- A set hold is only meaningful for gear that actually carries a set id.
    if holdMode == "set" and not (row.entry.setId and row.entry.setId ~= 0) then
        if addon and addon.Diagnostic then
            addon:Diagnostic("info", "Set hold suppressed: row carries no set id.")
        end
        return
    end
    local existing = addon and addon.Holds and addon.Holds.FindActiveHoldForRow
                     and addon.Holds:FindActiveHoldForRow(row, holdMode)
    if existing then
        local data = {
            row        = row,
            holdMode   = holdMode,
            itemName   = row.entry.name or row.entry.itemLink or "?",
            holderName = addon.Holds:HolderName(existing),
        }
        if ZO_Dialogs_ShowPlatformDialog then
            ZO_Dialogs_ShowPlatformDialog(DIALOG_NAME_OVERRIDE, data)
        elseif ZO_Dialogs_ShowDialog then
            ZO_Dialogs_ShowDialog(DIALOG_NAME_OVERRIDE, data)
        end
        return
    end
    self:_ProceedPlaceHold(row, holdMode)
end

-- Open the route/target dialog for the chosen kind of hold. Set holds default
-- to a single desired count; item holds default to the full stack.
function HoldDialog:_ProceedPlaceHold(row, holdMode)
    if not row or not row.entry then return end
    holdMode = (holdMode == "set") and "set" or "item"
    if holdMode == "set" then
        self:OpenForRow(row, 1, false, "set")
    else
        self:OpenForRow(row, nil, false, "item")
    end
end
