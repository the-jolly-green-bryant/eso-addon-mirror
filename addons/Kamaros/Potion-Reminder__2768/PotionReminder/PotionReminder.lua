PotionReminder = PotionReminder or {}
PotionReminder.name = "PotionReminder"
PotionReminder.version = "1.1.0"
PotionReminder.variableVersion = 1
PotionReminder.defaultSavedVariables = {
    xPos = math.floor((GuiRoot:GetWidth() - 306) / 2),
    yPos = math.floor((GuiRoot:GetHeight() - 68) / 2),
    notificationColour = { 1, 1, 1, 1 },
    autoHideNotification = true,
    notificationDuration = 2,
    notifyOnNormalDifficulty = true,
    notifyInTrashFights = false
}

---------------------------------------------------------------------------------------------------
-- Utilities
---------------------------------------------------------------------------------------------------

local function isPlayerParsing()
    return GetUnitType("reticleover") == UNIT_TYPE_CLIENT_CHARACTER
end

local function isPlayerInPvPZone()
    return IsPlayerInAvAWorld() or IsActiveWorldBattleground()
end

local function isPlayerInBossFight()
    return DoesUnitExist("boss1")
end

local function isPlayerInGroupInstance()
    return IsUnitInDungeon("player") -- Returns true for dungeons, arenas, and trials
end

local function isVeteranDifficulty()
    return GetCurrentZoneDungeonDifficulty() == DUNGEON_DIFFICULTY_VETERAN
end

local function isPlayerInSupportedFight()
    local inBossFight = isPlayerInBossFight()
    local inGroupInstance = isPlayerInGroupInstance()
    local inTrashFight = inGroupInstance and not inBossFight

    return isPlayerParsing() or
        isPlayerInPvPZone() or
        (inBossFight and not inGroupInstance) or
        ((PotionReminder.savedVariables.notifyOnNormalDifficulty or isVeteranDifficulty()) and (
            inBossFight or
            (PotionReminder.savedVariables.notifyInTrashFights and inTrashFight)
        ))
end

local function isPlayerDead()
    return IsUnitDead("player")
end

local function getPotionCount()
    return GetSlotItemCount(GetCurrentQuickslot(), HOTBAR_CATEGORY_QUICKSLOT_WHEEL) or 0
end

local function getPotionCooldown()
    local remaining, _, global, _ = GetSlotCooldownInfo(GetCurrentQuickslot(), HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
    return remaining, global
end

---------------------------------------------------------------------------------------------------
-- UI
---------------------------------------------------------------------------------------------------

function PotionReminder.showNotification()
    PotionReminderNotification:SetHidden(false)
end

function PotionReminder.hideNotification()
    PotionReminderNotification:SetHidden(true)
end

function PotionReminder.unlockUI()
    PotionReminderNotification:SetHidden(false)
    PotionReminderNotification:SetMovable(true)
    PotionReminderNotification:SetMouseEnabled(true)
end

function PotionReminder.lockUI()
    PotionReminderNotification:SetHidden(true)
    PotionReminderNotification:SetMovable(false)
    PotionReminderNotification:SetMouseEnabled(false)
end

function PotionReminder.setNotificationColour(colour)
    PotionReminderNotificationLabel:SetColor(unpack(colour))
end

---------------------------------------------------------------------------------------------------
-- Event handlers
---------------------------------------------------------------------------------------------------

function PotionReminder.onNotificationMoveStop()
    PotionReminder.savedVariables.xPos = PotionReminderNotification:GetLeft()
    PotionReminder.savedVariables.yPos = PotionReminderNotification:GetTop()
end

function PotionReminder.onPollPotionCooldown()
    if isPlayerInSupportedFight() and getPotionCount() > 0 then
        local remaining, globalCooldown = getPotionCooldown()
        if (remaining > 0 and not globalCooldown) or isPlayerDead() then
            PotionReminder.hasShownAlert = false
            PotionReminder.hideNotification()
        elseif not isPlayerDead() and not PotionReminder.hasShownAlert then
            PotionReminder.hasShownAlert = true
            PotionReminder.showNotification()
            PlaySound(SOUNDS.CHAMPION_POINTS_COMMITTED)

            if PotionReminder.savedVariables.autoHideNotification then
                local notificationDuration = PotionReminder.savedVariables.notificationDuration * 1000
                zo_callLater(PotionReminder.hideNotification, notificationDuration)                
            end
        end
    end
end

function PotionReminder.onCombatStateChanged(eventCode, inCombat)
    if inCombat then
        EVENT_MANAGER:RegisterForUpdate(PotionReminder.name .. "PollPotionCooldown", 200, PotionReminder.onPollPotionCooldown)
    else 
        EVENT_MANAGER:UnregisterForUpdate(PotionReminder.name .. "PollPotionCooldown")
        PotionReminder.hasShownAlert = false
        PotionReminder.hideNotification()
    end
end

---------------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------------

function PotionReminder.loadSavedVariables()
    PotionReminder.savedVariables = ZO_SavedVars:NewAccountWide("PotionReminderSavedVariables", PotionReminder.variableVersion, nil, PotionReminder.defaultSavedVariables)
end

function PotionReminder.restoreUISettings()
    local xPos = PotionReminder.savedVariables.xPos
    local yPos = PotionReminder.savedVariables.yPos
    local colour = PotionReminder.savedVariables.notificationColour
    PotionReminderNotification:ClearAnchors()
    PotionReminderNotification:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, xPos, yPos)
    PotionReminder.setNotificationColour(colour)
end

function PotionReminder.registerForEvents()
    EVENT_MANAGER:RegisterForEvent(PotionReminder.name .. "CombatState", EVENT_PLAYER_COMBAT_STATE, PotionReminder.onCombatStateChanged)
end

function PotionReminder.onAddOnLoaded(eventCode, addonName)
    if addonName ~= PotionReminder.name then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(PotionReminder.name, eventCode)

    PotionReminder.hasShownAlert = false
    PotionReminder.loadSavedVariables()
    PotionReminder.restoreUISettings()
    PotionReminder.setupMenu()
    PotionReminder.registerForEvents()
end

EVENT_MANAGER:RegisterForEvent(PotionReminder.name, EVENT_ADD_ON_LOADED, PotionReminder.onAddOnLoaded)