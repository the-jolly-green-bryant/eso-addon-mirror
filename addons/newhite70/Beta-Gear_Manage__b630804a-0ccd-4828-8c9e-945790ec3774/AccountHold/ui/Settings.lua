-- Quartermaster/ui/Settings.lua
-- Settings panel. Routes through src/Platform.lua so we can swap the backend
-- (LHAS today; LAM2 tomorrow on PC) without touching the controls list.
-- LHAS is NOT bundled: Platform.GetSettingsBackend() resolves the global
-- `LibHarvensAddonSettings` at call time, so a standalone install of the
-- library satisfies it on any platform (including console). No DependsOn entry.

AccountHold = AccountHold or {}
AccountHold.Settings = AccountHold.Settings or {}

local Settings = AccountHold.Settings
local addon

local function s(svKey)
    return function() return addon.sv.settings[svKey] end,
           function(value) addon.sv.settings[svKey] = value end
end

-- ---------------------------------------------------------------------------
-- LHAS dropdown contract. Verified against the library's own source
-- (LibHarvensAddonSettings PC/Settings.lua and Console/Settings.lua):
--
--   * `items` must be a list of TABLES each carrying a `name` field. The
--     library reads `items[i].name` on both platforms —
--       PC:      combobox:CreateItemEntry(items[i].name, callback)
--       console: combobox:AddEntry(items[i]) ... callback reads data.name
--     A list of plain strings yields nil names and a dead dropdown.
--
--   * `setFunction` is invoked as (comboBox, name, item, ...) — the selected
--     value is the SECOND argument, NOT the first:
--       PC:      callback = function(...) self:ValueChanged(...) end
--                (ZO_ComboBox calls it with comboBox, name, item)
--       console: self:ValueChanged(control, data.name, data)
--     A one-parameter `function(value)` therefore receives the COMBOBOX and
--     silently never matches — which is exactly why these dropdowns rendered
--     correctly but did nothing.
--
--   * `getFunction` must return the display NAME string
--     (PC: combobox:SetSelectedItem(self.getFunction())), and `default` is
--     likewise a name string (Main.lua ResetToDefaults compares
--     `self.items[i].name == self.default`).
--
-- Checkboxes, sliders and buttons take a single value and are unaffected.
-- ---------------------------------------------------------------------------

local function dropdownItems(labels)
    local items = {}
    for i, label in ipairs(labels) do items[i] = { name = label } end
    return items
end

-- Pull the selected value out of LHAS's callback arguments, tolerating both the
-- (comboBox, name, item) shape and a bare (value) from any older build.
local function dropdownValue(a, b)
    if type(b) == "string" then return b end
    if type(a) == "string" then return a end
    return nil
end

-- LHAS button contract: ST_BUTTON's param setup copies `params.clickHandler`
-- and does NOT copy `params.setFunction` (verified in the library's
-- setupControlFunctions, both Console/Settings.lua and PC/Settings.lua).
-- AddonSettingsControl:ValueChanged prefers self.setFunction and falls back to
-- self.clickHandler — but since setFunction was never copied, a button declared
-- with only setFunction is DEAD: it renders, it is selectable, and clicking it
-- does nothing at all. See the `add` wrapper in _BuildLHAS, which mirrors the
-- handler onto clickHandler so every button fires on any build.

function Settings:Initialize(addonRef)
    addon = addonRef
    local backend = addon.Platform.GetSettingsBackend()
    if not backend then
        -- No backend available; degrade gracefully. Users on console without
        -- LHAS see no settings panel; the addon still runs with defaults.
        addon:Debug("No settings backend available; panel skipped.")
        return
    end

    if backend.kind == "LHAS" then
        if addon.locked then
            self:_BuildLockedLHAS(backend.lib)
        else
            self:_BuildLHAS(backend.lib)
        end
    elseif backend.kind == "LAM2" then
        self:_BuildLAM2(backend.lib)
    end
end

-- Minimal panel shown to accounts that are NOT on the beta allowlist. Just the
-- beta banner section and a "Features Disabled" label — nothing configurable.
function Settings:_BuildLockedLHAS(LHAS)
    local panel = LHAS:AddAddon(GetString(SI_ACCOUNTHOLD_SETTINGS_TITLE))
    if not panel then return end
    panel:AddSetting({ type = LHAS.ST_SECTION, label = GetString(SI_ACCOUNTHOLD_BETA_BANNER) })
    panel:AddSetting({ type = LHAS.ST_LABEL,   label = GetString(SI_ACCOUNTHOLD_FEATURES_DISABLED) })
