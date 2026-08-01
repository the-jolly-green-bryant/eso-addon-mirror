local SousChef = SousChef
local u = SousChef.Utility
local m = SousChef.Media

function SousChef.HookTrading(...) 
    if SousChef.hookedDataFunction then return end
    SousChef.hookedDataFunction = TRADING_HOUSE.m_searchResultsList.dataTypes[1].setupCallback
    if SousChef.hookedDataFunction then
        TRADING_HOUSE.m_searchResultsList.dataTypes[1].setupCallback = function(...)
            local row, data = ...
            SousChef.hookedDataFunction(...)
            zo_callLater(function() SousChef.AddRankToSlot(row, {GetTradingHouseSearchResultItemLink, "slotIndex", nil}) end, 100)
        end
    else
        d("SousChef could not hook into the Trading House")
    end
end