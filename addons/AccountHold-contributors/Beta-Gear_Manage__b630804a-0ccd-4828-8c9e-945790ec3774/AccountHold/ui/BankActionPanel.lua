-- Quartermaster/ui/BankActionPanel.lua
-- The little panel that appears when the player opens any container that has
-- pending Quartermaster work. Wires the keystrip descriptor from src/Input.lua
-- and dispatches to Mover/Notify.

AccountHold = AccountHold or {}
AccountHold.UI = AccountHold.UI or {}
AccountHold.UI.BankActionPanel = AccountHold.UI.BankActionPanel or {}

local Panel = AccountHold.UI.BankActionPanel
local addon

function Panel:Initialize(addonRef)
    addon = addonRef
    self.control      = AccountHold_BankPanel
    self.role         = nil      -- "holder" | "requester"
    self.holds        = {}
    self.containerKey = nil

    if self.control then
        self.titleLabel = self.control:GetNamedChild("Title")
        self.bodyLabel  = self.control:GetNamedChild("Body")
        self.listCtrl   = self.control:GetNamedChild("List")
        self.control:SetHidden(true)

        -- P2 #14: build a single-row data type that paints the item link
        -- and an inline Confirm button. We runtime-create the row template
        -- so no extra XML is required and the row layout stays in one
        -- file with the data-binding code.
        self:_BuildList()
    end

    self.keystrip = addon.Input:BuildBankPanelKeystrip(self)

    self:_InstallReservedTooltipHooks()
end

-- Bug 8: annotate the native item tooltip with a "Reserved" line whenever the
-- inspected item matches an active hold, so the player can SEE which items are
-- reserved (at the bank and everywhere else).
--
-- IMPORTANT — do NOT hook GAMEPAD_TOOLTIPS:LayoutBagItem directly. GAMEPAD_TOOLTIPS
-- (a ZO_GamepadTooltip) dispatches layout calls through a metatable __index that
-- sets self.currentLayoutFunctionName before returning a generic LayoutFunction.
-- ZO_PostHook does a RAW table write, which permanently shadows that __index for
-- "LayoutBagItem": currentLayoutFunctionName is then never refreshed, so every
-- later call dispatches to the WRONG ZO_Tooltip method, produces no controls, and
-- the framework hides the fragment — breaking EVERY gamepad item tooltip in the
-- game (reserved or not). The pcall can't help; the damage happens in the
-- original call, before our hook body runs.
--
-- SAFE approach (verified against esoui source): hook the underlying class method
-- ZO_Tooltip.LayoutBagItem. LayoutFunction resolves the real layout function from
-- ZO_Tooltip and calls it as tooltipFunction(tooltip, bagId, slotIndex) AFTER
-- ClearLines() and BEFORE the HasControls()/fragment decision — so our appended
-- section is counted and the tooltip is shown correctly. Every call is guarded so
-- a missing API on any client build simply skips the annotation.
function Panel:_InstallReservedTooltipHooks()
    if not ZO_PostHook then return end
    -- Idempotency guard: these are GLOBAL tooltip hooks (they run for every item
    -- tooltip everywhere in the game). Installing them twice would double the
    -- per-tooltip cost and print duplicate "Reserved" lines.
    if self._reservedTooltipHooksInstalled then return end
    self._reservedTooltipHooksInstalled = true

    local function reservedLine(itemLink)
        local hold = addon.Holds:FindActiveHoldByItemLink(itemLink)
        if not hold then return nil end
        local who = addon.Holds:HolderName(hold)
        if who and who ~= "" then
            return string.format(GetString(SI_ACCOUNTHOLD_TOOLTIP_RESERVED_FOR), who)
        end
        return GetString(SI_ACCOUNTHOLD_TOOLTIP_RESERVED)
    end

    -- Keyboard tooltip: ItemTooltip is a plain control whose SetBagItem is a real
    -- method (no metatable dispatch), so a direct post-hook is safe here.
    if ItemTooltip and ItemTooltip.SetBagItem then
        ZO_PostHook(ItemTooltip, "SetBagItem", function(control, bagId, slotIndex)
            pcall(function()
                local link = GetItemLink and GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT)
                local text = link and reservedLine(link)
                if text and control.AddVerticalPadding and control.AddLine then
                    control:AddVerticalPadding(6)
                    control:AddLine(text, "", 1.0, 0.84, 0.0)
                end
            end)
        end)
    end

    -- Gamepad tooltip: hook the ZO_Tooltip CLASS method (NOT the GAMEPAD_TOOLTIPS
    -- singleton). `self` is the real ZO_Tooltip instance; the section is appended
    -- inside the dispatcher before the fragment show/hide decision.
    if ZO_Tooltip and ZO_Tooltip.LayoutBagItem then
        ZO_PostHook(ZO_Tooltip, "LayoutBagItem", function(self, bagId, slotIndex)
            pcall(function()
                local link = GetItemLink and GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT)
                local text = link and reservedLine(link)
                if not text then return end
                if not (self.AcquireSection and self.AddSection and self.GetStyle) then return end
                local section = self:AcquireSection(self:GetStyle("bodySection"))
                section:AddLine(text, self:GetStyle("bodyDescription"))
                self:AddSection(section)
            end)
        end)
    end