end

-- ---------------------------------------------------------------------------
-- LibHarvensAddonSettings panel
-- ---------------------------------------------------------------------------

function Settings:_BuildLHAS(LHAS)
    local panel = LHAS:AddAddon(GetString(SI_ACCOUNTHOLD_SETTINGS_TITLE))
    if not panel then return end

    local function add(controlSpec)
        -- Mirror a button's handler onto clickHandler: LHAS only copies
        -- params.clickHandler for ST_BUTTON, so a setFunction-only button never
        -- fires. Doing it here covers every button, including future ones.
        if controlSpec.type == LHAS.ST_BUTTON
           and controlSpec.setFunction and not controlSpec.clickHandler then
            controlSpec.clickHandler = controlSpec.setFunction
        end
        panel:AddSetting(controlSpec)
    end

    -- General / Scanning
    add({ type = LHAS.ST_SECTION, label = GetString(SI_ACCOUNTHOLD_SETTINGS_SCANNING) })

    add({
        type    = LHAS.ST_CHECKBOX,
        label   = GetString(SI_ACCOUNTHOLD_SETTINGS_SCAN_ON_LOGIN),
        getFunction = function()       return addon.sv.settings.scanOnLogin end,
        setFunction = function(value)  addon.sv.settings.scanOnLogin = value end,
        default = true,
    })

    add({
        type    = LHAS.ST_SLIDER,
        label   = GetString(SI_ACCOUNTHOLD_SETTINGS_SCAN_INTERVAL),
        min     = 5, max = 60, step = 1,
        getFunction = function()       return addon.sv.settings.scanIntervalMinutes end,
        setFunction = function(value)  addon.sv.settings.scanIntervalMinutes = value end,
        default = 15,
    })

    add({
        type    = LHAS.ST_CHECKBOX,
        label   = GetString(SI_ACCOUNTHOLD_SETTINGS_SCAN_CRAFT_BAG),
        tooltip = GetString(SI_ACCOUNTHOLD_SETTINGS_SCAN_CRAFT_NOTE),
        getFunction = function()       return addon.sv.settings.scanCraftBag ~= false end,
        setFunction = function(value)  addon.sv.settings.scanCraftBag = value and true or false end,
        default = true,
    })

    -- Presentation: where the item's LOCATION is shown in the gamepad
    -- Quartermaster blade. The tooltip always shows it; this only controls
    -- whether it is ALSO repeated as a sub label under every row. The tooltip
    -- text carries a worked before/after example, because "location sub label"
    -- does not convey what actually changes on screen.
    add({
        type    = LHAS.ST_CHECKBOX,
        label   = GetString(SI_ACCOUNTHOLD_SETTINGS_ROW_LOCATION),
        tooltip = GetString(SI_ACCOUNTHOLD_SETTINGS_ROW_LOCATION_NOTE),
        getFunction = function()       return addon.sv.settings.showRowLocation == true end,
        setFunction = function(value)
            addon.sv.settings.showRowLocation = value and true or false
            -- Repaint so the change is visible immediately rather than after
            -- the next scan.
            local tab = addon.UI and addon.UI.InventoryTabGamepad
            if tab and tab.Refresh then pcall(function() tab:Refresh() end) end
        end,
        default = false,
    })
    add({
        type    = LHAS.ST_CHECKBOX,
        label   = GetString(SI_ACCOUNTHOLD_SETTINGS_SCAN_ON_BANK),
        getFunction = function()       return addon.sv.settings.scanOnBankOpen ~= false end,
        setFunction = function(value)  addon.sv.settings.scanOnBankOpen = value and true or false end,
        default = true,
    })
    add({
        type    = LHAS.ST_CHECKBOX,
        label   = GetString(SI_ACCOUNTHOLD_SETTINGS_SCAN_ON_GUILDBANK),
        getFunction = function()       return addon.sv.settings.scanOnGuildBankOpen ~= false end,
        setFunction = function(value)  addon.sv.settings.scanOnGuildBankOpen = value and true or false end,
        default = true,
    })
    add({
        type    = LHAS.ST_CHECKBOX,
        label   = GetString(SI_ACCOUNTHOLD_SETTINGS_SCAN_ON_HOUSE),
        getFunction = function()       return addon.sv.settings.scanOnHouseStorageOpen ~= false end,
        setFunction = function(value)  addon.sv.settings.scanOnHouseStorageOpen = value and true or false end,
        default = true,
    })
    add({
        type    = LHAS.ST_CHECKBOX,
        label   = GetString(SI_ACCOUNTHOLD_SETTINGS_SCAN_ANNOUNCE),
        tooltip = GetString(SI_ACCOUNTHOLD_SETTINGS_SCAN_ANNOUNCE_TIP),
        getFunction = function()       return addon.sv.settings.announceScanResults end,
        setFunction = function(value)  addon.sv.settings.announceScanResults = value end,
        default = false,
    })
    add({
        type     = LHAS.ST_BUTTON,
        label    = GetString(SI_ACCOUNTHOLD_SETTINGS_SCAN_NOW),
        tooltip  = GetString(SI_ACCOUNTHOLD_SETTINGS_SCAN_NOW_TIP),
        buttonText = GetString(SI_ACCOUNTHOLD_BTN_SCAN_NOW),
        setFunction = function()
            if addon.Scanner and addon.Scanner.ScanAll then addon.Scanner:ScanAll() end
        end,
    })

    -- Notifications
    add({ type = LHAS.ST_SECTION, label = GetString(SI_ACCOUNTHOLD_SETTINGS_NOTIFICATIONS) })

    add({
        type    = LHAS.ST_CHECKBOX,
        label   = GetString(SI_ACCOUNTHOLD_SETTINGS_PROMPT_LOGIN),
        getFunction = function()       return addon.sv.settings.autoPromptOnLogin end,
        setFunction = function(value)  addon.sv.settings.autoPromptOnLogin = value end,
        default = true,
    })
    add({
        type    = LHAS.ST_CHECKBOX,
        label   = GetString(SI_ACCOUNTHOLD_SETTINGS_PROMPT_BANK),
        getFunction = function()       return addon.sv.settings.autoPromptAtBank end,
        setFunction = function(value)  addon.sv.settings.autoPromptAtBank = value end,
        default = true,
    })
    add({
        type    = LHAS.ST_CHECKBOX,
        label   = GetString(SI_ACCOUNTHOLD_SETTINGS_PROMPT_GUILDBANK),
        getFunction = function()       return addon.sv.settings.autoPromptAtGuildBank end,
        setFunction = function(value)  addon.sv.settings.autoPromptAtGuildBank = value end,
        default = true,
    })
    add({
        type    = LHAS.ST_CHECKBOX,
        label   = GetString(SI_ACCOUNTHOLD_SETTINGS_PROMPT_HOUSE),
        getFunction = function()       return addon.sv.settings.autoPromptAtHouseStorage end,
        setFunction = function(value)  addon.sv.settings.autoPromptAtHouseStorage = value end,
        default = true,
    })
    -- P1 #8: independent visibility toggles for the on-screen action panel.
    add({
        type    = LHAS.ST_CHECKBOX,
        label   = GetString(SI_ACCOUNTHOLD_SETTINGS_PANEL_BANK),
        tooltip = GetString(SI_ACCOUNTHOLD_SETTINGS_PANEL_TIP),
        getFunction = function()       return addon.sv.settings.showActionPanelAtBank end,
        setFunction = function(value)  addon.sv.settings.showActionPanelAtBank = value end,
        default = true,
    })
    add({
        type    = LHAS.ST_CHECKBOX,
        label   = GetString(SI_ACCOUNTHOLD_SETTINGS_PANEL_GUILDBANK),
        tooltip = GetString(SI_ACCOUNTHOLD_SETTINGS_PANEL_TIP),
        getFunction = function()       return addon.sv.settings.showActionPanelAtGuildBank end,
        setFunction = function(value)  addon.sv.settings.showActionPanelAtGuildBank = value end,
        default = true,
    })
    add({
        type    = LHAS.ST_CHECKBOX,
        label   = GetString(SI_ACCOUNTHOLD_SETTINGS_PANEL_HOUSE),
        tooltip = GetString(SI_ACCOUNTHOLD_SETTINGS_PANEL_TIP),
        getFunction = function()       return addon.sv.settings.showActionPanelAtHouseStorage end,
        setFunction = function(value)  addon.sv.settings.showActionPanelAtHouseStorage = value end,
        default = true,
    })
    add({
        type     = LHAS.ST_DROPDOWN,
        label    = GetString(SI_ACCOUNTHOLD_SETTINGS_NOTIFY_STYLE),
        items    = dropdownItems({
                     GetString(SI_ACCOUNTHOLD_SETTINGS_NOTIFY_CHAT),
                     GetString(SI_ACCOUNTHOLD_SETTINGS_NOTIFY_CENTER),
                     GetString(SI_ACCOUNTHOLD_SETTINGS_NOTIFY_BOTH) }),
        getFunction = function()
            local v = addon.sv.settings.notificationStyle
            if v == "chat" then return GetString(SI_ACCOUNTHOLD_SETTINGS_NOTIFY_CHAT) end
            if v == "centerScreen" then return GetString(SI_ACCOUNTHOLD_SETTINGS_NOTIFY_CENTER) end
            return GetString(SI_ACCOUNTHOLD_SETTINGS_NOTIFY_BOTH)
        end,
        -- (comboBox, name, item) — see the dropdown contract note above.
        setFunction = function(a, b)
            local value = dropdownValue(a, b)
            if value == nil then return end
            if value == GetString(SI_ACCOUNTHOLD_SETTINGS_NOTIFY_CHAT) then
                addon.sv.settings.notificationStyle = "chat"
            elseif value == GetString(SI_ACCOUNTHOLD_SETTINGS_NOTIFY_CENTER) then
                addon.sv.settings.notificationStyle = "centerScreen"
            else
                addon.sv.settings.notificationStyle = "both"
            end
            -- Immediately show a sample so the player can see the chosen style
            -- take effect (bug 5).
            if addon.Notify and addon.Notify.PreviewStyle then
                addon.Notify:PreviewStyle()
            end
        end,
        default = GetString(SI_ACCOUNTHOLD_SETTINGS_NOTIFY_BOTH),
    })

    -- Controls
    add({ type = LHAS.ST_SECTION, label = GetString(SI_ACCOUNTHOLD_SETTINGS_CONTROLS) })

    add({
        type    = LHAS.ST_CHECKBOX,
        label   = GetString(SI_ACCOUNTHOLD_SETTINGS_CONFIRM_EACH),
        getFunction = function()       return addon.sv.settings.confirmEachMove end,
        setFunction = function(value)  addon.sv.settings.confirmEachMove = value end,
        default = false,
    })
    -- P1 #7: default deposit route used by the Place-Hold dialog.
    -- Stored as the canonical key ("account_bank" | "guildbank:<id>" |
    -- "house:<id>:<bagId>"). The dropdown lists every route that's
    -- enumerable from the settings panel (the player's account bank +
    -- their current guild memberships); the Place-Hold dialog at open
    -- time additionally surfaces house storage in the loaded zone.
    local routeOptions = self:_BuildDefaultRouteOptions()
    add({
        type    = LHAS.ST_DROPDOWN,
        label   = GetString(SI_ACCOUNTHOLD_SETTINGS_DEFAULT_ROUTE),
        tooltip = GetString(SI_ACCOUNTHOLD_SETTINGS_DEFAULT_ROUTE_TIP),
        items   = dropdownItems((function()
            local labels = {}
            for _, r in ipairs(routeOptions) do labels[#labels + 1] = r.label end
            return labels
        end)()),
        getFunction = function()
            local saved = addon.sv.settings.defaultPreferredRoute or "account_bank"
            for _, r in ipairs(routeOptions) do
                if r.key == saved then return r.label end
            end
            return routeOptions[1] and routeOptions[1].label or ""
        end,
        -- (comboBox, name, item) — see the dropdown contract note above. The
        -- previous one-parameter form received the combobox, so this loop never
        -- matched and the default route was silently never saved.
        setFunction = function(a, b)
            local value = dropdownValue(a, b)
            if value == nil then return end
            for _, r in ipairs(routeOptions) do
                if r.label == value then
                    addon.sv.settings.defaultPreferredRoute = r.key
                    return
                end
            end
        end,
        default = (routeOptions[1] and routeOptions[1].label) or "",
    })
    add({
        type    = LHAS.ST_CHECKBOX,
        label   = GetString(SI_ACCOUNTHOLD_SETTINGS_AUTO_EQUIP),
        getFunction = function()       return addon.sv.settings.autoEquipOnReceive end,
        setFunction = function(value)  addon.sv.settings.autoEquipOnReceive = value end,
        default = false,
    })
    add({
        type    = LHAS.ST_SLIDER,
        label   = GetString(SI_ACCOUNTHOLD_SETTINGS_RETENTION),
        min     = 1, max = 30, step = 1,
        getFunction = function()       return addon.sv.settings.holdRetentionDays end,
        setFunction = function(value)  addon.sv.settings.holdRetentionDays = value end,
        default = 7,
    })
    add({
        type    = LHAS.ST_CHECKBOX,
        label   = GetString(SI_ACCOUNTHOLD_SETTINGS_DEBUG),
        getFunction = function()       return addon.sv.settings.debugLogging end,
        setFunction = function(value)  addon.sv.settings.debugLogging = value end,
        default = false,
    })

    -- ----------------------------------------------------------------
    -- Per-character permissions. Two toggles per known character:
    --   * can request — may reserve items / be a hold target.
    --   * can hold    — may act as holding space (a deposit source).
    -- A pure "storage mule" keeps can-hold on and can-request off.
    -- ----------------------------------------------------------------
    add({ type = LHAS.ST_SECTION, label = GetString(SI_ACCOUNTHOLD_SETTINGS_CHARACTERS) })
    add({ type = LHAS.ST_LABEL,   label = GetString(SI_ACCOUNTHOLD_SETTINGS_CHAR_INTRO) })

    local chars = addon:ListKnownCharacters()
    if #chars == 0 then
        add({ type = LHAS.ST_LABEL, label = GetString(SI_ACCOUNTHOLD_SETTINGS_CHAR_NONE) })
    else
        for _, c in ipairs(chars) do
            local charId = c.id
            add({
                type    = LHAS.ST_CHECKBOX,
                label   = string.format(GetString(SI_ACCOUNTHOLD_SETTINGS_CHAR_CAN_REQUEST), c.name),
                getFunction = function()      return addon:CanRequest(charId) end,
                setFunction = function(value) addon:SetCharacterPermission(charId, "allowRequest", value) end,
                default = true,
            })
        end
    end

    -- ----------------------------------------------------------------
    -- Optional features (Epic 0001 per-feature gates). Deterministically
    -- generated from the feature registry: a checkbox appears ONLY for
    -- features that are IMPLEMENTED (registry `available`) AND that this
    -- account is allowed to use (Features:UserFacingList applies both). A user
    -- may switch an allowed feature off (narrowing); they can never switch on
    -- a feature they are gated out of. Unimplemented / gated features never
    -- render a control, so nothing here looks functional before it ships.
    -- ----------------------------------------------------------------
    local featureRows = (addon.Features and addon.Features:UserFacingList()) or {}
    if #featureRows > 0 then
        add({ type = LHAS.ST_SECTION, label = GetString(SI_ACCOUNTHOLD_SETTINGS_FEATURES) })
        for _, f in ipairs(featureRows) do
            local featureKey = f.key
            add({
                type    = LHAS.ST_CHECKBOX,
                label   = f.label,
                tooltip = GetString(SI_ACCOUNTHOLD_SETTINGS_FEATURE_TIP),
                getFunction = function()      return addon.Features:GetUserEnabled(featureKey) end,
                setFunction = function(value) addon.Features:SetUserEnabled(featureKey, value) end,
                default = true,
            })
        end
    end

    -- ----------------------------------------------------------------
    -- Reset / clear-data section. Three confirmation-gated buttons:
    --   1. Snapshot only — clears scanned inventory but keeps holds.
    --   2. Holds only    — cancels and clears all holds; keeps snapshot.
    --   3. Everything    — full reset (settings preserved).
    -- Console players have no other way to recover from corrupt SV; this
    -- panel is the only entry point.
    -- ----------------------------------------------------------------
    add({ type = LHAS.ST_SECTION, label = GetString(SI_ACCOUNTHOLD_SETTINGS_RESET) })

    add({
        type     = LHAS.ST_BUTTON,
        label    = GetString(SI_ACCOUNTHOLD_WIPE_SNAPSHOT),
        tooltip  = GetString(SI_ACCOUNTHOLD_WIPE_SNAPSHOT_TIP),
        buttonText = GetString(SI_ACCOUNTHOLD_BTN_WIPE),
        setFunction = function()
            Settings:_ConfirmWipe("snapshot",
                GetString(SI_ACCOUNTHOLD_CONFIRM_WIPE_SNAPSHOT))
        end,
    })

    add({
        type     = LHAS.ST_BUTTON,
        label    = GetString(SI_ACCOUNTHOLD_WIPE_HOLDS),
        tooltip  = GetString(SI_ACCOUNTHOLD_WIPE_HOLDS_TIP),
        buttonText = GetString(SI_ACCOUNTHOLD_BTN_WIPE),
        setFunction = function()
            Settings:_ConfirmWipe("holds",
                GetString(SI_ACCOUNTHOLD_CONFIRM_WIPE_HOLDS))
        end,
    })

    add({
        type     = LHAS.ST_BUTTON,
        label    = GetString(SI_ACCOUNTHOLD_WIPE_ALL),
        tooltip  = GetString(SI_ACCOUNTHOLD_WIPE_ALL_TIP),
        buttonText = GetString(SI_ACCOUNTHOLD_BTN_WIPE_ALL),
        setFunction = function()
            Settings:_ConfirmWipe("all",
                GetString(SI_ACCOUNTHOLD_CONFIRM_WIPE_ALL))
        end,
    })

    -- Diagnostics dump button — PC parity for the gamepad gear scene's
    -- "Show recent diagnostics" keystrip entry. Lets PC players read the
    -- same ring buffer console players see through the gear scene.
    add({
        type     = LHAS.ST_BUTTON,
        label    = GetString(SI_ACCOUNTHOLD_DIAG_DUMP),
        tooltip  = GetString(SI_ACCOUNTHOLD_DIAG_DUMP_TIP),
        buttonText = GetString(SI_ACCOUNTHOLD_DIAG_DUMP),
        setFunction = function()
            if addon and addon.DumpDiagnostics then addon:DumpDiagnostics() end
        end,
    })

    -- ---------------------------------------------------------------------
    -- Travel tracing (BUGS.md QMQ-1).
    --
    -- Diagnostic, not a feature. The Quartermaster Queue cannot reliably turn
    -- a dungeon into a travel destination, and the missing fact -- what a
    -- dungeon's travel node is CALLED -- is game data that cannot be read from
    -- source. Turning this on prints the node used by EVERY jump, including
    -- manual ones from the world map, so travelling to a dungeon by hand
    -- reveals its real node name.
    -- ---------------------------------------------------------------------
    local Trace = AccountHold and AccountHold.TravelTrace
    if type(Trace) == "table" then
        add({
            type    = LHAS.ST_CHECKBOX,
            label   = GetString(SI_ACCOUNTHOLD_TRACE_TRAVEL),
            tooltip = GetString(SI_ACCOUNTHOLD_TRACE_TRAVEL_TIP),
            default = false,
            getFunction = function() return Trace.IsEnabled() end,
            setFunction = function(value)
                Trace.SetEnabled(value)
                if value then
                    Trace.Say(GetString(SI_ACCOUNTHOLD_TRACE_ON))
                end
            end,
        })

        add({
            type    = LHAS.ST_BUTTON,
            label   = GetString(SI_ACCOUNTHOLD_TRACE_DUMP),
            tooltip = GetString(SI_ACCOUNTHOLD_TRACE_DUMP_TIP),
            buttonText = GetString(SI_ACCOUNTHOLD_TRACE_DUMP),
            setFunction = function() Trace.DumpDungeonNodes() end,
        })
    end
end

-- ---------------------------------------------------------------------------
-- Confirmation dialog used by the three wipe buttons above. Registers a
-- single shared dialog template lazily on first call, then re-shows it
-- with the scope-specific body text and a callback bound to the right
-- WipeData scope.
-- ---------------------------------------------------------------------------
local DIALOG_CONFIRM_WIPE = "ACCOUNT_HOLD_CONFIRM_WIPE"
local _confirmRegistered  = false

function Settings:_ConfirmWipe(scope, bodyText)
    if not ZO_Dialogs_RegisterCustomDialog or not ZO_Dialogs_ShowDialog then
        addon:WipeData(scope)         -- last-ditch: just do it
        return
    end
    if not _confirmRegistered then
        ZO_Dialogs_RegisterCustomDialog(DIALOG_CONFIRM_WIPE, {
            canQueue = true,
            gamepadInfo = { dialogType = GAMEPAD_DIALOGS and GAMEPAD_DIALOGS.BASIC or 1 },
            title    = { text = GetString(SI_ACCOUNTHOLD_DIALOG_CONFIRM_WIPE_TITLE) },
            mainText = {
                text = function(dialog)
                    return (dialog.data and dialog.data.body) or ""
                end,
            },
            buttons = {
                {
                    text     = GetString(SI_ACCOUNTHOLD_DIALOG_WIPE_CONFIRM),
                    keybind  = "DIALOG_PRIMARY",
                    callback = function(dialog)
                        local d = dialog.data or {}
                        if d.scope == "holds" or d.scope == "all" then
                            if addon.Holds and addon.Holds.CancelAll then
                                addon.Holds:CancelAll()
                            end
                        end
                        addon:WipeData(d.scope or "snapshot")
                    end,
                },
                {
                    text     = GetString(SI_ACCOUNTHOLD_DIALOG_CANCEL),
                    keybind  = "DIALOG_NEGATIVE",
                },
            },
        })
        _confirmRegistered = true
    end
    ZO_Dialogs_ShowDialog(DIALOG_CONFIRM_WIPE, { scope = scope, body = bodyText })
end

-- ---------------------------------------------------------------------------
-- Build the list of routes to surface in the default-route dropdown.
-- Always includes the account bank; appends every guild bank the player is
-- currently a member of. House storage is intentionally NOT enumerated here
-- because membership in a house is zone-bound and the settings panel is
-- typically opened outside any house. The Place-Hold dialog enumerates
-- house routes live at open time, so the user can still pick them per-hold.
-- ---------------------------------------------------------------------------
function Settings:_BuildDefaultRouteOptions()
    local out = {
        { key = "account_bank", label = GetString(SI_ACCOUNTHOLD_SETTINGS_ROUTE_BANK) },
    }
    if GetNumGuilds then
        local n = GetNumGuilds() or 0
        for i = 1, n do
            local guildId = GetGuildId and GetGuildId(i) or 0
            if guildId ~= 0 and Settings:_GuildBankRetrievable(guildId) then
                local name = (GetGuildName and GetGuildName(guildId)) or "?"
                out[#out + 1] = {
                    key   = "guildbank:" .. tostring(guildId),
                    label = (string.format(GetString(SI_ACCOUNTHOLD_LOC_GUILD_BANK), name)),
                }
            end
        end
    end
    return out
end

-- Whether the player can withdraw items from a guild bank (bug 7). Guild-bank
-- deposit routes are gated on this so reserved items are never stranded in a
-- bank the player can't pull from. Defaults to true when the permission API is
-- unavailable.
function Settings:_GuildBankRetrievable(guildId)
    if not DoesPlayerHaveGuildPermission then return true end
    local perm = _G["GUILD_PERMISSION_BANK_WITHDRAW"]
    if not perm then return true end
    local ok, res = pcall(DoesPlayerHaveGuildPermission, guildId, perm)
    if not ok then return true end
    return res and true or false
end

-- ---------------------------------------------------------------------------
-- LibAddonMenu-2.0 panel (PC fallback for future use; not built today)
-- ---------------------------------------------------------------------------

function Settings:_BuildLAM2(LAM)
    -- Stub. Fill in if/when a PC-only LAM2 build is preferred. The control
    -- list mirrors _BuildLHAS above. Until then, LHAS handles both PC and
    -- console because it's embedded.
    addon:Debug("LAM2 backend selected; using LHAS instead.")
    local LHAS = LibHarvensAddonSettings
    if LHAS then self:_BuildLHAS(LHAS) end
end
