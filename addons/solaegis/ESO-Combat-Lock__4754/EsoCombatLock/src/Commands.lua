-- EsoCombatLock - slash commands

local ECL = EsoCombatLock
local Slots = ECL.Slots

local function printHelp()
    ECL.Chat("Commands:")
    ECL.Chat("  /ecl            — status")
    ECL.Chat("  /ecl settings   — open settings (if LibAddonMenu present)")
    ECL.Chat("  /ecl toggle     — toggle combat guard")
    ECL.Chat("  /ecl move       — temporary reposition (show+unlock; ends on combat)")
    ECL.Chat("  /ecl reset      — reset indicator position")
    ECL.Chat("  /ecl resetall   — reset all settings to defaults")
    ECL.Chat("  /ecl debug      — toggle debug logging")
    ECL.Chat("Diagnostics:")
    ECL.Chat("  /ecl probe      — dump quickslot index conventions")
    ECL.Chat("  /ecl testglow   — force combat highlight on/off")
    ECL.Chat("  /ecl halotex [n|reset] — list, switch, or clear halo texture override")
    ECL.Chat("  /ecl testpress  — test quickslot-press alert routing")
end

local function printStatus()
    local state = ECL.Guard.GetState()
    local sub = ECL.GetSubstitute()
    local subLabel = "(none)"
    if sub then
        subLabel = string.format("%s [%s:%s]", tostring(sub.displayName), tostring(sub.actionType), tostring(sub.actionId))
    end
    ECL.Chat(string.format(
        "v%s | guard=%s armed=%s resummon=%s vanityPets=%s",
        ECL.VERSION,
        tostring(ECL.IsGuardEnabled()),
        tostring(state.armed),
        tostring(ECL.IsResummonEnabled()),
        tostring(ECL.IncludeVanityPets())
    ))
    local indicator = ECL.Indicator and ECL.Indicator.GetDebugState and ECL.Indicator.GetDebugState() or {}
    ECL.Chat(string.format(
        "Indicator: alwaysVisible=%s locked=%s reposition=%s hidden=%s show=%s inCombat=%s companion=%s glow=%s glowPulse=%s | pressAlerts=%s pressWatch=%s pressAlertsLive=%s",
        tostring(ECL.IsIndicatorAlwaysVisible()),
        tostring(ECL.IsIndicatorLocked()),
        tostring(indicator.repositionMode),
        tostring(indicator.hidden),
        tostring(indicator.show),
        tostring(indicator.playerInCombat),
        tostring(indicator.hasActiveCompanion),
        tostring(indicator.combatHighlightVisible),
        tostring(indicator.combatHighlightPulsing),
        tostring(ECL.IsPressAlertsEnabled()),
        tostring(ECL.PressWatch and ECL.PressWatch.IsActive and ECL.PressWatch.IsActive()),
        tostring(ECL.PressWatch and ECL.PressWatch.AreAlertsEnabled and ECL.PressWatch.AreAlertsEnabled())
    ))
    ECL.Chat("Substitute: " .. subLabel)
    ECL.Chat(string.format(
        "Quickslot key: %s | preferDetectableNoOp=%s",
        ECL.GetQuickslotKeyLabel(),
        tostring(ECL.PreferDetectableNoOp())
    ))
    ECL.Chat("Current: " .. Slots.DescribeSlot(Slots.GetCurrent()))

    local parkSlot, parkTier = Slots.ResolveTargetWithTier(state.lastSafeSlot)
    ECL.Chat(string.format(
        "Park target: %s (tier=%s)",
        parkSlot and Slots.DescribeSlot(parkSlot) or "none",
        tostring(parkTier)
    ))

    local memento = Slots.FindMementoSlot and Slots.FindMementoSlot()
    if memento then
        ECL.Chat(string.format(
            "Memento no-op candidate: %s (safeNow=%s)",
            Slots.DescribeSlot(memento),
            tostring(Slots.IsNoOpCollectible(memento))
        ))
    else
        ECL.Chat("Memento no-op candidate: none slotted")
    end

    local detectable, reason = Slots.IsPressDetectable(Slots.GetCurrent())
    if detectable then
        ECL.Chat(string.format("Press alerts: current slot IS detectable (%s will announce)", ECL.GetQuickslotKeyLabel()))
    else
        ECL.Chat(string.format("Press alerts: NOT detectable — %s", tostring(reason)))
    end
    if state.armed then
        ECL.Chat(string.format(
            "Armed state: lastSafe=%s preCombat=%s companion=%s",
            tostring(state.lastSafeSlot),
            tostring(state.preCombatSlot),
            tostring(state.companionCollectibleId)
        ))
    end
end

