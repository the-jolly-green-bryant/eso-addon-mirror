local HARDCORE = HARDCORE

local ID = "TrueSpammable"
local NS = "HARDCORE_TrueSpammable"

local ICON_TRUE_SPAMMABLE = "/esoui/art/actionbar/abilityframe64_up.dds"

local Rule = {
    id = ID,
    title = "True Spammable: one normal skill per bar",
    icon = ICON_TRUE_SPAMMABLE,
    defaultEnabled = false
}

Rule.active = false
Rule._lastAlertMs = 0

local HOTBARS = {
    HOTBAR_CATEGORY_PRIMARY,
    HOTBAR_CATEGORY_BACKUP
}

local FIRST_NORMAL_SLOT = ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + 1
local LAST_NORMAL_SLOT = ACTION_BAR_ULTIMATE_SLOT_INDEX

local function IsHardcoreActive()
    return HARDCORE and HARDCORE.saved and HARDCORE.saved.isActive
end

local function IsManagedHotbar(hotbarCategory)
    return hotbarCategory == HOTBAR_CATEGORY_PRIMARY or hotbarCategory == HOTBAR_CATEGORY_BACKUP
end

local function IsNormalSkillSlot(actionSlotIndex)
    return actionSlotIndex and actionSlotIndex >= FIRST_NORMAL_SLOT and actionSlotIndex <= LAST_NORMAL_SLOT
end

local function IsSlottedSkill(actionSlotIndex, hotbarCategory)
    local actionType = GetSlotType(actionSlotIndex, hotbarCategory)
    return actionType == ACTION_TYPE_ABILITY or actionType == ACTION_TYPE_CRAFTED_ABILITY
end

local function Alert(message)
    local now = GetFrameTimeMilliseconds()
    if now - Rule._lastAlertMs > 1500 then
        ZO_AlertNoSuppression(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK, message)
        Rule._lastAlertMs = now
    end
end

local function CountBarSkills(hotbarCategory)
    local count = 0
    for actionSlotIndex = FIRST_NORMAL_SLOT, LAST_NORMAL_SLOT do
        if IsSlottedSkill(actionSlotIndex, hotbarCategory) then
            count = count + 1
        end
    end
    return count
end

local function CheckTrueSpammable()
    if not (Rule.active and IsHardcoreActive()) then
        return
    end

    for _, hotbarCategory in ipairs(HOTBARS) do
        if CountBarSkills(hotbarCategory) > 1 then
            Alert("HARDCORE: True Spammable allows only one normal skill on each bar.")
            return
        end
    end
end

local function OnHotbarSlotUpdated(_, actionSlotIndex, hotbarCategory)
    if Rule.active and IsManagedHotbar(hotbarCategory) and IsNormalSkillSlot(actionSlotIndex) then
        zo_callLater(CheckTrueSpammable, 80)
    end
end

local function RegisterEvents()
    EVENT_MANAGER:UnregisterForEvent(NS .. "_SLOT", EVENT_HOTBAR_SLOT_UPDATED)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_ACTIVE", EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_ACTIVATED", EVENT_PLAYER_ACTIVATED)

    EVENT_MANAGER:RegisterForEvent(NS .. "_SLOT", EVENT_HOTBAR_SLOT_UPDATED, OnHotbarSlotUpdated)
    EVENT_MANAGER:RegisterForEvent(NS .. "_ACTIVE", EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED, function()
        zo_callLater(CheckTrueSpammable, 120)
    end)
    EVENT_MANAGER:RegisterForEvent(NS .. "_ACTIVATED", EVENT_PLAYER_ACTIVATED, function()
        zo_callLater(CheckTrueSpammable, 250)
    end)
end

local function UnregisterEvents()
    EVENT_MANAGER:UnregisterForEvent(NS .. "_SLOT", EVENT_HOTBAR_SLOT_UPDATED)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_ACTIVE", EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED)
    EVENT_MANAGER:UnregisterForEvent(NS .. "_ACTIVATED", EVENT_PLAYER_ACTIVATED)
end

function Rule:OnEnable()
    self.active = true
    RegisterEvents()
    zo_callLater(CheckTrueSpammable, 150)
end

function Rule:OnDisable()
    self.active = false
    UnregisterEvents()
end

function Rule:DebugStatus()
    d("True Spammable active=" .. tostring(Rule.active) ..
        " hardcoreActive=" .. tostring(IsHardcoreActive()))
end

function HARDCORE.DebugTrueSpammableStatus()
    Rule:DebugStatus()
end

function HARDCORE.DebugTrueSpammableCommand(action)
    action = action or "help"

    if action == "help" then
        d("True Spammable debug:")
        d("/hc debug truespammable status")
        d("/hc debug truespammable check")
        return
    end

    if action == "status" then
        Rule:DebugStatus()
        return
    end

    if action == "check" then
        CheckTrueSpammable()
        Rule:DebugStatus()
        return
    end

    d("Unknown True Spammable debug action: " .. tostring(action))
end

HARDCORE.RuleManager:RegisterRule(Rule)
