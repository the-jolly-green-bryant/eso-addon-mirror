-- EsoCombatLock - quickslot keybinding lookup

local ECL = EsoCombatLock

-- Vanilla quickslot use action (see ingame/actionbar/actionbutton.lua).
ECL.QUICKSLOT_BINDING_ACTION = "ACTION_BUTTON_9"
ECL.QUICKSLOT_KEY_FALLBACK = "Q"

local cachedQuickslotKey = nil

local function lookupQuickslotKey()
    if ZO_Keybindings_GetBindingStringFromAction then
        local textOptions = KEYBIND_TEXT_OPTIONS_FULL_NAME or 0
        local textureOptions = KEYBIND_TEXTURE_OPTIONS_HIDE or 0
        local label = ZO_Keybindings_GetBindingStringFromAction(
            ECL.QUICKSLOT_BINDING_ACTION,
            textOptions,
            textureOptions
        )
        if label and label ~= "" then
            return label
        end
    end
    return ECL.QUICKSLOT_KEY_FALLBACK
end

function ECL.GetQuickslotKeyLabel()
    if cachedQuickslotKey == nil then
        cachedQuickslotKey = lookupQuickslotKey()
    end
    return cachedQuickslotKey
end

function ECL.RefreshQuickslotKeyLabel()
    cachedQuickslotKey = lookupQuickslotKey()
end

function ECL.FormatQuickslotUsed(resourceName)
    return string.format("%s used %s — companion protected", ECL.GetQuickslotKeyLabel(), tostring(resourceName))
end

function ECL.FormatQuickslotBlocked(resourceName)
    return string.format("%s pressed — %s blocked", ECL.GetQuickslotKeyLabel(), tostring(resourceName))
end

function ECL.FormatQuickslotNoOp(resourceName)
    return string.format(
        "%s pressed — companion protected (nothing used)",
        ECL.GetQuickslotKeyLabel()
    )
end

function ECL.FormatGuardParkedEmpty()
    return string.format("Companion protected — %s parked on an empty slot", ECL.GetQuickslotKeyLabel())
end

function ECL.FormatGuardParkedNoOp(resourceName)
    return string.format(
        "Companion protected — %s parked on %s (no-op)",
        ECL.GetQuickslotKeyLabel(),
        tostring(resourceName)
    )
end

function ECL.FormatGuardParkedOn(resourceName)
    return string.format(
        "Companion protected — %s now uses %s",
        ECL.GetQuickslotKeyLabel(),
        tostring(resourceName)
    )
end

function ECL.RegisterQuickslotKeyListeners()
    local function onKeybindingChanged()
        ECL.RefreshQuickslotKeyLabel()
    end

    EVENT_MANAGER:RegisterForEvent(ECL.NAME, EVENT_KEYBINDING_SET, onKeybindingChanged)
    EVENT_MANAGER:RegisterForEvent(ECL.NAME, EVENT_KEYBINDING_CLEARED, onKeybindingChanged)
end
