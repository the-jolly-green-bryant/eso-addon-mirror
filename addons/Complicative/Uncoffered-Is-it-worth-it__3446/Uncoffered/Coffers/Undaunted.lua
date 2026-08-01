UCUndaunted = {}

local function cStart(hex) return "|c" .. hex end --returns colour start for a string

local function cEnd() return "|r" end             --return colour end string

local currencyIcon = "|t24:24:esoui/art/currency/undauntedkey_64.dds|t"

local function GetNormalItemLinkMysteryItemLink(itemLink)
    local normalId = GetItemLinkItemId(itemLink)
    for k, v in pairs(UncofferedData.Undaunted) do
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
    local hasSet2, setName2, numBonusus2, numNormalEquipped2, maxEquipped2, setId2, numPerfectedEquipped2 =
        GetItemLinkContainerSetInfo(itemLink, 2)

    local setCol1 = 0
    local setCol2 = 0

    local total = 6


    for i = 4, 6 do --1 to 3 are the mask pieces. We need only the shoulders
        if Uncoffered.IsCollectedFromSetId(setId1, i) then
            setCol1 = setCol1 + 1
        end
        if Uncoffered.IsCollectedFromSetId(setId2, i) then
            setCol2 = setCol2 + 1
        end
    end


    local col = setCol1 + setCol2
    local expectedCost = 8

    --returns all the collected info
    return setId1, setCol1, setId2, setCol2, total, expectedCost
end

local function GetInfoMystery(itemLink)
    local cofferId = GetItemLinkItemId(itemLink)
    local col = 0
    local total = #UncofferedData.Undaunted[cofferId] * 3 * 2

    local bestNormalCoffer = { ["id"] = nil, ["col"] = nil }
    for _, v in pairs(UncofferedData.Undaunted[cofferId]) do
        --Counts the collected amount of shoulder and saves the highest amount of uncollected % in the table
        local normalItemLink = Uncoffered.GetItemLinkFromId(v)
        local setId1, setCol1, setId2, setCol2, t = GetInfoNormal(normalItemLink)
        col = setCol1 + setCol2 + col
        if not bestNormalCoffer["id"] or bestNormalCoffer["col"] > setCol1 + setCol2 then
            bestNormalCoffer["id"] = v
            bestNormalCoffer["col"] = setCol1 + setCol2
        end
    end


    local bestNormalCofferItemLink = Uncoffered.GetItemLinkFromId(bestNormalCoffer["id"])
    local expectedCost = 1 / ((total - col) / total)

    --returns all the collected info
    return col, total, expectedCost, bestNormalCofferItemLink
end


function UCUndaunted.GetNormalText(itemLink)
    local normalCoffer = {}
    local mysteryCoffer = {}
    normalCoffer.setId1, normalCoffer.setCol1, normalCoffer.setId2, normalCoffer.setCol2, normalCoffer.total, normalCoffer.expectedCost =
        GetInfoNormal(itemLink)
    mysteryCoffer.col, mysteryCoffer.total, mysteryCoffer.expectedCost, mysteryCoffer.bestNormalCofferItemLink =
        GetInfoMystery(GetNormalItemLinkMysteryItemLink(itemLink))

    local line1 = string.format("%d/%d Collected (%.2f%%)\n", (normalCoffer.setCol1 + normalCoffer.setCol2),
        normalCoffer.total,
        (normalCoffer.setCol1 + normalCoffer.setCol2) / normalCoffer.total * 100)
    if normalCoffer.setCol1 + normalCoffer.setCol2 >= normalCoffer.total then
        local line2 = "Everything has been collected. Well done!"
        return cStart("888888") .. line1 .. line2 .. cEnd()
    end
    local line2 = string.format("\n%s\nExpected cost for ANY new piece: %.1f%s",
        GetNormalItemLinkMysteryItemLink(itemLink),
        mysteryCoffer.expectedCost, currencyIcon)
    if mysteryCoffer.expectedCost < 8 then
        local line3 = "The Expected Cost is lower on Mystery Coffer.\nYou might want to buy that instead."
        return line1 .. line2 .. cStart("CC0000") .. line3 .. cEnd()
    end
    return line1 .. line2
end

function UCUndaunted.GetMysteryText(itemLink)
    local mysteryCoffer = {}
    local normalCoffer = {}
    mysteryCoffer.col, mysteryCoffer.total, mysteryCoffer.expectedCost, mysteryCoffer.bestNormalCofferItemLink =
        GetInfoMystery(itemLink)
    normalCoffer.setId1, normalCoffer.setCol1, normalCoffer.setId2, normalCoffer.setCol2, normalCoffer.total, normalCoffer.expectedCost =
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
    if mysteryCoffer.expectedCost >= 8 then
        local line3 = "The Expected Cost is higher than that of a Curated Coffer!\nDon't buy!"
        return cStart("CC0000") .. line1 .. line2 .. line3 .. cEnd()
    end

    return line1 .. line2
end
