FCOCO = FCOCO or  {}
local FCOCompanion = FCOCO
if not FCOCompanion.isCompanionUnlocked then return end
------------------------------------------------------------------------------------------------------------------------
--[[
local ev = EVENT_MANAGER
local addonVars = FCOCompanion.addonVars
local addonName = addonVars.addonName
local ctrlVars = FCOCompanion.ctrlVars

local csk = COMPANION_SKILLS_KEYBOARD
local csg = COMPANION_SKILLS_GAMEPAD
local cs

local assignableActionBarSuffix = "AssignableActionBar"
local companionActionBar

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
local function updateCompanionSkillsVar()
    if IsInGamepadPreferredMode() then
        cs = COMPANION_SKILLS_GAMEPAD
    else
        cs = COMPANION_SKILLS_KEYBOARD
    end
    if cs == nil then return end
    companionActionBar = GetControl(cs.control, assignableActionBarSuffix) --ZO_CompanionSkills_Panel_Gamepad -> ZO_CompanionSkills_Panel_GamepadAssignableActionBar
    ctrlVars.companionSkills = cs
    ctrlVars.companionSkillsActionBar = companionActionBar
end
updateCompanionSkillsVar()

local function checkIfSlotIsLocked(actionBarSlotId)
    if actionBarSlotId < ACTION_BAR_FIRST_NORMAL_SLOT_INDEX then return end
    local hotbarData = ACTION_BAR_ASSIGNMENT_MANAGER:GetCurrentHotbar()
    if not hotbarData then return end
    if hotbarData:GetHotbarCategory() ~= HOTBAR_CATEGORY_COMPANION then return end
    --The slot seems to be unlocked within the action bar, but it sill shows:  "Slot is not unlocked.", -- SI_RESPECRESULT34
    local isLockedSlot = hotbarData:IsSlotLocked(actionBarSlotId)
d(string.format("[FCOCO]isLockedSlot %s: ", tostring(actionBarSlotId), tostring(isLockedSlot)))
    return isLockedSlot
end
FCOCompanion.IsCompanionSlotLocked = checkIfSlotIsLocked
]]

--[[
local function OnEVENT_ACTION_BAR_LOCKED_REASON_CHANGED(eventId, actionBarLockedReason)

end
ev:RegisterForEvent(addonName, EVENT_ACTION_BAR_LOCKED_REASON_CHANGED, OnEVENT_ACTION_BAR_LOCKED_REASON_CHANGED)
]]
