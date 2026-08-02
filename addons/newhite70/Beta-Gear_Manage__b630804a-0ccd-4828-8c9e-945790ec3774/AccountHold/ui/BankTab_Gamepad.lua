-- Quartermaster/ui/BankTab_Gamepad.lua
-- Adds a real THIRD tab to the gamepad bank (alongside the native Withdraw /
-- Deposit tabs) that lists the items reserved at the open bank and lets the
-- player approve moves: (A) approve the selected item, (X) approve all.
--
-- This replaces the old floating-overlay / per-row dialog flow on gamepad with
-- a first-class parametric list hooked into GAMEPAD_BANKING, mirroring the
-- pattern InventoryTab_Gamepad.lua uses for GAMEPAD_INVENTORY.
--
-- Design notes (verified against esoui `live` source):
--   * The gamepad bank has NO GetTabBarEntries / SwitchActiveList. Tabs live in
--     ZO_BankingCommon_Gamepad.tabsTable and dispatch through OnCategoryChanged.
--   * ZO_BankingCommon_Gamepad is the SHARED base of BOTH the player bank
--     (GAMEPAD_BANKING, which also drives house storage / the furniture vault)
--     and the guild bank (GAMEPAD_GUILD_BANK, a separate ZO_GuildBank_Gamepad
--     singleton/scene). We attach to BOTH recognized hosts. Each host keeps its
--     OWN AddList result, header tab data, RefreshList adapter and lifecycle
--     state in a per-host record (self._records[host]); we never share one raw
--     list across the two host screens.
--   * We must NOT stomp host.mode (BANKING_GAMEPAD_MODE_*). It drives the
--     native keybind visibility. We track our own state in
--     host._quartermasterTabActive instead.
--   * Everything is pcall/type-guarded so a missing API or a throw can never
--     break the player's bank.

AccountHold = AccountHold or {}
AccountHold.UI = AccountHold.UI or {}
AccountHold.UI.BankTabGamepad = AccountHold.UI.BankTabGamepad or {}

local Tab = AccountHold.UI.BankTabGamepad
local addon

local LIST_NAME    = "accountHoldBank"

-- Row template for ITEM rows. The stock gamepad inventory registers and adds
-- ZO_GamepadItemSubEntryTemplate for every item row (esoui/esoui@master
-- esoui/ingame/inventory/gamepad/gamepadinventory.lua:1153-1154, :1349, :1351).
-- Its label inherits ZO_GamepadSubMenuEntryLabelTemplate — ZoFontGamepad34 with
-- NO modifyTextType (esoui/common/gamepad/zo_gamepadtemplatescommon.xml:188) —
-- and its icon carries a SubStatusIcon child for the locked / BoP overlay
-- (:283-287).
--
-- ZO_GamepadItemEntryTemplate (what we used to use) resolves to
-- ZO_GamepadMenuEntryLabelTemplate instead: modifyTextType="UPPERCASE" (:212)
-- and no SubStatusIcon. That is why our reserved rows SHOUTED while the native
-- Withdraw/Deposit lists next to them did not. It is the template the native
-- CATEGORY list uses (gamepadinventory.lua:982-984), not the item list.
--
-- The fallback is retained so a client that cannot resolve the sub-entry
-- template degrades to exactly what we shipped before rather than an empty tab.
local ITEM_ROW_TEMPLATE          = "ZO_GamepadItemSubEntryTemplate"
local ITEM_ROW_TEMPLATE_FALLBACK = "ZO_GamepadItemEntryTemplate"

local function shortErr(e)
    e = tostring(e or "")
    return (#e > 160) and (e:sub(1, 160) .. "...") or e
end

-- The gamepad banking host singletons we attach to. GAMEPAD_BANKING drives the
-- player bank AND house storage / furniture vault; GAMEPAD_GUILD_BANK is a
-- SEPARATE ZO_GuildBank_Gamepad singleton/scene that also subclasses
-- ZO_BankingCommon_Gamepad. Both probes are guarded so a keyboard-only client
-- or the test harness (where these globals are absent) simply never attaches.
local function isRecognizedHost(h)
    if h == nil then return false end
    if GAMEPAD_BANKING and h == GAMEPAD_BANKING then return true end
    if GAMEPAD_GUILD_BANK and h == GAMEPAD_GUILD_BANK then return true end
    return false
end

local function isGuildHost(h)
    return h ~= nil and GAMEPAD_GUILD_BANK ~= nil and h == GAMEPAD_GUILD_BANK
end

-- Currently-selected guild bank id. Prefer the Scanner's tracked id (set from
-- EVENT_GUILD_BANK_SELECTED) and fall back to the live API. Guarded so the
-- mock / older clients stay safe.
local function selectedGuildBankId()
    if addon and addon.Scanner and addon.Scanner._currentGuildBankId
       and addon.Scanner._currentGuildBankId ~= 0 then
        return addon.Scanner._currentGuildBankId
    end
    if type(GetSelectedGuildBankId) == "function" then
        local ok, id = pcall(GetSelectedGuildBankId)
        if ok and type(id) == "number" and id ~= 0 then return id end
    end
    return 0
end

local function guildIdFromKey(ck)
    if type(ck) ~= "string" then return nil end
    local id = ck:match("^guildbank:(%d+)$")
    return id and tonumber(id) or nil
end

-- Guild item-permission probes. All guarded so a missing global / newer API can
-- never break the tab; the Mover remains the final enforcement layer.
local function guildCanWithdraw(guildId)
    if not guildId or guildId == 0 then return false end
    if type(DoesPlayerHaveGuildPermission) ~= "function" or GUILD_PERMISSION_BANK_WITHDRAW == nil then
        return true
    end
    local ok, res = pcall(DoesPlayerHaveGuildPermission, guildId, GUILD_PERMISSION_BANK_WITHDRAW)
    if not ok then return true end
    return res == true
end

local function guildCanDeposit(guildId)
    if not guildId or guildId == 0 then return false end
    local can = true
    if type(DoesPlayerHaveGuildPermission) == "function" and GUILD_PERMISSION_BANK_DEPOSIT ~= nil then
        local ok, res = pcall(DoesPlayerHaveGuildPermission, guildId, GUILD_PERMISSION_BANK_DEPOSIT)
        if ok then can = (res == true) end
    end
    -- Guild-level deposit privilege (guild size / roster gating). Only consulted
    -- where the global exists on this client build.
    if can and type(DoesGuildHavePrivilege) == "function" and GUILD_PRIVILEGE_BANK_DEPOSIT ~= nil then
        local ok, res = pcall(DoesGuildHavePrivilege, guildId, GUILD_PRIVILEGE_BANK_DEPOSIT)
        if ok then can = (res == true) end
    end
    return can
end

-- ---------------------------------------------------------------------------
-- Native row visuals: PURE helpers
-- ---------------------------------------------------------------------------
-- ZO-free (every base-game call is behind a type check, with an injection point
-- for the mock harness) so these are the testable surface for how a row LOOKS.
-- Rules taken from the published UI source, esoui/esoui@master:
--
--   * Item names reach a native row already formatted with
--     zo_strformat(SI_TOOLTIP_ITEM_NAME, rawName)
--     (esoui/ingame/inventory/sharedinventory.lua:625); the tooltip title uses
--     the same id (esoui/publicallingames/tooltip/itemtooltips.lua:32).
--     "<<t:1>>" alone titlecases but is not the string the game uses.
--   * A native row is coloured by DISPLAY quality:
--     InitializeInventoryVisualData does
--     SetNameColors(self:GetColorsBasedOnQuality(self.displayQuality or self.quality))
--     (esoui/common/gamepad/zo_gamepadentrydata.lua:32).
--   * Secondary detail belongs in SUB LABELS, never appended to the name. The
--     row label is a single ELLIPSIS-clipped line
--     (zo_gamepadtemplatescommon.xml:188), so "Name (Waiting for deposit)" eats
--     the item name itself at TV distance. The native precedent for an item row
--     with an always-visible sub label is InitializeTradingHouseVisualData
--     (zo_gamepadentrydata.lua:48-52).
-- ---------------------------------------------------------------------------

-- Format a raw item name the way the base game does. `formatter` is an
-- injection point: the mock harness has no zo_strformat.
function Tab.FormatItemName(name, formatter)
    if type(name) ~= "string" or name == "" then return "" end
    formatter = formatter or (type(zo_strformat) == "function" and zo_strformat) or nil
    if type(formatter) ~= "function" then return name end
    -- Fall back to the literal expansion of SI_TOOLTIP_ITEM_NAME so a client
    -- (or harness) without the string id registered still strips the markers.
    local fmt = SI_TOOLTIP_ITEM_NAME
    if fmt == nil then fmt = "<<t:1>>" end
    local ok, out = pcall(formatter, fmt, name)
    if ok and type(out) == "string" and out ~= "" then return out end
    return name