end

local DATA_TYPE_HOLD = 1
local ROW_HEIGHT     = 36

function Panel:_BuildList()
    if not (self.listCtrl and ZO_ScrollList_AddDataType
            and WINDOW_MANAGER and WINDOW_MANAGER.CreateControl) then
        return
    end

    -- Lazily create one row template under the panel control so virtual
    -- inheritance can reference it. Each list slot will inherit from this
    -- template by name when ZO_ScrollList stamps row controls.
    if not _G["AccountHold_BankPanelRowTemplate"] then
        local ctType = CT_CONTROL
        if not ctType then return end          -- very old build; skip the list
        local tmpl = WINDOW_MANAGER:CreateControl(
            "AccountHold_BankPanelRowTemplate", self.control, ctType)
        if tmpl then
            tmpl:SetHidden(true)
            tmpl:SetDimensions(480, ROW_HEIGHT)
        end
    end

    ZO_ScrollList_AddDataType(self.listCtrl, DATA_TYPE_HOLD,
        "AccountHold_BankPanelRowTemplate", ROW_HEIGHT,
        function(rowControl, data) self:_SetupRow(rowControl, data) end)

    if ZO_ScrollList_EnableHighlight then
        ZO_ScrollList_EnableHighlight(self.listCtrl, "ZO_ThinListHighlight")
    end
end

-- Materialise the link label + Confirm button on a row control. ESO
-- creates the row from the named virtual template above and then calls
-- this setup function for each visible row, so we have to be defensive
-- about the children already existing from a prior recycle.
function Panel:_SetupRow(rowControl, data)
    if not rowControl then return end
    rowControl.dataEntry = data

    local link = rowControl:GetNamedChild("Link")
    if not link and WINDOW_MANAGER and WINDOW_MANAGER.CreateControlFromVirtual then
        link = WINDOW_MANAGER:CreateControlFromVirtual(
            rowControl:GetName() .. "Link", rowControl, "ZO_SelectableLabel")
        if link then
            link:SetAnchor(LEFT,  rowControl, LEFT,  4, 0)
            link:SetAnchor(RIGHT, rowControl, RIGHT, -110, 0)
            link:SetMouseEnabled(true)
        end
    end
    if link and link.SetText then
        local hold = data.hold or {}
        local label = string.format("%s  x%d",
            hold.itemLink or "?", hold.desiredCount or 1)
        link:SetText(label)
        link:SetHandler("OnMouseEnter", function()
            if hold.itemLink and ItemTooltip and InitializeTooltip then
                InitializeTooltip(ItemTooltip, link, RIGHT, -10, 0)
                ItemTooltip:SetLink(hold.itemLink)
            end
        end)
        link:SetHandler("OnMouseExit", function()
            if ClearTooltip and ItemTooltip then ClearTooltip(ItemTooltip) end
        end)
    end

    local btn = rowControl:GetNamedChild("Confirm")
    if not btn and WINDOW_MANAGER and WINDOW_MANAGER.CreateControlFromVirtual then
        btn = WINDOW_MANAGER:CreateControlFromVirtual(
            rowControl:GetName() .. "Confirm", rowControl, "ZO_DefaultButton")
        if btn then
            btn:SetDimensions(100, 26)
            btn:SetAnchor(RIGHT, rowControl, RIGHT, -4, 0)
        end
    end
    if btn then
        btn:SetText(GetString(SI_ACCOUNTHOLD_PANEL_CONFIRM_ROW))
        btn:SetHandler("OnClicked", function()
            self:ConfirmRow(data.hold)
        end)
    end