local function runProbe()
    ECL.Chat("=== ECL Probe ===")
    local current = GetCurrentQuickslot()
    ECL.Chat("GetCurrentQuickslot() = " .. tostring(current))
    ECL.Chat("ACTION_BAR_UTILITY_BAR_SIZE = " .. tostring(ACTION_BAR_UTILITY_BAR_SIZE))
    ECL.Chat("ACTION_BAR_FIRST_UTILITY_BAR_SLOT = " .. tostring(ACTION_BAR_FIRST_UTILITY_BAR_SLOT))
    ECL.Chat(string.format(
        "Quickslot key (%s): %s",
        ECL.QUICKSLOT_BINDING_ACTION,
        ECL.GetQuickslotKeyLabel()
    ))

    ECL.Chat("-- Wheel indices 1 .. SIZE with HOTBAR_CATEGORY_QUICKSLOT_WHEEL --")
    local size = ACTION_BAR_UTILITY_BAR_SIZE or 8
    for i = 1, size do
        local slotType = GetSlotType(i, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
        local boundId = GetSlotBoundId(i, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
        local name = GetSlotName(i, HOTBAR_CATEGORY_QUICKSLOT_WHEEL) or ""
        local mark = (i == current) and " <== CURRENT" or ""
        ECL.Chat(string.format(
            "  [%d] type=%s id=%s name=%q%s",
            i,
            tostring(slotType),
            tostring(boundId),
            name,
            mark
        ))
    end

    if ACTION_BAR_FIRST_UTILITY_BAR_SLOT then
        ECL.Chat("-- Legacy physical indices FIRST+1 .. FIRST+SIZE (no hotbar arg) --")
        local first = ACTION_BAR_FIRST_UTILITY_BAR_SLOT
        for i = first + 1, first + size do
            local slotType = GetSlotType(i)
            local boundId = GetSlotBoundId(i)
            local name = GetSlotName(i) or ""
            ECL.Chat(string.format(
                "  [%d] type=%s id=%s name=%q",
                i,
                tostring(slotType),
                tostring(boundId),
                name
            ))
        end
    else
        ECL.Chat("ACTION_BAR_FIRST_UTILITY_BAR_SLOT is nil — modern wheel indices only.")
    end

    -- Empty-slot selectability probe (non-destructive: restore afterwards).
    local empty = Slots.FindEmptySlot()
    if empty then
        ECL.Chat("Empty slot found at " .. tostring(empty) .. " — testing SetCurrentQuickslot...")
        local before = GetCurrentQuickslot()
        SetCurrentQuickslot(empty)
        local after = GetCurrentQuickslot()
        local ok = (after == empty)
        ECL.Chat(string.format(
            "  SetCurrentQuickslot(%d) -> GetCurrentQuickslot()=%s  selectable=%s",
            empty,
            tostring(after),
            tostring(ok)
        ))
        SetCurrentQuickslot(before)
        if ECL.db then
            ECL.db.emptySlotsSelectable = ok
        end
        if ok then
            ECL.Chat("Empty slots ARE selectable — no-op fallback enabled.")
        else
            ECL.Chat("Empty slots are NOT selectable — no-op fallback disabled.")
        end
    else
        ECL.Chat("No empty quickslot available to test no-op selectability.")
    end

    local memento = Slots.FindMementoSlot and Slots.FindMementoSlot()
    if memento then
        ECL.Chat("Memento no-op candidate: " .. Slots.DescribeSlot(memento))
        local usable = false
        local id = Slots.GetBoundId(memento)
        if id and IsCollectibleUsable then
            usable = IsCollectibleUsable(id, GAMEPLAY_ACTOR_CATEGORY_PLAYER) == true
        end
        ECL.Chat(string.format(
            "  IsMemento=%s IsNoOpCollectible=%s IsCollectibleUsable=%s IsPressDetectable=%s",
            tostring(Slots.IsMementoSlot(memento)),
            tostring(Slots.IsNoOpCollectible(memento)),
            tostring(usable),
            tostring(select(1, Slots.IsPressDetectable(memento)))
        ))
    else
        ECL.Chat("Memento no-op candidate: none slotted (park will use empty slot if available)")
    end

    local collectibleId, defId = Slots.GetActiveCompanionCollectibleId()
    local hasRiskyActive = Slots.HasActiveRiskyCollectible and Slots.HasActiveRiskyCollectible()
    ECL.Chat(string.format(
        "Active companion: has=%s defId=%s collectibleId=%s activeRiskyCollectible=%s",
        tostring(HasActiveCompanion and HasActiveCompanion()),
        tostring(defId),
        tostring(collectibleId),
        tostring(hasRiskyActive)
    ))

    local parkSlot, parkTier = Slots.FindParkTarget and Slots.FindParkTarget() or nil, "n/a"
    ECL.Chat(string.format(
        "Park cascade: %s (tier=%s)",
        parkSlot and Slots.DescribeSlot(parkSlot) or "none",
        tostring(parkTier)
    ))
    ECL.Chat("Pinned convention: wheel indices 1.." .. tostring(size) .. " + HOTBAR_CATEGORY_QUICKSLOT_WHEEL")
    ECL.Chat("=== End Probe ===")
end

local function handleCommand(args)
    args = args and zo_strformat("<<1>>", args) or ""
    args = string.lower(string.gsub(args, "^%s*(.-)%s*$", "%1"))

    if args == "" or args == "status" then
        printStatus()
    elseif args == "help" then
        printHelp()
    elseif args == "probe" then
        runProbe()
    elseif args == "settings" or args == "config" then
        if ECL.OpenSettings then
            ECL.OpenSettings()
        else
            ECL.Chat("Settings panel unavailable (LibAddonMenu-2.0 not loaded?)")
        end
    elseif args == "toggle" then
        if ECL.db then
            ECL.db.guardEnabled = not ECL.IsGuardEnabled()
            ECL.Chat("Guard " .. (ECL.IsGuardEnabled() and "enabled" or "disabled"))
        end
    elseif args == "move" then
        if ECL.Indicator and ECL.Indicator.TogglePositionLock then
            ECL.Indicator.TogglePositionLock()
        end
    elseif args == "testglow" then
        if ECL.Indicator and ECL.Indicator.ToggleForcedCombatHighlight then
            local on = ECL.Indicator.ToggleForcedCombatHighlight()
            ECL.Chat("Forced combat highlight " .. (on and "ON" or "OFF"))
            if on and ECL.db and ECL.db.haloEnabled == false then
                ECL.Chat("  (Combat halo setting is off — testglow bypasses it)")
            end
            local state = ECL.Indicator.GetDebugState and ECL.Indicator.GetDebugState() or {}
            ECL.Chat(string.format(
                "  show=%s hidden=%s highlight=%s pulsing=%s",
                tostring(state.show),
                tostring(state.hidden),
                tostring(state.combatHighlightVisible),
                tostring(state.combatHighlightPulsing)
            ))
            for _, line in ipairs(ECL.Indicator.DescribeHighlightControls()) do
                ECL.Chat("  " .. line)
            end
        end
    elseif args == "halotex" or string.find(args, "^halotex%s") then
        local reset = string.match(args, "^halotex%s+reset$")
        if reset and ECL.Indicator and ECL.Indicator.ClearHaloTextureOverride then
            if ECL.Indicator.ClearHaloTextureOverride() then
                ECL.Chat("Halo texture override cleared")
            else
                ECL.Chat("No halo texture override to clear")
            end
        else
            local choice = tonumber(string.match(args, "^halotex%s+(%d+)$"))
            if choice and ECL.Indicator and ECL.Indicator.SetHaloTextureIndex then
                local path = ECL.Indicator.SetHaloTextureIndex(choice)
                ECL.Chat(path and ("Halo texture -> " .. path) or ("No halo texture " .. choice))
            end
        end
        if ECL.Indicator and ECL.Indicator.DescribeHaloTextures then
            for _, line in ipairs(ECL.Indicator.DescribeHaloTextures()) do
                ECL.Chat("  " .. line)
            end
        end
    elseif args == "testpress" then
        if not ECL.IsPressAlertsEnabled() then
            ECL.Chat("Press alerts are disabled — enable Alert on quickslot activity in combat in settings")
        elseif ECL.PressWatch and ECL.PressWatch.IsActive and ECL.PressWatch.IsActive() then
            ECL.Announce(ECL.FormatQuickslotUsed("test potion"))
        else
            ECL.Chat(string.format(
                "%s-press alert test (guard not armed — enter combat with companion for live detection)",
                ECL.GetQuickslotKeyLabel()
            ))
        end
    elseif args == "reset" then
        if ECL.Indicator and ECL.Indicator.ResetPosition then
            ECL.Indicator.ResetPosition()
        end
    elseif args == "resetall" then
        ECL.ResetSettings()
        if ECL.Indicator and ECL.Indicator.Initialize then
            ECL.Indicator.Initialize()
        end
        ECL.Chat("All settings reset to defaults (open settings to refresh the panel)")
    elseif args == "debug" then
        if ECL.db then
            ECL.db.debug = not ECL.db.debug
            ECL.Chat("Debug " .. (ECL.db.debug and "ON" or "OFF"))
        end
    else
        ECL.Chat("Unknown command. Try /ecl help")
    end
end

function ECL.RegisterCommands()
    SLASH_COMMANDS["/ecl"] = handleCommand
    SLASH_COMMANDS["/eclprobe"] = function()
        runProbe()
    end
    SLASH_COMMANDS["/esocombatlock"] = handleCommand
end
