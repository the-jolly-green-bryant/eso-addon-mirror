-- PreviewAnywhereBankActions.lua: Adds an item preview toggle to the gamepad
-- banking screen (player bank, house banks, and the ESO Plus Furnishing
-- Vault). Mirrors the vendor Buy screen flow (storewindowbuy_gamepad.lua):
-- toggle the interaction camera preview, then drive the preview from the
-- selected list entry, and drop back to the bank camera when the selection
-- can no longer be previewed.
--
-- Keybind choice: the keybind strip evicts a pre-existing button when a
-- duplicate keybind registers, and the banking screen already registers
-- RIGHT_STICK (bank upgrade), SECONDARY (rename), TERTIARY (actions),
-- QUATERNARY (stow all), and LEFT_STICK (sort/stack) regardless of their
-- visibility. D-pad right (UI_SHORTCUT_INPUT_RIGHT) is unclaimed in this
-- scene, so we use it.

local BankUtils = PreviewAnywhere.BankUtils

local BankActions = {}

local keybindAdded = false

local function IsBankPreviewActive()
    return ITEM_PREVIEW_GAMEPAD:IsInteractionCameraPreviewEnabled()
end

local function SetBankPreviewEnabled(enabled)
    if enabled ~= IsBankPreviewActive() then
        ITEM_PREVIEW_GAMEPAD:SetInteractionCameraPreviewEnabled(enabled, FRAME_TARGET_CENTERED_FRAGMENT, FRAME_PLAYER_ON_SCENE_HIDDEN_FRAGMENT, GAMEPAD_NAV_QUADRANT_2_3_FURNITURE_ITEM_PREVIEW_OPTIONS_FRAGMENT)
    end
end

local previewKeybindDescriptor =
{
    alignment = KEYBIND_STRIP_ALIGN_LEFT,
    keybind = "UI_SHORTCUT_INPUT_RIGHT",
    name = function()
        if IsBankPreviewActive() then
            return GetString(SI_CRAFTING_EXIT_PREVIEW_MODE)
        end
        return GetString(SI_CRAFTING_ENTER_PREVIEW_MODE)
    end,
    callback = function()
        BankActions.TogglePreview()
    end,
    visible = function()
        if not PreviewAnywhere.state.savedVars.enabled then
            return false
        end
        -- While previewing, always offer the exit action.
        if IsBankPreviewActive() then
            return true
        end
        if GAMEPAD_BANKING:IsHeaderActive() or not IsCharacterPreviewingAvailable() then
            return false
        end
        return BankUtils.IsEntryPreviewable(GAMEPAD_BANKING:GetTargetData())
    end,
}

local function RefreshPreviewKeybind()
    if keybindAdded then
        KEYBIND_STRIP:UpdateKeybindButton(previewKeybindDescriptor)
    end
end

---Preview the currently selected banking entry, or leave preview mode when the
---selection cannot be previewed (mirrors ZO_GamepadStoreBuy:UpdatePreview).
local function UpdatePreviewedEntry()
    if not IsBankPreviewActive() then
        return
    end

    local targetData = GAMEPAD_BANKING:GetTargetData()
    if BankUtils.IsEntryPreviewable(targetData) then
        local bagId, slotIndex = BankUtils.GetEntryBagAndSlot(targetData)
        ITEM_PREVIEW_GAMEPAD:ClearPreviewCollection()
        ITEM_PREVIEW_GAMEPAD:PreviewInventoryItem(bagId, slotIndex)
    else
        SetBankPreviewEnabled(false)
    end
end

function BankActions.TogglePreview()
    SetBankPreviewEnabled(not IsBankPreviewActive())
    UpdatePreviewedEntry()
    RefreshPreviewKeybind()
end

local function OnBankingSceneStateChange(_oldState, newState)
    if newState == SCENE_SHOWING then
        KEYBIND_STRIP:AddKeybindButton(previewKeybindDescriptor)
        keybindAdded = true
        PreviewAnywhere.diagnostics.bankSceneShows = PreviewAnywhere.diagnostics.bankSceneShows + 1
    elseif newState == SCENE_HIDING then
        -- Restore the interact camera before the bank interaction tears down.
        SetBankPreviewEnabled(false)
    elseif newState == SCENE_HIDDEN then
        if keybindAdded then
            KEYBIND_STRIP:RemoveKeybindButton(previewKeybindDescriptor)
            keybindAdded = false
        end
    end
end

---Post-hook body for ZO_GamepadBanking:OnTargetChangedCallback.
---@param banking table The ZO_GamepadBanking instance
local function OnBankTargetChanged(banking)
    if banking ~= GAMEPAD_BANKING or not keybindAdded then
        return
    end
    UpdatePreviewedEntry()
    RefreshPreviewKeybind()
end

function BankActions.Initialize()
    local bankingScene = SCENE_MANAGER:GetScene("gamepad_banking")
    if not bankingScene or not GAMEPAD_BANKING then
        PreviewAnywhere.Log("ERROR: gamepad banking scene not available; bank preview not installed")
        return
    end

    bankingScene:RegisterCallback("StateChange", OnBankingSceneStateChange)
    ZO_PostHook(ZO_GamepadBanking, "OnTargetChangedCallback", OnBankTargetChanged)
end

PreviewAnywhere.BankActions = BankActions
