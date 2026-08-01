UCCyrodiil = {}

local function cStart(hex) return "|c" .. hex end --returns colour start for a string

local function cEnd() return "|r" end             --return colour end string

local function colorText(text, hex)
    return cStart(hex) .. text .. cEnd()
end

local currencyIcon = "|t24:24:esoui/art/currency/alliancepoints_64.dds|t"

local function GetInfoMask(itemLink)
    --Ids of the sets that can drop from the coffer
    --IC coffers only have 1 set, so every set2 var will be 0 or nil!
    local hasSet1, setName1, numBonusus1, numNormalEquipped1, maxEquipped1, setId1, numPerfectedEquipped1 =
        GetItemLinkContainerSetInfo(itemLink, 1)

    local col = 0

    local total = 3

    for i = 1, 3 do --1 to 3 are the mask pieces. We need only the shoulders
        if Uncoffered.IsCollectedFromSetId(setId1, i) then
            col = col + 1
        end
    end

    --returns all the collected info
    return setId1, col, total
end

local function GetInfoShoulder(itemLink)
    --Ids of the sets that can drop from the coffer
    --IC coffers only have 1 set, so every set2 var will be 0 or nil!
    local hasSet1, setName1, numBonusus1, numNormalEquipped1, maxEquipped1, setId1, numPerfectedEquipped1 =
        GetItemLinkContainerSetInfo(itemLink, 1)

    local col = 0

    local total = 3

    for i = 4, 6 do --1 to 3 are the mask pieces. We need only the shoulders
        if Uncoffered.IsCollectedFromSetId(setId1, i) then
            col = col + 1
        end
    end

    --returns all the collected info
    return setId1, col, total
end

function UCCyrodiil.GetShoulderText(itemLink)
    local normalCoffer = {}
    normalCoffer.setId1, normalCoffer.setCol, normalCoffer.total, normalCoffer.expectedCost =
        GetInfoShoulder(itemLink)


    local line1 = string.format("%d/%d Collected (%.2f%%)", (normalCoffer.setCol),
        normalCoffer.total,
        (normalCoffer.setCol) / normalCoffer.total * 100)
    if normalCoffer.setCol >= normalCoffer.total then
        local line2 = "\nEverything has been collected. Well done!"
        return cStart("888888") .. line1 .. line2 .. cEnd()
    end
    return line1
end

function UCCyrodiil.GetMaskText(itemLink)
    local normalCoffer = {}
    normalCoffer.setId1, normalCoffer.setCol, normalCoffer.total, normalCoffer.expectedCost =
        GetInfoMask(itemLink)


    local line1 = string.format("%d/%d Collected (%.2f%%)", (normalCoffer.setCol),
        normalCoffer.total,
        (normalCoffer.setCol) / normalCoffer.total * 100)
    if normalCoffer.setCol >= normalCoffer.total then
        local line2 = "\nEverything has been collected. Well done!"
        return cStart("888888") .. line1 .. line2 .. cEnd()
    end
    return line1
end
