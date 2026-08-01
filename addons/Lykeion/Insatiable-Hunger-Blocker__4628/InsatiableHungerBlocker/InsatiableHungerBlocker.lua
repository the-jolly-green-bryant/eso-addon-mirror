
local localizedNames = {
    ["de"] = "unersättlicher Hunger^m",
    ["en"] = "Insatiable Hunger",
    ["es"] = "hambre insaciable^fm",
    ["fr"] = "Faim insatiable^f",
    ["jp"] = "満たされぬ飢え",
    ["ru"] = "Ненасытный голод",
    ["zh"] = "无尽渴求",
}

local addonName = "InsatiableHungerBlocker"
local hungerIconFilename = "/esoui/art/icons/ability_werewolf_007.dds"
local hungerSkillId = 33208
local feedingFreezySkillId = 58775
local lastActiveTime = 0
local isCombatActive = false
local db
local SV_NAME = "InsatiableHungerBlocker_SV"
local defaults = {
    timeout = 2000,
    overlandEnabled = false,
    pounceEnabled = true,
    feedingpriority = false,
}

local function ShouldHide()
    local hasSynergy, _, iconFilename = GetCurrentSynergyInfo()
    return hasSynergy and iconFilename == hungerIconFilename and (db.overlandEnabled or IsUnitInDungeon("player"))
end

local function OnCombatEvent(_, result, _, _, _, _, _, _, targetName)
    if IsUnitInCombat("player") and targetName ~= GetRawUnitName("player") and
       (result == ACTION_RESULT_DAMAGE or result == ACTION_RESULT_CRITICAL_DAMAGE) then
        lastActiveTime = GetGameTimeMilliseconds()
    end
end

local function RestoreInsatiableHungeSynergyrInfo()
    if ShouldHide() then
        SHARED_INFORMATION_AREA:SetHidden(SYNERGY, isCombatActive)
        if not isCombatActive then
            -- the value of synergy info could be empty or wrong since they are hidden when they should be updated, so we need to set the text and icon back
            SYNERGY.action:SetText(localizedNames[GetCVar("language.2")] or localizedNames["en"])
            SYNERGY.icon:SetTexture(hungerIconFilename)
        end
    end
end

local function CombatIdleCheck()
    local now = GetGameTimeMilliseconds()
    local isActivating = (now - lastActiveTime) < db.timeout

    if isCombatActive ~= isActivating then
        isCombatActive = isActivating
        RestoreInsatiableHungeSynergyrInfo()
    end
end

local function OnCombatStateChange(_, inCombat)
    if inCombat then
        isCombatActive = (GetGameTimeMilliseconds() - lastActiveTime) < db.timeout
        EVENT_MANAGER:RegisterForUpdate(addonName, db.timeout / 2, CombatIdleCheck)
    else
        isCombatActive = false
        lastActiveTime = 0
        EVENT_MANAGER:UnregisterForUpdate(addonName)
        RestoreInsatiableHungeSynergyrInfo()
    end
end

local function OnPlayerInit()
    EVENT_MANAGER:UnregisterForEvent(addonName .. "_INIT", EVENT_PLAYER_ACTIVATED)

    SetSynergyPriorityOverride(hungerSkillId, 10)
    if db.feedingpriority then
        SetSynergyPriorityOverride(feedingFreezySkillId, 4)
    end
    EVENT_MANAGER:RegisterForEvent(addonName, EVENT_PLAYER_COMBAT_STATE, OnCombatStateChange)
    EVENT_MANAGER:RegisterForEvent(addonName, EVENT_COMBAT_EVENT, OnCombatEvent)
    EVENT_MANAGER:AddFilterForEvent(addonName, EVENT_COMBAT_EVENT,
        REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER,
        REGISTER_FILTER_IS_ERROR, false)

    ZO_PreHook(SYNERGY, "OnSynergyAbilityChanged", function()
        if ShouldHide() and isCombatActive then
            SHARED_INFORMATION_AREA:SetHidden(SYNERGY, true)
            return true
        end
    end)

    ZO_PreHook("ZO_ActionBar_CanUseActionSlots", function()
        local slotNum = tonumber(debug.traceback():match('ACTION_BUTTON_(%d)'))
        if not db.pounceEnabled and GetUnitName("boss1") ~= "" and (GetSlotBoundId(slotNum) == 32632 or GetSlotBoundId(slotNum) == 39104 or GetSlotBoundId(slotNum) == 39105) then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, SI_RESPECRESULT10)
            return true
        end
    end)
end

local function PrintUsage()
    CHAT_ROUTER:AddSystemMessage("IHB Usage:")
    CHAT_ROUTER:AddSystemMessage("/ihb timeout {milliseconds}")
    CHAT_ROUTER:AddSystemMessage("/ihb overlandtoggle")
    CHAT_ROUTER:AddSystemMessage("/ihb pouncetoggle")
    CHAT_ROUTER:AddSystemMessage("/ihb feedingtoggle")
end

local function OnLoaded(_, name)
    if name ~= addonName then return end
    EVENT_MANAGER:UnregisterForEvent(addonName, EVENT_ADD_ON_LOADED)
    EVENT_MANAGER:RegisterForEvent(addonName .. "_INIT", EVENT_PLAYER_ACTIVATED, OnPlayerInit)

    local worldName = GetWorldName()
    db = ZO_SavedVars:NewAccountWide(SV_NAME, 1, nil, defaults, worldName)

    SLASH_COMMANDS["/ihb"] = function(commands)
        local args = {}
        for command in string.gmatch(commands, "%S+") do
            table.insert(args, command)
        end

        if #args == 0 then
            PrintUsage()
            return
        end

        if args[1] == "timeout" then
            local timeout = tonumber(args[2])
            if not timeout then
                CHAT_ROUTER:AddSystemMessage("IHB: " .. args[2] .. " is not a valid number, use /ihb timeout {milliseconds}")
            elseif timeout < 500 then
                CHAT_ROUTER:AddSystemMessage("IHB: Timeout given is too short. Please set it to at least 500ms")
            else
                db.timeout = timeout
                EVENT_MANAGER:UnregisterForUpdate(addonName)
                EVENT_MANAGER:RegisterForUpdate(addonName, db.timeout / 2, CombatIdleCheck)
                CHAT_ROUTER:AddSystemMessage("IHB: Timeout set to " .. timeout .. "ms")
            end
        elseif args[1] == "overlandtoggle" then
            db.overlandEnabled = not db.overlandEnabled
            CHAT_ROUTER:AddSystemMessage("IHB: Overland Mode " .. (db.overlandEnabled and "|cCC922FENABLED|r" or "|c215895DISABLED|r"))
        elseif args[1] == "feedingpriority" then
            db.feedingpriority = not db.feedingpriority
            if db.feedingpriority then
                SetSynergyPriorityOverride(feedingFreezySkillId, 4)
            else
                ClearSynergyPriorityOverride(feedingFreezySkillId)
            end
            CHAT_ROUTER:AddSystemMessage("IHB: Feeding Freezy Priority " .. (db.feedingpriority and "|cCC922FENABLED|r" or "|c215895DISABLED|r"))
        elseif args[1] == "pouncetoggle" then
            db.pounceEnabled = not db.pounceEnabled
            CHAT_ROUTER:AddSystemMessage("IHB: Pounce " .. (db.pounceEnabled and "|cCC922FENABLED|r" or "|c215895DISABLED|r"))
        end
    end
end

EVENT_MANAGER:RegisterForEvent(addonName, EVENT_ADD_ON_LOADED, OnLoaded)