end

-- Split a hold into the two things the gamepad template renders separately: the
-- single-line NAME and the sub labels beneath it. ONLY the item/set name may
-- end up in the name; the pending status becomes a sub label.
-- `setLabelFormat` is the "%s (Set)"-style wrapper, `pendingStatus` the string
-- Holds:DescribePendingStatus produced (both may be nil).
-- Returns (text, subLabels).
function Tab.HoldLabels(name, isSetHold, setLabelFormat, pendingStatus)
    local text = (type(name) == "string" and name ~= "") and name or "?"
    -- Make the SET-ness explicit. "Rush of Agony" alone can read as an item
    -- name; the player needs to know ANY piece of the set satisfies this
    -- reservation. This one stays IN the name because it qualifies the name.
    if isSetHold and type(setLabelFormat) == "string" and setLabelFormat ~= "" then
        local ok, out = pcall(string.format, setLabelFormat, text)
        if ok and type(out) == "string" and out ~= "" then text = out end
    end
    local subLabels = {}
    if type(pendingStatus) == "string" and pendingStatus ~= "" then
        subLabels[#subLabels + 1] = pendingStatus
    end
    return text, subLabels
end

-- Display name + icon for a hold (display only; guarded for all client builds).
--
-- A SET hold is named after the SET, not after whichever piece the player
-- happened to be hovering when they created it. Holds:Create copies
-- spec.itemLink onto every hold (src/Holds.lua), so a set reservation made from
-- a "Rush of Agony Sash" row used to render as "Rush of Agony Sash" — which
-- reads as a reservation for that one item and hides the fact that ANY piece of
-- the set satisfies it. The icon still comes from the item link, because a set
-- has no icon of its own and a representative piece is better than none.
local function holdDisplay(hold)
    local name, icon = "?", nil
    local link = hold and hold.itemLink

    if link and link ~= "" and GetItemLinkIcon then
        local ok, i = pcall(GetItemLinkIcon, link)
        if ok then icon = i end
    end

    local isSetHold = hold and hold.holdType == "set" and hold.setId
    if isSetHold and GetItemSetName then
        local ok, n = pcall(GetItemSetName, hold.setId)
        if ok and n and n ~= "" then name = n end
    end

    -- Item holds, and set holds whose set name could not be resolved, fall back
    -- to the item name.
    if name == "?" and link and link ~= "" and GetItemLinkName then
        local ok, n = pcall(GetItemLinkName, link)
        if ok and n and n ~= "" then name = n end
    end

    -- Run it through the game's own item-name formatter. This used to use a
    -- bare "<<t:1>>", which titlecases but is NOT what the base game passes;
    -- SI_TOOLTIP_ITEM_NAME is the id used for item names everywhere else
    -- (sharedinventory.lua:625, itemtooltips.lua:32), and using it keeps the
    -- gender/article markers ("^Fn", "^m") from rendering as literal text.
    name = Tab.FormatItemName(name)
    if name == "" then name = "?" end
    return name, icon, isSetHold and true or false
end

-- ---------------------------------------------------------------------------
-- Keybind strip descriptor (Approve / Approve All / Back)
-- ---------------------------------------------------------------------------
function Tab:Keybinds()
    if self._keybinds then return self._keybinds end
    local tabRef = self
    local function selectedRow()
        local list = tabRef.list
        if list and list.GetTargetData then return list:GetTargetData() end
        return nil
    end
    self._keybinds = {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        {
            -- (A) approve the selected reservation: deposit it (holder) or
            -- withdraw it (requester).
            name = function()
                local td = selectedRow()
                if td and td.qmRole == "holder" then
                    return GetString(SI_ACCOUNTHOLD_BANK_APPROVE_DEPOSIT)
                end
                return GetString(SI_ACCOUNTHOLD_BANK_APPROVE_WITHDRAW)
            end,
            keybind = "UI_SHORTCUT_PRIMARY",
            visible = function()
                local td = selectedRow()
                if not (td ~= nil and td.qmHold ~= nil and td.qmRole ~= "pending") then
                    return false
                end
                -- Respect guild item permissions on a guild container: hide
                -- deposit without deposit permission, withdraw without withdraw
                -- permission. Non-guild containers are always allowed here.
                return tabRef:_GuildGate(td.qmRole == "holder" and "deposit" or "withdraw")
            end,
            callback = function()
                local td = selectedRow()
                if td and td.qmHold and td.qmRole ~= "pending" then
                    tabRef:_ApproveOne(td.qmHold, td.qmRole)
                end
            end,
        },
        {
            -- (X) Withdraw All. This is a USER-REQUIRED, intentionally
            -- withdraw-only bulk action (it processes requester/withdraw rows
            -- only — see _ApproveAll), even though (A) is symmetric
            -- Deposit/Withdraw. The asymmetry is deliberate: bulk-depositing a
            -- holder's items is not offered on a single keybind. Withdraw-only,
            -- so it respects withdraw permission on a guild container.
            name    = function() return GetString(SI_ACCOUNTHOLD_BANK_APPROVE_ALL) end,
            keybind = "UI_SHORTCUT_SECONDARY",
            visible = function()
                return tabRef._hasActionRows == true and tabRef:_GuildGate("withdraw")
            end,
            callback = function() tabRef:_ApproveAll() end,
        },
        {
            -- (Y) Options for the highlighted reservation.
            --
            -- A dialog rather than more keybinds: the bank screen has very few
            -- free slots, claiming one risks colliding with a descriptor the
            -- host already owns (zo_keybindstrip.lua:342-343 does not merely
            -- assert on a duplicate -- it REMOVES the existing button, which is
            -- how this add-on once lost the native Back), and a dialog can hold
            -- as many actions as the reservation needs.
            name    = function() return GetString(SI_ACCOUNTHOLD_BANK_OPTIONS) end,
            keybind = "UI_SHORTCUT_TERTIARY",
            visible = function()
                local td = selectedRow()
                return td ~= nil and td.qmHold ~= nil
            end,
            callback = function()
                local td = selectedRow()
                if td and td.qmHold then tabRef:_ShowRowOptions(td.qmHold) end
            end,
        },
        {
            -- (B) leave the bank, matching the native bank back behaviour. We
            -- removed the native main descriptor while our tab is active, so we
            -- must supply our own back entry.
            name     = function() return GetString(SI_GAMEPAD_BACK_OPTION) end,
            keybind  = "UI_SHORTCUT_NEGATIVE",
            callback = function()
                if SCENE_MANAGER ~= nil and SCENE_MANAGER.HideCurrentScene then
                    pcall(function() SCENE_MANAGER:HideCurrentScene() end)
                end
            end,
        },
    }
    return self._keybinds
end

-- ---------------------------------------------------------------------------
-- Reservation options dialog (expand / tick pieces / cancel)
-- ---------------------------------------------------------------------------
-- A SET reservation covers every piece of the set the account owns, which is
-- exactly why the list collapses it to one row. This is the "expand" half: it
-- lists the constituent pieces and lets the player deselect the ones they do
-- NOT want moved, producing a targeted deposit list.
--
-- Built as a parametric gamepad DIALOG for the same reason the Priorities
-- surface is: dialogs need no scene, no top-level window and no runtime control
-- tree, and are the one gamepad surface that has worked first time on this
-- player's hardware.
--
-- Verified contract (esoui/esoui @ master):
--   zo_dialog.lua:604-605                 dialogInfo.setup(dialog, ...) runs on every show
--   zo_genericdialog_gamepad.lua:692      dialog.setupFunc builds the parametric list
--   zo_genericdialog_gamepad.lua:745      templateData.setup is called UNCONDITIONALLY
--   zo_genericdialog_gamepad.lua:785      ipairs over parametricList, every open
--   zo_genericdialog_gamepad.lua:801-807  a `text` FUNCTION is entry-level only
local ROW_OPTIONS_DIALOG = "ACCOUNT_HOLD_BANK_ROW_OPTIONS_DIALOG"
Tab._ROW_OPTIONS_DIALOG = ROW_OPTIONS_DIALOG

local function optL(id, fallback)
    if AccountHold and type(AccountHold.L) == "function" then
        local ok, s = pcall(AccountHold.L, id, fallback)
        if ok and type(s) == "string" and s ~= "" then return s end
    end
    return fallback
end

-- Build the dialog entries for one hold. Pure apart from string lookups, so the
-- expand/tick/cancel row shape is testable without any UI globals.
function Tab._BuildRowOptionEntries(hold, members, setupFn)
    local entries = {}
    if type(hold) ~= "table" then return entries end

    -- Piece rows: only a SET hold has constituents to expand.
    if type(members) == "table" and #members > 0 then
        local header = optL("SI_ACCOUNTHOLD_BANK_OPT_PIECES", "Pieces (A toggles)")
        for i = 1, #members do
            local m = members[i]
            if type(m) == "table" then
                local mark = m.included
                    and optL("SI_ACCOUNTHOLD_BANK_OPT_ON",  "[x] ")
                    or  optL("SI_ACCOUNTHOLD_BANK_OPT_OFF", "[  ] ")
                local label = mark .. tostring(m.name or "?")
                if m.locationLabel and m.locationLabel ~= "" then
                    label = label .. "  -  " .. tostring(m.locationLabel)
                end
                entries[#entries + 1] = {
                    template = "ZO_GamepadFullWidthLeftLabelEntryTemplate",
                    header   = (i == 1) and header or nil,
                    text     = label,
                    templateData = {
                        setup = setupFn,
                        qmMember = m,
                        qmAction = "toggle",
                    },
                }
            end
        end
    end

    -- Cancel is always offered: an item hold has nothing to expand, but the
    -- player still needs a way to release it from this screen.
    entries[#entries + 1] = {
        template = "ZO_GamepadFullWidthLeftLabelEntryTemplate",
        header   = optL("SI_ACCOUNTHOLD_BANK_OPT_ACTIONS", "Actions"),
        text     = optL("SI_ACCOUNTHOLD_BANK_OPT_CANCEL", "Cancel this reservation"),
        templateData = {
            setup = setupFn,
            qmAction = "cancel",
        },
    }
    return entries
end

function Tab:_ShowRowOptions(hold)
    if type(hold) ~= "table" then return false end
    if type(ZO_Dialogs_RegisterCustomDialog) ~= "function"
       or type(ZO_Dialogs_ShowGamepadDialog) ~= "function"
       or type(ZO_SharedGamepadEntry_OnSetup) ~= "function" then
        if addon and addon.Diagnostic then
            addon:Diagnostic("warn", "Gamepad dialog API unavailable - no reservation options.")
        end
        return false
    end

    local tabRef = self
    local members = {}
    if addon and addon.Holds and addon.Holds.GetSetMembers then
        local ok, m = pcall(addon.Holds.GetSetMembers, addon.Holds, hold)
        if ok and type(m) == "table" then members = m end
    end

    local title = optL("SI_ACCOUNTHOLD_BANK_OPTIONS", "Reservation options")
    local entries = Tab._BuildRowOptionEntries(hold, members, ZO_SharedGamepadEntry_OnSetup)

    local info = {
        gamepadInfo = { dialogType = GAMEPAD_DIALOGS and GAMEPAD_DIALOGS.PARAMETRIC or 1 },
        -- REQUIRED: without this the parametric list is never built and the
        -- dialog opens empty (zo_dialog.lua:604-605 -> setupFunc, :692).
        setup = function(dialog)
            if type(ZO_GenericGamepadDialog_RefreshText) == "function" then
                pcall(ZO_GenericGamepadDialog_RefreshText, dialog, title)
            end
            -- The dialog is a CONTROL, i.e. USERDATA, not a table
            -- (zo_dialog.lua:449 ZO_GenericGamepadDialog_GetControl; :488
            -- dialog:GetNamedChild). Guarding with type(dialog) == "table" was
            -- ALWAYS FALSE in game, so setupFunc never ran, so the parametric
            -- list was never built -- which is exactly the reported
            -- "Y button for Reservation Options doesn't actually display any
            -- options". Duck-type the method instead of the container.
            if dialog ~= nil and type(dialog.setupFunc) == "function" then
                dialog:setupFunc()
            end
        end,
        title = { text = title },
        parametricList = entries,
        blockDialogReleaseOnPress = true,
        buttons = {
            {
                keybind = "DIALOG_PRIMARY",
                text    = optL("SI_ACCOUNTHOLD_BANK_OPT_SELECT", "Select"),
                callback = function(dialog)
                    local reopen = false
                    pcall(function()
                        local td = dialog and dialog.entryList and dialog.entryList:GetTargetData()
                        if not td then return end
                        if td.qmAction == "toggle" and td.qmMember then
                            if addon and addon.Holds and addon.Holds.SetMemberIncluded then
                                pcall(addon.Holds.SetMemberIncluded, addon.Holds, hold,
                                      td.qmMember.itemSignature, not td.qmMember.included)
                            end
                            reopen = true      -- show the new tick state
                        elseif td.qmAction == "cancel" then
                            if addon and addon.Holds and addon.Holds.Cancel and hold.id then
                                pcall(addon.Holds.Cancel, addon.Holds, hold.id)
                            end
                            pcall(function() tabRef:Populate() end)
                        end
                    end)
                    if type(ZO_Dialogs_ReleaseDialogOnButtonPress) == "function" then
                        pcall(ZO_Dialogs_ReleaseDialogOnButtonPress, ROW_OPTIONS_DIALOG)
                    end
                    -- Re-open so the player can tick several pieces without
                    -- re-navigating from the bank list each time.
                    if reopen then
                        pcall(function() tabRef:_ShowRowOptions(hold) end)
                    end
                end,
            },
            {
                keybind = "DIALOG_NEGATIVE",
                text    = SI_DIALOG_CANCEL,
                callback = function()
                    if type(ZO_Dialogs_ReleaseDialogOnButtonPress) == "function" then
                        pcall(ZO_Dialogs_ReleaseDialogOnButtonPress, ROW_OPTIONS_DIALOG)
                    end
                end,
            },
        },
    }

    if not pcall(ZO_Dialogs_RegisterCustomDialog, ROW_OPTIONS_DIALOG, info) then return false end
    if not pcall(ZO_Dialogs_ShowGamepadDialog, ROW_OPTIONS_DIALOG) then return false end
    return true
end

-- ---------------------------------------------------------------------------
-- Per-host state
--
-- GAMEPAD_BANKING (player bank + house storage) and GAMEPAD_GUILD_BANK are two
-- distinct host screens with two distinct native search screens. We must NOT
-- share one raw AddList result between them: each host gets its OWN list, header
-- tab data, RefreshList adapter and lifecycle state, stored on a per-host
-- record. `self.list` / `self._containerKey` / `self._hasActionRows` mirror the
-- CURRENTLY ACTIVE host (bank and guild-bank scenes are mutually exclusive, so
-- only one is ever active), which keeps Populate / keybinds host-agnostic.
-- ---------------------------------------------------------------------------
function Tab:_Record(host)
    self._records = self._records or {}
    local rec = self._records[host]
    if not rec then rec = { host = host }; self._records[host] = rec end
    return rec
end

-- Point the active-host view at `host`'s record and resolve its live container.
function Tab:_SelectHost(host)
    local rec = self:_Record(host)
    self._activeHost   = host
    self.list          = rec.list
    self._containerKey = self:_ResolveContainerKey(host)
end

-- Resolve the ACTUAL container key for a host (never hardcode BAG_BANK):
--   * guild host  -> guildbank:<selectedGuildId>
--   * banking host -> GetBankingBag() -> Mover:ContainerKeyForOpenedBag, so the
--     account bank is "bank" and each house chest is "house:<houseId>:<bagId>".
-- Returns nil when the container is not indexable (e.g. the furniture vault,
-- which the Scanner does not index) so the tab is left unavailable there.
function Tab:_ResolveContainerKey(host)
    if isGuildHost(host) then
        local gid = selectedGuildBankId()
        if gid and gid ~= 0 then return "guildbank:" .. tostring(gid) end
        return nil
    end
    local bag = (type(GetBankingBag) == "function") and GetBankingBag() or nil
    if bag and addon and addon.Mover and addon.Mover.ContainerKeyForOpenedBag then
        local ok, key = pcall(function() return addon.Mover:ContainerKeyForOpenedBag(bag) end)
        if ok and type(key) == "string" and key ~= "" then return key end
    end
    return nil
end

-- Permission gate for the ACTIVE container. Non-guild containers are always
-- allowed here (space/bind checks stay in the Mover); a guild container gates
-- "withdraw" on GUILD_PERMISSION_BANK_WITHDRAW and "deposit" on the deposit
-- permission/privilege.
function Tab:_GuildGate(action)
    local gid = guildIdFromKey(self._containerKey)
    if not gid then return true end
    if action == "deposit" then return guildCanDeposit(gid) end
    return guildCanWithdraw(gid)
end

-- ---------------------------------------------------------------------------
-- List creation + population
-- ---------------------------------------------------------------------------
function Tab:_EnsureList(host)
    if type(host) ~= "table" or type(host.AddList) ~= "function" then return nil end
    local rec = self:_Record(host)
    if rec.list then return rec.list end
    local ok, list = pcall(function()
        return host:AddList(LIST_NAME, function(theList)
            -- Native registers the SUB-entry template for its item list, with
            -- BOTH a plain and a with-header variant
            -- (esoui/esoui@master esoui/ingame/inventory/gamepad/gamepadinventory.lua:1153-1154).
            -- We used to register only ZO_GamepadItemEntryTemplate, whose label
            -- is ZO_GamepadMenuEntryLabelTemplate with modifyTextType="UPPERCASE"
            -- (zo_gamepadtemplatescommon.xml:212) — that is why our reserved rows
            -- SHOUTED while the Withdraw/Deposit lists beside them did not.
            --
            -- The with-header variant must exist or _AddSection's
            -- AddEntryWithHeader call throws, which leaves Commit() with an
            -- inconsistent list and renders the tab empty. Header template name
            -- matches ZO_Gamepad_ParametricList_Screen:SetupList.
            local itemTemplate = ITEM_ROW_TEMPLATE_FALLBACK
            if theList.AddDataTemplate and ZO_SharedGamepadEntry_OnSetup
               and ZO_GamepadMenuEntryTemplateParametricListFunction then
                local function register(name)
                    return pcall(function()
                        theList:AddDataTemplate(
                            name,
                            ZO_SharedGamepadEntry_OnSetup,
                            ZO_GamepadMenuEntryTemplateParametricListFunction)
                        if theList.AddDataTemplateWithHeader then
                            theList:AddDataTemplateWithHeader(
                                name,
                                ZO_SharedGamepadEntry_OnSetup,
                                ZO_GamepadMenuEntryTemplateParametricListFunction,
                                nil,
                                "ZO_GamepadMenuEntryHeaderTemplate")
                        end
                    end)
                end
                if register(ITEM_ROW_TEMPLATE) then
                    itemTemplate = ITEM_ROW_TEMPLATE
                else
                    -- Degrade to exactly what we shipped before.
                    register(ITEM_ROW_TEMPLATE_FALLBACK)
                end
            end
            self._itemTemplate = itemTemplate
            -- Stored on the LIST, not on the tab: the bank and the guild bank
            -- are separate hosts with separate lists, and if one registered the
            -- sub-entry template while the other fell back, a tab-level field
            -- would make one of them add rows under a template it never
            -- registered (AddEntry throws, the pcall eats it, the tab looks
            -- empty). _AddSection already receives the list, so it reads it here.
            theList.qmItemTemplate = itemTemplate
        end)
    end)
    if ok and list then
        rec.list = list
        -- ZO_Gamepad_ParametricList_Search_Screen:PerformUpdate (esoui `live`,
        -- line ~64) calls GetCurrentList():RefreshList(). Our classless
        -- host:AddList result is a raw ZO_GamepadVerticalItemParametricScroll
        -- list that has NO RefreshList method, yet _ActivateTab makes it the
        -- current list. The first BAG_BACKPACK inventory update after a
        -- successful withdraw therefore drives PerformUpdate into a nil
        -- RefreshList and crashes the gamepad UI. Attach a minimal list-contract
        -- adapter PER HOST (only when absent) that re-selects this host and
        -- routes RefreshList back to Populate(). The reentrancy guard is stored
        -- on the host record (so a refresh on one host can't wedge the other)
        -- and is ALWAYS cleared even when Populate errors, because pcall never
        -- rethrows; failures surface through Diagnostic rather than being
        -- swallowed.
        if type(list.RefreshList) ~= "function" then
            local tab = self
            list.RefreshList = function()
                if rec.refreshing then return end
                rec.refreshing = true
                local pok, perr = pcall(function()
                    tab:_SelectHost(host)
                    tab:Populate()
                end)
                rec.refreshing = false
                if not pok and addon and addon.Diagnostic then
                    addon:Diagnostic("warn",
                        "Quartermaster bank list refresh failed: %s", shortErr(perr))
                end
            end
        end
        if list.SetNoItemText then
            pcall(function() list:SetNoItemText(GetString(SI_ACCOUNTHOLD_BANK_TAB_EMPTY)) end)
        end
        -- Selection changes on OUR list must refresh OUR keybind group (so the
        -- (A) label flips Deposit/Withdraw with the highlighted row) WITHOUT
        -- invoking the native UpdateKeybinds side effects (which would re-add
        -- the empty Y itemActions on our non-slot rows). We route target-change
        -- through _UpdateQMKeybinds when our list is current.
        --
        -- It must ALSO paint the item tooltip. Our rows are not real bag slots,
        -- so the native bank screen has nothing to lay out for them and simply
        -- leaves whatever was last shown — which is why reserved rows appeared
        -- with no tooltip at all and the player could not tell which item they
        -- were on.
        if type(list.SetOnSelectedDataChangedCallback) == "function" then
            local tab, theHost = self, host
            pcall(function()
                list:SetOnSelectedDataChangedCallback(function(_, selectedData)
                    if tab:_IsQMCurrent(theHost) then
                        tab:_UpdateQMKeybinds(theHost)
                    end
                    tab:_UpdateTooltip(selectedData)
                end)
            end)
        end
    elseif addon and addon.Diagnostic then
        addon:Diagnostic("warn", "Quartermaster bank list could not be created: %s", shortErr(list))
    end
    return rec.list
end

-- Build one of our custom tooltip lines. Every step is guarded: a missing
-- string id, a missing zo_strformat or a bad substitution must drop the LINE,
-- never the whole tooltip (and never the bank screen behind it).
local function tooltipLine(stringId, ...)
    local pattern
    if type(GetString) == "function" and stringId ~= nil then
        local ok, s = pcall(GetString, stringId)
        if ok and type(s) == "string" and s ~= "" then pattern = s end
    end
    if type(pattern) ~= "string" then return nil end
    if type(zo_strformat) == "function" then
        local ok, out = pcall(zo_strformat, pattern, ...)
        if ok and type(out) == "string" and out ~= "" then return out end
    end
    -- No formatter (or it refused the pattern): show the unsubstituted string
    -- rather than nothing, so the line still tells the player which field it is.
    return pattern
end

-- Drop every tooltip we may have painted, on BOTH panes, so a stale
-- Quartermaster card can never sit over a native bank screen.
--
-- Native prefers Reset over ClearTooltip when it swaps lists —
-- ZO_GamepadInventory:SwitchActiveList does
-- GAMEPAD_TOOLTIPS:Reset(GAMEPAD_LEFT_TOOLTIP) / Reset(GAMEPAD_RIGHT_TOOLTIP)
-- (esoui/ingame/inventory/gamepad/gamepadinventory.lua:269-270) — because Reset
-- also restores the background, scroll and header state a Layout* call may have
-- changed (zo_tooltip_gamepad.lua:292-310), where ClearTooltip only empties the
-- lines (:156-170). We use Reset when it exists and fall back to ClearTooltip.
-- ClearTooltip clears the status label itself (:169), so the explicit
-- ClearStatusLabel only matters on the Reset path.
function Tab:_ClearTooltips()
    if GAMEPAD_TOOLTIPS == nil then return end
    local which = {}
    -- Built by hand rather than as a literal: a nil constant in a table literal
    -- would truncate ipairs and silently skip the other pane.
    if GAMEPAD_LEFT_TOOLTIP  ~= nil then which[#which + 1] = GAMEPAD_LEFT_TOOLTIP  end
    if GAMEPAD_RIGHT_TOOLTIP ~= nil then which[#which + 1] = GAMEPAD_RIGHT_TOOLTIP end
    local reset = GAMEPAD_TOOLTIPS.Reset
    for _, id in ipairs(which) do
        local done = false
        if type(reset) == "function" then
            done = pcall(function() GAMEPAD_TOOLTIPS:Reset(id) end)
        end
        if not done then
            pcall(function() GAMEPAD_TOOLTIPS:ClearTooltip(id) end)
        end
    end
    pcall(function() GAMEPAD_TOOLTIPS:ClearStatusLabel(GAMEPAD_LEFT_TOOLTIP) end)
end

-- Paint the gamepad item tooltip for the highlighted Quartermaster row.
--
-- Why this exists at all: our rows are synthetic (they describe a HOLD, not a
-- live bag slot), so the native bank screen has no slot to lay out for them and
-- leaves whatever the previous list painted. The result was a reserved row with
-- either no tooltip or a stale one, so the player could not tell which item they
-- were hovering.
--
-- Callback contract (zo_parametricscrolllist.lua:1135): the handler is invoked
-- as (list, selectedData, oldData, reachedTarget, targetIndex), and :843 fires
-- it with selectedData = nil when the selection is cleared. Both shapes are
-- handled. Everything is pcall-guarded: a tooltip failure must never take the
-- bank screen down with it.
function Tab:_UpdateTooltip(selectedData)
    if GAMEPAD_TOOLTIPS == nil then return end

    -- Tolerate being called with no argument by resolving from the list.
    if selectedData == nil and self.list and type(self.list.GetTargetData) == "function" then
        local ok, data = pcall(self.list.GetTargetData, self.list)
        if ok then selectedData = data end
    end

    local hold = type(selectedData) == "table" and selectedData.qmHold or nil
    local link = hold and hold.itemLink
    if not link or link == "" then
        -- Selection left our list (or landed on a row with no item). Drop BOTH
        -- panes: leaving only the left one clear would strand the equipped
        -- comparison card we may have painted on the right over a native screen.
        self:_ClearTooltips()
        return
    end

    -- The native bank category rows set the LEFT tooltip status label; the
    -- Layout* calls do not reset it (ClearTooltip does, at
    -- esoui/ingame/tooltip/gamepad/zo_tooltip_gamepad.lua:169, but we are not
    -- calling it on this path), so a stale header would sit above our card.
    pcall(function() GAMEPAD_TOOLTIPS:ClearStatusLabel(GAMEPAD_LEFT_TOOLTIP) end)

    -- Lay the native item card down first, then append our own lines beneath
    -- it — the same ordering the inventory blade uses, so the two surfaces
    -- read identically.
    --
    -- LayoutItemWithStackCountSimple, not LayoutBagItem: LayoutBagItem reads a
    -- LIVE (bagId, slotIndex) — GetItemLink/IsItemPlayerLocked/GetItemCreatorName
    -- on that slot (esoui/publicallingames/tooltip/itemtooltips.lua:1686-1727)
    -- — and our rows are synthetic descriptions of a hold with no slot behind
    -- them. The link-only variant (itemtooltips.lua:1680-1682) is the correct
    -- call here and is what the base game itself uses wherever it only has a
    -- link.
    pcall(function()
        GAMEPAD_TOOLTIPS:LayoutItemWithStackCountSimple(
            GAMEPAD_LEFT_TOOLTIP, link, hold.desiredCount or 1)
    end)

    -- Gear comparison against what the player is wearing, on the RIGHT tooltip.
    -- The native item list drives exactly this off the same selection callback:
    -- OnSelectedDataChangedCallback calls UpdateItemLeftTooltip
    -- (esoui/ingame/inventory/gamepad/gamepadinventory.lua:1162) AND
    -- UpdateRightTooltip (:1169), whose comparison branch is
    -- ZO_LayoutBagItemEquippedComparison (:1610, defined at
    -- itemtooltips.lua:1745). We call the LINK-only sibling
    -- ZO_LayoutItemLinkEquippedComparison (itemtooltips.lua:1731-1743) because
    -- a hold has no slot to read; it returns false for anything non-equippable
    -- (GetItemLinkEquippedComparisonEquipSlots -> EQUIP_SLOT_NONE) and sets the
    -- right pane's "Equipped" rail itself via
    -- ZO_InventoryUtils_UpdateTooltipEquippedIndicatorText. We clear the pane
    -- first, so a failure leaves it empty exactly as before rather than stale.
    pcall(function() GAMEPAD_TOOLTIPS:ClearTooltip(GAMEPAD_RIGHT_TOOLTIP) end)
    if type(ZO_LayoutItemLinkEquippedComparison) == "function" then
        pcall(function()
            ZO_LayoutItemLinkEquippedComparison(GAMEPAD_RIGHT_TOOLTIP, link)
        end)
    end

    local lines = {}

    -- A set reservation gets ONE unambiguous line. Previously this produced
    -- three overlapping lines ("Reserved: <set>" / "Reserved for <char>" /
    -- "Reserved"), each telling half the story and none of them saying the
    -- thing that actually matters: every piece of the set is spoken for.
    local setName
    if hold.holdType == "set" and hold.setId and type(GetItemSetName) == "function" then
        local ok, n = pcall(GetItemSetName, hold.setId)
        if ok and type(n) == "string" and n ~= "" then setName = n end
    end

    local who = addon and addon.Holds and addon.Holds.HolderName
                and addon.Holds:HolderName(hold)

    if setName then
        if who and who ~= "" then
            lines[#lines + 1] = string.format(
                GetString(SI_ACCOUNTHOLD_TOOLTIP_SET_RESERVED_FOR), setName, who)
        else
            lines[#lines + 1] = string.format(
                GetString(SI_ACCOUNTHOLD_TOOLTIP_SET_RESERVED), setName)
        end
    elseif who and who ~= "" then
        lines[#lines + 1] = string.format(GetString(SI_ACCOUNTHOLD_TOOLTIP_RESERVED_FOR), who)
    else
        lines[#lines + 1] = GetString(SI_ACCOUNTHOLD_TOOLTIP_RESERVED)
    end

    if type(selectedData) == "table" and selectedData.qmPendingStatus
       and selectedData.qmPendingStatus ~= "" then
        local line = tooltipLine(SI_ACCOUNTHOLD_TOOLTIP_HOLD_STATUS,
                                 selectedData.qmPendingStatus)
        if line then lines[#lines + 1] = line end
    end

    if #lines == 0 then return end

    pcall(function()
        if type(GAMEPAD_TOOLTIPS.GetTooltip) ~= "function" then return end
        local tt = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP)
        if not tt or type(tt.AcquireSection) ~= "function" then return end
        local section = tt:AcquireSection(tt:GetStyle("bodySection"))
        for _, line in ipairs(lines) do
            section:AddLine(line, tt:GetStyle("bodyDescription"))
        end
        tt:AddSection(section)
    end)
end

-- Resolve the visual fields (quality colour, true stack count, uniqueId) the
-- gamepad item template needs so our bank rows render like native inventory
-- rows instead of a plain white "1x" line. Quality comes from the itemLink;
-- the real stack count / uniqueId come from the scanned index row when
-- available, falling back to the reserved count. All lookups are guarded.
--
-- DISPLAY quality first: a native row colours by displayQuality, not functional
-- quality (zo_gamepadentrydata.lua:32, and the tooltip title uses
-- GetItemLinkDisplayQuality at itemtooltips.lua:30). The two differ for any
-- item whose displayed tier has been shifted (e.g. crafted/upgraded gear), so
-- reading functional quality first could paint our row a different colour from
-- the very same item in the Withdraw list beside it.
local function holdVisual(hold)
    local quality, stack, uid
    local link = hold and hold.itemLink
    if link and link ~= "" then
        if GetItemLinkDisplayQuality then
            local ok, q = pcall(GetItemLinkDisplayQuality, link)
            if ok and type(q) == "number" then quality = q end
        end
        if quality == nil and GetItemLinkFunctionalQuality then
            local ok, q = pcall(GetItemLinkFunctionalQuality, link)
            if ok and type(q) == "number" then quality = q end
        end
        if quality == nil and GetItemLinkQuality then
            local ok, q = pcall(GetItemLinkQuality, link)
            if ok and type(q) == "number" then quality = q end
        end
    end
    if addon and addon.Index and addon.Index.RowsForHold then
        local ok, rows = pcall(function() return addon.Index:RowsForHold(hold) end)
        if ok and type(rows) == "table" then
            for _, r in ipairs(rows) do
                if r.entry then
                    stack   = stack or r.entry.stackCount
                    uid     = uid or r.entry.uniqueId
                    quality = quality or r.entry.quality
                end
            end
        end
    end
    stack = stack or (hold and hold.desiredCount) or 1
    return quality, stack, uid
end

-- Append one role section (with a header on its first row). Returns row count.
--
-- Row construction mirrors the stock gamepad inventory
--     local entryData = ZO_GamepadEntryData:New(itemData.name, itemData.iconFile)
--     entryData:InitializeInventoryVisualData(itemData)
-- (esoui/esoui@master esoui/ingame/inventory/gamepad/gamepadinventory.lua:1309-1310),
-- with everything that initializer would do ALSO set explicitly afterwards so a
-- client where it is missing or throws still gets a native-looking row.
--
-- Our rows are SYNTHETIC — they describe a hold, not a live bag slot — so we
-- deliberately never call ZO_InventorySlot_SetType (gamepadinventory.lua:1337)
-- and never hand these entries to itemActions:SetInventorySlot(); doing so
-- previously corrupted the keybind strip.
function Tab:_AddSection(list, holds, role, headerText)
    if type(holds) ~= "table" or #holds == 0 then return 0 end
    if not (ZO_GamepadEntryData and (list.AddEntry or list.AddEntryWithHeader)) then return 0 end
    local template = list.qmItemTemplate or self._itemTemplate or ITEM_ROW_TEMPLATE_FALLBACK
    local n = 0
    for i, hold in ipairs(holds) do
        local name, icon, isSetHold = holdDisplay(hold)
        local pendingStatus
        if role == "pending" and addon.Holds and addon.Holds.DescribePendingStatus then
            pendingStatus = addon.Holds:DescribePendingStatus(hold)
        end
        -- The pending status used to be concatenated into the name as
        -- "Name (Waiting for deposit)". That is one ELLIPSIS-clipped line
        -- (zo_gamepadtemplatescommon.xml:188), so at TV distance the status
        -- pushed the item name itself off the end of the row. It is secondary
        -- information, so it belongs in a sub label, which is exactly what the
        -- native templates provide for it.
        local displayName, subLabels = Tab.HoldLabels(
            name, isSetHold, GetString(SI_ACCOUNTHOLD_HOLD_SET_LABEL), pendingStatus)
        local quality, stackCount, uid = holdVisual(hold)
        stackCount = stackCount or 1
        local data = ZO_GamepadEntryData:New(displayName, icon)
        if data.InitializeInventoryVisualData then
            pcall(function()
                data:InitializeInventoryVisualData({
                    name = displayName,
                    -- iconFile ONLY. New(name, icon) already called AddIcon
                    -- (zo_gamepadentrydata.lua:13) and this initializer calls
                    -- AddIcon(itemData.icon) again (:29). Native survives that
                    -- because the shared inventory only ever populates
                    -- slot.iconFile, never slot.icon (sharedinventory.lua:635),
                    -- so the second call is a no-op and the row has exactly one
                    -- icon. Setting BOTH gave every row two icons in the
                    -- ZO_MultiIcon, which animates between frames.
                    iconFile = icon,
                    stackCount = stackCount,
                    displayQuality = quality, quality = quality,
                    uniqueId = uid,
                })
            end)
        end
        data.qmHold = hold
        data.qmRole = role
        data.qmPendingStatus = pendingStatus

        -- Explicit copies of what InitializeInventoryVisualData sets, so the row
        -- still looks native if that method is absent or threw.
        if quality and data.SetNameColors and data.GetColorsBasedOnQuality then
            pcall(function() data:SetNameColors(data:GetColorsBasedOnQuality(quality)) end)
        end
        if data.SetStackCount then
            -- The badge only prints when the count is > 1
            -- (zo_gamepadtemplatescommon.lua:300-306), so singles stay bare
            -- exactly like native.
            pcall(function() data:SetStackCount(stackCount) end)
        end
        -- Item rows explicitly do NOT grow on selection: the initializer ends
        -- with SetFontScaleOnSelection(false) and the comment "item entries
        -- don't grow on selection" (zo_gamepadentrydata.lua:35). Only
        -- menu/category rows scale.
        if data.SetFontScaleOnSelection then
            pcall(function() data:SetFontScaleOnSelection(false) end)
        end
        -- Native sets this on every inventory item row (gamepadinventory.lua:1343).
        -- Without it data.traitInformation is nil, and the status-indicator pass
        -- tests `traitInformation ~= ITEM_TRAIT_INFORMATION_NONE` (which is 0),
        -- so nil passes and it asks for the icon of a nil trait
        -- (zo_gamepadtemplatescommon.lua:428-430).
        if data.SetIgnoreTraitInformation then
            pcall(function() data:SetIgnoreTraitInformation(true) end)
        end
        -- Every row in this tab IS a reservation, so every row gets the native
        -- padlock pip: SetLocked (zo_gamepadentrydata.lua:387) drives
        -- ZO_GAMEPAD_LOCKED_ICON_32 in the status-indicator pass
        -- (zo_gamepadtemplatescommon.lua:424-426) — the same visual language the
        -- game already uses for "you cannot casually get rid of this".
        if data.SetLocked then
            pcall(function() data:SetLocked(true) end)
        end
        if data.AddSubLabel then
            for _, s in ipairs(subLabels) do
                pcall(function() data:AddSubLabel(s) end)
            end
            if #subLabels > 0 then
                if data.SetSubLabelColors and ZO_NORMAL_TEXT then
                    pcall(function() data:SetSubLabelColors(ZO_NORMAL_TEXT) end)
                end
                if data.SetShowUnselectedSublabels then
                    pcall(function() data:SetShowUnselectedSublabels(true) end)
                end
            end
        end

        local added = false
        if i == 1 and list.AddEntryWithHeader then
            data.header = headerText
            if data.SetHeader then pcall(function() data:SetHeader(headerText) end) end
            added = pcall(function()
                list:AddEntryWithHeader(template, data)
            end)
        end
        if not added and list.AddEntry then
            pcall(function() list:AddEntry(template, data) end)
        end
        n = n + 1
    end
    return n
end

function Tab:Populate()
    local list = self.list
    if not list then return end
    local ck = self._containerKey or self:_ResolveContainerKey(self._activeHost)
    self._containerKey = ck

    local function updateKeybinds()
        -- Only ever touch OUR group, and only when our list is current, so a
        -- repopulate never fires the native UpdateKeybinds (empty Y itemActions).
        if self:_IsQMCurrent(self._activeHost) then
            self:_UpdateQMKeybinds(self._activeHost)
        end
    end

    -- No indexable container (e.g. the furniture vault, or a guild bank whose id
    -- isn't known yet): render an empty list with no action rows so nothing can
    -- be approved against an untracked store.
    if not ck then
        if list.Clear then pcall(function() list:Clear() end) end
        if list.Commit then pcall(function() list:Commit() end) end
        self._hasRows = false
        self._hasActionRows = false
        updateKeybinds()
        return
    end

    if addon.Holds and addon.Holds.RefreshAllCandidates then
        pcall(function() addon.Holds:RefreshAllCandidates() end)
    end

    local requester = (addon.Holds and addon.Holds.GetHoldsAtContainer
        and addon.Holds:GetHoldsAtContainer(ck, "requester")) or {}
    local holder = (addon.Holds and addon.Holds.GetHoldsAtContainer
        and addon.Holds:GetHoldsAtContainer(ck, "holder")) or {}
    local pending = (addon.Holds and addon.Holds.GetPendingHoldsForCharacter
        and addon.Holds:GetPendingHoldsForCharacter(ck)) or {}

    if list.Clear then pcall(function() list:Clear() end) end

    local total = 0
    local actionable = 0
    actionable = actionable + self:_AddSection(list, requester, "requester",
        GetString(SI_ACCOUNTHOLD_BANK_SECTION_WITHDRAW))
    actionable = actionable + self:_AddSection(list, holder, "holder",
        GetString(SI_ACCOUNTHOLD_BANK_SECTION_DEPOSIT))
    total = actionable
    total = total + self:_AddSection(list, pending, "pending",
        GetString(SI_ACCOUNTHOLD_BANK_SECTION_PENDING))
    self._hasRows = total > 0
    self._hasActionRows = actionable > 0

    if list.Commit then pcall(function() list:Commit() end) end

    -- Paint the tooltip for whatever ends up selected after the rebuild. The
    -- SelectedDataChanged callback only fires on a CHANGE, so without this the
    -- first row shown after a repopulate would have no tooltip.
    self:_UpdateTooltip(nil)

    updateKeybinds()
end

-- ---------------------------------------------------------------------------
-- Approve actions
-- ---------------------------------------------------------------------------
-- Force a fresh scan of the currently-open container so the Index rows the
-- Mover trusts in its first (cached-slot) pass reflect the item's CURRENT slot.
-- Without this, an item deposited by another character (or moved since our last
-- scan) has a stale cached slot; pass 1 skips it and — for holds created without
-- an itemSignature — the pass-2 signature re-scan can't recover, so the withdraw
-- silently moves nothing. Guarded so a missing Scanner can never break approve.
local function refreshOpenContainer(containerKey)
    if not (addon and addon.Scanner) then return end
    local s = addon.Scanner
    if containerKey == "bank" then
        if s.ScanAccountBank then pcall(function() s:ScanAccountBank() end) end
        return
    end
    if type(containerKey) == "string" then
        local gid = containerKey:match("^guildbank:(%d+)$")
        if gid and s.ScanGuildBank then
            pcall(function() s:ScanGuildBank(tonumber(gid)) end)
            return
        end
        local hbag = containerKey:match("^house:%d+:(%d+)$")
        if hbag and s.ScanHouseStorage then
            pcall(function() s:ScanHouseStorage(tonumber(hbag)) end)
            return
        end
    end
end

-- Surface the outcome of an approve action so a no-op is never silent. The
-- Mover returns the QUEUED (not yet confirmed) count; the actual moved total is
-- announced separately by the Mover on queue completion. We therefore report
-- "Queued N..." here — never "Moved N" for merely enqueued work. If this pass
-- space-blocked, the Mover already alerted with the exact count, so we stay
-- quiet; otherwise, when nothing was queued we show the "nothing moved"
-- message. We use the per-pass blocked count (returned by the Mover) rather
-- than the Mover's sticky retry flag, which can linger from an earlier action
-- and would wrongly suppress this message forever.
local function reportMoveResult(queued, blocked, role)
    if not (addon and addon.Notify and addon.Notify.Alert) then return end
    if queued and queued > 0 then
        pcall(function()
            addon.Notify:Alert(GetString(SI_ACCOUNTHOLD_BANK_MOVE_QUEUED):format(queued))
        end)
    elseif not (blocked and blocked > 0) then
        -- A deposit pulls from the player's own bags, not from the container,
        -- so the "reopen the bank" advice would be actively misleading.
        local stringId = (role == "holder")
            and SI_ACCOUNTHOLD_BANK_MOVE_NONE_DEPOSIT
            or SI_ACCOUNTHOLD_BANK_MOVE_NONE
        pcall(function() addon.Notify:Alert(GetString(stringId)) end)
    end
end

function Tab:_ApproveOne(hold, role)
    if role == "pending" then return end
    local ck = self._containerKey or self:_ResolveContainerKey(self._activeHost)
    if not ck then return end
    -- Respect guild permissions defensively (visibility already hides gated
    -- actions; the Mover is the final enforcement layer regardless).
    if not self:_GuildGate(role == "holder" and "deposit" or "withdraw") then return end
    refreshOpenContainer(ck)
    local queued, blocked = 0, 0
    if role == "holder" then
        if addon.Mover and addon.Mover.DepositForHolds then
            pcall(function() queued, blocked = addon.Mover:DepositForHolds(ck, { hold }) end)
        end
    else
        if addon.Mover and addon.Mover.WithdrawForHolds then
            pcall(function() queued, blocked = addon.Mover:WithdrawForHolds(ck, { hold }) end)
        end
    end
    reportMoveResult(queued or 0, blocked or 0, role)
    self:Populate()
end

function Tab:_ApproveAll()
    local ck = self._containerKey or self:_ResolveContainerKey(self._activeHost)
    if not ck then return end
    -- "Withdraw All" is withdraw-only, so it must respect withdraw permission
    -- on a guild container.
    if not self:_GuildGate("withdraw") then return end
    refreshOpenContainer(ck)
    if addon.Holds and addon.Holds.RefreshAllCandidates then
        pcall(function() addon.Holds:RefreshAllCandidates() end)
    end
    -- "Withdraw All" processes requester/withdraw rows ONLY, so this label never
    -- silently deposits holder rows. Deposits stay on the per-row action
    -- (_ApproveOne with role "holder") and the keyboard action panel.
    local requester = (addon.Holds and addon.Holds:GetHoldsAtContainer(ck, "requester")) or {}
    local queued, blocked = 0, 0
    if #requester > 0 and addon.Mover and addon.Mover.WithdrawForHolds then
        pcall(function()
            local q, b = addon.Mover:WithdrawForHolds(ck, requester)
            queued = queued + (q or 0); blocked = blocked + (b or 0)
        end)
    end
    reportMoveResult(queued, blocked)
    self:Populate()
end

-- ---------------------------------------------------------------------------
-- Native keybind restoration via idempotent INSTANCE-level wrappers
--
-- The gamepad bank re-adds its native keybind groups from several native entry
-- points that fire out-of-band while ANY list is current:
--   * player bank: AddKeybinds re-adds mainKeybindStripDescriptor; UpdateKeybinds
--     re-adds the SEPARATE nonListItemKeybind AND itemActions. itemActions is
--     the "Actions" (Y) group, which renders EMPTY on our non-inventory-slot
--     rows (and, if fed one of our custom entries, corrupts the strip and drops
--     native B).
--   * guild bank: a single currentKeybindStripDescriptor and NO itemActions.
--   * SetCurrentList ALWAYS virtual-dispatches RefreshKeybinds, and the bank's
--     RefreshKeybinds re-adds those native groups.
-- ZO_PostHook cannot suppress an original's side effects, so we REPLACE the
-- three methods on THIS host instance with idempotent wrappers. Each wrapper
-- guards SOLELY on "is our custom list the current list?": when it is, we
-- install/refresh OUR A/X/B group and skip the native re-add (so the empty Y
-- Actions never appears on our list); when it is NOT (a native list is
-- current), we call the original, which restores the native groups. We
-- deliberately do NOT gate on a broad _quartermasterTabActive flag — that would
-- also suppress the native restoration path.
-- ---------------------------------------------------------------------------

-- Is our custom list the host's current list?
function Tab:_IsQMCurrent(host)
    if type(host) ~= "table" or type(host.GetCurrentList) ~= "function" then return false end
    local rec = self._records and self._records[host]
    if not (rec and rec.list) then return false end
    local ok, cur = pcall(function() return host:GetCurrentList() end)
    return ok and cur == rec.list
end

-- The native keybind descriptor groups a host owns (only the fields present):
-- player bank -> main + nonListItem + itemActions; guild bank -> current.
function Tab:_NativeGroups(host)
    local out = {}
    local function push(g) if type(g) == "table" then out[#out + 1] = g end end
    push(host.mainKeybindStripDescriptor)
    push(host.currentKeybindStripDescriptor)
    push(host.nonListItemKeybind)
    push(host.itemActions)
    return out
end

local function stripAdd(group)
    if KEYBIND_STRIP ~= nil and KEYBIND_STRIP.AddKeybindButtonGroup and type(group) == "table" then
        pcall(function() KEYBIND_STRIP:AddKeybindButtonGroup(group) end)
    end
end
local function stripRemove(group)
    if KEYBIND_STRIP ~= nil and KEYBIND_STRIP.RemoveKeybindButtonGroup and type(group) == "table" then
        pcall(function() KEYBIND_STRIP:RemoveKeybindButtonGroup(group) end)
    end
end
local function stripUpdate(group)
    if KEYBIND_STRIP ~= nil and KEYBIND_STRIP.UpdateKeybindButtonGroup and type(group) == "table" then
        pcall(function() KEYBIND_STRIP:UpdateKeybindButtonGroup(group) end)
    end
end

-- Remove every native group from the strip (used on activation so a group the
-- previously-current native list left behind cannot linger under ours).
function Tab:_RemoveNativeGroups(host)
    for _, g in ipairs(self:_NativeGroups(host)) do stripRemove(g) end
end

-- Add + refresh OUR keybind group. Idempotent: added at most once, labels /
-- visibility re-evaluated each call. Also defensively clears any native group
-- so the empty Y Actions can never coexist with our list.
function Tab:_InstallQMKeybinds(host)
    local rec = self:_Record(host)
    self:_RemoveNativeGroups(host)
    if not rec.qmAdded then
        stripAdd(self:Keybinds())
        rec.qmAdded = true
    end
    stripUpdate(self:Keybinds())
end

-- Re-evaluate OUR group only (selection changes / repopulate) — never the
-- native UpdateKeybinds itemActions path.
function Tab:_UpdateQMKeybinds(host)
    local rec = self:_Record(host)
    if not rec.qmAdded then
        self:_InstallQMKeybinds(host)
        return
    end
    stripUpdate(self:Keybinds())
end

-- Remove OUR group (used when leaving our tab). We do NOT re-add native groups
-- here: native restoration happens by letting the native category/list path
-- make its native list current, after which its own RefreshKeybinds/AddKeybinds
-- (reached through the wrapper's ORIGINAL branch) re-adds them. The strip
-- removal is unconditional (RemoveKeybindButtonGroup no-ops on an absent group)
-- so leaving the tab can never leave QM keybind residue behind, even if the
-- qmAdded bookkeeping ever drifts.
function Tab:_RemoveQMKeybinds(host)
    local rec = self:_Record(host)
    stripRemove(self:Keybinds())
    rec.qmAdded = false
end

-- Install the idempotent instance-level wrappers on this host (once per host).
function Tab:_WrapHostKeybinds(host)
    local rec = self:_Record(host)
    if rec.wrapped then return end
    rec.wrapped = true
    local tab = self

    local origAdd = host.AddKeybinds
    if type(origAdd) == "function" then
        host.AddKeybinds = function(hostSelf, ...)
            if tab:_IsQMCurrent(hostSelf) then
                tab:_InstallQMKeybinds(hostSelf)
                return
            end
            return origAdd(hostSelf, ...)
        end
    end

    local origRefresh = host.RefreshKeybinds
    if type(origRefresh) == "function" then
        host.RefreshKeybinds = function(hostSelf, ...)
            if tab:_IsQMCurrent(hostSelf) then
                tab:_InstallQMKeybinds(hostSelf)
                return
            end
            return origRefresh(hostSelf, ...)
        end
    end

    local origUpdate = host.UpdateKeybinds
    if type(origUpdate) == "function" then
        host.UpdateKeybinds = function(hostSelf, ...)
            if tab:_IsQMCurrent(hostSelf) then
                tab:_UpdateQMKeybinds(hostSelf)
                return
            end
            return origUpdate(hostSelf, ...)
        end
    end
end

-- ---------------------------------------------------------------------------
-- Tab activation / deactivation
-- ---------------------------------------------------------------------------
function Tab:_ActivateTab(host)
    local list = self:_EnsureList(host)
    if not list then return end
    self:_WrapHostKeybinds(host)
    self:_SelectHost(host)
    -- Bookkeeping only (drives the scene-hide teardown). NEVER used to gate the
    -- keybind wrappers — those key off GetCurrentList() so native restoration is
    -- not suppressed.
    host._quartermasterTabActive = true

    if host.HideSelector then pcall(function() host:HideSelector() end) end

    -- Clear any native group the previously-current native list left in the
    -- strip, THEN make our list current. SetCurrentList virtual-dispatches the
    -- host's RefreshKeybinds, which the wrapper turns into _InstallQMKeybinds
    -- (never the native re-add) because our list is now current. We never call
    -- native AddKeybinds while our synthetic list is current.
    self:_RemoveNativeGroups(host)
    if host.SetCurrentList then pcall(function() host:SetCurrentList(self.list) end) end

    local rec = self:_Record(host)
    if ZO_GamepadGenericHeader_SetActiveTabIndex and host.header and rec.tabIndex then
        pcall(function() ZO_GamepadGenericHeader_SetActiveTabIndex(host.header, rec.tabIndex) end)
    end

    -- Populate while the list is already current so Commit() runs cleanly and
    -- the A/X visibility predicates see populated target data.
    self:Populate()

    -- Ensure our group is present + current even on a host whose SetCurrentList
    -- doesn't dispatch RefreshKeybinds (older / stripped builds, the harness).
    self:_InstallQMKeybinds(host)
end

-- Leaving our tab. `restoreMain` is retained for call-site compatibility but is
-- intentionally unused: we only strip OUR group. Native groups are restored by
-- the native category/list path (or _RestoreNativeWithdraw) making a native
-- list current, which re-adds them through the wrapper's original branch.
function Tab:_DeactivateTab(host, restoreMain)
    host._quartermasterTabActive = false
    if self._activeHost == host then self._activeHost = nil end
    self:_RemoveQMKeybinds(host)
    -- Our tooltip describes a HOLD, not a bag slot. Leaving it up while the
    -- player is back on a native list would show the wrong item, so clear it
    -- and let the native screen paint its own. BOTH panes: we may also have
    -- painted an equipped-comparison card on the right.
    self:_ClearTooltips()
    -- We intentionally do NOT call host:AddKeybinds()/UpdateKeybinds() here.
    -- Doing so while our synthetic list is still current fired the bank's
    -- UpdateKeybinds against itemActions:SetInventorySlot() with our custom
    -- (non-slot) entry and corrupted the strip — which dropped the native
    -- B/back button on the Withdraw/Deposit tabs.
end

-- Return the native bank to the Withdraw tab + list. Called when the scene
-- hides while our tab is active so the NEXT time the bank opens it starts on
-- the native Withdraw tab instead of a stale Quartermaster selection showing
-- native content (re-entry desync). Making the native list current
-- virtual-dispatches the host's RefreshKeybinds; because our list is no longer
-- current, the wrapper calls the ORIGINAL, restoring the native groups (main +
-- nonListItem + itemActions, or the guild currentKeybindStripDescriptor) and
-- native B.
function Tab:_RestoreNativeWithdraw(host)
    -- Drop our group first so the native re-add doesn't stack under it.
    self:_RemoveQMKeybinds(host)
    if self._activeHost == host then self._activeHost = nil end
    host._quartermasterTabActive = false
    -- Drop our card (both panes) before the native list becomes current, so any
    -- tooltip the native screen paints for its own selection wins.
    self:_ClearTooltips()

    local withdrawMode = (type(BANKING_GAMEPAD_MODE_WITHDRAW) == "number")
        and BANKING_GAMEPAD_MODE_WITHDRAW or 1
    host.mode = withdrawMode
    local mainList = host.withdrawList
        or (host.GetMainListForMode and host:GetMainListForMode())
    if mainList and host.SetCurrentList then
        pcall(function() host:SetCurrentList(mainList) end)
    end
    if ZO_GamepadGenericHeader_SetActiveTabIndex and host.header then
        pcall(function()
            ZO_GamepadGenericHeader_SetActiveTabIndex(host.header, withdrawMode)
        end)
    end
end

-- Build our tab data + append the tab, after the native header is built. Works
-- for BOTH GAMEPAD_BANKING (player bank / house storage) and GAMEPAD_GUILD_BANK.
function Tab:_OnHeaderInitialized(host)
    if not isRecognizedHost(host) then return end
    if type(host.tabsTable) ~= "table" then return end

    -- Guild bank: only surface the tab when the player has at least one relevant
    -- item permission for the accessed guild bank. If the guild id isn't known
    -- yet we still append (the Mover enforces permissions on the actual action).
    if isGuildHost(host) then
        local gid = selectedGuildBankId()
        if gid and gid ~= 0 and not (guildCanWithdraw(gid) or guildCanDeposit(gid)) then
            return
        end
    end

    local list = self:_EnsureList(host)
    if not list then return end
    local rec = self:_Record(host)

    -- Marker table (no numeric `mode` so we never collide with the native
    -- BANKING_GAMEPAD_MODE_* values that gate the native keybinds). Each host
    -- gets its OWN tab data pointing at its OWN list.
    local tabData = { quartermasterTab = true, itemList = list }
    rec.tabData = tabData

    host.tabsTable[#host.tabsTable + 1] = {
        text     = GetString(SI_ACCOUNTHOLD_OPEN_ENTRY),
        callback = function() host:OnCategoryChanged(tabData) end,
    }
    rec.tabIndex = #host.tabsTable

    if ZO_GamepadGenericHeader_Refresh and host.header and host.headerData then
        pcall(function() ZO_GamepadGenericHeader_Refresh(host.header, host.headerData) end)
    end
end

-- ---------------------------------------------------------------------------
-- Hook installation
-- ---------------------------------------------------------------------------
function Tab:_InstallHooks()
    if type(ZO_BankingCommon_Gamepad) ~= "table" then
        -- Banking class not present (keyboard-only client / test harness). The
        -- gamepad bank tab simply doesn't attach; nothing else is affected.
        return
    end

    if not ZO_BankingCommon_Gamepad.__QuartermasterBankTabHooked then
        ZO_BankingCommon_Gamepad.__QuartermasterBankTabHooked = true

        -- Hook 1: append our tab once the native header/tabs are built.
        local originalInitHeader = ZO_BankingCommon_Gamepad.InitializeHeader
        ZO_BankingCommon_Gamepad.InitializeHeader = function(bankSelf, ...)
            local r
            if originalInitHeader then r = originalInitHeader(bankSelf, ...) end
            pcall(function() Tab:_OnHeaderInitialized(bankSelf) end)
            return r
        end

        -- Hook 2: dispatch our tab selection to our list + keybinds. Handles
        -- BOTH the player-bank host and the guild-bank host (both subclass
        -- ZO_BankingCommon_Gamepad, so this single hook covers them).
        local originalOnCategoryChanged = ZO_BankingCommon_Gamepad.OnCategoryChanged
        ZO_BankingCommon_Gamepad.OnCategoryChanged = function(bankSelf, selectedData, ...)
            if isRecognizedHost(bankSelf) and selectedData and selectedData.quartermasterTab then
                local ok, err = pcall(function() Tab:_ActivateTab(bankSelf) end)
                if not ok and addon and addon.Diagnostic then
                    addon:Diagnostic("error", "Quartermaster bank tab activate failed: %s", shortErr(err))
                end
                return
            end
            -- Switching to a native tab while ours was active: restore native
            -- keybinds, THEN let the native handler set up its list.
            if isRecognizedHost(bankSelf) and bankSelf._quartermasterTabActive then
                pcall(function() Tab:_DeactivateTab(bankSelf, true) end)
            end
            if originalOnCategoryChanged then
                return originalOnCategoryChanged(bankSelf, selectedData, ...)
            end
        end
    end

    -- Hook 3: reset when a banking scene hides (leak-safe: scenes fire
    -- reliably). We hook BOTH the player-bank scene and the guild-bank scene so
    -- either host's stale Quartermaster selection is torn down and the native
    -- Withdraw tab restored.
    if not self._sceneHooked then
        self._sceneHooked = true
        local function hookScene(scene, host)
            if type(scene) == "table" and scene.RegisterCallback then
                scene:RegisterCallback("StateChange", function(_, newState)
                    if newState == SCENE_HIDDEN or newState == SCENE_HIDING then
                        pcall(function()
                            if host and host._quartermasterTabActive then
                                Tab:_DeactivateTab(host, false)
                                Tab:_RestoreNativeWithdraw(host)
                            end
                        end)
                    end
                end)
            end
        end
        hookScene(GAMEPAD_BANKING_SCENE, GAMEPAD_BANKING)
        hookScene(GAMEPAD_GUILD_BANK_SCENE, GAMEPAD_GUILD_BANK)
    end
end

-- ---------------------------------------------------------------------------
-- Module entry point
-- ---------------------------------------------------------------------------
function Tab:Initialize(addonRef)
    addon = addonRef
    self.addon = addonRef
    self:_InstallHooks()
end
