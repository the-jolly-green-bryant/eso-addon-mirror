--------------------------------------------------
-- ShibUI Target Bar Module
--------------------------------------------------
local SUI = SUI
local sv

SUI.TargetBar = SUI.TargetBar or {}
local TargetBar = SUI.TargetBar

local Log = function(...) SUI.Debug:Log("Target Bar", ...) end

--------------------------------------------------
-- Target Bar Styling
--------------------------------------------------
local TARGET_UNIT_FRAME = "ZO_TargetUnitFrame"

SecurePostHook("CreateControlFromVirtual", function(name, _, template, suffix)
    if template == TARGET_UNIT_FRAME then
        local control = GetControl(name, suffix)
        ApplyTemplateToControl(control, "SUI_TargetUnitFrame")
    end
end)


-----------------------------------------------------
-- Filter out non-hostile targets during combat
-- Based on CombatTopHealthbar from Masteroshi430
-- Togglable via keybind or /tbh command
-----------------------------------------------------

function TargetBar:ShowHostileOnly()
    if not IsPlayerActivated() then return end
    if not UNIT_FRAMES then return end

    self.targetFrame = ZO_UnitFrames_GetUnitFrame("reticleover")
    self.targetFrame:SetAnimateShowHide(false) -- Maybe needed to prevent animation glitches

    local targetHealth = self.targetFrame:GetHealth() or 0

    if targetHealth == 0 then
        self.targetFrame:SetHiddenForReason("disabled", true)
        return
    end

    if sv.showHostileOnly then
        if (IsUnitInCombat("player")) and GetUnitReaction("reticleover") == UNIT_REACTION_HOSTILE then
            self.targetFrame:SetHiddenForReason("disabled", false)
        else
            self.targetFrame:SetHiddenForReason("disabled", true)
        end
    else
        self.targetFrame:SetHiddenForReason("disabled", false)
    end
end

function TargetBar:Toggle()
    sv.showHostileOnly = not sv.showHostileOnly
    Log("Show only hostile targets: " .. (sv.showHostileOnly and "ON" or "OFF"), 0)
    self:ShowHostileOnly()
end

---------------------------------------------------
-- Event Handling
---------------------------------------------------

EVENT_MANAGER:RegisterForEvent("SUI_FilterHostileTargets", EVENT_RETICLE_TARGET_CHANGED,
    function() TargetBar:ShowHostileOnly() end)
EVENT_MANAGER:RegisterForEvent("SUI_FilterHostileTargets", EVENT_PLAYER_COMBAT_STATE,
    function() TargetBar:ShowHostileOnly() end)

---------------------------------------------------
-- Initialize Target Bar
---------------------------------------------------
function TargetBar:Initialize()
    sv = SUI.SavedVars.saved
    Log("Initialized")
    ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_TARGET_BAR_KEYBIND", "Toggle Target Bar Filter")
end
