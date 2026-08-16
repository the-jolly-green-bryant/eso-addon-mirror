-- UF_Scan.lua
local UF = UnknownFilter

local function ClearTable(target)
    for key in pairs(target) do
        target[key] = nil
    end
end

local function SafeGetResultLink(index)
    if not GetTradingHouseSearchResultItemLink then
        return nil
    end

    local ok, link = pcall(GetTradingHouseSearchResultItemLink, index)
    if ok and type(link) == "string" and link ~= "" then
        return link
    end
    return nil
end

local function SafeGetItemId(link)
    if not (link and GetItemLinkItemId) then
        return nil
    end

    local ok, itemId = pcall(GetItemLinkItemId, link)
    if ok and type(itemId) == "number" and itemId > 0 then
        return itemId
    end
    return nil
end

function UF:GetCurrentServerResultCount()
    if TRADING_HOUSE_SEARCH and TRADING_HOUSE_SEARCH.GetNumItemsOnPage then
        local count = TRADING_HOUSE_SEARCH:GetNumItemsOnPage()
        if type(count) == "number" then
            return math.max(0, count)
        end
    end
    return 0
end

function UF:BuildPassMaps(count)
    ClearTable(self._passByIndex)
    ClearTable(self._passByLink)
    self._passTotal = 0

    local mode = (self.saved and self.saved.mode) or self.MODE_OFF
    local resultCount = tonumber(count) or self:GetCurrentServerResultCount()

    for index = 1, math.max(0, resultCount) do
        local link = SafeGetResultLink(index)
        if link then
            local keep = self:Passes(link, mode) == true
            self._passByIndex[index] = keep
            self._passTotal = self._passTotal + 1

            local itemId = SafeGetItemId(link)
            if itemId and self._passByLink[itemId] == nil then
                self._passByLink[itemId] = keep
            end
        end
    end
end

function UF:ClearResultCaches()
    ClearTable(self._passByIndex)
    ClearTable(self._passByLink)
    self._passTotal = 0
end
