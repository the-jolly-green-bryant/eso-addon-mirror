UCIC = {}

local function cStart(hex) return "|c" .. hex end --returns colour start for a string

local function cEnd() return "|r" end             --return colour end string

local function colorText(text, hex)
    return cStart(hex) .. text .. cEnd()
end

local currencyIcon = "|t24:24:esoui/art/currency/currency_telvar_64.dds|t"

local function GetNormalItemLinkMysteryItemLink(itemLink)
    local normalId = GetItemLinkItemId(itemLink)
    for k, v in pairs(UncofferedData.IC) do
        for _, i in ipairs(v) do
            if i == normalId then return Uncoffered.GetItemLinkFromId(k) end
        end
    end
end

local function GetInfoNormal(itemLink)
    --Ids of the sets that can drop from the coffer
    --IC coffers only have 1 set, so every set2 var will be 0 or nil!
    local hasSet1, setName1, numBonusus1, numNormalEquipped1, maxEquipped1, setId1, numPerfectedEquipped1 =
        GetItemLinkContainerSetInfo(itemLink, 1)

    local setCol = 0

    local total = 3


    for i = 4, 6 do --1 to 3 are the mask pieces. We need only the shoulders
        if Uncoffered.IsCollectedFromSetId(setId1, i) then
            setCol = setCol + 1
        end
    end


    local col = setCol
    local expectedCost = 20000

    --returns all the collected info
    return setId1, setCol, total, expectedCost
end

local function GetInfoMystery(itemLink)
    local cofferId = GetItemLinkItemId(itemLink)
    local col = 0
    local total = 0 + #UncofferedData.IC[cofferId] * 3

    local bestNormalCoffer = { ["id"] = nil, ["col"] = nil }
    for _, v in pairs(UncofferedData.IC[cofferId]) do
        --Counts the collected amount of shoulder and saves the highest amount of uncollected % in the table
        local normalItemLink = Uncoffered.GetItemLinkFromId(v)
        local setId1, setCol, t, expCost = GetInfoNormal(normalItemLink)
        col = setCol + col
        if not bestNormalCoffer["id"] or bestNormalCoffer["col"] > setCol then
            bestNormalCoffer["id"] = v
            bestNormalCoffer["col"] = setCol
        end
    end


    local bestNormalCofferItemLink = Uncoffered.GetItemLinkFromId(bestNormalCoffer["id"])
    local expectedCost = 10000 / ((total - col) / total)

    --returns all the collected info
    return col, total, expectedCost, bestNormalCofferItemLink
end

function UCIC.GetNormalText(itemLink)
    local normalCoffer = {}
    local mysteryCoffer = {}
    normalCoffer.setId1, normalCoffer.setCol, normalCoffer.total, normalCoffer.expectedCost =
        GetInfoNormal(itemLink)
    mysteryCoffer.col, mysteryCoffer.total, mysteryCoffer.expectedCost, mysteryCoffer.bestNormalCofferItemLink =
        GetInfoMystery(GetNormalItemLinkMysteryItemLink(itemLink))


    local line1 = string.format("%d/%d Collected (%.2f%%)\n", (normalCoffer.setCol),
        normalCoffer.total,
        (normalCoffer.setCol) / normalCoffer.total * 100)
    if normalCoffer.setCol >= normalCoffer.total then
        local line2 = "Everything has been collected. Well done!"
        return cStart("888888") .. line1 .. line2 .. cEnd()
    end
    local line2 = string.format("\n%s\nExpected cost for ANY new piece: %.1f%s",
        GetNormalItemLinkMysteryItemLink(itemLink),
        mysteryCoffer.expectedCost, currencyIcon)
    if mysteryCoffer.expectedCost < 20000 then
        local line3 = "The Expected Cost is lower on the Mystery Coffer.\nYou might want to buy that instead."
        return line1 .. line2 .. cStart("CC0000") .. line3 .. cEnd()
    end
    return line1 .. line2
end

function UCIC.GetMysteryText(itemLink)
    local mysteryCoffer = {}
    local normalCoffer = {}
    mysteryCoffer.col, mysteryCoffer.total, mysteryCoffer.expectedCost, mysteryCoffer.bestNormalCofferItemLink =
        GetInfoMystery(itemLink)
    normalCoffer.setId1, normalCoffer.setCol, normalCoffer.total, normalCoffer.expectedCost =
        GetInfoNormal(mysteryCoffer.bestNormalCofferItemLink)
    local bestCoffer = (mysteryCoffer.expectedCost < normalCoffer.expectedCost and itemLink or mysteryCoffer.bestNormalCofferItemLink)
    local bestExp = (mysteryCoffer.expectedCost < normalCoffer.expectedCost and mysteryCoffer.expectedCost or normalCoffer.expectedCost)

    local line1 = string.format("%d/%d Collected (%.2f%%)\n", mysteryCoffer.col, mysteryCoffer.total,
        mysteryCoffer.col / mysteryCoffer.total * 100)
    if mysteryCoffer.col >= mysteryCoffer.total then
        local line2 = "Everything has been collected. Well done!"
        return cStart("888888") .. line1 .. line2 .. cEnd()
    end
    local line2 = string.format("\nExpected Cost for a New Piece: %.1f%s\n", mysteryCoffer.expectedCost, currencyIcon)
    if mysteryCoffer.expectedCost >= 20000 then
        local line3 = "The Expected Cost is higher than that of a Curated Coffer!\nDon't buy!"
        return cStart("CC0000") .. line1 .. line2 .. line3 .. cEnd()
    end
end
