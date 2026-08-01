-- Outfit Switcher
-- Lets the player swap active outfit slots via /outfit <number>.
--
-- Verified API (ESOUI wiki / U17 API patch notes / esoui source repo/github):
--   GetNumUnlockedOutfits()                                     -> integer numUnlocked
--   EquipOutfit(GameplayActorCategory actorCategory, luaindex outfitIndex)
--   GAMEPLAY_ACTOR_CATEGORY_PLAYER  (global constant)
--   ZO_Alert(category, soundId, message, ...)                   -> auto-routes to the
--       gamepad or keyboard alert UI depending on which mode is currently active
--       (ZO_AlertText_Gamepad / ZO_AlertText_Keyboard), so this is the correct,
--       verified way to surface feedback in both modes without separate code paths.
--   UI_ALERT_CATEGORY_ERROR, UI_ALERT_CATEGORY_ALERT            (alert category enums)
--   SOUNDS.NEGATIVE_CLICK, SOUNDS.POSITIVE_CLICK                (SOUNDS table entries)
--   EVENT_OUTFIT_EQUIP_RESPONSE (eventCode, EquipOutfitResult response) -> confirms
--       (or rejects) the last EquipOutfit call. The event does not report which
--       outfit index it was for, so the addon tracks that itself.
--   EquipOutfitResult enum: EQUIP_OUTFIT_RESULT_SUCCESS,
--       EQUIP_OUTFIT_RESULT_OUTFIT_ALREADY_EQUIPPED, EQUIP_OUTFIT_RESULT_OUTFIT_INVALID,
--       EQUIP_OUTFIT_RESULT_OUTFIT_LOCKED, EQUIP_OUTFIT_RESULT_OUTFIT_SWITCHING_UNAVAILABLE

local ADDON_NAME = "OutfitSwitcher"

-- Set right before calling EquipOutfit and read back in the
-- EVENT_OUTFIT_EQUIP_RESPONSE handler, since that event doesn't include the
-- outfit index itself.
local pendingOutfitIndex = nil

-- Only accept a plain (optionally signed) integer: no decimals, hex, exponents,
-- "inf"/"nan", or stray characters. Leading/trailing whitespace is trimmed first.
local function ParseOutfitIndex(rawArgs)
    local trimmed = zo_strtrim(rawArgs)

    if trimmed == "" then
        return nil, "empty"
    end

    if not trimmed:match("^[+%-]?%d+$") then
        return nil, "not_a_number"
    end

    local index = tonumber(trimmed)

    if index <= 0 then
        return nil, "not_positive"
    end

    return index
end

-- Prints to chat (so it's in the log) and raises a gamepad/keyboard-aware
-- on-screen alert (so it's visible even if the chat window isn't open, which
-- is common in gamepad play).
local function Notify(category, soundId, colorHex, message)
    d(string.format("|c%s%s|r", colorHex, message))
    ZO_Alert(category, soundId, message)
end

local function OnOutfitCommand(rawArgs)
    local index, errorReason = ParseOutfitIndex(rawArgs)

    if index == nil then
        if errorReason == "not_a_number" then
            Notify(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, "FF0000",
                string.format("Outfit Switcher: '%s' isn't a valid slot number.", rawArgs))
        elseif errorReason == "not_positive" then
            Notify(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, "FF0000",
                "Outfit Switcher: Slot number must be 1 or higher.")
        else
            Notify(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK, "FFFF00",
                "Outfit Switcher usage: /outfit <number>")
        end
        return
    end

    local numUnlocked = GetNumUnlockedOutfits()

    if index > numUnlocked then
        Notify(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, "FF0000",
            string.format("Outfit Switcher: You only have %d outfit slot(s) unlocked.", numUnlocked))
        return
    end

    pendingOutfitIndex = index
    EquipOutfit(GAMEPLAY_ACTOR_CATEGORY_PLAYER, index)
    -- No message here: OnOutfitEquipResponse reports the confirmed result once
    -- EVENT_OUTFIT_EQUIP_RESPONSE fires.
end

local function OnOutfitEquipResponse(eventCode, response)
    local index = pendingOutfitIndex
    pendingOutfitIndex = nil

    local slotText = index and string.format(" (slot %d)", index) or ""

    if response == EQUIP_OUTFIT_RESULT_SUCCESS then
        Notify(UI_ALERT_CATEGORY_ALERT, SOUNDS.POSITIVE_CLICK, "00FF00",
            string.format("Outfit Switcher: Outfit switched%s.", slotText))
    elseif response == EQUIP_OUTFIT_RESULT_OUTFIT_ALREADY_EQUIPPED then
        Notify(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK, "FFFF00",
            string.format("Outfit Switcher: That outfit is already equipped%s.", slotText))
    elseif response == EQUIP_OUTFIT_RESULT_OUTFIT_INVALID then
        Notify(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, "FF0000",
            string.format("Outfit Switcher: That outfit slot isn't valid%s.", slotText))
    elseif response == EQUIP_OUTFIT_RESULT_OUTFIT_LOCKED then
        Notify(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, "FF0000",
            string.format("Outfit Switcher: That outfit slot is locked%s.", slotText))
    elseif response == EQUIP_OUTFIT_RESULT_OUTFIT_SWITCHING_UNAVAILABLE then
        Notify(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, "FF0000",
            "Outfit Switcher: Outfit switching isn't available right now.")
    else
        Notify(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, "FF0000",
            string.format("Outfit Switcher: Outfit switch failed%s.", slotText))
    end
end

local function Initialize(eventCode, addOnName)
    if addOnName ~= ADDON_NAME then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    SLASH_COMMANDS["/outfit"] = OnOutfitCommand
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_OUTFIT_EQUIP_RESPONSE, OnOutfitEquipResponse)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, Initialize)
