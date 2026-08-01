HT_Queue = HT_Queue or {}

local isLearning = false
local learnQueue = {}
local learnAttempts = {}
local learnRetryDelay = 2000

local function GetTimestamp()
    return os.date("%H:%M:%S")
end

local function Msg(text)
    CHAT_ROUTER:AddSystemMessage(string.format("[%s] [Hyborem's Tutor] %s", GetTimestamp(), text))
end

local function dDebug(msg)
    if not msg then return end
    local serverKey = GetWorldName()
    local vars = HyboremTutor_Vars and HyboremTutor_Vars[serverKey]
    if vars and vars.enableLogs then
        CHAT_SYSTEM:AddMessage(string.format("[%s] [HT DEBUG] %s", GetTimestamp(), msg))
    end
end

local function IsLPCAvailable()
    return LibPriceCache ~= nil and LibPriceCache.GetPrice ~= nil
end

local function GetVars()
    local serverKey = GetWorldName()
    HyboremTutor_Vars = HyboremTutor_Vars or {}
    HyboremTutor_Vars[serverKey] = HyboremTutor_Vars[serverKey] or {}
    return HyboremTutor_Vars[serverKey]
end

function HT_Queue.ShouldLearnNow(itemLink, charName)
    if not itemLink then return false end
    
    local vars = GetVars()
    
    -- Sprawdź czy postać jest wykluczona
    local excluded = vars.excludedCharacters or {}
    for _, excludedName in ipairs(excluded) do
        if excludedName == charName then
            dDebug("Character " .. charName .. " is excluded from learning")
            return false
        end
    end
    
    local category = HT_Knowledge.GetCategory(itemLink)

    if HT_Knowledge.IsKnownByChar(itemLink, charName) then 
        return false 
    end

    if category == "SCRIPT" then
        local scriptLearner = vars.scriptLearner or "0"
        local learnerName = HT_LAM.GetCharacterNameById(scriptLearner)
        if learnerName == "None selected" or learnerName ~= charName then 
            return false 
        end
        local isBound = itemLink:find("BIND_ON_PICKUP") ~= nil
        if isBound then return true end
        if not IsLPCAvailable() then
            return false
        end
        local price = LibPriceCache.GetPrice(itemLink) or 0
        local limit = HT_Knowledge.GetPriceLimit(category)
        return price > 0 and price <= limit
    end

    if category == "STYLE" then
        return false
    end

    local mySlot = nil
    for i = 1, 3 do
        local slot = vars["p"..i]
        if slot and slot.char ~= "0" and slot.char ~= "None selected" then
            local slotCharName = HT_LAM.GetCharacterNameById(slot.char)
            if slotCharName == charName then 
                mySlot = i
                break 
            end
        end
    end

    local hasPriority = mySlot and HT_Knowledge.HasPriority(category, mySlot) or false
    if hasPriority then 
        dDebug(string.format("Priority: %s has priority for %s - learning", charName, category))
        return true 
    end

    for i = 1, 3 do
        local slot = vars["p"..i]
        local pcharId = slot and slot.char
        if pcharId and pcharId ~= "0" and pcharId ~= "None selected" then
            local pcharName = HT_LAM.GetCharacterNameById(pcharId)
            if pcharName ~= charName then
                if HT_Knowledge.HasPriority(category, i) and not HT_Knowledge.IsKnownByChar(itemLink, pcharName) then
                    dDebug(string.format("Priority: %s has priority and doesn't know - saving for them", pcharName))
                    return false
                end
            end
        end
    end

    if not IsLPCAvailable() then
        return false
    end
    
    local price = LibPriceCache.GetPrice(itemLink) or 0
    local limit = HT_Knowledge.GetPriceLimit(category)
    
    if price <= 0 then
        return false
    end
    
    local should = price <= limit
    
    if should then
        dDebug(string.format("Price: %d <= %d - learning", price, limit))
    else
        dDebug(string.format("Price: %d > %d - not learning", price, limit))
    end
    
    return should
end

function HT_Queue.LearnAllFromInventory()
    local vars = GetVars()
    if not vars.autoLearnEnabled then
        return
    end
    
    if isLearning then
        return
    end
    
    learnQueue = {}
    learnAttempts = {}
    
    local char = GetUnitName("player")
    
    for slot = 0, GetBagSize(BAG_BACKPACK) - 1 do
        local link = GetItemLink(BAG_BACKPACK, slot)
        if link and HT_Knowledge.IsInterestingItemByLink(link) then
            if HT_Queue.ShouldLearnNow(link, char) then
                table.insert(learnQueue, {link = link, slot = slot})
                dDebug("Added to learn queue: " .. link)
            end
        end
    end
    
    if #learnQueue > 0 then
        Msg(string.format("Learning %d items from inventory", #learnQueue))
        HT_Queue.ProcessLearnQueue()
    end
end

function HT_Queue.ProcessLearnQueue()
    if #learnQueue == 0 then
        isLearning = false
        Msg("Learning complete")
        return
    end
    
    isLearning = true
    local item = table.remove(learnQueue, 1)
    learnAttempts[item.link] = 0
    
    HT_Queue.LearnSingleItem(item.link, item.slot)
end

local function UseItemSafe(bag, slot, itemLink)
    local success = pcall(function()
        CallSecureProtected("UseItem", bag, slot)
    end)
    if not success and itemLink then
        pcall(function()
            ZO_LinkHandler_OnLinkClicked(itemLink)
        end)
    end
end

function HT_Queue.LearnSingleItem(itemLink, slot)
    local charName = GetUnitName("player")
    
    if HT_Knowledge.IsKnownByChar(itemLink, charName) then
        HT_Queue.ProcessLearnQueue()
        return
    end
    
    UseItemSafe(BAG_BACKPACK, slot, itemLink)
    
    zo_callLater(function()
        local stillExists = false
        for checkSlot = 0, GetBagSize(BAG_BACKPACK) - 1 do
            if GetItemLink(BAG_BACKPACK, checkSlot) == itemLink then
                stillExists = true
                break
            end
        end
        
        if not stillExists then
            Msg(string.format("%s |c00FF00learned|r %s", charName, itemLink))
            HT_Queue.ProcessLearnQueue()
        else
            learnAttempts[itemLink] = (learnAttempts[itemLink] or 0) + 1
            if learnAttempts[itemLink] < 3 then
                Msg(string.format("|cFF8800Retry %d/3|r %s", learnAttempts[itemLink], itemLink))
                local newSlot = nil
                for s = 0, GetBagSize(BAG_BACKPACK) - 1 do
                    if GetItemLink(BAG_BACKPACK, s) == itemLink then
                        newSlot = s
                        break
                    end
                end
                if newSlot then
                    zo_callLater(function() 
                        HT_Queue.LearnSingleItem(itemLink, newSlot) 
                    end, learnRetryDelay)
                else
                    HT_Queue.ProcessLearnQueue()
                end
            else
                Msg(string.format("|cFF0000Failed after 3 attempts|r %s", itemLink))
                HT_Queue.ProcessLearnQueue()
            end
        end
    end, 1500)
end

function HT_Queue.IsLearning()
    return isLearning
end