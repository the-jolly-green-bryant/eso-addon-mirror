AutoTrans = {}
AutoTransSavedVariables = {}

AutoTrans.name = "AutoTrans"
local cooldown = 300
local cooldownTimer = 5000;

local function resetTables()
    AutoTransSavedVariables.containerNames = {"Transmutation Geode", "Uncracked Transmutation Geode",
                                              "Géode de transmutation", "Géode de transmutation intacte",
                                              "Transmutationsgeode", "intakte Transmutationsgeode"}
    AutoTransSavedVariables.containerIDs = {"134583", "134588", "134590", "134591", "134618"}
    --[[
        [134583] = true, -- White Transmutation Geode
        [134588] = true, -- Blue Transmutation Geode -- |H1:item:134588:122:1:0:0:0:5:10000:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h
        [134590] = true, -- Pink Transmutation Geode -- |H1:item:134590:123:1:0:0:0:5:10000:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h
        [134591] = true, -- Yellow Transmutation Geode -- |H1:item:134591:124:1:0:0:0:5:10000:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h
        [134618] = true, -- Yellow Uncracked Transmutation Geode -- |H1:item:134618:124:1:0:0:0:5:10000:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h
        ]]
    d("AutoTrans - Tables reset!")
    d("#containerNames = " ..tostring(#AutoTransSavedVariables.containerNames) .. " | #containerIDs = " ..tostring(#AutoTransSavedVariables.containerIDs))
end

local function GetItemIDFromLink(itemLink)
    return tonumber(string.match(itemLink, "|H%d:item:(%d+)"))
end

local function attemptOpenContainer(slot)
    if GetSlotCooldownInfo(1) > 0 or IsInteractionUsingInteractCamera() or SCENE_MANAGER:GetCurrentScene().name ==
        'interact' then
        zo_callLater(function()
            attemptOpenContainer(slot)
        end, math.max(GetSlotCooldownInfo(1) + 300, 300))
    else
        if IsProtectedFunction("UseItem") then
            CallSecureProtected("UseItem", BAG_BACKPACK, slot)
        else
            UseItem(BAG_BACKPACK, slot)
        end
    end
end

local function OnLootUpdated(event)
    local lootInfo = {GetLootTargetInfo()}
    for i = 1, #AutoTransSavedVariables.containerNames do
        local a, b = string.find(string.lower(lootInfo[1]), string.lower(AutoTransSavedVariables.containerNames[i]))
        if a then
            local numTransmute = GetCurrencyAmount(CURT_CHAOTIC_CREATIA, CURRENCY_LOCATION_ACCOUNT)
            local numLootTransmute = GetLootCurrency(CURT_CHAOTIC_CREATIA)
            if numLootTransmute == 0 or numTransmute + numLootTransmute <=
                GetMaxPossibleCurrency(5, CURRENCY_LOCATION_ACCOUNT) then
                LootAll()
                d("AutoTrans - Container opened")
            end
            return true
        end
    end
end

function AutoTrans.slotUpdateHandler(event, ...)
    if IsUnitSwimming("player") then
        return true
    end
    if IsUnitInCombat("player") then
        return true
    end
    if GetGameTimeMilliseconds() - cooldown < cooldownTimer then
        return true
    end
    cooldown = GetGameTimeMilliseconds()
    local numTransmute = GetCurrencyAmount(CURT_CHAOTIC_CREATIA, CURRENCY_LOCATION_ACCOUNT)
    if GetMaxPossibleCurrency(5, CURRENCY_LOCATION_ACCOUNT) - numTransmute < 50 then
        return true
    end
    if not FindFirstEmptySlotInBag(BAG_BACKPACK) then
        return true
    end
    for x = 0, GetBagSize(BAG_BACKPACK) do
        local link = GetItemLink(BAG_BACKPACK, x)
        for y = 1, #AutoTransSavedVariables.containerIDs do
            if tostring(GetItemIDFromLink(link)) == tostring(AutoTransSavedVariables.containerIDs[y]) then
                attemptOpenContainer(x)
            end
        end
    end
end

local function commandHandler(arg)
    a = string.match(arg, "%d+")
    b = string.match(arg, "%a+")
    if string.lower(arg) == "reset" then
        resetTables()
    elseif a then
        table.insert(AutoTransSavedVariables.containerIDs, arg)
        d("Added integer " .. arg .. " to containerIDs")
    elseif b then
        table.insert(AutoTransSavedVariables.containerNames, arg)
        d("Added string " .. arg .. " to containerNames")
    else
        d("Container ids:")
        for i, v in ipairs(AutoTransSavedVariables.containerIDs) do
            d(v)
        end
        d("Container names:")
        for i, v in ipairs(AutoTransSavedVariables.containerNames) do
            d(v)
        end
    end
end

function AutoTrans:Initialize()
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, self.slotUpdateHandler)
    ZO_PreHook(SYSTEMS:GetObject("loot"), "UpdateLootWindow", OnLootUpdated)
    SLASH_COMMANDS["/autotrans"] = commandHandler
    if (AutoTransSavedVariables.containerNames == nil) or (AutoTransSavedVariables.containerIDs == nil) then
        resetTables()
    end
    if (#AutoTransSavedVariables.containerNames < 6) or (#AutoTransSavedVariables.containerIDs < 5) then
        resetTables()
    end
end

function AutoTrans.OnAddOnLoaded(event, addonName)
    if addonName == AutoTrans.name then
        AutoTrans:Initialize()
    end
end

-- Finally, we'll register our event handler function to be called when the proper event occurs.
EVENT_MANAGER:RegisterForEvent(AutoTrans.name, EVENT_ADD_ON_LOADED, AutoTrans.OnAddOnLoaded)
