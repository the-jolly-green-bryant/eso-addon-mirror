UCIA = {}

local function cStart(hex) return "|c" .. hex end --returns colour start for a string

local function cEnd() return "|r" end             --return colour end string

local function colorText(text, hex)
    return cStart(hex) .. text .. cEnd()
end

local currencyIcon = "|t24:24:esoui/art/currency/archivalfragments_64.dds|t"

local function GetInfo(itemLink)
    --Ids of the sets that can drop from the coffer
    --IC coffers only have 1 set, so every set2 var will be 0 or nil!
    local hasSet1, setName1, numBonusus1, numNormalEquipped1, maxEquipped1, setId1, numPerfectedEquipped1 =
        GetItemLinkContainerSetInfo(itemLink, 1)

    local col = 0

    local total = 36


    for i = 1, 36 do
        if Uncoffered.IsCollectedFromSetId(setId1, i) then
            col = col + 1
        end
    end

    local expectedCost = 2000 / ((total - col) / total)

    --returns all the collected info
    return setId1, col, total, expectedCost
end

function UCIA.GetNormalText(itemLink)
    local normalCoffer = {}
    normalCoffer.setId1, normalCoffer.setCol1, normalCoffer.total, normalCoffer.expectedCost =
        GetInfo(itemLink)

    local line1 = string.format("%d/%d Collected (%.2f%%)\n", normalCoffer.setCol1,
        normalCoffer.total,
        normalCoffer.setCol1 / normalCoffer.total * 100)
    if normalCoffer.setCol1 >= normalCoffer.total then
        local line2 = "Everything has been collected. Well done!"
        return cStart("888888") .. line1 .. line2 .. cEnd()
    end
    local line2 = string.format("\nExpected Cost for New Piece: %s %s\n",
        ZO_CommaDelimitDecimalNumber(zo_roundToNearest(normalCoffer.expectedCost, .1)), currencyIcon)
    if normalCoffer.expectedCost >= 15000 then
        local line3 = "The Expected Cost is higher than that of the Curated Coffer!\nDon't buy!"
        return cStart("CC0000") .. line1 .. line2 .. line3 .. cEnd()
    end
    return line1 .. line2
end

function UCIA.GetCuratedText(itemLink)
    local normalCoffer = {}
    normalCoffer.setId1, normalCoffer.setCol1, normalCoffer.total, normalCoffer.expectedCost =
        GetInfo(itemLink)

    local line1 = string.format("%d/%d Collected (%.2f%%)\n", normalCoffer.setCol1,
        normalCoffer.total,
        normalCoffer.setCol1 / normalCoffer.total * 100)
    if normalCoffer.setCol1 >= normalCoffer.total then
        local line2 = "Everything has been collected. Well done!"
        return cStart("888888") .. line1 .. line2 .. cEnd()
    end
    local line2 = string.format("\nExpected Cost from non-Curated Coffer:\n%s %s\n",
        ZO_CommaDelimitDecimalNumber(zo_roundToNearest(normalCoffer.expectedCost, .1)), currencyIcon)
    if normalCoffer.expectedCost < 15000 then
        local line3 = "The Expected Cost is lower on the non-Curated Coffer.\nYou might want to buy that instead."
        return line1 .. line2 .. cStart("CC0000") .. line3 .. cEnd()
    end
    return line1 .. line2
end
