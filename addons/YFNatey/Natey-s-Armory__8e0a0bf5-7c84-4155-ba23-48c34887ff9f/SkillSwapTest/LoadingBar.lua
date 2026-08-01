--=============================================================================
-- PROGRESS BAR CONTROL FUNCTIONS
--=============================================================================
function ArmoryM:ShowProgressBar()
    -- Check if progress bar is enabled in settings
    if self.savedVars.showProgressBar == false then
        return -- Don't show if disabled
    end

    if ArmoryM_ProgressBar then
        -- Apply saved position
        local x = self.savedVars.progressBarX or 0
        local y = self.savedVars.progressBarY or 300
        ArmoryM_ProgressBar:ClearAnchors()
        ArmoryM_ProgressBar:SetAnchor(CENTER, GuiRoot, CENTER, x, y)

        ArmoryM_ProgressBar:SetHidden(false)
        self:ResetProgressBar()
        self:SetProgressText("")
        ArmoryM:DebugPrint("Progress bar shown")
    end
end

function ArmoryM:HideProgressBar()
    if ArmoryM_ProgressBar then
        ArmoryM_ProgressBar:SetHidden(true)
    end
end

function ArmoryM:HideProgressBar()
    EVENT_MANAGER:UnregisterForUpdate("ArmoryM_EmergencyShutoff") -- Cancel emergency timer
    if ArmoryM_ProgressBar then
        ArmoryM_ProgressBar:SetHidden(true)
        ArmoryM:DebugPrint("Progress bar hidden")
    end
end

function ArmoryM:ResetProgressBar()
    -- Reset all phases to dark gray (incomplete)
    if ArmoryM_ProgressBarPhase1 then
        ArmoryM_ProgressBarPhase1:SetColor(0.3, 0.3, 0.3, 1)
    end
    if ArmoryM_ProgressBarPhase2 then
        ArmoryM_ProgressBarPhase2:SetColor(0.3, 0.3, 0.3, 1)
    end
    if ArmoryM_ProgressBarPhase3 then
        ArmoryM_ProgressBarPhase3:SetColor(0.3, 0.3, 0.3, 1)
    end
    if ArmoryM_ProgressBarPhase4 then
        ArmoryM_ProgressBarPhase4:SetColor(0.3, 0.3, 0.3, 1)
    end

    ArmoryM:DebugPrint("Progress bar reset")
end

function ArmoryM:SetPhaseComplete(phase)
    local phaseControl = _G["ArmoryM_ProgressBarPhase" .. phase]
    if phaseControl then
        phaseControl:SetColor(0.2, 0.8, 0.2, 1) -- Bright green for completed
        ArmoryM:DebugPrint("Phase " .. phase .. " marked complete")
    end
end

function ArmoryM:SetPhaseActive(phase)
    local phaseControl = _G["ArmoryM_ProgressBarPhase" .. phase]
    if phaseControl then
        phaseControl:SetColor(0.8, 0.8, 0.2, 1) -- Yellow for currently active
        ArmoryM:DebugPrint("Phase " .. phase .. " marked active")
    end
end

function ArmoryM:SetPhaseRetrying(phase)
    local phaseControl = _G["ArmoryM_ProgressBarPhase" .. phase]
    if phaseControl then
        phaseControl:SetColor(1, 0.5, 0, 1) -- Orange for retrying
        ArmoryM:DebugPrint("Phase " .. phase .. " marked retrying")
    end
end

function ArmoryM:SetProgressText(text)
    if ArmoryM_ProgressBarLabel then
        ArmoryM_ProgressBarLabel:SetText(text)
    end
end

--=============================================================================
-- INTEGRATION FUNCTIONS - Call these from your gear loading system
--=============================================================================

-- Phase 1: Unequipping (0-25%)
function ArmoryM:OnUnequipStart()
    self:ShowProgressBar()
    self:SetPhaseActive(1)
    self:SetProgressText("Clearing equipment...")
end

function ArmoryM:OnUnequipComplete()
    self:SetPhaseComplete(1)
    self:SetProgressText("Equipment cleared")

    -- Brief pause then move to next phase
    EVENT_MANAGER:RegisterForUpdate("ArmoryM_ProgressPhase2", 300, function()
        EVENT_MANAGER:UnregisterForUpdate("ArmoryM_ProgressPhase2")
        self:OnArmorStart()
    end)
end

-- Phase 2: Armor Loading (25-65%)
function ArmoryM:OnArmorStart()
    self:SetPhaseActive(2)
    self:SetProgressText("Loading armor...")
end

function ArmoryM:OnArmorProgress(itemsEquipped, totalItems)
    -- Optional: could show item count in text
    if totalItems > 0 then
        self:SetProgressText(string.format("Loading armor... (%d/%d)", itemsEquipped, totalItems))
    end
end

function ArmoryM:OnArmorComplete()
    self:SetPhaseComplete(2)
    self:SetProgressText("Armor loaded")

    -- Brief pause then move to weapons
    EVENT_MANAGER:RegisterForUpdate("ArmoryM_ProgressPhase3", 200, function()
        EVENT_MANAGER:UnregisterForUpdate("ArmoryM_ProgressPhase3")
        self:OnWeaponStart()
    end)
end

-- Phase 3: Weapon Loading (65-85%)
function ArmoryM:OnWeaponStart()
    self:SetPhaseActive(3)
    self:SetProgressText("Loading weapons...")
end

function ArmoryM:OnWeaponProgress(weaponsEquipped, totalWeapons)
    if totalWeapons > 0 then
        self:SetProgressText(string.format("Loading weapons... (%d/%d)", weaponsEquipped, totalWeapons))
    end
end

function ArmoryM:OnWeaponComplete()
    self:SetPhaseComplete(3)
    self:SetProgressText("Weapons loaded")

    -- Brief pause then move to verification
    EVENT_MANAGER:RegisterForUpdate("ArmoryM_ProgressPhase4", 200, function()
        EVENT_MANAGER:UnregisterForUpdate("ArmoryM_ProgressPhase4")
        self:OnVerificationStart()
    end)
end

-- Phase 4: Verification/Completion (85-100%)
function ArmoryM:OnVerificationStart()
    self:SetPhaseActive(4)

    if self.isRetrying then
        self:SetProgressText("Optimizing equipment...")
    else
        self:SetProgressText("Swap bars to finish.")
    end
end

function ArmoryM:OnRetryStart()
    -- Mark phase 4 as retrying (orange color)
    self:SetPhaseRetrying(4)
    self:SetProgressText("Optimizing weapon placement...")
end

function ArmoryM:OnLoadingComplete()
    self:SetPhaseComplete(4)

    if self.isRetrying then
        self:SetProgressText("Optimization complete!")
    else
        self:SetProgressText("Loading complete!")
    end

    -- Hide progress bar after a short delay
    EVENT_MANAGER:RegisterForUpdate("ArmoryM_HideProgress", 1500, function()
        EVENT_MANAGER:UnregisterForUpdate("ArmoryM_HideProgress")
        self:HideProgressBar()
    end)
end

function ArmoryM:OnItemEquipping(itemName, slot)
    local slotName = self:GetEquipSlotName(slot) or ("slot " .. slot)
    self:SetProgressText(string.format("Equipping %s...", itemName))
end

-- Enhanced version for weapon conflicts
function ArmoryM:OnWeaponConflict()
    self:SetPhaseRetrying(3)
    self:SetProgressText("Resolving weapon conflicts...")
end

-- Enhanced version for jewelry conflicts
function ArmoryM:OnJewelryConflict()
    self:SetProgressText("Resolving ring placement...")
end
