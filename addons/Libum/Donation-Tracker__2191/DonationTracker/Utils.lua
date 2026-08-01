---- Debug and output
DT.DEBUGMODE = false
DT.ERROR_WARN = 1
DT.ERROR_CRITICAL = 2

function DT.Debug(...)
    if DT.DEBUGMODE then d(...) end
end

function DT.DebugReplaceSender(mail)
    if DT.DEBUGMODE then    
        if not mail.IsSenderUser then
            local NAMES = {"@bob", "@george", "@robert", "@katie", "@jacob", "@vincent", "@roger", "@jake", "@emily", "@ricardo"}
            local newSender = NAMES[math.random(1, #NAMES + 1)]
            mail.Sender = newSender
            mail.IsSenderUser = true
        end
    end
end

function DT.Error(msg, level)
    if level == nil then level = DT.ERROR_WARN end
    CHAT_SYSTEM:AddMessage("ERROR:" .. msg)
end

function DT.SystemPrintf(...)
    CHAT_SYSTEM:AddMessage(string.format(...))
end

---- General functions
DT.QUALITY_COLORS = {TRASH="", NORMAL="b4b2b0", FINE="2cc50d", SUPERIOR="3991ff", EPIC="9f2df7", LEGENDARY="eec827"}
DT.QUALITY_NAME = {[0]="TRASH", [1]="NORMAL", [2]="FINE", [3]="SUPERIOR", [4]="EPIC", [5]="LEGENDARY"}

function DT.FormatColorText(str, hex)
    return string.format("|c%s%s|r", hex, str)
end

function DT.StartsWith(str, start)
   return str:sub(1, #start) == start
end

function DT.GetOrderedKeyList(tbl)
    local keys = {}
    for k,v in pairs(tbl) do
        table.insert(keys, k)
    end
    table.sort(keys)
    return keys
end

function DT.Clone(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[DT.Clone(orig_key)] = DT.Clone(orig_value)
        end
        setmetatable(copy, DT.Clone(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function DT.HasValue(list, val)
    for index, value in ipairs(list) do
        if value == val then
            return true
        end
    end
    return false
end

function DT.ArrayRemove(t, fnRemove)
    local j, n = 1, #t;

    for i=1,n do
        if not fnRemove(t, i, j) then
            -- Move i's kept value to j's position, if it's not already there.
            if (i ~= j) then
                t[j] = t[i];
                t[i] = nil;
            end
            j = j + 1; -- Increment position of where we'll place the next kept value.
        else
            t[i] = nil;
        end
    end

    return t;
end

---- Vouchers
function DT.MasterWritCost(link)
    -- Master writ price calculation with WritWorthy
    if WritWorthy ~= nil then
        local parser = WritWorthy.CreateParser(link)
        if not parser:ParseItemLink(link) then return nil end
        local mat_list = parser:ToMatList()
        return WritWorthy.MatRow.ListTotal(mat_list) or 0
    end
    return nil
end

-- MasterWritVoucherCount function is taken without permission from WritWorthy (unclear licensing)
function DT.MasterWritVoucherCount(item_link)
    -- Convert a Master Writ item_link into the integer number of
    -- writ vouchers it returns.
    -- local reward_text = GenerateMasterWritRewardText(item_link)
    local fields      = DT.GetItemLinkWritFields(item_link)
    return math.floor(0.5 + (fields.writ_reward / 10000))
end

-- GetItemLinkWritFields function is taken without permission from WritWorthy (unclear licensing)
function DT.GetItemLinkWritFields(item_link)
    -- Break an item_link string into its numeric pieces
    --
    -- The writ1..writ6 fields are what we really want.
    -- Their meanings change depending on the master writ type.
    --
    local x = { ZO_LinkHandler_ParseLink(item_link) }
    local o = {
        text             =          x[ 1]
    ,   link_style       = tonumber(x[ 2])
    ,   unknown3         = tonumber(x[ 3])
    ,   item_id          = tonumber(x[ 4])
    ,   sub_type         = tonumber(x[ 5])
    ,   internal_level   = tonumber(x[ 6])
    ,   enchant_id       = tonumber(x[ 7])
    ,   enchant_sub_type = tonumber(x[ 8])
    ,   enchant_level    = tonumber(x[ 9])
    ,   writ1            = tonumber(x[10])
    ,   writ2            = tonumber(x[11])
    ,   writ3            = tonumber(x[12])
    ,   writ4            = tonumber(x[13])
    ,   writ5            = tonumber(x[14])
    ,   writ6            = tonumber(x[15])
    ,   item_style       = tonumber(x[16])
    ,   is_crafted       = tonumber(x[17])
    ,   is_bound         = tonumber(x[18])
    ,   is_stolen        = tonumber(x[19])
    ,   charge_ct        = tonumber(x[20])
    ,   unknown21        = tonumber(x[21])
    ,   unknown22        = tonumber(x[22])
    ,   unknown23        = tonumber(x[23])
    ,   writ_reward      = tonumber(x[24])
    }

    -- d("text             = [ 1] = " .. tostring(o.text            ))
    -- d("link_style       = [ 2] = " .. tostring(o.link_style      ))
    -- d("item_id          = [ 4] = " .. tostring(o.item_id         ))
    -- d("sub_type         = [ 5] = " .. tostring(o.sub_type        ))
    -- d("internal_level   = [ 6] = " .. tostring(o.internal_level  ))
    -- d("enchant_id       = [ 7] = " .. tostring(o.enchant_id      ))
    -- d("enchant_sub_type = [ 8] = " .. tostring(o.enchant_sub_type))
    -- d("enchant_level    = [ 9] = " .. tostring(o.enchant_level   ))
    -- d("writ1            = [10] = " .. tostring(o.writ1           ))
    -- d("writ2            = [11] = " .. tostring(o.writ2           ))
    -- d("writ3            = [12] = " .. tostring(o.writ3           ))
    -- d("writ4            = [13] = " .. tostring(o.writ4           ))
    -- d("writ5            = [14] = " .. tostring(o.writ5           ))
    -- d("writ6            = [15] = " .. tostring(o.writ6           ))
    -- d("writ_reward      = [24] = " .. tostring(o.writ_reward     ))

    return o
end

---- Prices
function DT.TTCSuggestedPrice(link)
    if not link or not TamrielTradeCentrePrice then return nil end
    priceInfo = TamrielTradeCentrePrice:GetPriceInfo(link)
    return priceInfo ~= nil and priceInfo.SuggestedPrice or nil
end

function DT.TTCAvgPrice(link)
    if not link or not TamrielTradeCentrePrice then return nil end
    priceInfo = TamrielTradeCentrePrice:GetPriceInfo(link)
    return priceInfo ~= nil and priceInfo.Avg or nil
end


-- MMPrice function is taken without permission from WritWorthy (unclear licensing)
function DT.MMPrice(link)
    if not link then return nil end
    
    if MasterMerchant then
        local mm = MasterMerchant:itemStats(link, false)
        if not mm then return nil end
        if mm.avgPrice and 0 < mm.avgPrice then
            return mm.avgPrice
        end

                          -- Normal price lookup came up empty, try an
                          -- expanded time range.
                          --
                          -- MasterMerchant lacks an API to control time range,
                          -- it does this internally by polling the state of
                          -- control/shift-key modifiers (!).
                          --
                          -- So instead of using a non-existent API, we
                          -- monkey-patch MM with our own code that ignores
                          -- modifier keys and always returns a LOOONG time
                          -- range.
                          --
        local save_tc = MasterMerchant.TimeCheck
        MasterMerchant.TimeCheck
          = function(self)
              local daysRange = 100  -- 3+ months is long enough.
              return GetTimeStamp() - (86400 * daysRange), daysRange
            end
        mm = MasterMerchant:itemStats(link, false)
        MasterMerchant.TimeCheck = save_tc

        if not mm then return nil end
        return mm.avgPrice
    end

    -- Fallback to ATT if MM not installed.
    -- Thank you, Patros!
    if ArkadiusTradeTools and ArkadiusTradeTools.Modules and ArkadiusTradeTools.Modules.Sales then
        -- Try for a recent price: last 3 days. If nothing
        -- that recent, reach back for last 3+ months or so.
        local day_secs = 24*60*60
        local att = ArkadiusTradeTools.Modules.Sales:GetAveragePricePerItem(
                            link, GetTimeStamp() - (day_secs * 3))
        if (not att) or (att <= 0) then
            att = ArkadiusTradeTools.Modules.Sales:GetAveragePricePerItem(
                            link, GetTimeStamp() - (day_secs * 100))
        end
        if (not att) or (att <= 0) then
            return nil
        end
        return att
    end

    return nil
end

-- FormatMoney function is taken without permission from WritWorthy (unclear licensing)
function DT.FormatMoney(x)
    if x == nil then return "?" end
    return "|t16:16:EsoUI/Art/currency/currency_gold.dds|t" .. ZO_CurrencyControl_FormatCurrency(math.floor(0.5+x), false)
end