end

-- Inline per-row Confirm dispatch. Mirrors OpenReview's path but skips
-- the ZO_Dialogs round-trip — clicking the button issues exactly one
-- Mover call for that single hold.
function Panel:ConfirmRow(hold)
    if not (hold and self.containerKey and self.role) then return end
    if self.role == "holder" then
        addon.Mover:DepositForHolds(self.containerKey, { hold })
    elseif self.role == "requester" then
        addon.Mover:WithdrawForHolds(self.containerKey, { hold })
    end
    -- Optimistically drop the row from the displayed list so the user
    -- gets feedback while the in-flight tracker confirms the move.
    for i = #self.holds, 1, -1 do
        if self.holds[i] == hold then table.remove(self.holds, i) end
    end
    self:_PopulateList()
    if #self.holds == 0 then self:Close() end
end

function Panel:_PopulateList()
    if not (self.listCtrl and ZO_ScrollList_GetDataList
            and ZO_ScrollList_CreateDataEntry and ZO_ScrollList_Commit) then
        return
    end
    local data = ZO_ScrollList_GetDataList(self.listCtrl)
    if ZO_ClearNumericallyIndexedTable then
        ZO_ClearNumericallyIndexedTable(data)
    end
    for _, hold in ipairs(self.holds or {}) do
        data[#data + 1] = ZO_ScrollList_CreateDataEntry(DATA_TYPE_HOLD,
            { hold = hold })
    end
    ZO_ScrollList_Commit(self.listCtrl)
end

-- ---------------------------------------------------------------------------
-- Open / close on container events
-- ---------------------------------------------------------------------------

