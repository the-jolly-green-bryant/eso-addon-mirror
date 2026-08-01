-- UF_Scan.lua
local UF = UnknownFilter

local function wipe(tbl) for k in pairs(tbl) do tbl[k] = nil end end

local function Safe_GetResultLink(i)
    if not GetTradingHouseSearchResultItemLink then return nil end
    local ok, link = pcall(GetTradingHouseSearchResultItemLink, i)
    if ok and type(link)=="string" and link ~= "" then return link end
    return nil
end

local function Safe_ItemId(link)
    if not (link and GetItemLinkItemId) then return nil end
    local ok, id = pcall(GetItemLinkItemId, link)
    if ok and type(id)=="number" and id > 0 then return id end
    return nil
end

UF._idxKeys = UF._idxKeys or { "resultIndex", "tradingHouseIndex", "searchResultIndex", "slotIndex", "index" }

function UF:ResultIndexFromRow(tbl)
    if type(tbl) ~= "table" then return nil end
    for _,k in ipairs(self._idxKeys) do
        local v = tbl[k]
        if type(v)=="number" and v>0 then return v end
    end
    local nests = { "itemData", "data", "details" }
    for _,n in ipairs(nests) do
        local sub = tbl[n]
        if type(sub)=="table" then
            for _,k in ipairs(self._idxKeys) do
                local v = sub[k]
                if type(v)=="number" and v>0 then return v end
            end
        end
    end
    return nil
end

function UF:DeepLink(v, depth)
    depth = (depth or 0)
    if depth > 5 or v == nil then return nil end
    local tv = type(v)
    if tv == "string" then
        if string.find(v, "|H", 1, true) then return v end
    elseif tv == "table" then
        if type(v.itemLink) == "string" and v.itemLink ~= "" then return v.itemLink end
        if type(v.link)     == "string" and v.link     ~= "" then return v.link end
        for _,k in ipairs({ "itemData", "data", "details", "payload", "value" }) do
            local s = v[k]
            if s then
                local got = self:DeepLink(s, depth+1)
                if got then return got end
            end
        end
        local n=0
        for _,vv in pairs(v) do
            n = n + 1
            if n > 60 then break end
            local got = self:DeepLink(vv, depth+1)
            if got then return got end
        end
    end
    return nil
end

function UF:GetBestEffortCount(maxProbe)
    local count, blanks = 0, 0
    local limit = tonumber(maxProbe) or 600
    for i = 1, limit do
        local l = Safe_GetResultLink(i)
        if l then count = count + 1; blanks = 0
        else blanks = blanks + 1; if blanks >= 3 then break end end
    end
    return count
end

function UF:BuildPassMaps(count)
    wipe(self._passByIndex)
    wipe(self._passByLink)
    self._passTotal = 0

    local mode = (self.saved and self.saved.mode) or self.MODE_OFF
    local printed = 0
    local maxDebugLines = (self.saved and self.saved.debugCap) or 80
    if not (self.saved and self.saved.debugScan) then maxDebugLines = 0 end

    local linkCap = 160

    for i = 1, math.max(count or 0, 0) do
        local link = Safe_GetResultLink(i)
        if link then
            self._passTotal = self._passTotal + 1

            local keep, how = self:Passes(link, mode)
            self._passByIndex[i] = keep

            if linkCap > 0 then
                local id = Safe_ItemId(link)
                if id and self._passByLink[id] == nil then
                    self._passByLink[id] = keep
                    linkCap = linkCap - 1
                end
            end

            if printed < maxDebugLines then
                self:Say(string.format("PASS #%d | via=%s | keep=%s", i, tostring(how), tostring(keep)))
                printed = printed + 1
            end
        end
    end

    self:Say(string.format("PassMaps built: total=%d | mode=%s", self._passTotal, self:ModeLabel(mode)))
end

function UF:BuildPassMapsBestEffort()
    local count = self:GetBestEffortCount(600)
    if count > 0 then
        self:BuildPassMaps(count)
    else
        self:Say("BestEffort: no API links found")
    end
end
