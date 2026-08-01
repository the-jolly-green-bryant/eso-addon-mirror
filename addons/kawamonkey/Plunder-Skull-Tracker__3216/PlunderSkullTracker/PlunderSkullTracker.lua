local instancedZoneIds = {
    [890] = true, -- Rkundzelft
    [893] = true, -- Ruins of Kardala
    [895] = true, -- Rkhardahrk
    [897] = true, -- Chiselshriek Mine
    [899] = true, -- Mtharnaz
    [904] = true, -- Zalgaz's Den
    [906] = true, -- Hircine's Haunt
    [907] = true, -- Rahni'Za, School of Warriors
    [908] = true, -- Shada's Tear
    [909] = true, -- Seeker's Archive
    [910] = true, -- Elinhir Sewerworks
    [911] = true, -- Reinhold's Retreat
    [913] = true, -- The Mage's Staff
    [914] = true, -- Skyreach Catacombs
    [915] = true, -- Skyreach Temple
    [916] = true, -- Skyreach Pinnacle
    [1272] = true, -- Atoll of Immolation
    [1274] = true, -- Garden of Shadows
    [1420] = true, -- Bastion Nymic
    [1436] = true, -- Infinite Archive
    [1475] = true, -- Seat of Detritus
}
local plunderSkullItemId = 190037
local dremoraPlunderSkullItemIds = {
    [190013] = 1, -- Arena
    [190014] = 2, -- Incursions
    [190015] = 3, -- Delve
    [190016] = 4, -- Dungeon
    [190017] = 5, -- Public & Sweeper
    [190018] = 6, -- Trial
    [190019] = 7, -- World
    [190038] = 8, -- Crowborne Horror
    [211125] = 9, -- Lord Hollowjack
    [211126] = 10, -- Infinite Archive
}
local plunderSkullAchievementId = 1542
local savedVars
local cooldownEnd

local function IsPlayerInInstancedContent()
    return GetCurrentZoneDungeonDifficulty() ~= DUNGEON_DIFFICULTY_NONE or instancedZoneIds[GetUnitWorldPosition("player")] == true
end

local function CheckBosses()
    if savedVars.resetTime < GetTimeStamp() then
        savedVars.resetTime = GetTimeStamp() + TIMED_ACTIVITIES_MANAGER:GetTimedActivityTypeTimeRemainingSeconds(TIMED_ACTIVITY_TYPE_DAILY)

        for _, bossType in pairs(dremoraPlunderSkullItemIds) do
            savedVars.bossTypes[bossType] = false
        end
    end
end

local function PlunderSkullCooldown()
    if cooldownEnd <= GetGameTimeMilliseconds() then
        PlunderSkullCooldownIndicator:SetHidden(true)
        EVENT_MANAGER:UnregisterForUpdate("PlunderSkullCooldown", 100)
    else
        if not IsPlayerInInstancedContent() then
            PlunderSkullCooldownIndicatorLabel:SetText(ZO_FormatTimeMilliseconds(cooldownEnd - GetGameTimeMilliseconds(), TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL))
            PlunderSkullCooldownIndicator:SetHidden(false)
        else
            PlunderSkullCooldownIndicator:SetHidden(true)
        end
    end
end

local function OnInventorySlotUpdate(_, bagId, slotIndex)
    local itemId = GetItemId(bagId, slotIndex)

    if itemId == plunderSkullItemId or dremoraPlunderSkullItemIds[itemId] ~= nil then
        if not IsPlayerInInstancedContent() and GetInteractionType() ~= INTERACTION_CONVERSATION then
            cooldownEnd = GetGameTimeMilliseconds() + 3 * 60 * 1000
            EVENT_MANAGER:RegisterForUpdate("PlunderSkullCooldown", 100, PlunderSkullCooldown)
            PlunderSkullCooldownIndicator:SetHidden(false)
        end

        if itemId ~= plunderSkullItemId then
            CheckBosses()

            local bossType = dremoraPlunderSkullItemIds[itemId]

            savedVars.bossTypes[bossType] = true
        end
    end
end

local function OnAddOnLoaded(_, addOnName)
	if addOnName == "PlunderSkullTracker" then
		savedVars = ZO_SavedVars:NewAccountWide("PlunderSkullTracker", 1, GetWorldName(), {["bossTypes"] = {}, ["resetTime"] = 0})

        EVENT_MANAGER:RegisterForEvent("PlunderSkullTracker", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnInventorySlotUpdate)
        EVENT_MANAGER:AddFilterForEvent("PlunderSkullTracker", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_IS_NEW_ITEM, true)
        EVENT_MANAGER:AddFilterForEvent("PlunderSkullTracker", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_BACKPACK)
        EVENT_MANAGER:AddFilterForEvent("PlunderSkullTracker", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)
	end
end

SLASH_COMMANDS[GetString(SI_PLUNDERSKULL_COMTRACKER)] = function ()
    CheckBosses()

    CHAT_ROUTER:AddSystemMessage(zo_strformat("|t18:18:<<1>>|t |c<<2>><<3>>|r", "/esoui/art/icons/event_halloween_dremora_skull_bucket.dds", "ffffff", GetString(SI_PLUNDERSKULL_NAME)))

    for _, bossType in pairs(dremoraPlunderSkullItemIds) do
        CHAT_ROUTER:AddSystemMessage(zo_strformat("|t14:14:<<1>>|t|c<<2>><<3>>|r", "/esoui/art/buttons/gamepad/gp_menu_rightarrow.dds", savedVars.bossTypes[bossType] == true and "00ff00" or "ff0000", GetString("SI_PLUNDERSKULL_BOSSTYPE", bossType)))
    end
end

SLASH_COMMANDS[GetString(SI_PLUNDERSKULL_COMACHIEVEMENT)] = function ()
    local name = GetAchievementInfo(plunderSkullAchievementId)
    local completed, required = select(2, GetAchievementCriterion(plunderSkullAchievementId, 1))

    CHAT_ROUTER:AddSystemMessage(zo_strformat("|t18:18:<<1>>|t |c<<2>><<3>>: <<4>> / <<5>>|r", "/esoui/art/icons/event_halloween_2016_skull_bucket.dds", completed == required and "00ff00" or "ff0000", name, completed, required))
end

EVENT_MANAGER:RegisterForEvent("PlunderSkullTracker", EVENT_ADD_ON_LOADED, OnAddOnLoaded)