function Panel:OnContainerOpened(bagId)
    self.containerKey = addon.Mover:ContainerKeyForOpenedBag(bagId)
    if not self.containerKey then return end

    -- P1 #8: independent silencing of the on-screen action panel. The
    -- chat/CSA banner is gated separately by Notify via autoPromptAt*.
    if not self:_panelEnabledFor(self.containerKey) then
        return
    end

    -- Refresh candidate snapshots before deciding whether to show.
    addon.Holds:RefreshAllCandidates()

    -- As requester first: prefer "you have items waiting".
    local reqHolds = addon.Holds:GetHoldsAtContainer(self.containerKey, "requester")
    if #reqHolds > 0 then
        if addon.Diagnostic then
            addon:Diagnostic("info",
                "BankActionPanel: %d requester hold(s) at %s.",
                #reqHolds, tostring(self.containerKey))
        end
        self:_show("requester", reqHolds)
        -- Notify gates itself on the per-container-family prompt toggle.
        addon.Notify:OnRequesterAtContainer(self.containerKey, #reqHolds)
        return
    end

    -- Then as holder.
    local holderHolds = addon.Holds:GetHoldsAtContainer(self.containerKey, "holder")
    if #holderHolds > 0 then
        if addon.Diagnostic then
            addon:Diagnostic("info",
                "BankActionPanel: %d holder hold(s) at %s.",
                #holderHolds, tostring(self.containerKey))
        end
        self:_show("holder", holderHolds)
        addon.Notify:OnHolderAtContainer(self.containerKey, #holderHolds)
    end
end

function Panel:_panelEnabledFor(containerKey)
    local s = addon.sv and addon.sv.settings
    if not s then return true end
    if containerKey == "bank" then
        return s.showActionPanelAtBank ~= false
    elseif type(containerKey) == "string" and containerKey:sub(1, 10) == "guildbank:" then
        return s.showActionPanelAtGuildBank ~= false
    elseif type(containerKey) == "string" and containerKey:sub(1, 6) == "house:" then
        return s.showActionPanelAtHouseStorage ~= false
    end
    return true
end

function Panel:OnContainerClosed()
    self:Close()
end

-- ---------------------------------------------------------------------------
-- Show / close
-- ---------------------------------------------------------------------------

function Panel:_show(role, holds)
    self.role  = role
    self.holds = holds or {}
    -- On gamepad / Xbox the keyboard XML overlay (anchored absolutely to
    -- the screen and laid out in keyboard pixel coordinates) collides with
    -- the gamepad bank scene. Skip the overlay entirely on gamepad and use
    -- the per-row review dialog flow instead — that dialog is registered
    -- with `gamepadInfo` so it integrates cleanly with the gamepad UI.
    -- The keystrip is still useful on PC where the overlay paints normally.
    if IsInGamepadPreferredMode and IsInGamepadPreferredMode() then
        -- The gamepad bank now has a dedicated Quartermaster tab
        -- (ui/BankTab_Gamepad.lua) that lists and approves reserved moves.
        -- Do NOT open the old per-row review dialog here: it would pop over the
        -- bank scene and could advance hold states before the player has seen
        -- them on the tab. The chat/CSA banner (fired by Notify right after this
        -- returns) still announces that items are waiting.
        if addon.Diagnostic then
            addon:Diagnostic("info",
                "Gamepad mode: %d %s hold(s) available on the Quartermaster bank tab.",
                #self.holds, tostring(role))
        end
        return
    end
    if self.titleLabel then self.titleLabel:SetText(GetString(SI_ACCOUNTHOLD_HEADER_BANK_PANEL)) end
    if self.bodyLabel then
        local fmt = (role == "holder")
            and GetString(SI_ACCOUNTHOLD_NOTIFY_HOLDER_AT_BANK)
            or  GetString(SI_ACCOUNTHOLD_NOTIFY_REQ_AT_BANK)
        self.bodyLabel:SetText(string.format(fmt, #self.holds))
    end
    -- P2 #14: paint the per-hold rows.
    self:_PopulateList()
    if self.control then self.control:SetHidden(false) end
    addon.Input:PushKeybinds(self.keystrip)
end

function Panel:Close()
    addon.Input:PopKeybinds(self.keystrip)
    self.role         = nil
    self.holds        = {}
    self.containerKey = nil
    if self.control then self.control:SetHidden(true) end
end

-- ---------------------------------------------------------------------------
-- Keystrip callbacks
-- ---------------------------------------------------------------------------

function Panel:DepositAll()
    if self.role ~= "holder" or not self.containerKey then return end
    if addon.sv.settings.confirmEachMove then
        self:OpenReview()
        return
    end
    local n = addon.Mover:DepositForHolds(self.containerKey, self.holds)
    addon:Debug("DepositAll queued %d item(s)", n)
    self:Close()
end

function Panel:WithdrawAll()
    if self.role ~= "requester" or not self.containerKey then return end
    if addon.sv.settings.confirmEachMove then
        self:OpenReview()
        return
    end
    local n = addon.Mover:WithdrawForHolds(self.containerKey, self.holds)
    addon:Debug("WithdrawAll queued %d item(s)", n)
    self:Close()
end

function Panel:OpenReview()
    -- Per-item review: dispatch each hold through ZO_Dialogs one at a time.
    -- The gamepad dialog system queues them (canQueue = true); the "Approve
    -- all" button releases the rest at once (bug 9). Each dialog carries the
    -- FULL remaining hold list so Approve-all can process every reserved item.
    --
    -- ACCOUNT_HOLD_REVIEW is a PARAMETRIC gamepad dialog (registered with
    -- gamepadInfo and a 3rd DIALOG_TERTIARY button). It MUST be shown via
    -- ZO_Dialogs_ShowPlatformDialog / ShowGamepadDialog. ZO_Dialogs_ShowDialog
    -- is the KEYBOARD path (isGamepad = nil): on console it lays 3 buttons onto
    -- the 2-button keyboard template, GetButtonControl returns nil, and it
    -- crashes in zo_dialog.lua:556 -- the recurring "2007bc7c" error that left
    -- the action panel empty. ShowPlatformDialog auto-selects gamepad on
    -- console and keyboard on PC.
    local show = ZO_Dialogs_ShowPlatformDialog
                 or ZO_Dialogs_ShowGamepadDialog
                 or ZO_Dialogs_ShowDialog
    if not show then return end
    self._lastContainerKey = self.containerKey
    self._lastRole         = self.role
    local role         = self.role
    local containerKey = self.containerKey
    local allHolds     = {}
    for _, h in ipairs(self.holds) do allHolds[#allHolds + 1] = h end
    for _, hold in ipairs(allHolds) do
        show("ACCOUNT_HOLD_REVIEW", {
            hold         = hold,
            role         = role,
            containerKey = containerKey,
            allHolds     = allHolds,
        })
    end
    self:Close()
end

-- Re-open the review dialog for the container the player most recently had
-- Quartermaster work at (feature F4). Also usable via the /qmreview command.
function Panel:Reopen()
    local ck = self.containerKey or self._lastContainerKey
    if not ck then
        if addon.Notify then addon.Notify:Alert(GetString(SI_ACCOUNTHOLD_ALERT_RETRY_NONE)) end
        return
    end
    addon.Holds:RefreshAllCandidates()
    local reqHolds = addon.Holds:GetHoldsAtContainer(ck, "requester")
    if #reqHolds > 0 then self:_show("requester", reqHolds); return end
    local holderHolds = addon.Holds:GetHoldsAtContainer(ck, "holder")
    if #holderHolds > 0 then self:_show("holder", holderHolds); return end
    if addon.Notify then addon.Notify:Alert(GetString(SI_ACCOUNTHOLD_ALERT_RETRY_NONE)) end
end

-- ---------------------------------------------------------------------------
-- Per-row review dialog (registered once)
-- ---------------------------------------------------------------------------

if ZO_Dialogs_RegisterCustomDialog then
    ZO_Dialogs_RegisterCustomDialog("ACCOUNT_HOLD_REVIEW", {
        canQueue    = true,
        gamepadInfo = { dialogType = GAMEPAD_DIALOGS and GAMEPAD_DIALOGS.BASIC or 1 },
        title       = { text = GetString(SI_ACCOUNTHOLD_HEADER_BANK_PANEL) },
        mainText    = {
            text = function(dialog)
                local d = dialog.data or {}
                local hold = d.hold or {}
                return string.format("%s x%d", hold.itemLink or "?", hold.desiredCount or 1)
            end,
        },
        buttons = {
            {
                text     = GetString(SI_ACCOUNTHOLD_PANEL_CONFIRM_ROW),
                keybind  = "DIALOG_PRIMARY",
                callback = function(dialog)
                    local d = dialog.data or {}
                    if not addon then return end
                    if d.role == "holder" then
                        addon.Mover:DepositForHolds(d.containerKey, { d.hold })
                    elseif d.role == "requester" then
                        addon.Mover:WithdrawForHolds(d.containerKey, { d.hold })
                    end
                end,
            },
            {
                -- Bug 9: approve every remaining reserved item in one action
                -- and release the rest of the queued per-item dialogs.
                text     = GetString(SI_ACCOUNTHOLD_PANEL_CONFIRM_ALL),
                keybind  = "DIALOG_TERTIARY",
                visible  = function(dialog)
                    local d = dialog.data or {}
                    return d.allHolds and #d.allHolds > 1
                end,
                callback = function(dialog)
                    local d = dialog.data or {}
                    if not addon then return end
                    local holds = d.allHolds or { d.hold }
                    if d.role == "holder" then
                        addon.Mover:DepositForHolds(d.containerKey, holds)
                    elseif d.role == "requester" then
                        addon.Mover:WithdrawForHolds(d.containerKey, holds)
                    end
                    if ZO_Dialogs_ReleaseAllDialogsOfName then
                        ZO_Dialogs_ReleaseAllDialogsOfName("ACCOUNT_HOLD_REVIEW")
                    end
                end,
            },
            {
                text    = GetString(SI_ACCOUNTHOLD_PANEL_SKIP_ROW),
                keybind = "DIALOG_NEGATIVE",
            },
        },
    })
end
